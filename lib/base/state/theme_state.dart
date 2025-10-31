import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import 'package:uy_dosh/base/logger/logger.dart';
import '../constants/app_strings.dart';
import '../../presentation/widgets/language_switcher.dart';

/// State management for app themes
class ThemeState extends ChangeNotifier {
  static final ThemeState _instance = ThemeState._internal();
  factory ThemeState() => _instance;
  ThemeState._internal();

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
      case AppTheme.purpleTheme:
        return AppStrings.get("purple_theme", currentLanguage);
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
        _currentTheme = savedTheme;
        logger.d('Loaded saved theme: $_currentTheme');
      } else {
        logger.d('No saved theme found, using default: $_currentTheme');
      }
    } catch (e) {
      // If there's an error loading, keep the default theme
      logger.d('Error loading saved theme: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current theme
  Future<void> changeTheme(String themeName) async {
    if (_currentTheme != themeName) {
      _currentTheme = themeName;

      // Save to local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.selectedTheme, themeName);
        logger.d('Saved theme to storage: $themeName');
      } catch (e) {
        logger.d('Error saving theme to storage: $e');
      }

      notifyListeners();
    }
  }

  /// Toggle between themes
  Future<void> toggleTheme() async {
    if (_currentTheme == AppTheme.lightTheme) {
      await changeTheme(AppTheme.blueTheme);
    } else if (_currentTheme == AppTheme.blueTheme) {
      await changeTheme(AppTheme.purpleTheme);
    } else {
      await changeTheme(AppTheme.lightTheme);
    }
  }

  /// Check if current theme is purple
  bool get isPurpleTheme => _currentTheme == AppTheme.purpleTheme;

  /// Check if current theme is blue
  bool get isBlueTheme => _currentTheme == AppTheme.blueTheme;

  /// Check if current theme is light
  bool get isLightTheme => _currentTheme == AppTheme.lightTheme;

  /// Clear saved theme and reset to default
  Future<void> clearSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.selectedTheme);
      _currentTheme = AppTheme.lightTheme; // Reset to default
      notifyListeners();
    } catch (e) {
      logger.d('Error clearing saved theme: $e');
    }
  }
}
