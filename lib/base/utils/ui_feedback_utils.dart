import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";

/// Pairs [HapticFeedbackUtils] with [SendSoundUtils] for settings-style controls.
///
/// Respects [HapticFeedbackState] and [SoundEffectsState] via the underlying helpers.
abstract final class UiFeedbackUtils {
  UiFeedbackUtils._();

  static DateTime? _lastSliderTick;

  /// Toggles, menu selections, dropdown commits, primary control taps.
  static void tap() {
    HapticFeedbackUtils.impact();
    SendSoundUtils.playSelectionSound();
  }

  /// Segmented controls, tabs, explicit single-option picks.
  static void selection() {
    HapticFeedbackUtils.selection();
    SendSoundUtils.playSelectionSound();
  }

  /// Dragging [Slider] / dense scrubbing. One shared throttle for haptic + audio.
  static void sliderTick({
    Duration minInterval = const Duration(milliseconds: 56),
  }) {
    final now = DateTime.now();
    if (_lastSliderTick != null &&
        now.difference(_lastSliderTick!) < minInterval) {
      return;
    }
    _lastSliderTick = now;
    HapticFeedbackUtils.selectionClick();
    SendSoundUtils.playSelectionSound();
  }
}
