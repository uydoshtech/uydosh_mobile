import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";

class OnboardingState extends ChangeNotifier {
  factory OnboardingState() => _instance;
  OnboardingState._internal();
  static final OnboardingState _instance = OnboardingState._internal();

  bool _showOnboarding = true; // Default ON; user can disable in settings
  bool _hasSeenOnboardingScreens = false; // Don't show onboarding screens again
  bool _isInitialized = false;

  bool get showOnboarding => _showOnboarding;
  bool get hasSeenOnboardingScreens => _hasSeenOnboardingScreens;
  bool get isInitialized => _isInitialized;

  static const String _keyShowOnboarding = "show_onboarding";
  static const String _keyHasSeenOnboardingScreens = "has_seen_onboarding_screens";

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _showOnboarding =
          prefs.getBool(_keyShowOnboarding) ??
          true; // Default ON; user can disable in settings
      _hasSeenOnboardingScreens =
          prefs.getBool(_keyHasSeenOnboardingScreens) ?? false;
      logger.d("Loaded onboarding: show=$_showOnboarding, hasSeen=$_hasSeenOnboardingScreens");
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logger.d("Error initializing onboarding state: $e");
      _showOnboarding = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Call when user completes or skips onboarding screens. Keeps toggle ON so
  /// in-app tutorials still show; just prevents showing onboarding screens again.
  Future<void> markOnboardingScreensSeen() async {
    if (_hasSeenOnboardingScreens) return;
    _hasSeenOnboardingScreens = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboardingScreens, true);
    } catch (e) {
      logger.d("Error saving hasSeenOnboardingScreens: $e");
    }
  }

  Future<void> setShowOnboarding(bool show) async {
    if (_showOnboarding == show) return;

    _showOnboarding = show;
    logger.d("Setting onboarding preference to: $show");
    notifyListeners();

    if (show) {
      await TutorialState().resetTutorial();
    }

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
