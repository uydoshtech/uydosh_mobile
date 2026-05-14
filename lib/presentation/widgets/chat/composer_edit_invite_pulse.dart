import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/safe_state.dart";

/// Wraps the chat composer field; when [pulseTrigger] notifies (typically each
/// increment means “user started editing an existing bubble”), the border
/// flashes green a few times to draw attention without blocking input.
class ComposerEditInvitePulse extends StatefulWidget {
  const ComposerEditInvitePulse({
    required this.child,
    required this.pulseTrigger,
    required this.borderRadius,
    super.key,
  });

  final Widget child;
  final ValueListenable<int> pulseTrigger;
  final BorderRadius borderRadius;

  @override
  State<ComposerEditInvitePulse> createState() =>
      _ComposerEditInvitePulseState();
}

class _ComposerEditInvitePulseState extends State<ComposerEditInvitePulse> {
  static const Color _green = Color(0xFF22C55E);
  static const int _blinks = 3;
  static const Duration _onDuration = Duration(milliseconds: 260);
  static const Duration _offDuration = Duration(milliseconds: 220);

  late final VoidCallback _listener;
  int _pulseGen = 0;
  bool _glow = false;

  @override
  void initState() {
    super.initState();
    _listener = _onPulseSignal;
    widget.pulseTrigger.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant ComposerEditInvitePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseTrigger != widget.pulseTrigger) {
      oldWidget.pulseTrigger.removeListener(_listener);
      widget.pulseTrigger.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.pulseTrigger.removeListener(_listener);
    super.dispose();
  }

  void _onPulseSignal() {
    final gen = ++_pulseGen;
    unawaited(_runBlinkSequence(gen));
  }

  Future<void> _runBlinkSequence(int gen) async {
    for (var i = 0; i < _blinks; i++) {
      if (!mounted || gen != _pulseGen) return;
      setStateIfMounted(() => _glow = true);
      await Future<void>.delayed(_onDuration);
      if (!mounted || gen != _pulseGen) return;
      setStateIfMounted(() => _glow = false);
      await Future<void>.delayed(_offDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_glow) return widget.child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: _green.withValues(alpha: 0.92),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.38),
                    blurRadius: 14,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
