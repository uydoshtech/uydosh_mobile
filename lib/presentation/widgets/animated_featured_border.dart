import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFeaturedBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;

  const AnimatedFeaturedBorder({
    super.key,
    required this.child,
    this.borderWidth = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<AnimatedFeaturedBorder> createState() => _AnimatedFeaturedBorderState();
}

class _AnimatedFeaturedBorderState extends State<AnimatedFeaturedBorder>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.repeat();
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              width: widget.borderWidth,
              color: Colors.transparent,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: SweepGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.red,
                ],
                startAngle: _animation.value * 2 * math.pi,
                endAngle: (_animation.value * 2 * math.pi) + 2 * math.pi,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(widget.borderWidth),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: widget.borderRadius,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
