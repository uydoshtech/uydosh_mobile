import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Rounded surface with [ThreeDSurfaceStyle] gradient and dual shadows.
/// Wraps [child] in transparent [Material] so [ListTile] ink splashes work.
class ThreeDElevatedSurface extends StatelessWidget {
  const ThreeDElevatedSurface({
    required this.baseColor,
    required this.child,
    super.key,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final Color baseColor;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
