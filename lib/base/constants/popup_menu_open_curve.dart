import "package:flutter/animation.dart";

/// [Curves.bounceOut] for most of the timeline, then a short linear ramp to 1.0.
///
/// Full [Curves.bounceOut] ends with small oscillations in velocity; combined with
/// Flutter's staggered item fades and [Align] height factor, the last [PopupMenuItem]
/// can flicker at the bottom edge. Smoothing only the final ~6% removes that without
/// losing the visible bounce earlier in the motion.
class PopupMenuOpenCurve extends Curve {
  const PopupMenuOpenCurve();

  static const double _linearTailStart = 0.94;

  @override
  double transformInternal(double t) {
    if (t <= 0) {
      return 0;
    }
    if (t >= 1) {
      return 1;
    }
    if (t <= _linearTailStart) {
      return Curves.bounceOut.transform(t);
    }
    final y0 = Curves.bounceOut.transform(_linearTailStart);
    final u = (t - _linearTailStart) / (1.0 - _linearTailStart);
    return y0 + (1.0 - y0) * u;
  }
}
