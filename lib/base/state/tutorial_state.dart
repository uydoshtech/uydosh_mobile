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
  bool _isInitialized = false;

  bool get hasCompletedSearchTutorial => _hasCompletedSearchTutorial;
  bool get isInitialized => _isInitialized;

  static const String _keySearchTutorialCompleted =
      "tutorial_search_completed";

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedSearchTutorial =
          prefs.getBool(_keySearchTutorialCompleted) ?? false;
      logger.d("Loaded tutorial state: search=$_hasCompletedSearchTutorial");
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      logger.d("Error initializing tutorial state: $e");
      _hasCompletedSearchTutorial = false;
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

  /// Reset tutorial (e.g. for testing or from settings).
  Future<void> resetTutorial() async {
    _hasCompletedSearchTutorial = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySearchTutorialCompleted, false);
      logger.d("Tutorial state reset");
    } catch (e) {
      logger.d("Error resetting tutorial state: $e");
    }
  }
}
