import "dart:typed_data";
import "dart:ui" as ui;
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:uy_dosh/base/cache/coordinates_cache.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/cache/tashkent_district_boundary_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

class ListingMapPin {
  const ListingMapPin({
    required this.listingId,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.subtitle,
    this.locationLabel,
    this.stationLabel,
    this.subwayLineIds = const [],
    this.listingTypeId,
    this.listingTypeCode,
    this.gender,
    this.photoUrl,
  });

  final int listingId;
  final double latitude;
  final double longitude;
  final String title;
  final String? subtitle;
  final String? locationLabel;
  final String? stationLabel;
  final List<int> subwayLineIds;
  final int? listingTypeId;
  final String? listingTypeCode;
  final int? gender;
  final String? photoUrl;
}

class UniversityMapMarker {
  const UniversityMapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.fullTitle,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String fullTitle;
}

class _ListingPinGroup {
  const _ListingPinGroup({
    required this.key,
    required this.latitude,
    required this.longitude,
    required this.pins,
  });

  final String key;
  final double latitude;
  final double longitude;
  final List<ListingMapPin> pins;
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate map tiles
    const gridSize = 20.0;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some random "buildings" or "roads"
    final buildingPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // Add some random rectangles to simulate buildings
    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 8; i++) {
      final x = (random + i * 100) % (size.width - 30).toInt();
      final y = (random + i * 150) % (size.height - 20).toInt();
      final width = 15.0 + (i % 3) * 5;
      final height = 10.0 + (i % 2) * 5;

      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), y.toDouble(), width, height),
        buildingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class YandexMapWidget extends StatefulWidget {
  const YandexMapWidget({
    required this.apiKey,
    super.key,
    this.latitude,
    this.longitude,
    this.title,
    this.listingDetail,
    this.pins = const [],
    this.universityMarkers = const [],
    this.selectedListingId,
    this.selectedListingGroupIds = const [],
    this.onPinTap,
    this.onPinGroupTap,
    this.onUniversityMarkerTap,
    this.onMapTap,
    this.onMapCreated,
    this.onCameraPositionChanged,
    this.height = 200,
    this.moveCameraOnTargetChange = true,
    this.includeUniversityMarkersInCamera = true,
    this.showListingDetailTooltip = true,
    this.showUniversityMarkerTooltip = true,
    this.showDefaultPlacemark = true,
    this.showUserLocation = false,
    this.showDistrictLayer = false,
    this.showMetroStationsLayer = false,
    this.onMetroStationTooltipChanged,
  });

  final double? latitude;
  final double? longitude;
  final String? title;
  final double height;
  final String apiKey;
  final ListingDetail? listingDetail;
  final List<ListingMapPin> pins;
  final List<UniversityMapMarker> universityMarkers;
  final int? selectedListingId;
  final List<int> selectedListingGroupIds;
  final ValueChanged<ListingMapPin>? onPinTap;
  final ValueChanged<List<ListingMapPin>>? onPinGroupTap;
  final ValueChanged<UniversityMapMarker>? onUniversityMarkerTap;
  final ValueChanged<Point>? onMapTap;
  final MapCreatedCallback? onMapCreated;
  final CameraPositionCallback? onCameraPositionChanged;
  final bool moveCameraOnTargetChange;
  final bool includeUniversityMarkersInCamera;
  final bool showListingDetailTooltip;
  final bool showUniversityMarkerTooltip;
  final bool showDefaultPlacemark;
  final bool showUserLocation;
  final bool showDistrictLayer;
  final bool showMetroStationsLayer;
  final ValueChanged<bool>? onMetroStationTooltipChanged;

  @override
  State<YandexMapWidget> createState() => _YandexMapWidgetState();
}

class _YandexMapWidgetState extends State<YandexMapWidget> {
  static const double _minZoom = 3.0;
  static const double _maxZoom = 20.0;
  static const double _maxMultiPinAutoZoom = 13.25;
  static const double _minDistrictLabelZoom = 11.5;
  static const double _minMetroStationLabelZoom = 12.5;
  static const double _listingPinZIndex = 100.0;
  static const double _listingGroupPinZIndex = 101.0;
  static const double _selectedListingPinZIndex = 110.0;

