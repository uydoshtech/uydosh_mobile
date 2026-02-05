import "package:flutter/material.dart";
import "package:flutter/gestures.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// A theme-aware toggle switch component that automatically adapts its colors
/// based on the current app theme
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.materialTapTargetSize = MaterialTapTargetSize.padded,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.overlayColor,
    this.splashRadius,
    this.focusColor,
    this.hoverColor,
  });

  /// The current value of the toggle
  final bool value;

  /// Called when the user toggles the switch
  final ValueChanged<bool> onChanged;

  /// The color to use when the switch is on (overrides theme-aware colors if provided)
  final Color? activeColor;

  /// The color to use when the switch is off (overrides theme-aware colors if provided)
  final Color? inactiveColor;

  /// The color to use for the track when the switch is on (overrides theme-aware colors if provided)
  final Color? activeTrackColor;

  /// The color to use for the track when the switch is off (overrides theme-aware colors if provided)
  final Color? inactiveTrackColor;

  /// The color to use for the thumb when the switch is on (overrides theme-aware colors if provided)
  final Color? activeThumbColor;

  /// The color to use for the thumb when the switch is off (overrides theme-aware colors if provided)
  final Color? inactiveThumbColor;

  /// The size of the tap target
  final MaterialTapTargetSize materialTapTargetSize;

  /// The drag start behavior
  final DragStartBehavior dragStartBehavior;

  /// The mouse cursor
  final MouseCursor? mouseCursor;

  /// The focus node
  final FocusNode? focusNode;

  /// Whether the switch should autofocus
  final bool autofocus;

  /// The overlay color
  final MaterialStateProperty<Color?>? overlayColor;

  /// The splash radius
  final double? splashRadius;

  /// The focus color
  final Color? focusColor;

  /// The hover color
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final currentTheme = ThemeState().currentTheme;

        // Get theme-aware colors
        final themeColors = _getThemeAwareColors(currentTheme);

        return Switch(
          value: value,
          onChanged: (newValue) {
            // Add haptic feedback when toggle changes (if enabled)
            if (AppConfig.enableHapticFeedback) {
              HapticFeedbackUtils.impact();
            }
            onChanged(newValue);
          },
          activeColor: activeColor ?? themeColors.activeColor,
          inactiveThumbColor:
              inactiveThumbColor ?? themeColors.inactiveThumbColor,
          activeTrackColor: activeTrackColor ?? themeColors.activeTrackColor,
          inactiveTrackColor:
              inactiveTrackColor ?? themeColors.inactiveTrackColor,
          materialTapTargetSize: materialTapTargetSize,
          dragStartBehavior: dragStartBehavior,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          overlayColor: overlayColor,
          splashRadius: splashRadius,
          focusColor: focusColor,
          hoverColor: hoverColor,
        );
      },
    );
  }

  /// Returns theme-aware colors based on the current app theme
  _ThemeToggleColors _getThemeAwareColors(String themeName) {
    switch (themeName) {
      case AppTheme.blueTheme:
        return _ThemeToggleColors(
          activeColor: AppColors.secondary, // Use blue for active color
          inactiveThumbColor: Colors.grey[400]!,
          activeTrackColor: AppColors.secondary.withValues(
            alpha: 0.5,
          ), // Use blue track
          inactiveTrackColor: Colors.grey[300]!,
        );
      case AppTheme.lightTheme:
      default:
        return _ThemeToggleColors(
          activeColor: Colors.white,
          inactiveThumbColor: Colors.grey[400]!,
          activeTrackColor: Colors.black,
          inactiveTrackColor: Colors.grey[600]!,
        );
    }
  }
}

/// Internal class to hold theme-aware colors for the toggle
class _ThemeToggleColors {
  const _ThemeToggleColors({
    required this.activeColor,
    required this.inactiveThumbColor,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
  });

  final Color activeColor;
  final Color inactiveThumbColor;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
}
