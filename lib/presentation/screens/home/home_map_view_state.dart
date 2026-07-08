part of "home_screen.dart";

class _HomeMapViewState {
  _SearchResultsView view = _SearchResultsView.list;
  SearchBottomSheetResult? result;
  List<Listing> initialMapListings = const [];
  int? initialMapTotal;

  /// Set when the map is opened targeting a specific listing (e.g. from the
  /// listing-detail screen's "Open map" button) so the embedded map can
  /// select and camera-focus that listing's pin once loaded.
  int? focusListingId;

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
    int? focusListingId,
  }) {
    result = nextResult;
    view = _SearchResultsView.map;
    this.focusListingId = focusListingId;
    if (initialMapListings != null) {
      this.initialMapListings = initialMapListings;
      this.initialMapTotal = initialMapTotal;
    }
  }

  void openFeed(SearchBottomSheetResult nextResult) {
    result = nextResult;
    view = _SearchResultsView.list;
    focusListingId = null;
  }

  void resetToList() {
    result = null;
    view = _SearchResultsView.list;
    focusListingId = null;
  }
}
