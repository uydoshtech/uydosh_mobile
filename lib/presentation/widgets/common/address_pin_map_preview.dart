import "dart:async" show unawaited;
import "dart:typed_data";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

/// A metro (or other point-of-interest) target the preview should draw a
/// dashed walking-path line to, from the current address pin.
class MapPathTarget {
  const MapPathTarget({
    required this.id,
    required this.point,
    required this.color,
  });

  /// Stable identity (e.g. the station id) used for map-object diffing.
  final String id;
  final Point point;
  final Color color;
}

/// Small draggable single-pin map used while picking an address in the
/// roommate-needed create-listing wizard — mirrors the Telegram Mini App's
/// `renderSinglePinMap` (a single draggable Yandex placemark the author can
/// nudge to refine their exact address).
class AddressPinMapPreview extends StatefulWidget {
  const AddressPinMapPreview({
    required this.latitude,
    required this.longitude,
    required this.onPinDragEnd,
    super.key,
    this.height = 200,
    this.pinColor = AppColors.error,
    this.pathTargets = const [],
  });

  final double latitude;
  final double longitude;

  /// Fired once the user releases the pin after dragging it.
  final void Function(double latitude, double longitude) onPinDragEnd;
  final double height;
  final Color pinColor;

  /// Stations (or other points) to draw a dashed path to from the address
  /// pin — e.g. the metro chip the author just tapped below the map.
  final List<MapPathTarget> pathTargets;

  @override
  State<AddressPinMapPreview> createState() => _AddressPinMapPreviewState();
}

class _AddressPinMapPreviewState extends State<AddressPinMapPreview> {
  static const _placemarkId = MapObjectId("address_pin_preview_placemark");
  static const double _defaultZoom = 16;

  YandexMapController? _controller;
  Point? _pendingDragPoint;
  Uint8List? _iconBytes;

  Point get _currentPoint =>
      Point(latitude: widget.latitude, longitude: widget.longitude);

  @override
  void initState() {
    super.initState();
    _loadIcon();
  }

