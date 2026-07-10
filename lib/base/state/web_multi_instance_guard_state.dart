import "package:flutter/foundation.dart";
import "package:uy_dosh/base/config/client_web_app_multiple_instance_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/web_instance_guard.dart";

/// Detects when the UyDosh web app is open in more than one browser tab at
/// once (via a same-origin `BroadcastChannel`) and flips [isRevoked] on every
/// tab except the most recently opened one. Gated by the server-backed
/// [ClientWebAppMultipleInstanceConfig] kill switch; a no-op on mobile/desktop
/// or whenever the flag is off.
class WebMultiInstanceGuardState extends ChangeNotifier {
  WebMultiInstanceGuardState._();

  static final WebMultiInstanceGuardState _instance =
      WebMultiInstanceGuardState._();

  factory WebMultiInstanceGuardState() => _instance;

  bool _revoked = false;
  bool _started = false;

  bool get isRevoked => _revoked;

  Future<void> startIfEnabled() async {
    if (_started) return;
    if (!kIsWeb) return;
    if (!ClientWebAppMultipleInstanceConfig.enabled.value) return;
    _started = true;
    try {
      await WebInstanceGuard.instance.start(onRevoked: _handleRevoked);
    } catch (e, st) {
      logger.d("WebMultiInstanceGuardState.startIfEnabled failed: $e\n$st");
    }
  }

  void _handleRevoked() {
    if (_revoked) return;
    _revoked = true;
    notifyListeners();
  }

  /// Reclaims this tab as the active instance (from the locked screen's
  /// "use this tab" action), unlocking here and revoking any other open tab.
  void reclaim() {
    WebInstanceGuard.instance.reclaim();
    if (!_revoked) return;
    _revoked = false;
    notifyListeners();
  }
}
