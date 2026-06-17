import "dart:ui" show ImageFilter, TileMode;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";

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

  /// Drawer blur strength.
  static const double panelBlurSigma = 22;

  /// Modal bottom sheets — lighter frost so content behind bleeds through.
  static const double bottomSheetBlurSigma = 14;

  /// Smaller controls (filter ribbon, FAB) sitting on blurred surfaces.
  static const double plateBlurSigma = 14;

  /// Backdrop blur on the messages inbox tab switch and matching glass tiles.
  static const double switchGlassBlurSigma = 18;

  /// Frosted fill for the active thumb on segmented switches and glass tiles.
  static BoxDecoration switchThumbGlassDecoration({
    required Color tintColor,
    required BorderRadius borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tintColor.withValues(alpha: 0.38),
          tintColor.withValues(alpha: 0.58),
        ],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.20),
        width: 0.6,
      ),
    );
  }

  static List<BoxShadow> switchThumbGlassShadows() => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 12,
          spreadRadius: 0.4,
          offset: const Offset(0, 4),
        ),
      ];

  /// Frosted glass for feed/detail tiles. Blue theme keeps the switch-thumb
  /// tint; light theme uses a pale [plateGradient] so tiles don't read as
  /// dark slabs on a white canvas.
  static BoxDecoration elevatedTileGlassDecoration({
    required BuildContext context,
    required BorderRadius borderRadius,
    required Color tintColor,
  }) {
    if (ThemeState().isLightTheme) {
      return BoxDecoration(
        borderRadius: borderRadius,
        gradient: plateGradient(context: context, isDark: false),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.14),
          width: 0.6,
        ),
      );
    }

    return switchThumbGlassDecoration(
      tintColor: tintColor,
      borderRadius: borderRadius,
    );
  }

  static double elevatedTileGlassBlurSigma(BuildContext context) {
    if (ThemeState().isLightTheme) {
      return plateBlurSigma + 4;
    }
    return switchGlassBlurSigma;
  }

  static List<BoxShadow> elevatedTileGlassShadows(BuildContext context) {
    if (ThemeState().isLightTheme) {
      final lightShadow = Colors.white.withValues(
        alpha: neumorphicLightShadowAlpha(context),
      );
      return [
        BoxShadow(
          color: lightShadow,
          offset: const Offset(-3, -3),
          blurRadius: 10,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.20),
          offset: const Offset(6, 6),
          blurRadius: 14,
        ),
      ];
    }
    return switchThumbGlassShadows();
  }

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

  /// Fallback fill when blur is off (reduce motion / accessibility).
  static Color bottomSheetFillColor(ColorScheme scheme,
          {required bool isDark}) =>
      scheme.surface.withValues(alpha: isDark ? 0.82 : 0.90);

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
        Colors.white.withValues(alpha: isDark ? 0.05 : 0.58),
        surfaceTint.withValues(alpha: isDark ? 0.22 : 0.72),
        baseSurface.withValues(alpha: isDark ? 0.22 : 0.68),
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
