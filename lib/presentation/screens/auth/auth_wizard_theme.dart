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

  /// Content (label + icon) color for the *selected* state of auth-wizard
  /// pill / card toggles. In both blue and light themes the selected surface
  /// is filled with the primary color (deep blue / pure black respectively),
  /// so the foreground is white in both cases — otherwise the label and icon
  /// vanish into the dark fill.
  static Color getSelectedButtonTextColor() => Colors.white;

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
