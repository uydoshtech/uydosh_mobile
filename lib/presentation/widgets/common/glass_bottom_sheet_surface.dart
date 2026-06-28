import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// Frosted-glass surface for modal bottom sheets (search, achievements, pickers, etc.).
class GlassBottomSheetSurface extends StatelessWidget {
  const GlassBottomSheetSurface({
    required this.child,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(20)),
    this.padding,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectsEnabled = LiquidGlassRendering.effectsEnabled(context);

    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: effectsEnabled
          ? LiquidGlassRendering.panelGradient(
              scheme: scheme,
              isDark: isDark,
            )
          : null,
      color: effectsEnabled
          ? null
          : LiquidGlassRendering.bottomSheetFillColor(
              scheme,
              isDark: isDark,
            ),
      border: Border(
        top: BorderSide(
          color: LiquidGlassRendering.panelBorderColor(scheme.surface),
          width: 0.6,
        ),
      ),
      boxShadow: UiPerformancePolicy.solidColorsPreferredForDevice
          ? LiquidGlassRendering.feedTileCompactShadows(context)
          : [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: isDark ? 0.28 : 0.18),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, -8),
              ),
            ],
    );

    final content =
        padding != null ? Padding(padding: padding!, child: child) : child;

    return ClipRRect(
      borderRadius: borderRadius,
      child: LiquidGlassRendering.backdropBlur(
        enabled: effectsEnabled,
        sigma: LiquidGlassRendering.bottomSheetBlurSigma,
        child: DecoratedBox(decoration: decoration, child: content),
      ),
    );
  }
}
