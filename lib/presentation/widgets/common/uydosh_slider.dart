import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
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
    this.forceLtrScale = false,
    this.invertTrack = false,
    this.scaleStartLabel,
    this.scaleEndLabel,
    this.onChangeStart,
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

  /// When true, the track and tick marks follow [TextDirection.ltr] so low
  /// [min] stays on the physical left (e.g. messy → clean reads left → right).
  final bool forceLtrScale;

  /// When true, the thumb maps so physical **left** = [max] and **right** = [min]
  /// while [value] / [onChanged] still use the normal [min]…[max] semantics.
  final bool invertTrack;

  /// Optional captions at the physical start/end of the track (shown when both
  /// are non-null).
  final String? scaleStartLabel;
  final String? scaleEndLabel;
  final ValueChanged<int>? onChangeStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ThemeState().currentTheme;
    final isLightTheme = currentTheme == AppTheme.lightTheme;
    final isBlueTheme = currentTheme == AppTheme.blueTheme;
    final clamped = value.clamp(min, max);
    final selectedValueText = labels != null &&
            clamped >= min &&
            clamped <= max &&
            (clamped - min) < labels!.length
        ? labels![clamped - min]
        : clamped.toString();
    final selectedValueBorderColor = isBlueTheme
        ? Colors.white
        : (isLightTheme ? Colors.black : theme.colorScheme.onSurface);
    final trackValue = invertTrack ? (max + min - clamped) : clamped;

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
                  color: isBlueTheme
                      ? Colors.white
                      : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isBlueTheme
                        ? Colors.white
                        : (isLightTheme ? Colors.grey[800] : Colors.grey[200]),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selectedValueBorderColor,
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    selectedValueText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isBlueTheme
                          ? Colors.white
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Compact slider: custom thumb / track / overlay sizes and a fixed
          // height wrapper collapse the default ~48px tap target down to ~24px
          // so the tile reads tight without shrinking the hit area too much.
          Builder(
            builder: (context) {
              final mutedColor = isBlueTheme
                  ? Colors.white70
                  : (isLightTheme ? Colors.grey[600] : Colors.grey[400]);
              final scaleChildren = <Widget>[
                SizedBox(
                  height: 24,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: isBlueTheme
                          ? Colors.blue[600]
                          : theme.colorScheme.primary,
                      inactiveTrackColor:
                          isBlueTheme ? Colors.grey[300] : Colors.grey[600],
                      thumbColor: isBlueTheme
                          ? Colors.blue[600]
                          : theme.colorScheme.primary,
                      overlayColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      valueIndicatorColor: theme.colorScheme.primary,
                      valueIndicatorShape:
                          const PaddedSliderValueIndicatorShape(
                        labelPadding: 24.0,
                      ),
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Slider(
                      value: trackValue.toDouble(),
                      min: min.toDouble(),
                      max: max.toDouble(),
                      divisions: divisions ?? (max - min),
                      label: selectedValueText,
                      onChangeStart: (newValue) {
                        final rounded = newValue.round();
                        final api =
                            invertTrack ? (max + min - rounded) : rounded;
                        onChangeStart?.call(api);
                      },
                      onChanged: (newValue) {
                        UiFeedbackUtils.sliderTick();
                        final rounded = newValue.round();
                        final api =
                            invertTrack ? (max + min - rounded) : rounded;
                        onChanged(api);
                      },
                    ),
                  ),
                ),
                if (scaleStartLabel != null && scaleEndLabel != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            scaleStartLabel!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            scaleEndLabel!,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (labels != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(max - min + 1, (i) {
                        final n = invertTrack ? (max - i) : (min + i);
                        return n;
                      }).map((n) {
                        return Text(
                          n.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: mutedColor,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ];

              final scaleColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: scaleChildren,
              );

              if (forceLtrScale) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: scaleColumn,
                );
              }
              return scaleColumn;
            },
          ),
        ],
      ),
    );
  }
}

/// Shared slider chrome for price / range controls outside [UydoshSlider] rows.
class UydoshSliderChrome {
  UydoshSliderChrome._();

  static SliderThemeData priceRangeTrack(
    BuildContext context, {
    required Color sliderColor,
    required Color inactiveTrackColor,
  }) {
    return SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
      rangeThumbShape:
          const RoundRangeSliderThumbShape(enabledThumbRadius: 8.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
      activeTrackColor: sliderColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: sliderColor,
      overlayColor: sliderColor.withValues(alpha: 0.1),
      showValueIndicator: ShowValueIndicator.always,
      valueIndicatorColor: sliderColor,
      valueIndicatorShape: const PaddedSliderValueIndicatorShape(
        labelPadding: 16.0,
      ),
      rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
      ),
    );
  }
}
