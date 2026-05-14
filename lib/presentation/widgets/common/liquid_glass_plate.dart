import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";

/// Lightweight “glass” plate for controls that sit on top of a blurred sheet.
///
/// Intentionally subtle: low shadow, thin border, and a gentle tint gradient.
class LiquidGlassPlate extends StatelessWidget {
  const LiquidGlassPlate({
    required this.child,
    super.key,
    this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.sigma = 14,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final double sigma;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
    final surfaceTint =
        Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.10) ??
        theme.colorScheme.surface;

    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: enableGlass ? (isDark ? sigma : (sigma + 4)) : 0,
            sigmaY: enableGlass ? (isDark ? sigma : (sigma + 4)) : 0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.08 : 0.46),
                  surfaceTint.withValues(alpha: isDark ? 0.28 : 0.74),
                  theme.colorScheme.surface.withValues(
                    alpha: isDark ? 0.18 : 0.64,
                  ),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: isDark ? 0.12 : 0.14,
                ),
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
                  blurRadius: isDark ? 14 : 12,
                  spreadRadius: isDark ? 0.5 : 0.2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

