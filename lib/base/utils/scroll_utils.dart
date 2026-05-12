import "dart:async";
import "package:flutter/material.dart";

/// Utility class for optimized scroll handling with throttling and memory management
class ScrollUtils {
  static const Duration _defaultThrottleDuration = Duration(milliseconds: 100);
  static const double _defaultScrollDelta = 200.0;

  /// Creates a throttled scroll listener that prevents excessive calls
  /// and manages memory efficiently
  static void Function() createThrottledScrollListener({
    required ScrollController scrollController,
    required VoidCallback onLoadMore,
    Duration throttleDuration = _defaultThrottleDuration,
    double scrollDelta = _defaultScrollDelta,
    bool Function()? shouldLoadMore,
  }) {
    Timer? throttleTimer;
    var isLoadingMore = false;

    return () {
      // Early return if already loading more
      if (isLoadingMore) return;

      final currentScroll = scrollController.position.pixels;
      final maxScroll = scrollController.position.maxScrollExtent;

      // Check if we're near the bottom
      if (currentScroll >= maxScroll - scrollDelta) {
        // Check if we should load more (optional custom logic)
        if (shouldLoadMore != null && !shouldLoadMore()) return;

        isLoadingMore = true;

        // Use throttling to prevent excessive calls
        throttleTimer?.cancel();
        throttleTimer = Timer(throttleDuration, () {
          // Use post-frame callback for better performance
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              onLoadMore();
              // Reset loading state after successful load more call
              isLoadingMore = false;
            } catch (e) {
              // Reset loading state on error
              isLoadingMore = false;
            }
          });
        });
      }
    };
  }

  /// Creates a throttled scroll listener with external reset capability
  /// Returns both the listener and a reset function
  static ({VoidCallback listener, VoidCallback resetLoadingState})
  createThrottledScrollListenerWithReset({
    required ScrollController scrollController,
    required VoidCallback onLoadMore,
    Duration throttleDuration = _defaultThrottleDuration,
    double scrollDelta = _defaultScrollDelta,
    bool Function()? shouldLoadMore,
  }) {
    Timer? throttleTimer;
    var isLoadingMore = false;

    void listener() {
      // Early return if already loading more
      if (isLoadingMore) return;

      final currentScroll = scrollController.position.pixels;
      final maxScroll = scrollController.position.maxScrollExtent;

      // Check if we're near the bottom
      if (currentScroll >= maxScroll - scrollDelta) {
        // Check if we should load more (optional custom logic)
        if (shouldLoadMore != null && !shouldLoadMore()) return;

        isLoadingMore = true;

        // Use throttling to prevent excessive calls
        throttleTimer?.cancel();
        throttleTimer = Timer(throttleDuration, () {
          // Use post-frame callback for better performance
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              onLoadMore();
              // Reset loading state after successful load more call
              isLoadingMore = false;
            } catch (e) {
              // Reset loading state on error
              isLoadingMore = false;
            }
          });
        });
      }
    }

    void resetLoadingState() {
      isLoadingMore = false;
      throttleTimer?.cancel();
    }

    return (listener: listener, resetLoadingState: resetLoadingState);
  }

  /// Resets the loading state for a scroll listener
  /// Call this when the loading operation completes
  static void resetScrollLoadingState(VoidCallback resetCallback) {
    resetCallback();
  }

  /// Disposes [controller]. When a listener was registered with
  /// [ScrollController.addListener], pass it here so it is removed before dispose.
  static void disposeScrollController(
    ScrollController controller, [
    VoidCallback? listener,
  ]) {
    if (listener != null) {
      controller.removeListener(listener);
    }
    controller.dispose();
  }
}
