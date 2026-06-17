import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// State management for app themes
class ThemeState extends ChangeNotifier with WidgetsBindingObserver {
  factory ThemeState() => _instance;
  ThemeState._internal();
  static final ThemeState _instance = ThemeState._internal();

  String _selectedTheme = AppTheme.blueTheme;
  bool _isInitialized = false;

  /// Get the currently applied theme name.
  ///
  /// When the selected preference is "system", this returns the resolved
  /// light/blue theme so older theme-aware code keeps behaving correctly.
  String get currentTheme => effectiveTheme;

  /// Get the user's selected theme preference.
  String get selectedTheme => _selectedTheme;

  /// Get the theme currently applied after resolving the system preference.
  String get effectiveTheme => AppTheme.resolveTheme(_selectedTheme);

  /// Get the current theme data
  ThemeData get currentThemeData => AppTheme.getTheme(effectiveTheme);

  /// Get the display name of the current theme
  String get currentThemeDisplayName {
    // Get current language from LanguageState
    final currentLanguage = LanguageState().currentLanguage;

    // Use localized strings instead of hardcoded display names
    switch (_selectedTheme) {
      case AppTheme.systemTheme:
        return AppStrings.get("system_theme", currentLanguage);
      case AppTheme.lightTheme:
        return AppStrings.get("light_theme", currentLanguage);
      case AppTheme.blueTheme:
        return AppStrings.get("blue_theme", currentLanguage);
      default:
        return AppStrings.get("blue_theme", currentLanguage);
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
      WidgetsBinding.instance.addObserver(this);

      if (savedTheme != null && savedTheme.isNotEmpty) {
        _selectedTheme = AppTheme.normalizeThemeName(savedTheme);
        logger.d("Loaded saved theme: $_selectedTheme");
      } else {
        logger.d("No saved theme found, using default: $_selectedTheme");
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
    final normalizedTheme = AppTheme.normalizeThemeName(themeName);
    if (_selectedTheme != normalizedTheme) {
      getIt<AppAnalyticsService>().logThemeChanged(theme: normalizedTheme);
      _selectedTheme = normalizedTheme;

      // Save to local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.selectedTheme, normalizedTheme);
        logger.d("Saved theme to storage: $normalizedTheme");
      } catch (e) {
        logger.d("Error saving theme to storage: $e");
      }

      notifyListeners();
    }
  }

  /// Toggle between themes
  Future<void> toggleTheme() async {
    if (effectiveTheme == AppTheme.lightTheme) {
      await changeTheme(AppTheme.blueTheme);
    } else {
      await changeTheme(AppTheme.lightTheme);
    }
  }

  /// Check if current theme is blue
  bool get isBlueTheme => effectiveTheme == AppTheme.blueTheme;

  /// Check if current theme is light
  bool get isLightTheme => effectiveTheme == AppTheme.lightTheme;

  /// Check if the user selected the system theme preference.
  bool get isSystemTheme => _selectedTheme == AppTheme.systemTheme;

  /// Apply system theme (dark/light) when user has no saved preference.
  /// Called on first login. Returns true if theme was applied.
  Future<bool> applySystemThemeIfFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(StorageKeys.selectedTheme);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        return false; // User already has a saved theme
      }

      _selectedTheme = AppTheme.systemTheme;
      await prefs.setString(StorageKeys.selectedTheme, AppTheme.systemTheme);
      logger.d(
        "Applied system theme on first login: $effectiveTheme",
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
      _selectedTheme = AppTheme.blueTheme; // Reset to default
      notifyListeners();
    } catch (e) {
      logger.d("Error clearing saved theme: $e");
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (isSystemTheme) {
      notifyListeners();
    }
  }
}
