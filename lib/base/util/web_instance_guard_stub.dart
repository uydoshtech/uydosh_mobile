/// Non-web platforms have no notion of "another browser tab", so this guard
/// is entirely inert here.
class WebInstanceGuard {
  WebInstanceGuard._();

  static final WebInstanceGuard instance = WebInstanceGuard._();

  Future<void> start({required void Function() onRevoked}) async {}

  void reclaim() {}

  void dispose() {}
}
