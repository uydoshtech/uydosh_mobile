import "dart:async" show unawaited;

import "package:firebase_remote_config/firebase_remote_config.dart";
import "package:flutter/foundation.dart" show ValueNotifier, kDebugMode;
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/constants/app_domains.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Resolves runtime-tunable client config (API base URL plus a small set of
/// public URLs surfaced in the UI) from Firebase Remote Config, with
/// persistent caching for offline / cold-start scenarios.
///
/// Why this exists:
///   The compile-time defaults in [EnvironmentUtil] are baked into the
///   binary at build time. If any of them ever changes (EC2 stop/start, ToS
///   URL update, privacy policy migration, etc.), every installed app
///   version with the stale value becomes broken on those flows — the only
///   fix would be a forced app store update. With Remote Config these
///   values become things we can change in seconds from the Firebase
///   Console, with no rebuild and no user-facing update.
///
/// Resolution order for every typed getter below:
///   1. Live in-memory value populated by the most recent successful fetch.
///   2. SharedPreferences cache from a previous run (instantly available
///      after [initialize] finishes, even offline).
///   3. The corresponding `EnvironmentUtil.compileTime*` constant —
///      last-resort fallback baked into the binary.
///
/// First-launch behavior:
///   When there is NO cached value for the API base URL (fresh install /
///   cleared storage), we block startup briefly (max
///   [_firstLaunchFetchTimeout]) waiting for the first fetch. This ensures
///   the very first network call uses a known-good URL even if the
///   compile-time default has gone stale. On subsequent launches the cache
///   is used immediately and the fetch happens in the background, so
///   cold-start time is unaffected.
///
/// Adding a new key:
///   1. Add a `_kSomething` constant.
///   2. Add it to [_defaults] mapped to its `EnvironmentUtil.compileTime*`
///      fallback.
///   3. Expose a typed getter that returns `_values[_kSomething]!`.
///   4. Configure the same key in the Firebase Console.
abstract class RemoteConfigService {
  static const _kApiBasePath = "api_base_path";
  static const _kShareWebBase = "share_web_base";
  static const _kTermsOfServiceUrl = "terms_of_service_url";
  static const _kPrivacyPolicyUrl = "privacy_policy_url";
  static const _kDeleteAccountUrl = "delete_account_url";
  static const _kYandexMapsApiKey = "yandex_maps_api_key";
  static const _kYandexGeosuggestApiKey = "yandex_geosuggest_api_key";
  static const _kGeminiApiKey = "gemini_api_key";
  static const _kGeminiApiKey2 = "gemini_api_key_2";
  static const _kUzsPerUsd = "uzs_per_usd";
  static const _kDefaultUzsPerUsd = "12600";

  /// Max number of photos a user may attach to a single listing. Stored as
  /// the stringified int (Remote Config doesn't have a native int type that
  /// plays nicely with our string-only `_values` map). Parsed lazily by
  /// [maxPhotosPerListing], which falls back to
  /// [_kDefaultMaxPhotosPerListing] on any malformed / non-positive value
  /// (e.g. someone fat-fingering "0" or "five" in the Firebase Console).
  static const _kMaxPhotosPerListing = "max_photos_per_listing";
  static const _kDefaultMaxPhotosPerListing = "5";

  /// Max number of photos a provider may attach to a single gig offer.
  /// Independent from [_kMaxPhotosPerListing] so the two can be tuned
  /// separately as the marketplaces evolve at different paces (a service
  /// listing typically wants fewer cover shots than a flat).
  static const _kMaxPhotosPerGigOffer = "max_photos_per_gig_offer";
  static const _kDefaultMaxPhotosPerGigOffer = "5";

  /// Boolean flag (stored as the string `"true"` / `"false"`) that controls
  /// whether the small floating labels above the create/edit-listing form
  /// fields (title, description, price, etc.) are rendered. Defaults to
  /// shown; flip in the Firebase Console to hide them globally without
  /// shipping a new build.
  static const _kShowListingFormFieldLabels =
      "show_listing_form_field_labels";

  /// Default value used both as the Firebase Remote Config default and as
  /// the seed for [showListingFormFieldLabels]. Defined as a constant so the
  /// two stay in sync.
  static const _kDefaultShowListingFormFieldLabels = "true";

  /// Prefix for SharedPreferences cache keys. The `api_base_path` cache key
  /// (`uydosh.remote_config.api_base_path`) intentionally matches the value
  /// used before the multi-key refactor so existing installs keep their
  /// cached URL across upgrade.
  static const _kPrefsCachePrefix = "uydosh.remote_config.";
  static const _firstLaunchFetchTimeout = Duration(seconds: 4);

  /// Canonical https base for shareable listing links (messengers need https).
  static const canonicalShareWebBase = AppDomains.shareWebBase;

  static final RegExp _legacyShareWebHost = RegExp(
    '://(?:www\\.)?${RegExp.escape(AppDomains.legacyWebHost)}(?=/|\$)',
    caseSensitive: false,
  );

  /// Every RC key we care about, mapped to its compile-time fallback.
  static final Map<String, String> _defaults = <String, String>{
    _kApiBasePath: EnvironmentUtil.compileTimeBasePath,
    _kShareWebBase: EnvironmentUtil.compileTimeShareWebBase,
    _kTermsOfServiceUrl: EnvironmentUtil.compileTimeTermsOfService,
    _kPrivacyPolicyUrl: EnvironmentUtil.compileTimePrivacyPolicy,
    _kDeleteAccountUrl: EnvironmentUtil.compileTimeDeleteAccount,
    _kYandexMapsApiKey: EnvironmentUtil.compileTimeYandexMapsApiKey,
    _kYandexGeosuggestApiKey: EnvironmentUtil.compileTimeYandexGeosuggestApiKey,
    _kGeminiApiKey: EnvironmentUtil.compileTimeGeminiApiKey,
    _kGeminiApiKey2: EnvironmentUtil.compileTimeGeminiApiKey2,
    _kUzsPerUsd: _kDefaultUzsPerUsd,
    _kShowListingFormFieldLabels: _kDefaultShowListingFormFieldLabels,
    _kMaxPhotosPerListing: _kDefaultMaxPhotosPerListing,
    _kMaxPhotosPerGigOffer: _kDefaultMaxPhotosPerGigOffer,
  };

  /// Currently-active values. Seeded from [_defaults], overridden by the
  /// SharedPreferences cache during [initialize], and refreshed on every
  /// successful `fetchAndActivate`.
  static final Map<String, String> _values =
      Map<String, String>.from(_defaults);

  static bool _initialized = false;

  /// The currently active API base URL. Safe to call before [initialize]
  /// (returns the compile-time default until init completes).
  static String get apiBasePath => _values[_kApiBasePath]!;

  /// Web base for shareable https links. Safe to call before [initialize].
  static String get shareWebBase =>
      _normalizeValue(_kShareWebBase, _values[_kShareWebBase]!);

  /// Public Terms of Service URL. Safe to call before [initialize].
  static String get termsOfServiceUrl => _values[_kTermsOfServiceUrl]!;

  /// Public Privacy Policy URL. Safe to call before [initialize].
  static String get privacyPolicyUrl => _values[_kPrivacyPolicyUrl]!;

  /// Public "delete account" instructions URL. Safe to call before
  /// [initialize].
  static String get deleteAccountUrl => _values[_kDeleteAccountUrl]!;

  /// Yandex Maps JS API key. Safe to call before [initialize] (returns the
  /// compile-time default until init completes / RC fetch lands).
  static String get yandexMapsApiKey => _values[_kYandexMapsApiKey]!;

  /// Yandex Geosuggest API key for address autocomplete. When the dedicated
  /// RC / `--dart-define` value is empty, falls back to [yandexMapsApiKey]
  /// (that key is usually rejected by the suggest endpoint — enable the
  /// Geosuggest product on a dedicated key in the Yandex developer console).
  static String get yandexGeosuggestApiKey {
    final dedicated = (_values[_kYandexGeosuggestApiKey] ?? "").trim();
    if (dedicated.isNotEmpty) {
      return dedicated;
    }
    return yandexMapsApiKey;
  }

  /// Primary Google Gemini API key. Safe to call before [initialize]; will
  /// return `""` until the first RC fetch lands (unless overridden via
  /// `--dart-define=GEMINI_API_KEY=…` at build time). Callers should treat
  /// an empty string as "not configured".
  static String get geminiApiKey => _values[_kGeminiApiKey]!;

  /// Secondary Google Gemini API key (fallback for transient/key errors).
  /// Same caveats as [geminiApiKey].
  static String get geminiApiKey2 => _values[_kGeminiApiKey2]!;

  /// UZS per 1 USD exchange-rate used for client-side display conversions.
  /// Tunable from Firebase Console key: `uzs_per_usd`.
  ///
  /// Stored as a stringified number; parsed defensively and falls back to
  /// [_kDefaultUzsPerUsd] on invalid / non-positive values.
  static int get uzsPerUsd {
    final raw = _values[_kUzsPerUsd];
    final parsed = int.tryParse(raw?.trim() ?? "");
    if (parsed == null || parsed <= 0) {
      return int.parse(_kDefaultUzsPerUsd);
    }
    return parsed;
  }

  /// Max number of photos per listing. Tunable from the Firebase Console
  /// under the `max_photos_per_listing` key. Falls back to the compile-time
  /// default ([_kDefaultMaxPhotosPerListing], currently `5`) when the
  /// stored value is missing, empty, non-numeric, or non-positive — we
  /// never want to render a UI that can't accept a single photo just
  /// because someone typo'd the RC value.
  static int get maxPhotosPerListing {
    final raw = _values[_kMaxPhotosPerListing];
    final parsed = int.tryParse(raw?.trim() ?? "");
    if (parsed == null || parsed <= 0) {
      return int.parse(_kDefaultMaxPhotosPerListing);
    }
    return parsed;
  }

  /// Max number of photos per gig offer. Tunable independently from the
  /// listings cap (see [maxPhotosPerListing]) under the
  /// `max_photos_per_gig_offer` Firebase Console key. Same defensive
  /// fallback rules.
  static int get maxPhotosPerGigOffer {
    final raw = _values[_kMaxPhotosPerGigOffer];
    final parsed = int.tryParse(raw?.trim() ?? "");
    if (parsed == null || parsed <= 0) {
      return int.parse(_kDefaultMaxPhotosPerGigOffer);
    }
    return parsed;
  }

  /// Reactive notifier mirroring [_kShowListingFormFieldLabels]. Widgets
  /// (e.g. `LabeledFieldOverlay`) listen to this so toggling the flag in the
  /// Firebase Console takes effect on the next successful fetch without an
  /// app restart. Seeded from the cached / compile-time value during
  /// [initialize].
  static final ValueNotifier<bool> showListingFormFieldLabels =
      ValueNotifier(_parseBool(_kDefaultShowListingFormFieldLabels));

  static bool _parseBool(String raw) {
    final v = raw.trim().toLowerCase();
    return v == "true" || v == "1" || v == "yes" || v == "on";
  }

  /// Initialize Remote Config. Call once during app bootstrap, after
  /// `Firebase.initializeApp()` and before any service that issues HTTP
  /// requests.
  ///
  /// Never throws — any failure (network down, RC backend hiccup, plugin
  /// init crash) falls through to whatever cached / compile-time value is
  /// available so the app stays usable.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    var hadApiBaseCache = false;
    for (final key in _defaults.keys) {
      final cached = prefs.getString("$_kPrefsCachePrefix$key");
      if (cached != null && cached.isNotEmpty) {
        final normalized = _normalizeValue(key, cached);
        _values[key] = normalized;
        if (normalized != cached) {
          await prefs.setString("$_kPrefsCachePrefix$key", normalized);
          logger.d(
            "🛰️ RemoteConfig: migrated cached $key → $normalized",
          );
        }
        if (key == _kApiBasePath) hadApiBaseCache = true;
      }
    }
    if (hadApiBaseCache) {
      logger.d(
        "🛰️ RemoteConfig: using cached apiBasePath=${_values[_kApiBasePath]}",
      );
    }
    _syncReactiveValues();

    FirebaseRemoteConfig rc;
    try {
      rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          // In debug builds, ignore the throttle so engineers can test
          // changes immediately. In release, cap fetches to once per hour
          // (a value change still propagates within ~1 hour without an app
          // restart, and immediately on next cold start).
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      await rc.setDefaults(<String, Object>{
        for (final entry in _defaults.entries) entry.key: entry.value,
      });
    } catch (e) {
      logger.d("🛰️ RemoteConfig: init failed, using fallback: $e");
      return;
    }

    final fetchFuture = _fetchAndApply(rc, prefs);
    if (!hadApiBaseCache) {
      // No cache for the critical API URL — wait briefly so the first
      // network call uses a fresh value. Other keys are cosmetic enough
      // that the compile-time fallback is fine until the background fetch
      // completes.
      try {
        await fetchFuture.timeout(_firstLaunchFetchTimeout);
      } catch (_) {
        // Fall through with compile-time defaults; subsequent launches retry.
      }
    } else {
      // We already have a cached api_base_path to start with — let the
      // fetch run in the background so it doesn't delay the first frame.
      unawaited(fetchFuture);
    }
  }

  static Future<void> _fetchAndApply(
    FirebaseRemoteConfig rc,
    SharedPreferences prefs,
  ) async {
    try {
      await rc.fetchAndActivate();
      for (final key in _defaults.keys) {
        final fresh = _normalizeValue(key, rc.getString(key).trim());
        if (fresh.isEmpty) continue;
        if (fresh == _values[key]) continue;
        _values[key] = fresh;
        await prefs.setString("$_kPrefsCachePrefix$key", fresh);
        logger.d("🛰️ RemoteConfig: applied fresh $key=$fresh");
      }
      _syncReactiveValues();
    } catch (e) {
      logger.d("🛰️ RemoteConfig: fetch failed, keeping current values: $e");
    }
  }

  /// Rewrites legacy Remote Config / cache values (e.g. `uydosh.app` share host).
  static String _normalizeValue(String key, String value) {
    if (key != _kShareWebBase) return value;
    var v = value.trim();
    if (v.isEmpty) return canonicalShareWebBase;
    if (_legacyShareWebHost.hasMatch(v)) {
      v = v.replaceAll(_legacyShareWebHost, "://${AppDomains.webHost}");
    }
    return v.replaceAll(RegExp(r"/+$"), "");
  }

  /// Push the current string-typed `_values` into reactive notifiers so any
  /// widget listening to a flag (like [showListingFormFieldLabels]) rebuilds.
  static void _syncReactiveValues() {
    final raw = _values[_kShowListingFormFieldLabels] ??
        _kDefaultShowListingFormFieldLabels;
    final parsed = _parseBool(raw);
    if (showListingFormFieldLabels.value != parsed) {
      showListingFormFieldLabels.value = parsed;
    }
  }
}
