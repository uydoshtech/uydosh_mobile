import "dart:async" show unawaited;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/foundation.dart" show ValueListenable, ValueNotifier;
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart" as geo;
import "package:permission_handler/permission_handler.dart";
import "package:pointer_interceptor/pointer_interceptor.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/cache/university_cache.dart";
import "package:uy_dosh/base/config/client_map_layer_defaults_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/home_inline_search_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/platform_device.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_map_pin_data.dart";
import "package:uy_dosh/domain/search/resolved_listing_search_params.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/domain/search/search_filter_defaults.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/gender_badge.dart";
import "package:uy_dosh/presentation/widgets/common/applied_search_filters_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/search_floating_action_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

part "widgets/search_results_map_header.dart";
part "widgets/search_results_map_filter_ribbon.dart";
part "widgets/search_results_map_content.dart";
part "widgets/search_results_map_models.dart";
part "widgets/search_results_map_pin_summary.dart";
part "widgets/search_results_map_controls.dart";

enum _WalkRadiusMinutes {
  min10(10),
  min20(20),
  min30(30);

  const _WalkRadiusMinutes(this.minutes);

  final int minutes;

  _WalkRadiusMinutes get next {
    return switch (this) {
      _WalkRadiusMinutes.min10 => _WalkRadiusMinutes.min20,
      _WalkRadiusMinutes.min20 => _WalkRadiusMinutes.min30,
      _WalkRadiusMinutes.min30 => _WalkRadiusMinutes.min10,
    };
  }
}

enum _MetroLayerMode {
  off,
  line1,
  line2,
  line3,
  line4,
  all;

  int? get lineId {
    return switch (this) {
      _MetroLayerMode.line1 => 1,
      _MetroLayerMode.line2 => 2,
      _MetroLayerMode.line3 => 3,
      _MetroLayerMode.line4 => 4,
      _MetroLayerMode.off || _MetroLayerMode.all => null,
    };
  }

  bool get showsStations => this != _MetroLayerMode.off;

  _MetroLayerMode get next {
    return switch (this) {
      _MetroLayerMode.off => _MetroLayerMode.all,
      _MetroLayerMode.all => _MetroLayerMode.line1,
      _MetroLayerMode.line1 => _MetroLayerMode.line2,
      _MetroLayerMode.line2 => _MetroLayerMode.line3,
      _MetroLayerMode.line3 => _MetroLayerMode.line4,
      _MetroLayerMode.line4 => _MetroLayerMode.off,
    };
  }
}

class SearchResultsMapScreen extends StatefulWidget {
  const SearchResultsMapScreen({
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    super.key,
    this.listingTypeIds,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
    this.gender,
    this.onOpenFeed,
    this.embedded = false,
    this.initialListings = const [],
    this.initialTotal,
    this.embeddedMapBottomInset = 0,
    this.embeddedSearchButtonBottom = 125.0,
    this.embeddedViewToggleBottom = 181.2,
    this.onOpenEmbeddedSearch,
    this.onDismissFilterRibbon,
    this.feedListingsRevision = -1,
  });

  final int listingTypeId;
  final List<int>? listingTypeIds;
  final int? locationId;
  final int? subwayStationId;
  final List<int> subwayStationIds;
  final int? subwayLineId;
  final int? gender;
  final double minPrice;
  final double maxPrice;
  final bool privateRoom;
  final bool withPhoto;
  final void Function(
    BuildContext context,
    SearchBottomSheetResult result, {
    bool mapFilterRibbonDismissed,
  })? onOpenFeed;
  final bool embedded;
  final List<Listing> initialListings;
  final int? initialTotal;
  final double embeddedMapBottomInset;
  final double embeddedSearchButtonBottom;
  final double embeddedViewToggleBottom;
  final VoidCallback? onOpenEmbeddedSearch;

  /// When set (embedded home map), closing the filter ribbon also clears saved
  /// filters in the parent so the feed ribbon does not reappear on view toggle.
  final VoidCallback? onDismissFilterRibbon;

  /// [ListingsBloc] revision for the home feed while [embedded] is true. When
  /// this changes without filter changes, map results are refreshed so pin
  /// counts stay aligned with the AppBar total.
  final int feedListingsRevision;

  @override
  State<SearchResultsMapScreen> createState() => _SearchResultsMapScreenState();
}

class _SearchResultsMapScreenState extends State<SearchResultsMapScreen> {
  static const int _defaultMapSearchLimit = 300;
  static const int _androidMapSearchLimit = 100;
  static const double _defaultMinPrice = 0;
  static const double _defaultMaxPrice = 1000;
  static const double _profileDefaultMinPrice =
      SearchFilterDefaultsPolicy.defaultMinPrice;
  static const double _profileDefaultMaxPrice =
      SearchFilterDefaultsPolicy.defaultMaxPrice;

  _SearchMapResult? _result;
  Object? _loadError;
  bool _isLoading = true;
  int _loadGeneration = 0;
  ListingMapPin? _selectedPin;
  List<ListingMapPin> _selectedPinGroup = const [];
  List<int> _selectedListingGroupIds = const [];
  final Set<int> _visitedListingIds = {};
  UniversityMapMarker? _selectedUniversityMarker;
  SubwayStation? _selectedMetroStation;
  late final ValueNotifier<_SearchMapCanvasProps> _canvasPropsNotifier;
  late final ValueNotifier<_SearchMapOverlayProps> _overlayPropsNotifier;
  List<UniversityMapMarker> _universityMarkers = const [];
  String? _currentUserUniversityMarkerId;
  late bool _showDistrictLayer;
  late _MetroLayerMode _metroLayerMode;
  _WalkRadiusMinutes _walkRadiusMinutes = _WalkRadiusMinutes.min10;
  late bool _showUniversitiesLayer;
  bool _showGroceryStoresLayer = false;
  bool _showBusStopsLayer = false;
  bool? _mapNightModeOverride;
  bool _showLocationPrompt = false;
  bool _userLocationPermissionGranted = false;
  bool _showFilterRibbon = true;
  /// True only after the user taps X on the map filter ribbon — not when the
  /// ribbon is hidden because filters are profile defaults only.
  bool _filterRibbonDismissedByUser = false;
  int _userLocationRequestToken = 0;
  int _userLocationFocusToken = 0;
  int _userLocationLoadGeneration = 0;
  double? _userLocationLatitude;
  double? _userLocationLongitude;

