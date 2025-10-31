import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// Widget for switching between different app themes
class ThemeSwitcherWidget extends StatefulWidget {
  const ThemeSwitcherWidget({
    super.key,
    this.onThemeChanged, // Made optional for backward compatibility
  });

  final Function(String)?
  onThemeChanged; // Made optional for backward compatibility

  @override
  State<ThemeSwitcherWidget> createState() => _ThemeSwitcherWidgetState();
}

class _ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  late String _selectedTheme;
  final ThemeState _themeState = ThemeState();

  @override
  void initState() {
    super.initState();
    _selectedTheme = _themeState.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade400, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.get("select_theme", _getCurrentLanguage(context)),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.get(
                  "select_theme_description",
                  _getCurrentLanguage(context),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(AppTheme.lightTheme),
            _buildThemeOption(AppTheme.blueTheme),
            _buildThemeOption(AppTheme.purpleTheme),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                    onPressed: () async {
                      // Apply theme globally and persist it
                      await _themeState.changeTheme(_selectedTheme);

                      // Call the callback if provided (for backward compatibility)
                      if (widget.onThemeChanged != null) {
                        widget.onThemeChanged!(_selectedTheme);
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppStrings.get("confirm", _getCurrentLanguage(context)),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppStrings.get("cancel", _getCurrentLanguage(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String themeName) {
    final isSelected = _selectedTheme == themeName;

    // Use localized strings instead of hardcoded display names
    String displayName;
    switch (themeName) {
      case AppTheme.lightTheme:
        displayName = AppStrings.get(
          "light_theme",
          _getCurrentLanguage(context),
        );
        break;
      case AppTheme.blueTheme:
        displayName = AppStrings.get(
          "blue_theme",
          _getCurrentLanguage(context),
        );
        break;
      case AppTheme.purpleTheme:
        displayName = AppStrings.get(
          "purple_theme",
          _getCurrentLanguage(context),
        );
        break;
      default:
        displayName = AppStrings.get(
          "light_theme",
          _getCurrentLanguage(context),
        );
    }

    // Get theme color for indicator
    Color themeColor;
    switch (themeName) {
      case AppTheme.lightTheme:
        themeColor = Colors.white;
        break;
      case AppTheme.blueTheme:
        themeColor = Colors.blue;
        break;
      case AppTheme.purpleTheme:
        themeColor = Colors.purple;
        break;
      default:
        themeColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        value: themeName,
        groupValue: _selectedTheme,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedTheme = value;
            });
          }
        },
        title: Text(displayName, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          AppStrings.get("theme_color", _getCurrentLanguage(context)) +
              ": ${themeColor.toString()}",
          style: const TextStyle(color: Colors.white70),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Icon(
            Icons.palette,
            color:
                themeName == AppTheme.lightTheme ? Colors.black : Colors.white,
            size: 20,
          ),
        ),
        activeColor: AppColors.primary,
      ),
    );
  }

  String _getCurrentLanguage(BuildContext context) {
    // Try to get language from context, fallback to default
    try {
      final locale = Localizations.localeOf(context);
      return locale.languageCode;
    } catch (e) {
      return "en"; // Default fallback
    }
  }
}

/// Simple theme switcher button that can be placed in app bars or other locations
class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({
    super.key,
    this.currentTheme, // Made optional to use global state
    this.onThemeChanged, // Made optional for backward compatibility
  });

  final String? currentTheme; // Made optional to use global state
  final Function(String)?
  onThemeChanged; // Made optional for backward compatibility

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final actualCurrentTheme = currentTheme ?? themeState.currentTheme;

        return IconButton(
          icon: const Icon(Icons.palette),
          onPressed: () {
            _showThemeDialog(context, actualCurrentTheme);
          },
          tooltip: AppStrings.get("theme", _getCurrentLanguage(context)),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, String currentTheme) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: ThemeSwitcherWidget(onThemeChanged: onThemeChanged),
          ),
    );
  }

  String _getCurrentLanguage(BuildContext context) {
    // Try to get language from context, fallback to default
    try {
      final locale = Localizations.localeOf(context);
      return locale.languageCode;
    } catch (e) {
      return "en"; // Default fallback
    }
  }
}