  Uint8List? _cachedIconBytes;
  Uint8List? _cachedSelectedIconBytes;
  Uint8List? _cachedUniversityIconBytes;
  Uint8List? _cachedSelectedUniversityIconBytes;
  final Map<String, Uint8List> _cachedListingTypeIconBytes = {};
  final Map<String, Uint8List> _cachedSelectedListingTypeIconBytes = {};
  final Map<String, Uint8List> _cachedListingGroupIconBytes = {};
  final Map<int, Uint8List> _cachedMetroStationIconBytes = {};
  final Set<String> _pendingListingGroupIconKeys = {};
  YandexMapController? _mapController;
  bool _isMapReady = false;
  bool _isInitializing = false;
  int _retryCount = 0;
  int _automaticCameraFinishesToIgnore = 0;
  bool _showListingDetailTooltip = false;
  UniversityMapMarker? _selectedUniversityMarker;
  SubwayStation? _selectedMetroStation;
  bool _isUserLocationLayerVisible = false;
  int _zoomSliderRequestId = 0;
  late double _currentZoom;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _currentZoom = _initialZoom();
    _showListingDetailTooltip = _canShowListingDetailTooltip;
    _initializeIcon();
    _syncListingGroupIconBytes();
    _initializeMapWithDelay();
  }

  @override
  void didUpdateWidget(covariant YandexMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listingDetail?.id != widget.listingDetail?.id) {
      _showListingDetailTooltip = _canShowListingDetailTooltip;
    }
    if (oldWidget.showUserLocation != widget.showUserLocation) {
      _syncUserLocationLayer();
    }
    if (oldWidget.showMetroStationsLayer && !widget.showMetroStationsLayer) {
      _setSelectedMetroStation(null, notify: true);
    }
    if (_pinsChanged(oldWidget.pins, widget.pins) ||
        !_intListsEqual(
          oldWidget.selectedListingGroupIds,
          widget.selectedListingGroupIds,
        )) {
      _syncListingGroupIconBytes();
    }
    _syncSelectedUniversityMarker();
    if (!_mapTargetChanged(oldWidget) || !widget.moveCameraOnTargetChange) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isMapReady || _mapController == null) return;
      _moveCameraToCurrentTarget();
    });
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  Future<void> _initializeIcon() async {
    try {
      final iconBytes = await _createIconBytes(Icons.home, 100);
      final selectedIconBytes = await _createIconBytes(
        Icons.home,
        124,
        backgroundColor: AppColors.primary,
        outlineColor: Colors.white,
        outlineWidth: 7,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shadowBlurRadius: 10,
        shadowOffset: const Offset(0, 5),
      );
      final listingTypeIconBytes = <String, Uint8List>{};
      final selectedListingTypeIconBytes = <String, Uint8List>{};
      for (final code in ListingTypeHelper.getAllCodes()) {
        final icon = ListingTypeHelper.getIcon(code);
        listingTypeIconBytes[code] = await _createIconBytes(icon, 100);
        selectedListingTypeIconBytes[code] = await _createIconBytes(
          icon,
          124,
          backgroundColor: AppColors.primary,
          outlineColor: Colors.white,
          outlineWidth: 7,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          shadowBlurRadius: 10,
          shadowOffset: const Offset(0, 5),
        );
      }
      final universityIconBytes = await _createIconBytes(
        Icons.school_rounded,
        112,
        backgroundColor: AppColors.success,
        outlineColor: Colors.white,
        outlineWidth: 7,
        shadowColor: Colors.black.withValues(alpha: 0.32),
        shadowBlurRadius: 10,
        shadowOffset: const Offset(0, 5),
      );
      final selectedUniversityIconBytes = await _createIconBytes(
        Icons.school_rounded,
        124,
        backgroundColor: Colors.black,
        iconColor: Colors.white,
        outlineColor: Colors.white,
        outlineWidth: 8,
        shadowColor: Colors.black.withValues(alpha: 0.38),
        shadowBlurRadius: 12,
        shadowOffset: const Offset(0, 6),
      );
      final metroStationIconBytes = <int, Uint8List>{};
      for (final line in MetroCache.getAvailableLines()) {
        metroStationIconBytes[line] = await _createIconBytes(
          Icons.directions_subway_rounded,
          96,
          backgroundColor: _metroLineColor(line),
          outlineColor: Colors.white,
          outlineWidth: 7,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          shadowBlurRadius: 9,
          shadowOffset: const Offset(0, 4),
        );
      }
      _cachedIconBytes = iconBytes;
      _cachedSelectedIconBytes = selectedIconBytes;
      _cachedUniversityIconBytes = universityIconBytes;
      _cachedSelectedUniversityIconBytes = selectedUniversityIconBytes;
      _cachedListingTypeIconBytes
        ..clear()
        ..addAll(listingTypeIconBytes);
      _cachedSelectedListingTypeIconBytes
        ..clear()
        ..addAll(selectedListingTypeIconBytes);
      _cachedMetroStationIconBytes
        ..clear()
        ..addAll(metroStationIconBytes);
      _syncListingGroupIconBytes();
      logger.d("✅ Map listing type icons created successfully");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      logger.e("❌ Error creating map listing type icons: $e");
    }
  }

  Future<void> _initializeMapWithDelay() async {
    if (_isInitializing) return;

    _isInitializing = true;
    logger.d(
      "🗺️ Initializing Yandex Map with delay... (attempt ${_retryCount + 1}/$_maxRetries)",
    );

    // Add a delay to allow Yandex Maps SDK to fully initialize
    await Future.delayed(_retryDelay);

    if (mounted) {
      setState(() {
        _isMapReady = true;
        _isInitializing = false;
      });
    }
  }

  void _retryMapInitialization() {
    if (_retryCount >= _maxRetries) {
      logger.e("❌ Max retries reached for Yandex Map initialization");
      return;
    }

    _retryCount++;
    logger.d(
      "🔄 Retrying Yandex Map initialization (attempt ${_retryCount + 1}/$_maxRetries)",
    );

    _initializeMapWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    // Get map objects for location and metro station
    final mapObjects = _createMapObjects();

    // Determine center point for camera
    final centerPoint = _getCenterPoint();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Show loading state while map is initializing
            if (!_isMapReady && !kIsWeb)
              _buildMapLoadingState(context, centerPoint),
            // Show actual map when ready
            if (_isMapReady || kIsWeb)
              kIsWeb
                  ? _buildWebFallback(
                      context,
                      centerPoint["latitude"]!,
                      centerPoint["longitude"]!,
                    )
                  : _buildMobileMap(context, centerPoint, mapObjects),
            Positioned(
              left: 8,
              right: 8,
              top: 8,
              child: MapTooltipFadeTransition(
                child: _activeMapTooltip(),
              ),
            ),
            // Zoom controls (only when map is ready)
            if (!kIsWeb && _isMapReady) _buildZoomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLoadingState(
    BuildContext context,
    Map<String, double> centerPoint,
  ) {
    logger.d("⏳ Building map loading state...");
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Stack(
        children: [
          // Map-like background pattern
          CustomPaint(painter: MapPatternPainter(), size: Size.infinite),
          // Loading indicator and location info
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading indicator
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                // Location pin
                const ThemeIcon(Icons.location_on, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  widget.title ?? context.l10n.loading_map,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "${centerPoint["latitude"]!.toStringAsFixed(4)}, ${centerPoint["longitude"]!.toStringAsFixed(4)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                // Retry button if initialization failed
                if (_retryCount > 0 && _retryCount < _maxRetries)
                  PrimaryButtonFactory.iconText(
                    onPressed: () {
                      _retryMapInitialization();
                    },
                    icon: Icons.refresh,
                    text: context.l10n.retry,
                    surfaceGradientBase: Colors.red,
                    textColor: Colors.white,
                    iconSize: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFallback(
    BuildContext context,
    double latitude,
    double longitude,
  ) {
    logger.d("🌐 Building web fallback map at $latitude, $longitude");
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Stack(
        children: [
          // Map-like background pattern
          CustomPaint(painter: MapPatternPainter(), size: Size.infinite),
          // Location pin and info
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ThemeIcon(Icons.location_on, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  widget.title ?? context.l10n.location,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Web notice
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                context.l10n.map_web_preview,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMap(
    BuildContext context,
    Map<String, double> centerPoint,
    List<MapObject> mapObjects,
  ) {
    logger.d("📱 Building mobile map...");
    try {
      return YandexMap(
        // Enable all gesture interactions for better user experience
        scrollGesturesEnabled: true, // Enable pan/drag gestures with finger
        zoomGesturesEnabled: true, // Enable pinch-to-zoom
        rotateGesturesEnabled: true, // Enable rotation gestures
        tiltGesturesEnabled: true, // Enable tilt gestures
        fastTapEnabled: true, // Enable fast tap for better responsiveness
        onMapCreated: (controller) {
          if (!mounted) return;
          // Store controller for zoom controls
          _mapController = controller;
          widget.onMapCreated?.call(controller);
          _syncUserLocationLayer();

          // Map created successfully
          logger.d(
            "🗺️ Yandex Map created successfully with ${mapObjects.length} pins",
          );
          logger.d(
            "📍 Pin location: ${centerPoint["latitude"]}, ${centerPoint["longitude"]}",
          );
          logger.d(
            "🎯 MapObjects: ${mapObjects.map((obj) => obj.runtimeType).toList()}",
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _moveCameraToCurrentTarget();
            }
          });

          // Map created successfully - placemarks should be visible from mapObjects
          logger.d("🔧 Map created with ${mapObjects.length} placemarks");
        },
        onMapTap: (point) {
          logger.d("🗺️ Map tapped at: ${point.latitude}, ${point.longitude}");
          if (_showListingDetailTooltip) {
            setState(() => _showListingDetailTooltip = false);
          }
          if (_selectedUniversityMarker != null) {
            setState(() => _selectedUniversityMarker = null);
          }
          _setSelectedMetroStation(null, notify: true);
          widget.onMapTap?.call(point);
        },
        onCameraPositionChanged: _handleCameraPositionChanged,
        onUserLocationAdded: _customizeUserLocationView,
        mapObjects: mapObjects,
        poiLimit: widget.pins.isNotEmpty ? 0 : null,
      );
    } catch (e) {
      logger.e("❌ Yandex Map creation failed: $e");
      logger.d("🔄 Retrying map initialization...");

      // If this is the first attempt, retry after a delay
      if (_retryCount < _maxRetries) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _retryMapInitialization();
          }
        });
      }

      // Show loading state while retrying
      return _buildMapLoadingState(context, centerPoint);
    }
  }

  Future<void> _syncUserLocationLayer() async {
    final controller = _mapController;
    if (controller == null || kIsWeb) return;

    if (!widget.showUserLocation) {
      if (!_isUserLocationLayerVisible) return;
      try {
        await controller.toggleUserLayer(visible: false);
        _isUserLocationLayerVisible = false;
      } catch (error) {
        logger.w("Could not hide user location layer: $error");
      }
      return;
    }

    final status = await Permission.location.request();
    if (!mounted || !status.isGranted) return;

    try {
      await controller.toggleUserLayer(
        visible: true,
        autoZoomEnabled: false,
      );
      _isUserLocationLayerVisible = true;
    } catch (error) {
      logger.w("Could not show user location layer: $error");
    }
  }

  Future<UserLocationView> _customizeUserLocationView(
    UserLocationView view,
  ) async {
    return view.copyWith(
      accuracyCircle: view.accuracyCircle.copyWith(
        fillColor: AppColors.primary.withValues(alpha: 0.16),
        strokeColor: AppColors.primary.withValues(alpha: 0.35),
        strokeWidth: 2,
      ),
    );
  }

  List<MapObject> _createMapObjects() {
    final districtLayerObjects = widget.showDistrictLayer
        ? _createDistrictLayerMapObjects()
        : const <MapObject>[];
    final metroStationLayerObjects = widget.showMetroStationsLayer
        ? _createMetroStationLayerMapObjects()
        : const <MapObject>[];
    final areaLayerObjects = [
      ...districtLayerObjects,
      ...metroStationLayerObjects,
    ];
    final universityMarkerObjects = _createUniversityMarkerMapObjects();
    if (widget.pins.isNotEmpty) {
      final listingPinObjects = _createListingPinMapObjects();
      return [
        ...areaLayerObjects,
        if (listingPinObjects.isNotEmpty)
          MapObjectCollection(
            mapId: const MapObjectId("listing_pin_layer"),
            mapObjects: listingPinObjects,
            zIndex: _listingPinZIndex,
          ),
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

    logger.d(
      "📍 Creating map objects at: ${coordinates["latitude"]}, ${coordinates["longitude"]}",
    );

    // Use Cupertino icon if available, otherwise fallback to PNG
    BitmapDescriptor iconDescriptor;
    if (_cachedIconBytes != null) {
      logger.d("🎨 Using Cupertino location icon");
      final listingTypeCode = widget.listingDetail?.listingType.code;
      final listingTypeIconBytes = listingTypeCode == null
          ? null
          : _cachedListingTypeIconBytes[listingTypeCode];
      iconDescriptor = BitmapDescriptor.fromBytes(
        listingTypeIconBytes ?? _cachedIconBytes!,
      );
    } else {
      logger.d("🖼️ Using PNG fallback");
      iconDescriptor = BitmapDescriptor.fromAssetImage(
        "assets/images/location_pin.png",
      );
    }

    final placemark = PlacemarkMapObject(
      mapId: const MapObjectId("listing_location_placemark"),
      point: Point(
        latitude: coordinates["latitude"]!,
        longitude: coordinates["longitude"]!,
      ),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(image: iconDescriptor, scale: 1.0),
      ),
    );

    logger.d("✅ Created placemark: ${placemark.mapId}");
    logger.d(
      "🎯 Placemark point: ${placemark.point.latitude}, ${placemark.point.longitude}",
    );
    return [
      ...areaLayerObjects,
      placemark,
    ];
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
            polygon: Polygon(
              outerRing: _toLinearRing(
                district.polygons[polygonIndex].outerRing,
              ),
              innerRings: [
                for (final ring in district.polygons[polygonIndex].innerRings)
                  _toLinearRing(ring),
              ],
            ),
            zIndex: 0.1,
            strokeWidth: 2.0,
            strokeColor: _districtLayerColor(
              district.locationId,
            ).withValues(alpha: 0.78),
            fillColor: _districtLayerColor(
              district.locationId,
            ).withValues(alpha: 0.22),
          ),
      if (_currentZoom >= _minDistrictLabelZoom)
        ..._createDistrictLabelMapObjects(),
    ];
  }

  List<MapObject> _createDistrictLabelMapObjects() {
    final language = Localizations.localeOf(context).languageCode;
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
            style: const PlacemarkTextStyle(
              placement: TextStylePlacement.center,
              color: Color(0xFF111111),
              outlineColor: Colors.white,
              size: 11,
              textOptional: true,
            ),
          ),
        ),
    ];
  }

  Point _districtLabelPoint(TashkentDistrictBoundary district) {
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
    final language = Localizations.localeOf(context).languageCode;
    final showLabels = _currentZoom >= _minMetroStationLabelZoom;
    return [
      for (final station in MetroCache.getAllStations())
        if (station.latitude != null && station.longitude != null) ...[
          _createMetroStationPlacemark(station),
          if (showLabels)
            PlacemarkMapObject(
              mapId: MapObjectId(
                "tashkent_metro_station_${station.id}_label",
              ),
              point: Point(
                latitude: station.latitude!,
                longitude: station.longitude!,
              ),
              zIndex: 1.25,
              opacity: 1.0,
              consumeTapEvents: true,
              text: PlacemarkText(
                text: MetroCache.getStationName(station, language),
                style: const PlacemarkTextStyle(
                  placement: TextStylePlacement.right,
                  offset: 6,
                  color: Color(0xFF111111),
                  outlineColor: Colors.white,
                  size: 10,
                  textOptional: true,
                ),
              ),
              onTap: (_, point) => _handleMetroStationTap(station, point),
            ),
        ],
    ];
  }

  MapObject _createMetroStationPlacemark(SubwayStation station) {
    final point = Point(
      latitude: station.latitude!,
      longitude: station.longitude!,
    );
    final iconBytes = _cachedMetroStationIconBytes[station.line];
    if (iconBytes == null) {
      return CircleMapObject(
        mapId: MapObjectId("tashkent_metro_station_${station.id}_circle"),
        circle: Circle(center: point, radius: 180),
        zIndex: 1.15,
        consumeTapEvents: true,
        strokeWidth: 3.0,
        strokeColor: Colors.white.withValues(alpha: 0.95),
        fillColor: _metroLineColor(station.line).withValues(alpha: 0.9),
        onTap: (_, point) => _handleMetroStationTap(station, point),
      );
    }

    return PlacemarkMapObject(
      mapId: MapObjectId("tashkent_metro_station_${station.id}_placemark"),
      point: point,
      zIndex: 1.2,
      opacity: 1.0,
      consumeTapEvents: true,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(iconBytes),
          anchor: const Offset(0.5, 0.5),
          scale: 0.62,
        ),
      ),
      onTap: (_, point) => _handleMetroStationTap(station, point),
    );
  }

  void _handleMetroStationTap(SubwayStation station, Point point) {
    if (_showListingDetailTooltip) {
      _showListingDetailTooltip = false;
    }
    if (_selectedUniversityMarker != null) {
      _selectedUniversityMarker = null;
    }
    widget.onMapTap?.call(point);
    _setSelectedMetroStation(station, notify: true);
  }

  void _setSelectedMetroStation(
    SubwayStation? station, {
    required bool notify,
  }) {
    final wasVisible = _selectedMetroStation != null;
    final isVisible = station != null;
    if (_selectedMetroStation?.id == station?.id) return;

    setState(() => _selectedMetroStation = station);
    if (notify && wasVisible != isVisible) {
      widget.onMetroStationTooltipChanged?.call(isVisible);
    }
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

  List<MapObject> _createUniversityMarkerMapObjects() {
    final iconBytes = _cachedUniversityIconBytes;
    final selectedIconBytes = _cachedSelectedUniversityIconBytes;
    if (widget.universityMarkers.isEmpty) return [];
    if (iconBytes == null || selectedIconBytes == null) {
      logger.w("📍 University marker icon is not ready yet");
      return [];
    }

    final selectedMarkerId = _selectedUniversityMarker?.id;
    final orderedMarkers = <UniversityMapMarker>[
      for (final marker in widget.universityMarkers)
        if (marker.id != selectedMarkerId) marker,
      for (final marker in widget.universityMarkers)
        if (marker.id == selectedMarkerId) marker,
    ];

    return [
      for (final marker in orderedMarkers)
        if (marker.id == selectedMarkerId)
          PlacemarkMapObject(
            mapId: MapObjectId("university_${marker.id}_placemark"),
            point: Point(
              latitude: marker.latitude,
              longitude: marker.longitude,
            ),
            zIndex: 9,
            opacity: 1.0,
            consumeTapEvents: true,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(selectedIconBytes),
                anchor: const Offset(0.5, 0.5),
                scale: 1.0,
              ),
            ),
            onTap: (_, point) => _handleUniversityMarkerTap(marker, point),
          )
        else
          PlacemarkMapObject(
            mapId: MapObjectId("university_${marker.id}_placemark"),
            point: Point(
              latitude: marker.latitude,
              longitude: marker.longitude,
            ),
            zIndex: 5,
            opacity: 1.0,
            consumeTapEvents: true,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(iconBytes),
                anchor: const Offset(0.5, 0.5),
                scale: 0.9,
              ),
            ),
            onTap: (_, point) => _handleUniversityMarkerTap(marker, point),
          ),
    ];
  }

  void _handleUniversityMarkerTap(UniversityMapMarker marker, Point point) {
    if (_showListingDetailTooltip) {
      _showListingDetailTooltip = false;
    }
    _setSelectedMetroStation(null, notify: true);
    widget.onMapTap?.call(point);
    final onUniversityMarkerTap = widget.onUniversityMarkerTap;
    if (onUniversityMarkerTap != null) {
      if (_selectedUniversityMarker != null) {
        setState(() => _selectedUniversityMarker = null);
      }
      onUniversityMarkerTap(marker);
      return;
    }
    setState(() => _selectedUniversityMarker = marker);
  }

  List<MapObject> _createListingPinMapObjects() {
    logger.d("📍 Creating ${widget.pins.length} listing map pins");

    final iconBytes = _cachedIconBytes;
    final selectedIconBytes = _cachedSelectedIconBytes;
    if (iconBytes == null || selectedIconBytes == null) {
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
          PlacemarkMapObject(
            mapId:
                MapObjectId("listing_${group.pins.first.listingId}_placemark"),
            point: Point(
              latitude: group.pins.first.latitude,
              longitude: group.pins.first.longitude,
            ),
            zIndex: _selectedListingPinZIndex,
            opacity: 1.0,
            consumeTapEvents: true,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: _listingPinIconDescriptor(
                  group.pins.first,
                  selected: true,
                ),
                anchor: const Offset(0.5, 0.5),
                zIndex: _selectedListingPinZIndex,
                scale: 1.0,
              ),
            ),
            onTap: (_, __) {
              if (_selectedUniversityMarker != null) {
                setState(() => _selectedUniversityMarker = null);
              }
              _setSelectedMetroStation(null, notify: true);
              widget.onPinTap?.call(group.pins.first);
            },
          )
        else
          PlacemarkMapObject(
            mapId:
                MapObjectId("listing_${group.pins.first.listingId}_placemark"),
            point: Point(
              latitude: group.pins.first.latitude,
              longitude: group.pins.first.longitude,
            ),
            zIndex: _listingPinZIndex,
            opacity: 1.0,
            consumeTapEvents: true,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: _listingPinIconDescriptor(group.pins.first),
                anchor: const Offset(0.5, 0.5),
                zIndex: _listingPinZIndex,
                scale: 0.9,
              ),
            ),
            onTap: (_, __) {
              if (_selectedUniversityMarker != null) {
                setState(() => _selectedUniversityMarker = null);
              }
              _setSelectedMetroStation(null, notify: true);
              widget.onPinTap?.call(group.pins.first);
            },
          ),
    ];
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
    )];
    return PlacemarkMapObject(
      mapId: MapObjectId("listing_group_${group.key}_placemark"),
      point: Point(
        latitude: group.latitude,
        longitude: group.longitude,
      ),
      zIndex: selected ? _selectedListingPinZIndex : _listingGroupPinZIndex,
      opacity: 1.0,
      consumeTapEvents: true,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: groupIconBytes == null
              ? BitmapDescriptor.fromBytes(
                  selected ? _cachedSelectedIconBytes! : _cachedIconBytes!,
                )
              : BitmapDescriptor.fromBytes(groupIconBytes),
          anchor: const Offset(0.5, 0.5),
          zIndex: selected ? _selectedListingPinZIndex : _listingGroupPinZIndex,
          scale: selected ? 1.5 : 1.425,
        ),
      ),
      onTap: (_, __) {
        if (_selectedUniversityMarker != null) {
          setState(() => _selectedUniversityMarker = null);
        }
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
    final fallbackBytes =
        selected ? _cachedSelectedIconBytes : _cachedIconBytes;
    final bytesByCode = selected
        ? _cachedSelectedListingTypeIconBytes
        : _cachedListingTypeIconBytes;
    final resolvedCode = _resolveListingTypeCode(
      listingTypeCode: listingTypeCode,
      listingTypeId: listingTypeId,
    );
    final iconBytes = resolvedCode == null ? null : bytesByCode[resolvedCode];
    return BitmapDescriptor.fromBytes(iconBytes ?? fallbackBytes!);
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

  Map<String, double>? _getCoordinates() {
    // First try to use explicitly provided coordinates
    if (widget.latitude != null && widget.longitude != null) {
      return {"latitude": widget.latitude!, "longitude": widget.longitude!};
    }

    // If no explicit coordinates, try to get from listing data
    if (widget.listingDetail != null) {
      final listing = widget.listingDetail!;

      // PRIORITY 1: Try to get coordinates from metro station first (highest priority)
      if (listing.subwayStation != null) {
        // Try to get coordinates by station ID first
        final coordsById = MetroCache.getMetroStationCoordinatesById(
          listing.subwayStation!.id,
        );
        if (coordsById != null) {
          logger.d(
            "🚇 Found metro station coordinates by ID ${listing.subwayStation!.id}: $coordsById",
          );
          return coordsById;
        }

        // Fallback to name-based lookup
        final stationName = listing.subwayStation?.nameEn ??
            listing.subwayStation?.nameRu ??
            listing.subwayStation?.nameUz;

        if (stationName != null && stationName.isNotEmpty) {
          final coordsByName = MetroCache.getMetroStationCoordinatesByName(
            stationName,
          );
          if (coordsByName != null) {
            logger.d(
              "🚇 Found metro station coordinates by name $stationName: $coordsByName",
            );
            return coordsByName;
          }

          // No fallback needed - MetroCache should have all stations
        }
      }

      // PRIORITY 2: Try to get coordinates from location (lower priority)
      if (listing.location != null) {
        // Try to get coordinates by location ID first
        final coordsById = LocationCache.getLocationCoordinatesById(
          listing.location!.id,
        );
        if (coordsById != null) {
          logger.d(
            "📍 Found location coordinates by ID ${listing.location!.id}: $coordsById",
          );
          return coordsById;
        }

        // Fallback to name-based lookup
        final locationName = listing.location?.nameEn ??
            listing.location?.nameRu ??
            listing.location?.nameUz;

        if (locationName != null && locationName.isNotEmpty) {
          final coordsByName = LocationCache.getLocationCoordinatesByName(
            locationName,
          );
          if (coordsByName != null) {
            logger.d(
              "📍 Found location coordinates by name $locationName: $coordsByName",
            );
            return coordsByName;
          }

          // No fallback needed - LocationCache should have all locations
        }
      }
    }

    // Fallback to first available location coordinates
    logger.d("📍 Using fallback coordinates from first available location");
    final firstLocation = LocationCache.getAllLocations().first;
    if (firstLocation.latitude != null && firstLocation.longitude != null) {
      return {
        "latitude": firstLocation.latitude!,
        "longitude": firstLocation.longitude!,
      };
    }

    // Ultimate fallback to hardcoded Tashkent center
    logger.d("📍 Using ultimate fallback - hardcoded Tashkent center");
    return CoordinatesCache.getDefaultCoordinates();
  }

  Map<String, double> _getCenterPoint() {
    final targetPoints = _targetPoints();
    if (targetPoints.isNotEmpty) {
      final latSum = targetPoints.fold<double>(
        0,
        (sum, point) => sum + point.latitude,
      );
      final lonSum = targetPoints.fold<double>(
        0,
        (sum, point) => sum + point.longitude,
      );
      return {
        "latitude": latSum / targetPoints.length,
        "longitude": lonSum / targetPoints.length,
      };
    }

    final coordinates = _getCoordinates();
    if (coordinates != null) return coordinates;

    // Fallback to first available location coordinates
    final firstLocation = LocationCache.getAllLocations().first;
    if (firstLocation.latitude != null && firstLocation.longitude != null) {
      return {
        "latitude": firstLocation.latitude!,
        "longitude": firstLocation.longitude!,
      };
    }

    // Ultimate fallback to hardcoded Tashkent center
    return CoordinatesCache.getDefaultCoordinates();
  }

  double _initialZoom() {
    return _targetPoints().length == 1 ? 16.0 : 14.25;
  }

  Future<void> _moveCameraToCurrentTarget() async {
    final controller = _mapController;
    if (controller == null) return;
    await _moveInitialCamera(controller, _getCenterPoint());
  }

  bool _mapTargetChanged(YandexMapWidget oldWidget) {
    if (_pinsChanged(oldWidget.pins, widget.pins)) return true;
    if (widget.includeUniversityMarkersInCamera &&
        _universityMarkersChanged(
          oldWidget.universityMarkers,
          widget.universityMarkers,
        )) {
      return true;
    }
    if (oldWidget.includeUniversityMarkersInCamera !=
        widget.includeUniversityMarkersInCamera) {
      return true;
    }
    return oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.listingDetail?.id != widget.listingDetail?.id;
  }

  bool _pinsChanged(List<ListingMapPin> oldPins, List<ListingMapPin> newPins) {
    if (oldPins.length != newPins.length) return true;
    for (var i = 0; i < oldPins.length; i++) {
      final oldPin = oldPins[i];
      final newPin = newPins[i];
      if (oldPin.listingId != newPin.listingId ||
          oldPin.latitude != newPin.latitude ||
          oldPin.longitude != newPin.longitude ||
          oldPin.listingTypeId != newPin.listingTypeId ||
          oldPin.listingTypeCode != newPin.listingTypeCode ||
          oldPin.gender != newPin.gender) {
        return true;
      }
    }
    return false;
  }

  bool _intListsEqual(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _universityMarkersChanged(
    List<UniversityMapMarker> oldMarkers,
    List<UniversityMapMarker> newMarkers,
  ) {
    if (oldMarkers.length != newMarkers.length) return true;
    for (var i = 0; i < oldMarkers.length; i++) {
      final oldMarker = oldMarkers[i];
      final newMarker = newMarkers[i];
      if (oldMarker.id != newMarker.id ||
          oldMarker.latitude != newMarker.latitude ||
          oldMarker.longitude != newMarker.longitude ||
          oldMarker.title != newMarker.title ||
          oldMarker.fullTitle != newMarker.fullTitle) {
        return true;
      }
    }
    return false;
  }

  List<Point> _targetPoints() {
    return [
      for (final pin in widget.pins)
        Point(latitude: pin.latitude, longitude: pin.longitude),
      if (widget.includeUniversityMarkersInCamera)
        for (final marker in widget.universityMarkers)
          Point(latitude: marker.latitude, longitude: marker.longitude),
    ];
  }

  List<_ListingPinGroup> _groupListingPins(List<ListingMapPin> pins) {
    final pinsByCoordinate = <String, List<ListingMapPin>>{};
    for (final pin in pins) {
      final key = _listingPinCoordinateKey(pin.latitude, pin.longitude);
      pinsByCoordinate.putIfAbsent(key, () => <ListingMapPin>[]).add(pin);
    }
    return [
      for (final entry in pinsByCoordinate.entries)
        _ListingPinGroup(
          key: entry.key,
          latitude: entry.value.first.latitude,
          longitude: entry.value.first.longitude,
          pins: List<ListingMapPin>.unmodifiable(entry.value),
        ),
    ];
  }

  String _listingPinCoordinateKey(double latitude, double longitude) {
    return "${latitude.toStringAsFixed(6)}_${longitude.toStringAsFixed(6)}";
  }

  bool get _canShowListingDetailTooltip {
    return widget.showListingDetailTooltip && widget.listingDetail != null;
  }

  Widget? _activeMapTooltip() {
    final listingDetail = widget.listingDetail;
    if (_showListingDetailTooltip && listingDetail != null) {
      return _ListingDetailMapTooltip(
        key: ValueKey("listing-detail-${listingDetail.id}"),
        listingDetail: listingDetail,
        onClose: () => setState(() {
          _showListingDetailTooltip = false;
        }),
      );
    }

    final metroStation = _selectedMetroStation;
    if (widget.showMetroStationsLayer && metroStation != null) {
      return _MetroStationMapTooltip(
        key: ValueKey("metro-station-${metroStation.id}"),
        station: metroStation,
        lineColor: _metroLineColor(metroStation.line),
        onClose: () => _setSelectedMetroStation(null, notify: true),
      );
    }

    final marker = _selectedUniversityMarker;
    if (widget.showUniversityMarkerTooltip && marker != null) {
      return UniversityMapTooltip(
        key: ValueKey("university-${marker.id}"),
        marker: marker,
        onClose: () => setState(() {
          _selectedUniversityMarker = null;
        }),
      );
    }

    return null;
  }

  void _syncSelectedUniversityMarker() {
    final selected = _selectedUniversityMarker;
    if (selected == null) return;

    for (final marker in widget.universityMarkers) {
      if (marker.id == selected.id &&
          marker.latitude == selected.latitude &&
          marker.longitude == selected.longitude &&
          marker.title == selected.title &&
          marker.fullTitle == selected.fullTitle) {
        _selectedUniversityMarker = marker;
        return;
      }
    }

    _selectedUniversityMarker = null;
  }

  Future<void> _moveInitialCamera(
    YandexMapController controller,
    Map<String, double> centerPoint,
  ) async {
    final targetPoints = _targetPoints();
    if (targetPoints.length > 1) {
      var minLat = targetPoints.first.latitude;
      var maxLat = targetPoints.first.latitude;
      var minLon = targetPoints.first.longitude;
      var maxLon = targetPoints.first.longitude;
      for (final point in targetPoints.skip(1)) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLon = point.longitude < minLon ? point.longitude : minLon;
        maxLon = point.longitude > maxLon ? point.longitude : maxLon;
      }

      final latPadding = ((maxLat - minLat).abs() * 0.18).clamp(0.008, 0.06);
      final lonPadding = ((maxLon - minLon).abs() * 0.18).clamp(0.008, 0.06);
      final boundsCenter = Point(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLon + maxLon) / 2,
      );
      final geometry = Geometry.fromBoundingBox(
        BoundingBox(
          northEast: Point(
            latitude: maxLat + latPadding,
            longitude: maxLon + lonPadding,
          ),
          southWest: Point(
            latitude: minLat - latPadding,
            longitude: minLon - lonPadding,
          ),
        ),
      );
      final moved = await _moveCameraAutomatically(
        controller,
        CameraUpdate.newGeometry(geometry),
      );
      if (!moved) return;

      final cameraPosition = await controller.getCameraPosition();
      if (cameraPosition.zoom > _maxMultiPinAutoZoom) {
        final moved = await _moveCameraAutomatically(
          controller,
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: boundsCenter,
              zoom: _maxMultiPinAutoZoom,
              azimuth: cameraPosition.azimuth,
              tilt: cameraPosition.tilt,
            ),
          ),
        );
        if (moved) _setCurrentZoom(_maxMultiPinAutoZoom);
      } else {
        _setCurrentZoom(cameraPosition.zoom);
      }
      return;
    }

    final zoom = _initialZoom();
    final moved = await _moveCameraAutomatically(
      controller,
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: centerPoint["latitude"]!,
            longitude: centerPoint["longitude"]!,
          ),
          zoom: zoom,
          azimuth: 0.0,
          tilt: 0.0,
        ),
      ),
    );
    if (moved) _setCurrentZoom(zoom);
  }

  Future<bool> _moveCameraAutomatically(
    YandexMapController controller,
    CameraUpdate cameraUpdate,
  ) async {
    _automaticCameraFinishesToIgnore++;
    final moved = await controller.moveCamera(cameraUpdate);
    if (!moved) {
      _consumeAutomaticCameraFinish();
    }
    return moved;
  }

  void _handleCameraPositionChanged(
    CameraPosition cameraPosition,
    CameraUpdateReason reason,
    bool finished,
  ) {
    if (finished) {
      _setCurrentZoom(cameraPosition.zoom);
    }
    if (_automaticCameraFinishesToIgnore > 0) {
      if (finished) {
        _consumeAutomaticCameraFinish();
      }
      return;
    }
    widget.onCameraPositionChanged?.call(cameraPosition, reason, finished);
  }

  void _setCurrentZoom(double zoom) {
    final nextZoom = zoom.clamp(_minZoom, _maxZoom).toDouble();
    if ((nextZoom - _currentZoom).abs() < 0.01) return;
    if (!mounted) {
      _currentZoom = nextZoom;
      return;
    }
    setState(() => _currentZoom = nextZoom);
  }

  void _consumeAutomaticCameraFinish() {
    if (_automaticCameraFinishesToIgnore > 0) {
      _automaticCameraFinishesToIgnore--;
    }
  }

  Future<Uint8List> _createIconBytes(
    IconData iconData,
    int size, {
    Color backgroundColor = const Color(0xFF000000),
    Color iconColor = Colors.white,
    Color? outlineColor,
    double outlineWidth = 0,
    Color? shadowColor,
    double shadowBlurRadius = 0,
    Offset shadowOffset = Offset.zero,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final center = Offset(size / 2, size / 2);
    final radius = size * 0.39;

    if (shadowColor != null && shadowBlurRadius > 0) {
      final shadowPaint = Paint()
        ..color = shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + shadowOffset, radius, shadowPaint);
    }

    if (outlineColor != null && outlineWidth > 0) {
      final outlinePaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + outlineWidth, outlinePaint);
    }

    final circlePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size.toDouble() * 0.6,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  void _syncListingGroupIconBytes() {
    for (final group in _groupListingPins(widget.pins)) {
      if (group.pins.length < 2) continue;
      final listingTypeCode = _listingGroupTypeCode(group.pins);
      _ensureListingGroupIconBytes(
        group.pins.length,
        listingTypeCode: listingTypeCode,
      );
      _ensureListingGroupIconBytes(
        group.pins.length,
        listingTypeCode: listingTypeCode,
        selected: true,
      );
    }
  }

  void _ensureListingGroupIconBytes(
    int count, {
    String? listingTypeCode,
    bool selected = false,
  }) {
    if (_cachedIconBytes == null || _cachedSelectedIconBytes == null) return;
    final key = _listingGroupIconKey(
      count,
      listingTypeCode: listingTypeCode,
      selected: selected,
    );
    if (_cachedListingGroupIconBytes.containsKey(key) ||
        _pendingListingGroupIconKeys.contains(key)) {
      return;
    }

    _pendingListingGroupIconKeys.add(key);
    _createListingGroupIconBytes(
      count,
      listingTypeCode: listingTypeCode,
      selected: selected,
    ).then((bytes) {
      _pendingListingGroupIconKeys.remove(key);
      _cachedListingGroupIconBytes[key] = bytes;
      if (mounted) setState(() {});
    }).catchError((error) {
      _pendingListingGroupIconKeys.remove(key);
      logger.w("Could not create grouped listing pin icon: $error");
    });
  }

  String _listingGroupIconKey(
    int count, {
    required String? listingTypeCode,
    required bool selected,
  }) {
    return "${selected ? "selected" : "default"}_${listingTypeCode ?? "mixed"}_$count";
  }

  Future<Uint8List> _createListingGroupIconBytes(
    int count, {
    required bool selected,
    String? listingTypeCode,
  }) async {
    const width = 148;
    const height = 96;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const center = Offset(width / 2, height / 2);
    final pillHeight = selected ? 68.0 : 62.0;
    final pillWidth = selected ? 130.0 : 122.0;
    final pillRect = Rect.fromCenter(
      center: center,
      width: pillWidth,
      height: pillHeight,
    );
    final pillRadius = Radius.circular(pillHeight / 2);
    final pillRRect = RRect.fromRectAndRadius(pillRect, pillRadius);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: selected ? 0.35 : 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRRect.shift(const Offset(0, 5)), shadowPaint);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final outlineWidth = selected ? 8.0 : 6.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        pillRect.inflate(outlineWidth),
        Radius.circular((pillHeight / 2) + outlineWidth),
      ),
      outlinePaint,
    );

    final pillPaint = Paint()
      ..color = selected ? AppColors.primary : Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRRect, pillPaint);

    final label = count > 99 ? "99+" : count.toString();
    final iconData = listingTypeCode == null
        ? Icons.home_work_outlined
        : ListingTypeHelper.getIcon(listingTypeCode);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 32 : 38,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 30 : 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const gap = 8.0;
    final contentWidth = textPainter.width + gap + iconPainter.width;
    final contentHeight = iconPainter.height > textPainter.height
        ? iconPainter.height
        : textPainter.height;
    final contentLeft = (width - contentWidth) / 2;
    final contentTop = (height - contentHeight) / 2;
    textPainter.paint(
      canvas,
      Offset(
        contentLeft,
        contentTop + (contentHeight - textPainter.height) / 2,
      ),
    );
    iconPainter.paint(
      canvas,
      Offset(
        contentLeft + textPainter.width + gap,
        contentTop + (contentHeight - iconPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Widget _buildZoomControls() {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final foregroundColor =
        themeState.isBlueTheme ? Colors.black : theme.colorScheme.onSurface;
    final borderRadius = BorderRadius.circular(999);
    final safeAreaPadding = MediaQuery.paddingOf(context);
    const width = 48.0;
    const height = 176.0;
    final slider = _buildZoomSlider(foregroundColor);

    return Positioned(
      left: safeAreaPadding.left + 8,
      bottom: 44 + safeAreaPadding.bottom,
      child: SizedBox(
        width: width,
        height: height,
        child: useLiquidGlass
            ? LiquidGlassPlate(
                width: width,
                height: height,
                borderRadius: borderRadius,
                child: slider,
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    theme.colorScheme.surface,
                  ),
                  boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                ),
                child: slider,
              ),
      ),
    );
  }

  Widget _buildZoomSlider(Color foregroundColor) {
    return RotatedBox(
      quarterTurns: 3,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: foregroundColor,
          inactiveTrackColor: foregroundColor.withValues(alpha: 0.26),
          thumbColor: foregroundColor,
          overlayColor: foregroundColor.withValues(alpha: 0.12),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 8,
          ),
          overlayShape: const RoundSliderOverlayShape(
            overlayRadius: 16,
          ),
        ),
        child: Slider(
          min: _minZoom,
          max: _maxZoom,
          value: _currentZoom,
          onChanged: _setZoomFromSlider,
        ),
      ),
    );
  }

  Future<void> _setZoomFromSlider(double zoom) async {
    final requestId = ++_zoomSliderRequestId;
    _setCurrentZoom(zoom);
    final controller = _mapController;
    if (controller == null) return;

    final cameraPosition = await controller.getCameraPosition();
    if (!mounted || requestId != _zoomSliderRequestId) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: cameraPosition.target,
          zoom: zoom,
          azimuth: cameraPosition.azimuth,
          tilt: cameraPosition.tilt,
        ),
      ),
    );
  }
}

