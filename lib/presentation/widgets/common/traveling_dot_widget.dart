import "dart:math" as math;

import "package:flutter/material.dart";

/// A one-shot "traveling dot" animation: a tiny dot arcs into [targetContext].
///
/// Intended for subtle attention cues (e.g. new message arrival) without a
/// persistent blink.
class TravelingDotWidget extends StatefulWidget {
  const TravelingDotWidget({
    required this.targetContext,
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

  /// BuildContext of the destination widget (e.g. the badge/dot).
  ///
  /// We intentionally avoid a GlobalKey here because some navigation widgets
  /// (e.g. CurvedNavigationBar) may temporarily duplicate item subtrees during
  /// transitions, which can cause "Duplicate GlobalKey" crashes.
  final BuildContext? targetContext;

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
  late final AnimationController _controller;

  late final CurvedAnimation _travel;
  late final CurvedAnimation _fadeIn;
  late final CurvedAnimation _fadeOut;
  late final CurvedAnimation _landPop;

  int _lastTrigger = 0;
  DateTime? _lastPlayedAt;
  Offset? _start;
  Offset? _end;
  double _lift = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _travel = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
    );
    _fadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
    );
    _landPop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeOutBack),
    );
    _lastTrigger = widget.trigger;
    // Don't autoplay on mount; only when trigger changes.
  }

  @override
  void didUpdateWidget(covariant TravelingDotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
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
      final overlayBox = context.findRenderObject() as RenderBox?;
      if (overlayBox == null || !overlayBox.hasSize) return;

      final end = _computeEnd(overlayBox);
      if (end == null) return;

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

  Offset? _computeEnd(RenderBox overlayBox) {
    final targetContext = widget.targetContext;
    if (targetContext == null) return null;
    final targetElement = targetContext is Element ? targetContext : null;
    if (targetElement != null && !targetElement.mounted) return null;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    if (targetBox == null || !targetBox.hasSize) return null;

    final targetCenterGlobal =
        targetBox.localToGlobal(targetBox.size.center(Offset.zero));
    final overlayTopLeftGlobal = overlayBox.localToGlobal(Offset.zero);
    return targetCenterGlobal - overlayTopLeftGlobal;
  }

  @override
  void dispose() {
    _travel.dispose();
    _fadeIn.dispose();
    _fadeOut.dispose();
    _landPop.dispose();
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

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final overlayBox = context.findRenderObject() as RenderBox?;
          final endNow =
              (overlayBox == null || !overlayBox.hasSize)
                  ? null
                  : _computeEnd(overlayBox);
          final endStable = endNow ?? end;

          final t = _travel.value;
          final p = _quadraticBezier(
            start,
            _controlPoint(start, endStable, _lift),
            endStable,
            t,
          );

          final opacity = (_fadeIn.value * (1.0 - _fadeOut.value)).clamp(0.0, 1.0);
          final scale = 1.0 + 0.25 * _landPop.value;

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

