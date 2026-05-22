import "package:flutter/foundation.dart" show kIsWeb;
import "package:telegram_login/telegram_login.dart";
import "package:uy_dosh/base/config/telegram_native_login_config.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Wraps the official Telegram Login native SDKs (via [TelegramLogin] plugin).
///
/// On success returns a JWT `id_token` to POST to `/users/telegram-auth`.
/// Returns `null` when the user cancels. Throws [TelegramLoginError] on failure.
class TelegramNativeLoginService {
  TelegramNativeLoginService._();

  static final TelegramNativeLoginService instance =
      TelegramNativeLoginService._();

  final TelegramLogin _login = TelegramLogin();
  var _configured = false;

  bool get isSupported => !kIsWeb && TelegramNativeLoginConfig.isConfigured;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    if (!TelegramNativeLoginConfig.isConfigured) {
      throw TelegramLoginError.notConfigured();
    }
    await _login.configure(
      TelegramLoginConfiguration(
        clientId: TelegramNativeLoginConfig.clientId,
        redirectUri: TelegramNativeLoginConfig.redirectUri,
        scopes: TelegramNativeLoginConfig.scopes,
        fallbackScheme: "uydosh",
      ),
    );
    _configured = true;
  }

  /// Starts native Telegram login. Returns JWT id_token or `null` if cancelled.
  Future<String?> login() async {
    if (kIsWeb) return null;
    await _ensureConfigured();
    try {
      final result = await _login.login();
      final token = result.idToken.trim();
      if (token.isEmpty) {
        throw TelegramLoginError.requestFailed(
          "Telegram login returned an empty id_token",
        );
      }
      return token;
    } on TelegramLoginError catch (e) {
      if (e.code == TelegramLoginErrorCode.cancelled) {
        logger.d("Telegram native login cancelled");
        return null;
      }
      rethrow;
    }
  }

  Future<void> cancelLogin() async {
    if (kIsWeb || !_configured) return;
    try {
      await _login.cancelLogin();
    } catch (e) {
      logger.d("Telegram native login cancel failed: $e");
    }
  }
}