  @override
  void didUpdateWidget(covariant AddressPinMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pathTargetsChanged = !_pathTargetIdsEqual(
      oldWidget.pathTargets,
      widget.pathTargets,
    );
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _pendingDragPoint = null;
      if (widget.pathTargets.isEmpty) {
        _moveCameraToCurrentPoint();
      } else {
        _fitCameraToPathTargets();
      }
    } else if (pathTargetsChanged) {
      if (widget.pathTargets.isEmpty) {
        _moveCameraToCurrentPoint();
      } else {
        _fitCameraToPathTargets();
      }
    }
    if (oldWidget.pinColor != widget.pinColor) {
      _loadIcon();
    }
  }

  bool _pathTargetIdsEqual(List<MapPathTarget> a, List<MapPathTarget> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _loadIcon() async {
    final bytes = await _createPinIconBytes(widget.pinColor);
    if (!mounted) return;
    setState(() => _iconBytes = bytes);
  }

  Future<void> _moveCameraToCurrentPoint() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPoint, zoom: _defaultZoom),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.3,
      ),
    );
  }

  /// Zooms/pans just enough to fit the address pin and every path target
  /// (e.g. the tapped metro station) on screen together, so the dashed
  /// path connecting them is fully visible rather than running off-frame.
  Future<void> _fitCameraToPathTargets() async {
    final controller = _controller;
    if (controller == null) return;
    final points = [_pendingDragPoint ?? _currentPoint, ...widget.pathTargets.map((t) => t.point)];

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLon = points.first.longitude;
    var maxLon = points.first.longitude;
    for (final point in points.skip(1)) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLon = point.longitude < minLon ? point.longitude : minLon;
      maxLon = point.longitude > maxLon ? point.longitude : maxLon;
    }
    final latPadding = ((maxLat - minLat).abs() * 0.25).clamp(0.006, 0.08);
    final lonPadding = ((maxLon - minLon).abs() * 0.25).clamp(0.006, 0.08);

    await controller.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(
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
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.3,
      ),
    );
  }

  void _handleMapCreated(YandexMapController controller) {
    _controller = controller;
    // Yandex MapKit's platform view isn't fully laid out yet at the moment
    // `onMapCreated` fires — moving the camera synchronously here gets
    // silently dropped and the map is left at its default world-zoom
    // position. Deferring to the next frame (same fix as the main
    // `YandexMapWidget`) ensures the move actually lands.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller != controller) return;
      if (widget.pathTargets.isEmpty) {
        unawaited(
          controller.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentPoint, zoom: _defaultZoom),
            ),
          ),
        );
      } else {
        unawaited(_fitCameraToPathTargets());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconBytes = _iconBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            YandexMap(
              onMapCreated: _handleMapCreated,
              mapObjects: iconBytes == null
                  ? const []
                  : [
                      for (final target in widget.pathTargets) ...[
                        PolylineMapObject(
                          mapId: MapObjectId("address_pin_path_${target.id}"),
                          polyline: Polyline(
                            points: [
                              _pendingDragPoint ?? _currentPoint,
                              target.point,
                            ],
                          ),
                          strokeColor: target.color,
                          strokeWidth: 3,
                          dashLength: 10,
                          gapLength: 6,
                        ),
                        CircleMapObject(
                          mapId: MapObjectId(
                            "address_pin_path_target_${target.id}",
                          ),
                          circle: Circle(
                            center: target.point,
                            radius: 18,
                          ),
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                          fillColor: target.color,
                        ),
                      ],
                      PlacemarkMapObject(
                        mapId: _placemarkId,
                        point: _pendingDragPoint ?? _currentPoint,
                        opacity: 1,
                        isDraggable: true,
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromBytes(iconBytes),
                            anchor: const Offset(0.5, 1),
                            scale: 1,
                          ),
                        ),
                        onDrag: (_, point) => _pendingDragPoint = point,
                        onDragEnd: (_) {
                          final point = _pendingDragPoint;
                          if (point == null) return;
                          widget.onPinDragEnd(point.latitude, point.longitude);
                        },
                      ),
                    ],
            ),
            if (iconBytes == null)
              const Center(
                child: UydoshLogoSpinner(size: 24),
              ),
          ],
        ),
      ),
    );
  }
}

/// Draws a simple teardrop pin (matches the style already used for other map
/// glyphs in the app) so this preview doesn't depend on a bundled pin asset.
Future<Uint8List> _createPinIconBytes(Color color) async {
  const size = 72.0;
  const headRadius = size * 0.3;
  const headCenter = Offset(size / 2, headRadius + 4);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final path = Path()
    ..moveTo(headCenter.dx, size)
    ..lineTo(headCenter.dx - headRadius * 0.85, headCenter.dy + headRadius * 0.55)
    ..arcToPoint(
      Offset(headCenter.dx + headRadius * 0.85, headCenter.dy + headRadius * 0.55),
      radius: Radius.circular(headRadius),
      clockwise: false,
      largeArc: true,
    )
    ..close();

  final shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.28)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

  final outlinePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  canvas.drawPath(path, outlinePaint);
  canvas.drawCircle(headCenter, headRadius + 3, outlinePaint);

  final fillPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  final scaledPath = Path()
    ..moveTo(headCenter.dx, size - 3)
    ..lineTo(
      headCenter.dx - headRadius * 0.72,
      headCenter.dy + headRadius * 0.42,
    )
    ..arcToPoint(
      Offset(
        headCenter.dx + headRadius * 0.72,
        headCenter.dy + headRadius * 0.42,
      ),
      radius: Radius.circular(headRadius * 0.86),
      clockwise: false,
      largeArc: true,
    )
    ..close();
  canvas.drawPath(scaledPath, fillPaint);
  canvas.drawCircle(headCenter, headRadius * 0.86, fillPaint);

  final dotPaint = Paint()..color = Colors.white;
  canvas.drawCircle(headCenter, headRadius * 0.32, dotPaint);

  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(size.round(), size.round());
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}
