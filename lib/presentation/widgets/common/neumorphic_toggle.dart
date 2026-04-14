import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Soft raised track + thumb (neumorphic-style).
///
/// Track size matches Material 3 [Switch] (52 × 32 logical pixels) so width aligns
/// with a standard [Switch].
class NeumorphicToggle extends StatelessWidget {
  const NeumorphicToggle({
    required this.activeAccentColor,
    required this.activeTrackColor,
    required this.inactiveThumbColor,
    required this.inactiveTrackColor,
    required this.onChanged,
    required this.value,
    this.enabled = true,
    this.height = _kMaterial3SwitchTrackHeight,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeAccentColor;
  final Color activeTrackColor;
  final Color inactiveThumbColor;
  final Color inactiveTrackColor;
  final double height;

  /// When false, ignores pointer events and appears dimmed.
  final bool enabled;

  /// Material 3 switch track width.
  static const double _kMaterial3SwitchTrackWidth = 52;

  /// Material 3 switch track height.
  static const double _kMaterial3SwitchTrackHeight = 32;

  static const Duration _anim = Duration(milliseconds: 200);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hi = isDark ? 0.10 : 0.55;
    final lo = isDark ? 0.35 : 0.12;

    final toggle = SizedBox(
      width: _kMaterial3SwitchTrackWidth,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          borderRadius: BorderRadius.circular(height / 2),
          child: AnimatedContainer(
            duration: _anim,
            curve: _curve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: value ? activeTrackColor : inactiveTrackColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: lo),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: hi),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Square thumb fills the padded inner bounds (Material-like ~80% of track).
                final thumbSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                return AnimatedAlign(
                  duration: _anim,
                  curve: _curve,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? activeAccentColor : inactiveThumbColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: lo + 0.05),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: hi * 0.85),
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (!enabled) {
      return Opacity(opacity: 0.45, child: IgnorePointer(child: toggle));
    }
    return toggle;
  }
}

/// Neumorphic switch using the same palette and haptics as the former [ThemeToggle]
/// (Material [Switch]), for settings and filters — not for sun/moon theme controls.
class NeumorphicThemeAwareToggle extends StatelessWidget {
  const NeumorphicThemeAwareToggle({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.height = 32,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final double height;

  static _NeumorphicTogglePalette _paletteForTheme(String themeName) {
    switch (themeName) {
      case AppTheme.blueTheme:
        return _NeumorphicTogglePalette(
          activeAccentColor: AppColors.secondary,
          inactiveThumbColor: Colors.grey[400]!,
          activeTrackColor: AppColors.secondary.withValues(alpha: 0.5),
          inactiveTrackColor: Colors.grey[300]!,
        );
      case AppTheme.lightTheme:
      default:
        return _NeumorphicTogglePalette(
          activeAccentColor: Colors.white,
          inactiveThumbColor: Colors.grey[400]!,
          activeTrackColor: Colors.black,
          inactiveTrackColor: Colors.grey[600]!,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final p = _paletteForTheme(ThemeState().currentTheme);
        return NeumorphicToggle(
          value: value,
          enabled: enabled,
          height: height,
          activeAccentColor: p.activeAccentColor,
          activeTrackColor: p.activeTrackColor,
          inactiveThumbColor: p.inactiveThumbColor,
          inactiveTrackColor: p.inactiveTrackColor,
          onChanged: (newValue) {
            if (HapticFeedbackState().isEnabled) {
              HapticFeedbackUtils.impact();
            }
            onChanged(newValue);
          },
        );
      },
    );
  }
}

class _NeumorphicTogglePalette {
  const _NeumorphicTogglePalette({
    required this.activeAccentColor,
    required this.inactiveThumbColor,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
  });

  final Color activeAccentColor;
  final Color inactiveThumbColor;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
}
