import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:uy_dosh/base/api/auth_token_repository_i.dart";
import "package:uy_dosh/base/services/session_manager.dart";

class AuthTokenRepository implements IAuthTokenRepository {
  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";

  @override
  Future<String?> getAccessToken() async {
    // Use our session manager instead of separate storage
    final token = await SessionManager.getToken();
    debugPrint("🔑 AuthTokenRepository: getAccessToken called");
    debugPrint(
      "🔑 AuthTokenRepository: Token from SessionManager: ${token != null ? "exists" : "null"}",
    );
    if (token != null) {
      debugPrint("🔑 AuthTokenRepository: Token length: ${token.length}");
      debugPrint(
        "🔑 AuthTokenRepository: Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
      );
    }
    return token;
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  @override
  Future<void> saveTokens(String token) async {
    // This method is now deprecated - use SessionManager.saveSession instead
    // Keeping for backward compatibility but it won't be used
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setString(_refreshTokenKey, token);
  }

  @override
  Future<bool> refreshTokens() async {
    try {
      debugPrint(
        "🔄 AuthTokenRepository: Attempting to refresh Firebase token...",
      );

      // Get current Firebase user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint(
          "❌ AuthTokenRepository: No Firebase user found, cannot refresh token",
        );
        return false;
      }

      // Force refresh the Firebase ID token
      debugPrint(
        "🔄 AuthTokenRepository: Refreshing Firebase ID token for user: ${user.email}",
      );
      final newToken = await user.getIdToken(true); // force refresh

      if (newToken != null && newToken.isNotEmpty) {
        debugPrint(
          "✅ AuthTokenRepository: Successfully refreshed Firebase token",
        );
        debugPrint(
          "🔑 AuthTokenRepository: New token length: ${newToken.length}",
        );

        // Update the session with the new token
        await SessionManager.storeSessionToken(newToken);

        // Also update the last login timestamp to extend session validity
        await SessionManager.refreshSession();

        debugPrint("✅ AuthTokenRepository: Session updated with new token");
        return true;
      } else {
        debugPrint(
          "❌ AuthTokenRepository: Failed to get new token from Firebase",
        );
        return false;
      }
    } catch (e) {
      debugPrint("❌ AuthTokenRepository: Error refreshing tokens: $e");

      // If token refresh fails, clear the session to force re-authentication
      debugPrint(
        "🔄 AuthTokenRepository: Clearing session due to refresh failure",
      );
      await SessionManager.clearSession();

      return false;
    }
  }

  @override
  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearTokens() async {
    // Use our session manager to clear everything
    await SessionManager.clearSession();

    // Also clear the old storage keys for backward compatibility
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
