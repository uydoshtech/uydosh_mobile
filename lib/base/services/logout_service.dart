import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uy_dosh/base/services/session_manager.dart';
import 'package:uy_dosh/base/logger/logger.dart';
import 'package:uy_dosh/base/state/authentication_state.dart';

import 'package:http/http.dart' as http;
import 'package:uy_dosh/base/util/environment_util.dart';

class LogoutService {
  static final LogoutService _instance = LogoutService._internal();
  factory LogoutService() => _instance;
  LogoutService._internal();

  /// Centralized logout method that handles Firebase, backend, and local logout
  /// Note: Success toast should be shown by the calling UI before calling this method
  Future<void> performLogout(BuildContext context) async {
    logger.d('🚪 Starting centralized logout process...');

    try {
      // 1. Sign out from Firebase (Google Sign-In)
      logger.d('🔥 Signing out from Firebase...');
      await FirebaseAuth.instance.signOut();
      logger.d('✅ Firebase sign out completed');

      // 2. Call backend logout endpoint if we have a session token
      final token = await SessionManager.getToken();
      logger.d('🎫 Session token: ${token != null ? "Found" : "Not found"}');

      if (token != null) {
        try {
          logger.d('🌐 Calling backend logout endpoint...');
          await _callBackendLogout(token);
          logger.d('✅ Backend logout completed');
        } catch (e) {
          logger.d('❌ Backend logout failed: $e');
          // Continue with local logout even if backend fails
        }
      }

      // 3. Clear local session
      logger.d('🗑️ Clearing local session...');
      await SessionManager.clearSession();
      logger.d('✅ Local session cleared');

      // 4. Update global authentication state
      logger.d('🔐 Updating global authentication state...');
      await AuthenticationState().logout();
      logger.d('✅ Global authentication state updated');
    } catch (e) {
      logger.d('❌ Logout error: $e');
      // Even if there's an error, try to clear local state
      try {
        await SessionManager.clearSession();
        await AuthenticationState().logout();
        logger.d('✅ Local logout completed despite error');
      } catch (localError) {
        logger.d('❌ Local logout also failed: $localError');
      }
    }
  }

  /// Call backend logout endpoint
  Future<void> _callBackendLogout(String token) async {
    final response = await http.post(
      Uri.parse('${EnvironmentUtil.basePath}/users/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Backend logout failed: ${response.statusCode}');
    }
  }
}
