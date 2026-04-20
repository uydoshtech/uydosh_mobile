import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/logger/logger.dart";

class SoundEffectsState extends ChangeNotifier {
  factory SoundEffectsState() => _instance;
  SoundEffectsState._internal();
  static final SoundEffectsState _instance = SoundEffectsState._internal();

  bool _isEnabled = AppConfig.enableSoundEffects;
  bool _isInitialized = false;

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  static const String _keySoundEffectsEnabled = "sound_effects_enabled";

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled =
          prefs.getBool(_keySoundEffectsEnabled) ?? AppConfig.enableSoundEffects;
      logger.d("Loaded sound effects preference: $_isEnabled");
    } catch (e) {
      logger.d("Error initializing sound effects state: $e");
      _isEnabled = AppConfig.enableSoundEffects;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;

    _isEnabled = enabled;
    logger.d("Setting sound effects preference to: $enabled");
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySoundEffectsEnabled, enabled);
      logger.d("Saved sound effects preference to storage: $enabled");
      logger.d("=== SOUND EFFECTS PREFERENCE UPDATED ===");
      logger.d("Sounds: ${enabled ? "ENABLED" : "DISABLED"}");
      logger.d("========================================");
    } catch (e) {
      logger.d("Error saving sound effects preference: $e");
    }
  }

  Future<void> toggle() async => setEnabled(!_isEnabled);
}

