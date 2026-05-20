import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// A reusable "liquid glass" surface for modal bottom sheets.
///
/// Designed to match the Search / Achievement bottom sheet visuals:
/// - transparent modal background + blurred backdrop
/// - subtle top specular highlight
/// - soft shadow lifting the sheet
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
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final enableGlass = LiquidGlassRendering.effectsEnabled(context);

    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: LiquidGlassRendering.panelGradient(
        scheme: scheme,
        isDark: isDark,
      ),
      border: Border(
        top: BorderSide(
          color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.55),
          width: 0.6,
        ),
      ),
    );

    final content =
        padding != null ? Padding(padding: padding!, child: child) : child;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: isDark ? 30 : 22,
            spreadRadius: isDark ? 2 : 1,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: enableGlass
            ? LiquidGlassRendering.backdropSaturationAndBlur(
                enabled: true,
                sigma: isDark ? 34 : 40,
                saturationMatrix: _glassSaturationMatrix(
                  saturation: isDark ? 1.6 : 1.8,
                ),
                child: DecoratedBox(decoration: decoration, child: content),
              )
            : DecoratedBox(decoration: decoration, child: content),
      ),
    );
  }
}

List<double> _glassSaturationMatrix({required double saturation}) {
  const lumR = 0.2126;
  const lumG = 0.7152;
  const lumB = 0.0722;
  final invSat = 1 - saturation;
  final r = invSat * lumR;
  final g = invSat * lumG;
  final b = invSat * lumB;
  return <double>[
    r + saturation, g, b, 0, 0,
    r, g + saturation, b, 0, 0,
    r, g, b + saturation, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
