import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";

/// Haptic + optional click sound when [PressableTransform] is tapped.
enum PressableFeedback {
  /// Caller supplies feedback (or none).
  none,

  /// [UiFeedbackUtils.tap] — default.
  tap,

  /// [UiFeedbackUtils.selection] — picking among a small set of options.
  selection,
}

/// Adds the app's standard "pressed" transform (y-translation) to arbitrary UI.
class PressableTransform extends StatefulWidget {
  const PressableTransform({
    required this.onTap,
    required this.child,
    required this.borderRadius,
    super.key,
    this.enabled = true,
    this.feedback = PressableFeedback.tap,
    this.pressedOffset = 2.0,
    this.duration = const Duration(milliseconds: 90),
    this.disabledOpacity = 0.55,
  });

  final VoidCallback? onTap;
  final Widget child;
  final BorderRadius borderRadius;
  final bool enabled;

  /// Haptic + UI sound pairing for taps. Use [PressableFeedback.none] if the
  /// callback already calls [UiFeedbackUtils] or another feedback helper.
  final PressableFeedback feedback;
  final double pressedOffset;
  final Duration duration;
  final double disabledOpacity;

  @override
  State<PressableTransform> createState() => _PressableTransformState();
}

class _PressableTransformState extends State<PressableTransform> {
  bool _pressed = false;

  bool get _enabled => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      transform: Matrix4.translationValues(
        0,
        _pressed && _enabled ? widget.pressedOffset : 0,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap:
              _enabled
                  ? () {
                    final f = widget.feedback;
                    if (f == PressableFeedback.tap) {
                      UiFeedbackUtils.tap();
                    } else if (f == PressableFeedback.selection) {
                      UiFeedbackUtils.selection();
                    }
                    widget.onTap!();
                  }
                  : null,
          onHighlightChanged:
              _enabled ? (v) => setState(() => _pressed = v) : null,
          child: Opacity(
            opacity: _enabled ? 1 : widget.disabledOpacity,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

