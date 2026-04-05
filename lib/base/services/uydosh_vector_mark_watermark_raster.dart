import "dart:ui" as ui;

import "package:flutter/services.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Rasterizes the combined U + roof + chimney SVG (no blue plate — excludes `square.svg`)
/// to PNG bytes for [WatermarkService].
final class UydoshVectorMarkWatermarkRaster {
  UydoshVectorMarkWatermarkRaster._();

  static const String _assetPath = "assets/icon/uydosh_vector_mark_watermark.svg";
  /// Raster width; height follows SVG aspect ratio.
  static const int _rasterWidthPx = 512;

  /// Bump when the SVG or raster pipeline changes so in-memory cache is not reused incorrectly.
  static const int cacheVersion = 2;

  static Uint8List? _cachedPng;
  static int _cachedAtVersion = -1;

  static Future<Uint8List> pngBytes() async {
    if (_cachedPng != null && _cachedAtVersion == cacheVersion) {
      return _cachedPng!;
    }

    final svg = await rootBundle.loadString(_assetPath);
    final loader = SvgStringLoader(svg);
    final pictureInfo = await vg.loadPicture(loader, null);
    try {
      final lw = pictureInfo.size.width;
      final lh = pictureInfo.size.height;
      if (lw <= 0 || lh <= 0) {
        throw StateError("Invalid vector mark size: ${pictureInfo.size}");
      }
      const outW = _rasterWidthPx;
      final outH = (outW * lh / lw).round().clamp(1, 4096);
      final uiImage = await pictureInfo.picture.toImage(outW, outH);
      try {
        final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw StateError("toByteData returned null for vector mark");
        }
        _cachedPng = byteData.buffer.asUint8List();
        _cachedAtVersion = cacheVersion;
        return _cachedPng!;
      } finally {
        uiImage.dispose();
      }
    } finally {
      pictureInfo.picture.dispose();
    }
  }
}
