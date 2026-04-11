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
