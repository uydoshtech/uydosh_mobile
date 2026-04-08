import "package:flutter/material.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A theme toggle with sun (light) and moon (dark/blue) icons.
/// Matches the design: pill-shaped track, circular sliding thumb, moon left / sun right.
class ThemeToggleSunMoon extends StatelessWidget {
  const ThemeToggleSunMoon({
    super.key,
    this.iconColor,
    this.size = 35,
    this.onToggled,
  });

  /// Color for the icons. If null, uses dark grey for light theme and white for dark theme.
  final Color? iconColor;

  /// Size of the toggle (controls height; width is proportional)
  final double size;

  /// Optional callback invoked after the theme has been toggled.
  final VoidCallback? onToggled;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final isLight = themeState.isLightTheme;

        // Track: light grey for light theme, dark grey for dark theme
        final trackColor = isLight
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF424242);

        // Icons and thumb: dark grey for light theme, white for dark theme
        final iconAndThumbColor = iconColor ??
            (isLight ? const Color(0xFF616161) : Colors.white);

        return GestureDetector(
          onTap: () async {
            if (HapticFeedbackState().isEnabled) {
              HapticFeedbackUtils.impact();
            }
            await themeState.toggleTheme();
            onToggled?.call();
          },
          child: Container(
            width: size * 1.6,
            height: size * 0.9,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(size * 0.5),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Moon icon (left)
                Positioned(
                  left: size * 0.22,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ThemeIcon(
                      Icons.dark_mode,
                      size: size * 0.5,
                      color: isLight
                          ? iconAndThumbColor.withValues(alpha: 0.4)
                          : iconAndThumbColor,
                    ),
                  ),
                ),
                // Sun icon (right)
                Positioned(
                  right: size * 0.22,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ThemeIcon(
                      Icons.light_mode,
                      size: size * 0.5,
                      color: isLight
                          ? iconAndThumbColor
                          : iconAndThumbColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                // Circular sliding thumb
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment:
                      isLight ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: size * 0.7,
                    height: size * 0.7,
                    margin: EdgeInsets.symmetric(horizontal: size * 0.1),
                    decoration: BoxDecoration(
                      color: iconAndThumbColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
