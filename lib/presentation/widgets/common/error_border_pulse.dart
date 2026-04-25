import "package:flutter/material.dart";

/// Wraps [child] with a soft, gently pulsing red border + glow when
/// [showError] is true. Used to flag form controls that failed validation
/// without disturbing the underlying decoration of the control itself.
///
/// The overlay is rendered via a [Stack] / [Positioned.fill] [IgnorePointer]
/// so it never intercepts taps and does not influence layout — the child
/// retains its original size and hit-test behaviour. When [showError] is
/// false, [ErrorBorderPulse] returns the child untouched, so it costs
/// nothing in the happy path.
///
/// Visually mirrors the validation styling used by the create/edit listing
/// flow (see [ThreeDSurfaceStyle.wheelPickerPlateDecoration]) so the entire
/// app speaks the same "field missing" language.
class ErrorBorderPulse extends StatefulWidget {
  const ErrorBorderPulse({
    required this.child,
    required this.showError,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.minWidth = 1.2,
    this.maxWidth = 2.1,
  });

  final Widget child;
  final bool showError;
  final BorderRadius borderRadius;

  /// Stroke width at the dimmest pulse frame.
  final double minWidth;

  /// Stroke width at the brightest pulse frame.
  final double maxWidth;

  @override
  State<ErrorBorderPulse> createState() => _ErrorBorderPulseState();
}

class _ErrorBorderPulseState extends State<ErrorBorderPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.showError) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ErrorBorderPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError != oldWidget.showError) {
      if (widget.showError) {
        _controller.repeat(reverse: true);
      } else {
        _controller
          ..stop()
          ..reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showError) {
      return widget.child;
    }
    final error = Theme.of(context).colorScheme.error;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final p = _pulse.value;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: Border.all(
                      color: Color.lerp(
                        error.withValues(alpha: 0.38),
                        error,
                        p,
                      )!,
                      width: widget.minWidth +
                          (widget.maxWidth - widget.minWidth) * p,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: error.withValues(alpha: 0.07 + 0.26 * p),
                        blurRadius: 2 + 14 * p,
                        spreadRadius: 0.2 + 1.1 * p,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
