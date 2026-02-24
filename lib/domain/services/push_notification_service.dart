import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart" show defaultTargetPlatform, kIsWeb, TargetPlatform;
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/push/register_fcm_token_request.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";

/// Background message handler - must be top-level function.
@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.d("📲 FCM background message: ${message.messageId}");
}

abstract class IPushNotificationService {
  /// Initialize FCM: request permission, get token, set up handlers.
  Future<void> initialize();

  /// Register the current FCM token with the backend (call after auth).
  Future<void> registerTokenWithBackend();

  /// Handle pending notification tap (call when app is ready, e.g. from MainNavigation).
  void handlePendingNotificationTap();

  /// Check if push notifications are supported on this platform.
  bool get isSupported;

  /// Get current notification permission status. Returns null if not supported.
  Future<AuthorizationStatus?> getNotificationStatus();

  /// Request permission again (e.g. from settings menu). On iOS, if denied,
  /// opens app settings. On Android, may show the permission dialog again.
  /// Returns true if permission was granted and token registered.
  Future<bool> requestPermissionAndRegister();
}

class PushNotificationService implements IPushNotificationService {
  PushNotificationService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;
  bool _handlersSetup = false;
  RemoteMessage? _pendingNotificationTap;

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
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      logger.d("📲 FCM token refreshed");
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
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.d("📲 Push notification permission denied");
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        logger.d("📲 Push notification permission provisional");
      }

      _setupMessageHandlers();

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
  Future<bool> requestPermissionAndRegister() async {
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

      // Permission denied. Open app settings so user can enable manually.
      await openAppSettings();
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
    _navigateToMessageIfApplicable(message);
  }

  void _handleNewMessageNotification(RemoteMessage message) {
    final data = message.data;
    if (data["type"] != "new_message") return;
    UnreadMessagesState().incrementUnreadCount();
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
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
  }

  @override
  void handlePendingNotificationTap() {
    final pending = _pendingNotificationTap;
    _pendingNotificationTap = null;
    if (pending != null) {
      _navigateToMessageIfApplicable(pending);
    }
  }

  @override
  Future<void> registerTokenWithBackend() async {
    if (!_isSupported) return;

    final userId = await SessionManager.getBackendUserId();
    if (userId == null) {
      logger.d("📲 Skipping FCM token registration: user not authenticated");
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        logger.d("📲 No FCM token available");
        return;
      }

      final platform =
          defaultTargetPlatform == TargetPlatform.iOS ? "ios" : "android";
      final request = RegisterFcmTokenRequest(token: token, platform: platform);

      await _oauthApiClient.post<Map<String, dynamic>, RegisterFcmTokenRequest>(
        "/users/fcm-token",
        (json) => json as Map<String, dynamic>,
        data: request,
      );

      logger.d("📲 FCM token registered with backend");
    } catch (e) {
      logger.d("📲 FCM token registration failed: $e");
    }
  }
}
