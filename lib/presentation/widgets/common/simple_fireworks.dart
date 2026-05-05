import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

/// Lightweight, self-contained replacement for `flutter_fireworks`.
///
/// We previously used `package:flutter_fireworks` for the achievement-unlock
/// celebration, which transitively pulled in `package:flame` (~60 KB Dart
/// AOT plus its own dependencies). The visual effect we actually used is
/// modest enough — a handful of rockets that rise, decelerate, and explode
/// into coloured particles — that a custom [CustomPainter] is a much
/// cheaper way to ship the same UX.
///
/// Public API mirrors the bits we depended on so the existing call sites
/// (e.g. [AchievementUnlockBottomSheet]) needed only an import swap:
///
/// * [SimpleFireworksController] — exposes [fireMultipleRockets] and is
///   `ChangeNotifier`-based, so [SimpleFireworksDisplay] simply listens.
/// * [SimpleFireworksDisplay] — paints the rockets and particles every
///   frame via a [Ticker]. Repaints stop automatically when there are no
///   active rockets/particles.
///
/// This widget never claims pointer events; wrap it in [IgnorePointer] at
/// the call site if it sits above interactive content.
class SimpleFireworksController extends ChangeNotifier {
  SimpleFireworksController({
    required this.colors,
    this.minExplosionDuration = 1.0,
    this.maxExplosionDuration = 2.5,
    this.minParticleCount = 80,
    this.maxParticleCount = 180,
    this.fadeOutDuration = 0.4,
  })  : assert(colors.isNotEmpty, "Need at least one colour"),
        assert(minExplosionDuration > 0),
        assert(maxExplosionDuration >= minExplosionDuration),
        assert(minParticleCount > 0),
        assert(maxParticleCount >= minParticleCount),
        assert(fadeOutDuration >= 0);

  /// Palette to draw rocket trails and explosion particles from. Each rocket
  /// picks one colour and reuses it for all of its child particles so each
  /// burst reads as a coherent splash.
  final List<Color> colors;

  /// Particle lifetime range, in seconds. Picked uniformly per rocket.
  final double minExplosionDuration;
  final double maxExplosionDuration;

  /// How many particles a rocket emits when it explodes. Picked uniformly
  /// per rocket within `[minParticleCount, maxParticleCount]`.
  final int minParticleCount;
  final int maxParticleCount;

  /// Tail of each particle's lifetime spent fading to alpha 0, in seconds.
  /// (Not a separate animation phase; we just ramp alpha during the last
  /// `fadeOutDuration` seconds of a particle's life.)
  final double fadeOutDuration;

  final List<_Rocket> _rockets = <_Rocket>[];
  final List<_Particle> _particles = <_Particle>[];
  final Random _rng = Random();

  /// Whether anything is currently animating. The display widget uses this
  /// to decide whether to keep its [Ticker] running.
  bool get isAnimating => _rockets.isNotEmpty || _particles.isNotEmpty;

  /// Schedules `[minRockets, maxRockets]` rockets to launch over
  /// [launchWindow]. Each rocket is given a random horizontal launch X (10%
  /// inset on each side) and a random apex height between 35% and 65% of
  /// the canvas height. Apex height is resolved at first paint when we
  /// finally know the canvas size.
  void fireMultipleRockets({
    required int minRockets,
    required int maxRockets,
    required Duration launchWindow,
  }) {
    assert(minRockets > 0);
    assert(maxRockets >= minRockets);
    final count = minRockets + _rng.nextInt(maxRockets - minRockets + 1);
    final windowMs = launchWindow.inMilliseconds;
    for (var i = 0; i < count; i++) {
      final delayMs = count <= 1 ? 0 : (windowMs * i ~/ (count - 1));
      Future<void>.delayed(Duration(milliseconds: delayMs), () {
        _spawnRocket();
      });
    }
  }

  void _spawnRocket() {
    final color = colors[_rng.nextInt(colors.length)];
    final apexFraction = 0.35 + _rng.nextDouble() * 0.30;
    // Inset launch X to 10..90% so rockets don't clip the gutters.
    final launchXFraction = 0.10 + _rng.nextDouble() * 0.80;
    // Rise duration between 0.6s and 1.0s — short enough that consecutive
    // rockets in a multi-fire don't all hang on the way up.
    final riseDuration = 0.6 + _rng.nextDouble() * 0.4;
    final particleCount = minParticleCount +
        _rng.nextInt(maxParticleCount - minParticleCount + 1);
    final lifetime = minExplosionDuration +
        _rng.nextDouble() * (maxExplosionDuration - minExplosionDuration);

    _rockets.add(
      _Rocket(
        launchXFraction: launchXFraction,
        apexFraction: apexFraction,
        riseDuration: riseDuration,
        color: color,
        particleCount: particleCount,
        particleLifetime: lifetime,
      ),
    );
    notifyListeners();
  }

