import "dart:async";

import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:permission_handler/permission_handler.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/navigation/top_named_route_tracker.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/services/device_info_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/push/register_fcm_token_request.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_pending_action.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";

final class _EmptyJson implements IJsonEncodable {
  const _EmptyJson();

  @override
  Map<String, dynamic> toJson() => const {};
}

/// Background message handler - must be top-level function.
@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.d("📲 FCM background message: ${message.messageId}");
}

abstract class IPushNotificationService {
  /// Initialize FCM wiring without prompting the OS permission alert.
  ///
  /// Important: do NOT call `requestPermission` here. We want the app to start
  /// without the iOS permission modal; permission should be requested from an
  /// explicit user action (e.g. Notifications screen, creating an alert).
  Future<void> initialize();

  /// Register the current FCM token with the backend (call after auth).
  Future<void> registerTokenWithBackend();

  /// Handle pending notification tap (call when app is ready, e.g. from MainNavigation).
  void handlePendingNotificationTap();

  /// Call from [MainNavigation.initState] when the tab shell has replaced splash.
  void markNavigationShellReady();

  /// Call from [MainNavigation.dispose] so taps while on auth / splash buffer safely.
  void markNavigationShellNotReady();

  /// Check if push notifications are supported on this platform.
  bool get isSupported;

  /// Get current notification permission status. Returns null if not supported.
  Future<AuthorizationStatus?> getNotificationStatus();

  /// Request permission again (e.g. from settings menu). When
  /// [openSettingsOnDenied] is true (default — kept for legacy callers), a
  /// denied result silently opens iOS Settings so the user can flip the
  /// switch manually. New callers gated by `NotificationPermissionGate`
  /// should pass `false` and handle the denied case themselves with a
  /// proper rationale screen instead of slamming the user into Settings.
  ///
  /// Returns true iff permission was granted and the FCM token was
  /// registered with the backend.
  Future<bool> requestPermissionAndRegister({
    bool openSettingsOnDenied = true,
  });

  /// Debug-only helper: ask backend to send a test push to this user.
  ///
  /// Returns a small status map so the UI can show whether sending is disabled
  /// on the server, or whether the send had failures.
  Future<Map<String, dynamic>> sendTestPushFromBackend();

  /// Debug helper: ask backend to send a test push to a specific FCM token.
  Future<Map<String, dynamic>> sendTestPushToToken(String token);
}

class PushNotificationService implements IPushNotificationService {
  PushNotificationService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;
  bool _handlersSetup = false;
  RemoteMessage? _pendingNotificationTap;

  /// When false, [FirebaseMessaging.onMessageOpenedApp] must not push routes yet —
  /// the root [Navigator] may still be showing splash; pushing chat first makes
  /// `QuickSplashScreen`'s `pushReplacement` replace the chat route (user bounces
  /// to home).
  bool _navigationShellReady = false;
  String? _lastRoutedTapKey;
  DateTime? _lastRoutedTapAt;
  bool _registerInFlight = false;
  int _registerRetryAttempt = 0;
  Timer? _registerRetryTimer;

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  bool get isSupported => _isSupported;

