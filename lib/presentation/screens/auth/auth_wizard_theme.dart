import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// Theme-dependent color helpers for auth wizard screens.
abstract final class AuthWizardTheme {
  static Color getPrimaryColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.primary;
    } else {
      return AppColors.primary;
    }
  }

  static Color getSuccessColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.success;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.success;
    } else {
      return AppColors.success;
    }
  }

  static Color getOnboardingBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.onboardingBackground;
    }
    return LightThemeColors.onboardingBackground;
  }

  static Color getSelectedButtonBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary;
    }
    return Colors.transparent;
  }

  /// Foreground for auth-wizard toggles and selectors when their tile reads as
  /// “filled”. Blue theme uses a saturated plate — white text. Light theme uses
  /// a white / near-white fill ([AuthWizardProfilePage] selected surface) —
  /// dark text. Messaging/dark themes keep white on primary-tinted fills.
  static Color getSelectedButtonTextColor() {
    if (ThemeState().isBlueTheme) return Colors.white;
    if (ThemeState().isLightTheme) return LightThemeColors.textPrimary;
    return Colors.white;
  }

  static Color getSelectedButtonBorderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    }
    return Colors.black;
  }

  static Color getUnselectedButtonBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary;
    }
    return Colors.transparent;
  }

  static Color getUnselectedButtonBorderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    }
    return Colors.grey.shade300;
  }

  static Color getUnselectedButtonTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    }
    return Colors.black;
  }

  static Color getInputTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.black;
    }
    return Colors.black;
  }

  static Color getBottomSheetBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.onboardingCard;
    }
    return LightThemeColors.onboardingCard;
  }

  static Color getBottomSheetTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    }
    return Colors.black;
  }

  static Color getBottomSheetCursorColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    }
    return Colors.black;
  }

  /// L10n key for the OAuth wizard step subtitle shown above the provider
  /// buttons (generic — logos identify each option).
  static String oauthStepTitleL10nKey() => "sign_in_oauth_prompt";

  static Color getBottomSheetHandleColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return Colors.white.withValues(alpha: 0.4);
    } else if (ThemeState().isLightTheme) {
      return Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
    }
  }
}