  /// Advances the simulation by [dt] seconds. Called by the display widget's
  /// ticker. Returns `true` if anything is still animating.
  bool tick(double dt, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return isAnimating;

    // Rockets: rise and explode at apex.
    for (var i = _rockets.length - 1; i >= 0; i--) {
      final r = _rockets[i];
      r.elapsed += dt;
      final t = (r.elapsed / r.riseDuration).clamp(0.0, 1.0);
      // Eased rise: start fast, decelerate at apex (1 - (1 - t)^2 inverted).
      final progress = 1 - (1 - t) * (1 - t);
      r.currentPosition = Offset(
        r.launchXFraction * canvasSize.width,
        canvasSize.height -
            progress *
                (canvasSize.height -
                    r.apexFraction * canvasSize.height),
      );
      if (t >= 1.0) {
        _explode(r, canvasSize);
        _rockets.removeAt(i);
      }
    }

    // Particles: integrate velocity + gravity, age out.
    const gravity = 220.0; // px / s^2
    const drag = 0.92; // applied per second
    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.age += dt;
      if (p.age >= p.lifetime) {
        _particles.removeAt(i);
        continue;
      }
      // Drag: vel *= drag^dt. Cheaper than computing pow each frame; for
      // small dt the linear approximation is visually indistinguishable.
      final dragFactor = 1 - (1 - drag) * dt;
      p.velocity = Offset(
        p.velocity.dx * dragFactor,
        p.velocity.dy * dragFactor + gravity * dt,
      );
      p.position += p.velocity * dt;
    }

    return isAnimating;
  }

  void _explode(_Rocket rocket, Size canvasSize) {
    final origin = rocket.currentPosition;
    final n = rocket.particleCount;
    for (var i = 0; i < n; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      // Speed distributed over a band so the burst looks bushy, not ringy.
      final speed = 80 + _rng.nextDouble() * 220;
      final velocity = Offset(cos(angle) * speed, sin(angle) * speed);
      final lifetime = rocket.particleLifetime *
          (0.7 + _rng.nextDouble() * 0.3);
      _particles.add(
        _Particle(
          position: origin,
          velocity: velocity,
          color: rocket.color,
          lifetime: lifetime,
        ),
      );
    }
    notifyListeners();
  }
}

/// Paints the rockets and particles owned by [controller]. Runs a [Ticker]
/// while the controller has anything active, then idles to avoid burning
/// CPU.
class SimpleFireworksDisplay extends StatefulWidget {
  const SimpleFireworksDisplay({
    required this.controller,
    super.key,
  });

  final SimpleFireworksController controller;

  @override
  State<SimpleFireworksDisplay> createState() => _SimpleFireworksDisplayState();
}

class _SimpleFireworksDisplayState extends State<SimpleFireworksDisplay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration? _lastTickTimestamp;
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.isAnimating) _ticker.start();
  }

  @override
  void didUpdateWidget(covariant SimpleFireworksDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (widget.controller.isAnimating && !_ticker.isActive) {
      _lastTickTimestamp = null;
      _ticker.start();
    }
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    final last = _lastTickTimestamp;
    _lastTickTimestamp = elapsed;
    if (last == null) return;
    final dt = (elapsed - last).inMicroseconds / 1e6;
    final stillAnimating = widget.controller.tick(dt, _canvasSize);
    if (!stillAnimating) {
      _ticker.stop();
      _lastTickTimestamp = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: _canvasSize,
          painter: _FireworksPainter(
            controller: widget.controller,
            fadeOutDuration: widget.controller.fadeOutDuration,
          ),
        );
      },
    );
  }
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter({
    required this.controller,
    required this.fadeOutDuration,
  });

  final SimpleFireworksController controller;
  final double fadeOutDuration;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Rocket trails: small streak from launch x at the base up to current
    // position. Reads as a glowing line; we draw it as a soft gradient via
    // a couple of stacked circles instead of [Paint.maskFilter] for cost.
    for (final r in controller._rockets) {
      final start = Offset(r.launchXFraction * size.width, size.height);
      final end = r.currentPosition;
      paint
        ..color = r.color.withValues(alpha: 0.55)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, paint);
      paint
        ..style = PaintingStyle.fill
        ..color = r.color;
      canvas.drawCircle(end, 2.5, paint);
    }

    // Particles: filled circles. Alpha ramps over the last [fadeOutDuration]
    // seconds of life, otherwise full intensity. Radius shrinks slightly
    // toward end-of-life for a snappier "die-out".
    for (final p in controller._particles) {
      final remaining = p.lifetime - p.age;
      final fadeStart = fadeOutDuration;
      final alpha = remaining >= fadeStart
          ? 1.0
          : (remaining / fadeStart).clamp(0.0, 1.0);
      final lifeFraction = (p.age / p.lifetime).clamp(0.0, 1.0);
      final radius = 2.5 * (1 - lifeFraction * 0.4);
      paint
        ..style = PaintingStyle.fill
        ..color = p.color.withValues(alpha: alpha);
      canvas.drawCircle(p.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) => true;
}

class _Rocket {
  _Rocket({
    required this.launchXFraction,
    required this.apexFraction,
    required this.riseDuration,
    required this.color,
    required this.particleCount,
    required this.particleLifetime,
  });

  final double launchXFraction;
  final double apexFraction;
  final double riseDuration;
  final Color color;
  final int particleCount;
  final double particleLifetime;

  double elapsed = 0;
  Offset currentPosition = Offset.zero;
}

class _Particle {
  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.lifetime,
  });

  Offset position;
  Offset velocity;
  final Color color;
  final double lifetime;
  double age = 0;
}
