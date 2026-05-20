import "dart:ui" show ImageFilter, TileMode;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";

/// Shared liquid-glass rendering helpers (drawer, bottom sheets, plates).
///
/// On web, [BackdropFilter] only works reliably with the CanvasKit renderer
/// (see [web/flutter_bootstrap.js]). Use semi-transparent theme tints on top
/// of the blur — never opaque black/white slabs.
abstract final class LiquidGlassRendering {
  LiquidGlassRendering._();

  static ImageFilter blurFilter(double sigma) => ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.clamp,
      );

  /// Frosted-glass blur is structural UI chrome — not a decorative animation.
  /// Only respect the platform reduce-motion / disable-animations flag.
  static bool effectsEnabled(BuildContext context) =>
      !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);

  /// Drawer / bottom-sheet blur strength.
  static const double panelBlurSigma = 22;

  /// Smaller controls (filter ribbon, FAB) sitting on blurred surfaces.
  static const double plateBlurSigma = 14;

  /// Neumorphic top-left highlight strength (listing cards, 3D buttons).
  static double neumorphicLightShadowAlpha(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!kIsWeb) return isDark ? 0.06 : 0.65;
    return isDark ? 0.04 : 0.65;
  }

  /// Gradient for [LiquidGlassPlate] and similar controls.
  static LinearGradient plateGradient({
    required BuildContext context,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surface;
    final surfaceTint =
        Color.lerp(base, theme.colorScheme.primary, 0.10) ?? base;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: isDark ? 0.08 : 0.46),
        surfaceTint.withValues(alpha: isDark ? 0.28 : 0.74),
        base.withValues(alpha: isDark ? 0.18 : 0.64),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  /// Gradient for large panels (bottom sheets).
  static LinearGradient panelGradient({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final baseSurface = isDark ? Colors.black : scheme.surface;
    final surfaceTint =
        Color.lerp(baseSurface, scheme.primary, isDark ? 0.06 : 0.08) ??
            baseSurface;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: isDark ? 0.05 : 0.22),
        surfaceTint.withValues(alpha: isDark ? 0.22 : 0.30),
        baseSurface.withValues(alpha: isDark ? 0.22 : 0.28),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Solid tint for the navigation drawer.
  static Color panelFillColor(Color base, {required bool isDark}) {
    return base.withValues(alpha: isDark ? 0.32 : 0.48);
  }

  /// Subtle lit edge on drawer / sheet panels.
  static Color panelBorderColor(Color tint) =>
      Color.lerp(tint, Colors.white, 0.65)!.withValues(alpha: 0.55);

  /// App bar / footer chrome tint.
  static Color chromeFillColor(Color base, {required bool isDark}) {
    return base.withValues(alpha: isDark ? 0.44 : 0.32);
  }

  static double chromeSheenAlpha({required bool isDark}) =>
      isDark ? 0.08 : 0.05;

  /// Nested tile fill (e.g. create-choice rows inside a sheet).
  static double nestedTileFillAlpha({required bool isDark}) =>
      isDark ? 0.28 : 0.55;

  static double navigationBarAlpha(double nativeAlpha) => nativeAlpha;

  static Widget backdropBlur({
    required bool enabled,
    required double sigma,
    required Widget child,
  }) {
    if (!enabled || sigma <= 0) return child;
    return BackdropFilter(
      filter: blurFilter(sigma),
      child: child,
    );
  }

  static Widget backdropSaturationAndBlur({
    required bool enabled,
    required double sigma,
    required List<double> saturationMatrix,
    required Widget child,
  }) {
    if (!enabled) return child;
    return BackdropFilter(
      filter: ColorFilter.matrix(saturationMatrix),
      child: backdropBlur(enabled: true, sigma: sigma, child: child),
    );
  }
}
