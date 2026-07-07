import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Rotating UyDosh brand-mark (red roof + white "U") used app-wide in place
/// of the default Material [CircularProgressIndicator].
///
/// Always renders the dark-themed brand mark (white glyph, red roof) so the
/// spinner reads consistently regardless of the surrounding theme or the
/// color previously passed to a [CircularProgressIndicator].
class UydoshLogoSpinner extends StatefulWidget {
  const UydoshLogoSpinner({
    super.key,
    this.size = 28,
    this.duration = const Duration(milliseconds: 900),
  });

  /// Width and height of the rendered logo.
  final double size;

  /// Duration of one full 360° rotation.
  final Duration duration;

  @override
  State<UydoshLogoSpinner> createState() => _UydoshLogoSpinnerState();
}

class _UydoshLogoSpinnerState extends State<UydoshLogoSpinner>
    with SingleTickerProviderStateMixin {
  // Renders the brand mark twice as large as [UydoshLogoSpinner.size] so it
  // reads clearly at the small dimensions most call sites request, while
  // `Transform.scale` keeps the widget's own layout footprint at `size` —
  // it just paints larger over/around whatever tight row or button already
  // budgeted space for the old CircularProgressIndicator, no call sites
  // need to change their sizing.
  static const double _visualScale = 2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Transform.scale(
        scale: _visualScale,
        child: RotationTransition(
          turns: _controller,
          child: SvgPicture.asset(
            "assets/icon/components/brand_logo_transparent.svg",
            width: widget.size,
            height: widget.size,
          ),
        ),
      ),
    );
  }
}
