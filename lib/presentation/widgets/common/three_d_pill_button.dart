import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class ThreeDPillButton extends StatefulWidget {
  const ThreeDPillButton({
    required this.child,
    required this.onPressed,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.backgroundColor,
    this.borderSide,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  bool get _enabled => onPressed != null;

  @override
  State<ThreeDPillButton> createState() => _ThreeDPillButtonState();
}

class _ThreeDPillButtonState extends State<ThreeDPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.backgroundColor ?? scheme.surface;
    final enabled = widget._enabled;

    final shadows = _pressed || !enabled
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: enabled
              ? () {
                  HapticFeedbackUtils.impact();
                  widget.onPressed?.call();
                }
              : null,
          onHighlightChanged: enabled ? (v) => setState(() => _pressed = v) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: ThreeDSurfaceStyle.surfaceGradient(context, bg),
              boxShadow: shadows,
              border:
                  widget.borderSide == null ? null : Border.fromBorderSide(widget.borderSide!),
            ),
            child: Opacity(
              opacity: enabled ? 1 : 0.55,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: scheme.onSurface),
                child: IconTheme.merge(
                  data: IconThemeData(color: scheme.onSurface),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
