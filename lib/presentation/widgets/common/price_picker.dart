import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class PricePicker extends StatelessWidget {
  /// The currently selected price in dollars
  final int selectedPrice;

  /// Callback function called when price selection changes
  final ValueChanged<int> onPriceChanged;

  /// Whether to use theme colors (default: true)
  final bool useThemeColors;

  /// Whether the picker is required (affects visual styling)
  final bool isRequired;

  /// Custom height for the picker container (default: 80)
  final double height;

  /// Custom border radius (default: 10)
  final double borderRadius;

  /// Whether to show haptic feedback (default: true)
  final bool enableHapticFeedback;

  /// Custom price icon color (if null, uses theme-aware color)
  final Color? priceIconColor;

  /// Whether to show scroll arrows on the right side
  final bool showArrows;

  const PricePicker({
    super.key,
    required this.selectedPrice,
    required this.onPriceChanged,
    this.priceIconColor,
    this.useThemeColors = true,
    this.isRequired = false,
    this.height = 80,
    this.borderRadius = 10,
    this.enableHapticFeedback = true,
    this.showArrows = true,
  });

  /// Get the appropriate price icon color based on theme and price
  Color _getPriceIconColor() {
    if (priceIconColor != null) {
      return priceIconColor!;
    }

    if (selectedPrice <= 150) {
      return AppColors.success;
    } else if (selectedPrice <= 250) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  /// Handle price selection change
  void _onPriceChanged(int index) {
    final newPrice = (index + 1) * 10;

    if (enableHapticFeedback && HapticFeedbackState().isEnabled) {
      HapticFeedbackUtils.impact();
    }

    onPriceChanged(newPrice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use the same styling as listing type picker
    final backgroundColor = theme.colorScheme.surfaceVariant;
    final borderColor = theme.colorScheme.outline;
    // Use black font for light theme, theme-aware color otherwise
    final textColor =
        ThemeState().isLightTheme
            ? Colors.black
            : theme.colorScheme.onSurfaceVariant;

    // Calculate initial index based on selected price (range: 10-500)
    final initialIndex = ((selectedPrice ~/ 10) - 1).clamp(0, 49);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      height: height,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              onSelectedItemChanged: _onPriceChanged,
              children: List.generate(50, (index) {
                final price = (index + 1) * 10;
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        price.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "y.e.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getPriceIconColor(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "/ ${LanguageAwareStringHelper.getCurrent(context, "month")}",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Right part with arrows - same as listing type picker
          if (showArrows)
            Container(
              width: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
