import "package:uy_dosh/base/services/remote_config_service.dart";

/// Centralized access to environment-dependent settings.
///
/// History note: [basePath] used to be a `const` baked into the binary at
/// compile time. That meant any change to the API host required a forced
/// app store update for every existing install. It is now a runtime getter
/// that defers to [RemoteConfigService.apiBasePath], which resolves the
/// current value from Firebase Remote Config (with persistent caching and a
/// graceful fallback to [compileTimeBasePath] when offline / on first run).
///
/// [compileTimeBasePath] is preserved as a `const` so it can still be used
/// where the language requires a constant (e.g. default parameter values
/// that need to be `const`-evaluated). It is also the last-resort fallback
/// inside [RemoteConfigService].
abstract class EnvironmentUtil {
  /// Compile-time default for the API base URL. Used as the last-resort
  /// fallback by [RemoteConfigService] and as the default value for
  /// `String.fromEnvironment("API_BASE_PATH")` when developers want to
  /// override the URL via `--dart-define` at build time.
  ///
  /// Should be kept reasonably current so that fresh installs without any
  /// network at all can still reach the API on first launch — but it does
  /// NOT need to be perfectly up-to-date, since Remote Config will
  /// override it on the very first successful fetch.
  static const compileTimeBasePath = String.fromEnvironment(
    "API_BASE_PATH",
    defaultValue: "http://3.128.76.53:3000",
  );

  /// Current API base URL.
  ///
  /// Resolves at runtime from Remote Config (cached locally), falling back
  /// to [compileTimeBasePath] when Remote Config has not yet provided a
  /// value (e.g. very first call on a fresh install before RC fetch has
  /// completed, or when offline with no cache).
  static String get basePath => RemoteConfigService.apiBasePath;

  /// Web URL for shareable links (https). Messengers like Telegram only make
  /// https:// links clickable, not custom schemes like uydosh://.
  static const shareWebBase = String.fromEnvironment(
    "SHARE_WEB_BASE",
    defaultValue: "https://uydosh.app",
  );

  static String? apiBasePath(String api) {
    return const bool.hasEnvironment("API_BASE_PATH")
        ? '${const String.fromEnvironment('API_BASE_PATH')}/$api'
        : null;
  }

  static const termsOfService = String.fromEnvironment(
    "TERMS_OF_SERVICE",
    defaultValue: "URL",
  );

  static const privacyPolicy = String.fromEnvironment(
    "PRIVACY_POLICY",
    defaultValue: "https://uydoshtech.github.io/privacy-policy.html",
  );

  static const deleteAccount = String.fromEnvironment(
    "DELETE_ACCOUNT",
    defaultValue: "URL",
  );
}
