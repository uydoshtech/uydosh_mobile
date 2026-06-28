import "dart:ui" show ImageFilter, TileMode;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/platform_device.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/feed_scroll_scope.dart";

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

  /// Frosted-glass blur is structural UI chrome, but still expensive on
  /// Android because it samples and blends the backdrop while scrolling.
  static bool effectsEnabled(BuildContext context) =>
      AnimationSettingsState().uiAnimationsEnabled &&
      UiPerformancePolicy.backdropBlurEnabled(context);

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
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return BoxDecoration(
        borderRadius: borderRadius,
        color: tintColor,
      );
    }

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
        if (!UiPerformancePolicy.solidColorsPreferredForDevice)
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
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).colorScheme.surface,
      );
    }

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
    if (UiPerformancePolicy.solidColorsPreferredForDevice) return const [];

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

  /// Backdrop blur on feed [ListingTile]s is visually subtle but extremely
  /// expensive on Android (each tile samples the layer behind it every frame
  /// while scrolling). Skip it on Android always, and on other platforms while
  /// the user is actively scrolling the feed.
  static bool feedTileBackdropBlurEnabled(BuildContext context) {
    if (!effectsEnabled(context)) return false;
    if (!AnimationSettingsState().uiAnimationsEnabled) return false;
    if (FeedScrollScope.isUserScrollingOf(context)) return false;
    return true;
  }

  /// Dual neumorphic shadows on every feed row add GPU overdraw during flings.
  /// Android feed tiles use a single, lighter drop shadow instead.
  static bool feedTileUseCompactShadows(BuildContext context) {
    return UiPerformancePolicy.compactShadowsPreferred(context);
  }

  static List<BoxShadow> feedTileCompactShadows(BuildContext context) {
    if (UiPerformancePolicy.solidColorsPreferredForDevice) return const [];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];
  }

  /// Neumorphic top-left highlight strength (listing cards, 3D buttons).
  static double neumorphicLightShadowAlpha(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!UiPerformancePolicy.complexShadowsEnabled(context)) {
      return isDark ? 0.04 : 0.18;
    }
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
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return LinearGradient(
        colors: [base, base],
      );
    }

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
      {required bool isDark}) {
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return scheme.surface;
    }
    return scheme.surface.withValues(alpha: isDark ? 0.82 : 0.90);
  }

  /// Gradient for large panels (bottom sheets).
  static LinearGradient panelGradient({
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final baseSurface = isDark ? Colors.black : scheme.surface;
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return LinearGradient(
        colors: [baseSurface, baseSurface],
      );
    }

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
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return base;
    }
    return base.withValues(alpha: isDark ? 0.32 : 0.48);
  }

  /// Subtle lit edge on drawer / sheet panels.
  static Color panelBorderColor(Color tint) =>
      UiPerformancePolicy.solidColorsPreferredForDevice
          ? Color.lerp(tint, Colors.white, 0.65)!
          : Color.lerp(tint, Colors.white, 0.65)!.withValues(alpha: 0.55);

  /// App bar / footer chrome tint.
  static Color chromeFillColor(Color base, {required bool isDark}) {
    if (UiPerformancePolicy.solidColorsPreferredForDevice) {
      return base;
    }
    return base.withValues(alpha: isDark ? 0.44 : 0.32);
  }

  static double chromeSheenAlpha({required bool isDark}) =>
      UiPerformancePolicy.solidColorsPreferredForDevice
          ? 0
          : isDark
              ? 0.08
              : 0.05;

  /// Nested tile fill (e.g. create-choice rows inside a sheet).
  static double nestedTileFillAlpha({required bool isDark}) =>
      UiPerformancePolicy.solidColorsPreferredForDevice
          ? 1
          : isDark
              ? 0.28
              : 0.55;

  static double navigationBarAlpha(double nativeAlpha) =>
      UiPerformancePolicy.solidColorsPreferredForDevice ? 1 : nativeAlpha;

  static Widget backdropBlur({
    required bool enabled,
    required double sigma,
    required Widget child,
  }) {
    if (!enabled || sigma <= 0 || isAndroidDevice) return child;
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
    if (!enabled || sigma <= 0 || isAndroidDevice) return child;
    return BackdropFilter(
      filter: ColorFilter.matrix(saturationMatrix),
      child: backdropBlur(enabled: true, sigma: sigma, child: child),
    );
  }
}
