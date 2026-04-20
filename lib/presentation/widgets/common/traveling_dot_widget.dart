import "dart:math" as math;

import "package:flutter/material.dart";

/// A one-shot "traveling dot" animation: a tiny dot arcs into [targetKey].
///
/// Intended for subtle attention cues (e.g. new message arrival) without a
/// persistent blink.
class TravelingDotWidget extends StatefulWidget {
  const TravelingDotWidget({
    required this.targetKey,
    required this.trigger,
    super.key,
    this.color = const Color(0xFF2ECC71),
    this.size = 7,
    this.duration = const Duration(milliseconds: 780),
    this.cooldown = const Duration(milliseconds: 900),
    // Defaults to slightly above the host bounds. The host is often positioned
    // with a negative top (see bottom-nav overlay usage) so this reads as
    // "incoming from above" even on short nav bars.
    this.startAlignment = const Alignment(0.0, -1.15),
  });

  /// GlobalKey attached to the destination widget (e.g. the badge/dot).
  final GlobalKey targetKey;

  /// Change this value (e.g. increment) to replay the animation.
  final int trigger;

  final Color color;
  final double size;
  final Duration duration;

  /// Minimum delay between replays (local cooldown).
  final Duration cooldown;

  /// Where the dot "spawns" within this widget's bounds.
  final Alignment startAlignment;

  @override
  State<TravelingDotWidget> createState() => _TravelingDotWidgetState();
}

class _TravelingDotWidgetState extends State<TravelingDotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  int _lastTrigger = 0;
  DateTime? _lastPlayedAt;
  Offset? _start;
  Offset? _end;
  double _lift = 0;

  @override
  void initState() {
    super.initState();
    _lastTrigger = widget.trigger;
    // Don't autoplay on mount; only when trigger changes.
  }

  @override
  void didUpdateWidget(covariant TravelingDotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger == _lastTrigger) return;
    _lastTrigger = widget.trigger;
    _maybePlay();
  }

  void _maybePlay() {
    final now = DateTime.now();
    final last = _lastPlayedAt;
    if (last != null && now.difference(last) < widget.cooldown) return;
    _lastPlayedAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final targetContext = widget.targetKey.currentContext;
      if (targetContext == null) return;

      final targetBox = targetContext.findRenderObject() as RenderBox?;
      final overlayBox = context.findRenderObject() as RenderBox?;
      if (targetBox == null || overlayBox == null) return;
      if (!targetBox.hasSize || !overlayBox.hasSize) return;

      final targetCenterGlobal =
          targetBox.localToGlobal(targetBox.size.center(Offset.zero));
      final overlayTopLeftGlobal = overlayBox.localToGlobal(Offset.zero);
      final end = targetCenterGlobal - overlayTopLeftGlobal;

      final start = widget.startAlignment.alongSize(overlayBox.size);
      final dx = (end.dx - start.dx).abs();
      // Lift the arc upward; scale by distance but cap so it's subtle.
      final lift = math.min(54.0, 18.0 + dx * 0.18);

      setState(() {
        _start = start;
        _end = end;
        _lift = lift;
      });

      _controller
        ..stop()
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we haven't measured start/end yet, keep the layer inert.
    final start = _start;
    final end = _end;
    if (start == null || end == null) {
      return const SizedBox.expand();
    }

    final travel = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    final fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
    );
    final fadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
    );
    final landPop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeOutBack),
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = travel.value;
          final p = _quadraticBezier(
            start,
            _controlPoint(start, end, _lift),
            end,
            t,
          );

          final opacity = (fadeIn.value * (1.0 - fadeOut.value)).clamp(0.0, 1.0);
          final scale = 1.0 + 0.25 * landPop.value;

          return Stack(
            children: [
              Positioned(
                left: p.dx - widget.size / 2,
                top: p.dy - widget.size / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: _Dot(
                      color: widget.color,
                      size: widget.size,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Offset _controlPoint(Offset start, Offset end, double lift) {
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    return mid.translate(0, -lift);
  }

  static Offset _quadraticBezier(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1.0 - t;
    final tt = t * t;
    final uu = u * u;
    return Offset(
      (uu * p0.dx) + (2 * u * t * p1.dx) + (tt * p2.dx),
      (uu * p0.dy) + (2 * u * t * p1.dy) + (tt * p2.dy),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}

