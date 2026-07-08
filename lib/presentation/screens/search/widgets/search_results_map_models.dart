part of "../search_results_map_screen.dart";

class _SearchMapLayoutMetrics {
  const _SearchMapLayoutMetrics._();

  static const double listingTooltipGap = 8.0;
  static const double listingTooltipBottomMargin = 10.0;
  static const double listingTooltipHorizontalInset = 12.0;
  static const double singlePinTooltipFallbackHeight = 124.0;
  static const double embeddedSearchAboveShellInset = 55.0;
  static const double standaloneLocationBottomMargin = 8.0;
  static const Duration chromeShiftDuration = Duration(milliseconds: 220);
  static const Curve chromeShiftCurve = Curves.easeOutCubic;
}

double _listingTooltipLiftFor({
  required ListingMapPin? selectedPin,
  required double measuredHeight,
  required bool placeViewToggleAtBottom,
}) {
  if (selectedPin == null) return 0;
  const fallback = _SearchMapLayoutMetrics.singlePinTooltipFallbackHeight;
  final tooltipBlockHeight = (measuredHeight > 0 ? measuredHeight : fallback) +
      _SearchMapLayoutMetrics.listingTooltipGap +
      _SearchMapLayoutMetrics.listingTooltipBottomMargin;
  if (placeViewToggleAtBottom) {
    return (tooltipBlockHeight -
            _SearchMapLayoutMetrics.embeddedSearchAboveShellInset)
        .clamp(0.0, double.infinity);
  }
  return (tooltipBlockHeight -
          _SearchMapLayoutMetrics.standaloneLocationBottomMargin)
      .clamp(0.0, double.infinity);
}

class _SearchMapResult {
  const _SearchMapResult({
    required this.pins,
    required this.total,
    required this.mappableCount,
  });

  final List<ListingMapPin> pins;
  final int total;
  final int mappableCount;
}

class _PinMeta {
  const _PinMeta({
    required this.locationLabel,
    required this.stationLabel,
    required this.subwayLineIds,
  });

  final String? locationLabel;
  final String? stationLabel;
  final List<int> subwayLineIds;
}

class _MetroSummary {
  const _MetroSummary({required this.label, required this.lineIds});

  final String label;
  final List<int> lineIds;
}

/// Immutable snapshot driving [YandexMapWidget] rebuilds only.
@immutable
class _SearchMapCanvasProps {
  const _SearchMapCanvasProps({
    required this.result,
    required this.hasSearchFilters,
    required this.showFilterRibbon,
    required this.locationId,
    required this.universityMarkers,
    required this.userUniversityMarkerId,
    required this.selectedListingId,
    required this.visitedListingIds,
    required this.selectedUniversityMarkerId,
    required this.selectedUniversityZoomFocusId,
    required this.selectedMetroStationId,
    required this.showDistrictLayer,
    required this.metroLayerMode,
    required this.walkRadiusMinutes,
    required this.showUniversitiesLayer,
    required this.showGroceryStoresLayer,
    required this.showBusStopsLayer,
    required this.mapNightModeOverride,
    required this.userLocationRequestToken,
    required this.userLocationFocusToken,
    required this.userLocationLatitude,
    required this.userLocationLongitude,
    required this.focusListingToken,
    required this.focusListingLatitude,
    required this.focusListingLongitude,
    required this.placeViewToggleAtBottom,
    required this.mapBottomInset,
    required this.viewToggleBottom,
    required this.searchButtonBottom,
    required this.listingTooltipLift,
  });

  final _SearchMapResult result;
  final bool hasSearchFilters;
  final bool showFilterRibbon;
  final int? locationId;
  final List<UniversityMapMarker> universityMarkers;
  final String? userUniversityMarkerId;
  final int? selectedListingId;
  final Set<int> visitedListingIds;
  final String? selectedUniversityMarkerId;
  final String? selectedUniversityZoomFocusId;
  final int? selectedMetroStationId;
  final bool showDistrictLayer;
  final _MetroLayerMode metroLayerMode;
  final _WalkRadiusMinutes walkRadiusMinutes;
  final bool showUniversitiesLayer;
  final bool showGroceryStoresLayer;
  final bool showBusStopsLayer;
  final bool? mapNightModeOverride;
  final int userLocationRequestToken;
  final int userLocationFocusToken;
  final double? userLocationLatitude;
  final double? userLocationLongitude;
  final int focusListingToken;
  final double? focusListingLatitude;
  final double? focusListingLongitude;
  final bool placeViewToggleAtBottom;
  final double mapBottomInset;
  final double viewToggleBottom;
  final double searchButtonBottom;
  final double listingTooltipLift;

