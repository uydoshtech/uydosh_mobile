import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Static, non-animated version of the splash logo.
///
/// Renders the same composition produced at the end of [AnimatedSvgLogo]'s
/// timeline — square + white U letter + red roof + white chimney — all in
/// their final resting positions. Use this where the splash branding is
/// needed without the intro animation (e.g. quick re-entries, previews,
/// embedded headers).
class QuickSplashLogo extends StatelessWidget {
  const QuickSplashLogo({super.key, this.size = 100.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size * 1.5,
        height: size * 1.5,
        child: Stack(
          children: [
            Positioned(
              top: size * 0.25,
              left: size * 0.25,
              right: size * 0.25,
              bottom: size * 0.25,
              child: SvgPicture.asset(
                "assets/icon/components/square.svg",
                width: size * 1.44,
                height: size * 1.44,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF00426E),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => SizedBox(
                  width: size * 1.44,
                  height: size * 1.44,
                  child: const Center(
                    child: Text(
                      "Square",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size * 0.25,
              left: size * 0.25,
              right: size * 0.25,
              bottom: size * 0.25,
              child: SvgPicture.asset(
                "assets/icon/components/u_letter.svg",
                width: size * 1.92,
                height: size * 1.44,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => SizedBox(
                  width: size * 1.92,
                  height: size * 1.44,
                  child: const Center(
                    child: Text(
                      "U",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size * 0.25,
              left: size * 0.25,
              right: size * 0.25,
              bottom: size * 0.25,
              child: SvgPicture.asset(
                "assets/icon/components/red_roof.svg",
                width: size * 2.16,
                height: size * 0.96,
                colorFilter: const ColorFilter.mode(
                  Color.fromRGBO(255, 0, 0, 1.0),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => SizedBox(
                  width: size * 2.16,
                  height: size * 0.96,
                  child: const Center(
                    child: Text(
                      "Roof",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size * 0.25,
              left: size * 0.25,
              right: size * 0.25,
              bottom: size * 0.25,
              child: SvgPicture.asset(
                "assets/icon/components/chimney.svg",
                width: size * 1.44,
                height: size * 1.44,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => SizedBox(
                  width: size * 1.44,
                  height: size * 1.44,
                  child: const Center(
                    child: Text(
                      "Chimney",
                      style: TextStyle(color: Colors.grey, fontSize: 8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
