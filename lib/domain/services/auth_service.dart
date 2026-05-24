import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/auth/auth_request.dart";
import "package:uy_dosh/domain/models/auth/auth_response.dart";
import "package:uy_dosh/domain/models/auth/firebase_auth_request.dart";
import "package:uy_dosh/domain/models/auth/firebase_phone_auth_request.dart";

abstract class IAuthService {
  Future<AuthResponse> register(String email);
  Future<AuthResponse> login(String email);
  /// Authenticate with backend using Firebase credentials.
  /// Returns raw response with sessionToken, user, profileExists.
  Future<Map<String, dynamic>> firebaseAuth({
    required String email,
    required String firebaseUid,
    String? avatarUrl,
  });

  /// Authenticate with backend after a successful Firebase Phone Auth sign-in.
  /// [phoneNumber] must be in E.164 format (e.g. `+998901234567`) and must be
  /// the number that was verified by Firebase.
  Future<Map<String, dynamic>> firebasePhoneAuth({
    required String firebaseUid,
    required String phoneNumber,
    String? avatarUrl,
  });

  /// Best-effort: forward Apple's one-shot `authorization_code` to the
  /// backend so it can exchange it for a refresh token and persist it
  /// for later revocation at account-deletion time (App Review
  /// Guideline 5.1.1(v)). Failures must NOT block sign-in — the worst
  /// case is that account deletion can't revoke the Apple session,
  /// which the user can still do manually via Settings → Apple ID.
  Future<void> appleBind({required String authorizationCode});

  /// Current session + profile flags (Bearer = stored session token).
  Future<Map<String, dynamic>> verifySession();

  /// Telegram OIDC: GET `/users/telegram-oauth/start` (public). Browser fallback only.
  Future<String> fetchTelegramOAuthAuthorizationUrl({
    String? languageCode,
    String? returnTo,
  });

  /// Telegram native SDK / OIDC: POST `/users/telegram-auth` with JWT id_token.
  Future<Map<String, dynamic>> telegramAuthWithIdToken(String idToken);

  /// GET `/users/me` — identity fields for the authenticated user.
  Future<Map<String, dynamic>> fetchCurrentUser();

  /// POST `/users/telegram-bind` — link Telegram to the current account.
  Future<Map<String, dynamic>> telegramBind({required String idToken});

  /// DELETE `/users/telegram-unbind` — remove Telegram login from the current account.
  Future<Map<String, dynamic>> telegramUnbind();

  /// Authenticated Telegram OAuth URL for linking while logged in (browser fallback).
  Future<String> fetchTelegramOAuthBindAuthorizationUrl({
    String? languageCode,
    String? returnTo,
  });

  Future<bool> refreshToken();
  Future<void> logout();
}

class _AppleBindRequest implements IJsonEncodable {
  _AppleBindRequest({required this.authorizationCode});
  final String authorizationCode;

  @override
  Map<String, dynamic> toJson() => {
        "authorization_code": authorizationCode,
      };
}

class _EmptyJson implements IJsonEncodable {
  const _EmptyJson();
  @override
  Map<String, dynamic> toJson() => {};
}

class _TelegramIdTokenRequest implements IJsonEncodable {
  _TelegramIdTokenRequest({required this.idToken});
  final String idToken;

  @override
  Map<String, dynamic> toJson() => {"id_token": idToken};
}

class AuthService implements IAuthService {

  AuthService(this._apiClient, this._oauthApiClient);
  final IPublicApiClient _apiClient;
  final IOAuthApiClient _oauthApiClient;

