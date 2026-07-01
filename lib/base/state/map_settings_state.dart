import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Device-local map UI preferences (zoom slider visibility, etc.).
class MapSettingsState extends ChangeNotifier {
  factory MapSettingsState() => _instance;
  MapSettingsState._internal();
  static final MapSettingsState _instance = MapSettingsState._internal();

  static const String _keyShowZoomSlider = "map_show_zoom_slider";

  bool _showZoomSlider = false;
  bool _isInitialized = false;

  bool get showZoomSlider => _showZoomSlider;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _showZoomSlider = prefs.getBool(_keyShowZoomSlider) ?? false;
      logger.d("Loaded map zoom slider preference: $_showZoomSlider");
    } catch (e) {
      logger.d("Error initializing MapSettingsState: $e");
      _showZoomSlider = false;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setShowZoomSlider(bool value) async {
    if (_showZoomSlider == value) return;

    _showZoomSlider = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyShowZoomSlider, value);
    } catch (e) {
      logger.d("Error saving map zoom slider preference: $e");
    }
  }
}
