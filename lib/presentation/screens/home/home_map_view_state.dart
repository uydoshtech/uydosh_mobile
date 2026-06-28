part of "home_screen.dart";

class _HomeMapViewState {
  _SearchResultsView view = _SearchResultsView.list;
  SearchBottomSheetResult? result;

  Future<bool> activateInitialMapIfRequested({
    required bool showMapInitially,
  }) async {
    if (!showMapInitially) return false;
    view = _SearchResultsView.map;
    return true;
  }

  void openMap(SearchBottomSheetResult nextResult) {
    result = nextResult;
    view = _SearchResultsView.map;
  }

  void openFeed(SearchBottomSheetResult nextResult) {
    result = nextResult;
    view = _SearchResultsView.list;
  }

  void resetToList() {
    result = null;
    view = _SearchResultsView.list;
  }
}
