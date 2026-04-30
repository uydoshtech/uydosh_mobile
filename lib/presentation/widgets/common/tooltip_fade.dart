import "package:flutter/material.dart";

/// Fades [child] in/out based on [visible]. While fading out, the child stays
/// in the tree until the animation finishes; when fully invisible it returns
/// `SizedBox.shrink` so it no longer occupies space.
///
/// By default, while the fade animates, the child also collapses its height
/// proportionally so surrounding layout reflows smoothly. Set [collapse] to
/// `false` for stack-positioned tooltips where layout collapse is unnecessary
/// (e.g. floating hint bubbles anchored to a fixed point).
///
/// This is the canonical "appear/disappear with fade" treatment for in-app
/// tips and hint bubbles. Pair it with the global [TooltipsState] toggle and
/// any per-tip dismissal flag to control [visible].
class TooltipFade extends StatefulWidget {
  const TooltipFade({
    required this.visible,
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 240),
    this.curve = Curves.easeInOut,
    this.collapse = true,
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool collapse;

  @override
  State<TooltipFade> createState() => _TooltipFadeState();
}

class _TooltipFadeState extends State<TooltipFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant TooltipFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        if (t == 0) return const SizedBox.shrink();
        Widget faded = Opacity(opacity: t.clamp(0.0, 1.0), child: child);
        if (widget.collapse) {
          faded = ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t.clamp(0.0, 1.0),
              child: faded,
            ),
          );
        }
        return faded;
      },
      child: widget.child,
    );
  }
}
