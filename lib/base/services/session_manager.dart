import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/domain/models/user_profile.dart";

// 🚀 PRODUCTION CONFIGURATION:
// - Token expires after 1 year (365 days)
// - Refresh needed within 30 days of expiry
// - These values are suitable for production use

class SessionManager {
  static const String _tokenKey = "session_token";
  static const String _userIdKey = "user_id";
  static const String _emailKey = "user_email";
  static const String _lastLoginKey = "last_login";
  static const String _userRoleKey = "user_role";
  static const String _userBlockedKey = "user_blocked";
  static const String _googleDisplayNameKey = "google_display_name";
  static const String _googlePhotoUrlKey = "google_photo_url";
  static const String _userProfileCacheKey = "user_profile_cache";
  static const String _chatSecurityRibbonDismissedKey =
      "chat_security_ribbon_dismissed";

  // Check if user is currently authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final lastLogin = prefs.getString(_lastLoginKey);

    if (token == null || lastLogin == null) {
      return false;
    }

    // Check if token is expired (1 year for production, adjust as needed)
    final lastLoginTime = DateTime.parse(lastLogin);
    final now = DateTime.now();
    final difference = now.difference(lastLoginTime);

    // Token expires after 1 year (365 days)
    if (difference.inDays > 365) {
      // Don't clear session immediately - let the app try to refresh
      return false;
    }

    return true;
  }

  // Check if session is fully verified (OTP completed)
  static Future<bool> isSessionVerified() async {
    final prefs = await SharedPreferences.getInstance();
    final isVerified = prefs.getBool("session_verified") ?? false;
    return isVerified;
  }

  // Mark session as verified (after OTP completion)
  static Future<void> markSessionVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("session_verified", true);
  }

  // Clear verification status (when session expires)
  static Future<void> clearVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("session_verified");
  }

  // Save user session after successful authentication
  static Future<void> saveSession({
    required String token,
    required int userId,
    required String email,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
    } else {
      await prefs.remove(_userRoleKey);
    }
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    // Session starts as unverified (OTP pending)
    await prefs.setBool("session_verified", false);
  }

  // Get current session token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Get current user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userBlockedKey);
    await prefs.remove(_lastLoginKey);
    await prefs.remove(_googleDisplayNameKey);
    await prefs.remove(_googlePhotoUrlKey);
    await prefs.remove(_userProfileCacheKey);
    await clearVerificationStatus();
  }

  // Refresh session timestamp (extend validity)
  static Future<void> refreshSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  // Check if token needs refresh (within 30 days of expiry for production)
  static Future<bool> needsTokenRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString(_lastLoginKey);

    if (lastLogin == null) return false;

    final lastLoginTime = DateTime.parse(lastLogin);
    final now = DateTime.now();
    final difference = now.difference(lastLoginTime);

    // Return true if token expires within 30 days (for production)
    return difference.inDays >= 335;
  }

  // Check if we have stored credentials for silent re-authentication
  static Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    return email != null;
  }

  // Get stored email for silent re-auth
  static Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Store email address (used during OTP verification flow)
  static Future<void> storeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // Store session token from Firebase authentication
  static Future<void> storeSessionToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  // Store backend user ID from Firebase authentication
  static Future<void> storeBackendUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  // Store user blocked status (violation)
  static Future<void> storeUserBlockedStatus(bool isBlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userBlockedKey, isBlocked);
  }

  // Get user blocked status
  static Future<bool> getIsUserBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userBlockedKey) ?? false;
  }

  // Store backend user role
  static Future<void> storeUserRole(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role == null) {
      await prefs.remove(_userRoleKey);
      return;
    }
    await prefs.setString(_userRoleKey, role);
  }

  // Get backend user ID for profile creation
  static Future<int?> getBackendUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Store Google profile data for fast access in UI
  static Future<void> storeGoogleProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (displayName != null && displayName.trim().isNotEmpty) {
      await prefs.setString(_googleDisplayNameKey, displayName.trim());
    } else {
      await prefs.remove(_googleDisplayNameKey);
    }
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      await prefs.setString(_googlePhotoUrlKey, photoUrl.trim());
    } else {
      await prefs.remove(_googlePhotoUrlKey);
    }
  }

  static Future<String?> getGoogleDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googleDisplayNameKey);
  }

  static Future<String?> getGooglePhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googlePhotoUrlKey);
  }

  // Store full user profile locally for fast UI rendering
  static Future<void> storeUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userProfileCacheKey,
      jsonEncode(profile.toJson()),
    );
  }

  static Future<UserProfile?> getCachedUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userProfileCacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json =
          jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (_) {
      await prefs.remove(_userProfileCacheKey);
      return null;
    }
  }

  static Future<bool> isChatSecurityRibbonDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chatSecurityRibbonDismissedKey) ?? false;
  }

  static Future<void> dismissChatSecurityRibbon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chatSecurityRibbonDismissedKey, true);
  }

  // ===== Per-conversation translation prefs =====
  // Keyed by conversationId so each chat remembers its own choice.
  static String _chatShowOriginalKey(int conversationId) =>
      "chat_show_original_$conversationId";
  static String _chatTranslationTargetKey(int conversationId) =>
      "chat_translation_target_$conversationId";

  static Future<bool> getChatShowOriginal(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chatShowOriginalKey(conversationId)) ?? false;
  }

  static Future<void> setChatShowOriginal(
    int conversationId,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_chatShowOriginalKey(conversationId), true);
    } else {
      await prefs.remove(_chatShowOriginalKey(conversationId));
    }
  }

  /// Returns the per-chat target language override (e.g. `"ru"`) or `null`
  /// when the chat should fall back to the user's profile language.
  static Future<String?> getChatTranslationTarget(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_chatTranslationTargetKey(conversationId));
    if (v == null || v.isEmpty) return null;
    return v;
  }

  static Future<void> setChatTranslationTarget(
    int conversationId,
    String? language,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (language == null || language.isEmpty) {
      await prefs.remove(_chatTranslationTargetKey(conversationId));
    } else {
      await prefs.setString(_chatTranslationTargetKey(conversationId), language);
    }
  }
}
