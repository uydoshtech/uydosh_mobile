import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_menu_item.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_toggle.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/theme_toggle_sun_moon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "settings");
  }

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
        return L10n.get("blue_theme");
      default:
        return L10n.get("light_theme");
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
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: L10n.text(
          "settings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                _getTextColor(),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ColoredBox(
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
                      context.pushProfile();
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
            _buildHapticFeedbackToggleMenuItem(context),
            _buildAnimationsToggleMenuItems(context),

            _buildMenuItem(
              icon: Icons.info,
              titleKey: "menu_about",
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip,
              titleKey: "menu_privacy_policy",
              onTap: () {
                _showLegalDialog(
                  context,
                  titleKey: "privacy_policy_title",
                  bodyKey: "privacy_policy_body",
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.description,
              titleKey: "menu_user_license_agreement",
              onTap: () {
                _showLegalDialog(
                  context,
                  titleKey: "user_license_agreement_title",
                  bodyKey: "user_license_agreement_body",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageMenuItem(BuildContext context) {
    return ListTile(
      leading: ThemeIcon(CupertinoIcons.globe, color: _getIconColor()),
      title: L10n.text(
        "menu_language",
        style: TextStyle(fontWeight: FontWeight.w500, color: _getTextColor()),
      ),
      subtitle: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          return Text(
            L10n.get("current_language"),
            style: TextStyle(color: _getSecondaryTextColor()),
          );
        },
      ),
      onTap: () {
        HapticFeedbackUtils.impact();
        _showLanguageDialog(context);
      },
      trailing: ThemeIcon(
        Icons.arrow_forward_ios,
        size: 16,
        color: _getSecondaryIconColor(),
      ),
    );
  }

  Widget _buildThemeMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        return ListTile(
          leading: ThemeIcon(Icons.palette, color: _getIconColor()),
          title: L10n.text(
            "theme",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: Text(
            _getLocalizedThemeName(ThemeState().currentTheme),
            style: TextStyle(color: _getSecondaryTextColor()),
          ),
          trailing: ThemeToggleSunMoon(
            iconColor: _getIconColor(),
            size: 35,
            onToggled: () {
              if (context.mounted) {
                ToastTheme.showSuccess(
                  context,
                  message: AppStrings.getWithParams(
                    "theme_changed_to",
                    LanguageState().currentLanguage,
                    params: {
                      "theme": L10n.get(
                        ThemeState().isBlueTheme ? "blue_theme" : "light_theme",
                      ),
                    },
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildOnboardingToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: OnboardingState(),
      builder: (context, child) {
        return UydoshToggle(
          icon: Icons.school,
          iconColor: _getIconColor(),
          title: L10n.text(
            "onboarding_toggle",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: L10n.text(
            "onboarding_toggle_description",
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          value: OnboardingState().showOnboarding,
          onChanged: (value) async {
            await OnboardingState().setShowOnboarding(value);
            // When turned ON, onboarding will show on next app start (no immediate navigation)
          },
        );
      },
    );
  }

  Widget _buildHapticFeedbackToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: HapticFeedbackState(),
      builder: (context, child) {
        return UydoshToggle(
          icon: Icons.vibration,
          iconColor: _getIconColor(),
          title: L10n.text(
            "haptic_feedback",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: L10n.text(
            "haptic_feedback_description",
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          value: HapticFeedbackState().isEnabled,
          onChanged: (value) async {
            await HapticFeedbackState().setEnabled(value);
          },
        );
      },
    );
  }

  Widget _buildAnimationsToggleMenuItems(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        final animations = AnimationSettingsState();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UydoshToggle(
              icon: Icons.animation,
              iconColor: _getIconColor(),
              title: L10n.text(
                "ui_animations",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
              subtitle: L10n.text(
                "ui_animations_description",
                style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
              ),
              value: animations.uiAnimationsEnabled,
              onChanged: (value) async {
                await animations.setUiAnimationsEnabled(value);
              },
            ),
          ],
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
    return UydoshMenuItem(
      icon: icon,
      title: L10n.text(
        titleKey,
        style: TextStyle(fontWeight: FontWeight.w500, color: _getTextColor()),
      ),
      subtitle:
          subtitleKey != null
              ? L10n.text(
                subtitleKey,
                style: TextStyle(color: _getSecondaryTextColor()),
              )
              : null,
      onTap: onTap,
      iconColor: _getIconColor(),
      textColor: _getTextColor(),
      trailingColor: _getSecondaryIconColor(),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _getLanguageDialogBackgroundColor(),
            title: Text(
              L10n.get("select_language"),
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
      title: L10n.text(
        nameKey,
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
              ? ThemeIcon(
                Icons.check,
                color:
                    ThemeState().currentTheme == AppTheme.lightTheme
                        ? Colors.black
                        : Colors.white,
              )
              : null,
      onTap: () {
        HapticFeedbackUtils.impact();
        Navigator.pop(context);
        // Handle language change
        LanguageState().setLanguage(code);
        ToastTheme.showSuccess(
          context,
          message: AppStrings.getWithParams(
            "language_changed_to",
            LanguageState().currentLanguage,
            params: {
              "language": L10n.get(nameKey),
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
              child: L10n.text(
                "about_uy_dosh",
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
                L10n.text(
                  "about_description",
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
                  HapticFeedbackUtils.impact();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: L10n.text("close"),
              ),
            ],
          ),
    );
  }

  void _showLegalDialog(
    BuildContext context, {
    required String titleKey,
    required String bodyKey,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _getLanguageDialogBackgroundColor(),
            title: Center(
              child: L10n.text(
                titleKey,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _getAboutModalTextColor(),
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                L10n.get(bodyKey),
                style: TextStyle(
                  fontSize: 16,
                  color: _getAboutModalTextColor(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedbackUtils.impact();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: L10n.text("close"),
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
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeIcon(icon, size: 20, color: _getAboutModalTextColor()),
          const SizedBox(width: 12),
          Expanded(
            child: L10n.text(
              key,
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
