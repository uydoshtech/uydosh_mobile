import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

/// Frosted bar behind a transparent [AppBar] toolbar (main shell, blue theme).
class LiquidGlassAppBarFlexibleSpace extends StatelessWidget {
  const LiquidGlassAppBarFlexibleSpace({super.key});

  static const BorderRadius _bottomRadius = BorderRadius.vertical(
    bottom: Radius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _bottomRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _bottomRadius,
            color: BlueThemeColors.background.withValues(alpha: 0.44),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.10),
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
