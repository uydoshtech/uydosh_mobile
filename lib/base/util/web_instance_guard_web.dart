// ignore_for_file: avoid_web_libraries_in_flutter
import "dart:async";
import "dart:convert";
import "dart:html" as html;
import "dart:math";

/// Same-origin, cross-tab "who's the active instance" negotiation built on
/// `BroadcastChannel` (supported by every browser Flutter web targets).
///
/// Every *visible* tab announces `{instanceId, startedAtMs}` on start (and
/// again on every hidden→visible transition) and whenever it wants to
/// reclaim activity. Any tab that sees an announcement newer than its own
/// considers itself superseded and reports revocation. There is no server
/// round-trip involved — this is purely a same-device, same-browser courtesy
/// check, not a security boundary.
///
/// Announcing is gated on [html.Document.visibilityState] being `"visible"`
/// on purpose: a same-origin context that is backgrounded/hidden — Telegram's
/// in-app WebView after handing off to the system browser, a link-preview
/// crawler fetch, or a tab the user opened earlier and never switched back
/// to — must never be able to revoke the tab someone is actually looking at.
/// A hidden tab can still *be* revoked by a genuinely visible one; it just
/// can't cause a revocation itself until the user switches to it.
class WebInstanceGuard {
  WebInstanceGuard._();

  static final WebInstanceGuard instance = WebInstanceGuard._();

  static const _channelName = "uydosh_web_instance_guard";
  static const _typeAnnounce = "announce";

  html.BroadcastChannel? _channel;
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  StreamSubscription<html.Event>? _visibilitySubscription;
  void Function()? _onRevoked;
  String _instanceId = "";
  int _startedAtMs = 0;
  bool _revoked = false;

  bool get _isVisible => html.document.visibilityState == "visible";

  Future<void> start({required void Function() onRevoked}) async {
    _onRevoked = onRevoked;
    _instanceId = _generateInstanceId();
    _startedAtMs = DateTime.now().millisecondsSinceEpoch;
    _revoked = false;

    try {
      _channel = html.BroadcastChannel(_channelName);
    } catch (_) {
      // BroadcastChannel unsupported (very old/embedded WebView) — fail open
      // rather than blocking legitimate single-tab usage.
      return;
    }

    _messageSubscription = _channel!.onMessage.listen(_handleMessage);
    _visibilitySubscription = html.document.onVisibilityChange.listen((_) {
      if (_isVisible) _announce();
    });
    if (_isVisible) {
      _announce();
    }
  }

  String _generateInstanceId() {
    final random = Random();
    return "${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1 << 32)}";
  }

  void _announce() {
    _channel?.postMessage(jsonEncode({
      "type": _typeAnnounce,
      "instanceId": _instanceId,
      "startedAtMs": _startedAtMs,
    }));
  }

  void _handleMessage(html.MessageEvent event) {
    if (_revoked) return;
    final raw = event.data;
    if (raw is! String) return;

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      data = decoded;
    } catch (_) {
      return;
    }

    if (data["type"] != _typeAnnounce) return;
    final incomingId = data["instanceId"]?.toString() ?? "";
    if (incomingId == _instanceId || incomingId.isEmpty) return;

    final rawStartedAt = data["startedAtMs"];
    final incomingStartedAt = rawStartedAt is int
        ? rawStartedAt
        : int.tryParse("$rawStartedAt") ?? 0;

    final isNewer = incomingStartedAt > _startedAtMs ||
        (incomingStartedAt == _startedAtMs && incomingId.compareTo(_instanceId) > 0);
    if (isNewer) {
      _revoked = true;
      _onRevoked?.call();
    }
  }

  /// Re-announces this tab with a fresh timestamp so it becomes the "active"
  /// instance again; any other open tab will revoke itself in response. Used
  /// by the "use this tab" recovery action on the locked screen.
  void reclaim() {
    _revoked = false;
    _startedAtMs = DateTime.now().millisecondsSinceEpoch;
    _announce();
  }

  void dispose() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _visibilitySubscription?.cancel();
    _visibilitySubscription = null;
    _channel?.close();
    _channel = null;
  }
}
