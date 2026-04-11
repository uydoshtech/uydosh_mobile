import "package:flutter/material.dart";

/// Neumorphic-style elevation shared by [ThreeDPillButton] and listing-detail tiles.
abstract final class ThreeDSurfaceStyle {
  ThreeDSurfaceStyle._();

  static Color _darkShadowColor(BuildContext context) => Colors.black.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.20,
      );

  static Color _lightShadowColor(BuildContext context) => Colors.white.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.65,
      );

  static List<BoxShadow> elevatedShadows(BuildContext context) => [
        BoxShadow(
          color: _lightShadowColor(context),
          offset: const Offset(-3, -3),
          blurRadius: 10,
        ),
        BoxShadow(
          color: _darkShadowColor(context),
          offset: const Offset(6, 6),
          blurRadius: 14,
        ),
      ];

  static List<BoxShadow> pressedShadows(BuildContext context) => [
        BoxShadow(
          color: _darkShadowColor(context),
          offset: const Offset(2, 2),
          blurRadius: 8,
        ),
      ];

  /// Recessed / “pressed” look (e.g. selected language card). Uses negative
  /// [BoxShadow.spreadRadius] so shadows read as inside the rounded rect.
  static List<BoxShadow> insetRecessedShadows(BuildContext context) => [
        BoxShadow(
          color: _darkShadowColor(context),
          offset: const Offset(4, 4),
          blurRadius: 12,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: _lightShadowColor(context),
          offset: const Offset(-4, -4),
          blurRadius: 12,
          spreadRadius: -6,
        ),
      ];

  static LinearGradient surfaceGradient(BuildContext context, Color bg) {
    final scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          bg,
          scheme.onSurface,
          Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.03,
        )!,
        bg,
      ],
    );
  }

  /// Soft colored glow behind circular “orb” controls (search FAB, curved nav).
  static List<BoxShadow> floatingOrbHaloShadows(
    BuildContext context,
    Color base, {
    double depthScale = 1.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cool = Color.lerp(base, const Color(0xFF9EB7E8), 0.42)!;
    return [
      BoxShadow(
        color: cool.withValues(alpha: isDark ? 0.38 : 0.22),
        blurRadius: 26 * depthScale,
        spreadRadius: 1.8 * depthScale,
        offset: Offset(-5 * depthScale, -5 * depthScale),
      ),
      BoxShadow(
        color: Color.lerp(base, Colors.white, 0.5)!
            .withValues(alpha: isDark ? 0.16 : 0.12),
        blurRadius: 16 * depthScale,
        spreadRadius: 0.5 * depthScale,
        offset: Offset(-2 * depthScale, -3 * depthScale),
      ),
    ];
  }

  /// Base fill + neumorphic shadows for a raised circular face (matches search FAB).
  static BoxDecoration circularElevatedOrbDecoration(
    BuildContext context,
    Color base, {
    double depthScale = 1.0,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: surfaceGradient(context, base),
      boxShadow: [
        ...floatingOrbHaloShadows(context, base, depthScale: depthScale),
        ...elevatedShadows(context),
      ],
    );
  }

  /// Top-left specular wash on dark orb surfaces ([SearchFloatingActionButton]).
  static Gradient surfaceRadialHighlightGradient(Brightness brightness) {
    return RadialGradient(
      center: const Alignment(-0.55, -0.62),
      radius: 1.05,
      colors: [
        Colors.white.withValues(
          alpha: brightness == Brightness.dark ? 0.22 : 0.45,
        ),
        Colors.white.withValues(alpha: 0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.28, 0.52],
    );
  }

  /// Same corner radius as [ThreeDAppBarIconButton.kDefaultSquareRadius].
  static const double wheelPickerCornerRadius = 12;

  static const BorderRadius wheelPickerPlateRadius = BorderRadius.all(
    Radius.circular(wheelPickerCornerRadius),
  );

  /// Right strip inside wheel rows (arrow column) — matches plate corners.
  static const BorderRadius wheelPickerPlateArrowStripBorderRadius =
      BorderRadius.only(
        topRight: Radius.circular(wheelPickerCornerRadius),
        bottomRight: Radius.circular(wheelPickerCornerRadius),
      );

  /// Outer chrome for [CupertinoPicker] wheels: same gradient + shadows as [ThreeDPillButton].
  static BoxDecoration wheelPickerPlateDecoration(
    BuildContext context, {
    ThemeData? theme,
    bool showErrorBorder = false,
  }) {
    final t = theme ?? Theme.of(context);
    final plateBase = t.colorScheme.surface;
    return BoxDecoration(
      borderRadius: wheelPickerPlateRadius,
      gradient: surfaceGradient(context, plateBase),
      boxShadow: elevatedShadows(context),
      border: showErrorBorder
          ? Border.all(color: t.colorScheme.error, width: 1.5)
          : null,
    );
  }
}