  @override
  Future<AuthResponse> register(String email) async {
    try {
      final request = AuthRequest(email: email);
      final response = await _apiClient.post<AuthResponse, AuthRequest>(
        "/users/register",
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
      throw Exception("Failed to register user: $e");
    }
  }

  @override
  Future<AuthResponse> login(String email) async {
    try {
      final request = AuthRequest(email: email);
      final response = await _apiClient.post<AuthResponse, AuthRequest>(
        "/users/login",
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
      throw Exception("Failed to login user: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> firebaseAuth({
    required String email,
    required String firebaseUid,
    String? avatarUrl,
  }) async {
    try {
      final request = FirebaseAuthRequest(
        email: email,
        firebaseUid: firebaseUid,
        avatarUrl: avatarUrl,
      );
      final response = await _apiClient.post<Map<String, dynamic>, FirebaseAuthRequest>(
        "/users/firebase-auth",
        (json) => json as Map<String, dynamic>,
        data: request,
      );
      return response;
    } catch (e) {
      throw Exception("Firebase auth failed: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> firebasePhoneAuth({
    required String firebaseUid,
    required String phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final request = FirebasePhoneAuthRequest(
        firebaseUid: firebaseUid,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      final response = await _apiClient
          .post<Map<String, dynamic>, FirebasePhoneAuthRequest>(
        "/users/firebase-phone-auth",
        (json) => json as Map<String, dynamic>,
        data: request,
      );
      return response;
    } catch (e) {
      throw Exception("Firebase phone auth failed: $e");
    }
  }

  @override
  Future<void> appleBind({required String authorizationCode}) async {
    // Best-effort: never throw out of this method. The endpoint itself
    // also returns 200 on its own internal failures, so most errors
    // here are transport-level (network down, 401 from a stale token,
    // etc.). All non-fatal: account deletion will still work, it just
    // won't be able to revoke the Apple session at Apple's side.
    try {
      await _oauthApiClient
          .post<Map<String, dynamic>, _AppleBindRequest>(
        "/users/apple-bind",
        (json) => json is Map
            ? Map<String, dynamic>.from(json)
            : <String, dynamic>{},
        data: _AppleBindRequest(authorizationCode: authorizationCode),
      );
    } catch (e) {
      logger.d("Apple bind (non-fatal): $e");
    }
  }

  @override
  Future<Map<String, dynamic>> verifySession() async {
    try {
      return await _oauthApiClient.post<Map<String, dynamic>, _EmptyJson>(
        "/users/verify-session",
        (json) => json as Map<String, dynamic>,
        data: const _EmptyJson(),
      );
    } catch (e) {
      throw Exception("verify-session failed: $e");
    }
  }

  @override
  Future<String> fetchTelegramOAuthAuthorizationUrl({
    String? languageCode,
    String? returnTo,
  }) async {
    try {
      final lang = languageCode?.trim();
      final returnToTrimmed = returnTo?.trim();
      final queryParameters = <String, String>{};
      if (lang != null && lang.isNotEmpty) {
        queryParameters["lang"] = lang;
      }
      if (returnToTrimmed != null && returnToTrimmed.isNotEmpty) {
        queryParameters["return_to"] = returnToTrimmed;
      }
      final map = await _apiClient.get<Map<String, dynamic>>(
        "/users/telegram-oauth/start",
        (json) => json as Map<String, dynamic>,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final url = map["authorizationUrl"];
      if (url is! String || url.isEmpty) {
        throw Exception("Telegram OAuth URL missing");
      }
      return url;
    } catch (e) {
      throw Exception("Telegram OAuth start failed: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> telegramAuthWithIdToken(String idToken) async {
    try {
      final token = idToken.trim();
      if (token.isEmpty) {
        throw Exception("Telegram id_token is empty");
      }
      return await _apiClient.post<Map<String, dynamic>, _TelegramIdTokenRequest>(
        "/users/telegram-auth",
        (json) => json as Map<String, dynamic>,
        data: _TelegramIdTokenRequest(idToken: token),
      );
    } catch (e) {
      throw Exception("Telegram auth failed: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    return _oauthApiClient.get<Map<String, dynamic>>(
      "/users/me",
      (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Map<String, dynamic>> telegramBind({required String idToken}) async {
    final token = idToken.trim();
    if (token.isEmpty) {
      throw Exception("Telegram id_token is empty");
    }
    return _oauthApiClient.post<Map<String, dynamic>, _TelegramIdTokenRequest>(
      "/users/telegram-bind",
      (json) => json as Map<String, dynamic>,
      data: _TelegramIdTokenRequest(idToken: token),
    );
  }

  @override
  Future<Map<String, dynamic>> telegramUnbind() async {
    return _oauthApiClient.delete<Map<String, dynamic>, _EmptyJson>(
      "/users/telegram-unbind",
      (json) => json as Map<String, dynamic>,
      data: const _EmptyJson(),
    );
  }

  @override
  Future<String> fetchTelegramOAuthBindAuthorizationUrl({
    String? languageCode,
    String? returnTo,
  }) async {
    try {
      final lang = languageCode?.trim();
      final returnToTrimmed = returnTo?.trim();
      final queryParameters = <String, String>{};
      if (lang != null && lang.isNotEmpty) {
        queryParameters["lang"] = lang;
      }
      if (returnToTrimmed != null && returnToTrimmed.isNotEmpty) {
        queryParameters["return_to"] = returnToTrimmed;
      }
      final map = await _oauthApiClient.get<Map<String, dynamic>>(
        "/users/me/telegram-oauth/start",
        (json) => json as Map<String, dynamic>,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final url = map["authorizationUrl"];
      if (url is! String || url.isEmpty) {
        throw Exception("Telegram OAuth URL missing");
      }
      return url;
    } catch (e) {
      throw Exception("Telegram OAuth bind start failed: $e");
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
        logger.d("TODO: Implement backend logout call with token: $token");
      }
    } catch (e) {
      logger.d("Logout error: $e");
      // Continue with local logout even if backend call fails
    } finally {
      // Always clear local session
      await SessionManager.clearSession();
    }
  }
}
