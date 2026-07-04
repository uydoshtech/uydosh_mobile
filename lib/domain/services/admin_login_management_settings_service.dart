import "dart:convert";

import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

Map<String, dynamic> _requireJsonMap(dynamic response, String errorMessage) {
  dynamic decoded = response;
  if (response is String) {
    final s = response.trim();
    if (s.isEmpty) {
      throw Exception(errorMessage);
    }
    try {
      decoded = jsonDecode(s);
    } catch (_) {
      throw Exception(errorMessage);
    }
  }
  if (decoded is! Map) {
    throw Exception(errorMessage);
  }
  return Map<String, dynamic>.from(decoded);
}

/// Accepts bool, int, or common string forms (matches relaxed server parsers).
bool _parseBoolLoose(dynamic value, {required bool defaultValue}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final s = value.trim().toLowerCase();
    if (s == "true" || s == "1" || s == "yes") {
      return true;
    }
    if (s == "false" || s == "0" || s == "no") {
      return false;
    }
  }
  return defaultValue;
}

class LoginMethodEnabledResponse {
  LoginMethodEnabledResponse({required this.enabled});

  factory LoginMethodEnabledResponse.fromJson(Map<String, dynamic> json) {
    return LoginMethodEnabledResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: true),
    );
  }

  final bool enabled;
}

class _PatchLoginMethodEnabledRequest implements IJsonEncodable {
  _PatchLoginMethodEnabledRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

/// Backend-facing service for the admin "Login Management" section, where
/// admins can turn each sign-in provider on/off platform-wide.
abstract class IAdminLoginManagementSettingsService {
  Future<LoginMethodEnabledResponse> getGoogleSignInEnabledSetting();

  Future<LoginMethodEnabledResponse> setGoogleSignInEnabled({
    required bool enabled,
  });

  Future<LoginMethodEnabledResponse> getAppleSignInEnabledSetting();

  Future<LoginMethodEnabledResponse> setAppleSignInEnabled({
    required bool enabled,
  });

  Future<LoginMethodEnabledResponse> getTelegramSignInEnabledSetting();

  Future<LoginMethodEnabledResponse> setTelegramSignInEnabled({
    required bool enabled,
  });

  Future<LoginMethodEnabledResponse> getPhoneSignInEnabledSetting();

  Future<LoginMethodEnabledResponse> setPhoneSignInEnabled({
    required bool enabled,
  });
}

class AdminLoginManagementSettingsService
    implements IAdminLoginManagementSettingsService {
  AdminLoginManagementSettingsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  Future<LoginMethodEnabledResponse> _getEnabled(String path) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        path,
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return LoginMethodEnabledResponse.fromJson(
        _requireJsonMap(response, "Unexpected response from $path"),
      );
    } catch (e) {
      logger.d("Error loading login management setting ($path): $e");
      rethrow;
    }
  }

  Future<LoginMethodEnabledResponse> _setEnabled(
    String path, {
    required bool enabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        path,
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchLoginMethodEnabledRequest(enabled: enabled),
      );
      return LoginMethodEnabledResponse.fromJson(
        _requireJsonMap(response, "Unexpected response from $path"),
      );
    } catch (e) {
      logger.d("Error updating login management setting ($path): $e");
      rethrow;
    }
  }

  @override
  Future<LoginMethodEnabledResponse> getGoogleSignInEnabledSetting() =>
      _getEnabled("/admin/settings/google-sign-in-enabled");

  @override
  Future<LoginMethodEnabledResponse> setGoogleSignInEnabled({
    required bool enabled,
  }) =>
      _setEnabled(
        "/admin/settings/google-sign-in-enabled",
        enabled: enabled,
      );

  @override
  Future<LoginMethodEnabledResponse> getAppleSignInEnabledSetting() =>
      _getEnabled("/admin/settings/apple-sign-in-enabled");

  @override
  Future<LoginMethodEnabledResponse> setAppleSignInEnabled({
    required bool enabled,
  }) =>
      _setEnabled(
        "/admin/settings/apple-sign-in-enabled",
        enabled: enabled,
      );

  @override
  Future<LoginMethodEnabledResponse> getTelegramSignInEnabledSetting() =>
      _getEnabled("/admin/settings/telegram-sign-in-enabled");

  @override
  Future<LoginMethodEnabledResponse> setTelegramSignInEnabled({
    required bool enabled,
  }) =>
      _setEnabled(
        "/admin/settings/telegram-sign-in-enabled",
        enabled: enabled,
      );

  @override
  Future<LoginMethodEnabledResponse> getPhoneSignInEnabledSetting() =>
      _getEnabled("/admin/settings/phone-sign-in-enabled");

  @override
  Future<LoginMethodEnabledResponse> setPhoneSignInEnabled({
    required bool enabled,
  }) =>
      _setEnabled(
        "/admin/settings/phone-sign-in-enabled",
        enabled: enabled,
      );
}
