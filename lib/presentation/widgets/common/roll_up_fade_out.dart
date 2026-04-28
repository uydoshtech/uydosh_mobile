import "package:flutter/material.dart";

/// Collapses a widget upward (heightFactor 1→0) while fading it out (opacity 1→0).
///
/// Intentionally uses [ClipRect] only during the animation to avoid clipping
/// shadows in the steady state (callers usually only wrap while dismissing).
class RollUpFadeOut extends StatelessWidget {
  const RollUpFadeOut({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, t, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

