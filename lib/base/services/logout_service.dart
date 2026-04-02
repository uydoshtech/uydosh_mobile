import "package:dio/dio.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Thrown when account deletion is rejected because the account is blocked.
class AccountBlockedException implements Exception {}

class _EmptyDeleteRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

class LogoutService {
  factory LogoutService() => _instance;
  LogoutService._internal();
  static final LogoutService _instance = LogoutService._internal();

  /// Centralized logout method that handles Firebase, backend, and local logout
  /// Note: Success toast should be shown by the calling UI before calling this method
  Future<void> performLogout(BuildContext context) async {
    logger.d("🚪 Starting centralized logout process...");
    getIt<AppAnalyticsService>().logSignOut();
    await getIt<AppAnalyticsService>().setUserId(null);

    try {
      // 1. Sign out from Firebase (Google Sign-In)
      logger.d("🔥 Signing out from Firebase...");
      await FirebaseAuth.instance.signOut();
      logger.d("✅ Firebase sign out completed");

      // 2. Call backend logout endpoint if we have a session token
      final token = await SessionManager.getToken();
      logger.d('🎫 Session token: ${token != null ? "Found" : "Not found"}');

      if (token != null) {
        try {
          logger.d("🌐 Calling backend logout endpoint...");
          await _callBackendLogout();
          logger.d("✅ Backend logout completed");
        } catch (e) {
          logger.d("❌ Backend logout failed: $e");
          // Continue with local logout even if backend fails
        }
      }

      // 3. Clear local session
      logger.d("🗑️ Clearing local session...");
      await SessionManager.clearSession();
      ProfileCompletionState().reset();
      logger.d("✅ Local session cleared");

      // 4. Update global authentication state
      logger.d("🔐 Updating global authentication state...");
      await AuthenticationState().logout();
      logger.d("✅ Global authentication state updated");
    } catch (e) {
      logger.d("❌ Logout error: $e");
      // Even if there's an error, try to clear local state
      try {
        await SessionManager.clearSession();
        ProfileCompletionState().reset();
        await AuthenticationState().logout();
        logger.d("✅ Local logout completed despite error");
      } catch (localError) {
        logger.d("❌ Local logout also failed: $localError");
      }
    }
  }

  /// Call backend logout endpoint via Dio (uses OAuth interceptor for token)
  Future<void> _callBackendLogout() async {
    await getIt<IOAuthApiClient>().post<Map<String, dynamic>, _EmptyDeleteRequest>(
      "/users/logout",
      (json) => json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      data: _EmptyDeleteRequest(),
    );
  }

  /// Delete user account and then perform logout.
  /// Shows success toast before logout to avoid context issues after navigation.
  /// Throws [AccountBlockedException] if the account is blocked and deletion is not allowed.
  Future<void> performDeleteAccount(BuildContext context) async {
    logger.d("🗑️ Starting account deletion...");

    try {
      await getIt<IOAuthApiClient>().delete<Map<String, dynamic>, _EmptyDeleteRequest>(
        "/users/delete-account",
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AccountBlockedException();
      }
      rethrow;
    }

    logger.d("✅ Account deleted on backend");

    // Show success toast before logout (avoids context issues after navigation)
    final message = _getDeleteAccountSuccessMessage(context);
    ToastTheme.showSuccess(context, message: message);

    await performLogout(context);
    logger.d("✅ Delete account flow completed");
  }

  static String _getDeleteAccountSuccessMessage(BuildContext context) {
    try {
      return L10n.get("delete_account_success");
    } catch (_) {
      return "Account deleted successfully";
    }
  }
}
