import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/padded_slider_value_indicator_shape.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

class PriceRangePicker extends StatefulWidget {
  const PriceRangePicker({
    required this.onPriceRangeChanged,
    super.key,
    this.minPrice = 0.0,
    this.maxPrice = 1000.0,
    this.initialMinPrice = 0.0,
    this.initialMaxPrice = 500.0,
    this.useSinglePrice = false,
    this.showErrorBorder = false,
    this.useGlassPlate = false,
  });

  final Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final double minPrice;
  final double maxPrice;
  final double initialMinPrice;
  final double initialMaxPrice;
  /// When true, shows a single handle and passes the same price for both min and max.
  final bool useSinglePrice;
  /// When true, draws a pulsing red outline to highlight a missing selection.
  final bool showErrorBorder;
  final bool useGlassPlate;

  @override
  State<PriceRangePicker> createState() => _PriceRangePickerState();
}

class _PriceRangePickerState extends State<PriceRangePicker> {
  late double _minPrice;
  late double _maxPrice;

  /// USD-scale tick (matches how listings store the small "USD-index" amounts).
  static const double _stepUsd = 10.0;

  /// UZS-display tick. 10.000 keeps the slider feeling native to UZS users
  /// without producing a wall of zeroes — labels render as `K`/`M` further down.
  static const double _stepUzs = 10000.0;

  /// Nearest step to [v], then nudged into [[rangeMin], [rangeMax]] so we never
  /// round *outside* the track (e.g. 12.600 → nearest 10k is 10.000 < min 12.600).
  static double _snapToStepInRange(
    double v,
    double rangeMin,
    double rangeMax,
    double step,
  ) {
    if (step <= 0 || rangeMax < rangeMin) {
      return v.clamp(rangeMin, rangeMax);
    }
    var snapped = (v / step).round() * step;
    if (snapped < rangeMin) {
      snapped = (rangeMin / step).ceil() * step;
    }
    if (snapped > rangeMax) {
      snapped = (rangeMax / step).floor() * step;
    }
    return snapped.clamp(rangeMin, rangeMax);
  }

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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final theme = Theme.of(context);
        final themeState = ThemeState();

        Color getSliderColor() {
          if (themeState.isBlueTheme) {
            return BlueThemeColors.buttonPrimary;
          }
          return theme.colorScheme.primary;
        }

        Color getTextColor() {
          if (themeState.isBlueTheme) {
            return Colors.white;
          }
          return Colors.black;
        }

        final sliderColor = getSliderColor();
        final textColor = getTextColor();

        Color getInactiveTrackColor() {
          if (themeState.isBlueTheme) {
            return Colors.white.withValues(alpha: 0.35);
          }
          return sliderColor.withValues(alpha: 0.2);
        }

        final isUzsDisplay = PriceDisplaySettingsState().currency ==
            PriceDisplayCurrency.national;
        final rate = AppConfig.uzsPerUsd.toDouble();
        // Slider operates in either USD-scale or UZS-scale depending on pref.
        // Storage stays USD-scale via [_emitFromScaled] so listings/filters
        // don't need to know about the display swap.
        final scale = isUzsDisplay && rate > 0 ? rate : 1.0;
        final step = isUzsDisplay && rate > 0 ? _stepUzs : _stepUsd;

        final scaledRangeMin = widget.minPrice * scale;
        final scaledRangeMax = widget.maxPrice * scale;
        final divisions = ((scaledRangeMax - scaledRangeMin) / step).round();

        var scaledMin = _snapToStepInRange(
          (_minPrice * scale).clamp(scaledRangeMin, scaledRangeMax),
          scaledRangeMin,
          scaledRangeMax,
          step,
        );
        var scaledMax = _snapToStepInRange(
          (_maxPrice * scale).clamp(scaledRangeMin, scaledRangeMax),
          scaledRangeMin,
          scaledRangeMax,
          step,
        );
        if (scaledMin > scaledMax) {
          final t = scaledMin;
          scaledMin = scaledMax;
          scaledMax = t;
        }

        String formatLabel(double scaled) {
          if (isUzsDisplay) {
            return PriceRangeHelper.formatUzsCompact(scaled.round());
          }
          return "${scaled.round()}";
        }

