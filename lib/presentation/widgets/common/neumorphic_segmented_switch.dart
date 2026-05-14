import "dart:math" as math;

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// One option inside a [NeumorphicSegmentedSwitch].
class SegmentedSwitchEntry<T> {
  const SegmentedSwitchEntry({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// Optional second line shown under [label], e.g. on the Publish Task/Service
  /// segmented control.
  final String? subtitle;
}

/// Reusable N-segment switcher: a 3D pill container with an animated sliding
/// thumb that rides under the active segment. Originally introduced in
/// `publish_gig_screen.dart` for the Task/Service / budget-type / pricing-type
/// togglers; lifted here so other surfaces (e.g. the Services hub) can share
/// the same affordance.
class NeumorphicSegmentedSwitch<T> extends StatelessWidget {
  const NeumorphicSegmentedSwitch({
    required this.value,
    required this.entries,
    required this.onChanged,
    this.height = 48,
    this.intrinsicWidthFirstSegment = false,
    this.firstSegmentWidthScale = 1,
    this.firstSegmentMinFractionOfBar,
    this.liquidGlass = false,
    super.key,
  });

  final T value;
  final List<SegmentedSwitchEntry<T>> entries;
  final ValueChanged<T> onChanged;
  final double height;

  /// When true, uses [LiquidGlassPlate] for the outer pill and a translucent
  /// primary thumb — matches liquid-glass theme controls (e.g. hub FAB chips).
  final bool liquidGlass;

  /// When true, the first segment is only as wide as its icon + label (with a
  /// sensible minimum tap target); remaining segments split the rest equally.
  /// When false, every segment gets the same width (original behavior).
  final bool intrinsicWidthFirstSegment;

  /// Horizontal-only: multiplies the first segment’s **width** (thumb + column).
  /// Does not change [height]. Only used when [intrinsicWidthFirstSegment] is true.
  final double firstSegmentWidthScale;

  /// When set (with [intrinsicWidthFirstSegment]), the first segment uses at least
  /// this fraction of the inner bar width so short labels are not dwarfed by
  /// longer siblings (intrinsic width alone is often too small).
  final double? firstSegmentMinFractionOfBar;

  static const double _thumbInset = 2;
  static const double _tabHorizontalPadding = 6;
  /// Mirrors horizontal padding inside [_SegmentedSwitchTab] (label row).
  static const double _tabInnerHorizontalPadding = 6;
  static const double _iconSize = 18;
  static const double _iconTextGap = 6;

  double _outerRadius() => height / 2;
  double _innerRadius() => height / 2 - _thumbInset;

  double _measureFirstSegmentWidth(BuildContext context) {
    final entry = entries.first;
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.labelLarge ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);
    final style = baseStyle.merge(
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
    final scaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: entry.label, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    var w = _tabHorizontalPadding * 2;
    if (entry.icon != null) {
      w += _iconSize + _iconTextGap;
    }
    w += painter.width;
    w += _tabInnerHorizontalPadding * 2;
    // Small slack so layout / icon glyph boxes don’t clip the label.
    return w + 2;
  }

  List<double> _segmentWidths(BuildContext context, double totalInner) {
    if (entries.isEmpty) {
      return [];
    }
    if (!intrinsicWidthFirstSegment || entries.length == 1) {
      final w = totalInner / entries.length;
      return List.filled(entries.length, w);
    }
    final measured = _measureFirstSegmentWidth(context);
    final base = measured < kMinInteractiveDimension
        ? kMinInteractiveDimension.toDouble()
        : measured;
    var w0 = base * firstSegmentWidthScale;
    if (firstSegmentMinFractionOfBar != null) {
      w0 = math.max(w0, totalInner * firstSegmentMinFractionOfBar!);
    }
    final minForRest =
        (entries.length - 1) * kMinInteractiveDimension.toDouble();
    final maxW0 = totalInner - minForRest;
    if (maxW0 < kMinInteractiveDimension || totalInner <= minForRest) {
      final w = totalInner / entries.length;
      return List.filled(entries.length, w);
    }
    w0 = w0.clamp(kMinInteractiveDimension.toDouble(), maxW0);
    final rem = totalInner - w0;
    final wRest = rem / (entries.length - 1);
    return [w0, ...List.filled(entries.length - 1, wRest)];
  }

  @override
  Widget build(BuildContext context) {
    assert(entries.isNotEmpty, "Switch needs at least one entry");
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final primaryColor = themeState.primaryColor;
        final cardColor = themeState.cardColor;
        final selectedTextColor =
            ThemeData.estimateBrightnessForColor(primaryColor) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final unselectedTextColor = liquidGlass && isDark
            ? Colors.white.withValues(alpha: 0.78)
            : themeState.unselectedTabTextColor;

        final selectedIndex = entries.indexWhere((e) => e.value == value);
        // Anchor the thumb to index 0 if no match (defensive — keeps the
        // switch from "disappearing" the thumb on a stale value).
        final activeIndex = selectedIndex < 0 ? 0 : selectedIndex;

        return LayoutBuilder(
          builder: (context, constraints) {
            final totalInner =
                (constraints.maxWidth - _thumbInset * 2).clamp(0.0, double.infinity);
            final segmentWidths = _segmentWidths(
              context,
              totalInner,
            );

            final thumbDecoration = liquidGlass
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(_innerRadius()),
                    gradient: ThreeDSurfaceStyle.surfaceGradient(
                      context,
                      primaryColor,
                    ),
                    boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                  );

            final innerR = BorderRadius.circular(_innerRadius());
            final stack = Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _thumbInset +
                      segmentWidths
                          .take(activeIndex)
                          .fold<double>(0, (a, w) => a + w),
                  top: _thumbInset,
                  bottom: _thumbInset,
                  width: segmentWidths[activeIndex],
                  child: liquidGlass
                      ? _LiquidGlassThumb(
                          borderRadius: innerR,
                          primaryColor: primaryColor,
                          isDark: isDark,
                        )
                      : DecoratedBox(
                          decoration: thumbDecoration!,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _thumbInset,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < entries.length; i++)
                        intrinsicWidthFirstSegment &&
                                i == 0 &&
                                entries.length > 1
                            ? SizedBox(
                                width: segmentWidths[i],
                                child: _SegmentedSwitchTab<T>(
                                  entry: entries[i],
                                  isSelected: i == activeIndex,
                                  height: height,
                                  liquidGlass: liquidGlass,
                                  selectedTextColor: selectedTextColor,
                                  unselectedTextColor: unselectedTextColor,
                                  onTap: () {
                                    if (i == activeIndex) return;
                                    UiFeedbackUtils.selection();
                                    onChanged(entries[i].value);
                                  },
                                ),
                              )
                            : Expanded(
                                child: _SegmentedSwitchTab<T>(
                                  entry: entries[i],
                                  isSelected: i == activeIndex,
                                  height: height,
                                  liquidGlass: liquidGlass,
                                  selectedTextColor: selectedTextColor,
                                  unselectedTextColor: unselectedTextColor,
                                  onTap: () {
                                    if (i == activeIndex) return;
                                    UiFeedbackUtils.selection();
                                    onChanged(entries[i].value);
                                  },
                                ),
                              ),
                    ],
                  ),
                ),
              ],
            );

            if (liquidGlass) {
              return LiquidGlassPlate(
                height: height,
                borderRadius: BorderRadius.circular(_outerRadius()),
                padding: EdgeInsets.zero,
                variant: LiquidGlassPlateVariant.segmentedTrack,
                child: stack,
              );
            }

            return Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_outerRadius()),
                gradient: ThreeDSurfaceStyle.surfaceGradient(
                  context,
                  cardColor,
                ),
                boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
              ),
              child: stack,
            );
          },
        );
      },
    );
  }
}