  bool get activeMapSearch => showFilterRibbon && hasSearchFilters;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _SearchMapCanvasProps &&
            result == other.result &&
            hasSearchFilters == other.hasSearchFilters &&
            showFilterRibbon == other.showFilterRibbon &&
            locationId == other.locationId &&
            identical(universityMarkers, other.universityMarkers) &&
            userUniversityMarkerId == other.userUniversityMarkerId &&
            selectedListingId == other.selectedListingId &&
            _intSetsEqual(visitedListingIds, other.visitedListingIds) &&
            selectedUniversityMarkerId == other.selectedUniversityMarkerId &&
            selectedUniversityZoomFocusId == other.selectedUniversityZoomFocusId &&
            selectedMetroStationId == other.selectedMetroStationId &&
            showDistrictLayer == other.showDistrictLayer &&
            metroLayerMode == other.metroLayerMode &&
            walkRadiusMinutes == other.walkRadiusMinutes &&
            showUniversitiesLayer == other.showUniversitiesLayer &&
            showGroceryStoresLayer == other.showGroceryStoresLayer &&
            showBusStopsLayer == other.showBusStopsLayer &&
            mapNightModeOverride == other.mapNightModeOverride &&
            userLocationRequestToken == other.userLocationRequestToken &&
            userLocationFocusToken == other.userLocationFocusToken &&
            userLocationLatitude == other.userLocationLatitude &&
            userLocationLongitude == other.userLocationLongitude &&
            focusListingToken == other.focusListingToken &&
            focusListingLatitude == other.focusListingLatitude &&
            focusListingLongitude == other.focusListingLongitude &&
            placeViewToggleAtBottom == other.placeViewToggleAtBottom &&
            mapBottomInset == other.mapBottomInset &&
            viewToggleBottom == other.viewToggleBottom &&
            searchButtonBottom == other.searchButtonBottom &&
            listingTooltipLift == other.listingTooltipLift;
  }

  @override
  int get hashCode => Object.hashAll([
        result,
        hasSearchFilters,
        showFilterRibbon,
        locationId,
        universityMarkers,
        userUniversityMarkerId,
        selectedListingId,
        Object.hashAll(visitedListingIds),
        selectedUniversityMarkerId,
        selectedUniversityZoomFocusId,
        selectedMetroStationId,
        showDistrictLayer,
        metroLayerMode,
        walkRadiusMinutes,
        showUniversitiesLayer,
        showGroceryStoresLayer,
        showBusStopsLayer,
        mapNightModeOverride,
        userLocationRequestToken,
        userLocationFocusToken,
        userLocationLatitude,
        userLocationLongitude,
        focusListingToken,
        focusListingLatitude,
        focusListingLongitude,
        placeViewToggleAtBottom,
        mapBottomInset,
        viewToggleBottom,
        searchButtonBottom,
        listingTooltipLift,
      ]);
}

/// Immutable snapshot driving map chrome overlays (no [YandexMapWidget]).
@immutable
class _SearchMapOverlayProps {
  const _SearchMapOverlayProps({
    required this.isLoading,
    required this.hasSearchFilters,
    required this.resultTotal,
    required this.listingTypeId,
    required this.gender,
    required this.locationId,
    required this.subwayStationId,
    required this.subwayStationIds,
    required this.subwayLineId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    required this.selectedPin,
    required this.visiblePins,
    required this.selectedUniversityMarker,
    required this.selectedMetroStation,
    required this.showDistrictLayer,
    required this.metroLayerMode,
    required this.walkRadiusMinutes,
    required this.showUniversitiesLayer,
    required this.mapNightModeOverride,
    required this.showLocationPrompt,
    required this.showUserLocationButton,
    required this.filterRibbonEnabled,
    required this.showFilterRibbon,
    required this.placeViewToggleAtBottom,
    required this.mapBottomInset,
    required this.searchButtonBottom,
    required this.viewToggleBottom,
    required this.hasEmbeddedSearch,
    required this.listingTooltipLift,
    this.has3dTour = false,
  });

