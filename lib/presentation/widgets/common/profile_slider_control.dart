import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ProfileSliderControl extends StatelessWidget {
  const ProfileSliderControl({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    super.key,
    this.icon,
    this.divisions,
    this.labels,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final int min;
  final int max;
  final IconData? icon;
  final int? divisions;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ThemeState().currentTheme;
    final isLightTheme = currentTheme == AppTheme.lightTheme;
    final isBlueTheme = currentTheme == AppTheme.blueTheme;
    final currentValue = value ?? min;
    final sectionBackground =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: sectionBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
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
                currentValue.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isBlueTheme ? Colors.white : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:
                  isBlueTheme ? Colors.blue[600] : theme.colorScheme.primary,
              inactiveTrackColor:
                  isBlueTheme ? Colors.grey[300] : Colors.grey[600],
              thumbColor:
                  isBlueTheme ? Colors.blue[600] : theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
              valueIndicatorColor: theme.colorScheme.primary,
              valueIndicatorTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Slider(
              value: currentValue.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions ?? (max - min),
              label:
                  labels != null &&
                          currentValue >= 0 &&
                          currentValue < labels!.length
                      ? labels![currentValue]
                      : currentValue.toString(),
              onChanged: (double newValue) {
                onChanged(newValue.round());
              },
            ),
          ),
          if (labels != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  labels!.map((label) {
                    return Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isBlueTheme
                                ? Colors.white70
                                : (isLightTheme
                                    ? Colors.grey[600]
                                    : Colors.grey[400]),
                        fontSize: 10,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
