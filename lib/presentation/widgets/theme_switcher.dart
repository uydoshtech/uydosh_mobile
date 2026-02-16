import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Theme switcher widget for selecting app themes
class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({required this.child, super.key});

  final Widget child;

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  final ThemeState _themeState = ThemeState();

  void _changeTheme(String themeName) {
    _themeState.changeTheme(themeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "select_theme"),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.primary,
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeTheme,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: AppTheme.lightTheme,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "light_theme",
                          ),
                          style: Theme.of(context).popupMenuTheme.textStyle,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: AppTheme.blueTheme,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "blue_theme",
                          ),
                          style: Theme.of(context).popupMenuTheme.textStyle,
                        ),
                      ],
                    ),
                  ),
                ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.palette),
                  const SizedBox(width: 8),
                  ListenableBuilder(
                    listenable: _themeState,
                    builder: (context, child) {
                      return Text(_themeState.currentThemeDisplayName);
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

/// Helper class for theme-aware string retrieval
class ThemeAwareStringHelper {
  static String getCurrent(BuildContext context, String key) {
    final currentLanguage = LanguageState().currentLanguage;
    return AppStrings.get(key, currentLanguage);
  }
}
