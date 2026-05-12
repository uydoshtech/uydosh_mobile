import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";

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
        final dividerColor = _getThemeAwareDividerColor(themeState);

        final effectivePadding =
            padding ?? const EdgeInsets.symmetric(vertical: 8);
        return Container(
          width: double.infinity,
          padding: effectivePadding,
          child: Row(
            children: [
              Expanded(child: Container(height: 1, color: dividerColor)),
              const SizedBox(width: 10),
              LiquidGlassPlate(
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                sigma: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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

}
