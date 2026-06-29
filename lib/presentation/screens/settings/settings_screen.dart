import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/state/home_start_view_settings_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/restore_filters_state.dart";
import "package:uy_dosh/base/state/sound_effects_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_info_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_menu_item.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_toggle.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

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

  Color _getCardColor(BuildContext context) {
    final bg = _getBackgroundColor(context);
    // Slight lift from background for neumorphic cards.
    return Color.lerp(
            bg, Colors.white, ThemeState().isBlueTheme ? 0.06 : 0.12) ??
        bg;
  }

  List<BoxShadow> _getNeumorphicShadows(BuildContext context) {
    final isBlue = ThemeState().isBlueTheme;
    final darkShadow =
        (isBlue ? Colors.black : const Color(0xFF0B1220)).withValues(
      alpha: isBlue ? 0.28 : 0.12,
    );
    final lightShadow = Colors.white.withValues(alpha: isBlue ? 0.10 : 0.75);

    return [
      BoxShadow(
        color: darkShadow,
        blurRadius: 18,
        offset: const Offset(8, 10),
      ),
      BoxShadow(
        color: lightShadow,
        blurRadius: 18,
        offset: const Offset(-8, -10),
      ),
    ];
  }

  Widget _buildSectionHeader(String titleKey) {
    return Padding(
      // Keep the section label visually separated from the card below.
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Text(
        L10n.get(titleKey).toUpperCase(),
        style: TextStyle(
          color: _getSecondaryTextColor(),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: _getNeumorphicShadows(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _withDividers(children),
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> children) {
    if (children.isEmpty) return const [];
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: ThemeState().isBlueTheme
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE5E7EB),
    );

    return [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i != children.length - 1) divider,
      ],
    ];
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

  /// Get localized theme name based on current language
  String _getLocalizedThemeName(String themeCode) {
    switch (themeCode) {
      case AppTheme.systemTheme:
        return L10n.get("system_theme");
      case AppTheme.blueTheme:
        return L10n.get("blue_theme");
      default:
        return L10n.get("light_theme");
    }
  }

  Future<void> _changeThemeFromSettings(
    BuildContext context,
    String themeName,
  ) async {
    await ThemeState().changeTheme(themeName);
    if (!context.mounted) return;

    ToastTheme.showSuccess(
      context,
      message: AppStrings.getWithParams(
        "theme_changed_to",
        LanguageState().currentLanguage,
        params: {"theme": _getLocalizedThemeName(themeName)},
      ),
    );
  }

  PopupMenuItem<String> _buildThemePopupItem(
    BuildContext context,
    String themeName,
  ) {
    return PopupMenuItem(
      value: themeName,
      child: Row(
        children: [
          ThemeIcon(
            _getThemeIcon(themeName),
            size: 20,
            color: Theme.of(context).popupMenuTheme.textStyle?.color,
          ),
          const SizedBox(width: 8),
          Text(
            _getLocalizedThemeName(themeName),
            style: Theme.of(context).popupMenuTheme.textStyle,
          ),
        ],
      ),
    );
  }

  IconData _getThemeIcon(String themeName) {
    switch (themeName) {
      case AppTheme.systemTheme:
        return Icons.settings_suggest;
      case AppTheme.lightTheme:
        return Icons.light_mode;
      default:
        return Icons.dark_mode;
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
      appBar: CommonAppBar(
        title: L10n.get("settings"),
        showBackButton: true,
        centerTitle: true,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ColoredBox(
        color: _getBackgroundColor(
          context,
        ), // Set background color to match app bar
        child: ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            // PREFERENCES
            _buildSectionHeader("settings_section_preferences"),
            _buildSectionCard(
              context,
              [
                _buildLanguageMenuItem(context),
                _buildThemeMenuItem(context),
              ],
            ),

            // EXPERIENCE
            _buildSectionHeader("settings_section_experience"),
            _buildSectionCard(
              context,
              [
                _buildOnboardingToggleMenuItem(context),
                _buildHomeStartViewToggleMenuItem(context),
                _buildTooltipsToggleMenuItem(context),
                _buildRestoreFiltersToggleMenuItem(context),
                _buildHapticFeedbackToggleMenuItem(context),
                _buildSoundEffectsToggleMenuItem(context),
                _buildAnimationsToggleMenuItems(context),
              ],
            ),

            // ABOUT
            _buildSectionHeader("settings_section_about"),
            _buildSectionCard(
              context,
              [
                _buildMenuItem(
                  icon: Icons.info,
                  titleKey: "menu_about",
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),

            // LEGAL
            _buildSectionHeader("settings_section_legal"),
            _buildSectionCard(
              context,
              [
                _buildMenuItem(
                  icon: Icons.privacy_tip,
                  titleKey: "menu_privacy_policy",
                  onTap: () {
                    _openPrivacyPolicy(context);
                  },
                ),
              ],
            ),

            // bottom breathing room
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    HapticFeedbackUtils.impact();

    final uri = Uri.tryParse(EnvironmentUtil.privacyPolicy);
    if (uri == null) {
      if (context.mounted) {
        ToastTheme.showError(context, message: L10n.get("error"));
      }
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );

    if (!launched && context.mounted) {
      ToastTheme.showError(context, message: L10n.get("error"));
    }
  }

  Widget _buildLanguageMenuItem(BuildContext context) {
    return UydoshMenuItem(
      icon: CupertinoIcons.globe,
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
      iconColor: _getIconColor(),
      trailingColor: _getSecondaryIconColor(),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Widget _buildThemeMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        return UydoshMenuItem(
          icon: Icons.palette,
          title: L10n.text(
            "theme",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: Text(
            _getLocalizedThemeName(ThemeState().selectedTheme),
            style: TextStyle(color: _getSecondaryTextColor()),
          ),
          iconColor: _getIconColor(),
          trailingColor: _getSecondaryIconColor(),
          trailing: PopupMenuButton<String>(
            icon: ThemeIcon(
              _getThemeIcon(ThemeState().selectedTheme),
              color: _getSecondaryIconColor(),
            ),
            onOpened: HapticFeedbackUtils.selection,
            onSelected: (themeName) {
              HapticFeedbackUtils.selection();
              _changeThemeFromSettings(context, themeName);
            },
            itemBuilder: (context) => [
              _buildThemePopupItem(context, AppTheme.systemTheme),
              _buildThemePopupItem(context, AppTheme.lightTheme),
              _buildThemePopupItem(context, AppTheme.blueTheme),
            ],
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

  Widget _buildHomeStartViewToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: HomeStartViewSettingsState(),
      builder: (context, child) {
        return UydoshToggle(
          icon: Icons.map_outlined,
          iconColor: _getIconColor(),
          title: L10n.text(
            "admin_app_setting_home_start_map_title",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: L10n.text(
            "admin_app_setting_home_start_map_subtitle",
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          value: HomeStartViewSettingsState().showMapInitially,
          onChanged: (value) async {
            await HomeStartViewSettingsState().setShowMapInitially(value);
          },
        );
      },
    );
  }

  Widget _buildTooltipsToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: TooltipsState(),
      builder: (context, child) {
        return UydoshToggle(
          icon: Icons.tips_and_updates_outlined,
          iconColor: _getIconColor(),
          title: L10n.text(
            "tooltips_toggle",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: L10n.text(
            "tooltips_toggle_description",
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          value: TooltipsState().enabled,
          onChanged: (value) async {
            if (value) {
              await TooltipsState().enableAndResetAll();
            } else {
              await TooltipsState().setEnabled(false);
            }
          },
        );
      },
    );
  }

  Widget _buildRestoreFiltersToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: RestoreFiltersState(),
      builder: (context, child) {
        return UydoshToggle(
          icon: Icons.restore,
          iconColor: _getIconColor(),
          title: L10n.text(
            "restore_filters_on_start",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: L10n.text(
            "restore_filters_on_start_description",
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          value: RestoreFiltersState().shouldRestore,
          onChanged: (value) async {
            await RestoreFiltersState().setShouldRestore(value);
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

  Widget _buildSoundEffectsToggleMenuItem(BuildContext context) {
    return ListenableBuilder(
      listenable: SoundEffectsState(),
      builder: (context, child) {
        return UydoshToggle(
          icon: Icons.volume_up,
          iconColor: _getIconColor(),
          title: L10n.text(
            "sound_effects",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          subtitle: L10n.text(
            "sound_effects_description",
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 12),
          ),
          value: SoundEffectsState().isEnabled,
          onChanged: (value) async {
            await SoundEffectsState().setEnabled(value);
          },
        );
      },
    );
  }

  Widget _buildAnimationsToggleMenuItems(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AnimationSettingsState(),
        UiPerformancePolicy.listenable,
      ]),
      builder: (context, _) {
        final animations = AnimationSettingsState();
        final optimizedForDevice = animations.uiAnimationsPreferenceEnabled &&
            !animations.uiAnimationsEnabled;

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
              subtitle: _buildAnimationsSubtitle(optimizedForDevice),
              value: animations.uiAnimationsPreferenceEnabled,
              onChanged: (value) async {
                await animations.setUiAnimationsEnabled(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimationsSubtitle(bool optimizedForDevice) {
    final secondaryStyle = TextStyle(
      color: _getSecondaryTextColor(),
      fontSize: 12,
    );
    if (!optimizedForDevice) {
      return L10n.text("ui_animations_description", style: secondaryStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        L10n.text("ui_animations_description", style: secondaryStyle),
        const SizedBox(height: 2),
        L10n.text(
          "ui_animations_optimized_for_device",
          style: secondaryStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
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
      subtitle: subtitleKey != null
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
    showLanguagePickerDialog(context);
  }

  void _showAboutDialog(BuildContext context) {
    final textColor = _getAboutModalTextColor();
    UydoshInfoDialog.show(
      context,
      backgroundColor: _getLanguageDialogBackgroundColor(),
      title: L10n.text(
        "about_uy_dosh",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          L10n.text(
            "about_description",
            style: TextStyle(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(context, "about_feature_1"),
          _buildFeatureItem(context, "about_feature_2"),
          _buildFeatureItem(context, "about_feature_3"),
          _buildFeatureItem(context, "about_feature_4"),
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
