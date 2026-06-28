import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";

/// Shared theme/color helpers for listing detail widgets.
/// Centralizes theme-dependent color logic for consistent styling.
class ListingDetailThemeHelper {
  ListingDetailThemeHelper._();

  static Color get iconColor {
    if (ThemeState().isLightTheme) return Colors.black;
    if (ThemeState().isBlueTheme) return Colors.white;
    return AppColors.primary;
  }

  static Color get secondaryTextColor =>
      AppColors.textLight; // Used with Theme.of(context) where available

  static Color get descriptionTextColor {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    if (ThemeState().isLightTheme) return Colors.black;
    return AppColors.textGrey;
  }

  /// Tappable @Telegram / phone links in listing description (readable on blue gradient).
  static Color get descriptionLinkColor {
    if (ThemeState().isBlueTheme) return Colors.white;
    if (ThemeState().isLightTheme) return AppColors.primary;
    return AppColors.primary;
  }

  /// Frosted glass tiles on listing detail (matches inbox + alerts).
  static bool get useGlassTiles => ThemeState().usesLiquidGlassChrome;

  static Color get locationTextColor {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    return AppColors.textDark87;
  }

  static Color get dateTextColor {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    return AppColors.textDark87;
  }

  static Color get dateIconColor {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    return AppColors.textGrey600;
  }

  static Color get yandexButtonColor {
    if (ThemeState().isBlueTheme) return Colors.white;
    return AppColors.textDark;
  }

  static Color get privateRoomIconColor {
    if (ThemeState().isLightTheme) return AppColors.primary;
    if (ThemeState().isBlueTheme) return Colors.white;
    return AppColors.primary;
  }

  static Color get amenityIconColor {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    if (ThemeState().isLightTheme) return Colors.black;
    return AppColors.iconPrimary;
  }

  static Color get amenityChipBackgroundColor {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight.withValues(alpha: 0.1);
    }
    if (ThemeState().isLightTheme) return Colors.white;
    return AppColors.primary.withValues(alpha: 0.1);
  }

  static Color get amenityChipBorderColor {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    if (ThemeState().isLightTheme) return Colors.black;
    return AppColors.primary;
  }

  static Color secondaryTextColorFromContext(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);

  static Color lineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  static Color genderColor(int gender) {
    switch (gender) {
      case 1:
        return AppColors.genderMale;
      case 2:
        return AppColors.genderFemale;
      default:
        return AppColors.textGrey;
    }
  }

  /// Icon and label color for gender badges (higher contrast on light theme).
  static Color genderForegroundColor(int gender) {
    if (ThemeState().isLightTheme && gender == 1) {
      return AppColors.genderMaleLightForeground;
    }
    return genderColor(gender);
  }
}
