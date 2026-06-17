import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
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
    /// When true, fills with the highlight (top-left) tone from [ThreeDSurfaceStyle.surfaceGradient]
    /// instead of the diagonal gradient — reads as a single flat face.
    this.useFlatHighlightColor = false,
    /// Frosted glass matching the messages inbox tab switch thumb.
    this.useLiquidGlass = false,
  });

  final Color baseColor;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final bool useFlatHighlightColor;
  final bool useLiquidGlass;

  @override
  Widget build(BuildContext context) {
    if (useLiquidGlass) {
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      final enableGlass = AnimationSettingsState().uiAnimationsEnabled &&
          !disableAnimations;

      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: LiquidGlassRendering.switchThumbGlassShadows(),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: LiquidGlassRendering.backdropBlur(
            enabled: enableGlass,
            sigma: LiquidGlassRendering.switchGlassBlurSigma,
            child: DecoratedBox(
              decoration: LiquidGlassRendering.switchThumbGlassDecoration(
                tintColor: baseColor,
                borderRadius: borderRadius,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final flatHighlight = Color.lerp(
      baseColor,
      scheme.onSurface,
      Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.03,
    )!;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: useFlatHighlightColor ? flatHighlight : null,
        gradient:
            useFlatHighlightColor ? null : ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
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
