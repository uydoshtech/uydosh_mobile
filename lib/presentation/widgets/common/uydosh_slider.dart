import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/padded_slider_value_indicator_shape.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable settings row with an icon, label, value display, and a slider.
/// Theme-aware. Can be wrapped in a container (e.g. ProfileSliderControl) for
/// section styling.
class UydoshSlider extends StatelessWidget {
  const UydoshSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    super.key,
    this.icon,
    this.divisions,
    this.labels,
    this.contentPadding,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final IconData? icon;
  final int? divisions;
  final List<String>? labels;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ThemeState().currentTheme;
    final isLightTheme = currentTheme == AppTheme.lightTheme;
    final isBlueTheme = currentTheme == AppTheme.blueTheme;

    return Padding(
      padding: contentPadding ?? const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                ThemeIcon(
                  icon,
                  color:
                      isBlueTheme
                          ? Colors.white
                          : (isLightTheme
                              ? Colors.grey[600]
                              : Colors.grey[400]),
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        isBlueTheme
                            ? Colors.white
                            : (isLightTheme
                                ? Colors.grey[800]
                                : Colors.grey[200]),
                  ),
                ),
              ),
              Text(
                labels != null &&
                        value >= min &&
                        value <= max &&
                        (value - min) < labels!.length
                    ? labels![value - min]
                    : value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isBlueTheme ? Colors.white : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          // Compact slider: custom thumb / track / overlay sizes and a fixed
          // height wrapper collapse the default ~48px tap target down to ~24px
          // so the tile reads tight without shrinking the hit area too much.
          SizedBox(
            height: 24,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor:
                    isBlueTheme ? Colors.blue[600] : theme.colorScheme.primary,
                inactiveTrackColor:
                    isBlueTheme ? Colors.grey[300] : Colors.grey[600],
                thumbColor:
                    isBlueTheme ? Colors.blue[600] : theme.colorScheme.primary,
                overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                valueIndicatorColor: theme.colorScheme.primary,
                valueIndicatorShape: const PaddedSliderValueIndicatorShape(
                  labelPadding: 24.0,
                ),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: divisions ?? (max - min),
                label:
                    labels != null &&
                            value >= min &&
                            value <= max &&
                            (value - min) < labels!.length
                        ? labels![value - min]
                        : value.toString(),
                onChanged: (newValue) {
                  onChanged(newValue.round());
                },
              ),
            ),
          ),
          if (labels != null) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    List.generate(max - min + 1, (i) => min + i).map((n) {
                  return Text(
                    n.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isBlueTheme
                              ? Colors.white70
                              : (isLightTheme
                                  ? Colors.grey[600]
                                  : Colors.grey[400]),
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