class MapTooltipFadeTransition extends StatelessWidget {
  const MapTooltipFadeTransition({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 220),
    this.reverseDuration = const Duration(milliseconds: 170),
  });

  final Widget? child;
  final Duration duration;
  final Duration reverseDuration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      reverseDuration: reverseDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        reverseDuration: reverseDuration,
        transitionBuilder: (child, animation) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.04),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        child: child ?? const SizedBox.shrink(key: ValueKey("empty-tooltip")),
      ),
    );
  }
}

class _MetroStationMapTooltip extends StatelessWidget {
  const _MetroStationMapTooltip({
    required this.station,
    required this.lineColor,
    required this.onClose,
    super.key,
  });

  final SubwayStation station;
  final Color lineColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final stationName = MetroCache.getStationLabelFromStation(
      station,
      language,
    );
    final locationId = station.locationId;
    final districtName = locationId == null
        ? null
        : LocationCache.getLocationName(locationId, language);

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 44, 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    Icons.directions_subway_rounded,
                    color: lineColor,
                    size: 24,
                    useThemeColor: false,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (districtName != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            districtName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -10,
                right: -40,
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

class _ListingDetailMapTooltip extends StatelessWidget {
  const _ListingDetailMapTooltip({
    required this.listingDetail,
    required this.onClose,
    super.key,
  });

  final ListingDetail listingDetail;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 44, 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listingDetail.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _priceLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -10,
                right: -40,
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

  String _priceLabel() {
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: listingDetail.price,
      listingTypeCode: listingDetail.listingType.code,
      minPrice: listingDetail.minPrice,
      maxPrice: listingDetail.maxPrice,
    );
    return PriceRangeHelper.formatListingPriceRangeWithCurrencyMarker(
      bounds.min,
      bounds.max,
    );
  }
}

class UniversityMapTooltip extends StatelessWidget {
  const UniversityMapTooltip({
    required this.marker,
    required this.onClose,
    super.key,
  });

  final UniversityMapMarker marker;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    final iconColor = isBlueTheme ? Colors.white : AppColors.primary;
    final titleColor = isBlueTheme ? Colors.white : scheme.onSurface;
    final subtitleColor = isBlueTheme
        ? Colors.white.withValues(alpha: 0.82)
        : scheme.onSurfaceVariant;
    final shortTitle = marker.title == marker.fullTitle
        ? _toTitleCase(marker.title)
        : marker.title;
    final fullTitle = _toTitleCase(marker.fullTitle);

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 44, 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    Icons.school_rounded,
                    color: iconColor,
                    size: 22,
                    useThemeColor: false,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shortTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          fullTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -10,
                right: -40,
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

  String _toTitleCase(String value) {
    return value.trim().split(RegExp(r"\s+")).map((part) {
      return part.split("-").map(_capitalizeWord).join("-");
    }).join(" ");
  }

  String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
