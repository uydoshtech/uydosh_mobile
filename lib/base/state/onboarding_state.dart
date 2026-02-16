import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

class OnboardingState extends ChangeNotifier {
  factory OnboardingState() => _instance;
  OnboardingState._internal();
  static final OnboardingState _instance = OnboardingState._internal();

  bool _showOnboarding = true; // Default to showing onboarding
  bool _isInitialized = false;

  bool get showOnboarding => _showOnboarding;
  bool get isInitialized => _isInitialized;

  static const String _keyShowOnboarding = "show_onboarding";

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _showOnboarding =
          prefs.getBool(_keyShowOnboarding) ??
          true; // Default to true if no saved preference
      logger.d("Loaded onboarding preference: $_showOnboarding");
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logger.d("Error initializing onboarding state: $e");
      _showOnboarding = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setShowOnboarding(bool show) async {
    if (_showOnboarding == show) return;

    _showOnboarding = show;
    logger.d("Setting onboarding preference to: $show");
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyShowOnboarding, show);
      logger.d("Saved onboarding preference to storage: $show");
      logger.d("=== ONBOARDING PREFERENCE UPDATED ===");
      logger.d('Onboarding: ${show ? "ENABLED" : "DISABLED"}');
      logger.d("=====================================");
    } catch (e) {
      logger.d("Error saving onboarding preference: $e");
    }
  }

  // Method to explicitly turn off onboarding (called from hamburger menu)
  Future<void> turnOffOnboarding() async {
    await setShowOnboarding(false);
  }

  // Method to explicitly turn on onboarding (called from hamburger menu)
  Future<void> turnOnOnboarding() async {
    await setShowOnboarding(true);
  }

  Future<void> toggleOnboarding() async {
    await setShowOnboarding(!_showOnboarding);
  }
}
