import "dart:async" show unawaited;

import "package:firebase_remote_config/firebase_remote_config.dart";
import "package:flutter/foundation.dart" show kDebugMode;
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Resolves runtime-tunable client config (currently: API base URL) from
/// Firebase Remote Config, with persistent caching for offline / cold-start
/// scenarios.
///
/// Why this exists:
///   `EnvironmentUtil.compileTimeBasePath` is baked into the binary at build
///   time. If the API host ever changes (EC2 stop/start, server migration,
///   region move), every installed app version with the stale URL becomes
///   useless — the only fix is a forced app store update. With Remote Config,
///   the URL becomes a value we can change in seconds from the Firebase
///   Console, with no rebuild and no user-facing update.
///
/// Resolution order on every call to [apiBasePath]:
///   1. Live in-memory value populated by the most recent successful fetch.
///   2. SharedPreferences cache from a previous run (instantly available
///      after [initialize] finishes, even offline).
///   3. [EnvironmentUtil.compileTimeBasePath] — last-resort fallback.
///
/// First-launch behavior:
///   When there is NO cached value (fresh install / cleared storage), we
///   block startup briefly (max [_firstLaunchFetchTimeout]) waiting for the
///   first fetch. This ensures the very first network call uses a known-good
///   URL even if the compile-time default has gone stale. On subsequent
///   launches the cache is used immediately and the fetch happens in the
///   background, so cold-start time is unaffected.
abstract class RemoteConfigService {
  static const _kRcKey = "api_base_path";
  static const _kPrefsCacheKey = "uydosh.remote_config.api_base_path";
  static const _firstLaunchFetchTimeout = Duration(seconds: 4);

  static String _apiBasePath = EnvironmentUtil.compileTimeBasePath;
  static bool _initialized = false;

  /// The currently active API base URL. Safe to call before [initialize]
  /// (returns the compile-time default until init completes).
  static String get apiBasePath => _apiBasePath;

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

    final cached = prefs.getString(_kPrefsCacheKey);
    if (cached != null && cached.isNotEmpty) {
      _apiBasePath = cached;
      logger.d("🛰️ RemoteConfig: using cached apiBasePath=$cached");
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
        _kRcKey: EnvironmentUtil.compileTimeBasePath,
      });
    } catch (e) {
      logger.d("🛰️ RemoteConfig: init failed, using fallback: $e");
      return;
    }

    final fetchFuture = _fetchAndApply(rc, prefs);
    if (cached == null || cached.isEmpty) {
      // No cache — wait briefly so the first network call uses a fresh URL.
      try {
        await fetchFuture.timeout(_firstLaunchFetchTimeout);
      } catch (_) {
        // Fall through with compile-time default; subsequent launches retry.
      }
    } else {
      // We already have a cached value to start with — let the fetch run
      // in the background so it doesn't delay the first frame.
      unawaited(fetchFuture);
    }
  }

  static Future<void> _fetchAndApply(
    FirebaseRemoteConfig rc,
    SharedPreferences prefs,
  ) async {
    try {
      await rc.fetchAndActivate();
      final fresh = rc.getString(_kRcKey).trim();
      if (fresh.isEmpty) return;
      if (fresh == _apiBasePath) return;
      _apiBasePath = fresh;
      await prefs.setString(_kPrefsCacheKey, fresh);
      logger.d("🛰️ RemoteConfig: applied fresh apiBasePath=$fresh");
    } catch (e) {
      logger.d("🛰️ RemoteConfig: fetch failed, keeping current value: $e");
    }
  }
}
