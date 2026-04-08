import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A segmented control with pill-shaped buttons, matching the Period selector style.
/// Used for metro stations, districts, time ranges, and similar single-selection lists.
///
/// Features:
/// - Dark-themed container with rounded corners
/// - Title at top
/// - Horizontal row of pill buttons (scrollable when many options)
/// - Unselected: lighter background with thin border
/// - Selected: darker background with checkmark icon
class RotationSpinner<T> extends StatelessWidget {
  const RotationSpinner({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    super.key,
    this.itemBuilder,
    this.scrollable = false,
  });

  /// Title displayed above the selection controls
  final String title;

  /// List of options. Each item has a [value] and [label].
  final List<RotationSpinnerOption<T>> options;

  /// Currently selected value
  final T selectedValue;

  /// Called when selection changes
  final ValueChanged<T> onChanged;

  /// Optional custom builder for each option (label is used by default)
  final String Function(T value)? itemBuilder;

  /// If true, enables horizontal scroll when there are many options
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors matching the screenshot: dark container, pill buttons
    final containerColor = isDark ? const Color(0xFF2D3748) : theme.colorScheme.surfaceContainerHighest;
    final unselectedBg = isDark ? const Color(0xFF4A5568) : Colors.grey[200]!;
    final selectedBg = isDark ? const Color(0xFF616B7E) : Colors.grey[800]!;
    final borderColor = isDark ? const Color(0xFF718096) : theme.colorScheme.outline;
    final unselectedTextColor = isDark ? Colors.white70 : Colors.black87;
    const selectedTextColor = Colors.white;

    final buttons = options.map((opt) {
      final isSelected = _isSelected(opt.value);
      return GestureDetector(
        onTap: () {
          HapticFeedbackUtils.impact();
          SendSoundUtils.playSelectionSound();
          onChanged(opt.value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? selectedBg : borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const ThemeIcon(Icons.check, size: 16, color: selectedTextColor),
                const SizedBox(width: 6),
              ],
              Text(
                itemBuilder != null ? itemBuilder!(opt.value) : opt.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          scrollable
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < buttons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        buttons[i],
                      ],
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: buttons,
                ),
        ],
      ),
    );
  }

  bool _isSelected(T value) {
    return value == selectedValue;
  }
}

/// Represents a single option in the rotation spinner
class RotationSpinnerOption<T> {
  const RotationSpinnerOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}
