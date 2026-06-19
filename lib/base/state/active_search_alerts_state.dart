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
  int _enabledAlertsCount = 0;
  int _celebrationTick = 0;
  bool _hasHydratedFromServer = false;
  List<SearchAlert>? _cachedAlerts;

  bool get hasActiveEnabledAlerts => _hasActiveEnabledAlerts;
  int get enabledAlertsCount => _enabledAlertsCount;

  /// Last alert list from [refresh] or [syncFromAlerts], for duplicate checks
  /// without an extra API round trip.
  List<SearchAlert>? get cachedAlerts => _cachedAlerts;

  /// Increments when the number of enabled alerts increases (used to trigger UI
  /// celebration animations like the header bell shake).
  int get celebrationTick => _celebrationTick;

  /// Triggers a one-off celebration animation for UI elements (e.g. header bell)
  /// when we already *know* an alert was created successfully, without waiting
  /// for eventual consistency in `listAlerts()`.
  void bumpCelebration() {
    _celebrationTick++;
    notifyListeners();
    logger.d("ActiveSearchAlertsState: bumpCelebration -> tick=$_celebrationTick");
  }

  /// Updates from a list already loaded in the UI (avoids an extra round trip).
  void syncFromAlerts(Iterable<SearchAlert> alerts) {
    _cachedAlerts = alerts is List<SearchAlert>
        ? List<SearchAlert>.from(alerts)
        : alerts.toList();
    final enabledCount = alerts.where((a) => a.enabled).length;
    final has = enabledCount > 0;

    final countChanged = _enabledAlertsCount != enabledCount;
    final hasChanged = _hasActiveEnabledAlerts != has;

    // Auto-celebrate when the user gains enabled alerts (e.g. adds a new alert),
    // but not on the first server hydration (avoids shake on cold start).
    if (_hasHydratedFromServer && enabledCount > _enabledAlertsCount) {
      _celebrationTick++;
    }
    _hasHydratedFromServer = true;

    if (!countChanged && !hasChanged) return;
    _enabledAlertsCount = enabledCount;
    _hasActiveEnabledAlerts = has;
    notifyListeners();
    logger.d(
      "ActiveSearchAlertsState: syncFromAlerts -> has=$has enabledCount=$enabledCount tick=$_celebrationTick",
    );
  }

  /// Fetches alerts from the API. No-op when not authenticated.
  Future<void> refresh() async {
    if (!AuthenticationState().isAuthenticated) {
      if (_hasActiveEnabledAlerts ||
          _enabledAlertsCount != 0 ||
          _cachedAlerts != null) {
        _hasActiveEnabledAlerts = false;
        _enabledAlertsCount = 0;
        _cachedAlerts = null;
        _hasHydratedFromServer = false;
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
