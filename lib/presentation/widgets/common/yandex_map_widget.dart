import "dart:async" show unawaited;
import "dart:typed_data";
import "dart:ui" as ui;
import "package:flutter/foundation.dart" show kDebugMode, kIsWeb;
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
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/platform_device.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

part "yandex_map_widget_icons.dart";
part "yandex_map_widget_map_objects.dart";

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

class YandexMapCameraOptions {
  const YandexMapCameraOptions({
    this.moveOnTargetChange = true,
    this.includeUniversityMarkersInCamera = true,
    this.fitCityWhenNoPins = false,
  });

  final bool moveOnTargetChange;
  final bool includeUniversityMarkersInCamera;
  /// When there are no listing/university camera targets, fit the full city
  /// bounds (Tashkent) instead of a tight neighborhood zoom.
  final bool fitCityWhenNoPins;
}

class YandexMapLayerOptions {
  const YandexMapLayerOptions({
    this.showUserLocation = false,
    this.showDistrictLayer = false,
    this.showMetroStationsLayer = false,
    this.metroStationLineId,
    this.showGroceryStoresLayer = false,
    this.showBusStopsLayer = false,
  });

  final bool showUserLocation;
  final bool showDistrictLayer;
  final bool showMetroStationsLayer;
  final int? metroStationLineId;
  final bool showGroceryStoresLayer;
  final bool showBusStopsLayer;
}

class YandexMapTooltipOptions {
  const YandexMapTooltipOptions({
    this.showListingDetail = true,
    this.showUniversityMarker = true,
    this.showMetroStation = true,
  });

  final bool showListingDetail;
  final bool showUniversityMarker;
  final bool showMetroStation;
}

class YandexMapZoomControlsOptions {
  const YandexMapZoomControlsOptions({this.right, this.bottom});

  final double? right;
  final double? bottom;
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

class _YandexMapPoiMarker {
  const _YandexMapPoiMarker({
    required this.id,
    required this.name,
    required this.point,
  });

  final String id;
  final String name;
  final Point point;
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
    this.selectedUniversityMarkerId,
    this.userUniversityMarkerId,
    this.selectedUniversityZoomFocusId,
    this.selectedListingId,
    this.selectedListingGroupIds = const [],
    this.onPinTap,
    this.onPinGroupTap,
    this.onUniversityMarkerTap,
    this.onMapTap,
    this.onMapCreated,
    this.onCameraPositionChanged,
    this.height = 200,
    this.cameraOptions = const YandexMapCameraOptions(),
    this.layerOptions = const YandexMapLayerOptions(),
    this.tooltipOptions = const YandexMapTooltipOptions(),
    this.showDefaultPlacemark = true,
    this.showLoadingPlaceholderContent = true,
    this.showBrandMark = true,
    this.brandMarkBottomInset = 0,
    this.showZoomControls = true,
    this.nightModeEnabled = false,
    this.zoomControlsOptions = const YandexMapZoomControlsOptions(),
    this.userLocationRequestToken = 0,
    this.userLocationLatitude,
    this.userLocationLongitude,
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
  final String? selectedUniversityMarkerId;
  final String? userUniversityMarkerId;
  final String? selectedUniversityZoomFocusId;
  final int? selectedListingId;
  final List<int> selectedListingGroupIds;
  final ValueChanged<ListingMapPin>? onPinTap;
  final ValueChanged<List<ListingMapPin>>? onPinGroupTap;
  final ValueChanged<UniversityMapMarker>? onUniversityMarkerTap;
  final ValueChanged<Point>? onMapTap;
  final MapCreatedCallback? onMapCreated;
  final CameraPositionCallback? onCameraPositionChanged;
  final YandexMapCameraOptions cameraOptions;
  final YandexMapLayerOptions layerOptions;
  final YandexMapTooltipOptions tooltipOptions;
  final bool showDefaultPlacemark;
  final bool showLoadingPlaceholderContent;
  final bool showBrandMark;
  final double brandMarkBottomInset;
  final bool showZoomControls;
  final bool nightModeEnabled;
  final YandexMapZoomControlsOptions zoomControlsOptions;
  final int userLocationRequestToken;
  final double? userLocationLatitude;
  final double? userLocationLongitude;
  final ValueChanged<bool>? onMetroStationTooltipChanged;

