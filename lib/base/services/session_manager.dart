import 'package:shared_preferences/shared_preferences.dart';

// 🚀 PRODUCTION CONFIGURATION:
// - Token expires after 1 year (365 days)
// - Refresh needed within 30 days of expiry
// - These values are suitable for production use

class SessionManager {
  static const String _tokenKey = 'session_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _lastLoginKey = 'last_login';

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
    final isVerified = prefs.getBool('session_verified') ?? false;
    return isVerified;
  }

  // Mark session as verified (after OTP completion)
  static Future<void> markSessionVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('session_verified', true);
  }

  // Clear verification status (when session expires)
  static Future<void> clearVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_verified');
  }

  // Save user session after successful authentication
  static Future<void> saveSession({
    required String token,
    required int userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    // Session starts as unverified (OTP pending)
    await prefs.setBool('session_verified', false);
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

  // Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_lastLoginKey);
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

  // Get backend user ID for profile creation
  static Future<int?> getBackendUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }
}
