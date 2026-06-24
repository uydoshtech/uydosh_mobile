import "dart:math" as math;

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Notify-me control for empty search: expanding ring + bell wiggle on tap.
class NotifySearchAlertGhostButton extends StatefulWidget {
  const NotifySearchAlertGhostButton({
    required this.height,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final double height;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<NotifySearchAlertGhostButton> createState() =>
      _NotifySearchAlertGhostButtonState();
}

class _NotifySearchAlertGhostButtonState
    extends State<NotifySearchAlertGhostButton> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bellTurns;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final AnimationController _idleController;
  late final Animation<double> _idleBellTurns;
  late final CurvedAnimation _idleCurve;
  late final CurvedAnimation _ringScaleCurve;
  late final CurvedAnimation _ringOpacityCurve;
  late final AnimationSettingsState _animationSettings;
  bool _tickersEnabled = true;
  bool _lastIdleEnabled = false;
  bool _lastTapEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationSettings = AnimationSettingsState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    );
    _idleCurve = CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    );
    _idleBellTurns = Tween<double>(begin: -0.012, end: 0.012).animate(
      _idleCurve,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 624),
    );
    _bellTurns = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.09).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.09, end: 0.055).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.055, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 30,
      ),
    ]).animate(_controller);
    _ringScaleCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.72, curve: Curves.easeOut),
    );
    _ringScale = Tween<double>(begin: 1, end: 2.15).animate(_ringScaleCurve);
    _ringOpacityCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.88, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.5, end: 0).animate(_ringOpacityCurve);

    _animationSettings.addListener(_syncFromSettings);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickersEnabled = TickerMode.of(context);
    if (tickersEnabled != _tickersEnabled) {
      _tickersEnabled = tickersEnabled;
    }
    _syncFromSettings();
  }

  void _syncFromSettings() {
    if (!mounted) return;
    final idleEnabled = _animationSettings.bellIdleEnabled &&
        _animationSettings.uiAnimationsEnabled &&
        UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        _tickersEnabled;
    if (idleEnabled) {
      if (!_idleController.isAnimating) {
        _idleController.repeat(reverse: true);
      }
    } else {
      _idleController.stop();
      // 0 maps to tween begin (slightly rotated). Keep midpoint as "rest" angle.
      _idleController.value = 0.5;
    }

    final tapEnabled = _animationSettings.bellTapEnabled;
    if (!tapEnabled) {
      _controller.stop();
      _controller.value = 0;
    }

    if (_lastIdleEnabled != idleEnabled || _lastTapEnabled != tapEnabled) {
      _lastIdleEnabled = idleEnabled;
      _lastTapEnabled = tapEnabled;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationSettings.removeListener(_syncFromSettings);
    _idleCurve.dispose();
    _ringScaleCurve.dispose();
    _ringOpacityCurve.dispose();
    _controller.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _handlePressed() {
    if (widget.onPressed == null) return;
    if (_animationSettings.bellTapEnabled) {
      _controller.forward(from: 0);
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = theme.colorScheme.primary;
    final idleEnabled = _lastIdleEnabled;
    final tapEnabled = _lastTapEnabled;

    final label = theme.textTheme.labelLarge;
    final baseSize = label?.fontSize ?? 14;
    final textStyle = label?.copyWith(fontSize: baseSize * 1.2, height: 1.0) ??
        TextStyle(
          fontSize: baseSize * 1.2,
          height: 1.0,
          fontWeight: FontWeight.w500,
        );

    return PrimaryButton(
      onPressed: widget.onPressed == null ? null : _handlePressed,
      height: widget.height,
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: SizedBox(
              width: 30,
              height: 30,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (tapEnabled)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return IgnorePointer(
                          child: Opacity(
                            opacity: _ringOpacity.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: _ringScale.value,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ringColor.withValues(alpha: 0.85),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  AnimatedBuilder(
                    animation: Listenable.merge([_idleController, _controller]),
                    builder: (context, child) {
                      final turns = (idleEnabled ? _idleBellTurns.value : 0.0) +
                          (tapEnabled ? _bellTurns.value : 0.0);
                      return Transform.rotate(
                        angle: turns * 2 * math.pi,
                        alignment: Alignment.topCenter,
                        child: child,
                      );
                    },
                    child: const ThemeIcon(
                      Icons.notifications_active,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
