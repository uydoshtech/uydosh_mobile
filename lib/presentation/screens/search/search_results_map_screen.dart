import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/gender_badge.dart";
import "package:uy_dosh/presentation/widgets/common/applied_search_filters_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

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

  @override
  State<SearchResultsMapScreen> createState() => _SearchResultsMapScreenState();
}

class _SearchResultsMapScreenState extends State<SearchResultsMapScreen> {
  static const int _mapSearchLimit = 300;

  _SearchMapResult? _result;
  Object? _loadError;
  bool _isLoading = true;
  bool _showRefreshAreaButton = false;
  YandexMapController? _mapController;
  int _loadGeneration = 0;
  Timer? _cameraIdleRefreshTimer;
  ListingMapPin? _selectedPin;

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
    _loadResults(showLoading: false);
  }

  @override
  void dispose() {
    _cameraIdleRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadResults({
    _MapBounds? bounds,
    bool showLoading = true,
  }) async {
    final loadGeneration = ++_loadGeneration;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
        _showRefreshAreaButton = false;
        _selectedPin = null;
      });
    }

    try {
      final result = await _fetchResults(bounds: bounds);
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _result = result;
        _loadError = null;
        _isLoading = false;
        _selectedPin = _autoSelectedPin(result);
      });
    } catch (error) {
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<_SearchMapResult> _fetchResults({_MapBounds? bounds}) async {
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

    final listings = <Listing>[];
    final pins = <ListingMapPin>[];
    for (final listing in response.data) {
      final pin = _pinForListing(listing);
      if (pin == null) continue;
      if (bounds != null && !bounds.contains(pin.latitude, pin.longitude)) {
        continue;
      }
      listings.add(listing);
      pins.add(pin);
    }
    return _SearchMapResult(
      listings: bounds == null ? response.data : listings,
      pins: pins,
      total: bounds == null ? response.total : listings.length,
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
      currentSubwayLineId: _subwayLineId,
      currentGender: _gender,
      currentMinPrice: _minPrice,
      currentMaxPrice: _maxPrice,
      currentPrivateRoom: _privateRoom,
      currentWithPhoto: _withPhoto,
      primaryLabelKey: "apply",
      primaryIcon: Icons.check,
      onApply: (result) {
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
          _showRefreshAreaButton = false;
          _selectedPin = null;
        });
        _loadResults();
      },
    );
  }

  Future<void> _refreshVisibleArea() async {
    final controller = _mapController;
    if (controller == null || _isLoading) return;

    final visibleRegion = await controller.getVisibleRegion();
    if (!mounted) return;
    await _loadResults(bounds: _MapBounds.fromVisibleRegion(visibleRegion));
  }

  void _scheduleVisibleAreaRefresh() {
    _cameraIdleRefreshTimer?.cancel();
    _cameraIdleRefreshTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (_isLoading) {
        _scheduleVisibleAreaRefresh();
        return;
      }
      unawaited(_refreshVisibleArea());
    });
  }

  void _handleCameraPositionChanged(
    CameraPosition cameraPosition,
    CameraUpdateReason reason,
    bool finished,
  ) {
    if (!finished || _result == null) return;
    if (!_showRefreshAreaButton) {
      setState(() {
        _showRefreshAreaButton = true;
        _selectedPin = null;
      });
    }
    _scheduleVisibleAreaRefresh();
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
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.search_results,
        titleWidget: _MapHeaderTitle(
          title: context.l10n.search_results,
          loading: _isLoading,
        ),
        showBackButton: true,
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

    return Column(
      children: [
        _MapFilterRibbon(
          onPressed: _openFilters,
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
          total: result.total,
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: YandexMapWidget(
                  apiKey: AppConfig.yandexMapsApiKey,
                  pins: result.pins,
                  title: context.l10n.search_results,
                  height: double.infinity,
                  moveCameraOnTargetChange: result.pins.isNotEmpty,
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraPositionChanged: _handleCameraPositionChanged,
                  onMapTap: (_) => setState(() => _selectedPin = null),
                  onPinTap: (pin) => setState(() => _selectedPin = pin),
                ),
              ),
              if (result.pins.isEmpty)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: _MapStatusBanner(
                    icon: Icons.search_off_outlined,
                    title: context.l10n.no_search_results,
                  ),
                ),
              if (_selectedPin != null)
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  child: _PinSummaryTooltip(
                    pin: _selectedPin!,
                    onClose: () => setState(() => _selectedPin = null),
                    onOpen: () => context.pushListingDetail(
                      _selectedPin!.listingId,
                    ),
                  ),
                ),
              if (_showRefreshAreaButton || _isLoading)
                Positioned(
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _RefreshAreaButton(
                      loading: _isLoading,
                      onPressed: _refreshVisibleArea,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapHeaderTitle extends StatelessWidget {
  const _MapHeaderTitle({
    required this.title,
    required this.loading,
  });

  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        );
    final spinnerColor = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: style),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: loading
              ? Padding(
                  key: const ValueKey("map-header-loading"),
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: spinnerColor,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey("map-header-idle")),
        ),
      ],
    );
  }
}