  final bool isLoading;
  final bool hasSearchFilters;
  final int resultTotal;
  final int listingTypeId;
  final int? gender;
  final int? locationId;
  final int? subwayStationId;
  final List<int> subwayStationIds;
  final int? subwayLineId;
  final double minPrice;
  final double maxPrice;
  final bool privateRoom;
  final bool withPhoto;
  final bool has3dTour;
  final ListingMapPin? selectedPin;

  /// All pins currently visible on screen (map viewport), in stable result
  /// order, used to drive a swipeable carousel through them. Always includes
  /// [selectedPin] even if it has scrolled just outside the viewport.
  final List<ListingMapPin> visiblePins;
  final UniversityMapMarker? selectedUniversityMarker;
  final SubwayStation? selectedMetroStation;
  final bool showDistrictLayer;
  final _MetroLayerMode metroLayerMode;
  final _WalkRadiusMinutes walkRadiusMinutes;
  final bool showUniversitiesLayer;
  final bool? mapNightModeOverride;
  final bool showLocationPrompt;
  final bool showUserLocationButton;
  final bool filterRibbonEnabled;
  final bool showFilterRibbon;
  final bool placeViewToggleAtBottom;
  final double mapBottomInset;
  final double searchButtonBottom;
  final double viewToggleBottom;
  final bool hasEmbeddedSearch;
  final double listingTooltipLift;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _SearchMapOverlayProps &&
            isLoading == other.isLoading &&
            hasSearchFilters == other.hasSearchFilters &&
            resultTotal == other.resultTotal &&
            listingTypeId == other.listingTypeId &&
            gender == other.gender &&
            locationId == other.locationId &&
            subwayStationId == other.subwayStationId &&
            _intListsEqual(subwayStationIds, other.subwayStationIds) &&
            subwayLineId == other.subwayLineId &&
            minPrice == other.minPrice &&
            maxPrice == other.maxPrice &&
            privateRoom == other.privateRoom &&
            withPhoto == other.withPhoto &&
            has3dTour == other.has3dTour &&
            selectedPin == other.selectedPin &&
            _pinListsEqual(visiblePins, other.visiblePins) &&
            selectedUniversityMarker == other.selectedUniversityMarker &&
            selectedMetroStation == other.selectedMetroStation &&
            showDistrictLayer == other.showDistrictLayer &&
            metroLayerMode == other.metroLayerMode &&
            walkRadiusMinutes == other.walkRadiusMinutes &&
            showUniversitiesLayer == other.showUniversitiesLayer &&
            mapNightModeOverride == other.mapNightModeOverride &&
            showLocationPrompt == other.showLocationPrompt &&
            showUserLocationButton == other.showUserLocationButton &&
            filterRibbonEnabled == other.filterRibbonEnabled &&
            showFilterRibbon == other.showFilterRibbon &&
            placeViewToggleAtBottom == other.placeViewToggleAtBottom &&
            mapBottomInset == other.mapBottomInset &&
            searchButtonBottom == other.searchButtonBottom &&
            viewToggleBottom == other.viewToggleBottom &&
            hasEmbeddedSearch == other.hasEmbeddedSearch &&
            listingTooltipLift == other.listingTooltipLift;
  }

  @override
  int get hashCode => Object.hashAll([
        isLoading,
        hasSearchFilters,
        resultTotal,
        listingTypeId,
        gender,
        locationId,
        subwayStationId,
        Object.hashAll(subwayStationIds),
        subwayLineId,
        minPrice,
        maxPrice,
        privateRoom,
        withPhoto,
        has3dTour,
        selectedPin,
        Object.hashAll(visiblePins.map((pin) => pin.listingId)),
        selectedUniversityMarker,
        selectedMetroStation,
        showDistrictLayer,
        metroLayerMode,
        walkRadiusMinutes,
        showUniversitiesLayer,
        mapNightModeOverride,
        showLocationPrompt,
        showUserLocationButton,
        filterRibbonEnabled,
        showFilterRibbon,
        placeViewToggleAtBottom,
        mapBottomInset,
        searchButtonBottom,
        viewToggleBottom,
        hasEmbeddedSearch,
        listingTooltipLift,
      ]);
}

bool _intListsEqual(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _pinListsEqual(List<ListingMapPin> a, List<ListingMapPin> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].listingId != b[i].listingId) return false;
  }
  return true;
}

bool _intSetsEqual(Set<int> a, Set<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final value in a) {
    if (!b.contains(value)) return false;
  }
  return true;
}
