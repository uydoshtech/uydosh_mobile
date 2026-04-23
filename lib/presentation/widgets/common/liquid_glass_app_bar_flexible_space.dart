import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

/// Frosted bar behind a transparent [AppBar] toolbar (main shell).
class LiquidGlassAppBarFlexibleSpace extends StatelessWidget {
  const LiquidGlassAppBarFlexibleSpace({super.key});

  static const BorderRadius _bottomRadius = BorderRadius.vertical(
    bottom: Radius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    // Keep the frosted tint anchored to the themed surface (not primary-tinted)
    // so the shell header reads the same on every tab regardless of body content.
    final baseTint = isDark ? BlueThemeColors.background : scheme.surface;

    // Light: slightly higher opacity so the bar matches the canvas behind the
    // shell (see ThemePalette.screenCanvasColor) instead of picking up pure
    // white from listing cards under the blur.
    final blurSigma = isDark ? 18.0 : 22.0;
    final tintAlpha = isDark ? 0.44 : 0.32;
    final sheenHigh = isDark ? 0.08 : 0.05;

    return ClipRRect(
      borderRadius: _bottomRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: _bottomRadius,
                color: baseTint.withValues(alpha: tintAlpha),
                border: Border(
                  bottom: BorderSide(
                    color:
                        (isDark ? Colors.white : Colors.black).withValues(
                          alpha: isDark ? 0.10 : 0.08,
                        ),
                    width: 0.5,
                  ),
                ),
              ),
              child: const SizedBox.expand(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: _bottomRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: sheenHigh),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}
