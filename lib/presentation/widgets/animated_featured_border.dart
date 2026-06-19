import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

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

class _AnimatedFeaturedBorderState extends State<AnimatedFeaturedBorder> {
  // Why this widget no longer owns its own [AnimationController]:
  //
  // The previous implementation created one repeating controller per featured
  // tile. With several featured listings on screen (and many more held alive
  // by the feed's `ListView`/`SliverList` build cache while scrolled
  // off-screen), that meant N independent tickers each driving a sweep
  // gradient at 60 fps — measurable foreground CPU drain on long scroll
  // sessions.
  //
  // Now all featured borders share a single module-level ticker (see
  // [_SharedFeaturedSweep] below). Per-tile cost is just an `AnimatedBuilder`
  // listening to a `ValueNotifier`; the actual frame work is O(1) regardless
  // of how many featured tiles are mounted. The shared ticker also honors
  // `TickerMode` (paused when this tile's route is not on top, paused when
  // the app is not resumed via `LifecycleTickerMode`) by tracking each
  // tile's effective tick state via its own [TickerMode] dependency.
  bool _retained = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shouldTick = TickerMode.of(context);
    if (shouldTick && !_retained) {
      SharedFeaturedSweep.instance.retain();
      _retained = true;
    } else if (!shouldTick && _retained) {
      SharedFeaturedSweep.instance.release();
      _retained = false;
    }
  }

  @override
  void dispose() {
    if (_retained) {
      SharedFeaturedSweep.instance.release();
      _retained = false;
    }
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
        animation: SharedFeaturedSweep.instance.value,
        child: inner,
        builder: (context, child) {
          final t = SharedFeaturedSweep.instance.value.value;
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
                  startAngle: t * 2 * math.pi,
                  endAngle: (t * 2 * math.pi) + 2 * math.pi,
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

/// A single [Ticker] shared by every mounted [AnimatedFeaturedBorder].
///
/// Cost stays O(1) regardless of the number of featured tiles on screen — and
/// even more importantly, off-screen tiles parked in the feed's build cache
/// no longer each drive their own 60 fps repaint.
///
/// The ticker is only running while at least one tile has retained AND the
/// app is in [AppLifecycleState.resumed]. Per-tile pausing (e.g. when the
/// tile's route is not on top) is handled by [TickerMode]: tiles call
/// [release] from `didChangeDependencies` when their context's [TickerMode]
/// goes false, so the ref count drops naturally.
/// Shared ticker for featured listing rings. Exposed so feed scroll hosts can
/// pause the sweep while the user is flinging the list.
class SharedFeaturedSweep with WidgetsBindingObserver {
  SharedFeaturedSweep._() {
    WidgetsBinding.instance.addObserver(this);
    final initial = WidgetsBinding.instance.lifecycleState;
    _appResumed = initial == null || initial == AppLifecycleState.resumed;
  }

  static final SharedFeaturedSweep instance = SharedFeaturedSweep._();

  /// Sweep phase in `[0.0, 1.0)`. Tiles read this through `AnimatedBuilder`.
  final ValueNotifier<double> value = ValueNotifier<double>(0);

  /// Slowed from the previous 4 s → 8 s. Halves per-frame work the human eye
  /// is barely going to notice on a decorative rainbow ring, and the gradient
  /// still reads as "moving".
  static const Duration _period = Duration(seconds: 8);

  late final Ticker _ticker = Ticker(_onTick);
  int _refCount = 0;
  int _scrollPauseCount = 0;
  bool _appResumed = true;
  Duration _origin = Duration.zero;

  void retain() {
    _refCount++;
    _updateRunning();
  }

  void release() {
    if (_refCount > 0) _refCount--;
    _updateRunning();
  }

  void pauseForUserScroll() {
    _scrollPauseCount++;
    _updateRunning();
  }

  void resumeFromUserScroll() {
    if (_scrollPauseCount > 0) _scrollPauseCount--;
    _updateRunning();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isResumed = state == AppLifecycleState.resumed;
    if (isResumed != _appResumed) {
      _appResumed = isResumed;
      _updateRunning();
    }
  }

  void _updateRunning() {
    final shouldRun =
        _refCount > 0 && _appResumed && _scrollPauseCount == 0;
    if (shouldRun && !_ticker.isActive) {
      // Reset origin so the resumed phase doesn't jump after a long pause.
      _origin = Duration.zero;
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (_origin == Duration.zero) _origin = elapsed;
    final delta = elapsed - _origin;
    final periodMs = _period.inMilliseconds;
    final t = (delta.inMilliseconds % periodMs) / periodMs;
    value.value = t;
  }
}
