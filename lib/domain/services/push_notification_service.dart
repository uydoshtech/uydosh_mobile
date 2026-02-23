import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart" show kIsWeb, defaultTargetPlatform, TargetPlatform;
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/push/register_fcm_token_request.dart";

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
}

class PushNotificationService implements IPushNotificationService {
  PushNotificationService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize() async {
    if (!_isSupported) {
      logger.d("📲 Push notifications not supported on this platform");
      return;
    }

    try {
      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission (iOS shows dialog, Android 13+ shows dialog)
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

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Handle notification tap when app is in background/terminated
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        logger.d("📲 FCM token refreshed");
        registerTokenWithBackend();
      });

      logger.d("📲 FCM initialized successfully");
    } catch (e) {
      logger.d("📲 FCM initialization error: $e");
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    logger.d("📲 FCM foreground message: ${message.notification?.title}");
    // You can show an in-app banner or update UI here
  }

  void _handleNotificationTap(RemoteMessage message) {
    logger.d("📲 FCM notification tapped: ${message.data}");
    // Navigate based on message.data (e.g. conversationId, listingId)
    // Use a global navigator key or event bus
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
