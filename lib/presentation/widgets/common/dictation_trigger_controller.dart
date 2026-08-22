/// Imperative bridge for a parent CTA to open an existing dictation control.
/// The callback is attached only while its button is mounted.
class DictationTriggerController {
  void Function()? _toggle;

  /// Starts a recording when idle and stops/transcribes it while recording.
  void toggle() => _toggle?.call();

  /// Backwards-compatible name for callers that only start recording.
  void start() => toggle();

  void attach(void Function()? callback) => _toggle = callback;
}
