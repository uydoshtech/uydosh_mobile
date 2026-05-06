import "package:uy_dosh/base/services/remote_config_service.dart";

/// Centralized access to environment-dependent settings.
///
/// History note: several of these values used to be `const` strings baked
/// into the binary at compile time. That meant any change required a forced
/// app store update for every existing install. They are now runtime getters
/// that defer to [RemoteConfigService], which resolves the current value
/// from Firebase Remote Config (with persistent caching and graceful
/// fallback to the corresponding `compileTime*` constant when offline / on
/// first run).
///
/// The `compileTime*` constants are preserved as `const` so they can still
/// be used where the language requires a constant (e.g. default parameter
/// values that need to be `const`-evaluated). They are also the last-resort
/// fallback inside [RemoteConfigService].
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

  /// Compile-time default for the shareable https web base. See
  /// [shareWebBase] for the runtime accessor.
  static const compileTimeShareWebBase = String.fromEnvironment(
    "SHARE_WEB_BASE",
    defaultValue: "https://uydosh.app",
  );

  /// Compile-time default for the Terms of Service URL. See
  /// [termsOfService] for the runtime accessor.
  static const compileTimeTermsOfService = String.fromEnvironment(
    "TERMS_OF_SERVICE",
    defaultValue: "URL",
  );

  /// Compile-time default for the Privacy Policy URL. See [privacyPolicy]
  /// for the runtime accessor.
  static const compileTimePrivacyPolicy = String.fromEnvironment(
    "PRIVACY_POLICY",
    defaultValue: "https://uydoshtech.github.io/privacy-policy.html",
  );

  /// Compile-time default for the "delete account" URL. See [deleteAccount]
  /// for the runtime accessor.
  static const compileTimeDeleteAccount = String.fromEnvironment(
    "DELETE_ACCOUNT",
    defaultValue: "https://uydoshtech.github.io/delete-account.html",
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
  ///
  /// Resolves at runtime from Remote Config, falling back to
  /// [compileTimeShareWebBase].
  static String get shareWebBase => RemoteConfigService.shareWebBase;

  /// Public Terms of Service URL. Resolves at runtime from Remote Config,
  /// falling back to [compileTimeTermsOfService].
  static String get termsOfService => RemoteConfigService.termsOfServiceUrl;

  /// Public Privacy Policy URL. Resolves at runtime from Remote Config,
  /// falling back to [compileTimePrivacyPolicy].
  static String get privacyPolicy => RemoteConfigService.privacyPolicyUrl;

  /// Public "delete account" instructions URL. Resolves at runtime from
  /// Remote Config, falling back to [compileTimeDeleteAccount].
  static String get deleteAccount => RemoteConfigService.deleteAccountUrl;

  /// Convenience that returns `<API_BASE_PATH>/<api>` only when
  /// `API_BASE_PATH` was provided via `--dart-define` at build time,
  /// otherwise `null`. Intentionally uses the compile-time override (not
  /// Remote Config) — callers rely on this being null in default builds.
  static String? apiBasePath(String api) {
    return const bool.hasEnvironment("API_BASE_PATH")
        ? '${const String.fromEnvironment('API_BASE_PATH')}/$api'
        : null;
  }
}
