import 'dart:async';
import 'package:flutter/material.dart';

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
    Timer? _throttleTimer;
    bool _isLoadingMore = false;

    return () {
      // Early return if already loading more
      if (_isLoadingMore) return;

      final currentScroll = scrollController.position.pixels;
      final maxScroll = scrollController.position.maxScrollExtent;

      // Check if we're near the bottom
      if (currentScroll >= maxScroll - scrollDelta) {
        // Check if we should load more (optional custom logic)
        if (shouldLoadMore != null && !shouldLoadMore()) return;

        _isLoadingMore = true;

        // Use throttling to prevent excessive calls
        _throttleTimer?.cancel();
        _throttleTimer = Timer(throttleDuration, () {
          // Use post-frame callback for better performance
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              onLoadMore();
              // Reset loading state after successful load more call
              _isLoadingMore = false;
            } catch (e) {
              // Reset loading state on error
              _isLoadingMore = false;
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
    Timer? _throttleTimer;
    bool _isLoadingMore = false;

    final listener = () {
      // Early return if already loading more
      if (_isLoadingMore) return;

      final currentScroll = scrollController.position.pixels;
      final maxScroll = scrollController.position.maxScrollExtent;

      // Check if we're near the bottom
      if (currentScroll >= maxScroll - scrollDelta) {
        // Check if we should load more (optional custom logic)
        if (shouldLoadMore != null && !shouldLoadMore()) return;

        _isLoadingMore = true;

        // Use throttling to prevent excessive calls
        _throttleTimer?.cancel();
        _throttleTimer = Timer(throttleDuration, () {
          // Use post-frame callback for better performance
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              onLoadMore();
              // Reset loading state after successful load more call
              _isLoadingMore = false;
            } catch (e) {
              // Reset loading state on error
              _isLoadingMore = false;
            }
          });
        });
      }
    };

    final resetLoadingState = () {
      _isLoadingMore = false;
      _throttleTimer?.cancel();
    };

    return (listener: listener, resetLoadingState: resetLoadingState);
  }

  /// Resets the loading state for a scroll listener
  /// Call this when the loading operation completes
  static void resetScrollLoadingState(VoidCallback resetCallback) {
    resetCallback();
  }

  /// Disposes of scroll controller and cleans up resources
  static void disposeScrollController(ScrollController controller) {
    controller.dispose();
  }
}
