import "dart:math" as math;

import "package:flutter/material.dart";

class AnimatedFeaturedBorder extends StatefulWidget {

  const AnimatedFeaturedBorder({
    required this.child, super.key,
    this.borderWidth = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;

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
    // The inner card (margin + child) doesn't depend on the animation tick,
    // so we hoist it into the AnimatedBuilder `child` slot. This means each
    // ~16ms frame only rebuilds the two outer DecoratedBox widgets (one
    // transparent border + one sweep-gradient ring) instead of also
    // rebuilding the entire `widget.child` subtree (a full ListingTile).
    //
    // RepaintBoundary isolates the rotating ring's repaints from neighbours
    // — without it, the parent ListView treats this whole region as dirty
    // every frame, which can show up as raster-thread spikes when several
    // featured tiles are visible.
    final inner = Container(
      margin: EdgeInsets.all(widget.borderWidth),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        child: inner,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: Border.all(
                width: widget.borderWidth,
                color: Colors.transparent,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: SweepGradient(
                  colors: const [
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
              child: child,
            ),
          );
        },
      ),
    );
  }
}