class _MapFilterRibbon extends StatelessWidget {
  const _MapFilterRibbon({
    required this.onPressed,
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    required this.total,
    this.gender,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
  });

  final VoidCallback onPressed;
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
  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: AppliedSearchFiltersBar(
            onPressed: onPressed,
            listingTypeId: listingTypeId,
            gender: gender,
            locationId: locationId,
            subwayStationId: subwayStationId,
            subwayStationIds: subwayStationIds,
            subwayLineId: subwayLineId,
            minPrice: minPrice,
            maxPrice: maxPrice,
            privateRoom: privateRoom,
            withPhoto: withPhoto,
            total: total,
            showLabel: false,
            height: 44,
            chipSize: 32,
            alwaysShowPriceRange: true,
          ),
        ),
      ),
    );
  }
}

class _SearchMapResult {
  const _SearchMapResult({
    required this.listings,
    required this.pins,
    required this.total,
  });

  final List<Listing> listings;
  final List<ListingMapPin> pins;
  final int total;
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

class _MapBounds {
  const _MapBounds({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
  });

  factory _MapBounds.fromVisibleRegion(VisibleRegion region) {
    final points = [
      region.topLeft,
      region.topRight,
      region.bottomLeft,
      region.bottomRight,
    ];
    final latitudes = points.map((point) => point.latitude);
    final longitudes = points.map((point) => point.longitude);

    return _MapBounds(
      minLatitude: latitudes.reduce((a, b) => a < b ? a : b),
      maxLatitude: latitudes.reduce((a, b) => a > b ? a : b),
      minLongitude: longitudes.reduce((a, b) => a < b ? a : b),
      maxLongitude: longitudes.reduce((a, b) => a > b ? a : b),
    );
  }

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  bool contains(double latitude, double longitude) {
    return latitude >= minLatitude &&
        latitude <= maxLatitude &&
        longitude >= minLongitude &&
        longitude <= maxLongitude;
  }
}

class _PinSummaryTooltip extends StatelessWidget {
  const _PinSummaryTooltip({
    required this.pin,
    required this.onClose,
    required this.onOpen,
  });

  final ListingMapPin pin;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 52, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PinSummaryMediaColumn(
                      pin: pin,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (pin.listingTypeCode?.isNotEmpty == true ||
                                  pin.gender != null) ...[
                                _PinSummaryBadges(
                                  listingTypeCode: pin.listingTypeCode,
                                  gender: pin.gender,
                                  compact: true,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  pin.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (pin.subtitle?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              pin.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          if (pin.locationLabel?.isNotEmpty == true ||
                              pin.stationLabel?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            _PinGeoLabelsRow(
                              locationLabel: pin.locationLabel,
                              stationLabel: pin.stationLabel,
                              lineIds: pin.subwayLineIds,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            L10n.get("view_listing"),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinSummaryMediaColumn extends StatelessWidget {
  const _PinSummaryMediaColumn({required this.pin});

  final ListingMapPin pin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _PinSummaryPhoto.size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinSummaryPhoto(
            photoUrl: pin.photoUrl,
            listingTypeId: pin.listingTypeId,
          ),
        ],
      ),
    );
  }
}

class _PinSummaryBadges extends StatelessWidget {
  const _PinSummaryBadges({
    required this.listingTypeCode,
    required this.gender,
    this.compact = false,
  });

  final String? listingTypeCode;
  final int? gender;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (listingTypeCode?.isNotEmpty == true)
          ListingTypeIconBadge(
            listingTypeCode: listingTypeCode!,
            size: compact ? 13 : 14,
            padding: compact
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          ),
        if (gender != null)
          GenderBadge(
            gender: gender!,
            size: compact ? 13 : 14,
            padding: compact
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          ),
      ],
    );
  }
}

class _PinGeoLabelsRow extends StatelessWidget {
  const _PinGeoLabelsRow({
    required this.locationLabel,
    required this.stationLabel,
    required this.lineIds,
  });

