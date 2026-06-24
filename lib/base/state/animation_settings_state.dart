import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";

class AnimationSettingsState extends ChangeNotifier {
  factory AnimationSettingsState() => _instance;
  AnimationSettingsState._internal();
  static final AnimationSettingsState _instance =
      AnimationSettingsState._internal();

  static const String _keyUiAnimationsEnabled = "ui_animations_enabled";
  static const String _keySearchPulseEnabled = "ui_animation_search_pulse";
  static const String _keyBellIdleEnabled = "ui_animation_bell_idle";
  static const String _keyBellTapEnabled = "ui_animation_bell_tap";

  bool _isInitialized = false;
  bool _uiAnimationsEnabled = true;
  bool _searchPulseEnabled = true;
  // Idle bell wiggle is a pure decoration — two infinite tickers running
  // forever on every screen that shows the search FAB or app-bar bell, just
  // to wobble a bell ±0.012 turns. Defaulting it OFF dramatically reduces
  // foreground CPU/GPU drain. Users who like the wiggle can re-enable it
  // from Settings; existing users with a persisted preference are
  // unaffected (we only fall back to this default when the key is absent).
  bool _bellIdleEnabled = false;
  bool _bellTapEnabled = true;

  bool get isInitialized => _isInitialized;

  bool get uiAnimationsEnabled =>
      _uiAnimationsEnabled && !UiPerformancePolicy.reduceEffectsForDevice;
  bool get searchPulseEnabled => _uiAnimationsEnabled && _searchPulseEnabled;
  bool get bellIdleEnabled => _uiAnimationsEnabled && _bellIdleEnabled;
  bool get bellTapEnabled => _uiAnimationsEnabled && _bellTapEnabled;

  /// Raw values (ignores master toggle); useful for UI presentation.
  bool get searchPulseEnabledRaw => _searchPulseEnabled;
  bool get bellIdleEnabledRaw => _bellIdleEnabled;
  bool get bellTapEnabledRaw => _bellTapEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _uiAnimationsEnabled = prefs.getBool(_keyUiAnimationsEnabled) ?? true;
      _searchPulseEnabled = prefs.getBool(_keySearchPulseEnabled) ?? true;
      _bellIdleEnabled = prefs.getBool(_keyBellIdleEnabled) ?? false;
      _bellTapEnabled = prefs.getBool(_keyBellTapEnabled) ?? true;
      logger.d(
        "Loaded animation settings: ui=$_uiAnimationsEnabled, searchPulse=$_searchPulseEnabled, bellIdle=$_bellIdleEnabled, bellTap=$_bellTapEnabled",
      );
    } catch (e) {
      logger.d("Error initializing animation settings: $e");
      _uiAnimationsEnabled = true;
      _searchPulseEnabled = true;
      _bellIdleEnabled = false;
      _bellTapEnabled = true;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      logger.d("Error saving animation settings key=$key: $e");
    }
  }

  Future<void> setUiAnimationsEnabled(bool enabled) async {
    if (_uiAnimationsEnabled == enabled) return;
    _uiAnimationsEnabled = enabled;
    notifyListeners();
    await _saveBool(_keyUiAnimationsEnabled, enabled);
  }

  Future<void> setSearchPulseEnabled(bool enabled) async {
    if (_searchPulseEnabled == enabled) return;
    _searchPulseEnabled = enabled;
    notifyListeners();
    await _saveBool(_keySearchPulseEnabled, enabled);
  }

  Future<void> setBellIdleEnabled(bool enabled) async {
    if (_bellIdleEnabled == enabled) return;
    _bellIdleEnabled = enabled;
    notifyListeners();
    await _saveBool(_keyBellIdleEnabled, enabled);
  }

  Future<void> setBellTapEnabled(bool enabled) async {
    if (_bellTapEnabled == enabled) return;
    _bellTapEnabled = enabled;
    notifyListeners();
    await _saveBool(_keyBellTapEnabled, enabled);
  }
}
