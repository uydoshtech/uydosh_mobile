import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";

/// Subtle pulse + circular halo wrapper.
///
/// Used to draw attention to floating circular buttons (e.g. search lens).
class PulsingBorderWrapper extends StatefulWidget {
  const PulsingBorderWrapper({
    required this.child,
    super.key,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 900),
    this.scaleTo = 1.08,
    this.haloColor,
    this.haloBlurRadius = 18,
    this.haloSpreadRadius = 0.5,
    this.padding = const EdgeInsets.all(2),
  });

  final Widget child;
  final bool enabled;
  final Duration duration;
  final double scaleTo;
  final Color? haloColor;
  final double haloBlurRadius;
  final double haloSpreadRadius;
  final EdgeInsets padding;

  @override
  State<PulsingBorderWrapper> createState() => _PulsingBorderWrapperState();
}

class _PulsingBorderWrapperState extends State<PulsingBorderWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _motionEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: widget.scaleTo).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant PulsingBorderWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _sync();
    }
  }

  void _sync() {
    _motionEnabled = widget.enabled &&
        UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    if (!_motionEnabled) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final haloColor = widget.haloColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: haloColor,
            blurRadius: widget.haloBlurRadius,
            spreadRadius: widget.haloSpreadRadius,
          ),
        ],
      ),
      child: Padding(
        padding: widget.padding,
        child: ScaleTransition(
          scale: _motionEnabled ? _scale : const AlwaysStoppedAnimation(1.0),
          child: widget.child,
        ),
      ),
    );
  }
}
