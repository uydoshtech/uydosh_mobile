import "package:flutter/services.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";

class HapticFeedbackUtils {
  static const Duration _burstWindow = Duration(milliseconds: 600);
  static DateTime? _lastTriggerAt;
  static int _burstCount = 0;

  static bool get _enabled => HapticFeedbackState().isEnabled;

  static void impact() {
    if (!_enabled) {
      return;
    }
    _updateBurstCount();
    if (_burstCount == 1) {
      HapticFeedback.mediumImpact();
      return;
    }
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    if (!_enabled) {
      return;
    }
    _updateBurstCount();
    if (_burstCount == 1) {
      HapticFeedback.lightImpact();
      return;
    }
    if (_burstCount == 2) {
      HapticFeedback.mediumImpact();
      return;
    }
    HapticFeedback.heavyImpact();
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

  static void _updateBurstCount() {
    final now = DateTime.now();
    final lastTriggerAt = _lastTriggerAt;
    if (lastTriggerAt == null ||
        now.difference(lastTriggerAt) > _burstWindow) {
      _burstCount = 1;
    } else {
      _burstCount = (_burstCount + 1).clamp(1, 3);
    }
    _lastTriggerAt = now;
  }
}
