import "dart:typed_data";
import "dart:ui" as ui;
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/coordinates_cache.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
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
    this.onPinTap,
    this.onMapTap,
    this.onMapCreated,
    this.onCameraPositionChanged,
    this.height = 200,
    this.moveCameraOnTargetChange = true,
    this.showListingDetailTooltip = true,
  });

  final double? latitude;
  final double? longitude;
  final String? title;
  final double height;
  final String apiKey;
  final ListingDetail? listingDetail;
  final List<ListingMapPin> pins;
  final ValueChanged<ListingMapPin>? onPinTap;
  final ValueChanged<Point>? onMapTap;
  final MapCreatedCallback? onMapCreated;
  final CameraPositionCallback? onCameraPositionChanged;
  final bool moveCameraOnTargetChange;
  final bool showListingDetailTooltip;

  @override
  State<YandexMapWidget> createState() => _YandexMapWidgetState();
}

class _YandexMapWidgetState extends State<YandexMapWidget> {
  static const double _maxMultiPinAutoZoom = 13.25;

  Uint8List? _cachedIconBytes;
  YandexMapController? _mapController;
  bool _isMapReady = false;
  bool _isInitializing = false;
  int _retryCount = 0;
  int _automaticCameraFinishesToIgnore = 0;
  bool _showListingDetailTooltip = false;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _showListingDetailTooltip = _canShowListingDetailTooltip;
    _initializeIcon();
    _initializeMapWithDelay();
  }

  @override
  void didUpdateWidget(covariant YandexMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listingDetail?.id != widget.listingDetail?.id) {
      _showListingDetailTooltip = _canShowListingDetailTooltip;
    }
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
      final iconBytes = await _createIconBytes(
        Icons.location_on,
        Colors.red,
        100,
      );
      _cachedIconBytes = iconBytes;
      logger.d("✅ Cupertino icon created successfully");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      logger.e("❌ Error creating Cupertino icon: $e");
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
            if (_showListingDetailTooltip && widget.listingDetail != null)
              Positioned(
                left: 8,
                right: 8,
                top: 8,
                child: _ListingDetailMapTooltip(
                  listingDetail: widget.listingDetail!,
                  onClose: () => setState(() {
                    _showListingDetailTooltip = false;
                  }),
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
          widget.onMapTap?.call(point);
        },
        onCameraPositionChanged: _handleCameraPositionChanged,
        mapObjects: mapObjects,
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

  List<MapObject> _createMapObjects() {
    if (widget.pins.isNotEmpty) {
      return _createListingPinMapObjects();
    }

    final coordinates = _getCoordinates();
    if (coordinates == null) {
      logger.w("❌ No coordinates available for map objects");
      return [];
    }

    logger.d(
      "📍 Creating map objects at: ${coordinates["latitude"]}, ${coordinates["longitude"]}",
    );

    // Use Cupertino icon if available, otherwise fallback to PNG
    BitmapDescriptor iconDescriptor;
    if (_cachedIconBytes != null) {
      logger.d("🎨 Using Cupertino location icon");
      iconDescriptor = BitmapDescriptor.fromBytes(_cachedIconBytes!);
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
    return [placemark];
  }

  List<MapObject> _createListingPinMapObjects() {
    logger.d("📍 Creating ${widget.pins.length} listing map pins");

    final iconBytes = _cachedIconBytes;
    if (iconBytes == null) {
      logger.w("📍 Listing pin icon is not ready yet");
      return [];
    }
    final iconDescriptor = BitmapDescriptor.fromBytes(iconBytes);

    return [
      for (final pin in widget.pins)
        PlacemarkMapObject(
          mapId: MapObjectId("listing_${pin.listingId}_placemark"),
          point: Point(latitude: pin.latitude, longitude: pin.longitude),
          zIndex: 2,
          opacity: 1.0,
          consumeTapEvents: true,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: iconDescriptor,
              anchor: const Offset(0.5, 0.5),
              scale: 0.9,
            ),
          ),
          onTap: (_, __) => widget.onPinTap?.call(pin),
        ),
    ];
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
    if (widget.pins.isNotEmpty) {
      final latSum = widget.pins.fold<double>(
        0,
        (sum, pin) => sum + pin.latitude,
      );
      final lonSum = widget.pins.fold<double>(
        0,
        (sum, pin) => sum + pin.longitude,
      );
      return {
        "latitude": latSum / widget.pins.length,
        "longitude": lonSum / widget.pins.length,
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
    return widget.pins.length == 1 ? 16.0 : 14.25;
  }

  Future<void> _moveCameraToCurrentTarget() async {
    final controller = _mapController;
    if (controller == null) return;
    await _moveInitialCamera(controller, _getCenterPoint());
  }

  bool _mapTargetChanged(YandexMapWidget oldWidget) {
    if (_pinsChanged(oldWidget.pins, widget.pins)) return true;
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

  bool get _canShowListingDetailTooltip {
    return widget.showListingDetailTooltip && widget.listingDetail != null;
  }

  Future<void> _moveInitialCamera(
    YandexMapController controller,
    Map<String, double> centerPoint,
  ) async {
    final pins = widget.pins;
    if (pins.length > 1) {
      var minLat = pins.first.latitude;
      var maxLat = pins.first.latitude;
      var minLon = pins.first.longitude;
      var maxLon = pins.first.longitude;
      for (final pin in pins.skip(1)) {
        minLat = pin.latitude < minLat ? pin.latitude : minLat;
        maxLat = pin.latitude > maxLat ? pin.latitude : maxLat;
        minLon = pin.longitude < minLon ? pin.longitude : minLon;
        maxLon = pin.longitude > maxLon ? pin.longitude : maxLon;
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
        await _moveCameraAutomatically(
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
      }
      return;
    }

    await _moveCameraAutomatically(
      controller,
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: centerPoint["latitude"]!,
            longitude: centerPoint["longitude"]!,
          ),
          zoom: _initialZoom(),
          azimuth: 0.0,
          tilt: 0.0,
        ),
      ),
    );
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
    if (_automaticCameraFinishesToIgnore > 0) {
      if (finished) {
        _consumeAutomaticCameraFinish();
      }
      return;
    }
    widget.onCameraPositionChanged?.call(cameraPosition, reason, finished);
  }

  void _consumeAutomaticCameraFinish() {
    if (_automaticCameraFinishesToIgnore > 0) {
      _automaticCameraFinishesToIgnore--;
    }
  }

  Future<Uint8List> _createIconBytes(
    IconData iconData,
    Color color,
    int size,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    const solidBlack = Color(0xFF000000);

    final circlePaint = Paint()
      ..color = solidBlack
      ..style = PaintingStyle.fill;

    final center = Offset(size / 2, size / 2);
    final radius = size * 0.4;
    canvas.drawCircle(center, radius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size.toDouble() * 0.6,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: Colors.white,
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

  Widget _buildZoomControls() {
    return Positioned(
      right: 12,
      bottom: 12 + MediaQuery.paddingOf(context).bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(icon: Icons.add, onTap: _zoomIn),
          const SizedBox(height: 8),
          _buildZoomButton(icon: Icons.remove, onTap: _zoomOut),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const radius = 12.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: ThemeIcon(
              icon,
              color: Colors.white,
              size: 24,
              useThemeColor: false,
            ),
          ),
        ),
      ),
    );
  }

  void _zoomIn() {
    if (_mapController != null) {
      _mapController!.moveCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() {
    if (_mapController != null) {
      _mapController!.moveCamera(CameraUpdate.zoomOut());
    }
  }
}

class _ListingDetailMapTooltip extends StatelessWidget {
  const _ListingDetailMapTooltip({
    required this.listingDetail,
    required this.onClose,
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