        double emitFromScaled(double scaled) {
          if (!isUzsDisplay || rate <= 0) return scaled;
          // Round to whole USD-scale units so downstream `int price` consumers
          // (listing model, backend filters) get clean integers.
          return (scaled / rate).round().toDouble();
        }

        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (!widget.useSinglePrice)
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _unitIcon(textColor),
                        const SizedBox(width: 4),
                        Text(
                          formatLabel(scaledMin),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),

              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16.0,
                    ),
                    activeTrackColor: sliderColor,
                    inactiveTrackColor: getInactiveTrackColor(),
                    thumbColor: sliderColor,
                    overlayColor: sliderColor.withValues(alpha: 0.1),
                    showValueIndicator: ShowValueIndicator.always,
                    valueIndicatorColor: sliderColor,
                    valueIndicatorShape: const PaddedSliderValueIndicatorShape(
                      labelPadding: 16.0,
                    ),
                    rangeValueIndicatorShape:
                        const PaddleRangeSliderValueIndicatorShape(),
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                  child: widget.useSinglePrice
                      ? Slider(
                          value: scaledMin,
                          min: scaledRangeMin,
                          max: scaledRangeMax,
                          divisions: divisions > 0 ? divisions : null,
                          activeColor: sliderColor,
                          inactiveColor: getInactiveTrackColor(),
                          label: formatLabel(scaledMin),
                          onChanged: (value) {
                            final newScaled = _snapToStepInRange(
                              value,
                              scaledRangeMin,
                              scaledRangeMax,
                              step,
                            );
                            final newUsd = emitFromScaled(newScaled);
                            if ((newScaled / step).round() !=
                                (scaledMin / step).round()) {
                              HapticFeedbackUtils.impact();
                              SendSoundUtils.playSelectionSound();
                            }
                            setState(() {
                              _minPrice = newUsd;
                              _maxPrice = newUsd;
                            });
                            widget.onPriceRangeChanged(newUsd, newUsd);
                          },
                        )
                      : Transform.translate(
                          offset: const Offset(0.0, 0.0),
                          child: RangeSlider(
                            values: RangeValues(scaledMin, scaledMax),
                            min: scaledRangeMin,
                            max: scaledRangeMax,
                            divisions: divisions > 0 ? divisions : null,
                            activeColor: sliderColor,
                            inactiveColor: getInactiveTrackColor(),
                            labels: RangeLabels(
                              formatLabel(scaledMin),
                              formatLabel(scaledMax),
                            ),
                            onChanged: (values) {
                              final newScaledMin = _snapToStepInRange(
                                values.start,
                                scaledRangeMin,
                                scaledRangeMax,
                                step,
                              );
                              final newScaledMax = _snapToStepInRange(
                                values.end,
                                scaledRangeMin,
                                scaledRangeMax,
                                step,
                              );
                              final newUsdMin = emitFromScaled(newScaledMin);
                              final newUsdMax = emitFromScaled(newScaledMax);
                              if ((newScaledMin / step).round() !=
                                      (scaledMin / step).round() ||
                                  (newScaledMax / step).round() !=
                                      (scaledMax / step).round()) {
                                HapticFeedbackUtils.impact();
                                SendSoundUtils.playSelectionSound();
                              }
                              setState(() {
                                _minPrice = newUsdMin;
                                _maxPrice = newUsdMax;
                              });
                              widget.onPriceRangeChanged(newUsdMin, newUsdMax);
                            },
                          ),
                        ),
                ),
              ),

              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatLabel(
                          widget.useSinglePrice ? scaledMin : scaledMax,
                        ),
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

        if (widget.useGlassPlate) {
          Widget plate = LiquidGlassPlate(
            borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
            child: content,
          );
          if (widget.showErrorBorder) {
            plate = DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                border: Border.all(color: theme.colorScheme.error, width: 1.5),
              ),
              child: plate,
            );
          }
          return Container(margin: const EdgeInsets.all(5), child: plate);
        }

        return Container(
          margin: const EdgeInsets.all(5),
          child: WheelPickerPlateContainer(
            theme: theme,
            showErrorBorder: widget.showErrorBorder,
            child: content,
          ),
        );
      },
    );
  }
}