  late int _listingTypeId;
  List<int>? _listingTypeIds;
  int? _locationId;
  int? _subwayStationId;
  late List<int> _subwayStationIds;
  int? _subwayLineId;
  int? _gender;
  late double _minPrice;
  late double _maxPrice;
  late bool _privateRoom;
  late bool _withPhoto;

  late final ArgumentCallback<Point> _onMapBackgroundTap = _handleMapBackgroundTap;
  late final ValueChanged<ListingMapPin> _onSelectPin = _handleSelectPin;
  late final ValueChanged<List<ListingMapPin>> _onSelectPinGroup =
      _handleSelectPinGroup;
  late final ValueChanged<UniversityMapMarker> _onSelectUniversityMarker =
      _handleSelectUniversityMarker;
  late final ValueChanged<SubwayStation?> _onSelectedMetroStationChanged =
      _handleSelectedMetroStationChanged;
  late final VoidCallback _onClearSelectedPin = _handleClearSelectedPin;
  late final VoidCallback _onClearSelectedUniversityMarker =
      _handleClearSelectedUniversityMarker;
  late final VoidCallback _onClearSelectedMetroStation =
      _handleClearSelectedMetroStation;
  late final ValueChanged<ListingMapPin> _onOpenPin = _handleOpenPin;
  late final ValueChanged<List<ListingMapPin>>
      _onAllListingsViewedInCarousel = _handleAllListingsViewedInCarousel;
  late final VoidCallback _onToggleDistrictLayer = _handleToggleDistrictLayer;
  late final VoidCallback _onToggleWalkRadiusMinutes =
      _handleToggleWalkRadiusMinutes;
  late final VoidCallback _onToggleMetroLayerMode = _handleToggleMetroLayerMode;
  late final VoidCallback _onToggleUniversitiesLayer =
      _handleToggleUniversitiesLayer;
  late final ValueChanged<bool> _onToggleMapNightMode =
      _handleToggleMapNightMode;

  @override
  void initState() {
    super.initState();
    final layerDefaults = ClientMapLayerDefaultsConfig.defaults.value;
    _showDistrictLayer = !isAndroidDevice && layerDefaults.districts;
    _metroLayerMode = !isAndroidDevice && layerDefaults.metro
        ? _MetroLayerMode.all
        : _MetroLayerMode.off;
    _showUniversitiesLayer = !isAndroidDevice && layerDefaults.universities;
    _syncFiltersFromWidget();
    if (widget.initialListings.isNotEmpty || widget.initialTotal != null) {
      final initialResult = _resultFromListings(
        widget.initialListings,
        total: widget.initialTotal ?? widget.initialListings.length,
      );
      _result = initialResult;
      _selectedPin = _autoSelectedPin(initialResult);
    }
    if (_hasMapSearchFilters) {
      _loadResults(showLoading: false);
      _showFilterRibbon = _filterRibbonEnabled;
    } else if (widget.initialListings.isNotEmpty || widget.initialTotal != null) {
      _isLoading = false;
      _showFilterRibbon = false;
    } else {
      _result = const _SearchMapResult(pins: [], total: 0, mappableCount: 0);
      _isLoading = false;
      _showFilterRibbon = false;
    }
    _canvasPropsNotifier = ValueNotifier(_buildCanvasProps());
    _overlayPropsNotifier = ValueNotifier(_buildOverlayProps());
    if (!isAndroidDevice || _showUniversitiesLayer) {
      _loadUniversityMarkers();
    }
    unawaited(_refreshLocationPromptVisibility());
    if (widget.embedded) {
      _publishMapListingCount(_result);
    }
    _syncAllMapProps();
  }

  @override
  void didUpdateWidget(covariant SearchResultsMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final filtersChanged = _widgetFiltersChanged(oldWidget);
    final feedRevisionChanged = widget.embedded &&
        widget.feedListingsRevision != oldWidget.feedListingsRevision;

    if (filtersChanged) {
      _syncFiltersFromWidget();
      _selectedPin = null;
      _selectedPinGroup = const [];
      _selectedListingGroupIds = const [];
      _selectedUniversityMarker = null;
      _selectedMetroStation = null;
      if (!_filterRibbonDismissedByUser) {
        _showFilterRibbon = _filterRibbonEnabled && _hasMapSearchFilters;
      }
      if (_hasMapSearchFilters) {
        _loadResults();
      } else {
        _applyFeedListingsFromWidget();
      }
      return;
    }

    if (feedRevisionChanged) {
      if (_filterRibbonDismissedByUser) {
        _syncFiltersFromWidget();
      }
      if (_hasMapSearchFilters) {
        _loadResults(showLoading: false);
      } else {
        _applyFeedListingsFromWidget();
      }
      return;
    }
  }

  @override
  void dispose() {
    _canvasPropsNotifier.dispose();
    _overlayPropsNotifier.dispose();
    if (widget.embedded) {
      HomeInlineSearchState().setMapViewActive(false);
    }
    super.dispose();
  }

  _SearchMapCanvasProps _buildCanvasProps() {
    final result = _result ?? const _SearchMapResult(pins: [], total: 0, mappableCount: 0);
    return _SearchMapCanvasProps(
      result: result,
      hasSearchFilters: _hasMapSearchFilters,
      showFilterRibbon: _showFilterRibbon,
      locationId: _locationId,
      universityMarkers:
          _showUniversitiesLayer ? _universityMarkers : const [],
      userUniversityMarkerId: _currentUserUniversityMarkerId,
      selectedListingId: _selectedPin?.listingId,
      selectedListingGroupIds: _selectedListingGroupIds,
      visitedListingIds: _visitedListingIds,
      selectedUniversityMarkerId: _selectedUniversityMarker?.id,
      selectedUniversityZoomFocusId: _selectedUniversityMarker?.id,
      selectedMetroStationId: _selectedMetroStation?.id,
      showDistrictLayer: _showDistrictLayer,
      metroLayerMode: _metroLayerMode,
      walkRadiusMinutes: _walkRadiusMinutes,
      showUniversitiesLayer: _showUniversitiesLayer,
      showGroceryStoresLayer: _showGroceryStoresLayer,
      showBusStopsLayer: _showBusStopsLayer,
      mapNightModeOverride: _mapNightModeOverride,
      userLocationRequestToken: _userLocationRequestToken,
      userLocationFocusToken: _userLocationFocusToken,
      userLocationLatitude: _userLocationLatitude,
      userLocationLongitude: _userLocationLongitude,
      placeViewToggleAtBottom: widget.embedded,
      mapBottomInset: widget.embedded ? widget.embeddedMapBottomInset : 0,
      viewToggleBottom: widget.embeddedViewToggleBottom,
      searchButtonBottom: widget.embeddedSearchButtonBottom,
    );
  }

