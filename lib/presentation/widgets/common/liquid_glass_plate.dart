import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// Lightweight “glass” plate for controls that sit on top of a blurred sheet.
///
/// Intentionally subtle: low shadow, thin border, and a gentle tint gradient.
class LiquidGlassPlate extends StatelessWidget {
  const LiquidGlassPlate({
    required this.child,
    super.key,
    this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.sigma = LiquidGlassRendering.plateBlurSigma,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
    this.mapNightModeEnabled,
  });

  final Widget child;
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final double sigma;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  final bool? mapNightModeEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapNightMode = mapNightModeEnabled;
    final isDark = mapNightMode ?? theme.brightness == Brightness.dark;
    final useMapOverlayStyle = mapNightMode != null;
    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
    final borderColor = useMapOverlayStyle
        ? LiquidGlassRendering.mapOverlayPlateBorderColor(
            mapNightModeEnabled: mapNightMode,
          )
        : (isDark ? Colors.white : Colors.black).withValues(
            alpha: isDark ? 0.12 : 0.14,
          );

    if (!ThemeState().usesLiquidGlassChrome) {
      final surfaceColor = useMapOverlayStyle
          ? (mapNightMode
              ? const Color(0xFF1E1E1E)
              : theme.colorScheme.surface)
          : theme.colorScheme.surface;
      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: clipBehavior,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: surfaceColor,
              border: Border.all(
                color: borderColor,
                width: 0.6,
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    final enableGlass = LiquidGlassRendering.effectsEnabled(context);
    final plateShadows = UiPerformancePolicy.solidColorsPreferredForDevice
        ? const <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
              blurRadius: isDark ? 14 : 12,
              spreadRadius: isDark ? 0.5 : 0.2,
              offset: const Offset(0, 6),
            ),
          ];
    final plateGradient = useMapOverlayStyle
        ? LiquidGlassRendering.mapOverlayPlateGradient(
            context: context,
            mapNightModeEnabled: mapNightMode,
          )
        : LiquidGlassRendering.plateGradient(
            context: context,
            isDark: isDark,
          );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: LiquidGlassRendering.backdropBlur(
          enabled: enableGlass,
          sigma: isDark ? sigma : (sigma + 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: plateGradient,
              border: Border.all(
                color: borderColor,
                width: 0.6,
              ),
              boxShadow: plateShadows,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
