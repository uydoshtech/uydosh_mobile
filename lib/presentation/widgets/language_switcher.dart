import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/cache/university_cache.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/auth/update_profile_request.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

// Utility class for language display names
class LanguageDisplayHelper {
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case "en":
        return "🇺🇸 English";
      case "ru":
        return "🇷🇺 Русский";
      case "uz":
        return "🇺🇿 O'zbekcha";
      default:
        return languageCode.toUpperCase();
    }
  }
}

// Global language state with ChangeNotifier for reactivity
class LanguageState extends ChangeNotifier {
  factory LanguageState() => _instance;
  LanguageState._internal();
  static final LanguageState _instance = LanguageState._internal();

  String _currentLanguage = "uz"; // Default language
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  // Initialize and load saved language from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(StorageKeys.selectedLanguage);
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _currentLanguage = savedLanguage;
      }
    } catch (e) {
      // If there"s an error loading, keep the default language
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_currentLanguage != language) {
      final fromLanguage = _currentLanguage;
      _currentLanguage = language;
      getIt<AppAnalyticsService>().logLanguageChanged(
        fromLanguage: fromLanguage,
        toLanguage: language,
      );

      // Invalidate university cache so next fetch uses new language
      UniversityCache.clearCache();

      // Save to local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.selectedLanguage, language);
      } catch (e) {
        // Handle error silently
      }

      // Sync to user profile so other users can see what language they speak
      try {
        if (await SessionManager.isAuthenticated()) {
          final profileService = getIt<IUserProfileService>();
          await profileService.updateProfile(
            UpdateProfileRequest(preferredLanguage: language),
          );
        }
      } catch (e) {
        // Handle error silently - profile sync is best-effort
      }

      notifyListeners();
    }
  }

  // Clear saved language and reset to default
  Future<void> clearSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.selectedLanguage);
      _currentLanguage = "uz"; // Reset to default
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
}

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({required this.child, super.key});

  final Widget child;

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  final LanguageState _languageState = LanguageState();

  void _changeLanguage(String languageCode) {
    _languageState.setLanguage(
      languageCode,
    ); // This is now async but we don"t need to await it
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Language Test",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: "uz",
                    child: Text(
                      LanguageDisplayHelper.getLanguageDisplayName("uz"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "ru",
                    child: Text(
                      LanguageDisplayHelper.getLanguageDisplayName("ru"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "en",
                    child: Text(
                      LanguageDisplayHelper.getLanguageDisplayName("en"),
                    ),
                  ),
                ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ThemeIcon(CupertinoIcons.globe),
                  const SizedBox(width: 8),
                  ListenableBuilder(
                    listenable: _languageState,
                    builder: (context, child) {
                      return Text(
                        LanguageDisplayHelper.getLanguageDisplayName(
                          _languageState.currentLanguage,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: widget.child,
    );
  }
}
