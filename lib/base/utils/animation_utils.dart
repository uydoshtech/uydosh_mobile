import 'package:flutter/material.dart';

/// Utility class for optimized animation controller management
class AnimationUtils {
  /// Creates an animation controller with proper lifecycle management
  static AnimationController createAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
      lowerBound: lowerBound,
      upperBound: upperBound,
    );
  }

  /// Safely disposes of an animation controller
  static void disposeAnimationController(AnimationController? controller) {
    if (controller != null) {
      try {
        controller.dispose();
      } catch (e) {
        // Controller might already be disposed
        debugPrint('Animation controller disposal error: $e');
      }
    }
  }

  /// Disposes of multiple animation controllers safely
  static void disposeAnimationControllers(
    List<AnimationController> controllers,
  ) {
    for (final controller in controllers) {
      disposeAnimationController(controller);
    }
  }

  /// Disposes of animation controllers stored in a map
  static void disposeAnimationControllerMap(
    Map<dynamic, AnimationController> controllers,
  ) {
    for (final controller in controllers.values) {
      disposeAnimationController(controller);
    }
    controllers.clear();
  }

  /// Creates a scale animation with optimized curves
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 1.0,
    double end = 1.3,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// Creates a fade animation with optimized curves
  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// Safely plays an animation with error handling
  static Future<void> safePlayAnimation(
    AnimationController controller, {
    bool forward = true,
  }) async {
    try {
      if (forward) {
        await controller.forward();
      } else {
        await controller.reverse();
      }
    } catch (e) {
      // Handle animation errors gracefully
      debugPrint('Animation error: $e');
    }
  }
}
