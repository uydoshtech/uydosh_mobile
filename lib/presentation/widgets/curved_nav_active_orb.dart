import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Orb gradient + neumorphic depth + specular wash (no outer halo — unlike FAB).
///
/// Diameter matches the stock bar (28px icon + 8px [Padding] on each side ≈ 44).
/// Slight downward shift brings the disk back toward the curved bar like pre-3D.
class CurvedNavActiveOrb extends StatelessWidget {
  const CurvedNavActiveOrb({
    required this.baseColor,
    required this.child,
    super.key,
  });

  final Color baseColor;
  final Widget child;

  static const double _diameter = 44;

  /// Nudges the active disk toward the menu curve (package [Material] read smaller).
  static const double _nudgeTowardCurveY = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(0, _nudgeTowardCurveY),
      child: SizedBox(
        width: _diameter,
        height: _diameter,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    baseColor,
                  ),
                  boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ThreeDSurfaceStyle.surfaceRadialHighlightGradient(
                    theme.brightness,
                  ),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