  @override
  Future<AuthorizationStatus?> getNotificationStatus() async {
    if (!_isSupported) return null;
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      logger.d("📲 Failed to get notification status: $e");
      return null;
    }
  }

  void _setupMessageHandlers() {
    if (_handlersSetup) return;
    _handlersSetup = true;
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    // Wire onTokenRefresh unconditionally. On iOS the first getToken() after
    // login often races ahead of APNs delivering the device token; when it
    // finally arrives the refresh listener is what gets us a real FCM token
    // and a successful register-with-backend.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      logger.d("📲 FCM token refreshed (len=${token.length})");
      registerTokenWithBackend();
    });
  }

  @override
  Future<void> initialize() async {
    if (!_isSupported) {
      logger.d("📲 Push notifications not supported on this platform");
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Set up handlers early. Even if permission is not granted yet, this
      // keeps `onTokenRefresh` wired for the moment APNs/FCM delivers a token
      // after the user enables notifications later.
      _setupMessageHandlers();

      // Do NOT request permission here (would show iOS system modal on launch).
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      logger.d(
          "📲 FCM permission status (no prompt): ${settings.authorizationStatus.name}");

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _pendingNotificationTap = initialMessage;
      }

      logger.d("📲 FCM initialized successfully");
    } catch (e) {
      logger.d("📲 FCM initialization error: $e");
    }
  }

  @override
  Future<bool> requestPermissionAndRegister({
    bool openSettingsOnDenied = true,
  }) async {
    if (!_isSupported) return false;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _setupMessageHandlers();
        await registerTokenWithBackend();
        logger.d("📲 Push notifications enabled");
        return true;
      }

      // Permission denied. Legacy callers want us to open Settings so the
      // user can flip the switch manually; gate-driven callers handle the
      // denied state with a rationale screen instead and pass `false`.
      if (openSettingsOnDenied) {
        await openAppSettings();
      }
      return false;
    } catch (e) {
      logger.d("📲 requestPermissionAndRegister error: $e");
      return false;
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    logger.d("📲 FCM foreground message: ${message.notification?.title}");
    // Refresh unread count; optionally show in-app banner
    _handleNewMessageNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    logger.d("📲 FCM notification tapped: ${message.data}");
    if (!_navigationShellReady) {
      _pendingNotificationTap = message;
      return;
    }
    _routeFromNotification(message);
  }

  void _handleNewMessageNotification(RemoteMessage message) {
    final data = message.data;
    if (data["type"] != "new_message") return;
    final conversationId = int.tryParse("${data["conversationId"] ?? ""}");
    UnreadMessagesState().incrementUnreadCount(conversationId: conversationId);
    // If user is currently viewing this conversation, let ChatScreen play the
    // sound after the bubble appears (better perceived sync).
    if (conversationId != null &&
        conversationId == UnreadMessagesState().activeConversationId) {
      return;
    }
    SoundService().playIncomingMessage();
  }

  String _notificationTapDedupeKey(RemoteMessage message) {
    final mid = message.messageId;
    if (mid != null && mid.isNotEmpty) return mid;
    final data = message.data;
    final type = "${data["type"] ?? ""}";
    return switch (type) {
      "search_match" => "$type:${data["listingId"] ?? ""}",
      "gig_bid_accepted" => type,
      "group_join_request" =>
        "$type:${data["listingId"] ?? ""}:${data["requestId"] ?? ""}",
      "group_join_accepted" => "$type:${data["listingId"] ?? ""}",
      "group_join_rejected" => "$type:${data["listingId"] ?? ""}",
      _ => "$type:${data["conversationId"] ?? ""}",
    };
  }

  void _routeFromNotification(RemoteMessage message) {
    final dedupeKey = _notificationTapDedupeKey(message);
    final now = DateTime.now();
    if (_lastRoutedTapKey == dedupeKey &&
        _lastRoutedTapAt != null &&
        now.difference(_lastRoutedTapAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastRoutedTapKey = dedupeKey;
    _lastRoutedTapAt = now;

    final type = message.data["type"] ?? "";
    if (type == "new_message") {
      _navigateToMessageIfApplicable(message);
    } else if (type == "search_match") {
      _navigateToListingFromSearchAlert(message);
    } else if (type == "gig_bid_accepted") {
      _navigateToMyGigBookingsAsProvider(message);
    } else if (type == "group_join_request") {
      _navigateToListingFromGroupPush(
        message,
        initialAction: ListingDetailPendingAction.openJoinRequests,
      );
    } else if (type == "group_join_accepted") {
      _navigateToListingFromGroupPush(
        message,
        initialAction: ListingDetailPendingAction.openGroupChat,
      );
    } else if (type == "group_join_rejected") {
      _navigateToListingFromGroupPush(message);
    }
  }

  /// When notification opens a chat that is **already** on screen (no new
  /// [ChatScreen] is pushed), [ChatScreen.initState] does not run again —
  /// trigger a message refetch so the tapped new message appears.
  void _requestChatRefreshForPush(int conversationId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = getIt<GlobalKey<NavigatorState>>();
      final nav = key.currentState;
      if (nav == null || !nav.mounted) return;
      final ctx = nav.overlay?.context ?? key.currentContext;
      if (ctx == null || !ctx.mounted) return;
      ctx.read<MessagingBloc>().add(
            RefreshMessages(conversationId: conversationId),
          );
    });
  }

  void _navigateToMessageIfApplicable(RemoteMessage message) {
    final data = message.data;
    if (data["type"] != "new_message") return;

    final conversationIdStr = data["conversationId"];
    final listingIdStr = data["listingId"];
    final senderIdStr = data["senderId"];
    final senderName = data["senderName"] ?? "Someone";

    final conversationId = int.tryParse(conversationIdStr ?? "");
    if (conversationId == null || conversationId <= 0) return;

    final listingId = int.tryParse(listingIdStr ?? "");
    final senderId = int.tryParse(senderIdStr ?? "");

    if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) return;
    final navigatorKey = getIt<GlobalKey<NavigatorState>>();
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    final targetName = ChatScreen.routeName(conversationId);
    nav.popUntil((route) {
      if (route.isFirst) return true;
      return route.settings.name == targetName;
    });

    if (topNamedRouteTracker.topName == targetName ||
        UnreadMessagesState().activeConversationId == conversationId) {
      _requestChatRefreshForPush(conversationId);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!nav.mounted) return;
      if (topNamedRouteTracker.topName == targetName ||
          UnreadMessagesState().activeConversationId == conversationId) {
        _requestChatRefreshForPush(conversationId);
        return;
      }

      nav.push<void>(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: targetName),
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            listingId: (listingId != null && listingId > 0) ? listingId : null,
            otherUserInitials: StringUtils.extractInitials(senderName),
            otherUserName: senderName,
            otherUserId: (senderId != null && senderId > 0) ? senderId : null,
            otherUserAvatar: null,
          ),
        ),
      );
      // Second fetch next frame: catches replication lag vs. initState's
      // [FetchMessages] and ensures the notification's message appears.
      _requestChatRefreshForPush(conversationId);
    });
  }

  void _navigateToMyGigBookingsAsProvider(RemoteMessage _) {
    if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) return;
    final navigatorKey = getIt<GlobalKey<NavigatorState>>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      ctx.pushMyGigBookings(initialRoleFilter: "provider");
    });
  }

  void _navigateToListingFromSearchAlert(RemoteMessage message) {
    _navigateToListingFromGroupPush(message);
  }

  void _navigateToListingFromGroupPush(
    RemoteMessage message, {
    ListingDetailPendingAction? initialAction,
  }) {
    final listingId = int.tryParse(message.data["listingId"] ?? "");
    if (listingId == null || listingId <= 0) return;

    if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) return;
    final navigatorKey = getIt<GlobalKey<NavigatorState>>();
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ListingDetailBloc(getIt<IListingService>()),
            ),
            BlocProvider(create: (_) => ListingDetailPageBloc()),
          ],
          child: ListingDetailScreen(
            listingId: listingId,
            initialPendingAction: initialAction,
          ),
        ),
      ),
    );
  }

  @override
  void handlePendingNotificationTap() {
    final pending = _pendingNotificationTap;
    _pendingNotificationTap = null;
    if (pending != null) {
      _routeFromNotification(pending);
    }
  }

  @override
  void markNavigationShellReady() {
    _navigationShellReady = true;
  }

  @override
  void markNavigationShellNotReady() {
    _navigationShellReady = false;
  }

  @override
  Future<void> registerTokenWithBackend() async {
    if (!_isSupported) return;

    // Backend derives userId from the Bearer session token; we shouldn't
    // depend on having `user_id` cached locally (it may not be stored yet).
    final sessionToken = await SessionManager.getToken();
    if (sessionToken == null || sessionToken.isEmpty) {
      logger.d("📲 Skipping FCM token registration: no backend session token");
      _registerRetryTimer?.cancel();
      _registerRetryTimer = null;
      _registerRetryAttempt = 0;
      return;
    }

    if (_registerInFlight) {
      logger.d("📲 FCM token registration already in-flight, skipping");
      return;
    }

    try {
      _registerInFlight = true;
      // On iOS, FirebaseMessaging.getToken() returns null until APNs has
      // handed the app a device token. Poll briefly so login-time registration
      // doesn't silently no-op during the cold-start APNs race. On Android
      // there's no APNs, so this is effectively a no-op wait.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _awaitApnsToken();
        if (apnsToken == null) {
          logger.d(
            "📲 APNs token not available after wait; onTokenRefresh will "
            "retry once it arrives",
          );
          // Don't bail: still attempt getToken() (it may already be available)
          // and schedule a retry if needed.
        }
        if (apnsToken != null) {
          logger.d("📲 APNs token acquired (len=${apnsToken.length})");
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        logger.d("📲 No FCM token available (getToken returned null)");
        _scheduleRegisterRetry();
        return;
      }

      final platform =
          defaultTargetPlatform == TargetPlatform.iOS ? "ios" : "android";
      final device = await DeviceInfoService.get();
      final request = RegisterFcmTokenRequest(
        token: token,
        platform: platform,
        deviceId: device.deviceId,
        deviceModel: device.deviceModel,
        osVersion: device.osVersion,
        appVersion: device.appVersion,
      );

      await _oauthApiClient.post<Map<String, dynamic>, RegisterFcmTokenRequest>(
        "/users/fcm-token",
        (json) => json as Map<String, dynamic>,
        data: request,
      );

      _registerRetryAttempt = 0;
      _registerRetryTimer?.cancel();
      _registerRetryTimer = null;
      logger.d(
        "📲 FCM token registered with backend "
        "(platform=$platform, device=${device.deviceModel ?? "?"})",
      );
    } catch (e) {
      logger.d("📲 FCM token registration failed: $e");
      _scheduleRegisterRetry();
    } finally {
      _registerInFlight = false;
    }
  }

  @override
  Future<Map<String, dynamic>> sendTestPushFromBackend() async {
    if (!_isSupported) {
      return {"ok": false, "error": "not_supported"};
    }
    try {
      final res = await _oauthApiClient.post<Map<String, dynamic>, _EmptyJson>(
        "/users/me/push-test",
        (json) => (json as Map).cast<String, dynamic>(),
        data: const _EmptyJson(),
      );
      return res;
    } catch (e) {
      logger.d("📲 sendTestPushFromBackend error: $e");
      return {"ok": false, "error": e.toString()};
    }
  }

  void _scheduleRegisterRetry() {
    // Avoid infinite loops; iOS can take a bit to deliver APNs/FCM token on cold start.
    const maxAttempts = 6;
    if (_registerRetryAttempt >= maxAttempts) {
      logger.d("📲 FCM token registration: max retry attempts reached");
      return;
    }
    _registerRetryAttempt += 1;
    final seconds = switch (_registerRetryAttempt) {
      1 => 2,
      2 => 5,
      3 => 10,
      4 => 20,
      5 => 40,
      _ => 60,
    };
    logger.d("📲 Scheduling FCM token registration retry in ${seconds}s");
    _registerRetryTimer?.cancel();
    _registerRetryTimer = Timer(Duration(seconds: seconds), () async {
      _registerRetryTimer = null;
      await registerTokenWithBackend();
    });
  }

  /// Poll `getAPNSToken()` a few times with small backoff so the first
  /// post-login call doesn't lose the race against APNs token delivery.
  /// Returns null if APNs still hasn't delivered a token after the wait
  /// window — in that case `onTokenRefresh` is the retry mechanism.
  Future<String?> _awaitApnsToken({
    int maxAttempts = 10,
    Duration step = const Duration(milliseconds: 500),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null && apns.isNotEmpty) return apns;
      } catch (e) {
        logger.d("📲 getAPNSToken threw: $e");
        return null;
      }
      await Future<void>.delayed(step);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> sendTestPushToToken(String token) async {
    if (!_isSupported) {
      return {"ok": false, "error": "not_supported"};
    }
    final t = token.trim();
    if (t.isEmpty) {
      return {"ok": false, "error": "missing_token"};
    }
    try {
      final res = await _oauthApiClient
          .post<Map<String, dynamic>, _SendPushTestRequest>(
        "/users/me/push-test",
        (json) => (json as Map).cast<String, dynamic>(),
        data: _SendPushTestRequest(token: t),
      );
      return res;
    } catch (e) {
      logger.d("📲 sendTestPushToToken error: $e");
      return {"ok": false, "error": e.toString()};
    }
  }
}

final class _SendPushTestRequest implements IJsonEncodable {
  const _SendPushTestRequest({required this.token});
  final String token;
  @override
  Map<String, dynamic> toJson() => {"token": token};
}
