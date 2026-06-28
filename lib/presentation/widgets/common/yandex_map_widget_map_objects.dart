part of "yandex_map_widget.dart";

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

String _mapCoordinateKey(double latitude, double longitude) {
  return "${latitude.toStringAsFixed(6)}_${longitude.toStringAsFixed(6)}";
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
    final districtLabelsVisible =
        _currentZoom >= _YandexMapWidgetState._minDistrictLabelZoom;
    final metroWalkAreaLabelVisible = _isMetroWalkAreaLabelVisible;
    final listingPinGroups = _groupListingPins(widget.pins);
    return Object.hashAll([
      widget.layerOptions.showDistrictLayer,
      widget.layerOptions.showMetroStationsLayer,
      widget.layerOptions.showGroceryStoresLayer,
      widget.layerOptions.showBusStopsLayer,
      widget.showDefaultPlacemark,
      widget.nightModeEnabled,
      Localizations.localeOf(context).languageCode,
      districtLabelsVisible,
      metroWalkAreaLabelVisible,
      _selectedMetroStation?.id,
      _selectedUniversityMarker?.id,
      widget.selectedListingId,
      Object.hashAll(widget.selectedListingGroupIds),
      widget.latitude,
      widget.longitude,
      widget.listingDetail?.id,
      _cachedIconBytes != null,
      _cachedDarkIconBytes != null,
      _cachedSelectedIconBytes != null,
      _cachedUniversityIconBytes != null,
      _cachedUserUniversityIconBytes != null,
      _cachedSelectedUserUniversityIconBytes != null,
      _cachedSelectedUniversityIconBytes != null,
      _cachedGroceryStoreIconBytes != null,
      _cachedBusStopIconBytes != null,
      _cachedListingTypeIconBytes.length,
      _cachedDarkListingTypeIconBytes.length,
      _cachedSelectedListingTypeIconBytes.length,
      _cachedListingGroupIconBytes.length,
      _cachedMetroStationIconBytes.length,
      _cachedMetroWalkAreaLabelIconBytes.length,
      Object.hashAll(_groceryStoreMarkers.map(_poiMarkerCacheKey)),
      Object.hashAll(_busStopMarkers.map(_poiMarkerCacheKey)),
      Object.hashAll(listingPinGroups.map(_pinGroupCacheKey)),
      Object.hashAll(widget.universityMarkers.map(_universityMarkerCacheKey)),
      widget.selectedUniversityMarkerId,
      widget.userUniversityMarkerId,
    ]);
  }

  int _pinGroupCacheKey(_ListingPinGroup group) {
    // Same-coordinate listings are intentionally represented as one composite
    // marker. Cache and future clustering logic should treat this key as atomic.
    return Object.hashAll([
      group.key,
      group.latitude,
      group.longitude,
      Object.hashAll(group.pins.map(_pinCacheKey)),
    ]);
  }

  int _pinCacheKey(ListingMapPin pin) {
    return Object.hash(
      pin.listingId,
      pin.latitude,
      pin.longitude,
      pin.listingTypeId,
      pin.listingTypeCode,
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
    final districtLayerObjects = widget.layerOptions.showDistrictLayer
        ? _createDistrictLayerMapObjects()
        : const <MapObject>[];
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
    if (widget.pins.isNotEmpty) {
      final listingPinObjects = _createListingPinMapObjects();
      return [
        ...areaLayerObjects,
        if (listingPinObjects.isNotEmpty)
          _listingPinCollection(listingPinObjects),
        ...universityMarkerObjects,
      ];
    }
    if (universityMarkerObjects.isNotEmpty) {
      return [
        ...areaLayerObjects,
        ...universityMarkerObjects,
      ];
    }
    if (!widget.showDefaultPlacemark) {
      return areaLayerObjects;
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
      final listingTypeIconBytes = listingTypeCode == null
          ? null
          : _cachedListingTypeIconBytes[listingTypeCode];
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
        PlacemarkIconStyle(image: iconDescriptor, scale: 1.0),
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
    ];
  }

  MapObject _listingPinCollection(List<PlacemarkMapObject> placemarks) {
    if (placemarks.length <
        _YandexMapWidgetState._minClusterableListingPinGroups) {
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

  Future<Cluster?> _handleListingClusterAdded(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) async {
    final iconBytes = await _listingClusterIconBytes(cluster.size);
    return cluster.copyWith(
      appearance: cluster.appearance.copyWith(
        zIndex: _YandexMapWidgetState._selectedListingPinZIndex,
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

  void _handleListingClusterTap(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) {
    final controller = _mapController;
    if (controller == null) return;
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
    return [
      for (final district in TashkentDistrictBoundaryCache.districts)
        for (var polygonIndex = 0;
            polygonIndex < district.polygons.length;
            polygonIndex++)
          PolygonMapObject(
            mapId: MapObjectId(
              "tashkent_district_${district.locationId}_$polygonIndex",
            ),
            polygon: _districtPolygon(district, polygonIndex),
            zIndex: 0.1,
            strokeWidth: 2.0,
            strokeColor: _districtLayerColor(
              district.locationId,
            ).withValues(alpha: 0.78),
            fillColor: _districtLayerColor(
              district.locationId,
            ).withValues(alpha: 0.22),
          ),
      if (_currentZoom >= _YandexMapWidgetState._minDistrictLabelZoom)
        ..._createDistrictLabelMapObjects(),
    ];
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
    final language = Localizations.localeOf(context).languageCode;
    final textColor =
        widget.nightModeEnabled ? Colors.white : const Color(0xFF111111);
    final outlineColor =
        widget.nightModeEnabled ? Colors.white : const Color(0xFF111111);
    return [
      for (final district in TashkentDistrictBoundaryCache.districts)
        PlacemarkMapObject(
          mapId: MapObjectId("tashkent_district_${district.locationId}_label"),
          point: _districtLabelPoint(district),
          zIndex: 1.0,
          opacity: 1.0,
          text: PlacemarkText(
            text: LocationCache.getLocationShortName(
              district.locationId,
              language,
            ),
            style: PlacemarkTextStyle(
              placement: TextStylePlacement.center,
              color: textColor,
              outlineColor: outlineColor,
              size: 11,
              textOptional: true,
            ),
          ),
        ),
    ];
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

  List<MapObject> _createMetroStationLayerMapObjects() {
    return [
      if (_selectedMetroStation != null) ...[
        _createMetroStationWalkingRadius(),
        if (_isMetroWalkAreaLabelVisible)
          _createMetroStationWalkingRadiusLabel(),
      ],
      for (final station in MetroCache.getAllStations())
        if (station.latitude != null && station.longitude != null)
          _createMetroStationPlacemark(station),
    ];
  }

  bool get _isMetroWalkAreaLabelVisible {
    return _currentZoom >=
        _YandexMapWidgetState._minMetroStationWalkAreaLabelZoom;
  }

  CircleMapObject _createMetroStationWalkingRadius() {
    final station = _selectedMetroStation!;
    final point = Point(
      latitude: station.latitude!,
      longitude: station.longitude!,
    );
    final radiusColor =
        widget.nightModeEnabled ? Colors.white : const Color(0xFF1E88E5);
    return CircleMapObject(
      mapId: MapObjectId("tashkent_metro_station_${station.id}_walking_radius"),
      circle: Circle(
        center: point,
        radius: _YandexMapWidgetState._metroStationWalkingRadiusMeters,
      ),
      zIndex: 1.05,
      strokeWidth: 2.0,
      strokeColor: radiusColor.withValues(alpha: 0.42),
      fillColor: radiusColor.withValues(alpha: 0.16),
    );
  }

  PlacemarkMapObject _createMetroStationWalkingRadiusLabel() {
    final station = _selectedMetroStation!;
    final label = context.l10n.metro_station_walk_area_label;
    _ensureMetroWalkAreaLabelIconBytes(label);
    final iconBytes = _cachedMetroWalkAreaLabelIconBytes[label];
    final labelPoint = _pointOffsetNorth(
      latitude: station.latitude!,
      longitude: station.longitude!,
      meters: _YandexMapWidgetState._metroStationWalkingRadiusMeters * 0.56,
    );
    if (iconBytes != null) {
      return PlacemarkMapObject(
        mapId: MapObjectId(
          "tashkent_metro_station_${station.id}_walking_radius_label",
        ),
        point: labelPoint,
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

    return PlacemarkMapObject(
      mapId: MapObjectId(
        "tashkent_metro_station_${station.id}_walking_radius_label",
      ),
      point: labelPoint,
      zIndex: 1.1,
      opacity: 1.0,
      text: PlacemarkText(
        text: label,
        style: const PlacemarkTextStyle(
          placement: TextStylePlacement.center,
          color: Color(0xFF1565C0),
          outlineColor: Colors.white,
          size: 12,
          textOptional: false,
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
    final selected = _selectedMetroStation?.id == station.id;
    final iconBytes = _cachedMetroStationIconBytes[station.line];
    if (iconBytes == null) {
      return CircleMapObject(
        mapId: MapObjectId("tashkent_metro_station_${station.id}_circle"),
        circle: Circle(center: point, radius: selected ? 270 : 180),
        zIndex: selected ? 1.35 : 1.15,
        consumeTapEvents: true,
        strokeWidth: selected ? 4.5 : 3.0,
        strokeColor: (station.line == 4 ? Colors.black : Colors.white)
            .withValues(alpha: 0.95),
        fillColor: _metroLineColor(station.line).withValues(alpha: 0.9),
        onTap: (_, point) => _handleMetroStationTap(station, point),
      );
    }

    final key =
        "${station.id}_${station.line}_${selected ? "selected" : "base"}";
    final template = _cachedMetroStationPlacemarkTemplates.putIfAbsent(
      key,
      () => PlacemarkMapObject(
        mapId: MapObjectId("tashkent_metro_station_${station.id}_placemark"),
        point: point,
        zIndex: selected ? 1.35 : 1.2,
        opacity: 1.0,
        consumeTapEvents: true,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: _bitmapDescriptorFromBytes(iconBytes),
            anchor: const Offset(0.5, 0.5),
            scale: selected ? 0.93 : 0.62,
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
                scale: 0.58,
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
      ...regularLayer,
      if (highlightedPlacemark != null) highlightedPlacemark,
    ];
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
      mapId: const MapObjectId("university_marker_cluster_layer"),
      placemarks: placemarks,
      radius: _YandexMapWidgetState._universityClusterRadius,
      minZoom: _YandexMapWidgetState._universityClusterMinZoom,
      zIndex: 5,
      consumeTapEvents: true,
      onClusterAdded: _handleUniversityClusterAdded,
      onClusterTap: _handleUniversityClusterTap,
    );
  }

  Future<Cluster?> _handleUniversityClusterAdded(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) async {
    final iconBytes = await _universityClusterIconBytes(cluster.size);
    return cluster.copyWith(
      appearance: cluster.appearance.copyWith(
        zIndex: 9,
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

  void _handleUniversityClusterTap(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) {
    final controller = _mapController;
    if (controller == null) return;
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
      mapId: MapObjectId("university_${marker.id}_placemark"),
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
          scale: selected ? 1.0 : 0.9,
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
    final selectedListingIds = <int>{
      if (widget.selectedListingId != null) widget.selectedListingId!,
      ...widget.selectedListingGroupIds,
    };
    final groups = _groupListingPins(widget.pins);
    final orderedGroups = <_ListingPinGroup>[
      for (final group in groups)
        if (!group.pins
            .any((pin) => selectedListingIds.contains(pin.listingId)))
          group,
      for (final group in groups)
        if (group.pins.any((pin) => selectedListingIds.contains(pin.listingId)))
          group,
    ];

    return [
      for (final group in orderedGroups)
        if (group.pins.length > 1)
          _createListingGroupPlacemark(
            group,
            selected: group.pins.any(
              (pin) => selectedListingIds.contains(pin.listingId),
            ),
          )
        else if (selectedListingIds.contains(group.pins.first.listingId))
          _createListingPlacemark(group.pins.first, selected: true)
        else
          _createListingPlacemark(group.pins.first, selected: false),
    ];
  }

  PlacemarkMapObject _createListingPlacemark(
    ListingMapPin pin, {
    required bool selected,
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
          image: _listingPinIconDescriptor(pin, selected: selected),
          anchor: const Offset(0.5, 0.5),
          zIndex: zIndex,
          scale: selected ? 1.0 : 1.17,
        ),
      ),
      onTap: (_, __) {
        _clearSelectedUniversityMarker();
        _setSelectedMetroStation(null, notify: true);
        widget.onPinTap?.call(pin);
      },
    );
  }

  PlacemarkMapObject _createListingGroupPlacemark(
    _ListingPinGroup group, {
    required bool selected,
  }) {
    final count = group.pins.length;
    final listingTypeCode = _listingGroupTypeCode(group.pins);
    _ensureListingGroupIconBytes(
      count,
      listingTypeCode: listingTypeCode,
      selected: selected,
    );
    final groupIconBytes = _cachedListingGroupIconBytes[_listingGroupIconKey(
      count,
      listingTypeCode: listingTypeCode,
      selected: selected,
      darkMap: widget.nightModeEnabled && !selected,
    )];
    return PlacemarkMapObject(
      mapId: MapObjectId("listing_group_${group.key}_placemark"),
      point: _listingPlacemarkPoint(
        latitude: group.latitude,
        longitude: group.longitude,
      ),
      zIndex: selected
          ? _YandexMapWidgetState._selectedListingPinZIndex
          : _YandexMapWidgetState._listingGroupPinZIndex,
      opacity: 1.0,
      consumeTapEvents: true,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: groupIconBytes == null
              ? _bitmapDescriptorFromBytes(
                  selected
                      ? _cachedSelectedIconBytes!
                      : widget.nightModeEnabled
                          ? _cachedDarkIconBytes!
                          : _cachedIconBytes!,
                )
              : _bitmapDescriptorFromBytes(groupIconBytes),
          anchor: const Offset(0.5, 0.5),
          zIndex: selected
              ? _YandexMapWidgetState._selectedListingPinZIndex
              : _YandexMapWidgetState._listingGroupPinZIndex,
          scale: selected ? 1.5 : 1.425,
        ),
      ),
      onTap: (_, __) {
        _clearSelectedUniversityMarker();
        _setSelectedMetroStation(null, notify: true);
        final onPinGroupTap = widget.onPinGroupTap;
        if (onPinGroupTap != null) {
          onPinGroupTap(group.pins);
          return;
        }
        widget.onPinTap?.call(group.pins.first);
      },
    );
  }

  BitmapDescriptor _listingPinIconDescriptor(
    ListingMapPin pin, {
    bool selected = false,
  }) {
    return _listingTypeIconDescriptor(
      listingTypeCode: pin.listingTypeCode,
      listingTypeId: pin.listingTypeId,
      selected: selected,
    );
  }

  BitmapDescriptor _listingTypeIconDescriptor({
    String? listingTypeCode,
    int? listingTypeId,
    bool selected = false,
  }) {
    final fallbackBytes = selected
        ? _cachedSelectedIconBytes
        : widget.nightModeEnabled
            ? _cachedDarkIconBytes
            : _cachedIconBytes;
    final bytesByCode = selected
        ? _cachedSelectedListingTypeIconBytes
        : widget.nightModeEnabled
            ? _cachedDarkListingTypeIconBytes
            : _cachedListingTypeIconBytes;
    final resolvedCode = _resolveListingTypeCode(
      listingTypeCode: listingTypeCode,
      listingTypeId: listingTypeId,
    );
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

  String? _listingGroupTypeCode(List<ListingMapPin> pins) {
    String? groupCode;
    for (final pin in pins) {
      final code = _resolveListingTypeCode(
        listingTypeCode: pin.listingTypeCode,
        listingTypeId: pin.listingTypeId,
      );
      if (code == null) return null;
      groupCode ??= code;
      if (groupCode != code) return null;
    }
    return groupCode;
  }

  List<_ListingPinGroup> _groupListingPins(List<ListingMapPin> pins) {
    final key = Object.hashAll(pins.map(_pinCacheKey));
    final cached = _cachedListingPinGroups;
    if (_cachedListingPinGroupsKey == key && cached != null) return cached;

    final pinsByCoordinate = <String, List<ListingMapPin>>{};
    for (final pin in pins) {
      final key = _listingPinCoordinateKey(pin.latitude, pin.longitude);
      pinsByCoordinate.putIfAbsent(key, () => <ListingMapPin>[]).add(pin);
    }
    final groups = [
      for (final entry in pinsByCoordinate.entries)
        _ListingPinGroup(
          key: entry.key,
          latitude: entry.value.first.latitude,
          longitude: entry.value.first.longitude,
          pins: List<ListingMapPin>.unmodifiable(entry.value),
        ),
    ];
    _cachedListingPinGroupsKey = key;
    _cachedListingPinGroups = groups;
    return groups;
  }

  BitmapDescriptor _bitmapDescriptorFromBytes(Uint8List bytes) {
    return _cachedBitmapDescriptors.putIfAbsent(
      bytes,
      () => BitmapDescriptor.fromBytes(bytes),
    );
  }

  String _listingPinCoordinateKey(double latitude, double longitude) {
    return _mapCoordinateKey(latitude, longitude);
  }

  Point _listingPlacemarkPoint({
    required double latitude,
    required double longitude,
  }) {
    if (!widget.layerOptions.showMetroStationsLayer ||
        !_metroStationCoordinateKeys.contains(
          _mapCoordinateKey(latitude, longitude),
        )) {
      return Point(latitude: latitude, longitude: longitude);
    }

    return _pointOffsetNorth(
      latitude: latitude,
      longitude: longitude,
      meters: _YandexMapWidgetState._listingPinMetroStationOffsetMeters,
    );
  }
}
