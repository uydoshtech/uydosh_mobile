import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/platform_device.dart";

/// Central policy for expensive visual effects.
///
/// Android devices get the reduced-effects path by default because backdrop
/// blur, translucent layer blending, large soft shadows, and decorative
/// animation loops are the most common sources of raster-thread jank there.
abstract final class UiPerformancePolicy {
  UiPerformancePolicy._();

  static bool get reduceEffectsForDevice => isAndroidDevice;

  static bool mediaQueryDisablesAnimations(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  static bool decorativeAnimationsEnabled(BuildContext context) {
    return !reduceEffectsForDevice && !mediaQueryDisablesAnimations(context);
  }

  static bool backdropBlurEnabled(BuildContext context) {
    return decorativeAnimationsEnabled(context);
  }

  static bool complexShadowsEnabled(BuildContext context) {
    return !reduceEffectsForDevice;
  }

  static bool compactShadowsPreferred(BuildContext context) {
    return reduceEffectsForDevice;
  }

  static MediaQueryData reducedEffectsMediaQuery(MediaQueryData data) {
    if (!reduceEffectsForDevice) return data;
    return data.copyWith(disableAnimations: true);
  }
}

/// Uses Flutter's normal platform transitions except on reduced-effects
/// devices, where page routes swap immediately.
class UiPerformancePageTransitionsTheme extends PageTransitionsTheme {
  const UiPerformancePageTransitionsTheme();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (UiPerformancePolicy.reduceEffectsForDevice) return child;
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
