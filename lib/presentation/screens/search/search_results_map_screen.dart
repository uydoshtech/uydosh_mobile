import "dart:async" show unawaited;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/cache/university_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/gender_badge.dart";
import "package:uy_dosh/presentation/widgets/common/applied_search_filters_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/search_floating_action_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";

part "widgets/search_results_map_header.dart";
part "widgets/search_results_map_filter_ribbon.dart";
part "widgets/search_results_map_content.dart";
part "widgets/search_results_map_models.dart";
part "widgets/search_results_map_pin_summary.dart";
part "widgets/search_results_map_controls.dart";

class SearchResultsMapScreen extends StatefulWidget {
  const SearchResultsMapScreen({
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    super.key,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
    this.gender,
    this.onOpenFeed,
    this.embedded = false,
    this.initialListings = const [],
    this.initialTotal,
    this.embeddedSearchButtonBottom = 100.0,
    this.embeddedViewToggleBottom = 168.0,
    this.onOpenEmbeddedSearch,
  });

  final int listingTypeId;
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
    SearchBottomSheetResult result,
  )? onOpenFeed;
  final bool embedded;
  final List<Listing> initialListings;
  final int? initialTotal;
  final double embeddedSearchButtonBottom;
  final double embeddedViewToggleBottom;
  final VoidCallback? onOpenEmbeddedSearch;

  @override
  State<SearchResultsMapScreen> createState() => _SearchResultsMapScreenState();
}

class _SearchResultsMapScreenState extends State<SearchResultsMapScreen> {
  static const int _mapSearchLimit = 300;

  _SearchMapResult? _result;
  Object? _loadError;
  bool _isLoading = true;
  int _loadGeneration = 0;
  ListingMapPin? _selectedPin;
  List<ListingMapPin> _selectedPinGroup = const [];
  UniversityMapMarker? _selectedUniversityMarker;
  bool _hasSelectedMetroStation = false;
  List<UniversityMapMarker> _universityMarkers = const [];
  String? _currentUserUniversityMarkerId;
  bool _showDistrictLayer = true;
  bool _showMetroStationsLayer = true;
  bool _showUniversitiesLayer = false;
  bool _showGroceryStoresLayer = false;
  bool _showBusStopsLayer = false;
  bool? _mapNightModeOverride;
  bool _showLocationPrompt = false;
  int _userLocationRequestToken = 0;

  late int _listingTypeId;
  int? _locationId;
  int? _subwayStationId;
  late List<int> _subwayStationIds;
  int? _subwayLineId;
  int? _gender;
  late double _minPrice;
  late double _maxPrice;
  late bool _privateRoom;
  late bool _withPhoto;

  @override
  void initState() {
    super.initState();
    _syncFiltersFromWidget();
    if (widget.initialListings.isNotEmpty || widget.initialTotal != null) {
      final initialResult = _resultFromListings(
        widget.initialListings,
        total: widget.initialTotal ?? widget.initialListings.length,
      );
      _result = initialResult;
      _selectedPin = _autoSelectedPin(initialResult);
    }
    _loadResults(showLoading: false);
    _loadUniversityMarkers();
    unawaited(_refreshLocationPromptVisibility());
  }

  @override
  void didUpdateWidget(covariant SearchResultsMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_widgetFiltersChanged(oldWidget)) return;

