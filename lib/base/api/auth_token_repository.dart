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
    if (kDebugMode) {
      debugPrint("🔑 AuthTokenRepository: getAccessToken called");
      debugPrint(
        "🔑 AuthTokenRepository: Token from SessionManager: ${token != null ? "exists" : "null"}",
      );
      if (token != null) {
        debugPrint("🔑 AuthTokenRepository: Token length: ${token.length}");
      }
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
    // The backend session token is a DB-issued session id, not a Firebase
    // ID token. There's no client-side way to mint a new DB session token
    // from a Firebase refresh — that must go through the sign-in flow.
    //
    // Previously this method force-refreshed the Firebase ID token and
    // stored it as the session token, which the backend's session
    // verification always rejects. That bug caused "invalid session token"
    // loops after revocation. Return false so the 401 handler can kick
    // the user back to the auth wizard instead of silently failing.
    debugPrint(
      "🔄 AuthTokenRepository: refreshTokens() called — not supported, returning false",
    );
    return false;
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
