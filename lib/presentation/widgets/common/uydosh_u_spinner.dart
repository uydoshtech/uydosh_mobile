import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Rotating UyDosh brand-mark loader used for map-loading states, where the
/// "U" + chimney glyph must match the map's own light/dark tint (black over
/// the light map style, white over the night map style) rather than the app
/// theme, while the roof stays the fixed brand red.
///
/// Unlike [UydoshLogoSpinner] (which follows the app theme, or an explicit
/// light-surface override), this widget tints the `u_letter.svg` +
/// `chimney.svg` glyphs with [color] so they stay legible against either map
/// style, layering the always-red `red_roof.svg` on top — matching
/// `brand_logo_transparent.svg` / `brand_mark_light.svg`, just with a
/// swappable glyph color instead of a theme-driven asset.
class UydoshUSpinner extends StatefulWidget {
  const UydoshUSpinner({
    required this.color,
    super.key,
    this.size = 40,
    this.duration = const Duration(milliseconds: 900),
  });

  /// Tint applied to the "U" glyph.
  final Color color;

  /// Width and height of the rendered glyph.
  final double size;

  /// Duration of one full 360° rotation.
  final Duration duration;

  @override
  State<UydoshUSpinner> createState() => _UydoshUSpinnerState();
}

class _UydoshUSpinnerState extends State<UydoshUSpinner>
    with SingleTickerProviderStateMixin {
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
      child: RotationTransition(
        turns: _controller,
        child: Stack(
          alignment: Alignment.center,
          // All three glyphs share the same viewBox as
          // `brand_logo_transparent.svg`, so stacking them at the same size
          // reproduces that combined mark without needing a dedicated asset.
          children: [
            SvgPicture.asset(
              "assets/icon/components/red_roof.svg",
              width: widget.size,
              height: widget.size,
            ),
            SvgPicture.asset(
              "assets/icon/components/chimney.svg",
              width: widget.size,
              height: widget.size,
              colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
            ),
            SvgPicture.asset(
              "assets/icon/components/u_letter.svg",
              width: widget.size,
              height: widget.size,
              colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
