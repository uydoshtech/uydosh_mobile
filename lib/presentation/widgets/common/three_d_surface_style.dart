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
}
