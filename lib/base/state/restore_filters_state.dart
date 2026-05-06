import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// User preference for whether previously-applied search filters should be
/// restored on app cold start. Defaults to ON to match historical behavior.
///
/// When turned OFF, [SearchFiltersState.initialize] wipes any locally
/// persisted filter prefs (so the search starts fresh) and
/// [SearchFiltersState.hydrateFromBackendForCurrentUser] becomes a no-op.
/// The backend copy is intentionally left intact so flipping the toggle back
/// ON re-restores the user's previous filters across devices.
class RestoreFiltersState extends ChangeNotifier {
  factory RestoreFiltersState() => _instance;
  RestoreFiltersState._internal();
  static final RestoreFiltersState _instance = RestoreFiltersState._internal();

  static const String _prefsKey = "restore_filters_on_start";

  bool _shouldRestore = true;
  bool _isInitialized = false;

  bool get shouldRestore => _shouldRestore;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _shouldRestore = prefs.getBool(_prefsKey) ?? true;
    } catch (e) {
      logger.d("Error initializing RestoreFiltersState: $e");
      _shouldRestore = true;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setShouldRestore(bool value) async {
    if (_shouldRestore == value) return;
    _shouldRestore = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (e) {
      logger.d("Error saving RestoreFiltersState: $e");
    }
  }
}
