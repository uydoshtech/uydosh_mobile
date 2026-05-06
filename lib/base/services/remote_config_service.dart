import "dart:async" show unawaited;

import "package:firebase_remote_config/firebase_remote_config.dart";
import "package:flutter/foundation.dart" show kDebugMode;
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";
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

  /// Prefix for SharedPreferences cache keys. The `api_base_path` cache key
  /// (`uydosh.remote_config.api_base_path`) intentionally matches the value
  /// used before the multi-key refactor so existing installs keep their
  /// cached URL across upgrade.
  static const _kPrefsCachePrefix = "uydosh.remote_config.";
  static const _firstLaunchFetchTimeout = Duration(seconds: 4);

  /// Every RC key we care about, mapped to its compile-time fallback.
  static final Map<String, String> _defaults = <String, String>{
    _kApiBasePath: EnvironmentUtil.compileTimeBasePath,
    _kShareWebBase: EnvironmentUtil.compileTimeShareWebBase,
    _kTermsOfServiceUrl: EnvironmentUtil.compileTimeTermsOfService,
    _kPrivacyPolicyUrl: EnvironmentUtil.compileTimePrivacyPolicy,
    _kDeleteAccountUrl: EnvironmentUtil.compileTimeDeleteAccount,
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
  static String get shareWebBase => _values[_kShareWebBase]!;

  /// Public Terms of Service URL. Safe to call before [initialize].
  static String get termsOfServiceUrl => _values[_kTermsOfServiceUrl]!;

  /// Public Privacy Policy URL. Safe to call before [initialize].
  static String get privacyPolicyUrl => _values[_kPrivacyPolicyUrl]!;

  /// Public "delete account" instructions URL. Safe to call before
  /// [initialize].
  static String get deleteAccountUrl => _values[_kDeleteAccountUrl]!;

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
        _values[key] = cached;
        if (key == _kApiBasePath) hadApiBaseCache = true;
      }
    }
    if (hadApiBaseCache) {
      logger.d(
        "🛰️ RemoteConfig: using cached apiBasePath=${_values[_kApiBasePath]}",
      );
    }

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
        final fresh = rc.getString(key).trim();
        if (fresh.isEmpty) continue;
        if (fresh == _values[key]) continue;
        _values[key] = fresh;
        await prefs.setString("$_kPrefsCachePrefix$key", fresh);
        logger.d("🛰️ RemoteConfig: applied fresh $key=$fresh");
      }
    } catch (e) {
      logger.d("🛰️ RemoteConfig: fetch failed, keeping current values: $e");
    }
  }
}
