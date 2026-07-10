/// Detects when more than one tab of the same origin is running this app by
/// broadcasting a presence announcement over a same-origin `BroadcastChannel`.
/// Whenever a tab observes a newer instance announcing itself, it treats
/// itself as superseded and reports revocation via [WebInstanceGuard.start]'s
/// `onRevoked` callback. A no-op on non-web platforms.
export "web_instance_guard_stub.dart"
    if (dart.library.html) "web_instance_guard_web.dart";
