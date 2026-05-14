import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";

/// Visual recipe for [LiquidGlassPlate] — [segmentedTrack] is a deeper frosted
/// pill used behind sliding thumbs (e.g. Services / Tasks switch).
enum LiquidGlassPlateVariant {
  standard,
  segmentedTrack,
}

/// Lightweight “glass” plate for controls that sit on top of a blurred sheet.
///
/// Intentionally subtle: low shadow, thin border, and a gentle tint gradient.
class LiquidGlassPlate extends StatelessWidget {
  const LiquidGlassPlate({
    required this.child,
    super.key,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.sigma = 14,
    this.variant = LiquidGlassPlateVariant.standard,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final double? height;
  final BorderRadius borderRadius;
  final double sigma;
  final LiquidGlassPlateVariant variant;
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
    final isSegmentedTrack =
        variant == LiquidGlassPlateVariant.segmentedTrack;
    final baseBlur = isSegmentedTrack ? (isDark ? 18.0 : sigma + 2) : sigma;
    final blurSigma = enableGlass
        ? (isDark ? baseBlur : baseBlur + 4)
        : 0.0;

    final deepNavy = Color.lerp(
          theme.colorScheme.primary,
          const Color(0xFF050810),
          0.78,
        ) ??
        theme.colorScheme.primary;

    final LinearGradient gradient;
    final Color borderColor;
    final double borderWidth;
    final List<BoxShadow> shadows;

    if (isSegmentedTrack) {
      if (isDark) {
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            deepNavy.withValues(alpha: 0.48),
            deepNavy.withValues(alpha: 0.62),
          ],
          stops: const [0.0, 0.52, 1.0],
        );
        borderColor = Colors.white.withValues(alpha: 0.16);
        borderWidth = 0.7;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 16,
            spreadRadius: 0.2,
            offset: const Offset(0, 7),
          ),
        ];
      } else {
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.52),
            surfaceTint.withValues(alpha: 0.62),
            theme.colorScheme.surface.withValues(alpha: 0.72),
          ],
          stops: const [0.0, 0.52, 1.0],
        );
        borderColor = Colors.black.withValues(alpha: 0.10);
        borderWidth = 0.65;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 12,
            spreadRadius: 0.15,
            offset: const Offset(0, 5),
          ),
        ];
      }
    } else {
      gradient = LinearGradient(
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
      );
      borderColor = (isDark ? Colors.white : Colors.black).withValues(
        alpha: isDark ? 0.12 : 0.14,
      );
      borderWidth = 0.6;
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
          blurRadius: isDark ? 14 : 12,
          spreadRadius: isDark ? 0.5 : 0.2,
          offset: const Offset(0, 6),
        ),
      ];
    }

    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: gradient,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: shadows,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

