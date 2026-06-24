import "dart:math" as math;

import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";

/// Unread badge that pulses (scale) a few times on [trigger] changes,
/// then continues blinking to attract attention.
class PulseThenBlinkDotWidget extends StatefulWidget {
  const PulseThenBlinkDotWidget({
    required this.trigger,
    super.key,
    this.color = Colors.green,
    this.size = 12.0,
    this.blinkDuration = const Duration(seconds: 2),
    this.borderColor,
    this.borderWidth = 2.0,
    this.pulseCount = 3,
    this.pulseScale = 1.35,
    this.pulseStep = const Duration(milliseconds: 120),
  });

  /// Change this value (e.g. increment) to replay the pulse.
  final int trigger;

  final Color color;
  final double size;

  /// Duration of the blink cycle after the pulse completes.
  final Duration blinkDuration;

  final Color? borderColor;
  final double borderWidth;

  /// How many full grow+shrink pulses to play.
  final int pulseCount;

  /// Maximum scale during pulse.
  final double pulseScale;

  /// Duration of each half-step (grow or shrink).
  final Duration pulseStep;

  @override
  State<PulseThenBlinkDotWidget> createState() =>
      _PulseThenBlinkDotWidgetState();
}

class _PulseThenBlinkDotWidgetState extends State<PulseThenBlinkDotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: _pulseTotalDuration(widget.pulseCount, widget.pulseStep),
  );

  late final AnimationController _blinkController = AnimationController(
    vsync: this,
    duration: widget.blinkDuration,
  );

  late final Animation<double> _blink =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _blinkController, curve: Curves.linear),
  );

  /// Single merged listenable — avoids allocating [Listenable.merge] every build.
  late final Listenable _pulseAndBlink =
      Listenable.merge([_blinkController, _pulseController]);

  int _lastTrigger = 0;
  bool _blinkEnabled = false;

  static Duration _pulseTotalDuration(int pulseCount, Duration pulseStep) {
    final steps = (pulseCount <= 0) ? 0 : pulseCount * 2;
    return Duration(milliseconds: pulseStep.inMilliseconds * steps);
  }

  @override
  void initState() {
    super.initState();
    _lastTrigger = widget.trigger;

    // If we mount with an already-incremented trigger (e.g. app resumed with
    // unread that just arrived), play the pulse once so it’s noticeable.
    if (_lastTrigger > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _playPulseThenBlink();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBlink();
  }

  @override
  void didUpdateWidget(covariant PulseThenBlinkDotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.blinkDuration != widget.blinkDuration) {
      _blinkController.duration = widget.blinkDuration;
      if (_blinkController.isAnimating && _blinkEnabled) {
        _blinkController
          ..stop()
          ..repeat(reverse: true);
      }
    }

    // If pulse tuning changed, rebuild controller/animation quickly.
    if (oldWidget.pulseCount != widget.pulseCount ||
        oldWidget.pulseStep != widget.pulseStep) {
      _pulseController.duration =
          _pulseTotalDuration(widget.pulseCount, widget.pulseStep);
    }

    if (widget.trigger == _lastTrigger) return;
    _lastTrigger = widget.trigger;
    _playPulseThenBlink();
  }

  void _syncBlink() {
    final enabled = UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    _blinkEnabled = enabled;
    if (_pulseController.isAnimating) return;
    if (enabled) {
      if (!_blinkController.isAnimating) {
        _blinkController.repeat(reverse: true);
      }
    } else {
      _blinkController.stop();
      _blinkController.value = 1.0;
    }
  }

  Future<void> _playPulseThenBlink() async {
    if (!mounted) return;

    // Pause blink so the pulse reads clearly.
    _blinkController.stop();

    _pulseController
      ..stop()
      ..reset();

    // Animate a few scale oscillations (reads like "pulse").
    // We implement the oscillation by driving the scale via a sine-like curve:
    // scale = 1 + (pulseScale-1) * sin(pi * t) across each half-step.
    await _pulseController.forward();

    if (!mounted) return;
    _syncBlink();
  }

  double _pulseScaleValue() {
    // Oscillate around 1.0 so we visibly grow AND shrink several times.
    // scale = 1 + a * sin(2π * count * t)
    final count = widget.pulseCount <= 0 ? 0 : widget.pulseCount;
    if (count == 0) return 1.0;
    final a = (widget.pulseScale - 1.0).clamp(0.0, 1.0);
    final t = _pulseController.value;
    final s = math.sin(2 * math.pi * count * t); // -1..1
    return (1.0 + a * s).clamp(0.1, 10.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAndBlink,
      builder: (context, child) {
        // Blink: hide/show like the existing BlinkingDotWidget behavior.
        if (_blinkEnabled &&
            _blink.value < 0.5 &&
            !_pulseController.isAnimating) {
          return const SizedBox.shrink();
        }

        final scale = _pulseController.isAnimating ? _pulseScaleValue() : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(widget.color, Colors.white, 0.32) ?? widget.color,
                  Color.lerp(widget.color, Colors.black, 0.22) ?? widget.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.24),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
              color: widget.borderColor != null ? null : widget.color,
              border: widget.borderColor != null
                  ? Border.all(
                      color: widget.borderColor!,
                      width: widget.borderWidth,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
