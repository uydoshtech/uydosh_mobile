import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Fires light selection-style haptics in steps while the user pulls down at the
/// top of a vertical scroll view (Threads-style). Works with both clamping
/// physics (overscroll notifications) and bouncing physics (negative pixels).
///
/// Place [child] as the scrollable wrapped by [RefreshIndicator].
class PullToRefreshStretchHaptics extends StatefulWidget {
  const PullToRefreshStretchHaptics({
    required this.child,
    super.key,
    this.pixelsPerTick = 12.0,
  });

  final Widget child;

  /// Approximate pull distance between haptic ticks, in logical pixels.
  final double pixelsPerTick;

  @override
  State<PullToRefreshStretchHaptics> createState() =>
      _PullToRefreshStretchHapticsState();
}

class _PullToRefreshStretchHapticsState
    extends State<PullToRefreshStretchHaptics> {
  double _overscrollCarry = 0;
  int _lastStretchStep = 0;

  void _reset() {
    _overscrollCarry = 0;
    _lastStretchStep = 0;
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _reset();
      return false;
    }
    if (notification is ScrollEndNotification) {
      _reset();
      return false;
    }

    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    // Bouncing scroll (typical iOS): stretch is reflected as pixels < min.
    if (notification is ScrollUpdateNotification) {
      final m = notification.metrics;
      if (m.pixels >= m.minScrollExtent - 0.01) {
        _lastStretchStep = 0;
        return false;
      }
      final stretch = m.minScrollExtent - m.pixels;
      final step = widget.pixelsPerTick;
      final currentStep = (stretch / step).floor();
      if (currentStep > _lastStretchStep) {
        for (var i = _lastStretchStep; i < currentStep; i++) {
          HapticFeedbackUtils.selectionClick();
        }
        _lastStretchStep = currentStep;
      } else if (currentStep < _lastStretchStep) {
        _lastStretchStep = currentStep;
      }
      return false;
    }

    // Clamping physics (typical Android): top pull yields negative overscroll.
    if (notification is OverscrollNotification) {
      final m = notification.metrics;
      if (m.extentBefore > 1.0) {
        return false;
      }
      if (notification.overscroll >= -0.01) {
        return false;
      }
      _overscrollCarry += -notification.overscroll;
      final step = widget.pixelsPerTick;
      while (_overscrollCarry >= step) {
        _overscrollCarry -= step;
        HapticFeedbackUtils.selectionClick();
      }
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: widget.child,
    );
  }
}
