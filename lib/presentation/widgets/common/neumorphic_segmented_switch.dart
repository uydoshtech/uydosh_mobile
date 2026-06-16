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
    this.forceGlassPlate = false,
    super.key,
  });

  final T value;
  final List<SegmentedSwitchEntry<T>> entries;
  final ValueChanged<T> onChanged;
  final double height;

  /// When true, uses [LiquidGlassPlate] on the blue theme and a translucent
  /// primary thumb. On the light theme, keeps the same neumorphic track/thumb
  /// as the non-glass path so the control stays pale on white backgrounds.
  final bool liquidGlass;

  /// Forces the [LiquidGlassPlate] branch even on light surfaces. Keep this
  /// opt-in for controls that intentionally sit on a glass sheet.
  final bool forceGlassPlate;

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
        final isLightTheme = themeState.isLightTheme;
        // Default light-theme controls stay pale unless a caller explicitly
        // asks for the frosted glass plate.
        final useGlassPlate = liquidGlass && (forceGlassPlate || !isLightTheme);
        final selectedTextColor = themeState.selectedTabTextColor;
        final unselectedTextColor = themeState.unselectedTabTextColor;

        final selectedIndex = entries.indexWhere((e) => e.value == value);
        // Anchor the thumb to index 0 if no match (defensive — keeps the
        // switch from "disappearing" the thumb on a stale value).
        final activeIndex = selectedIndex < 0 ? 0 : selectedIndex;

        return LayoutBuilder(
          builder: (context, constraints) {
            final totalInner = (constraints.maxWidth - _thumbInset * 2)
                .clamp(0.0, double.infinity);
            final segmentWidths = _segmentWidths(
              context,
              totalInner,
            );

            final theme = Theme.of(context);

            final BoxDecoration thumbDecoration = useGlassPlate
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(_innerRadius()),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.38),
                        primaryColor.withValues(alpha: 0.58),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 12,
                        spreadRadius: 0.4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(_innerRadius()),
                    gradient: ThreeDSurfaceStyle.surfaceGradient(
                      context,
                      primaryColor,
                    ),
                    boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                  );

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
                  child: DecoratedBox(
                    decoration: thumbDecoration,
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

            if (useGlassPlate) {
              return LiquidGlassPlate(
                height: height,
                borderRadius: BorderRadius.circular(_outerRadius()),
                padding: EdgeInsets.zero,
                child: stack,
              );
            }

            final trackColor =
                isLightTheme ? theme.colorScheme.surface : cardColor;

            return Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_outerRadius()),
                gradient: ThreeDSurfaceStyle.surfaceGradient(
                  context,
                  trackColor,
                ),
                boxShadow: isLightTheme
                    ? ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context)
                    : ThreeDSurfaceStyle.elevatedShadows(context),
              ),
              child: stack,
            );
          },
        );
      },
    );
  }
}

class _SegmentedSwitchTab<T> extends StatelessWidget {
  const _SegmentedSwitchTab({
    required this.entry,
    required this.isSelected,
    required this.height,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onTap,
  });

  final SegmentedSwitchEntry<T> entry;
  final bool isSelected;
  final double height;
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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
                  color: color.withValues(alpha: isSelected ? 0.88 : 0.72),
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
          opacity: isSelected ? 1.0 : 0.82,
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
