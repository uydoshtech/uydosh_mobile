import "package:flutter/services.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";

class HapticFeedbackUtils {
  static bool get _enabled => HapticFeedbackState().isEnabled;

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
      Future.delayed(interval * i, HapticFeedback.selectionClick);
    }
  }

  /// Light haptic for general taps and interactions throughout the app.
  static void impact() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.lightImpact();
  }

  /// Light haptic for selection-style interactions (e.g. pickers, spinners).
  static void selection() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  static void lightImpact() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.lightImpact();
  }

  static void selectionClick() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  /// Strong haptic for splash logo animation only. Use sparingly.
  static void strongImpact() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.mediumImpact();
  }
}
