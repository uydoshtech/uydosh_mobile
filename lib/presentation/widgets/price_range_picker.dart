import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_slider.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

class PriceRangePicker extends StatefulWidget {
  const PriceRangePicker({
    required this.onPriceRangeChanged,
    super.key,
    this.minPrice = 0.0,
    this.maxPrice = 1000.0,
    this.initialMinPrice = 0.0,
    this.initialMaxPrice = 500.0,
    this.initialVisibleMaxPrice = 500.0,
    this.maxExpansionStep = 100.0,
    this.maxExpansionCooldown = const Duration(milliseconds: 650),
    this.initialValueExpandsVisibleMax = true,
    this.useSinglePrice = false,
    this.showErrorBorder = false,
    this.useGlassPlate = false,
  });

  final Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final double minPrice;
  final double maxPrice;
  final double initialMinPrice;
  final double initialMaxPrice;

  /// The right edge shown when the picker first opens. Dragging the upper
  /// handle to this edge expands the visible scale by [maxExpansionStep] until
  /// [maxPrice] is reached.
  final double initialVisibleMaxPrice;

  /// Amount by which the visible max grows when the user reaches the right edge.
  /// Set to 0 or less to keep the slider fixed at [initialVisibleMaxPrice].
  final double maxExpansionStep;

  /// Minimum pause between automatic max-scale expansions while dragging.
  final Duration maxExpansionCooldown;

  /// When true, an initial value above [initialVisibleMaxPrice] opens enough
  /// scale to show that value. Useful for edit forms with existing high prices.
  final bool initialValueExpandsVisibleMax;

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
  late double _visibleMaxPrice;
  DateTime? _lastMaxExpansionAt;

  /// USD-scale tick (matches how listings store the small "USD-index" amounts).
  static const double _stepUsd = 10.0;

  /// UZS-display tick. 10.000 keeps the slider feeling native to UZS users
  /// without producing a wall of zeroes — labels render as `K`/`M` further down.
  static const double _stepUzs = 10000.0;

  static double _clampDouble(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }

  double _initialVisibleMaxFor(double selectedUpper) {
    final base = _clampDouble(
      widget.initialVisibleMaxPrice,
      widget.minPrice,
      widget.maxPrice,
    );
    final selected = _clampDouble(
      selectedUpper,
      widget.minPrice,
      widget.maxPrice,
    );
    final step = widget.maxExpansionStep;
    if (!widget.initialValueExpandsVisibleMax) return base;
    if (step <= 0 || selected <= base) return base;

    final stepsNeeded = ((selected - base) / step).ceil();
    return _clampDouble(
        base + (stepsNeeded * step), widget.minPrice, widget.maxPrice);
  }

  void _maybeExpandVisibleMaxFor(double selectedUpper) {
    final step = widget.maxExpansionStep;
    if (step <= 0 || _visibleMaxPrice >= widget.maxPrice) return;
    if (selectedUpper < _visibleMaxPrice) return;

    final now = DateTime.now();
    final last = _lastMaxExpansionAt;
    if (last != null && now.difference(last) < widget.maxExpansionCooldown) {
      return;
    }
    _lastMaxExpansionAt = now;

    _visibleMaxPrice = _clampDouble(
      _visibleMaxPrice + step,
      widget.minPrice,
      widget.maxPrice,
    );
  }

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
      _minPrice =
          widget.initialMinPrice.clamp(widget.minPrice, widget.maxPrice);
      _maxPrice =
          widget.initialMaxPrice.clamp(widget.minPrice, widget.maxPrice);
    }
    _visibleMaxPrice = _initialVisibleMaxFor(_maxPrice);
  }

  @override
  void didUpdateWidget(PriceRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final boundsOrModeChanged = oldWidget.minPrice != widget.minPrice ||
        oldWidget.maxPrice != widget.maxPrice ||
        oldWidget.initialVisibleMaxPrice != widget.initialVisibleMaxPrice ||
        oldWidget.maxExpansionStep != widget.maxExpansionStep ||
        oldWidget.maxExpansionCooldown != widget.maxExpansionCooldown ||
        oldWidget.initialValueExpandsVisibleMax !=
            widget.initialValueExpandsVisibleMax ||
        oldWidget.useSinglePrice != widget.useSinglePrice;
    final initialValuesChanged =
        oldWidget.initialMinPrice != widget.initialMinPrice ||
            oldWidget.initialMaxPrice != widget.initialMaxPrice;

    if (boundsOrModeChanged || initialValuesChanged) {
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
        final nextVisible = _initialVisibleMaxFor(_maxPrice);
        if (boundsOrModeChanged) {
          _visibleMaxPrice = nextVisible;
          _lastMaxExpansionAt = null;
        } else {
          _visibleMaxPrice = _clampDouble(
            _visibleMaxPrice < nextVisible ? nextVisible : _visibleMaxPrice,
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
        final rangeMax = _clampDouble(
          _visibleMaxPrice,
          widget.minPrice,
          widget.maxPrice,
        );
        final scaledRangeMax = rangeMax * scale;
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
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
                  data: UydoshSliderChrome.priceRangeTrack(
                    context,
                    sliderColor: sliderColor,
                    inactiveTrackColor: getInactiveTrackColor(),
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
                              UiFeedbackUtils.tap();
                            }
                            setState(() {
                              _minPrice = newUsd;
                              _maxPrice = newUsd;
                              _maybeExpandVisibleMaxFor(newUsd);
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
                                UiFeedbackUtils.tap();
                              }
                              setState(() {
                                _minPrice = newUsdMin;
                                _maxPrice = newUsdMax;
                                _maybeExpandVisibleMaxFor(newUsdMax);
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
