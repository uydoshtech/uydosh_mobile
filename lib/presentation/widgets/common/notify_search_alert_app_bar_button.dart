import "dart:math" as math;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";

/// Animated bell-plus icon button used for "notify me" (search alerts).
///
/// Matches the search results screen behavior: idle wiggle (optional),
/// tap ring + wiggle, and a stronger "saved" celebration when
/// [celebrationTick] changes.
class NotifySearchAlertAppBarButton extends StatefulWidget {
  const NotifySearchAlertAppBarButton({
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.celebrationTick = 0,
    this.enabled = true,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final int celebrationTick;
  final bool enabled;

  @override
  State<NotifySearchAlertAppBarButton> createState() =>
      _NotifySearchAlertAppBarButtonState();
}

class _NotifySearchAlertAppBarButtonState
    extends State<NotifySearchAlertAppBarButton> with TickerProviderStateMixin {
  late final AnimationSettingsState _animationSettings;

  late final AnimationController _idleController;
  late final Animation<double> _idleBellTurns;

  late final AnimationController _tapController;
  late final Animation<double> _tapBellTurns;
  late final Animation<double> _tapRingScale;
  late final Animation<double> _tapRingOpacity;

  late final AnimationController _savedController;
  late final Animation<double> _savedBellTurns;
  late final Animation<double> _savedScale;
  late final Animation<double> _savedRingScale;
  late final Animation<double> _savedRingOpacity;

  @override
  void initState() {
    super.initState();
    _animationSettings = AnimationSettingsState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    );
    _idleBellTurns = Tween<double>(begin: -0.012, end: 0.012).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 624),
    );
    _tapBellTurns = TweenSequence<double>([
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
    ]).animate(_tapController);

    _tapRingScale = Tween<double>(begin: 1, end: 2.15).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: const Interval(0, 0.72, curve: Curves.easeOut),
      ),
    );
    // Opacity must be 0 at controller value 0: a Tween(begin: 0.5, end: 0) on an
    // Interval starting at 0 still evaluates to 0.5 at rest (curve t = 0 → begin).
    _tapRingOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.5).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 82,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 12),
    ]).animate(_tapController);

    _savedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    );
    _savedBellTurns = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.16).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.16, end: -0.14).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.14, end: 0.11).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.11, end: -0.065).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.065, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 20,
      ),
    ]).animate(_savedController);

    _savedScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.16).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.16, end: 0.97).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 54,
      ),
    ]).animate(_savedController);

    _savedRingScale = Tween<double>(begin: 1, end: 2.35).animate(
      CurvedAnimation(
        parent: _savedController,
        curve: const Interval(0.08, 0.82, curve: Curves.easeOut),
      ),
    );
    // Same rest-state issue: Interval(0.08, 1) with begin 0.58 still yields 0.58 at t=0.
    _savedRingOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 8),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.58).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.58, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 78,
      ),
    ]).animate(_savedController);

    _animationSettings.addListener(_syncFromSettings);
    _syncFromSettings();
  }

  @override
  void didUpdateWidget(covariant NotifySearchAlertAppBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrationTick != oldWidget.celebrationTick &&
        widget.celebrationTick > 0 &&
        _animationSettings.bellTapEnabled) {
      HapticFeedbackUtils.selection();
      _savedController.forward(from: 0);
    }
  }

  void _syncFromSettings() {
    if (!mounted) return;
    final idleEnabled = _animationSettings.bellIdleEnabled;
    if (idleEnabled) {
      if (!_idleController.isAnimating) {
        _idleController.repeat(reverse: true);
      }
    } else {
      _idleController.stop();
      _idleController.value = 0.5;
    }

    final tapEnabled = _animationSettings.bellTapEnabled;
    if (!tapEnabled) {
      _tapController.stop();
      _tapController.value = 0;
      _savedController.stop();
      _savedController.value = 0;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _animationSettings.removeListener(_syncFromSettings);
    _tapController.dispose();
    _idleController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  Color _iconColor() =>
      ThemeState().isBlueTheme ? Colors.white : Colors.black;

  void _handlePressed() {
    if (!widget.enabled) return;
    HapticFeedbackUtils.impact();
    if (_animationSettings.bellTapEnabled) {
      _tapController.forward(from: 0);
    }
    widget.onPressed();
  }

  Widget _icon(Color iconColor) {
    return Center(
      child: ThemeIcon(
        Icons.add_alert,
        size: 24,
        color: iconColor,
        useThemeColor: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idleEnabled = _animationSettings.bellIdleEnabled;
    final tapEnabled = _animationSettings.bellTapEnabled;
    final ringColor = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final iconColor = _iconColor();
        return Tooltip(
          message: widget.tooltip,
          child: Semantics(
            label: widget.tooltip,
            button: true,
            child: ThreeDPillButton(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              padding: const EdgeInsets.all(6),
              onPressed: widget.enabled ? _handlePressed : null,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (tapEnabled)
                      AnimatedBuilder(
                        animation: _tapController,
                        builder: (context, _) {
                          return IgnorePointer(
                            child: Opacity(
                              opacity: _tapRingOpacity.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: _tapRingScale.value,
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
                    if (tapEnabled)
                      AnimatedBuilder(
                        animation: _savedController,
                        builder: (context, _) {
                          return IgnorePointer(
                            child: Opacity(
                              opacity: _savedRingOpacity.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: _savedRingScale.value,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          AppColors.success.withValues(alpha: 0.9),
                                      width: 1.75,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _idleController,
                        _tapController,
                        _savedController,
                      ]),
                      builder: (context, _) {
                        final turns =
                            (idleEnabled ? _idleBellTurns.value : 0.0) +
                                (tapEnabled ? _tapBellTurns.value : 0.0) +
                                (tapEnabled ? _savedBellTurns.value : 0.0);
                        final scale = tapEnabled ? _savedScale.value : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: turns * 2 * math.pi,
                            alignment: Alignment.topCenter,
                            child: _icon(iconColor),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
