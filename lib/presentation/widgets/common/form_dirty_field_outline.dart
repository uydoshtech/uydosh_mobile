import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// Accent used to outline form controls that differ from their saved baseline
/// (edit listing / profile flows and gig edit).
Color formDirtyFieldOutlineColor(BuildContext context) {
  if (ThemeState().isBlueTheme) {
    return BlueThemeColors.buttonPrimary;
  }
  if (ThemeState().isLightTheme) {
    return Theme.of(context).colorScheme.primary;
  }
  return Theme.of(context).colorScheme.primary;
}