  _SearchMapOverlayProps _buildOverlayProps() {
    final result = _result ?? const _SearchMapResult(pins: [], total: 0, mappableCount: 0);
    return _SearchMapOverlayProps(
      isLoading: _isLoading,
      hasSearchFilters: _hasMapSearchFilters,
      resultTotal: result.total,
      listingTypeId: _listingTypeId,
      gender: _gender,
      locationId: _locationId,
      subwayStationId: _subwayStationId,
      subwayStationIds: _subwayStationIds,
      subwayLineId: _subwayLineId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      privateRoom: _privateRoom,
      withPhoto: _withPhoto,
      selectedPin: _selectedPin,
      selectedPinGroup: _selectedPinGroup,
      selectedUniversityMarker: _selectedUniversityMarker,
      selectedMetroStation: _selectedMetroStation,
      showDistrictLayer: _showDistrictLayer,
      metroLayerMode: _metroLayerMode,
      walkRadiusMinutes: _walkRadiusMinutes,
      showUniversitiesLayer: _showUniversitiesLayer,
      mapNightModeOverride: _mapNightModeOverride,
      showLocationPrompt: _showLocationPrompt,
      showUserLocationButton: !kIsWeb && _userLocationPermissionGranted,
      filterRibbonEnabled: _filterRibbonEnabled,
      showFilterRibbon: _showFilterRibbon,
      placeViewToggleAtBottom: widget.embedded,
      mapBottomInset: widget.embedded ? widget.embeddedMapBottomInset : 0,
      searchButtonBottom: widget.embeddedSearchButtonBottom,
      viewToggleBottom: widget.embeddedViewToggleBottom,
      hasEmbeddedSearch: widget.onOpenEmbeddedSearch != null,
    );
  }

  void _syncCanvasProps() {
    if (_result == null) return;
    final next = _buildCanvasProps();
    if (_canvasPropsNotifier.value == next) return;
    _canvasPropsNotifier.value = next;
  }

  void _syncOverlayProps() {
    if (_result == null) return;
    final next = _buildOverlayProps();
    if (_overlayPropsNotifier.value == next) return;
    _overlayPropsNotifier.value = next;
  }

  void _syncAllMapProps() {
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _invalidateMapView({bool canvas = true, bool overlay = true}) {
    if (_result == null) {
      if (mounted) setState(() {});
      return;
    }
    if (canvas) _syncCanvasProps();
    if (overlay) _syncOverlayProps();
  }

  void _publishMapListingCount(_SearchMapResult? result) {
    if (!widget.embedded) return;
    if (result == null) {
      HomeInlineSearchState().setMapListingCount(0);
      return;
    }
    HomeInlineSearchState().setMapListingCount(result.total);
  }

  void _pruneSelectionForCurrentResult() {
    final result = _result;
    if (result == null) return;
    final visibleListingIds = result.pins.map((pin) => pin.listingId).toSet();
    final selectedPin = _selectedPin;
    if (selectedPin != null &&
        !visibleListingIds.contains(selectedPin.listingId)) {
      _selectedPin = null;
    }
    if (_selectedPinGroup.isNotEmpty &&
        _selectedPinGroup.any(
          (pin) => !visibleListingIds.contains(pin.listingId),
        )) {
      _selectedPinGroup = const [];
      _selectedListingGroupIds = const [];
    }
  }

  void _syncFiltersFromWidget() {
    _listingTypeId = widget.listingTypeId;
    _listingTypeIds = widget.listingTypeIds == null
        ? null
        : List<int>.from(widget.listingTypeIds!);
    _locationId = widget.locationId;
    _subwayStationId = widget.subwayStationId;
    _subwayStationIds = List<int>.from(widget.subwayStationIds);
    _subwayLineId = widget.subwayLineId;
    _gender = widget.gender;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _privateRoom = widget.privateRoom;
    _withPhoto = widget.withPhoto;
  }

  bool _widgetFiltersChanged(SearchResultsMapScreen oldWidget) {
    return oldWidget.listingTypeId != widget.listingTypeId ||
        !_intListsEqual(
          oldWidget.listingTypeIds ?? const [],
          widget.listingTypeIds ?? const [],
        ) ||
        oldWidget.locationId != widget.locationId ||
        oldWidget.subwayStationId != widget.subwayStationId ||
        !_intListsEqual(oldWidget.subwayStationIds, widget.subwayStationIds) ||
        oldWidget.subwayLineId != widget.subwayLineId ||
        oldWidget.gender != widget.gender ||
        oldWidget.minPrice != widget.minPrice ||
        oldWidget.maxPrice != widget.maxPrice ||
        oldWidget.privateRoom != widget.privateRoom ||
        oldWidget.withPhoto != widget.withPhoto;
  }

  bool _matchesCurrentFilters(SearchBottomSheetResult result) {
    return _listingTypeId == result.listingTypeId &&
        _intListsEqual(
          _listingTypeIds ?? const [],
          result.listingTypeIds ?? const [],
        ) &&
        _locationId == result.locationId &&
        _subwayStationId == result.subwayStationId &&
        _intListsEqual(_subwayStationIds, result.subwayStationIds) &&
        _subwayLineId == result.subwayLineId &&
        _gender == result.gender &&
        _minPrice == result.minPrice &&
        _maxPrice == result.maxPrice &&
        _privateRoom == result.privateRoom &&
        _withPhoto == result.withPhoto;
  }

  bool get _filterRibbonEnabled =>
      AuthenticationState().isAuthenticated ||
      HomeInlineSearchState().isActive;

  bool get _hasMapSearchFilters {
    if (!_filterRibbonEnabled) {
      return _hasExplicitUserMapFilters;
    }
    return _hasProfileDefaultMapFilters || _hasExplicitUserMapFilters;
  }

  /// Listing type + profile gender — the same defaults applied on the home feed.
  bool get _hasProfileDefaultMapFilters {
    return _listingTypeId >= 1 &&
        _gender != null &&
        _gender! >= 1 &&
        _gender! <= 2;
  }

  bool get _hasExplicitUserMapFilters {
    return _locationId != null ||
        _subwayStationId != null ||
        _subwayStationIds.isNotEmpty ||
        _subwayLineId != null ||
        _hasCustomMapPriceRange(_minPrice, _maxPrice) ||
        _privateRoom ||
        _withPhoto;
  }

  bool _hasCustomMapPriceRange(double minPrice, double maxPrice) {
    final isFullDefault =
        minPrice == _defaultMinPrice && maxPrice == _defaultMaxPrice;
    final isProfileDefault = minPrice == _profileDefaultMinPrice &&
        maxPrice == _profileDefaultMaxPrice;
    return !isFullDefault && !isProfileDefault;
  }

  bool _intListsEqual(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _loadUniversityMarkers() async {
    try {
      if (!UniversityCache.isInitialized) {
        await UniversityCache.initialize();
      }
      final profile = await SessionManager.getCachedUserProfile();
      final language = LanguageState().currentLanguage;
      final markers = UniversityCache.getAllUniversities()
          .map((university) => _markerForUniversity(university, language))
          .whereType<UniversityMapMarker>()
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));

      if (!mounted) return;
      _universityMarkers = markers;
      _currentUserUniversityMarkerId = profile?.universityId?.toString();
      _syncCanvasProps();
    } catch (error) {
      logger.w("Could not load university markers: $error");
    }
  }

