part of "yandex_map_widget.dart";

enum _DistrictPolygonStyle { normal, dimmed, emphasized }

final Map<String, Polygon> _cachedDistrictPolygons = {};
final Map<String, Polygon> _cachedSimplifiedDistrictPolygons = {};
final Map<int, Point> _cachedDistrictLabelPoints = {};
final Map<String, PlacemarkMapObject> _cachedMetroStationPlacemarkTemplates =
    {};
final Set<String> _metroStationCoordinateKeys = {
  for (final station in MetroCache.getAllStations())
    if (station.latitude != null && station.longitude != null)
      _mapCoordinateKey(station.latitude!, station.longitude!),
};
final Map<String, Set<int>> _metroStationCoordinateLineIds = {
  for (final station in MetroCache.getAllStations())
    if (station.latitude != null && station.longitude != null)
      _mapCoordinateKey(station.latitude!, station.longitude!): {
        for (final matchingStation in MetroCache.getAllStations())
          if (matchingStation.latitude == station.latitude &&
              matchingStation.longitude == station.longitude)
            matchingStation.line,
      },
};

String _mapCoordinateKey(double latitude, double longitude) {
  return "${latitude.toStringAsFixed(6)}_${longitude.toStringAsFixed(6)}";
}

/// Yandex MapKit's Android bridge decodes `fromBytes` icon PNGs with
/// `BitmapFactory.decodeByteArray` (no density metadata), while iOS uses
/// `UIImage(data:)` at scale 1.0 and renders it in points as-is. With the
/// same pixel-sized source bytes and the same `PlacemarkIconStyle.scale`,
/// this makes pins render visibly larger on Android than on iOS. Scale
/// Android pins down by this factor so both platforms look consistent.
const double _androidPlacemarkScaleFactor = 0.7;

double _platformPlacemarkScale(double scale) {
  return isAndroidDevice ? scale * _androidPlacemarkScaleFactor : scale;
}

extension _YandexMapWidgetMapObjects on _YandexMapWidgetState {
  List<MapObject> _createMapObjects() {
    final key = _mapObjectsCacheKey();
    final cached = _cachedMapObjects;
    if (_cachedMapObjectsKey == key && cached != null) return cached;

    final mapObjects = _buildMapObjects();
    _cachedMapObjectsKey = key;
    _cachedMapObjects = mapObjects;
    return mapObjects;
  }

  int _mapObjectsCacheKey() {
    final showAllDistrictLabels = widget.layerOptions.showDistrictLayer &&
        _currentZoom >= _YandexMapWidgetState._minDistrictLabelZoom;
    final showHighlightedDistrictLabels =
        widget.layerOptions.highlightedLocationId != null &&
            _currentZoom >=
                _YandexMapWidgetState._minHighlightedDistrictLabelZoom;
    final metroWalkAreaLabelVisible = _effectiveSelectedMetroStation != null &&
        widget.layerOptions.showMetroStationsLayer &&
        _isWalkAreaLabelVisibleAtCurrentZoom;
    final universityWalkAreaLabelVisible =
        _selectedUniversityForWalkRadius != null &&
            _isWalkAreaLabelVisibleAtCurrentZoom;
    return Object.hashAll([
      widget.layerOptions.showDistrictLayer,
      widget.layerOptions.highlightedLocationId,
      widget.layerOptions.showMetroStationsLayer,
      widget.layerOptions.metroStationLineId,
      widget.layerOptions.showGroceryStoresLayer,
      widget.layerOptions.showBusStopsLayer,
      widget.showDefaultPlacemark,
      widget.nightModeEnabled,
      widget.walkRadiusMinutes,
      Localizations.localeOf(context).languageCode,
      showAllDistrictLabels,
      showHighlightedDistrictLabels,
      metroWalkAreaLabelVisible,
      universityWalkAreaLabelVisible,
      _highlightedMetroStationId,
      _selectedUniversityMarker?.id,
      widget.selectedListingId,
      Object.hashAll(widget.visitedListingIds),
      widget.latitude,
      widget.longitude,
      widget.userLocationLatitude,
      widget.userLocationLongitude,
      widget.listingDetail?.id,
      _cachedIconBytes != null,
      _cachedDarkIconBytes != null,
      _cachedVisitedIconBytes != null,
      _cachedDarkVisitedIconBytes != null,
      _cachedSelectedIconBytes != null,
      _cachedUniversityIconBytes != null,
      _cachedUserUniversityIconBytes != null,
      _cachedSelectedUserUniversityIconBytes != null,
      _cachedSelectedUniversityIconBytes != null,
      _cachedGroceryStoreIconBytes != null,
      _cachedBusStopIconBytes != null,
      _cachedListingTypeIconBytes.length,
      _cachedDarkListingTypeIconBytes.length,
      _cachedVisitedListingTypeIconBytes.length,
      _cachedDarkVisitedListingTypeIconBytes.length,
      _cachedSelectedListingTypeIconBytes.length,
      _cachedMetroStationIconBytes.length,
      _cachedSelectedMetroStationIconBytes.length,
      _cachedMetroWalkAreaLabelIconBytes.length,
      _cachedDistrictLabelIconBytes.length,
      Object.hashAll(_groceryStoreMarkers.map(_poiMarkerCacheKey)),
      Object.hashAll(_busStopMarkers.map(_poiMarkerCacheKey)),
      Object.hashAll(_visibleMetroStationIds),
      Object.hashAll(widget.pins.map(_pinCacheKey)),
      Object.hashAll(widget.universityMarkers.map(_universityMarkerCacheKey)),
      widget.selectedUniversityMarkerId,
      widget.selectedMetroStationId,
      widget.userUniversityMarkerId,
      _universityMapLayerEpoch,
    ]);
  }

  String get _universityMapLayerScope => "university_l$_universityMapLayerEpoch";

