import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// State management for app themes
class ThemeState extends ChangeNotifier {
  factory ThemeState() => _instance;
  ThemeState._internal();
  static final ThemeState _instance = ThemeState._internal();

  String _currentTheme = AppTheme.lightTheme;
  bool _isInitialized = false;

  /// Get the current theme name
  String get currentTheme => _currentTheme;

  /// Get the current theme data
  ThemeData get currentThemeData => AppTheme.getTheme(_currentTheme);

  /// Get the display name of the current theme
  String get currentThemeDisplayName {
    // Get current language from LanguageState
    final currentLanguage = LanguageState().currentLanguage;

    // Use localized strings instead of hardcoded display names
    switch (_currentTheme) {
      case AppTheme.lightTheme:
        return AppStrings.get("light_theme", currentLanguage);
      case AppTheme.blueTheme:
        return AppStrings.get("blue_theme", currentLanguage);
      default:
        return AppStrings.get("light_theme", currentLanguage);
    }
  }

  /// Check if the state has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize and load saved theme from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(StorageKeys.selectedTheme);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        _currentTheme =
            savedTheme == "purple" ? AppTheme.lightTheme : savedTheme;
        logger.d("Loaded saved theme: $_currentTheme");
      } else {
        logger.d("No saved theme found, using default: $_currentTheme");
      }
    } catch (e) {
      // If there's an error loading, keep the default theme
      logger.d("Error loading saved theme: $e");
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current theme
  Future<void> changeTheme(String themeName) async {
    if (_currentTheme != themeName) {
      getIt<AppAnalyticsService>().logThemeChanged(theme: themeName);
      _currentTheme = themeName;

      // Save to local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.selectedTheme, themeName);
        logger.d("Saved theme to storage: $themeName");
      } catch (e) {
        logger.d("Error saving theme to storage: $e");
      }

      notifyListeners();
    }
  }

  /// Toggle between themes
  Future<void> toggleTheme() async {
    if (_currentTheme == AppTheme.lightTheme) {
      await changeTheme(AppTheme.blueTheme);
    } else {
      await changeTheme(AppTheme.lightTheme);
    }
  }

  /// Check if current theme is blue
  bool get isBlueTheme => _currentTheme == AppTheme.blueTheme;

  /// Check if current theme is light
  bool get isLightTheme => _currentTheme == AppTheme.lightTheme;

  /// Apply system theme (dark/light) when user has no saved preference.
  /// Called on first login. Returns true if theme was applied.
  Future<bool> applySystemThemeIfFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(StorageKeys.selectedTheme);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        return false; // User already has a saved theme
      }

      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final themeName = brightness == Brightness.dark
          ? AppTheme.blueTheme
          : AppTheme.lightTheme;

      _currentTheme = themeName;
      await prefs.setString(StorageKeys.selectedTheme, themeName);
      logger.d(
        "Applied system theme on first login: $themeName (brightness: $brightness)",
      );
      notifyListeners();
      return true;
    } catch (e) {
      logger.d("Error applying system theme: $e");
      return false;
    }
  }

  /// Clear saved theme and reset to default
  Future<void> clearSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.selectedTheme);
      _currentTheme = AppTheme.lightTheme; // Reset to default
      notifyListeners();
    } catch (e) {
      logger.d("Error clearing saved theme: $e");
    }
  }
}
