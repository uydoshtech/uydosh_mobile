import "package:flutter/foundation.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Tracks first-launch / version-upgrade state used to decide which splash
/// variant to show.
///
/// - First install ever              -> full animated splash
/// - First launch of a new version   -> full animated splash
/// - Subsequent launches             -> quick (static) splash
///
/// The current app version is persisted on the first call to [initialize] so
/// the next launch sees `lastOpenedVersion == currentVersion`.
class AppLaunchState extends ChangeNotifier {
  factory AppLaunchState() => _instance;
  AppLaunchState._internal();
  static final AppLaunchState _instance = AppLaunchState._internal();

  static const String _keyLastOpenedVersion = "app_launch.last_opened_version";

  bool _isInitialized = false;
  bool _isFirstLaunchEver = false;
  bool _isFirstLaunchOfCurrentVersion = false;
  String? _lastOpenedVersion;
  String? _currentVersion;

  bool get isInitialized => _isInitialized;

  /// `true` only on the very first launch after install (no stored version).
  bool get isFirstLaunchEver => _isFirstLaunchEver;

  /// `true` on first launch after an app upgrade (stored version differs from
  /// the current build's version). Also `true` for [isFirstLaunchEver].
  bool get isFirstLaunchOfCurrentVersion => _isFirstLaunchOfCurrentVersion;

  /// Show the full animated splash on a fresh install or after an upgrade,
  /// otherwise the quick static splash.
  bool get shouldShowFullSplash =>
      _isFirstLaunchEver || _isFirstLaunchOfCurrentVersion;

  String? get lastOpenedVersion => _lastOpenedVersion;
  String? get currentVersion => _currentVersion;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_keyLastOpenedVersion);
      final current = await _readCurrentAppVersion();

      _lastOpenedVersion = stored;
      _currentVersion = current;
      _isFirstLaunchEver = stored == null;
      _isFirstLaunchOfCurrentVersion =
          current != null && stored != current;

      logger.d(
        "🚀 AppLaunchState: stored=$stored, current=$current, "
        "firstEver=$_isFirstLaunchEver, "
        "firstOfVersion=$_isFirstLaunchOfCurrentVersion",
      );

      if (current != null && current != stored) {
        await prefs.setString(_keyLastOpenedVersion, current);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logger.d("Error initializing AppLaunchState: $e");
      _isFirstLaunchEver = false;
      _isFirstLaunchOfCurrentVersion = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<String?> _readCurrentAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final build = info.buildNumber;
      if (version.isEmpty) return null;
      return build.isEmpty ? version : "$version+$build";
    } catch (_) {
      return null;
    }
  }

  /// Test/debug helper: clears the stored version so the next [initialize] is
  /// treated as a first-ever launch.
  @visibleForTesting
  Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastOpenedVersion);
    _isInitialized = false;
    _isFirstLaunchEver = false;
    _isFirstLaunchOfCurrentVersion = false;
    _lastOpenedVersion = null;
    _currentVersion = null;
    notifyListeners();
  }
}
