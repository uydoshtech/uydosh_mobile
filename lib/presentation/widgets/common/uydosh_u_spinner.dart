import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Rotating UyDosh "U" glyph used for map-loading states, where the loader
/// must match the map's own light/dark tint (black "U" over the light map
/// style, white "U" over the night map style) rather than the app theme.
///
/// Unlike [UydoshLogoSpinner] (which always renders the fixed dark brand
/// mark), this widget tints the bare `u_letter.svg` glyph with [color] so it
/// stays legible against either map style.
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
        child: SvgPicture.asset(
          "assets/icon/components/u_letter.svg",
          width: widget.size,
          height: widget.size,
          colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
