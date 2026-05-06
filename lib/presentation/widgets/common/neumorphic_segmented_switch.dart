import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// One option inside a [NeumorphicSegmentedSwitch].
class SegmentedSwitchEntry<T> {
  const SegmentedSwitchEntry({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
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
    super.key,
  });

  final T value;
  final List<SegmentedSwitchEntry<T>> entries;
  final ValueChanged<T> onChanged;
  final double height;

  /// When true, the first segment is only as wide as its icon + label (with a
  /// sensible minimum tap target); remaining segments split the rest equally.
  /// When false, every segment gets the same width (original behavior).
  final bool intrinsicWidthFirstSegment;

  static const double _thumbInset = 2;
  static const double _tabHorizontalPadding = 6;
  static const double _iconSize = 18;
  static const double _iconTextGap = 6;

  double _outerRadius() => height / 2;
  double _innerRadius() => height / 2 - _thumbInset;

  double _measureFirstSegmentWidth(BuildContext context) {
    final entry = entries.first;
    const style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );
    final painter = TextPainter(
      text: TextSpan(text: entry.label, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    var w = _tabHorizontalPadding * 2;
    if (entry.icon != null) {
      w += _iconSize + _iconTextGap;
    }
    w += painter.width;
    return w;
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
    final minForOthers = (entries.length - 1) * kMinInteractiveDimension;
    final maxFirst = (totalInner - minForOthers).clamp(0.0, totalInner);
    final w0 = measured.clamp(kMinInteractiveDimension, maxFirst);
    final rem = (totalInner - w0).clamp(0.0, double.infinity);
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
        final unselectedTextColor = themeState.unselectedTabTextColor;

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
              child: Stack(
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_innerRadius()),
                        gradient: ThreeDSurfaceStyle.surfaceGradient(
                          context,
                          primaryColor,
                        ),
                        boxShadow:
                            ThreeDSurfaceStyle.elevatedShadows(context),
                      ),
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
                                      HapticFeedbackUtils.selection();
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
                                      HapticFeedbackUtils.selection();
                                      onChanged(entries[i].value);
                                    },
                                  ),
                                ),
                      ],
                    ),
                  ),
                ],
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
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
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
