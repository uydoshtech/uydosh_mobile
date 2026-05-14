import "dart:ui" show lerpDouble;

import "package:flutter/material.dart";

/// Soft green halo around the chat composer field while editing an existing
/// message — breathing glow, not a hard blink.
class ComposerEditGlow extends StatefulWidget {
  const ComposerEditGlow({
    required this.child,
    required this.enabled,
    required this.borderRadius,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final BorderRadius borderRadius;

  static const Color _green = Color(0xFF22C55E);

  @override
  State<ComposerEditGlow> createState() => _ComposerEditGlowState();
}

class _ComposerEditGlowState extends State<ComposerEditGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _ease;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _ease = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _driveController();
  }

  @override
  void didUpdateWidget(covariant ComposerEditGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _driveController();
    }
  }

  void _driveController() {
    if (!widget.enabled) {
      _controller.stop();
      _controller.reset();
      return;
    }
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0.5;
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
    if (!widget.enabled) {
      return widget.child;
    }

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnimatedBuilder(
      animation: _ease,
      builder: (context, child) {
        final t = reduceMotion ? 0.5 : _ease.value;
        final haloA = lerpDouble(0.14, 0.42, t)!;
        final rimA = lerpDouble(0.42, 0.78, t)!;
        final blurOuter = lerpDouble(14, 30, t)!;
        final blurMid = lerpDouble(10, 22, t)!;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: Border.all(
                      color: ComposerEditGlow._green
                          .withValues(alpha: rimA.clamp(0.0, 1.0)),
                      width: 1.25,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ComposerEditGlow._green.withValues(
                          alpha: (haloA * 1.05).clamp(0.0, 1.0),
                        ),
                        blurRadius: blurMid,
                        spreadRadius: 0.25,
                      ),
                      BoxShadow(
                        color: ComposerEditGlow._green.withValues(
                          alpha: (haloA * 0.55).clamp(0.0, 1.0),
                        ),
                        blurRadius: blurOuter,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
