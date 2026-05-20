import "package:flutter/foundation.dart";

/// Which gig hub feeds should refetch after a publish / delete signal.
class GigHubFeedsRefreshSignal {
  const GigHubFeedsRefreshSignal({
    this.refreshServices = true,
    this.refreshTasks = true,
  });

  final bool refreshServices;
  final bool refreshTasks;

  static const both = GigHubFeedsRefreshSignal();
  static const servicesOnly =
      GigHubFeedsRefreshSignal(refreshTasks: false);
  static const tasksOnly =
      GigHubFeedsRefreshSignal(refreshServices: false);
}

/// Fired when the unified gig publish flow closes or an offer/task is removed
/// from another screen so [GigHubScreen] can refetch feeds — otherwise the
/// embedded hub keeps stale rows until a manual refresh.
class GigHubFeedsRefreshNotifier extends ChangeNotifier {
  GigHubFeedsRefreshSignal _lastSignal = GigHubFeedsRefreshSignal.both;

  /// Scope of the most recent [requestRefresh] call. Listeners read this when
  /// handling [notifyListeners] so they can skip feeds that did not change.
  GigHubFeedsRefreshSignal get lastSignal => _lastSignal;

  void requestRefresh([
    GigHubFeedsRefreshSignal signal = GigHubFeedsRefreshSignal.both,
  ]) {
    _lastSignal = signal;
    notifyListeners();
  }
}
