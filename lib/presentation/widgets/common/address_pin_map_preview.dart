import "dart:async" show unawaited;
import "dart:typed_data";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

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
  });

  final double latitude;
  final double longitude;

  /// Fired once the user releases the pin after dragging it.
  final void Function(double latitude, double longitude) onPinDragEnd;
  final double height;
  final Color pinColor;

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
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _pendingDragPoint = null;
      _moveCameraToCurrentPoint();
    }
    if (oldWidget.pinColor != widget.pinColor) {
      _loadIcon();
    }
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

  void _handleMapCreated(YandexMapController controller) {
    _controller = controller;
    unawaited(
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPoint, zoom: _defaultZoom),
        ),
      ),
    );
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
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
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