  @override
  State<YandexMapWidget> createState() => _YandexMapWidgetState();
}

class _YandexMapWidgetState extends State<YandexMapWidget> {
  static const double _minZoom = 3.0;
  static const double _maxZoom = 20.0;
  static const double _maxMultiPinAutoZoom = 13.25;
  static const double _minDistrictLabelZoom = 11.5;
  static const double _brandMarkSize = 42.0;
  static const double _brandMarkInset = 10.0;
  static const double _listingPinZIndex = 100.0;
  static const double _listingGroupPinZIndex = 101.0;
  static const double _selectedListingPinZIndex = 110.0;
  static const double _metroStationWalkingRadiusMeters = 1100.0;
  static const double _minMetroStationWalkAreaLabelZoom = 12.5;
  static const double _listingPinMetroStationOffsetMeters = 45.0;
  static const double _metroStationPlacemarkScale = 0.62;
  static const double _selectedMetroStationPlacemarkScale = 0.93;
  static const double _metroStationBorderPx = 1.0;
  static const double _selectedMetroStationBorderPx = 4.0;
  static double _metroStationIconOutlineWidth({required bool selected}) {
    final borderPx =
        selected ? _selectedMetroStationBorderPx : _metroStationBorderPx;
    final scale = selected
        ? _selectedMetroStationPlacemarkScale
        : _metroStationPlacemarkScale;
    return borderPx / scale;
  }
  static int get _minClusterableListingPinGroups =>
      isAndroidDevice ? 8 : 16;
  static const double _listingClusterRadius = 44.0;
  static int get _listingClusterMinZoom => isAndroidDevice ? 14 : 15;
  static int get _minClusterableUniversityMarkers => isAndroidDevice ? 8 : 16;
  static const double _universityClusterRadius = 44.0;
  static const int _universityClusterMinZoom = 15;

