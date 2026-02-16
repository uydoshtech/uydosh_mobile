import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/cache/university_cache.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/localization/l10n.dart";

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
  static final LanguageState _instance = LanguageState._internal();
  factory LanguageState() => _instance;
  LanguageState._internal();

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
      _currentLanguage = language;

      // Invalidate university cache so next fetch uses new language
      UniversityCache.clearCache();

      // Save to local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.selectedLanguage, language);
      } catch (e) {
        // Handle error silently
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
  const LanguageSwitcher({super.key, required this.child});

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
                  const Icon(Icons.language),
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

/// Localization helper. Prefer [L10n] for new code.
@Deprecated("Use L10n instead")
class LanguageAwareStringHelper {
  static String getCurrentLanguage(BuildContext context) {
    return L10n.currentLanguage;
  }

  static String getCurrent(BuildContext context, String key) {
    return L10n.get(key);
  }

  static Widget getText(String key, BuildContext context, {TextStyle? style}) {
    return L10n.text(key, style: style);
  }

  static Widget getInputField(
    String key,
    BuildContext context, {
    required Widget Function(String hintText) builder,
  }) {
    return L10n.inputField(key, builder: builder);
  }
}
