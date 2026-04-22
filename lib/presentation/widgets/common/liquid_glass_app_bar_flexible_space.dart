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
    final baseTint =
        isDark
            ? BlueThemeColors.background
            : (Color.lerp(scheme.surface, scheme.primary, 0.06) ?? scheme.surface);

    return ClipRRect(
      borderRadius: _bottomRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _bottomRadius,
            color: baseTint.withValues(alpha: isDark ? 0.44 : 0.72),
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
      ),
    );
  }
}
