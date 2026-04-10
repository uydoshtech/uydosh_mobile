import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Tracks whether the user has completed in-app tutorial steps.
/// Used to show coach marks (e.g. search button) on first visit to home screen.
class TutorialState extends ChangeNotifier {
  factory TutorialState() => _instance;
  TutorialState._internal();
  static final TutorialState _instance = TutorialState._internal();

  bool _hasCompletedSearchTutorial = false;
  bool _hasCompletedMetroTutorial = false;
  bool _hasCompletedAlertBellTutorial = false;
  bool _isInitialized = false;

  bool get hasCompletedSearchTutorial => _hasCompletedSearchTutorial;
  bool get hasCompletedMetroTutorial => _hasCompletedMetroTutorial;
  bool get hasCompletedAlertBellTutorial => _hasCompletedAlertBellTutorial;
  bool get isInitialized => _isInitialized;

  static const String _keySearchTutorialCompleted =
      "tutorial_search_completed";
  static const String _keyMetroTutorialCompleted =
      "tutorial_metro_completed";
  static const String _keyAlertBellTutorialCompleted =
      "tutorial_alert_bell_completed";

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedSearchTutorial =
          prefs.getBool(_keySearchTutorialCompleted) ?? false;
      _hasCompletedMetroTutorial =
          prefs.getBool(_keyMetroTutorialCompleted) ?? false;
      _hasCompletedAlertBellTutorial =
          prefs.getBool(_keyAlertBellTutorialCompleted) ?? false;
      logger.d(
        "Loaded tutorial state: search=$_hasCompletedSearchTutorial, metro=$_hasCompletedMetroTutorial, alertBell=$_hasCompletedAlertBellTutorial",
      );
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logger.d("Error initializing tutorial state: $e");
      _hasCompletedSearchTutorial = false;
      _hasCompletedAlertBellTutorial = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> markSearchTutorialCompleted() async {
    if (_hasCompletedSearchTutorial) return;

    _hasCompletedSearchTutorial = true;
    logger.d("Tutorial: search step completed");
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySearchTutorialCompleted, true);
    } catch (e) {
      logger.d("Error saving tutorial state: $e");
    }
  }

  Future<void> markMetroTutorialCompleted() async {
    if (_hasCompletedMetroTutorial) return;

    _hasCompletedMetroTutorial = true;
    logger.d("Tutorial: metro step completed");
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMetroTutorialCompleted, true);
    } catch (e) {
      logger.d("Error saving metro tutorial state: $e");
    }
  }

  Future<void> markAlertBellTutorialCompleted() async {
    if (_hasCompletedAlertBellTutorial) return;

    _hasCompletedAlertBellTutorial = true;
    logger.d("Tutorial: alert bell step completed");
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAlertBellTutorialCompleted, true);
    } catch (e) {
      logger.d("Error saving alert bell tutorial state: $e");
    }
  }

  /// Reset tutorial (e.g. for testing or from settings).
  Future<void> resetTutorial() async {
    _hasCompletedSearchTutorial = false;
    _hasCompletedMetroTutorial = false;
    _hasCompletedAlertBellTutorial = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySearchTutorialCompleted, false);
      await prefs.setBool(_keyMetroTutorialCompleted, false);
      await prefs.setBool(_keyAlertBellTutorialCompleted, false);
      logger.d("Tutorial state reset");
    } catch (e) {
      logger.d("Error resetting tutorial state: $e");
    }
  }
}