  UniversityMapMarker? _markerForUniversity(
    University university,
    String language,
  ) {
    final latitude = double.tryParse(university.latitude ?? "");
    final longitude = double.tryParse(university.longitude ?? "");
    if (latitude == null || longitude == null) return null;
    if (_isPlaceholderUniversityCoordinate(latitude, longitude)) return null;

    final shortName = university.getLocalizedShortName(language);
    final fullName = university.getLocalizedName(language);
    return UniversityMapMarker(
      id: university.id.toString(),
      latitude: latitude,
      longitude: longitude,
      title: shortName.isNotEmpty ? shortName : fullName,
      fullTitle: fullName,
    );
  }

  Future<void> _refreshLocationPromptVisibility() async {
    if (kIsWeb) return;
    final status = await Permission.location.status;
    if (!mounted) return;

    final isGranted = status.isGranted || status.isLimited;
    final shouldAutoLoad = isGranted && _userLocationRequestToken == 0;

    _userLocationPermissionGranted = isGranted;
    _showLocationPrompt =
        !isGranted &&
        _userLocationRequestToken == 0 &&
        !status.isPermanentlyDenied;
    if (shouldAutoLoad) {
      _userLocationRequestToken++;
    }
    _invalidateMapView(canvas: shouldAutoLoad, overlay: true);

    if (shouldAutoLoad) {
      await _loadCurrentUserLocationOnce();
    }
  }

  Future<void> _requestUserLocation() async {
    final status = await Permission.location.request();
    if (!mounted) return;
    final isGranted = status.isGranted || status.isLimited;
    _userLocationPermissionGranted = isGranted;
    _showLocationPrompt = false;
    if (isGranted) {
      _userLocationRequestToken++;
    }
    _invalidateMapView(canvas: isGranted, overlay: true);
    if (isGranted) {
      await _loadCurrentUserLocationOnce();
    }
  }

