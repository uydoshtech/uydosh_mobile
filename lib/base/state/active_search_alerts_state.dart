import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/domain/models/search_alert.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";

/// Whether the signed-in user has at least one **enabled** saved search alert.
/// Used for the main app bar bell (solid vs outline).
class ActiveSearchAlertsState extends ChangeNotifier {
  factory ActiveSearchAlertsState() => _instance;
  ActiveSearchAlertsState._internal();
  static final ActiveSearchAlertsState _instance =
      ActiveSearchAlertsState._internal();

  bool _hasActiveEnabledAlerts = false;

  bool get hasActiveEnabledAlerts => _hasActiveEnabledAlerts;

  /// Updates from a list already loaded in the UI (avoids an extra round trip).
  void syncFromAlerts(Iterable<SearchAlert> alerts) {
    final has = alerts.any((a) => a.enabled);
    if (_hasActiveEnabledAlerts == has) return;
    _hasActiveEnabledAlerts = has;
    notifyListeners();
    logger.d("ActiveSearchAlertsState: syncFromAlerts -> $has");
  }

  /// Fetches alerts from the API. No-op when not authenticated.
  Future<void> refresh() async {
    if (!AuthenticationState().isAuthenticated) {
      if (_hasActiveEnabledAlerts) {
        _hasActiveEnabledAlerts = false;
        notifyListeners();
        logger.d("ActiveSearchAlertsState: cleared (signed out)");
      }
      return;
    }
    try {
      final alerts = await getIt<ISearchAlertService>().listAlerts();
      syncFromAlerts(alerts);
    } catch (e) {
      logger.d("ActiveSearchAlertsState: refresh failed: $e");
    }
  }
}
