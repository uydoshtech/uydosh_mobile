import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class PriceRangePicker extends StatefulWidget {
  const PriceRangePicker({
    required this.onPriceRangeChanged,
    super.key,
    this.minPrice = 50.0,
    this.maxPrice = 500.0,
    this.initialMinPrice = 50.0,
    this.initialMaxPrice = 250.0,
    this.useSinglePrice = false,
  });

  final Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final double minPrice;
  final double maxPrice;
  final double initialMinPrice;
  final double initialMaxPrice;
  /// When true, shows a single handle and passes the same price for both min and max.
  final bool useSinglePrice;

  @override
  State<PriceRangePicker> createState() => _PriceRangePickerState();
}

class _PriceRangePickerState extends State<PriceRangePicker> {
  late double _minPrice;
  late double _maxPrice;

  Widget _unitIcon(Color color) {
    return Icon(Icons.payments_outlined, size: 14, color: color);
  }

  @override
  void initState() {
    super.initState();
    if (widget.useSinglePrice) {
      final initialPrice = widget.initialMinPrice;
      _minPrice = initialPrice.clamp(widget.minPrice, widget.maxPrice);
      _maxPrice = _minPrice;
    } else {
      _minPrice = widget.initialMinPrice.clamp(widget.minPrice, widget.maxPrice);
      _maxPrice = widget.initialMaxPrice.clamp(widget.minPrice, widget.maxPrice);
    }
  }

  @override
  void didUpdateWidget(PriceRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMinPrice != widget.initialMinPrice ||
        oldWidget.initialMaxPrice != widget.initialMaxPrice) {
      setState(() {
        if (widget.useSinglePrice) {
          final price = widget.initialMinPrice.clamp(
            widget.minPrice,
            widget.maxPrice,
          );
          _minPrice = price;
          _maxPrice = price;
        } else {
          _minPrice = widget.initialMinPrice.clamp(
            widget.minPrice,
            widget.maxPrice,
          );
          _maxPrice = widget.initialMaxPrice.clamp(
            widget.minPrice,
            widget.maxPrice,
          );
        }
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

    // Get the appropriate text color
    Color getTextColor() {
      if (themeState.isBlueTheme) {
        return Colors.white; // White text for blue theme
      }
      return Colors.black; // Black text for default theme
    }

    final sliderColor = getSliderColor();
    final textColor = getTextColor();

    // Inactive track: use lighter color in blue theme for visibility on dark background
    Color getInactiveTrackColor() {
      if (themeState.isBlueTheme) {
        return Colors.white.withValues(alpha: 0.35);
      }
      return sliderColor.withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: theme,
      ),
      child: Row(
        children: [
          if (!widget.useSinglePrice)
            // Min price label on the left (range mode only)
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _unitIcon(textColor),
                    const SizedBox(width: 4),
                    Text(
                      "${_minPrice.round()}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: textColor),
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
                  enabledThumbRadius: 8.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16.0,
                ),
                activeTrackColor: sliderColor,
                inactiveTrackColor: getInactiveTrackColor(),
                thumbColor: sliderColor,
                overlayColor: sliderColor.withValues(alpha: 0.1),
              ),
              child: widget.useSinglePrice
                  ? Slider(
                      value: _minPrice,
                      min: widget.minPrice,
                      max: widget.maxPrice,
                      activeColor: sliderColor,
                      inactiveColor: getInactiveTrackColor(),
                      label: "${_minPrice.round()}",
                      onChanged: (value) {
                        final newPrice = (value / 10).round() * 10.0;
                        if ((newPrice ~/ 10) != (_minPrice ~/ 10)) {
                          HapticFeedbackUtils.impact();
                          SendSoundUtils.playSelectionSound();
                        }
                        setState(() {
                          _minPrice = newPrice;
                          _maxPrice = newPrice;
                        });
                        widget.onPriceRangeChanged(
                          _minPrice.roundToDouble(),
                          _maxPrice.roundToDouble(),
                        );
                      },
                    )
                  : Transform.translate(
                      offset: const Offset(0.0, 0.0),
                      child: RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: widget.minPrice,
                        max: widget.maxPrice,
                        activeColor: sliderColor,
                        inactiveColor: getInactiveTrackColor(),
                        labels: RangeLabels(
                          "${_minPrice.round()}",
                          "${_maxPrice.round()}",
                        ),
                        onChanged: (values) {
                          final newMin = (values.start / 10).round() * 10.0;
                          final newMax = (values.end / 10).round() * 10.0;
                          if ((newMin ~/ 10) != (_minPrice ~/ 10) ||
                              (newMax ~/ 10) != (_maxPrice ~/ 10)) {
                            HapticFeedbackUtils.impact();
                            SendSoundUtils.playSelectionSound();
                          }
                          setState(() {
                            _minPrice = newMin;
                            _maxPrice = newMax;
                          });
                          widget.onPriceRangeChanged(
                            _minPrice.roundToDouble(),
                            _maxPrice.roundToDouble(),
                          );
                        },
                      ),
                    ),
            ),
          ),

          // Price label on the right
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(widget.useSinglePrice ? _minPrice : _maxPrice).round()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                  const SizedBox(width: 4),
                  _unitIcon(textColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
