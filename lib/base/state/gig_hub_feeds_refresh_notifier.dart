import "package:flutter/foundation.dart";

/// Fired when the unified gig publish flow closes or an offer/task is removed
/// from another screen so [GigHubScreen] can refetch feeds — otherwise the
/// embedded hub keeps stale rows until a manual refresh.
class GigHubFeedsRefreshNotifier extends ChangeNotifier {
  void requestRefresh() => notifyListeners();
}
