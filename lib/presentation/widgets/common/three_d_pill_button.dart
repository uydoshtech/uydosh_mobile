import "package:flutter/material.dart";

class ThreeDPillButton extends StatefulWidget {
  const ThreeDPillButton({
    required this.child,
    required this.onPressed,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;

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

    final darkShadow = Colors.black.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.20,
    );
    final lightShadow = Colors.white.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.65,
    );

    final shadows = _pressed || !enabled
        ? <BoxShadow>[
            BoxShadow(
              color: darkShadow,
              offset: const Offset(2, 2),
              blurRadius: 8,
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: lightShadow,
              offset: const Offset(-3, -3),
              blurRadius: 10,
            ),
            BoxShadow(
              color: darkShadow,
              offset: const Offset(6, 6),
              blurRadius: 14,
            ),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onPressed,
          onHighlightChanged: enabled ? (v) => setState(() => _pressed = v) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    bg,
                    scheme.onSurface,
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.06
                        : 0.03,
                  )!,
                  bg,
                ],
              ),
              boxShadow: shadows,
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