/// Sliding thumb for [NeumorphicSegmentedSwitch] when [liquidGlass] is true:
/// vertical blue gradient, specular top edge, and layered shadow.
class _LiquidGlassThumb extends StatelessWidget {
  const _LiquidGlassThumb({
    required this.borderRadius,
    required this.primaryColor,
    required this.isDark,
  });

  final BorderRadius borderRadius;
  final Color primaryColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(primaryColor, Colors.white, isDark ? 0.15 : 0.22)!;
    final mid = primaryColor;
    final bottom = Color.lerp(primaryColor, Colors.black, isDark ? 0.36 : 0.20)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.44 : 0.12),
            blurRadius: isDark ? 14 : 11,
            spreadRadius: isDark ? 0.12 : 0.04,
            offset: Offset(0, isDark ? 5.5 : 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.07),
            blurRadius: isDark ? 6 : 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top, mid, bottom],
                  stops: const [0.0, 0.42, 1.0],
                ),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: isDark ? 0.26 : 0.11,
                  ),
                  width: 0.65,
                ),
              ),
            ),
            Positioned(
              left: 4,
              right: 4,
              top: 0,
              height: 1.25,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.40 : 0.52),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedSwitchTab<T> extends StatelessWidget {
  const _SegmentedSwitchTab({
    required this.entry,
    required this.isSelected,
    required this.height,
    required this.liquidGlass,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onTap,
  });

  final SegmentedSwitchEntry<T> entry;
  final bool isSelected;
  final double height;
  final bool liquidGlass;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedTextColor : unselectedTextColor;
    final subtitle = entry.subtitle;
    final hasSubtitle = subtitle != null && subtitle.isNotEmpty;

    final labelRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entry.icon != null) ...[
          Icon(entry.icon, size: 18, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  (isSelected || liquidGlass) ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );

    final content = hasSubtitle
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: double.infinity, child: labelRow),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  color:
                      color.withValues(alpha: isSelected ? 0.88 : 0.72),
                ),
              ),
            ],
          )
        : labelRow;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          opacity: isSelected ? 1.0 : (liquidGlass ? 0.9 : 0.82),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            scale: isSelected ? 1.0 : 0.96,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: hasSubtitle ? 6 : 0,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
