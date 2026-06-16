import "dart:async" show unawaited;

import "package:flutter/services.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";

class HapticFeedbackUtils {
  static bool get _enabled => HapticFeedbackState().isEnabled;

  static void _run(Future<void> Function() feedback) {
    if (!_enabled) {
      return;
    }
    try {
      unawaited(feedback().catchError((_) {}));
    } catch (_) {
      // Haptics are optional feedback; they should never block the real action.
    }
  }

  /// A short chain of small selection ticks (Threads-style).
  ///
  /// Implemented as scheduled ticks so callers can fire-and-forget from sync
  /// handlers (e.g. Dismissible callbacks) without needing `await`.
  static void tapticChain({
    int ticks = 3,
    Duration interval = const Duration(milliseconds: 28),
  }) {
    if (!_enabled) {
      return;
    }
    if (ticks <= 0) {
      return;
    }
    for (var i = 0; i < ticks; i++) {
      Future.delayed(
        interval * i,
        () => _run(HapticFeedback.selectionClick),
      );
    }
  }

  /// Light haptic for general taps and interactions throughout the app.
  static void impact() {
    _run(HapticFeedback.lightImpact);
  }

  /// Light haptic for selection-style interactions (e.g. pickers, spinners).
  static void selection() {
    _run(HapticFeedback.selectionClick);
  }

  static void lightImpact() {
    _run(HapticFeedback.lightImpact);
  }

  static void selectionClick() {
    _run(HapticFeedback.selectionClick);
  }

  /// Strong haptic for splash logo animation only. Use sparingly.
  static void strongImpact() {
    _run(HapticFeedback.mediumImpact);
  }
}
