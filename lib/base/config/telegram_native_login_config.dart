import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Telegram Login **native SDK** configuration (iOS / Android).
///
/// Register each native app in @BotFather → Bot Settings → Login Widget →
/// Native Login. BotFather assigns a **platform-specific** App URL (not the
/// same as the bot OAuth client id domain).
///
/// Current production values (from BotFather):
/// - iOS App URL: `https://app3016986242-login.tg.dev`
/// - Android App URL: `https://app2183690589-login.tg.dev`
///
/// Add each host to iOS Associated Domains (`applinks:` + `webcredentials:`)
/// and Android App Links (Runner entitlements + AndroidManifest.xml).
abstract final class TelegramNativeLoginConfig {
  /// Bot client id from @BotFather (matches backend `TELEGRAM_OIDC_CLIENT_ID`).
  static const clientId = String.fromEnvironment(
    "TELEGRAM_OIDC_CLIENT_ID",
    defaultValue: "8088225152",
  );

  /// iOS native login redirect URI (copy App URL from BotFather → iOS entry).
  static const iosRedirectUri = String.fromEnvironment(
    "TELEGRAM_NATIVE_REDIRECT_URI_IOS",
    defaultValue: "https://app3016986242-login.tg.dev",
  );

  /// Android native login redirect URI (copy App URL from BotFather → Android).
  static const androidRedirectUri = String.fromEnvironment(
    "TELEGRAM_NATIVE_REDIRECT_URI_ANDROID",
    defaultValue: "https://app2183690589-login.tg.dev",
  );

  /// OAuth scopes requested from Telegram (openid is implicit in native SDK).
  static const scopes = ["profile"];

  /// Redirect URI for the current platform. Must match BotFather exactly.
  static String get redirectUri {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidRedirectUri;
    }
    return iosRedirectUri;
  }

  static bool get isConfigured {
    if (clientId.trim().isEmpty) return false;
    final uri = Uri.tryParse(redirectUri);
    return uri != null && uri.host.isNotEmpty;
  }

  static String? associatedDomainHostForPlatform(TargetPlatform platform) {
    final raw = platform == TargetPlatform.android
        ? androidRedirectUri
        : iosRedirectUri;
    final uri = Uri.tryParse(raw);
    return uri?.host.isNotEmpty == true ? uri!.host : null;
  }
}
