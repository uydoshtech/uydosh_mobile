import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/theme_toggle.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme-aware color helper methods
  Color _getTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      default:
        return Colors.black; // Black text for light theme
    }
  }

  Color _getSecondaryTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight70;
      default:
        return Colors.grey[600]!; // Dark grey for secondary text in light theme
    }
  }

  Color _getIconColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      default:
        return Colors.black;
    }
  }

  Color _getSecondaryIconColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight70;
      default:
        return Colors
            .grey[600]!; // Dark grey for secondary icons in light theme
    }
  }

  // Get background color for light and blue themes
  Color _getBackgroundColor(BuildContext context) {
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    if (appBarColor != null) {
      return appBarColor;
    }

    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return BlueThemeColors.primary;
      default:
        return AppColors.backgroundLight;
    }
  }

  // Get background color for language selection dialog based on theme
  Color _getLanguageDialogBackgroundColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.lightTheme:
        return Colors.white; // White background for light theme
      case AppTheme.blueTheme:
        return BlueThemeColors.primary; // Blue background for blue theme
      default:
        return BlueThemeColors.primary; // Default to blue theme background
    }
  }

  // Theme-aware divider method with better contrast for light theme
  Widget _buildThemeAwareDivider() {
    final currentTheme = ThemeState().currentTheme;
    Color dividerColor;

    switch (currentTheme) {
      case AppTheme.blueTheme:
        dividerColor = AppColors.textLight;
      default:
        // Use a darker color for better visibility in light theme
        dividerColor = const Color(
          0xFFD1D5DB,
        ); // Medium gray for better contrast
    }

    return Divider(color: dividerColor, thickness: 1.0, height: 1.0);
  }

  /// Get localized theme name based on current language
  String _getLocalizedThemeName(String themeCode) {
    switch (themeCode) {
      case AppTheme.blueTheme:
        return LanguageAwareStringHelper.getCurrent(context, "blue_theme");
      default:
        return LanguageAwareStringHelper.getCurrent(context, "light_theme");
    }
  }

  // Theme-dependent color method for About modal text
  Color _getAboutModalTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White text for blue theme
    } else {
      return Colors.black; // Black text for light theme
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LanguageAwareStringHelper.getText(
          "settings",
          context,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                _getTextColor(),
          ),
        ),
        centerTitle: false, // Move title to the left, closer to back button
        titleSpacing: 0, // Remove extra spacing between back button and title
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Container(
        color:
            _getBackgroundColor(
              context,
            ), // Set background color to match app bar
        child: ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            // Profile menu item - Only show when user is authenticated
            ListenableBuilder(
              listenable: AuthenticationState(),
              builder: (context, child) {
                final isAuthenticated = AuthenticationState().isAuthenticated;

                if (!isAuthenticated) {
                  return const SizedBox.shrink();
                }

                return _buildMenuItem(
                  icon: Icons.person_outline,
                  titleKey: "menu_profile",
                  onTap: () {
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),

            // Only show divider if profile section is visible
            ListenableBuilder(
              listenable: AuthenticationState(),
              builder: (context, child) {
                final isAuthenticated = AuthenticationState().isAuthenticated;

                if (!isAuthenticated) {
                  return const SizedBox.shrink();
                }

                return _buildThemeAwareDivider();
              },
            ),

            _buildLanguageMenuItem(context),
            _buildThemeMenuItem(context),
            _buildOnboardingToggleMenuItem(context),

            _buildThemeAwareDivider(),

            _buildMenuItem(
              icon: Icons.info,
              titleKey: "menu_about",
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageMenuItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.language, color: _getIconColor()),
      title: LanguageAwareStringHelper.getText(
        "menu_language",
        context,
        style: TextStyle(fontWeight: FontWeight.w500, color: _getTextColor()),
      ),
      subtitle: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          return Text(
            LanguageAwareStringHelper.getCurrent(context, "current_language"),
            style: TextStyle(color: _getSecondaryTextColor()),
          );
        },
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        _showLanguageDialog(context);
      },
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: _getSecondaryIconColor(),
      ),
    );
  }

  Widget _buildThemeMenuItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.palette, color: _getIconColor()),
      title: LanguageAwareStringHelper.getText(
        "theme",
        context,
        style: TextStyle(fontWeight: FontWeight.w500, color: _getTextColor()),
      ),
      subtitle: Text(
        _getLocalizedThemeName(ThemeState().currentTheme),
        style: TextStyle(color: _getSecondaryTextColor()),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        _showThemeDialog(context);
      },
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: _getSecondaryIconColor(),
      ),
    );
  }

  Widget _buildOnboardingToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: OnboardingState(),
      builder: (context, child) {
        return ListTile(
          leading: Icon(Icons.school, color: _getIconColor()),
          title: LanguageAwareStringHelper.getText(
            "onboarding_toggle",
            context,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: LanguageAwareStringHelper.getText(
            "onboarding_toggle_description",
            context,
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          trailing: ThemeToggle(
            value: OnboardingState().showOnboarding,
            onChanged: (value) async {
              // Onboarding toggle changed
              await OnboardingState().setShowOnboarding(value);
              // Onboarding state updated
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String titleKey,
    required VoidCallback onTap,
    String? subtitleKey,
  }) {
    return ListTile(
      leading: Icon(icon, color: _getIconColor()),
      title: LanguageAwareStringHelper.getText(
        titleKey,
        context,
        style: TextStyle(fontWeight: FontWeight.w500, color: _getTextColor()),
      ),
      subtitle:
          subtitleKey != null
              ? LanguageAwareStringHelper.getText(
                subtitleKey,
                context,
                style: TextStyle(color: _getSecondaryTextColor()),
              )
              : null,
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: _getSecondaryIconColor(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _getLanguageDialogBackgroundColor(),
            title: Text(
              LanguageAwareStringHelper.getCurrent(context, "select_language"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    ThemeState().currentTheme == AppTheme.lightTheme
                        ? Colors.black
                        : Colors.white,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(context, "language_uzbek", "uz"),
                _buildLanguageOption(context, "language_russian", "ru"),
                _buildLanguageOption(context, "language_english", "en"),
              ],
            ),
          ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _getLanguageDialogBackgroundColor(),
            title: Text(
              LanguageAwareStringHelper.getCurrent(context, "select_theme"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color:
                    ThemeState().currentTheme == AppTheme.lightTheme
                        ? Colors.black
                        : Colors.white,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(context, "light_theme", AppTheme.lightTheme),
                _buildThemeOption(context, "blue_theme", AppTheme.blueTheme),
              ],
            ),
          ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String nameKey,
    String themeCode,
  ) {
    final isCurrentTheme = ThemeState().currentTheme == themeCode;

    // Get theme color for indicator
    Color themeColor;
    themeColor = switch (themeCode) {
      AppTheme.lightTheme => Colors.white,
      AppTheme.blueTheme => Colors.blue,
      _ => AppColors.primary,
    };

    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isCurrentTheme
                    ? (themeCode == AppTheme.lightTheme
                        ? Colors.black
                        : Colors.white)
                    : Colors.grey.shade300,
            width: isCurrentTheme ? 2 : 1,
          ),
        ),
        child: Icon(
          Icons.palette,
          color: themeCode == AppTheme.lightTheme ? Colors.black : Colors.white,
          size: 18,
        ),
      ),
      title: Text(
        LanguageAwareStringHelper.getCurrent(context, nameKey),
        style: TextStyle(
          fontWeight: isCurrentTheme ? FontWeight.bold : FontWeight.normal,
          color:
              ThemeState().currentTheme == AppTheme.lightTheme
                  ? Colors.black
                  : Colors.white,
        ),
      ),
      trailing:
          isCurrentTheme
              ? Icon(
                Icons.check,
                color:
                    ThemeState().currentTheme == AppTheme.lightTheme
                        ? Colors.black
                        : Colors.white,
              )
              : null,
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        // Handle theme change
        await ThemeState().changeTheme(themeCode);
        if (context.mounted) {
          ToastTheme.showSuccess(
            context,
            message: AppStrings.getWithParams(
              "theme_changed_to",
              LanguageState().currentLanguage,
              params: {
                "theme": LanguageAwareStringHelper.getCurrent(context, nameKey),
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String nameKey,
    String code,
  ) {
    final isCurrentLanguage = LanguageState().currentLanguage == code;
    final flag = switch (code) {
      "en" => "🇺🇸",
      "ru" => "🇷🇺",
      "uz" => "🇺🇿",
      _ => "",
    };

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: LanguageAwareStringHelper.getText(
        nameKey,
        context,
        style: TextStyle(
          fontWeight: isCurrentLanguage ? FontWeight.bold : FontWeight.normal,
          color:
              ThemeState().currentTheme == AppTheme.lightTheme
                  ? Colors.black
                  : Colors.white,
        ),
      ),
      trailing:
          isCurrentLanguage
              ? Icon(
                Icons.check,
                color:
                    ThemeState().currentTheme == AppTheme.lightTheme
                        ? Colors.black
                        : Colors.white,
              )
              : null,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        // Handle language change
        LanguageState().setLanguage(code);
        ToastTheme.showSuccess(
          context,
          message: AppStrings.getWithParams(
            "language_changed_to",
            LanguageState().currentLanguage,
            params: {
              "language": LanguageAwareStringHelper.getCurrent(
                context,
                nameKey,
              ),
            },
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _getLanguageDialogBackgroundColor(),
            title: Center(
              child: LanguageAwareStringHelper.getText(
                "about_uy_dosh",
                context,
                style: TextStyle(
                  fontSize: 24, // 1.5x larger
                  fontWeight: FontWeight.bold,
                  color: _getAboutModalTextColor(),
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LanguageAwareStringHelper.getText(
                  "about_description",
                  context,
                  style: TextStyle(
                    fontSize: 18, // 1.5x larger (16 -> 18)
                    color: _getAboutModalTextColor(),
                  ),
                ),
                const SizedBox(height: 12), // Increased spacing
                _buildFeatureItem(context, "about_feature_1"),
                _buildFeatureItem(context, "about_feature_2"),
                _buildFeatureItem(context, "about_feature_3"),
                _buildFeatureItem(context, "about_feature_4"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: LanguageAwareStringHelper.getText("close", context),
              ),
            ],
          ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String key) {
    // Get appropriate icon for each feature
    IconData icon;
    switch (key) {
      case "about_feature_1":
        icon = Icons.train; // Metro icon for metro station browsing
      case "about_feature_2":
        icon = Icons.location_on; // Location icon for district search
      case "about_feature_3":
        icon = Icons.contact_phone; // Contact icon for direct contact
      case "about_feature_4":
        icon = Icons.verified; // Verified icon for safe listings
      default:
        icon = Icons.circle; // Default icon
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _getAboutModalTextColor()),
          const SizedBox(width: 12),
          Expanded(
            child: LanguageAwareStringHelper.getText(
              key,
              context,
              style: TextStyle(
                fontSize: 16, // 1.5x larger (14 -> 16)
                color: _getAboutModalTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
