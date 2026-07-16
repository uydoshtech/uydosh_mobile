import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Rotating UyDosh brand-mark (red roof + white "U") used for major
/// screen-level loading states (initial screen loads, full-page loaders).
///
/// Do not use this for buttons or other small inline controls — use
/// `UydoshInlineSpinner` (a plain [CircularProgressIndicator]) there instead,
/// so the brand animation is reserved for moments that matter.
///
/// Defaults to the dark-themed brand mark (white glyph, red roof) so the
/// spinner reads consistently regardless of the surrounding theme or the
/// color previously passed to a [CircularProgressIndicator].
///
/// Set [onLightBackground] to render the light-surface brand mark (black
/// glyph, red roof) instead, for cases where the spinner sits on a light
/// fill (e.g. the listing-detail photo placeholder) and the white glyph
/// would wash out.
class UydoshLogoSpinner extends StatefulWidget {
  const UydoshLogoSpinner({
    super.key,
    this.size = 28,
    this.duration = const Duration(milliseconds: 900),
    this.onLightBackground = false,
  });

  /// Width and height of the rendered logo.
  final double size;

  /// Duration of one full 360° rotation.
  final Duration duration;

  /// When `true`, renders the black-glyph mark meant for light backgrounds.
  final bool onLightBackground;

  @override
  State<UydoshLogoSpinner> createState() => _UydoshLogoSpinnerState();
}

class _UydoshLogoSpinnerState extends State<UydoshLogoSpinner>
    with SingleTickerProviderStateMixin {
  // Renders the brand mark twice as large as [UydoshLogoSpinner.size] so it
  // reads clearly at the small dimensions most call sites request, while
  // `OverflowBox` keeps the widget's own layout footprint at `size` —
  // it just paints larger over/around whatever tight row or button already
  // budgeted space for the old CircularProgressIndicator, no call sites
  // need to change their sizing. The SVG must be laid out at the full
  // visual size (not scaled up with `Transform.scale`), because flutter_svg
  // rasterizes at layout size and post-scaling the raster looks blurry.
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
    final double visualSize = widget.size * _visualScale;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: OverflowBox(
        maxWidth: visualSize,
        maxHeight: visualSize,
        child: RotationTransition(
          turns: _controller,
          child: SvgPicture.asset(
            widget.onLightBackground
                ? "assets/icon/components/brand_mark_light.svg"
                : "assets/icon/components/brand_logo_transparent.svg",
            width: visualSize,
            height: visualSize,
          ),
        ),
      ),
    );
  }
}