    _syncFiltersFromWidget();
    _selectedPin = null;
    _selectedPinGroup = const [];
    _selectedUniversityMarker = null;
    _hasSelectedMetroStation = false;
    _loadResults();
  }

  void _syncFiltersFromWidget() {
    _listingTypeId = widget.listingTypeId;
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
      setState(() {
        _universityMarkers = markers;
        _currentUserUniversityMarkerId = profile?.universityId?.toString();
      });
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
    if (widget.embedded == false || kIsWeb) return;
    final status = await Permission.location.status;
    if (!mounted) return;
    setState(() {
      _showLocationPrompt = !status.isGranted && !status.isPermanentlyDenied;
    });
  }

  Future<void> _requestUserLocation() async {
    final status = await Permission.location.request();
    if (!mounted) return;
    setState(() {
      _showLocationPrompt = false;
      if (status.isGranted) {
        _userLocationRequestToken++;
      }
    });
  }

  bool _isPlaceholderUniversityCoordinate(double latitude, double longitude) {
    return (latitude - 41.2995).abs() < 0.000001 &&
        (longitude - 69.2401).abs() < 0.000001;
  }

  Future<void> _loadResults({
    bool showLoading = true,
  }) async {
    final loadGeneration = ++_loadGeneration;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
        _selectedPin = null;
        _selectedPinGroup = const [];
        _selectedUniversityMarker = null;
        _hasSelectedMetroStation = false;
      });
    }

    try {
      final result = await _fetchResults();
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _result = result;
        _loadError = null;
        _isLoading = false;
        _selectedPin = _autoSelectedPin(result);
        _selectedPinGroup = const [];
        _hasSelectedMetroStation = false;
      });
    } catch (error) {
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<_SearchMapResult> _fetchResults() async {
    final response = await getIt<IListingService>().searchListings(
      page: 1,
      limit: _mapSearchLimit,
      listingTypeId: _listingTypeId,
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

    return _resultFromListings(response.data, total: response.total);
  }

  _SearchMapResult _resultFromListings(
    List<Listing> listings, {
    required int total,
  }) {
    final pins = <ListingMapPin>[];
    for (final listing in listings) {
      final pin = _pinForListing(listing);
      if (pin == null) continue;
      pins.add(pin);
    }
    return _SearchMapResult(
      pins: pins,
      total: total,
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
      currentLocationId: _locationId,
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
        if (_matchesCurrentFilters(result)) return;

        setState(() {
          _listingTypeId = result.listingTypeId;
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
          _selectedUniversityMarker = null;
          _hasSelectedMetroStation = false;
        });
        _loadResults();
      },
    );
  }

  void _openFeedView() {
    final onOpenFeed = widget.onOpenFeed;
    if (onOpenFeed != null) {
      onOpenFeed(context, _currentSearchResult());
      return;
    }
    Navigator.of(context).maybePop();
  }

  SearchBottomSheetResult _currentSearchResult() {
    return SearchBottomSheetResult(
      listingTypeId: _listingTypeId,
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
    final stations = listing.searchSubwayStations;
    if (stations != null && stations.isNotEmpty) return stations;
    final station = listing.subwayStation;
    return station == null ? const <SubwayStationDetail>[] : [station];
  }

  List<LocationDetail> _effectiveSearchLocations(
    Listing listing,
    List<SubwayStationDetail> stations,
  ) {
    final stationLocations = _locationsForStations(stations);
    if (stationLocations.isNotEmpty) return stationLocations;
    final locations = listing.searchLocations;
    if (locations != null && locations.isNotEmpty) return locations;
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
    final hasNoResults = _result?.pins.isEmpty == true;
    final title = hasNoResults
        ? context.l10n.no_search_results
        : context.l10n.search_results;
    if (widget.embedded) {
      return _buildBody(context);
    }
    return Scaffold(
      appBar: CommonAppBar(
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
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final result = _result;
    if (_isLoading && result == null) {
      return _CenteredMapStatus(
        icon: Icons.map_outlined,
        title: context.l10n.loading_map,
        loading: true,
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
      );
    }

    return _SearchResultsMapContent(
      result: result,
      isLoading: _isLoading,
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
      hasSelectedMetroStation: _hasSelectedMetroStation,
      universityMarkers: _showUniversitiesLayer ? _universityMarkers : const [],
      selectedUniversityMarkerId: _selectedUniversityMarker?.id,
      userUniversityMarkerId: _currentUserUniversityMarkerId,
      showDistrictLayer: _showDistrictLayer,
      showMetroStationsLayer: _showMetroStationsLayer,
      showUniversitiesLayer: _showUniversitiesLayer,
      showGroceryStoresLayer: _showGroceryStoresLayer,
      showBusStopsLayer: _showBusStopsLayer,
      mapNightModeOverride: _mapNightModeOverride,
      showLocationPrompt: _showLocationPrompt,
      userLocationRequestToken: _userLocationRequestToken,
      placeViewToggleAtBottom: widget.embedded,
      searchButtonBottom: widget.embeddedSearchButtonBottom,
      viewToggleBottom: widget.embeddedViewToggleBottom,
      onOpenFilters: _openFilters,
      onOpenEmbeddedSearch: widget.onOpenEmbeddedSearch,
      onOpenFeedView: _openFeedView,
      onRequestUserLocation: _requestUserLocation,
      onToggleDistrictLayer: () {
        setState(() => _showDistrictLayer = !_showDistrictLayer);
      },
      onToggleMetroStationsLayer: () {
        setState(() {
          _showMetroStationsLayer = !_showMetroStationsLayer;
          if (!_showMetroStationsLayer) {
            _hasSelectedMetroStation = false;
          }
        });
      },
      onToggleUniversitiesLayer: () {
        setState(() {
          _showUniversitiesLayer = !_showUniversitiesLayer;
          if (!_showUniversitiesLayer) {
            _selectedUniversityMarker = null;
          }
        });
      },
      onToggleMapNightMode: (enabled) {
        setState(() => _mapNightModeOverride = enabled);
      },
      onMetroStationTooltipChanged: (visible) {
        if (_hasSelectedMetroStation == visible) return;
        setState(() => _hasSelectedMetroStation = visible);
      },
      onClearSelectedPin: () {
        setState(() {
          _selectedPin = null;
          _selectedPinGroup = const [];
        });
      },
      onClearSelectedUniversityMarker: () {
        setState(() => _selectedUniversityMarker = null);
      },
      onSelectPin: (pin) {
        setState(() {
          _selectedPin = pin;
          _selectedPinGroup = const [];
          _selectedUniversityMarker = null;
        });
      },
      onSelectPinGroup: (pins) {
        setState(() {
          _selectedPin = null;
          _selectedPinGroup = List<ListingMapPin>.unmodifiable(pins);
          _selectedUniversityMarker = null;
        });
      },
      onSelectUniversityMarker: (marker) {
        setState(() {
          _selectedPin = null;
          _selectedPinGroup = const [];
          _selectedUniversityMarker = marker;
        });
      },
      onOpenPin: (pin) => context.pushListingDetail(pin.listingId),
    );
  }
}
