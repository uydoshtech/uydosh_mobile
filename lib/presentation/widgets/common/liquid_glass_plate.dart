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
  });

  final Widget child;
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final double sigma;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    if (!ThemeState().usesLiquidGlassChrome) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: clipBehavior,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: theme.colorScheme.surface,
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: isDark ? 0.12 : 0.14,
                ),
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
              gradient: LiquidGlassRendering.plateGradient(
                context: context,
                isDark: isDark,
              ),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: isDark ? 0.12 : 0.14,
                ),
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
