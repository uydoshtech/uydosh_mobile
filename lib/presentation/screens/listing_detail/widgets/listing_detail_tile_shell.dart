import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Listing-detail tile using the same neumorphic shadow and surface gradient as
/// [ThreeDPillButton], with [ThemeData.cardTheme] margin, color, and shape.
class ListingDetailTileShell extends StatelessWidget {
  const ListingDetailTileShell({
    required this.child,
    super.key,
    this.clipBehavior = Clip.none,
    this.margin,
    this.useLiquidGlass = false,
  });

  final Widget child;
  final Clip clipBehavior;

  /// When null, uses [ThemeData.cardTheme.margin].
  final EdgeInsetsGeometry? margin;

  /// Frosted glass matching inbox chat tiles and alerts (blue/light themes).
  final bool useLiquidGlass;

  static BorderRadius _borderRadius(BuildContext context, ShapeBorder shape) {
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(Directionality.of(context));
    }
    return BorderRadius.circular(12);
  }

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final shape =
        cardTheme.shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        );
    final borderRadius = _borderRadius(context, shape);
    final effectiveMargin = margin ?? cardTheme.margin ?? EdgeInsets.zero;
    final surfaceColor =
        cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final themeState = ThemeState();
    final glassTintColor = themeState.primaryColor;

    final shell = useLiquidGlass
        ? ThreeDElevatedSurface(
            baseColor: glassTintColor,
            useLiquidGlass: true,
            borderRadius: borderRadius,
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: shape,
              clipBehavior: clipBehavior,
              child: child,
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: ThreeDSurfaceStyle.surfaceGradient(
                context,
                surfaceColor,
              ),
              boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
            ),
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: shape,
              clipBehavior: clipBehavior,
              child: child,
            ),
          );

    if (effectiveMargin == EdgeInsets.zero) return shell;
    return Padding(padding: effectiveMargin, child: shell);
  }
}
