import "dart:math" as math;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_slider.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Cycles `null` (default order) -> `'asc'` (cheapest first) -> `'desc'`
/// (priciest first) -> back to `null` — mirrors the mini app's price-sort
/// chip (`PRICE_SORT_ORDER_VALUES` in `telegram-feed.js`).
String? nextPriceSortOrder(String? current) {
  switch (current) {
    case null:
      return "asc";
    case "asc":
      return "desc";
    default:
      return null;
  }
}

/// "Sort by price" toggle button placed between the Мин/Макс columns —
/// same $-plus-up/down-arrow glyph as the mini app's price-sort chip (see
/// `filterPriceSortIcon` in `uydosh-icons.js`), reimplemented with Material
/// icons since Flutter widgets can't reuse the web app's inline SVG paths.
class _PriceSortToggleButton extends StatelessWidget {
  const _PriceSortToggleButton({
    required this.order,
    required this.color,
    required this.accentColor,
    required this.onTap,
  });

  final String? order;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;

  bool get _isActive => order == "asc" || order == "desc";

  IconData get _icon {
    if (order == "asc") return Icons.arrow_upward;
    if (order == "desc") return Icons.arrow_downward;
    return Icons.unfold_more;
  }

  String get _semanticsLabel {
    if (order == "asc") return L10n.get("price_sort_toggle_aria_asc");
    if (order == "desc") return L10n.get("price_sort_toggle_aria_desc");
    return L10n.get("price_sort_toggle_aria_none");
  }

