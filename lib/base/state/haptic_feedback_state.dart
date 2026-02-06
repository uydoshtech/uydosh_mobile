import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/logger/logger.dart";

class HapticFeedbackState extends ChangeNotifier {
  static final HapticFeedbackState _instance =
      HapticFeedbackState._internal();
  factory HapticFeedbackState() => _instance;
  HapticFeedbackState._internal();

  bool _isEnabled = AppConfig.enableHapticFeedback;
  bool _isInitialized = false;

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  static const String _keyHapticFeedbackEnabled = "haptic_feedback_enabled";

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled =
          prefs.getBool(_keyHapticFeedbackEnabled) ??
          AppConfig.enableHapticFeedback;
      logger.d("Loaded haptic feedback preference: $_isEnabled");
    } catch (e) {
      logger.d("Error initializing haptic feedback state: $e");
      _isEnabled = AppConfig.enableHapticFeedback;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;

    _isEnabled = enabled;
    logger.d("Setting haptic feedback preference to: $enabled");
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHapticFeedbackEnabled, enabled);
      logger.d("Saved haptic feedback preference to storage: $enabled");
      logger.d("=== HAPTIC FEEDBACK PREFERENCE UPDATED ===");
      logger.d("Haptics: ${enabled ? "ENABLED" : "DISABLED"}");
      logger.d("=========================================");
    } catch (e) {
      logger.d("Error saving haptic feedback preference: $e");
    }
  }

  Future<void> toggle() async {
    await setEnabled(!_isEnabled);
  }
}
