import "package:flutter/foundation.dart";

/// Fired when the unified gig publish flow closes so [GigHubScreen] can refetch
/// feeds — otherwise the hub keeps showing pre-push data until a manual refresh.
class GigHubFeedsRefreshNotifier extends ChangeNotifier {
  void requestRefresh() => notifyListeners();
}
