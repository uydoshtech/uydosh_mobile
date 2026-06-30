part of "../search_results_map_screen.dart";

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
    required this.selectedListingGroupIds,
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
    required this.placeViewToggleAtBottom,
    required this.mapBottomInset,
    required this.viewToggleBottom,
    required this.searchButtonBottom,
  });

  final _SearchMapResult result;
  final bool hasSearchFilters;
  final bool showFilterRibbon;
  final int? locationId;
  final List<UniversityMapMarker> universityMarkers;
  final String? userUniversityMarkerId;
  final int? selectedListingId;
  final List<int> selectedListingGroupIds;
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
  final bool placeViewToggleAtBottom;
  final double mapBottomInset;
  final double viewToggleBottom;
  final double searchButtonBottom;

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
            _intListsEqual(selectedListingGroupIds, other.selectedListingGroupIds) &&
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
            placeViewToggleAtBottom == other.placeViewToggleAtBottom &&
            mapBottomInset == other.mapBottomInset &&
            viewToggleBottom == other.viewToggleBottom &&
            searchButtonBottom == other.searchButtonBottom;
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
        Object.hashAll(selectedListingGroupIds),
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
        placeViewToggleAtBottom,
        mapBottomInset,
        viewToggleBottom,
        searchButtonBottom,
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
    required this.selectedPinGroup,
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
  final ListingMapPin? selectedPin;
  final List<ListingMapPin> selectedPinGroup;
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
            selectedPin == other.selectedPin &&
            identical(selectedPinGroup, other.selectedPinGroup) &&
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
            hasEmbeddedSearch == other.hasEmbeddedSearch;
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
        selectedPin,
        selectedPinGroup,
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

bool _intSetsEqual(Set<int> a, Set<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final value in a) {
    if (!b.contains(value)) return false;
  }
  return true;
}
