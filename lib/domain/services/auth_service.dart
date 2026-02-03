import 'package:uy_dosh/domain/models/auth/auth_request.dart';
import 'package:uy_dosh/domain/models/auth/auth_response.dart';
import 'package:uy_dosh/base/api/client/public_api_client.dart';
import 'package:uy_dosh/base/logger/logger.dart';
import 'package:uy_dosh/base/services/session_manager.dart';

abstract class IAuthService {
  Future<AuthResponse> register(String email);
  Future<AuthResponse> login(String email);
  Future<bool> refreshToken();
  Future<void> logout(); // Add logout method
}

class AuthService implements IAuthService {
  final IPublicApiClient _apiClient;

  AuthService(this._apiClient);

  @override
  Future<AuthResponse> register(String email) async {
    try {
      final request = AuthRequest(email: email);
      final response = await _apiClient.post<AuthResponse, AuthRequest>(
        '/users/register',
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
        data: request,
      );

      // Save session after successful registration
      await SessionManager.saveSession(
        token: response.sessionToken,
        userId: response.user.id,
        email: response.user.email,
        role: response.user.role,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  @override
  Future<AuthResponse> login(String email) async {
    try {
      final request = AuthRequest(email: email);
      final response = await _apiClient.post<AuthResponse, AuthRequest>(
        '/users/login',
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
        data: request,
      );

      // Save session after successful login
      await SessionManager.saveSession(
        token: response.sessionToken,
        userId: response.user.id,
        email: response.user.email,
        role: response.user.role,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to login user: $e');
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final currentEmail = await SessionManager.getUserEmail();
      if (currentEmail == null) return false;

      // Try to login again to get a fresh token
      await login(currentEmail);

      // Session is already saved in login method
      return true;
    } catch (e) {
      // If refresh fails, clear the session
      await SessionManager.clearSession();
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Get current session token
      final token = await SessionManager.getToken();
      if (token != null) {
        // Call backend logout endpoint to invalidate server session
        // Note: You'll need to implement this with proper HTTP client
        // For now, we'll just clear local session
        logger.d('TODO: Implement backend logout call with token: $token');
      }
    } catch (e) {
      logger.d('Logout error: $e');
      // Continue with local logout even if backend call fails
    } finally {
      // Always clear local session
      await SessionManager.clearSession();
    }
  }
}