  final String? locationLabel;
  final String? stationLabel;
  final List<int> lineIds;

  @override
  Widget build(BuildContext context) {
    final hasLocation = locationLabel?.isNotEmpty == true;
    final hasStation = stationLabel?.isNotEmpty == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLocation)
          _PinMetaRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: locationLabel!,
          ),
        if (hasLocation && hasStation) const SizedBox(height: 4),
        if (hasStation)
          _PinMetroRow(
            lineIds: lineIds,
            label: stationLabel!,
          ),
      ],
    );
  }
}

class _PinMetaRow extends StatelessWidget {
  const _PinMetaRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ThemeIcon(icon, color: iconColor, size: 18, useThemeColor: false),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PinMetroRow extends StatelessWidget {
  const _PinMetroRow({required this.lineIds, required this.label});

  final List<int> lineIds;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleLineIds = lineIds.isEmpty ? const [1] : lineIds;
    return Row(
      children: [
        for (var i = 0; i < visibleLineIds.length; i++) ...[
          ThemeIcon(
            Icons.train,
            color: _lineColor(visibleLineIds[i]),
            size: 18,
            useThemeColor: false,
          ),
          SizedBox(width: i == visibleLineIds.length - 1 ? 6 : 2),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _lineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }
}

class _PinSummaryPhoto extends StatelessWidget {
  const _PinSummaryPhoto({
    required this.photoUrl,
    required this.listingTypeId,
  });

  static const String _noPhotoPlaceholderAsset =
      "assets/images/uydosh_no_photo_placeholder.png";
  static const String _noPhotoPlaceholderAssetLight =
      "assets/images/uydosh_light_no_photo_placeholder.png";
  static const String _roomNeededPlaceholderAsset =
      "assets/images/uydosh_room_needed_no_photo_placeholder.png";
  static const String _roomNeededPlaceholderAssetLight =
      "assets/images/uydosh_light_room_needed_no_photo_placeholder.png";
  static const double size = 104.0;

  final String? photoUrl;
  final int? listingTypeId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = photoUrl;
    final placeholder = _placeholder(context, scheme);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? placeholder
            : Image(
                image: CachedNetworkImageProvider(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return ColoredBox(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  );
                },
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, ColorScheme scheme) {
    final isLight = ThemeState().isLightTheme;
    final isRoomNeeded = listingTypeId == ListingTypeIds.roomNeeded;
    final asset = isRoomNeeded
        ? (isLight
            ? _roomNeededPlaceholderAssetLight
            : _roomNeededPlaceholderAsset)
        : (isLight ? _noPhotoPlaceholderAssetLight : _noPhotoPlaceholderAsset);
    final gradient = isLight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB1BFD5), Color(0xFFAABBD3)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3962), Color(0xFF112548)],
          );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: ThemeIcon(
            Icons.photo_outlined,
            color: scheme.onSurfaceVariant,
            size: 24,
            useThemeColor: false,
          ),
        ),
      ),
    );
  }
}

class _RefreshAreaButton extends StatelessWidget {
  const _RefreshAreaButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = theme.colorScheme.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: loading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                else
                  ThemeIcon(
                    Icons.refresh,
                    size: 18,
                    color: foregroundColor,
                    useThemeColor: false,
                  ),
                const SizedBox(width: 8),
                Text(
                  L10n.get("search_refresh_this_area"),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapStatusBanner extends StatelessWidget {
  const _MapStatusBanner({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMapStatus extends StatelessWidget {
  const _CenteredMapStatus({
    required this.icon,
    required this.title,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              HouseLoadingIndicator(
                size: 40,
                color: theme.colorScheme.primary,
              )
            else
              ThemeIcon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