  Future<void> _loadCurrentUserLocationOnce({bool focusOnMap = false}) async {
    final generation = ++_userLocationLoadGeneration;
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (!mounted || generation != _userLocationLoadGeneration) return;
      _userLocationLatitude = position.latitude;
      _userLocationLongitude = position.longitude;
      if (focusOnMap) {
        _userLocationFocusToken++;
      }
      _syncCanvasProps();
    } catch (error) {
      logger.w("Could not load current map location: $error");
    }
  }

  Future<void> _updateUserLocation() async {
    if (kIsWeb) return;

    final status = await Permission.location.status;
    if (!mounted) return;

    if (!status.isGranted && !status.isLimited) {
      await _requestUserLocation();
      return;
    }

    await _loadCurrentUserLocationOnce(focusOnMap: true);
  }

  bool _isPlaceholderUniversityCoordinate(double latitude, double longitude) {
    return (latitude - 41.2995).abs() < 0.000001 &&
        (longitude - 69.2401).abs() < 0.000001;
  }

  Future<void> _loadResults({
    bool showLoading = true,
  }) async {
    if (!_hasMapSearchFilters) {
      _loadGeneration++;
      _result = const _SearchMapResult(pins: [], total: 0, mappableCount: 0);
      _loadError = null;
      _isLoading = false;
      _selectedPin = null;
      _selectedPinGroup = const [];
      _selectedListingGroupIds = const [];
      _selectedUniversityMarker = null;
      _selectedMetroStation = null;
      _showFilterRibbon = false;
      _syncAllMapProps();
      return;
    }

    final loadGeneration = ++_loadGeneration;
    if (showLoading) {
      _isLoading = true;
      _loadError = null;
      _selectedPin = null;
      _selectedPinGroup = const [];
      _selectedListingGroupIds = const [];
      _selectedUniversityMarker = null;
      _selectedMetroStation = null;
      _syncCanvasProps();
      _syncOverlayProps();
    }

    try {
      final result = await _fetchResults();
      if (!mounted || loadGeneration != _loadGeneration) return;
      final mountingMapBody = _result == null;
      _result = result;
      _loadError = null;
      _isLoading = false;
      _selectedPin = _autoSelectedPin(result);
      _selectedPinGroup = const [];
      _selectedListingGroupIds = const [];
      _selectedMetroStation = null;
      _pruneSelectionForCurrentResult();
      _syncAllMapProps();
      if (mountingMapBody) setState(() {});
      _publishMapListingCount(result);
    } catch (error) {
      if (!mounted || loadGeneration != _loadGeneration) return;
      _loadError = error;
      _isLoading = false;
      if (_result == null) {
        setState(() {});
      } else {
        _syncOverlayProps();
      }
    }
  }

  ResolvedListingSearchParams get _searchParams =>
      ResolvedListingSearchParams.fromMapToggle(
        listingTypeId: _listingTypeId,
        listingTypeIds: _listingTypeIds,
        locationId: _locationId,
        subwayStationId: _subwayStationId,
        subwayStationIds: _subwayStationIds,
        subwayLineId: _subwayLineId,
        gender: _gender,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        privateRoom: _privateRoom,
        withPhoto: _withPhoto,
      );

  Future<_SearchMapResult> _fetchResults() async {
    final params = _searchParams;
    final pageLimit =
        isAndroidDevice ? _androidMapSearchLimit : _defaultMapSearchLimit;
    final accumulated = <Listing>[];
    var exactTotal = 0;
    var page = 1;

    while (true) {
      final response = await params.searchListingsPage(
        getIt<IListingService>(),
        page: page,
        limit: pageLimit,
      );
      if (page == 1) {
        exactTotal = response.total;
      }
      if (response.data.isEmpty) break;
      accumulated.addAll(response.data);
      if (exactTotal > 0 && accumulated.length >= exactTotal) break;
      if (response.data.length < pageLimit) break;
      page++;
      if (page > 100) break;
    }

    return _resultFromListings(
      accumulated,
      total: exactTotal > 0 ? exactTotal : accumulated.length,
    );
  }

  _SearchMapResult _resultFromMapPins(
    List<ListingMapPinData> pins, {
    required int total,
  }) {
    final mapPins = <ListingMapPin>[];
    final seenListingIds = <int>{};
    for (final pin in pins) {
      if (!seenListingIds.add(pin.id)) continue;
      mapPins.add(_mapPinFromData(pin));
    }
    final mappableCount = mapPins.length;
    return _SearchMapResult(
      pins: mapPins,
      total: total,
      mappableCount: mappableCount,
    );
  }

  ListingMapPin _mapPinFromData(ListingMapPinData pin) {
    final listingTypeCode =
        pin.listingTypeCode ?? _listingTypeCodeFromId(pin.listingTypeId);
    return ListingMapPin(
      listingId: pin.id,
      latitude: pin.latitude,
      longitude: pin.longitude,
      title: _mapPinTitle(pin),
      subtitle: _mapPinPriceLabel(pin, listingTypeCode),
      locationLabel: _mapPinLocationLabel(pin),
      stationLabel: _mapPinStationLabel(pin),
      subwayLineIds: _mapPinSubwayLineIds(pin),
      listingTypeId: pin.listingTypeId,
      listingTypeCode: listingTypeCode,
      hostResident: pin.hostResident,
      gender: pin.gender,
      photoUrl: pin.photoUrl != null
          ? EnvironmentUtil.hostedImageUrl(pin.photoUrl!)
          : null,
    );
  }

  String _mapPinTitle(ListingMapPinData pin) {
    if (ListingUtils.usesPresetListingTitle(pin.listingTypeId)) {
      return L10n.get(
        ListingUtils.presetListingTitleL10nKey(
          listingTypeId: pin.listingTypeId,
          gender: pin.gender,
        ),
      );
    }
    return pin.title;
  }

  String _mapPinPriceLabel(ListingMapPinData pin, String listingTypeCode) {
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: pin.price,
      listingTypeCode: listingTypeCode,
      minPrice: pin.minPrice,
      maxPrice: pin.maxPrice,
    );
    return PriceRangeHelper.formatListingPriceRangeWithCurrencyMarker(
      bounds.min,
      bounds.max,
    );
  }

  String? _mapPinLocationLabel(ListingMapPinData pin) {
    final locationId = pin.locationId ??
        (pin.subwayStationId != null
            ? MetroCache.getStationById(pin.subwayStationId!)?.locationId
            : null);
    if (locationId == null) return null;
    final location = LocationCache.getLocationById(locationId);
    if (location == null) return null;
    return _shortenDistrictSuffix(
      _getLocalizedName(
        nameUz: location.nameUz,
        nameRu: location.nameRu,
        nameEn: location.nameEn,
      ),
    );
  }

  String? _mapPinStationLabel(ListingMapPinData pin) {
    final stationId = pin.subwayStationId;
    if (stationId == null) return null;
    final station = MetroCache.getStationById(stationId);
    if (station == null) return null;
    return MetroCache.formatStationLabel(
      _getLocalizedName(
        nameUz: station.nameUz,
        nameRu: station.nameRu,
        nameEn: station.nameEn,
      ),
      LanguageState().currentLanguage,
    );
  }

  List<int> _mapPinSubwayLineIds(ListingMapPinData pin) {
    if (pin.subwayLineId != null) return [pin.subwayLineId!];
    final stationId = pin.subwayStationId;
    if (stationId == null) return const [];
    final station = MetroCache.getStationById(stationId);
    return station == null ? const [] : [station.line];
  }

  _SearchMapResult _resultFromListings(
    List<Listing> listings, {
    required int total,
  }) {
    final pins = <ListingMapPin>[];
    final seenListingIds = <int>{};
    for (final listing in listings) {
      if (!seenListingIds.add(listing.id)) continue;
      final pin = _pinForListing(listing);
      if (pin == null) continue;
      pins.add(pin);
    }
    final mappableCount = pins.length;
    return _SearchMapResult(
      pins: pins,
      total: total,
      mappableCount: mappableCount,
    );
  }

  ListingMapPin? _autoSelectedPin(_SearchMapResult result) {
    return result.pins.length == 1 ? result.pins.first : null;
  }

  Future<void> _openFilters() async {
    await SearchBottomSheetWidget.show(
      context,
      openedFromHomeScreen: false,
      currentListingTypeId: _listingTypeId,
      currentLocationId: _locationId ?? 0,
      currentSubwayStationId: _subwayStationId,
      currentSubwayStationIds: _subwayStationIds,
      currentSubwayLineId: _subwayLineId,
      currentGender: _gender,
      currentMinPrice: _minPrice,
      currentMaxPrice: _maxPrice,
      currentPrivateRoom: _privateRoom,
      currentWithPhoto: _withPhoto,
      primaryLabelKey: "apply",
      primaryIcon: Icons.check,
      primaryAction: SearchBottomSheetAction.map,
      onApply: (result) {
        final hasMapFilters = _hasMapSearchFiltersFor(result);
        if (_matchesCurrentFilters(result)) {
          _showFilterRibbon = _filterRibbonEnabled && hasMapFilters;
          _syncOverlayProps();
          return;
        }

        _filterRibbonDismissedByUser = false;
        _showFilterRibbon = _filterRibbonEnabled && hasMapFilters;
        _listingTypeId = result.listingTypeId;
        _listingTypeIds = result.listingTypeIds == null
            ? null
            : List<int>.from(result.listingTypeIds!);
        _locationId = result.locationId;
        _subwayStationId = result.subwayStationId;
        _subwayStationIds = List<int>.from(result.subwayStationIds);
        _subwayLineId = result.subwayLineId;
        _gender = result.gender;
        _minPrice = result.minPrice;
        _maxPrice = result.maxPrice;
        _privateRoom = result.privateRoom;
        _withPhoto = result.withPhoto;
        _selectedPin = null;
        _selectedPinGroup = const [];
        _selectedListingGroupIds = const [];
        _selectedUniversityMarker = null;
        _selectedMetroStation = null;
        _loadResults();
      },
    );
  }

  void _hideFilterRibbon() {
    widget.onDismissFilterRibbon?.call();
    _filterRibbonDismissedByUser = true;
    _showFilterRibbon = false;
    _loadError = null;
    _selectedPin = null;
    _selectedPinGroup = const [];
    _selectedListingGroupIds = const [];
    _selectedUniversityMarker = null;
    _selectedMetroStation = null;
    _syncAllMapProps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_filterRibbonDismissedByUser) return;
      _syncFiltersFromWidget();
      if (_hasMapSearchFilters) {
        _loadResults(showLoading: false);
      } else {
        _applyFeedListingsFromWidget();
      }
    });
  }

  void _applyFeedListingsFromWidget() {
    final listings = widget.initialListings;
    if (listings.isEmpty) {
      _loadGeneration++;
      _result = const _SearchMapResult(pins: [], total: 0, mappableCount: 0);
      _loadError = null;
      _isLoading = false;
      _syncAllMapProps();
      _publishMapListingCount(_result);
      return;
    }
    final result = _resultFromListings(
      listings,
      total: widget.initialTotal ?? listings.length,
    );
    _result = result;
    _loadError = null;
    _isLoading = false;
    _selectedPin = _autoSelectedPin(result);
    _selectedPinGroup = const [];
    _selectedListingGroupIds = const [];
    _selectedMetroStation = null;
    _pruneSelectionForCurrentResult();
    _syncAllMapProps();
    _publishMapListingCount(result);
  }

  bool _hasMapSearchFiltersFor(SearchBottomSheetResult result) {
    final hasProfileDefaults = _filterRibbonEnabled &&
        result.listingTypeId >= 1 &&
        result.gender != null &&
        result.gender! >= 1 &&
        result.gender! <= 2;
    return hasProfileDefaults ||
        result.locationId != null ||
        result.subwayStationId != null ||
        result.subwayStationIds.isNotEmpty ||
        result.subwayLineId != null ||
        _hasCustomMapPriceRange(result.minPrice, result.maxPrice) ||
        result.privateRoom ||
        result.withPhoto;
  }

  void _openFeedView() {
    final onOpenFeed = widget.onOpenFeed;
    if (onOpenFeed != null) {
      onOpenFeed(
        context,
        _currentSearchResult(),
        mapFilterRibbonDismissed: _filterRibbonDismissedByUser,
      );
      return;
    }
    Navigator.of(context).maybePop();
  }

  SearchBottomSheetResult _currentSearchResult() {
    return SearchBottomSheetResult(
      listingTypeId: _listingTypeId,
      listingTypeIds: _listingTypeIds,
      locationId: _locationId,
      subwayStationId: _subwayStationId,
      subwayStationIds: _subwayStationIds,
      subwayLineId: _subwayLineId,
      gender: _gender,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      privateRoom: _privateRoom,
      withPhoto: _withPhoto,
      action: SearchBottomSheetAction.feed,
    );
  }

  ListingMapPin? _pinForListing(Listing listing) {
    final pinMeta = _pinMetaForListing(listing);
    final listingTypeCode = listing.listingType?.code ??
        _listingTypeCodeFromId(listing.listingTypeId);
    final stationId = listing.subwayStationId ??
        listing.subwayStation?.id ??
        (listing.searchSubwayStations?.isNotEmpty == true
            ? listing.searchSubwayStations!.first.id
            : null);
    if (stationId != null) {
      final coords = MetroCache.getMetroStationCoordinatesById(stationId);
      if (coords != null) {
        return ListingMapPin(
          listingId: listing.id,
          latitude: coords["latitude"]!,
          longitude: coords["longitude"]!,
          title: _listingTitle(listing),
          subtitle: _listingPriceLabel(listing),
          locationLabel: pinMeta.locationLabel,
          stationLabel: pinMeta.stationLabel,
          subwayLineIds: pinMeta.subwayLineIds,
          listingTypeId: listing.listingTypeId,
          listingTypeCode: listingTypeCode,
          gender: listing.gender,
          photoUrl: _listingPrimaryPhotoUrl(listing),
          createdAt: listing.createdAt,
        );
      }
    }

    final locationId = listing.locationId ??
        listing.location?.id ??
        (listing.searchLocations?.isNotEmpty == true
            ? listing.searchLocations!.first.id
            : null);
    if (locationId != null) {
      final coords = LocationCache.getLocationCoordinatesById(locationId);
      if (coords != null) {
        return ListingMapPin(
          listingId: listing.id,
          latitude: coords["latitude"]!,
          longitude: coords["longitude"]!,
          title: _listingTitle(listing),
          subtitle: _listingPriceLabel(listing),
          locationLabel: pinMeta.locationLabel,
          stationLabel: pinMeta.stationLabel,
          subwayLineIds: pinMeta.subwayLineIds,
          listingTypeId: listing.listingTypeId,
          listingTypeCode: listingTypeCode,
          gender: listing.gender,
          photoUrl: _listingPrimaryPhotoUrl(listing),
          createdAt: listing.createdAt,
        );
      }
    }

    return null;
  }

  _PinMeta _pinMetaForListing(Listing listing) {
    final stations = _effectiveSearchStations(listing);
    final locations = _effectiveSearchLocations(listing, stations);
    final metroSummary = _metroSummary(stations);
    return _PinMeta(
      locationLabel:
          locations.isEmpty ? null : _locationSummaryLabel(locations),
      stationLabel: metroSummary?.label,
      subwayLineIds: metroSummary?.lineIds ?? const [],
    );
  }

  List<SubwayStationDetail> _effectiveSearchStations(Listing listing) {
    final locations = listing.searchLocations;
    if (locations != null && locations.isNotEmpty) {
      return const <SubwayStationDetail>[];
    }
    final stations = listing.searchSubwayStations;
    if (stations != null && stations.isNotEmpty) return stations;
    final station = listing.subwayStation;
    return station == null ? const <SubwayStationDetail>[] : [station];
  }

  List<LocationDetail> _effectiveSearchLocations(
    Listing listing,
    List<SubwayStationDetail> stations,
  ) {
    final locations = listing.searchLocations;
    if (locations != null && locations.isNotEmpty) return locations;
    final stationLocations = _locationsForStations(stations);
    if (stationLocations.isNotEmpty) return stationLocations;
    final location = listing.location;
    return location == null ? const <LocationDetail>[] : [location];
  }

  List<LocationDetail> _locationsForStations(
    List<SubwayStationDetail> stations,
  ) {
    if (stations.isEmpty) return const <LocationDetail>[];
    final displayStations = MetroCache.dedupeTransferStationPairs(
      stations,
      (station) => station.id,
    );
    final locationIds = <int>{};
    final locations = <LocationDetail>[];
    for (final stationDetail in displayStations) {
      final locationId =
          MetroCache.getStationById(stationDetail.id)?.locationId;
      if (locationId == null || !locationIds.add(locationId)) continue;
      final location = LocationCache.getLocationById(locationId);
      if (location == null) continue;
      locations.add(
        LocationDetail(
          id: location.id,
          nameUz: location.nameUz,
          nameRu: location.nameRu,
          nameEn: location.nameEn,
          shortNameUz: location.shortNameUz,
          shortNameRu: location.shortNameRu,
          shortNameEn: location.shortNameEn,
        ),
      );
    }
    return locations;
  }

  _MetroSummary? _metroSummary(List<SubwayStationDetail> stations) {
    final displayStations = MetroCache.dedupeTransferStationPairs(
      stations,
      (station) => station.id,
    );
    if (displayStations.isEmpty) return null;

    if (displayStations.length == 1) {
      final station = displayStations.first;
      final transferInfo = MetroCache.getTransferStationInfo(station.id);
      if (transferInfo != null) {
        final connectedStation = SubwayStationDetail(
          id: transferInfo["connectedStationId"],
          nameUz: transferInfo["connectedStationName"],
          nameRu: transferInfo["connectedStationNameRu"],
          nameEn: transferInfo["connectedStationNameEn"],
          line: transferInfo["connectedStationLine"],
        );
        final mainStation =
            _subwayLineId != null && connectedStation.line == _subwayLineId
                ? connectedStation
                : station;
        final transferStation =
            mainStation.id == station.id ? connectedStation : station;
        return _MetroSummary(
          label: MetroCache.formatStationLabel(
            _getLocalizedName(
              nameUz: mainStation.nameUz,
              nameRu: mainStation.nameRu,
              nameEn: mainStation.nameEn,
            ),
            LanguageState().currentLanguage,
          ),
          lineIds: [transferStation.line, mainStation.line],
        );
      }

      return _MetroSummary(
        label: MetroCache.formatStationLabel(
          _getLocalizedName(
            nameUz: station.nameUz,
            nameRu: station.nameRu,
            nameEn: station.nameEn,
          ),
          LanguageState().currentLanguage,
        ),
        lineIds: [station.line],
      );
    }

    final lineIds = <int>[];
    for (final station in displayStations) {
      if (!lineIds.contains(station.line)) lineIds.add(station.line);
    }
    return _MetroSummary(
      label: _stationSummaryLabel(displayStations),
      lineIds: lineIds,
    );
  }

  String _stationSummaryLabel(List<SubwayStationDetail> stations) {
    return L10n.plural("stations_count", stations.length);
  }

  String _locationSummaryLabel(List<LocationDetail> locations) {
    if (locations.length == 1) {
      return _shortenDistrictSuffix(
        _getLocalizedName(
          nameUz: locations.first.nameUz,
          nameRu: locations.first.nameRu,
          nameEn: locations.first.nameEn,
        ),
      );
    }
    return L10n.plural("districts_count", locations.length);
  }

  String _getLocalizedName({String? nameUz, String? nameRu, String? nameEn}) {
    switch (LanguageState().currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "";
      case "ru":
      default:
        return nameRu ?? nameUz ?? nameEn ?? "";
    }
  }

  String _shortenDistrictSuffix(String name) {
    const replacements = <String, String>{
      " район": " р.",
      " Район": " р.",
      " tumani": " t.",
      " Tumani": " t.",
      " district": " dist.",
      " District": " dist.",
    };
    var result = name;
    replacements.forEach((from, to) {
      result = result.replaceAll(from, to);
    });
    return result;
  }

  String _listingTitle(Listing listing) {
    if (ListingUtils.usesPresetListingTitle(listing.listingTypeId)) {
      return L10n.get(
        ListingUtils.presetListingTitleL10nKey(
          listingTypeId: listing.listingTypeId,
          gender: listing.gender,
        ),
      );
    }
    return listing.title;
  }

  String _listingPriceLabel(Listing listing) {
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: listing.price,
      listingTypeCode: listing.listingType?.code ??
          _listingTypeCodeFromId(listing.listingTypeId),
      minPrice: listing.minPrice,
      maxPrice: listing.maxPrice,
    );
    return PriceRangeHelper.formatListingPriceRangeWithCurrencyMarker(
      bounds.min,
      bounds.max,
    );
  }

  String? _listingPrimaryPhotoUrl(Listing listing) {
    final photos = listing.photos;
    if (photos == null || photos.isEmpty) return null;

    final primaryPhotos = photos.where((photo) => photo.isPrimary);
    final photo = primaryPhotos.isNotEmpty ? primaryPhotos.first : photos.first;
    return EnvironmentUtil.hostedImageUrl(photo.photoUrl);
  }

  String _listingTypeCodeFromId(int id) {
    return switch (id) {
      ListingTypeIds.roomNeeded => ListingTypeCodes.roomNeeded,
      ListingTypeIds.roommateNeeded => ListingTypeCodes.roommateNeeded,
      ListingTypeIds.groupForming => ListingTypeCodes.groupForming,
      _ => "unknown",
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return SizedBox.expand(child: _buildBody(context));
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<_SearchMapOverlayProps>(
          valueListenable: _overlayPropsNotifier,
          builder: (context, _, __) {
            final hasNoResults = _result?.pins.isEmpty == true;
            final title = hasNoResults
                ? context.l10n.no_search_results
                : context.l10n.search_results;
            return CommonAppBar(
              title: title,
              titleWidget: _MapHeaderTitle(
                title: title,
                loading: _isLoading,
              ),
              showBackButton: true,
              actions: hasNoResults
                  ? [
                      _MapHeaderSearchButton(onPressed: _openFilters),
                    ]
                  : null,
            );
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final result = _result;
    final appNightModeEnabled = Theme.of(context).brightness == Brightness.dark;
    final mapNightModeEnabled = _mapNightModeOverride ?? appNightModeEnabled;
    final mapLoaderColor = mapNightModeEnabled ? Colors.white : Colors.black;
    if (_isLoading && result == null) {
      return _CenteredMapStatus(
        icon: Icons.map_outlined,
        title: context.l10n.loading_map,
        loading: true,
        loaderColor: mapLoaderColor,
      );
    }

    if (_loadError != null && result == null) {
      return _CenteredMapStatus(
        icon: Icons.error_outline,
        title: L10n.get("error"),
      );
    }
    if (result == null) {
      return _CenteredMapStatus(
        icon: Icons.map_outlined,
        title: context.l10n.loading_map,
        loading: true,
        loaderColor: mapLoaderColor,
      );
    }

    return _SearchResultsMapBody(
      canvasListenable: _canvasPropsNotifier,
      overlayListenable: _overlayPropsNotifier,
      onOpenFilters: _openFilters,
      onCloseFilterRibbon: _hideFilterRibbon,
      onOpenEmbeddedSearch: widget.onOpenEmbeddedSearch,
      onOpenFeedView: _openFeedView,
      onRequestUserLocation: _requestUserLocation,
      onUpdateUserLocation: _updateUserLocation,
      onToggleDistrictLayer: _onToggleDistrictLayer,
      onToggleWalkRadiusMinutes: _onToggleWalkRadiusMinutes,
      onToggleMetroLayerMode: _onToggleMetroLayerMode,
      onToggleUniversitiesLayer: _onToggleUniversitiesLayer,
      onToggleMapNightMode: _onToggleMapNightMode,
      onMapBackgroundTap: _onMapBackgroundTap,
      onSelectedMetroStationChanged: _onSelectedMetroStationChanged,
      onClearSelectedMetroStation: _onClearSelectedMetroStation,
      onClearSelectedPin: _onClearSelectedPin,
      onClearSelectedUniversityMarker: _onClearSelectedUniversityMarker,
      onSelectPin: _onSelectPin,
      onSelectPinGroup: _onSelectPinGroup,
      onSelectUniversityMarker: _onSelectUniversityMarker,
      onOpenPin: _onOpenPin,
      onAllListingsViewedInCarousel: _onAllListingsViewedInCarousel,
    );
  }

  void _handleToggleDistrictLayer() {
    _showDistrictLayer = !_showDistrictLayer;
    _syncAllMapProps();
  }

  void _handleToggleWalkRadiusMinutes() {
    _walkRadiusMinutes = _walkRadiusMinutes.next;
    _syncAllMapProps();
  }

  void _handleToggleMetroLayerMode() {
    _metroLayerMode = _metroLayerMode.next;
    _selectedMetroStation = null;
    _selectedUniversityMarker = null;
    _syncAllMapProps();
  }

  void _handleToggleUniversitiesLayer() {
    _showUniversitiesLayer = !_showUniversitiesLayer;
    if (!_showUniversitiesLayer) {
      _selectedUniversityMarker = null;
    }
    _syncAllMapProps();
  }

  void _handleToggleMapNightMode(bool enabled) {
    _mapNightModeOverride = enabled;
    _syncAllMapProps();
  }

  void _handleOpenPin(ListingMapPin pin) {
    _markListingVisited(pin.listingId);
    context.pushListingDetail(pin.listingId);
  }

  void _markListingVisited(int listingId) {
    if (!_visitedListingIds.add(listingId)) return;
    _syncCanvasProps();
  }

  void _handleAllListingsViewedInCarousel(List<ListingMapPin> pins) {
    var changed = false;
    for (final pin in pins) {
      changed |= _visitedListingIds.add(pin.listingId);
    }
    if (changed) _syncCanvasProps();
  }

  void _handleMapBackgroundTap(Point point) {
    _handleClearSelectedPin();
    _handleClearSelectedUniversityMarker();
    _handleClearSelectedMetroStation();
  }

  void _handleClearSelectedPin() {
    _selectedPin = null;
    _selectedPinGroup = const [];
    _selectedListingGroupIds = const [];
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _handleClearSelectedUniversityMarker() {
    _selectedUniversityMarker = null;
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _handleClearSelectedMetroStation() {
    _selectedMetroStation = null;
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _handleSelectPin(ListingMapPin pin) {
    _markListingVisited(pin.listingId);
    _selectedPin = pin;
    _selectedPinGroup = const [];
    _selectedListingGroupIds = const [];
    _selectedUniversityMarker = null;
    _selectedMetroStation = null;
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _handleSelectPinGroup(List<ListingMapPin> pins) {
    _selectedPin = null;
    _selectedPinGroup = List<ListingMapPin>.unmodifiable(pins);
    _selectedListingGroupIds = [
      for (final pin in pins) pin.listingId,
    ];
    _selectedUniversityMarker = null;
    _selectedMetroStation = null;
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _handleSelectUniversityMarker(UniversityMapMarker marker) {
    _selectedPin = null;
    _selectedPinGroup = const [];
    _selectedListingGroupIds = const [];
    _selectedUniversityMarker = marker;
    _selectedMetroStation = null;
    _syncCanvasProps();
    _syncOverlayProps();
  }

  void _handleSelectedMetroStationChanged(SubwayStation? station) {
    if (_selectedMetroStation?.id == station?.id) return;
    _selectedMetroStation = station;
    if (station != null) {
      _selectedPin = null;
      _selectedPinGroup = const [];
      _selectedListingGroupIds = const [];
      _selectedUniversityMarker = null;
    }
    _syncCanvasProps();
    _syncOverlayProps();
  }
}
