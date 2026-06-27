part of "home_screen.dart";

class _HomeMapViewState {
  _SearchResultsView view = _SearchResultsView.list;
  SearchBottomSheetResult? result;

  Future<bool> activateInitialMapIfAllowed({
    required bool showMapInitially,
  }) async {
    if (!showMapInitially) return false;
    final canShowMap = await canShowMapView();
    if (!canShowMap) return false;
    view = _SearchResultsView.map;
    return true;
  }

  Future<bool> canShowMapView() async {
    final status = await Permission.location.status;
    return status.isGranted;
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
