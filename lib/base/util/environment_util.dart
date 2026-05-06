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

  /// Compile-time default for the Yandex Maps JS API key. Used as the
  /// last-resort fallback by [RemoteConfigService] (so map tiles still load
  /// on first launch before the first RC fetch completes) and as the
  /// `--dart-define` build-time override for engineers.
  ///
  /// Rotating this key requires an app update; rotating the value in
  /// Firebase Remote Config does not. Restrict the key in the Yandex
  /// console (HTTP referer / app bundle id) so an extracted copy is
  /// useless off-platform.
  static const compileTimeYandexMapsApiKey = String.fromEnvironment(
    "YANDEX_MAPS_API_KEY",
    defaultValue: "b7e30079-55fe-44d0-960c-50a03c3715e6",
  );

  /// Compile-time default for the primary Google Gemini API key. Last-resort
  /// fallback used by [RemoteConfigService] before the first successful RC
  /// fetch. Override via `--dart-define=GEMINI_API_KEY=…` at build time.
  ///
  /// `defaultValue: ""` deliberately fails closed: if Remote Config has not
  /// yet provided a key (and no `--dart-define` was supplied), the app
  /// reports Gemini as not configured rather than shipping a usable key in
  /// the binary. Real keys live in Firebase Remote Config so they can be
  /// rotated without an app update.
  static const compileTimeGeminiApiKey = String.fromEnvironment(
    "GEMINI_API_KEY",
    defaultValue: "",
  );

  /// Compile-time default for the secondary Google Gemini API key. Same
  /// rationale as [compileTimeGeminiApiKey]; used by the client as a
  /// fallback when the primary key returns a transient/key error. Note:
  /// per Google's docs, multiple keys under the same Cloud project share
  /// one quota pool — this is for resilience, not for doubling quota.
  static const compileTimeGeminiApiKey2 = String.fromEnvironment(
    "GEMINI_API_KEY_2",
    defaultValue: "",
  );

  /// Compile-time default for the max number of photos a user may attach
  /// to a single listing. Mirrors the Remote Config default — keep in
  /// sync with `_kDefaultMaxPhotosPerListing` in [RemoteConfigService] and
  /// with the `MAX_PHOTOS` constant in the backend Telegram-ingest worker.
  /// Override at build time with `--dart-define=MAX_PHOTOS_PER_LISTING=…`.
  static const compileTimeMaxPhotosPerListing = int.fromEnvironment(
    "MAX_PHOTOS_PER_LISTING",
    defaultValue: 5,
  );

  /// Compile-time default for the max number of photos a provider may
  /// attach to a single gig offer. Independent from
  /// [compileTimeMaxPhotosPerListing] — see
  /// `_kDefaultMaxPhotosPerGigOffer` in [RemoteConfigService] for the
  /// mirroring fallback chain. Override with
  /// `--dart-define=MAX_PHOTOS_PER_GIG_OFFER=…`.
  static const compileTimeMaxPhotosPerGigOffer = int.fromEnvironment(
    "MAX_PHOTOS_PER_GIG_OFFER",
    defaultValue: 5,
  );

  /// Current API base URL.
  ///
  /// Resolves at runtime from Remote Config (cached locally), falling back
  /// to [compileTimeBasePath] when Remote Config has not yet provided a
  /// value (e.g. very first call on a fresh install before RC fetch has
  /// completed, or when offline with no cache).
  static String get basePath => RemoteConfigService.apiBasePath;

  /// Paths such as `/images/gig-offers/1/1.jpg` stored on the API host.
  ///
  /// Used by image widgets: if a relative path is opened on Flutter Web without
  /// this prefix, the browser requests the **app** origin and may get HTML
  /// (e.g. the SPA shell) instead of bytes, which surfaces as a decode error.
  /// Prefix [basePath] for relative paths; leave `http(s)://…` unchanged.
  static String hostedImageUrl(String pathOrUrl) {
    final s = pathOrUrl.trim();
    if (s.isEmpty) return s;
    if (s.startsWith("http://") || s.startsWith("https://")) return s;
    return "$basePath$s";
  }

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

  /// Yandex Maps JS API key. Resolves at runtime from Remote Config,
  /// falling back to [compileTimeYandexMapsApiKey].
  static String get yandexMapsApiKey =>
      RemoteConfigService.yandexMapsApiKey;

  /// Primary Google Gemini API key. Resolves at runtime from Remote
  /// Config, falling back to [compileTimeGeminiApiKey] (empty by default;
  /// see that constant's doc for why).
  static String get geminiApiKey => RemoteConfigService.geminiApiKey;

  /// Secondary Google Gemini API key (same Cloud project as the primary;
  /// used for fallback on transient key errors). Resolves at runtime from
  /// Remote Config, falling back to [compileTimeGeminiApiKey2].
  static String get geminiApiKey2 => RemoteConfigService.geminiApiKey2;

  /// Max number of photos per listing. Resolves at runtime from Remote
  /// Config, falling back to [compileTimeMaxPhotosPerListing] when RC has
  /// not yet provided a value or the stored value is malformed.
  static int get maxPhotosPerListing =>
      RemoteConfigService.maxPhotosPerListing;

  /// Max number of photos per gig offer. Resolves at runtime from Remote
  /// Config, falling back to [compileTimeMaxPhotosPerGigOffer] when RC
  /// has not yet provided a value or the stored value is malformed.
  static int get maxPhotosPerGigOffer =>
      RemoteConfigService.maxPhotosPerGigOffer;

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
