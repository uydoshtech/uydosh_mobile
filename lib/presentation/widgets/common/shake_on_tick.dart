import "dart:math" as math;

import "package:flutter/material.dart";

/// Plays a short shake animation whenever [tick] changes.
///
/// Designed for app-bar icons: low amplitude, fast settle.
class ShakeOnTick extends StatefulWidget {
  const ShakeOnTick({
    required this.tick,
    required this.child,
    super.key,
    this.enabled = true,
  });

  final int tick;
  final bool enabled;
  final Widget child;

  @override
  State<ShakeOnTick> createState() => _ShakeOnTickState();
}

class _ShakeOnTickState extends State<ShakeOnTick>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _turns;
  int? _scheduledTick;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _turns = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.10).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.10, end: -0.09).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.09, end: 0.055).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.055, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant ShakeOnTick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) return;
    if (widget.tick != oldWidget.tick && widget.tick > 0) {
      // Let parent rebuild settle first (e.g. icon swap from outline -> active),
      // then animate to avoid a "jerk" where the child changes mid-shake.
      _scheduledTick = widget.tick;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!widget.enabled) return;
        if (_scheduledTick != widget.tick) return;
        _controller.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _turns.value * 2 * math.pi,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

