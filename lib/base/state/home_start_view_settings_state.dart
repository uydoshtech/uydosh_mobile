import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/config/client_home_start_view_config.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Device-local preference for whether the home tab opens on the map or feed.
///
/// On first cold start (no stored value), seeds from [ClientHomeStartViewConfig]
/// so the user inherits the server default. After that, the user's toggle in
/// Settings overrides the global config for this install.
class HomeStartViewSettingsState extends ChangeNotifier {
  factory HomeStartViewSettingsState() => _instance;
  HomeStartViewSettingsState._internal();
  static final HomeStartViewSettingsState _instance =
      HomeStartViewSettingsState._internal();

  static const String _prefsKey = "home_start_with_map";

  bool _showMapInitially = true;
  bool _isInitialized = false;

  bool get showMapInitially => _showMapInitially;
  bool get isInitialized => _isInitialized;

  /// Call after [ClientHomeStartViewConfig.load] so the global default is
  /// available when seeding a first-time install.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_prefsKey)) {
        _showMapInitially = prefs.getBool(_prefsKey) ??
            ClientHomeStartViewConfig.showMapInitially;
      } else {
        _showMapInitially = ClientHomeStartViewConfig.showMapInitially;
        await prefs.setBool(_prefsKey, _showMapInitially);
      }
    } catch (e) {
      logger.d("Error initializing HomeStartViewSettingsState: $e");
      _showMapInitially = ClientHomeStartViewConfig.showMapInitially;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setShowMapInitially(bool value) async {
    if (_showMapInitially == value) return;
    _showMapInitially = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (e) {
      logger.d("Error saving HomeStartViewSettingsState: $e");
    }
  }
}
