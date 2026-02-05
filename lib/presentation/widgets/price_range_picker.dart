import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class PriceRangePicker extends StatefulWidget {
  const PriceRangePicker({
    required this.onPriceRangeChanged,
    super.key,
    this.minPrice = 50.0,
    this.maxPrice = 500.0,
    this.initialMinPrice = 50.0,
    this.initialMaxPrice = 250.0,
  });

  final Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final double minPrice;
  final double maxPrice;
  final double initialMinPrice;
  final double initialMaxPrice;

  @override
  State<PriceRangePicker> createState() => _PriceRangePickerState();
}

class _PriceRangePickerState extends State<PriceRangePicker> {
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    // Use the initial values passed from SearchFiltersState
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;

    // Ensure values are within the allowed range
    _minPrice = _minPrice.clamp(widget.minPrice, widget.maxPrice);
    _maxPrice = _maxPrice.clamp(widget.minPrice, widget.maxPrice);
  }

  @override
  void didUpdateWidget(PriceRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if initial values change (e.g., when restoring from saved state)
    if (oldWidget.initialMinPrice != widget.initialMinPrice ||
        oldWidget.initialMaxPrice != widget.initialMaxPrice) {
      setState(() {
        _minPrice = widget.initialMinPrice.clamp(
          widget.minPrice,
          widget.maxPrice,
        );
        _maxPrice = widget.initialMaxPrice.clamp(
          widget.minPrice,
          widget.maxPrice,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();

    // Get the appropriate color for the blue theme to match the search button
    Color getSliderColor() {
      if (themeState.isBlueTheme) {
        return BlueThemeColors.buttonPrimary; // Same color as search button
      }
      return theme.colorScheme.primary; // Default theme color
    }

    // Get the appropriate background color
    Color getBackgroundColor() {
      if (themeState.isBlueTheme) {
        return BlueThemeColors.primary; // Dark blue background for blue theme
      }
      return Colors.white; // White background for default theme
    }

    // Get the appropriate text color
    Color getTextColor() {
      if (themeState.isBlueTheme) {
        return Colors.white; // White text for blue theme
      }
      return Colors.black; // Black text for default theme
    }

    final sliderColor = getSliderColor();
    final backgroundColor = getBackgroundColor();
    final textColor = getTextColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          // Min price label on the left
          Container(
            width: 50, // Fixed width for consistent sizing
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${_minPrice.round()}",
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "\ny.e.",
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Slider in the center
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 18.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 32.0,
                ),
                activeTrackColor: sliderColor,
                inactiveTrackColor: sliderColor.withValues(alpha: 0.2),
                thumbColor: sliderColor,
                overlayColor: sliderColor.withValues(alpha: 0.1),
              ),
              child: Transform.translate(
                offset: const Offset(
                  0.0,
                  0.0,
                ), // Move slider left by 8px to extend beyond container
                child: RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: widget.minPrice,
                  max: widget.maxPrice,
                  // Removed divisions to eliminate visual tick marks
                  activeColor: sliderColor,
                  inactiveColor: sliderColor.withValues(alpha: 0.2),
                  labels: RangeLabels(
                    "${_minPrice.round()} y.e.",
                    "${_maxPrice.round()} y.e.",
                  ),
                  onChanged: (values) {
                    // Round to nearest 10-unit increment
                    final newMin = (values.start / 10).round() * 10.0;
                    final newMax = (values.end / 10).round() * 10.0;

                    // Check if we crossed a 10-unit threshold for haptic feedback
                    final oldMin = _minPrice;
                    final oldMax = _maxPrice;

                    // Haptic feedback for every 10-unit step change
                    if ((newMin ~/ 10) != (oldMin ~/ 10) ||
                        (newMax ~/ 10) != (oldMax ~/ 10)) {
                      HapticFeedbackUtils.selection();
                    }

                    setState(() {
                      _minPrice = newMin;
                      _maxPrice = newMax;
                    });

                    // Call the callback to save the changes
                    widget.onPriceRangeChanged(
                      _minPrice.roundToDouble(),
                      _maxPrice.roundToDouble(),
                    );
                  },
                ),
              ),
            ),
          ),

          // Max price label on the right
          Container(
            width: 50, // Fixed width for consistent sizing
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${_maxPrice.round()}",
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "\ny.e.",
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