  int _pinCacheKey(ListingMapPin pin) {
    return Object.hash(
      pin.listingId,
      pin.latitude,
      pin.longitude,
      pin.listingTypeId,
      pin.listingTypeCode,
      pin.hostResident,
      pin.gender,
    );
  }

  int _universityMarkerCacheKey(UniversityMapMarker marker) {
    return Object.hash(
      marker.id,
      marker.latitude,
      marker.longitude,
      marker.title,
      marker.fullTitle,
    );
  }

  int _poiMarkerCacheKey(_YandexMapPoiMarker marker) {
    return Object.hash(
      marker.id,
      marker.name,
      marker.point.latitude,
      marker.point.longitude,
    );
  }

  List<MapObject> _buildMapObjects() {
    final districtLayerObjects = _createDistrictLayerMapObjects();
    final metroStationLayerObjects = widget.layerOptions.showMetroStationsLayer
        ? _createMetroStationLayerMapObjects()
        : const <MapObject>[];
    final groceryStoreLayerObjects = widget.layerOptions.showGroceryStoresLayer
        ? _createPoiLayerMapObjects(
            markers: _groceryStoreMarkers,
            layerId: "grocery_store",
            iconBytes: _cachedGroceryStoreIconBytes,
            fallbackColor: const Color(0xFF2E7D32),
          )
        : const <MapObject>[];
    final busStopLayerObjects = widget.layerOptions.showBusStopsLayer
        ? _createPoiLayerMapObjects(
            markers: _busStopMarkers,
            layerId: "bus_stop",
            iconBytes: _cachedBusStopIconBytes,
            fallbackColor: const Color(0xFF6A1B9A),
          )
        : const <MapObject>[];
    final areaLayerObjects = [
      ...districtLayerObjects,
      ...metroStationLayerObjects,
      ...groceryStoreLayerObjects,
      ...busStopLayerObjects,
    ];
    final universityMarkerObjects = _createUniversityMarkerMapObjects();
    final userLocationObject = _createStaticUserLocationMapObject();
    if (widget.pins.isNotEmpty) {
      final listingPinObjects = _createListingPinMapObjects();
      return [
        ...areaLayerObjects,
        if (listingPinObjects.isNotEmpty)
          _listingPinCollection(listingPinObjects),
        ...universityMarkerObjects,
        if (userLocationObject != null) userLocationObject,
      ];
    }
    if (universityMarkerObjects.isNotEmpty) {
      return [
        ...areaLayerObjects,
        ...universityMarkerObjects,
        if (userLocationObject != null) userLocationObject,
      ];
    }
    if (!widget.showDefaultPlacemark) {
      return [
        ...areaLayerObjects,
        if (userLocationObject != null) userLocationObject,
      ];
    }

    final coordinates = _getCoordinates();
    if (coordinates == null) {
      logger.w("❌ No coordinates available for map objects");
      return areaLayerObjects;
    }

    if (kDebugMode) {
      logger.d(
        "📍 Creating map objects at: ${coordinates["latitude"]}, ${coordinates["longitude"]}",
      );
    }

    BitmapDescriptor iconDescriptor;
    if (_cachedIconBytes != null) {
      if (kDebugMode) {
        logger.d("🎨 Using Cupertino location icon");
      }
      final listingTypeCode = widget.listingDetail?.listingType.code;
      final hostResident = widget.listingDetail?.hostResident;
      final mapIconKey = ListingTypeHelper.mapIconCacheKey(
        listingTypeCode,
        hostResident: hostResident,
      );
      final listingTypeIconBytes = mapIconKey == null
          ? null
          : _cachedListingTypeIconBytes[mapIconKey];
      iconDescriptor = _bitmapDescriptorFromBytes(
        listingTypeIconBytes ?? _cachedIconBytes!,
      );
    } else {
      if (kDebugMode) {
        logger.d("🖼️ Using PNG fallback");
      }
      iconDescriptor = BitmapDescriptor.fromAssetImage(
        "assets/images/location_pin.png",
      );
    }

    final placemark = PlacemarkMapObject(
      mapId: const MapObjectId("listing_location_placemark"),
      point: _listingPlacemarkPoint(
        latitude: coordinates["latitude"]!,
        longitude: coordinates["longitude"]!,
      ),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: iconDescriptor,
          scale: _platformPlacemarkScale(1.0),
        ),
      ),
    );

    if (kDebugMode) {
      logger.d("✅ Created placemark: ${placemark.mapId}");
      logger.d(
        "🎯 Placemark point: ${placemark.point.latitude}, ${placemark.point.longitude}",
      );
    }
    return [
      ...areaLayerObjects,
      placemark,
      if (userLocationObject != null) userLocationObject,
    ];
  }

  MapObject? _createStaticUserLocationMapObject() {
    final latitude = widget.userLocationLatitude;
    final longitude = widget.userLocationLongitude;
    if (latitude == null || longitude == null) return null;

    final point = Point(latitude: latitude, longitude: longitude);
    final iconBytes = widget.nightModeEnabled
        ? _cachedDarkUserLocationPinIconBytes
        : _cachedUserLocationPinIconBytes;
    if (iconBytes == null) {
      final borderColor = widget.nightModeEnabled ? Colors.white : Colors.black;
      return CircleMapObject(
        mapId: const MapObjectId("current_user_location_circle"),
        circle: Circle(center: point, radius: 120),
        zIndex: _YandexMapWidgetState._selectedListingPinZIndex + 5,
        strokeWidth: 3,
        strokeColor: borderColor.withValues(alpha: 0.95),
        fillColor: AppColors.error.withValues(alpha: 0.9),
      );
    }

    return PlacemarkMapObject(
      mapId: const MapObjectId("current_user_location_placemark"),
      point: point,
      zIndex: _YandexMapWidgetState._selectedListingPinZIndex + 5,
      opacity: 1.0,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: _bitmapDescriptorFromBytes(iconBytes),
          anchor: const Offset(0.5, 0.5),
          scale: 1.0,
        ),
      ),
    );
  }

  MapObject _listingPinCollection(List<PlacemarkMapObject> placemarks) {
    if (placemarks.length <
        _YandexMapWidgetState._minClusterableListingPins) {
      return MapObjectCollection(
        mapId: const MapObjectId("listing_pin_layer"),
        mapObjects: placemarks,
        zIndex: _YandexMapWidgetState._listingPinZIndex,
      );
    }

    return ClusterizedPlacemarkCollection(
      mapId: const MapObjectId("listing_pin_cluster_layer"),
      placemarks: placemarks,
      radius: _YandexMapWidgetState._listingClusterRadius,
      minZoom: _YandexMapWidgetState._listingClusterMinZoom,
      zIndex: _YandexMapWidgetState._listingPinZIndex,
      consumeTapEvents: true,
      onClusterAdded: _handleListingClusterAdded,
      onClusterTap: _handleListingClusterTap,
    );
  }

  static final RegExp _listingPlacemarkIdPattern =
      RegExp(r"^listing_(\d+)_placemark$");

  /// Extracts the listing id encoded in a [PlacemarkMapObject.mapId] created
  /// by [_createListingPlacemark], or `null` if it doesn't match that format
  /// (e.g. a placemark from a different layer).
  int? _listingIdFromPlacemark(PlacemarkMapObject placemark) {
    final match = _listingPlacemarkIdPattern.firstMatch(placemark.mapId.value);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  /// A cluster is considered "visited" only once every listing pin grouped
  /// into it has already been checked (swiped past in the carousel or
  /// opened), mirroring the per-pin grey-out so the bubble doesn't claim
  /// "nothing new here" while still hiding unseen listings.
  bool _isListingClusterVisited(Cluster cluster) {
    if (cluster.placemarks.isEmpty) return false;
    final visitedListingIds = widget.visitedListingIds;
    return cluster.placemarks.every((placemark) {
      final listingId = _listingIdFromPlacemark(placemark);
      return listingId != null && visitedListingIds.contains(listingId);
    });
  }

  Future<Cluster?> _handleListingClusterAdded(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) async {
    final iconBytes = await _listingClusterIconBytes(
      cluster.size,
      visited: _isListingClusterVisited(cluster),
    );
    return cluster.copyWith(
      appearance: cluster.appearance.copyWith(
        zIndex: _YandexMapWidgetState._selectedListingPinZIndex,
        opacity: 1.0,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: _bitmapDescriptorFromBytes(iconBytes),
            anchor: const Offset(0.5, 0.5),
            scale: _platformPlacemarkScale(1.0),
          ),
        ),
      ),
    );
  }

  void _handleListingClusterTap(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) {
    final controller = _mapController;
    if (controller == null) return;
    HapticFeedbackUtils.lightImpact();
    _clearSelectedUniversityMarker();
    _setSelectedMetroStation(null, notify: true);
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: cluster.appearance.point,
          zoom: (_currentZoom + 1.5)
              .clamp(
                _YandexMapWidgetState._minZoom,
                _YandexMapWidgetState._maxZoom,
              )
              .toDouble(),
          azimuth: 0,
          tilt: 0,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.28,
      ),
    );
  }

  List<MapObject> _createDistrictLayerMapObjects() {
    final highlightedId = widget.layerOptions.highlightedLocationId;
    final showAllDistricts = widget.layerOptions.showDistrictLayer;
    if (!showAllDistricts && highlightedId == null) {
      return const [];
    }

    final objects = <MapObject>[];

    if (showAllDistricts) {
      for (final district in TashkentDistrictBoundaryCache.districts) {
        if (district.locationId == highlightedId) continue;
        objects.addAll(
          _createDistrictPolygonMapObjects(
            district,
            style: highlightedId != null
                ? _DistrictPolygonStyle.dimmed
                : _DistrictPolygonStyle.normal,
          ),
        );
      }
    }

    if (highlightedId != null) {
      final district =
          TashkentDistrictBoundaryCache.findByLocationId(highlightedId);
      if (district != null) {
        objects.addAll(
          _createDistrictPolygonMapObjects(
            district,
            style: _DistrictPolygonStyle.emphasized,
          ),
        );
      }
    }

    objects.addAll(_createDistrictLabelMapObjects());
    return objects;
  }

  List<MapObject> _createDistrictPolygonMapObjects(
    TashkentDistrictBoundary district, {
    required _DistrictPolygonStyle style,
  }) {
    final colors = _districtPolygonColors(district.locationId, style);
    return [
      for (var polygonIndex = 0;
          polygonIndex < district.polygons.length;
          polygonIndex++)
        PolygonMapObject(
          mapId: MapObjectId(
            "tashkent_district_${district.locationId}_$polygonIndex",
          ),
          polygon: _districtPolygon(district, polygonIndex),
          zIndex: colors.zIndex,
          strokeWidth: colors.strokeWidth,
          strokeColor: colors.strokeColor,
          fillColor: colors.fillColor,
        ),
    ];
  }

  ({
    double zIndex,
    double strokeWidth,
    Color strokeColor,
    Color fillColor,
  }) _districtPolygonColors(int locationId, _DistrictPolygonStyle style) {
    final baseColor = _districtLayerColor(locationId);
    return switch (style) {
      _DistrictPolygonStyle.normal => (
          zIndex: 0.1,
          strokeWidth: 2.0,
          strokeColor: baseColor.withValues(alpha: 0.78),
          fillColor: baseColor.withValues(alpha: 0.22),
        ),
      _DistrictPolygonStyle.dimmed => (
          zIndex: 0.08,
          strokeWidth: 1.5,
          strokeColor: baseColor.withValues(alpha: 0.34),
          fillColor: baseColor.withValues(alpha: 0.08),
        ),
      _DistrictPolygonStyle.emphasized => (
          zIndex: 0.18,
          strokeWidth: 3.0,
          strokeColor: baseColor.withValues(alpha: 0.95),
          fillColor: baseColor.withValues(alpha: 0.34),
        ),
    };
  }

  Polygon _districtPolygon(
    TashkentDistrictBoundary district,
    int polygonIndex,
  ) {
    final key = "${district.locationId}_$polygonIndex";
    final cache = isAndroidDevice
        ? _cachedSimplifiedDistrictPolygons
        : _cachedDistrictPolygons;
    return cache.putIfAbsent(key, () {
      final polygon = district.polygons[polygonIndex];
      return Polygon(
        outerRing: _toLinearRing(_districtRingForPlatform(polygon.outerRing)),
        innerRings: [
          for (final ring in polygon.innerRings)
            _toLinearRing(_districtRingForPlatform(ring)),
        ],
      );
    });
  }

  List<DistrictBoundaryPoint> _districtRingForPlatform(
    List<DistrictBoundaryPoint> ring,
  ) {
    if (!isAndroidDevice) return ring;
    return _simplifyDistrictRing(ring);
  }

  List<DistrictBoundaryPoint> _simplifyDistrictRing(
    List<DistrictBoundaryPoint> ring,
  ) {
    const maxAndroidDistrictRingPoints = 80;
    if (ring.length <= maxAndroidDistrictRingPoints) return ring;

    final step = (ring.length / maxAndroidDistrictRingPoints).ceil();
    final simplified = <DistrictBoundaryPoint>[];
    for (var i = 0; i < ring.length; i += step) {
      simplified.add(ring[i]);
    }
    final last = ring.last;
    if (!identical(simplified.last, last)) {
      simplified.add(last);
    }
    return List<DistrictBoundaryPoint>.unmodifiable(simplified);
  }

  List<MapObject> _createDistrictLabelMapObjects() {
    final highlightedId = widget.layerOptions.highlightedLocationId;
    final showAllLabels = widget.layerOptions.showDistrictLayer &&
        _currentZoom >= _YandexMapWidgetState._minDistrictLabelZoom;
    final showHighlightedLabel = highlightedId != null &&
        _currentZoom >= _YandexMapWidgetState._minHighlightedDistrictLabelZoom;
    if (!showAllLabels && !showHighlightedLabel) {
      return const [];
    }

    final language = Localizations.localeOf(context).languageCode;
    final objects = <PlacemarkMapObject>[];
    for (final district in TashkentDistrictBoundaryCache.districts) {
      if (!showAllLabels && district.locationId != highlightedId) continue;

      final highlighted = district.locationId == highlightedId;
      final label = LocationCache.getLocationShortName(
        district.locationId,
        language,
      );
      _ensureDistrictLabelIconBytes(
        locationId: district.locationId,
        label: label,
        highlighted: highlighted,
      );
      final iconBytes = _cachedDistrictLabelIconBytes[
          _districtLabelIconCacheKey(
            locationId: district.locationId,
            language: language,
            highlighted: highlighted,
          )];
      if (iconBytes == null) continue;

      objects.add(
        PlacemarkMapObject(
          mapId: MapObjectId("tashkent_district_${district.locationId}_label"),
          point: _districtLabelPoint(district),
          zIndex: highlighted
              ? _YandexMapWidgetState._highlightedDistrictLabelZIndex
              : _YandexMapWidgetState._districtLabelZIndex,
          opacity: 1.0,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: _bitmapDescriptorFromBytes(iconBytes),
              anchor: const Offset(0.5, 0.5),
              scale: 1.0,
            ),
          ),
        ),
      );
    }
    return objects;
  }

  Point _districtLabelPoint(TashkentDistrictBoundary district) {
    return _cachedDistrictLabelPoints.putIfAbsent(
      district.locationId,
      () => _computeDistrictLabelPoint(district),
    );
  }

  Point _computeDistrictLabelPoint(TashkentDistrictBoundary district) {
    final ring = _largestOuterRing(district);
    if (ring.isEmpty) {
      final coordinates = LocationCache.getLocationCoordinatesById(
        district.locationId,
      );
      return Point(
        latitude: coordinates?["latitude"] ?? 41.2995,
        longitude: coordinates?["longitude"] ?? 69.2401,
      );
    }

    final centroid = _ringCentroid(ring);
    if (centroid != null) return centroid;

    final latitude = ring.fold<double>(
          0,
          (sum, point) => sum + point.latitude,
        ) /
        ring.length;
    final longitude = ring.fold<double>(
          0,
          (sum, point) => sum + point.longitude,
        ) /
        ring.length;
    return Point(latitude: latitude, longitude: longitude);
  }

  List<DistrictBoundaryPoint> _largestOuterRing(
    TashkentDistrictBoundary district,
  ) {
    List<DistrictBoundaryPoint> largest = const [];
    var largestArea = 0.0;
    for (final polygon in district.polygons) {
      final area = _ringArea(polygon.outerRing).abs();
      if (area > largestArea) {
        largestArea = area;
        largest = polygon.outerRing;
      }
    }
    return largest;
  }

  double _ringArea(List<DistrictBoundaryPoint> ring) {
    if (ring.length < 3) return 0;
    var area = 0.0;
    for (var i = 0; i < ring.length; i++) {
      final current = ring[i];
      final next = ring[(i + 1) % ring.length];
      area += current.longitude * next.latitude;
      area -= next.longitude * current.latitude;
    }
    return area / 2;
  }

  Point? _ringCentroid(List<DistrictBoundaryPoint> ring) {
    final area = _ringArea(ring);
    if (area.abs() < 0.000000001) return null;

    var latitude = 0.0;
    var longitude = 0.0;
    for (var i = 0; i < ring.length; i++) {
      final current = ring[i];
      final next = ring[(i + 1) % ring.length];
      final factor =
          current.longitude * next.latitude - next.longitude * current.latitude;
      longitude += (current.longitude + next.longitude) * factor;
      latitude += (current.latitude + next.latitude) * factor;
    }

    return Point(
      latitude: latitude / (6 * area),
      longitude: longitude / (6 * area),
    );
  }

  LinearRing _toLinearRing(List<DistrictBoundaryPoint> points) {
    return LinearRing(
      points: [
        for (final point in points)
          Point(latitude: point.latitude, longitude: point.longitude),
      ],
    );
  }

  Color _districtLayerColor(int locationId) {
    const colors = [
      Color(0xFFE53935),
      Color(0xFF8E24AA),
      Color(0xFF3949AB),
      Color(0xFF1E88E5),
      Color(0xFF00ACC1),
      Color(0xFF43A047),
      Color(0xFF7CB342),
      Color(0xFFFDD835),
      Color(0xFFFFB300),
      Color(0xFFFB8C00),
      Color(0xFF6D4C41),
      Color(0xFF546E7A),
    ];
    return colors[(locationId - 1).abs() % colors.length];
  }

  CircleMapObject _createWalkingRadiusCircle({
    required Point center,
    required String mapObjectId,
  }) {
    final radiusColor =
        widget.nightModeEnabled ? Colors.white : const Color(0xFF1E88E5);
    return CircleMapObject(
      mapId: MapObjectId(mapObjectId),
      circle: Circle(
        center: center,
        radius: _walkingRadiusMeters,
      ),
      zIndex: 1.05,
      strokeWidth: 2.0,
      strokeColor: radiusColor.withValues(alpha: 0.42),
      fillColor: radiusColor.withValues(alpha: 0.16),
    );
  }

  List<MapObject> _createMetroStationLayerMapObjects() {
    return [
      if (_effectiveSelectedMetroStation != null) ...[
        _createMetroStationWalkingRadius(),
        if (_isWalkAreaLabelVisibleAtCurrentZoom)
          if (_createMetroStationWalkingRadiusLabel() case final label?)
            label,
      ],
      for (final stationId in _metroPlacemarkStationIds)
        if (_metroStationForViewportId(stationId) case final station?)
          _createMetroStationPlacemark(station),
    ];
  }

  List<int> get _metroPlacemarkStationIds {
    final selectedId = _highlightedMetroStationId;
    if (selectedId == null) return _visibleMetroStationIds;
    if (_visibleMetroStationIds.contains(selectedId)) {
      return _visibleMetroStationIds;
    }
    return List<int>.unmodifiable([..._visibleMetroStationIds, selectedId]..sort());
  }

  SubwayStation? _metroStationForViewportId(int stationId) {
    final station = MetroCache.getStationById(stationId);
    if (station?.latitude == null || station?.longitude == null) return null;
    if (!_shouldShowMetroStation(station!)) return null;
    return station;
  }

  BoundingBox _paddedMetroViewportBoundingBox(VisibleRegion region) {
    const paddingFraction = 0.15;
    final box = _visibleRegionBoundingBox(region);
    final latSpan =
        (box.northEast.latitude - box.southWest.latitude).abs();
    final lonSpan =
        (box.northEast.longitude - box.southWest.longitude).abs();
    final latPadding = latSpan * paddingFraction;
    final lonPadding = lonSpan * paddingFraction;
    return BoundingBox(
      northEast: Point(
        latitude: box.northEast.latitude + latPadding,
        longitude: box.northEast.longitude + lonPadding,
      ),
      southWest: Point(
        latitude: box.southWest.latitude - latPadding,
        longitude: box.southWest.longitude - lonPadding,
      ),
    );
  }

  List<int> _metroStationIdsInViewport(BoundingBox box) {
    final ids = <int>{};
    final selectedId = _highlightedMetroStationId;
    if (selectedId != null) ids.add(selectedId);
    for (final station in MetroCache.getAllStations()) {
      if (station.latitude == null || station.longitude == null) continue;
      if (!_shouldShowMetroStation(station)) continue;
      if (_pointInBoundingBox(
        Point(latitude: station.latitude!, longitude: station.longitude!),
        box,
      )) {
        ids.add(station.id);
      }
    }
    final sorted = ids.toList()..sort();
    return List<int>.unmodifiable(sorted);
  }

  bool _pointInBoundingBox(Point point, BoundingBox box) {
    return point.latitude >= box.southWest.latitude &&
        point.latitude <= box.northEast.latitude &&
        point.longitude >= box.southWest.longitude &&
        point.longitude <= box.northEast.longitude;
  }

  bool _shouldShowMetroStation(SubwayStation station) {
    final selectedLineId = widget.layerOptions.metroStationLineId;
    return selectedLineId == null || station.line == selectedLineId;
  }

  bool get _isWalkAreaLabelVisibleAtCurrentZoom {
    return _currentZoom >=
        _YandexMapWidgetState._minMetroStationWalkAreaLabelZoom;
  }

  CircleMapObject _createMetroStationWalkingRadius() {
    final station = _effectiveSelectedMetroStation!;
    return _createWalkingRadiusCircle(
      center: Point(
        latitude: station.latitude!,
        longitude: station.longitude!,
      ),
      mapObjectId:
          "tashkent_metro_station_${station.id}_walking_radius_${widget.walkRadiusMinutes}",
    );
  }

  PlacemarkMapObject? _createMetroStationWalkingRadiusLabel() {
    final station = _effectiveSelectedMetroStation!;
    return _createWalkAreaRadiusLabel(
      mapObjectId:
          "tashkent_metro_station_${station.id}_walking_radius_label_${widget.walkRadiusMinutes}",
      latitude: station.latitude!,
      longitude: station.longitude!,
    );
  }

  PlacemarkMapObject? _createWalkAreaRadiusLabel({
    required String mapObjectId,
    required double latitude,
    required double longitude,
  }) {
    final label = context.l10n.metro_station_walk_area_label(
      widget.walkRadiusMinutes,
    );
    _ensureMetroWalkAreaLabelIconBytes(label);
    final iconBytes =
        _cachedMetroWalkAreaLabelIconBytes[_metroWalkAreaLabelIconCacheKey(label)];
    if (iconBytes == null) return null;

    return PlacemarkMapObject(
      mapId: MapObjectId(mapObjectId),
      point: _pointOffsetNorth(
        latitude: latitude,
        longitude: longitude,
        meters: _walkingRadiusMeters * 0.56,
      ),
      zIndex: 1.1,
      opacity: 1.0,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: _bitmapDescriptorFromBytes(iconBytes),
          anchor: const Offset(0.5, 0.5),
          scale: 1.0,
        ),
      ),
    );
  }

  Point _pointOffsetNorth({
    required double latitude,
    required double longitude,
    required double meters,
  }) {
    const metersPerLatitudeDegree = 111320.0;
    return Point(
      latitude: latitude + meters / metersPerLatitudeDegree,
      longitude: longitude,
    );
  }

  MapObject _createMetroStationPlacemark(SubwayStation station) {
    final point = Point(
      latitude: station.latitude!,
      longitude: station.longitude!,
    );
    final selected = _highlightedMetroStationId == station.id;
    final iconBytes = selected
        ? _cachedSelectedMetroStationIconBytes[station.line]
        : _cachedMetroStationIconBytes[station.line];
    if (iconBytes == null) {
      return CircleMapObject(
        mapId: MapObjectId(
          "tashkent_metro_station_${station.id}_circle_${_metroLayerScopeKey}",
        ),
        circle: Circle(center: point, radius: selected ? 270 : 180),
        zIndex: selected ? 1.35 : 1.15,
        consumeTapEvents: true,
        strokeWidth: selected
            ? _YandexMapWidgetState._selectedMetroStationBorderPx
            : _YandexMapWidgetState._metroStationBorderPx,
        strokeColor: (station.line == 4 ? Colors.black : Colors.white)
            .withValues(alpha: 0.95),
        fillColor: _metroLineColor(station.line).withValues(alpha: 0.9),
        onTap: (_, point) => _handleMetroStationTap(station, point),
      );
    }

    final key =
        "${_metroLayerScopeKey}_${station.id}_${station.line}_${selected ? "selected" : "base"}";
    final template = _cachedMetroStationPlacemarkTemplates.putIfAbsent(
      key,
      () => PlacemarkMapObject(
        mapId: MapObjectId(
          "tashkent_metro_station_${station.id}_placemark_${_metroLayerScopeKey}",
        ),
        point: point,
        zIndex: selected ? 1.35 : 1.2,
        opacity: 1.0,
        consumeTapEvents: true,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: _bitmapDescriptorFromBytes(iconBytes),
            anchor: const Offset(0.5, 0.5),
            scale: selected
                ? _YandexMapWidgetState._selectedMetroStationPlacemarkScale
                : _YandexMapWidgetState._metroStationPlacemarkScale,
          ),
        ),
      ),
    );
    return template.copyWith(
      onTap: (_, point) => _handleMetroStationTap(station, point),
    );
  }

  Color _metroLineColor(int line) {
    return switch (line) {
      1 => const Color(0xFFE53935),
      2 => const Color(0xFF1E88E5),
      3 => const Color(0xFF43A047),
      4 => const Color(0xFFFFB300),
      _ => const Color(0xFF546E7A),
    };
  }

  List<MapObject> _createPoiLayerMapObjects({
    required List<_YandexMapPoiMarker> markers,
    required String layerId,
    required Uint8List? iconBytes,
    required Color fallbackColor,
  }) {
    return [
      for (final marker in markers)
        if (iconBytes == null)
          CircleMapObject(
            mapId: MapObjectId("${layerId}_${marker.id}_circle"),
            circle: Circle(center: marker.point, radius: 120),
            zIndex: 2.0,
            strokeWidth: 2.5,
            strokeColor: Colors.white.withValues(alpha: 0.95),
            fillColor: fallbackColor.withValues(alpha: 0.9),
          )
        else
          PlacemarkMapObject(
            mapId: MapObjectId("${layerId}_${marker.id}_placemark"),
            point: marker.point,
            zIndex: 2.1,
            opacity: 1.0,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: _bitmapDescriptorFromBytes(iconBytes),
                anchor: const Offset(0.5, 0.5),
                scale: _platformPlacemarkScale(0.58),
              ),
            ),
          ),
    ];
  }

  List<MapObject> _createUniversityMarkerMapObjects() {
    final iconBytes = _cachedUniversityIconBytes;
    final userIconBytes = _cachedUserUniversityIconBytes;
    final selectedUserIconBytes = _cachedSelectedUserUniversityIconBytes;
    final selectedIconBytes = _cachedSelectedUniversityIconBytes;
    if (widget.universityMarkers.isEmpty) return [];
    if (iconBytes == null ||
        userIconBytes == null ||
        selectedUserIconBytes == null ||
        selectedIconBytes == null) {
      logger.w("📍 University marker icon is not ready yet");
      return [];
    }

    final highlightedMarkerId = _highlightedUniversityMarkerId;
    final regularPlacemarks = <PlacemarkMapObject>[
      for (final marker in widget.universityMarkers)
        if (marker.id != highlightedMarkerId)
          _createUniversityMarkerPlacemark(
            marker,
            iconBytes: iconBytes,
            userIconBytes: userIconBytes,
            selectedUserIconBytes: selectedUserIconBytes,
            selectedIconBytes: selectedIconBytes,
            selected: false,
          ),
    ];
    final highlightedPlacemark = highlightedMarkerId == null
        ? null
        : _highlightedUniversityPlacemark(
            highlightedMarkerId,
            iconBytes: iconBytes,
            userIconBytes: userIconBytes,
            selectedUserIconBytes: selectedUserIconBytes,
            selectedIconBytes: selectedIconBytes,
          );
    final regularLayer = regularPlacemarks.length <
            _YandexMapWidgetState._minClusterableUniversityMarkers
        ? regularPlacemarks
        : [_universityMarkerCollection(regularPlacemarks)];

    return [
      if (_selectedUniversityForWalkRadius case final marker?) ...[
        _createWalkingRadiusCircle(
          center: Point(
            latitude: marker.latitude,
            longitude: marker.longitude,
          ),
          mapObjectId:
              "${_universityMapLayerScope}_${marker.id}_walking_radius_${widget.walkRadiusMinutes}",
        ),
        if (_isWalkAreaLabelVisibleAtCurrentZoom)
          if (_createWalkAreaRadiusLabel(
                mapObjectId:
                    "${_universityMapLayerScope}_${marker.id}_walking_radius_label_${widget.walkRadiusMinutes}",
                latitude: marker.latitude,
                longitude: marker.longitude,
              )
              case final label?)
            label,
      ],
      ...regularLayer,
      if (highlightedPlacemark != null) highlightedPlacemark,
    ];
  }

  UniversityMapMarker? get _selectedUniversityForWalkRadius {
    final markerId = _highlightedUniversityMarkerId;
    if (markerId == null) return null;
    for (final marker in widget.universityMarkers) {
      if (marker.id == markerId) return marker;
    }
    return null;
  }

  String? get _highlightedUniversityMarkerId {
    return widget.selectedUniversityMarkerId ?? _selectedUniversityMarker?.id;
  }

  PlacemarkMapObject? _highlightedUniversityPlacemark(
    String highlightedMarkerId, {
    required Uint8List iconBytes,
    required Uint8List userIconBytes,
    required Uint8List selectedUserIconBytes,
    required Uint8List selectedIconBytes,
  }) {
    for (final marker in widget.universityMarkers) {
      if (marker.id == highlightedMarkerId) {
        return _createUniversityMarkerPlacemark(
          marker,
          iconBytes: iconBytes,
          userIconBytes: userIconBytes,
          selectedUserIconBytes: selectedUserIconBytes,
          selectedIconBytes: selectedIconBytes,
          selected: true,
        );
      }
    }
    return null;
  }

  MapObject _universityMarkerCollection(List<PlacemarkMapObject> placemarks) {
    return ClusterizedPlacemarkCollection(
      mapId: MapObjectId("${_universityMapLayerScope}_cluster_layer"),
      placemarks: placemarks,
      radius: _YandexMapWidgetState._universityClusterRadius,
      minZoom: _YandexMapWidgetState._universityClusterMinZoom,
      zIndex: 5,
      consumeTapEvents: true,
      onClusterAdded: _handleUniversityClusterAdded,
      onClusterTap: _handleUniversityClusterTap,
    );
  }

  bool _clusterContainsUserUniversity(Cluster cluster) {
    final userUniversityMarkerId = widget.userUniversityMarkerId;
    if (userUniversityMarkerId == null) return false;
    final userUniversityMapId =
        MapObjectId("${_universityMapLayerScope}_${userUniversityMarkerId}_placemark");
    return cluster.placemarks.any(
      (placemark) => placemark.mapId == userUniversityMapId,
    );
  }

  Future<Cluster?> _handleUniversityClusterAdded(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) async {
    final iconBytes = await _universityClusterIconBytes(
      cluster.size,
      isUserUniversity: _clusterContainsUserUniversity(cluster),
    );
    return cluster.copyWith(
      appearance: cluster.appearance.copyWith(
        zIndex: 9,
        opacity: 1.0,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: _bitmapDescriptorFromBytes(iconBytes),
            anchor: const Offset(0.5, 0.5),
            scale: _platformPlacemarkScale(1.0),
          ),
        ),
      ),
    );
  }

  void _handleUniversityClusterTap(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) {
    final controller = _mapController;
    if (controller == null) return;
    HapticFeedbackUtils.lightImpact();
    _clearSelectedUniversityMarker();
    _setSelectedMetroStation(null, notify: true);
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: cluster.appearance.point,
          zoom: (_currentZoom + 1.5)
              .clamp(
                _YandexMapWidgetState._minZoom,
                _YandexMapWidgetState._maxZoom,
              )
              .toDouble(),
          azimuth: 0,
          tilt: 0,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.28,
      ),
    );
  }

  PlacemarkMapObject _createUniversityMarkerPlacemark(
    UniversityMapMarker marker, {
    required Uint8List iconBytes,
    required Uint8List userIconBytes,
    required Uint8List selectedUserIconBytes,
    required Uint8List selectedIconBytes,
    required bool selected,
  }) {
    final isUserUniversity = marker.id == widget.userUniversityMarkerId;
    return PlacemarkMapObject(
      mapId: MapObjectId("${_universityMapLayerScope}_${marker.id}_placemark"),
      point: Point(
        latitude: marker.latitude,
        longitude: marker.longitude,
      ),
      zIndex: selected ? 9 : 5,
      opacity: 1.0,
      consumeTapEvents: true,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: _bitmapDescriptorFromBytes(
            selected
                ? isUserUniversity
                    ? selectedUserIconBytes
                    : selectedIconBytes
                : isUserUniversity
                    ? userIconBytes
                    : iconBytes,
          ),
          anchor: const Offset(0.5, 0.5),
          scale: _platformPlacemarkScale(selected ? 1.0 : 0.9),
        ),
      ),
      onTap: (_, point) => _handleUniversityMarkerTap(marker, point),
    );
  }

  List<PlacemarkMapObject> _createListingPinMapObjects() {
    if (kDebugMode) {
      logger.d("📍 Creating ${widget.pins.length} listing map pins");
    }

    final iconBytes = _cachedIconBytes;
    final darkIconBytes = _cachedDarkIconBytes;
    final selectedIconBytes = _cachedSelectedIconBytes;
    if (iconBytes == null ||
        selectedIconBytes == null ||
        (widget.nightModeEnabled && darkIconBytes == null)) {
      logger.w("📍 Listing pin icon is not ready yet");
      return [];
    }
    final selectedListingId = widget.selectedListingId;
    final visitedListingIds = widget.visitedListingIds;
    final orderedPins = <ListingMapPin>[
      for (final pin in widget.pins)
        if (pin.listingId != selectedListingId) pin,
      for (final pin in widget.pins)
        if (pin.listingId == selectedListingId) pin,
    ];

    return [
      for (final pin in orderedPins)
        _createListingPlacemark(
          pin,
          selected: pin.listingId == selectedListingId,
          visited: pin.listingId != selectedListingId &&
              visitedListingIds.contains(pin.listingId),
        ),
    ];
  }

  PlacemarkMapObject _createListingPlacemark(
    ListingMapPin pin, {
    required bool selected,
    bool visited = false,
  }) {
    final zIndex = selected
        ? _YandexMapWidgetState._selectedListingPinZIndex
        : _YandexMapWidgetState._listingPinZIndex;
    return PlacemarkMapObject(
      mapId: MapObjectId("listing_${pin.listingId}_placemark"),
      point: _listingPlacemarkPoint(
        latitude: pin.latitude,
        longitude: pin.longitude,
      ),
      zIndex: zIndex,
      opacity: 1.0,
      consumeTapEvents: true,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: _listingPinIconDescriptor(
            pin,
            selected: selected,
            visited: visited && !selected,
          ),
          anchor: const Offset(0.5, 0.5),
          zIndex: zIndex,
          scale: _platformPlacemarkScale(selected ? 1.0 : 1.17),
        ),
      ),
      onTap: (_, __) {
        HapticFeedbackUtils.lightImpact();
        _clearSelectedUniversityMarker();
        _setSelectedMetroStation(null, notify: true);
        widget.onPinTap?.call(pin);
      },
    );
  }

  BitmapDescriptor _listingPinIconDescriptor(
    ListingMapPin pin, {
    bool selected = false,
    bool visited = false,
  }) {
    return _listingTypeIconDescriptor(
      listingTypeCode: pin.listingTypeCode,
      listingTypeId: pin.listingTypeId,
      hostResident: pin.hostResident,
      selected: selected,
      visited: visited,
    );
  }

  BitmapDescriptor _listingTypeIconDescriptor({
    String? listingTypeCode,
    int? listingTypeId,
    bool? hostResident,
    bool selected = false,
    bool visited = false,
  }) {
    final fallbackBytes = selected
        ? _cachedSelectedIconBytes
        : visited
            ? widget.nightModeEnabled
                ? _cachedDarkVisitedIconBytes ?? _cachedDarkIconBytes
                : _cachedVisitedIconBytes ?? _cachedIconBytes
            : widget.nightModeEnabled
                ? _cachedDarkIconBytes
                : _cachedIconBytes;
    final bytesByCode = selected
        ? _cachedSelectedListingTypeIconBytes
        : visited
            ? widget.nightModeEnabled
                ? _cachedDarkVisitedListingTypeIconBytes.isNotEmpty
                    ? _cachedDarkVisitedListingTypeIconBytes
                    : _cachedDarkListingTypeIconBytes
                : _cachedVisitedListingTypeIconBytes.isNotEmpty
                    ? _cachedVisitedListingTypeIconBytes
                    : _cachedListingTypeIconBytes
            : widget.nightModeEnabled
                ? _cachedDarkListingTypeIconBytes
                : _cachedListingTypeIconBytes;
    final resolvedCode = ListingTypeHelper.mapIconCacheKey(
      _resolveListingTypeCode(
        listingTypeCode: listingTypeCode,
        listingTypeId: listingTypeId,
      ),
      hostResident: hostResident,
    );
    if (resolvedCode != null) {
      _ensureListingTypePinIconBytes(
        resolvedCode,
        selected: selected,
        visited: visited,
      );
    }
    final iconBytes = resolvedCode == null ? null : bytesByCode[resolvedCode];
    return _bitmapDescriptorFromBytes(iconBytes ?? fallbackBytes!);
  }

  String? _resolveListingTypeCode({
    String? listingTypeCode,
    int? listingTypeId,
  }) {
    final code = listingTypeCode;
    if (code != null &&
        code.isNotEmpty &&
        ListingTypeHelper.getAllCodes().contains(code)) {
      return code;
    }

    final id = listingTypeId;
    if (id == null) return null;
    final codeFromId = ListingTypeHelper.getCodeFromId(id);
    return ListingTypeHelper.getAllCodes().contains(codeFromId)
        ? codeFromId
        : null;
  }

  BitmapDescriptor _bitmapDescriptorFromBytes(Uint8List bytes) {
    return _cachedBitmapDescriptors.putIfAbsent(
      bytes,
      () => BitmapDescriptor.fromBytes(bytes),
    );
  }

  Point _listingPlacemarkPoint({
    required double latitude,
    required double longitude,
  }) {
    final coordinateKey = _mapCoordinateKey(latitude, longitude);
    if (!widget.layerOptions.showMetroStationsLayer ||
        !_metroStationCoordinateKeys.contains(coordinateKey)) {
      return Point(latitude: latitude, longitude: longitude);
    }
    final selectedLineId = widget.layerOptions.metroStationLineId;
    if (selectedLineId != null &&
        !(_metroStationCoordinateLineIds[coordinateKey]?.contains(
              selectedLineId,
            ) ??
            false)) {
      return Point(latitude: latitude, longitude: longitude);
    }

    return _pointOffsetNorth(
      latitude: latitude,
      longitude: longitude,
      meters: _YandexMapWidgetState._listingPinMetroStationOffsetMeters,
    );
  }
}
