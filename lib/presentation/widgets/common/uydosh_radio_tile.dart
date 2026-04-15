import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// A reusable selection row with Radio and title.
/// Used for single-choice forms (e.g. complaint category selection).
class UydoshRadioTile<T> extends StatelessWidget {
  const UydoshRadioTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    super.key,
    this.margin,
    this.selectedTileColor,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget title;
  final EdgeInsetsGeometry? margin;
  final Color? selectedTileColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;
    final baseFontSize = theme.textTheme.bodyLarge?.fontSize ?? 15;

    final isBlueTheme = ThemeState().isBlueTheme;
    final baseColor =
        (isBlueTheme && isSelected)
            ? (selectedTileColor ?? Colors.white)
            : theme.colorScheme.surface;

    final foregroundColor =
        (isBlueTheme && isSelected)
            ? Colors.black.withValues(alpha: 0.88)
            : theme.colorScheme.onSurface;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
      boxShadow:
          isSelected
              ? ThreeDSurfaceStyle.insetRecessedShadows(context)
              : ThreeDSurfaceStyle.elevatedShadows(context),
    );

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onChanged(value),
            child: ListTileTheme(
              textColor: foregroundColor,
              iconColor: foregroundColor,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: baseFontSize + 2,
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  title: title,
                  leading: Radio<T>(
                    value: value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return isBlueTheme
                            ? const Color(0xFF1E3A5F)
                            : theme.colorScheme.primary;
                      }
                      return foregroundColor.withValues(alpha: 0.72);
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