  @override
  Widget build(BuildContext context) {
    final fg = _isActive ? accentColor : color.withValues(alpha: 0.75);
    return Semantics(
      button: true,
      label: _semanticsLabel,
      child: Tooltip(
        message: _semanticsLabel,
        child: Material(
          color: _isActive
              ? accentColor.withValues(alpha: 0.14)
              : color.withValues(alpha: 0.08),
          shape: StadiumBorder(
            side: BorderSide(
              color: _isActive
                  ? accentColor.withValues(alpha: 0.55)
                  : color.withValues(alpha: 0.18),
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\$",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: fg,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(_icon, size: 14, color: fg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    this.title,
    this.priceSortOrder,
    this.onPriceSortOrderChanged,
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
  final String? title;

  /// `null` (default order), `'asc'` (cheapest first), or `'desc'`
  /// (priciest first). The sort toggle button (mirrors the mini app's
  /// price-sort chip — see `filterPriceSortIcon` in `uydosh-icons.js`) is
  /// only rendered in range mode when [onPriceSortOrderChanged] is set.
  final String? priceSortOrder;
  final ValueChanged<String?>? onPriceSortOrderChanged;

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

  /// Smallest allowed gap between the Мин/Макс handles (USD-index scale) in
  /// range mode — keeps the two independent sliders from landing on the same
  /// value (a degenerate "$180 – $180" range) when one is dragged past the
  /// other.
  static const double _minGapUsd = 5.0;

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

        // Keep stored values exact on first paint; only snap while dragging so
        // edit screens match the listing card (e.g. 85–165, not 90–170).
        var scaledMin =
            (_minPrice * scale).clamp(scaledRangeMin, scaledRangeMax);
        var scaledMax =
            (_maxPrice * scale).clamp(scaledRangeMin, scaledRangeMax);
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

        // Single-thumb slider row: icon+value on each side, matching the
        // pre-existing design (unchanged).
        Widget buildSingleSliderRow() {
          return Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: UydoshSliderChrome.priceRangeTrack(
                    context,
                    sliderColor: sliderColor,
                    inactiveTrackColor: getInactiveTrackColor(),
                  ),
                  child: Slider(
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
                        formatLabel(scaledMin),
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
          );
        }

        // Range mode: two independent single-thumb sliders side by side
        // (Мин/Макс), each filling from the track start to its own value —
        // mirrors the mini app's `.price-row` layout (see
        // `assets/telegram-create.js`/`.css` in uydoshtech.github.io) rather
        // than a single connected two-thumb track.
        Widget buildMinMaxSliderColumn({
          required String label,
          required double value,
          required ValueChanged<double> onChanged,
          bool alignEnd = false,
        }) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: alignEnd ? 0 : 4,
                  end: alignEnd ? 4 : 0,
                  bottom: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    _unitIcon(textColor.withValues(alpha: 0.75)),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: UydoshSliderChrome.priceRangeTrack(
                  context,
                  sliderColor: sliderColor,
                  inactiveTrackColor: getInactiveTrackColor(),
                ),
                child: Slider(
                  value: value,
                  min: scaledRangeMin,
                  max: scaledRangeMax,
                  divisions: divisions > 0 ? divisions : null,
                  activeColor: sliderColor,
                  inactiveColor: getInactiveTrackColor(),
                  label: formatLabel(value),
                  onChanged: onChanged,
                ),
              ),
            ],
          );
        }

        // Minimum Мин/Макс gap, converted into whichever scale the sliders
        // are currently operating in (see `scale` above).
        final minGapScaled = _minGapUsd * scale;

        void handleMinChanged(double value) {
          final rawMin = _snapToStepInRange(
            value,
            scaledRangeMin,
            scaledRangeMax,
            step,
          );
          // Leave enough room below the top of the track for Макс to still
          // sit at least `minGapScaled` above, instead of letting Мин crowd
          // all the way up to (or past) it.
          final newScaledMin = math.min(
            rawMin,
            math.max(scaledRangeMin, scaledRangeMax - minGapScaled),
          );
          // Crossing (or approaching) the other handle pushes it along by at
          // least the minimum gap, same idea as the mini app's
          // `data-price-min`/`data-price-max` input listeners.
          final newScaledMax = math.min(
            scaledRangeMax,
            math.max(scaledMax, newScaledMin + minGapScaled),
          );
          final newUsdMin = emitFromScaled(newScaledMin);
          final newUsdMax = emitFromScaled(newScaledMax);
          if ((newScaledMin / step).round() != (scaledMin / step).round()) {
            UiFeedbackUtils.tap();
          }
          setState(() {
            _minPrice = newUsdMin;
            _maxPrice = newUsdMax;
            _maybeExpandVisibleMaxFor(newUsdMax);
          });
          widget.onPriceRangeChanged(newUsdMin, newUsdMax);
        }

        void handleMaxChanged(double value) {
          final rawMax = _snapToStepInRange(
            value,
            scaledRangeMin,
            scaledRangeMax,
            step,
          );
          final newScaledMax = math.max(
            rawMax,
            math.min(scaledRangeMax, scaledRangeMin + minGapScaled),
          );
          final newScaledMin = math.max(
            scaledRangeMin,
            math.min(scaledMin, newScaledMax - minGapScaled),
          );
          final newUsdMin = emitFromScaled(newScaledMin);
          final newUsdMax = emitFromScaled(newScaledMax);
          if ((newScaledMax / step).round() != (scaledMax / step).round()) {
            UiFeedbackUtils.tap();
          }
          setState(() {
            _minPrice = newUsdMin;
            _maxPrice = newUsdMax;
            _maybeExpandVisibleMaxFor(newUsdMax);
          });
          widget.onPriceRangeChanged(newUsdMin, newUsdMax);
        }

        Widget buildMinMaxSlidersRow() {
          final onSortOrderChanged = widget.onPriceSortOrderChanged;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildMinMaxSliderColumn(
                  label: L10n.get("price_picker_min_label"),
                  value: scaledMin,
                  onChanged: handleMinChanged,
                ),
              ),
              if (onSortOrderChanged != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _PriceSortToggleButton(
                    order: widget.priceSortOrder,
                    color: textColor,
                    accentColor: sliderColor,
                    onTap: () {
                      UiFeedbackUtils.tap();
                      onSortOrderChanged(
                        nextPriceSortOrder(widget.priceSortOrder),
                      );
                    },
                  ),
                )
              else
                const SizedBox(width: 12),
              Expanded(
                child: buildMinMaxSliderColumn(
                  label: L10n.get("price_picker_max_label"),
                  value: scaledMax,
                  onChanged: handleMaxChanged,
                  alignEnd: true,
                ),
              ),
            ],
          );
        }

        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.useSinglePrice) ...[
                const SizedBox(height: 6),
                Text(
                  "${formatLabel(scaledMin)} – ${formatLabel(scaledMax)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: themeState.priceBadgeActiveColor,
                  ),
                ),
                const SizedBox(height: 10),
                buildMinMaxSlidersRow(),
              ] else
                buildSingleSliderRow(),
            ],
          ),
        );

        Widget withOptionalTitle(Widget child) {
          final title = widget.title?.trim();
          if (title == null || title.isEmpty) return child;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 8,
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ) ??
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              child,
            ],
          );
        }

        if (widget.useGlassPlate && ThemeState().usesLiquidGlassChrome) {
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
          return Container(
            margin: const EdgeInsets.all(5),
            child: withOptionalTitle(plate),
          );
        }

        return Container(
          margin: const EdgeInsets.all(5),
          child: withOptionalTitle(
            WheelPickerPlateContainer(
              theme: theme,
              showErrorBorder: widget.showErrorBorder,
              child: content,
            ),
          ),
        );
      },
    );
  }
}
