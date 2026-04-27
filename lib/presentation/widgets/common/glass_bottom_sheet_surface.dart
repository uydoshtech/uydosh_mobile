import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";

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

    // Keep the "glass" readable in light theme by staying closer to surfaces.
    // In dark theme, bias to a darker tint to get the black/dark glass request.
    final baseSurface = isDark ? Colors.black : scheme.surface;
    final surfaceTint =
        Color.lerp(baseSurface, scheme.primary, isDark ? 0.06 : 0.08) ??
            baseSurface;

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
        child: BackdropFilter(
          filter: ColorFilter.matrix(
            _glassSaturationMatrix(saturation: isDark ? 1.6 : 1.8),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDark ? 34 : 40,
              sigmaY: isDark ? 34 : 40,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Specular, slightly milky highlight at the top.
                    Colors.white.withValues(alpha: isDark ? 0.05 : 0.22),
                    surfaceTint.withValues(alpha: isDark ? 0.22 : 0.30),
                    baseSurface.withValues(alpha: isDark ? 0.22 : 0.28),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.55),
                    width: 0.6,
                  ),
                ),
              ),
              child: padding != null ? Padding(padding: padding!, child: child) : child,
            ),
          ),
        ),
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

