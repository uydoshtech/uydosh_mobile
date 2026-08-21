/// Imperative bridge for a parent CTA to open an existing dictation control.
/// The callback is attached only while its button is mounted.
class DictationTriggerController {
  void Function()? _start;

  void start() => _start?.call();

  void attach(void Function()? callback) => _start = callback;
}
