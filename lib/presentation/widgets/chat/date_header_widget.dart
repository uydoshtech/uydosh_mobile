import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class DateHeaderWidget extends StatelessWidget {

  const DateHeaderWidget({
    required this.dateString,
    required this.date,
    super.key,
    /// When set, overrides default vertical spacing (e.g. tighter top under a tab bar).
    this.padding,
  });
  final String dateString;
  final DateTime date;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final textColor = _getThemeAwareTextColor(themeState, context);
        final chromeBaseColor = _getChromeBaseColor(themeState, context);
        final dividerColor = _getThemeAwareDividerColor(themeState);

        final effectivePadding =
            padding ?? const EdgeInsets.symmetric(vertical: 16);
        return Container(
          width: double.infinity,
          padding: effectivePadding,
          child: Row(
            children: [
              Expanded(child: Container(height: 1, color: dividerColor)),
              const SizedBox(width: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    chromeBaseColor,
                  ),
                  boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                  border: Border.all(
                    color: _getThemeAwareBorderColor(themeState),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    dateString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: dividerColor)),
            ],
          ),
        );
      },
    );
  }

  /// Get theme-aware text color
  Color _getThemeAwareTextColor(ThemeState themeState, BuildContext context) {
    if (themeState.isLightTheme) {
      return Colors.black;
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.textPrimary;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _getChromeBaseColor(ThemeState themeState, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (themeState.isLightTheme) {
      // Not pure white, so the pill remains visible on white backgrounds.
      return Color.lerp(scheme.surface, scheme.onSurface, 0.04)!;
    } else if (themeState.isBlueTheme) {
      // Slightly lifted from the blue background so it reads as a pill.
      return Color.lerp(BlueThemeColors.background, Colors.white, 0.18)!;
    }
    return scheme.surface;
  }

  /// Get theme-aware divider color
  Color _getThemeAwareDividerColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[300]!;
    } else if (themeState.isBlueTheme) {
      // Use a subtle "glint" line so it reads on dark blue backgrounds.
      return Colors.white.withValues(alpha: 0.22);
    }
    return Colors.grey[300]!;
  }

  /// Get theme-aware border color
  Color _getThemeAwareBorderColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black.withValues(alpha: 0.08);
    } else if (themeState.isBlueTheme) {
      return Colors.white.withValues(alpha: 0.16);
    }
    return Colors.black.withValues(alpha: 0.08);
  }
}