  Uint8List? _cachedIconBytes;
  Uint8List? _cachedDarkIconBytes;
  Uint8List? _cachedSelectedIconBytes;
  Uint8List? _cachedUniversityIconBytes;
  Uint8List? _cachedUserUniversityIconBytes;
  Uint8List? _cachedSelectedUserUniversityIconBytes;
  Uint8List? _cachedSelectedUniversityIconBytes;
  Uint8List? _cachedUserLocationPinIconBytes;
  Uint8List? _cachedUserLocationArrowIconBytes;
  Uint8List? _cachedDarkUserLocationPinIconBytes;
  Uint8List? _cachedDarkUserLocationArrowIconBytes;
  Uint8List? _cachedGroceryStoreIconBytes;
  Uint8List? _cachedBusStopIconBytes;
  final Map<String, Uint8List> _cachedListingTypeIconBytes = {};
  final Map<String, Uint8List> _cachedDarkListingTypeIconBytes = {};
  final Map<String, Uint8List> _cachedSelectedListingTypeIconBytes = {};
  final Map<String, Uint8List> _cachedListingGroupIconBytes = {};
  final Map<int, Uint8List> _cachedMetroStationIconBytes = {};
  final Map<int, Uint8List> _cachedSelectedMetroStationIconBytes = {};
  final Map<String, Uint8List> _cachedMetroWalkAreaLabelIconBytes = {};
  final Set<String> _pendingListingGroupIconKeys = {};
  final Set<String> _pendingMetroWalkAreaLabelIconKeys = {};
  final Map<Uint8List, BitmapDescriptor> _cachedBitmapDescriptors = {};
  YandexMapController? _mapController;
  SearchSession? _groceryStoreSearchSession;
  SearchSession? _busStopSearchSession;
  bool _isMapReady = false;
  bool _areMapObjectsReady = false;
  bool _isInitializing = false;
  int _retryCount = 0;
  int _automaticCameraFinishesToIgnore = 0;
  bool _showListingDetailTooltip = false;
  UniversityMapMarker? _selectedUniversityMarker;
  SubwayStation? _selectedMetroStation;
  bool _isUserLocationLayerVisible = false;
  bool _mapRebuildScheduled = false;
  int _poiSearchGeneration = 0;
  String? _poiSearchVisibleRegionKey;
  List<_YandexMapPoiMarker> _groceryStoreMarkers = const [];
  List<_YandexMapPoiMarker> _busStopMarkers = const [];
  int? _cachedMapObjectsKey;
  List<MapObject>? _cachedMapObjects;
  int? _cachedListingPinGroupsKey;
  List<_ListingPinGroup>? _cachedListingPinGroups;
  int _zoomSliderRequestId = 0;
  int _mapOperationGeneration = 0;
  late final ValueNotifier<double> _zoomNotifier;
  late double _currentZoom;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _currentZoom = _initialZoom();
    _zoomNotifier = ValueNotifier<double>(_currentZoom);
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
    if (oldWidget.layerOptions.showUserLocation !=
        widget.layerOptions.showUserLocation) {
      _syncUserLocationLayer();
    }
    if (oldWidget.userLocationRequestToken != widget.userLocationRequestToken) {
      _syncUserLocationLayer(requestPermission: true);
    }
    if (oldWidget.layerOptions.showMetroStationsLayer &&
        !widget.layerOptions.showMetroStationsLayer) {
      _setSelectedMetroStation(null, notify: true);
    }
    if (_metroLayerOptionsChanged(oldWidget.layerOptions, widget.layerOptions)) {
      final selectedStation = _selectedMetroStation;
      final selectedLineId = widget.layerOptions.metroStationLineId;
      if (selectedStation != null &&
          selectedLineId != null &&
          selectedStation.line != selectedLineId) {
        _setSelectedMetroStation(null, notify: true);
      }
      _invalidateMapObjectsCache();
      _requestMapRebuild();
    }
    if (_poiLayerOptionsChanged(oldWidget.layerOptions, widget.layerOptions)) {
      _syncPoiLayers();
    }
    if (oldWidget.nightModeEnabled != widget.nightModeEnabled) {
      unawaited(_refreshUserLocationLayerAppearance());
    }
    if (_pinsChanged(oldWidget.pins, widget.pins) ||
        !_intListsEqual(
          oldWidget.selectedListingGroupIds,
          widget.selectedListingGroupIds,
        )) {
      _syncListingGroupIconBytes();
    }
    _syncSelectedUniversityMarker();
    final shouldMoveForPins =
        _mapTargetChanged(oldWidget) && widget.cameraOptions.moveOnTargetChange;
    final shouldMoveForCity = widget.cameraOptions.fitCityWhenNoPins &&
        widget.pins.isEmpty &&
        (widget.cameraOptions.fitCityWhenNoPins !=
                oldWidget.cameraOptions.fitCityWhenNoPins ||
            _pinsChanged(oldWidget.pins, widget.pins));
    if (!shouldMoveForPins && !shouldMoveForCity) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isMapReady || _mapController == null) return;
      unawaited(_moveCameraToCurrentTarget());
    });
  }

  @override
  void dispose() {
    _mapOperationGeneration++;
    _zoomSliderRequestId++;
    _poiSearchGeneration++;
    unawaited(_groceryStoreSearchSession?.close());
    unawaited(_busStopSearchSession?.close());
    _mapController = null;
    _cachedMapObjects = null;
    _cachedMapObjectsKey = null;
    _cachedListingPinGroups = null;
    _cachedListingPinGroupsKey = null;
    _zoomNotifier.dispose();
    super.dispose();
  }

  Future<void> _initializeIcon() async {
    try {
      final sharedIcons = await _loadSharedIconBytes();
      _cachedIconBytes = sharedIcons.defaultIconBytes;
      _cachedDarkIconBytes = sharedIcons.darkDefaultIconBytes;
      _cachedSelectedIconBytes = sharedIcons.selectedIconBytes;
      _cachedUniversityIconBytes = sharedIcons.universityIconBytes;
      _cachedUserUniversityIconBytes = sharedIcons.userUniversityIconBytes;
      _cachedSelectedUserUniversityIconBytes =
          sharedIcons.selectedUserUniversityIconBytes;
      _cachedSelectedUniversityIconBytes =
          sharedIcons.selectedUniversityIconBytes;
      _cachedUserLocationPinIconBytes = sharedIcons.userLocationPinIconBytes;
      _cachedUserLocationArrowIconBytes =
          sharedIcons.userLocationArrowIconBytes;
      _cachedDarkUserLocationPinIconBytes =
          sharedIcons.darkUserLocationPinIconBytes;
      _cachedDarkUserLocationArrowIconBytes =
          sharedIcons.darkUserLocationArrowIconBytes;
      _cachedGroceryStoreIconBytes = sharedIcons.groceryStoreIconBytes;
      _cachedBusStopIconBytes = sharedIcons.busStopIconBytes;
      _cachedListingTypeIconBytes
        ..clear()
        ..addAll(sharedIcons.listingTypeIconBytes);
      _cachedDarkListingTypeIconBytes
        ..clear()
        ..addAll(sharedIcons.darkListingTypeIconBytes);
      _cachedSelectedListingTypeIconBytes
        ..clear()
        ..addAll(sharedIcons.selectedListingTypeIconBytes);
      _cachedMetroStationIconBytes
        ..clear()
        ..addAll(sharedIcons.metroStationIconBytes);
      _cachedSelectedMetroStationIconBytes
        ..clear()
        ..addAll(sharedIcons.selectedMetroStationIconBytes);
      _syncListingGroupIconBytes();
      unawaited(_refreshUserLocationLayerAppearance());
      if (kDebugMode) {
        logger.d("✅ Map listing type icons created successfully");
      }
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
    if (kDebugMode) {
      logger.d(
        "🗺️ Initializing Yandex Map with delay... (attempt ${_retryCount + 1}/$_maxRetries)",
      );
    }

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
    if (kDebugMode) {
      logger.d(
        "🔄 Retrying Yandex Map initialization (attempt ${_retryCount + 1}/$_maxRetries)",
      );
    }

    _initializeMapWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    final mapReadyForObjects = _isMapReady || kIsWeb;
    final mapObjects = mapReadyForObjects && (_areMapObjectsReady || kIsWeb)
        ? _createMapObjects()
        : const <MapObject>[];
    final centerPoint = _getCenterPoint();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: UiPerformancePolicy.solidColorsPreferredForDevice
            ? null
            : [
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
            if (mapReadyForObjects)
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
              child: MapTooltipFadeTransition(child: _activeMapTooltip()),
            ),
            if (widget.showBrandMark) _buildMapBrandMark(),
            // Zoom controls (only when map is ready)
            if (widget.showZoomControls && !kIsWeb && _isMapReady)
              _buildZoomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBrandMark() {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomInset = widget.brandMarkBottomInset > bottomPadding
        ? widget.brandMarkBottomInset
        : bottomPadding;
    return Positioned(
      left: _brandMarkInset,
      bottom: _brandMarkInset + bottomInset,
      child: IgnorePointer(
        child: Image.asset(
          "assets/icon/components/brand_mark.png",
          width: _brandMarkSize,
          height: _brandMarkSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildMapLoadingState(
    BuildContext context,
    Map<String, double> centerPoint,
  ) {
    if (kDebugMode) {
      logger.d("⏳ Building map loading state...");
    }
    final loaderColor = widget.nightModeEnabled ? Colors.white : Colors.black;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Stack(
        children: [
          // Loading indicator and location info
          if (widget.showLoadingPlaceholderContent)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Loading indicator
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location pin
                  const ThemeIcon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 48,
                  ),
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
    if (kDebugMode) {
      logger.d("🌐 Building web fallback map at $latitude, $longitude");
    }
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
    if (kDebugMode) {
      logger.d("📱 Building mobile map...");
    }
    try {
      return YandexMap(
        // Enable all gesture interactions for better user experience
        scrollGesturesEnabled: true, // Enable pan/drag gestures with finger
        zoomGesturesEnabled: true, // Enable pinch-to-zoom
        rotateGesturesEnabled: !isAndroidDevice,
        tiltGesturesEnabled: !isAndroidDevice,
        fastTapEnabled: true, // Enable fast tap for better responsiveness
        nightModeEnabled: widget.nightModeEnabled,
        onMapCreated: (controller) {
          if (!mounted) return;
          // Store controller for zoom controls
          _mapController = controller;
          _mapOperationGeneration++;
          _areMapObjectsReady = false;
          widget.onMapCreated?.call(controller);
          _syncUserLocationLayer();

          // Map created successfully
          if (kDebugMode) {
            logger.d(
              "🗺️ Yandex Map created successfully with ${mapObjects.length} pins",
            );
            logger.d(
              "📍 Pin location: ${centerPoint["latitude"]}, ${centerPoint["longitude"]}",
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              unawaited(_moveCameraToCurrentTarget());
              _scheduleMapObjectsReady(controller);
            }
          });

          // Map created successfully - placemarks should be visible from mapObjects
          if (kDebugMode) {
            logger.d("🔧 Map created with ${mapObjects.length} placemarks");
          }
        },
        onMapTap: (point) {
          if (kDebugMode) {
            logger
                .d("🗺️ Map tapped at: ${point.latitude}, ${point.longitude}");
          }
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
      if (kDebugMode) {
        logger.d("🔄 Retrying map initialization...");
      }

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

  Future<void> _syncUserLocationLayer({bool requestPermission = false}) async {
    final controller = _mapController;
    if (controller == null || kIsWeb) return;
    final generation = _mapOperationGeneration;

    if (!widget.layerOptions.showUserLocation) {
      if (!_isUserLocationLayerVisible) return;
      try {
        await controller.toggleUserLayer(visible: false);
        if (!_isCurrentMapOperation(controller, generation)) return;
        _isUserLocationLayerVisible = false;
      } catch (error) {
        logger.w("Could not hide user location layer: $error");
      }
      return;
    }

    var status = await Permission.location.status;
    if (!status.isGranted && requestPermission) {
      status = await Permission.location.request();
    }
    if (!mounted || !status.isGranted) return;

    try {
      await controller.toggleUserLayer(visible: true, autoZoomEnabled: false);
      if (!_isCurrentMapOperation(controller, generation)) return;
      _isUserLocationLayerVisible = true;
    } catch (error) {
      logger.w("Could not show user location layer: $error");
    }
  }

  Future<void> _refreshUserLocationLayerAppearance() async {
    if (!_isUserLocationLayerVisible) return;
    final controller = _mapController;
    if (controller == null || kIsWeb) return;
    final generation = _mapOperationGeneration;

    try {
      await controller.toggleUserLayer(visible: false);
      if (!_isCurrentMapOperation(controller, generation)) return;
      _isUserLocationLayerVisible = false;
      await _syncUserLocationLayer();
    } catch (error) {
      logger.w("Could not refresh user location layer appearance: $error");
    }
  }

  Future<UserLocationView> _customizeUserLocationView(
    UserLocationView view,
  ) async {
    final pinIconBytes = widget.nightModeEnabled
        ? _cachedDarkUserLocationPinIconBytes
        : _cachedUserLocationPinIconBytes;
    final arrowIconBytes = widget.nightModeEnabled
        ? _cachedDarkUserLocationArrowIconBytes
        : _cachedUserLocationArrowIconBytes;
    const userLocationColor = AppColors.error;
    final accuracyCircle = view.accuracyCircle.copyWith(
      fillColor: userLocationColor.withValues(alpha: 0.12),
      strokeColor: userLocationColor.withValues(alpha: 0.28),
      strokeWidth: 2,
    );

    if (pinIconBytes == null || arrowIconBytes == null) {
      return view.copyWith(accuracyCircle: accuracyCircle);
    }

    return view.copyWith(
      pin: view.pin.copyWith(
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: _bitmapDescriptorFromBytes(pinIconBytes),
            scale: 1.0,
          ),
        ),
      ),
      arrow: view.arrow.copyWith(
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: _bitmapDescriptorFromBytes(arrowIconBytes),
            rotationType: RotationType.rotate,
            scale: 1.0,
          ),
        ),
      ),
      accuracyCircle: accuracyCircle,
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
          if (kDebugMode) {
            logger.d(
              "🚇 Found metro station coordinates by ID ${listing.subwayStation!.id}: $coordsById",
            );
          }
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
            if (kDebugMode) {
              logger.d(
                "🚇 Found metro station coordinates by name $stationName: $coordsByName",
              );
            }
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
          if (kDebugMode) {
            logger.d(
              "📍 Found location coordinates by ID ${listing.location!.id}: $coordsById",
            );
          }
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
            if (kDebugMode) {
              logger.d(
                "📍 Found location coordinates by name $locationName: $coordsByName",
              );
            }
            return coordsByName;
          }

          // No fallback needed - LocationCache should have all locations
        }
      }
    }

    // Fallback to first available location coordinates
    if (kDebugMode) {
      logger.d("📍 Using fallback coordinates from first available location");
    }
    final firstLocation = LocationCache.getAllLocations().first;
    if (firstLocation.latitude != null && firstLocation.longitude != null) {
      return {
        "latitude": firstLocation.latitude!,
        "longitude": firstLocation.longitude!,
      };
    }

    // Ultimate fallback to hardcoded Tashkent center
    if (kDebugMode) {
      logger.d("📍 Using ultimate fallback - hardcoded Tashkent center");
    }
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

  Point? _selectedZoomFocusPoint() {
    return _selectedMetroStationZoomFocusPoint() ??
        _selectedListingZoomFocusPoint() ??
        _selectedUniversityZoomFocusPoint();
  }

  Point? _selectedMetroStationZoomFocusPoint() {
    final station = _selectedMetroStation;
    if (station?.latitude == null || station?.longitude == null) return null;
    return Point(latitude: station!.latitude!, longitude: station.longitude!);
  }

  Point? _selectedListingZoomFocusPoint() {
    final selectedListingIds = <int>{
      if (widget.selectedListingId != null) widget.selectedListingId!,
      ...widget.selectedListingGroupIds,
    };
    if (selectedListingIds.isEmpty) return null;

    final points = [
      for (final pin in widget.pins)
        if (selectedListingIds.contains(pin.listingId))
          _listingPlacemarkPoint(
            latitude: pin.latitude,
            longitude: pin.longitude,
          ),
    ];
    return _averagePoint(points);
  }

  Point? _selectedUniversityZoomFocusPoint() {
    final selectedId = widget.selectedUniversityZoomFocusId;
    if (selectedId == null) {
      final marker = _selectedUniversityMarker;
      if (marker == null) return null;
      return Point(latitude: marker.latitude, longitude: marker.longitude);
    }

    for (final marker in widget.universityMarkers) {
      if (marker.id == selectedId) {
        return Point(latitude: marker.latitude, longitude: marker.longitude);
      }
    }
    return null;
  }

  Point? _averagePoint(List<Point> points) {
    if (points.isEmpty) return null;
    final latitude = points.fold<double>(
          0,
          (sum, point) => sum + point.latitude,
        ) /
        points.length;
    final longitude = points.fold<double>(
          0,
          (sum, point) => sum + point.longitude,
        ) /
        points.length;
    return Point(latitude: latitude, longitude: longitude);
  }

  bool _isCurrentMapOperation(
    YandexMapController controller,
    int generation,
  ) {
    return mounted &&
        generation == _mapOperationGeneration &&
        identical(_mapController, controller);
  }

  bool _mapTargetChanged(YandexMapWidget oldWidget) {
    if (_pinsChanged(oldWidget.pins, widget.pins)) return true;
    if (widget.cameraOptions.includeUniversityMarkersInCamera &&
        _universityMarkersChanged(
          oldWidget.universityMarkers,
          widget.universityMarkers,
        )) {
      return true;
    }
    if (oldWidget.cameraOptions.includeUniversityMarkersInCamera !=
        widget.cameraOptions.includeUniversityMarkersInCamera) {
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
      if (widget.cameraOptions.includeUniversityMarkersInCamera)
        for (final marker in widget.universityMarkers)
          Point(latitude: marker.latitude, longitude: marker.longitude),
    ];
  }

  bool get _canShowListingDetailTooltip {
    return widget.tooltipOptions.showListingDetail &&
        widget.listingDetail != null;
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
    if (widget.tooltipOptions.showMetroStation &&
        widget.layerOptions.showMetroStationsLayer &&
        metroStation != null) {
      return _MetroStationMapTooltip(
        key: ValueKey("metro-station-${metroStation.id}"),
        station: metroStation,
        lineColor: _metroLineColor(metroStation.line),
        onClose: () => _setSelectedMetroStation(null, notify: true),
      );
    }

    final marker = _selectedUniversityMarker;
    if (widget.tooltipOptions.showUniversityMarker && marker != null) {
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
    final generation = _mapOperationGeneration;
    final targetPoints = _targetPoints();
    if (targetPoints.isEmpty && widget.cameraOptions.fitCityWhenNoPins) {
      final bounds = CoordinatesCache.getCityBounds();
      final geometry = Geometry.fromBoundingBox(
        BoundingBox(
          northEast: Point(
            latitude: bounds["maxLat"]!,
            longitude: bounds["maxLon"]!,
          ),
          southWest: Point(
            latitude: bounds["minLat"]!,
            longitude: bounds["minLon"]!,
          ),
        ),
      );
      final moved = await _moveCameraAutomatically(
        controller,
        CameraUpdate.newGeometry(geometry),
      );
      if (moved && _isCurrentMapOperation(controller, generation)) {
        final cameraPosition = await controller.getCameraPosition();
        if (_isCurrentMapOperation(controller, generation)) {
          _setCurrentZoom(cameraPosition.zoom);
        }
      }
      return;
    }
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
      if (!moved || !_isCurrentMapOperation(controller, generation)) return;

      final cameraPosition = await controller.getCameraPosition();
      if (!_isCurrentMapOperation(controller, generation)) return;
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
    if (moved && _isCurrentMapOperation(controller, generation)) {
      _setCurrentZoom(zoom);
    }
  }

  Future<bool> _moveCameraAutomatically(
    YandexMapController controller,
    CameraUpdate cameraUpdate,
  ) async {
    final generation = _mapOperationGeneration;
    _automaticCameraFinishesToIgnore++;
    final moved = await controller.moveCamera(cameraUpdate);
    if (!_isCurrentMapOperation(controller, generation)) {
      _consumeAutomaticCameraFinish();
      return false;
    }
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
      _syncPoiLayers();
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
    final oldZoom = _currentZoom;
    final shouldRebuildMapObjects = _requiresZoomDrivenMapRebuild(
      oldZoom: oldZoom,
      newZoom: nextZoom,
    );
    _currentZoom = nextZoom;
    _zoomNotifier.value = nextZoom;
    if (!mounted) {
      return;
    }
    if (shouldRebuildMapObjects) {
      setState(() {});
    }
  }

  bool _requiresZoomDrivenMapRebuild({
    required double oldZoom,
    required double newZoom,
  }) {
    if (widget.layerOptions.showDistrictLayer) {
      final districtLabelChanged = (oldZoom >= _minDistrictLabelZoom) !=
          (newZoom >= _minDistrictLabelZoom);
      if (districtLabelChanged) return true;
    }
    if (_selectedMetroStation != null &&
        widget.layerOptions.showMetroStationsLayer) {
      final metroWalkAreaLabelChanged =
          (oldZoom >= _minMetroStationWalkAreaLabelZoom) !=
              (newZoom >= _minMetroStationWalkAreaLabelZoom);
      if (metroWalkAreaLabelChanged) return true;
    }
    return false;
  }

  void _consumeAutomaticCameraFinish() {
    if (_automaticCameraFinishesToIgnore > 0) {
      _automaticCameraFinishesToIgnore--;
    }
  }

  void _requestMapRebuild() {
    if (!mounted || _mapRebuildScheduled) return;
    _mapRebuildScheduled = true;
    Future.microtask(() {
      _mapRebuildScheduled = false;
      if (mounted) setState(() {});
    });
  }

  bool _poiLayerOptionsChanged(
    YandexMapLayerOptions oldOptions,
    YandexMapLayerOptions newOptions,
  ) {
    return oldOptions.showGroceryStoresLayer !=
            newOptions.showGroceryStoresLayer ||
        oldOptions.showBusStopsLayer != newOptions.showBusStopsLayer;
  }

  bool _metroLayerOptionsChanged(
    YandexMapLayerOptions oldOptions,
    YandexMapLayerOptions newOptions,
  ) {
    return oldOptions.showMetroStationsLayer !=
            newOptions.showMetroStationsLayer ||
        oldOptions.metroStationLineId != newOptions.metroStationLineId;
  }

  void _invalidateMapObjectsCache() {
    _cachedMapObjects = null;
    _cachedMapObjectsKey = null;
  }

  String get _metroLayerScopeKey {
    if (!widget.layerOptions.showMetroStationsLayer) return "off";
    final lineId = widget.layerOptions.metroStationLineId;
    return lineId == null ? "all" : "line$lineId";
  }

  void _syncPoiLayers() {
    if (!mounted || kIsWeb || !_isMapReady || _mapController == null) return;
    if (!widget.layerOptions.showGroceryStoresLayer &&
        !widget.layerOptions.showBusStopsLayer) {
      if (_groceryStoreMarkers.isEmpty && _busStopMarkers.isEmpty) return;
      setState(() {
        _groceryStoreMarkers = const [];
        _busStopMarkers = const [];
        _poiSearchVisibleRegionKey = null;
      });
      return;
    }
    unawaited(_refreshVisiblePoiLayers());
  }

  Future<void> _refreshVisiblePoiLayers() async {
    final controller = _mapController;
    if (controller == null || kIsWeb) return;
    final generation = ++_poiSearchGeneration;
    final mapGeneration = _mapOperationGeneration;
    final visibleRegion = await controller.getVisibleRegion();
    if (!_isCurrentMapOperation(controller, mapGeneration) ||
        generation != _poiSearchGeneration) {
      return;
    }

    final regionKey = _visibleRegionSearchKey(visibleRegion);
    final groceryEnabled = widget.layerOptions.showGroceryStoresLayer;
    final busStopEnabled = widget.layerOptions.showBusStopsLayer;
    if (_poiSearchVisibleRegionKey == regionKey &&
        (!groceryEnabled || _groceryStoreMarkers.isNotEmpty) &&
        (!busStopEnabled || _busStopMarkers.isNotEmpty)) {
      return;
    }

    final geometry = Geometry.fromBoundingBox(
      _visibleRegionBoundingBox(visibleRegion),
    );
    final results = await Future.wait([
      if (groceryEnabled)
        _searchPoiLayer(
          searchText: "продуктовый магазин",
          geometry: geometry,
          searchType: SearchType.biz,
          sessionSetter: (session) => _groceryStoreSearchSession = session,
        )
      else
        Future.value(const <_YandexMapPoiMarker>[]),
      if (busStopEnabled)
        _searchPoiLayer(
          searchText: "автобусная остановка",
          geometry: geometry,
          searchType: SearchType.none,
          sessionSetter: (session) => _busStopSearchSession = session,
        )
      else
        Future.value(const <_YandexMapPoiMarker>[]),
    ]);

    if (!mounted ||
        !_isCurrentMapOperation(controller, mapGeneration) ||
        generation != _poiSearchGeneration) {
      return;
    }
    setState(() {
      _poiSearchVisibleRegionKey = regionKey;
      _groceryStoreMarkers = results[0];
      _busStopMarkers = results[1];
    });
  }

  Future<List<_YandexMapPoiMarker>> _searchPoiLayer({
    required String searchText,
    required Geometry geometry,
    required SearchType searchType,
    required ValueChanged<SearchSession> sessionSetter,
  }) async {
    try {
      final (session, resultFuture) = await YandexSearch.searchByText(
        searchText: searchText,
        geometry: geometry,
        searchOptions: SearchOptions(
          searchType: searchType,
          geometry: true,
          resultPageSize: 50,
          origin: "uydosh_map_layers",
        ),
      );
      sessionSetter(session);
      final result = await resultFuture;
      if (result.error != null) {
        logger.w("Could not load $searchText map layer: ${result.error}");
        return const [];
      }
      return _poiMarkersFromSearchItems(searchText, result.items ?? const []);
    } catch (error) {
      logger.w("Could not load $searchText map layer: $error");
      return const [];
    }
  }

  List<_YandexMapPoiMarker> _poiMarkersFromSearchItems(
    String layerKey,
    List<SearchItem> items,
  ) {
    final markersByCoordinate = <String, _YandexMapPoiMarker>{};
    for (final item in items) {
      final point = _searchItemPoint(item);
      if (point == null) continue;
      final coordinateKey = _mapCoordinateKey(point.latitude, point.longitude);
      markersByCoordinate.putIfAbsent(
        coordinateKey,
        () => _YandexMapPoiMarker(
          id: "${layerKey.hashCode}_$coordinateKey",
          name: item.name,
          point: point,
        ),
      );
    }
    return List<_YandexMapPoiMarker>.unmodifiable(markersByCoordinate.values);
  }

  Point? _searchItemPoint(SearchItem item) {
    for (final geometry in item.geometry) {
      final point = geometry.point;
      if (point != null) return point;
    }
    return null;
  }

  BoundingBox _visibleRegionBoundingBox(VisibleRegion region) {
    final latitudes = [
      region.topLeft.latitude,
      region.topRight.latitude,
      region.bottomLeft.latitude,
      region.bottomRight.latitude,
    ];
    final longitudes = [
      region.topLeft.longitude,
      region.topRight.longitude,
      region.bottomLeft.longitude,
      region.bottomRight.longitude,
    ];
    final north = latitudes.reduce((a, b) => a > b ? a : b);
    final south = latitudes.reduce((a, b) => a < b ? a : b);
    final east = longitudes.reduce((a, b) => a > b ? a : b);
    final west = longitudes.reduce((a, b) => a < b ? a : b);
    return BoundingBox(
      northEast: Point(latitude: north, longitude: east),
      southWest: Point(latitude: south, longitude: west),
    );
  }

  String _visibleRegionSearchKey(VisibleRegion region) {
    final box = _visibleRegionBoundingBox(region);
    return [
      box.northEast.latitude.toStringAsFixed(3),
      box.northEast.longitude.toStringAsFixed(3),
      box.southWest.latitude.toStringAsFixed(3),
      box.southWest.longitude.toStringAsFixed(3),
      _currentZoom.toStringAsFixed(1),
    ].join("_");
  }

  void _clearSelectedUniversityMarker() {
    if (_selectedUniversityMarker != null) {
      setState(() => _selectedUniversityMarker = null);
    }
  }

  Widget _buildZoomControls() {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    final useLiquidGlass = themeState.usesLiquidGlassChrome;
    final foregroundColor = widget.nightModeEnabled
        ? Colors.white
        : themeState.isBlueTheme
            ? Colors.black
            : theme.colorScheme.onSurface;
    final borderRadius = BorderRadius.circular(999);
    final safeAreaPadding = MediaQuery.paddingOf(context);
    const width = 24.0;
    const height = 176.0;
    final slider = _buildZoomSlider(foregroundColor);
    final right = widget.zoomControlsOptions.right;
    final bottom = widget.zoomControlsOptions.bottom;

    return Positioned(
      left: right == null ? safeAreaPadding.left + 8 : null,
      right: right == null ? null : safeAreaPadding.right + right,
      bottom: bottom == null
          ? 44 + safeAreaPadding.bottom
          : safeAreaPadding.bottom + bottom,
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
                decoration: solidColors
                    ? BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: borderRadius,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      )
                    : BoxDecoration(
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
          inactiveTrackColor: UiPerformancePolicy.solidColorsPreferredForDevice
              ? Theme.of(context).colorScheme.outlineVariant
              : foregroundColor.withValues(alpha: 0.26),
          thumbColor: foregroundColor,
          overlayColor: UiPerformancePolicy.solidColorsPreferredForDevice
              ? Theme.of(context).colorScheme.outlineVariant
              : foregroundColor.withValues(alpha: 0.12),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        ),
        child: ValueListenableBuilder<double>(
          valueListenable: _zoomNotifier,
          builder: (context, zoom, _) {
            return Slider(
              min: _minZoom,
              max: _maxZoom,
              value: zoom,
              onChanged: _setZoomFromSlider,
            );
          },
        ),
      ),
    );
  }

  Future<void> _setZoomFromSlider(double zoom) async {
    final requestId = ++_zoomSliderRequestId;
    _setCurrentZoom(zoom);
    final controller = _mapController;
    if (controller == null) return;
    final generation = _mapOperationGeneration;

    final cameraPosition = await controller.getCameraPosition();
    if (requestId != _zoomSliderRequestId ||
        !_isCurrentMapOperation(controller, generation)) {
      return;
    }
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedZoomFocusPoint() ?? cameraPosition.target,
          zoom: zoom,
          azimuth: cameraPosition.azimuth,
          tilt: cameraPosition.tilt,
        ),
      ),
    );
  }

  Future<void> _scheduleMapObjectsReady(YandexMapController controller) async {
    final generation = _mapOperationGeneration;
    await Future<void>.delayed(
      isAndroidDevice
          ? const Duration(milliseconds: 180)
          : const Duration(milliseconds: 16),
    );
    if (!_isCurrentMapOperation(controller, generation)) return;
    if (!mounted || _areMapObjectsReady) return;
    setState(() => _areMapObjectsReady = true);
    _syncPoiLayers();
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
          if (UiPerformancePolicy.solidColorsPreferredForDevice) return child;

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
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    final stationName = MetroCache.getStationName(
      station,
      language,
    );
    final locationId = station.locationId;
    final districtName = locationId == null
        ? null
        : LocationCache.getLocationName(locationId, language);

    return Material(
      color: solidColors ? scheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: solidColors
              ? scheme.surface
              : scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: solidColors
              ? null
              : [
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
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    return Material(
      color: solidColors ? scheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: solidColors
              ? scheme.surface
              : scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: solidColors
              ? null
              : [
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
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    final iconColor = isBlueTheme ? Colors.white : AppColors.primary;
    final titleColor = isBlueTheme ? Colors.white : scheme.onSurface;
    final subtitleColor = isBlueTheme
        ? solidColors
            ? Colors.white
            : Colors.white.withValues(alpha: 0.82)
        : scheme.onSurfaceVariant;
    final shortTitle = marker.title == marker.fullTitle
        ? _toTitleCase(marker.title)
        : marker.title;
    final fullTitle = _toTitleCase(marker.fullTitle);

    return Material(
      color: solidColors ? scheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: solidColors
              ? scheme.surface
              : scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: solidColors
              ? null
              : [
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
