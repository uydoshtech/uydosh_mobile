part of "home_screen.dart";

class _HomeMapViewState {
  _SearchResultsView view = _SearchResultsView.list;
  SearchBottomSheetResult? result;
  List<Listing> initialMapListings = const [];
  int? initialMapTotal;

  Future<bool> activateInitialMapIfRequested({
    required bool showMapInitially,
    List<Listing> initialMapListings = const [],
    int? initialMapTotal,
  }) async {
    if (!showMapInitially) return false;
    view = _SearchResultsView.map;
    this.initialMapListings = initialMapListings;
    this.initialMapTotal = initialMapTotal;
    return true;
  }

  void openMap(
    SearchBottomSheetResult nextResult, {
    List<Listing>? initialMapListings,
    int? initialMapTotal,
  }) {
    result = nextResult;
    view = _SearchResultsView.map;
    if (initialMapListings != null) {
      this.initialMapListings = initialMapListings;
      this.initialMapTotal = initialMapTotal;
    }
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
