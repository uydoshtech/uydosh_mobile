import "dart:io";
import "dart:math" as math;
import "dart:typed_data";

import "package:image/image.dart" as img;
import "package:uy_dosh/base/logger/logger.dart";

/// Shared placement constants for the UyDosh brand mark.
///
/// Both the in-app previews ([PhotoReviewScreen], [ListingCropScreen]) and
/// the baked-in watermark from [WatermarkService] consume these so the
/// logo lives in the same spot on the preview and the final saved photo.
///
/// Values are expressed as a fraction of the photo's *shorter* side so the
/// mark scales with the image (a 1080-wide listing photo and a 4032-wide
/// raw capture both end up looking identical when displayed).
class WatermarkPlacement {
  /// Logo edge length as a fraction of the shorter side. Slightly smaller
  /// than the previous 0.12 — the box looked balanced in the preview /
  /// crop screens but reads as crowded against the corner on a
  /// fullscreen final-photo viewer (Photos.app, Telegram), where the
  /// photo bleeds to the device edge with no chrome.
  static const double sizeFraction = 0.10;

  /// Distance from the right and bottom edges as a fraction of the
  /// shorter side.
  ///
  /// Note: the brand-mark PNG has ~15-17% built-in transparent padding
  /// inside its square canvas (see brand_logo_transparent.svg viewBox —
  /// U letter ends at y=9590 in 11607-tall canvas, right at x=9974 in
  /// 11711-wide), so the visible "U" glyph already sits inset from the
  /// box edges. 0.155 read too far from the corner on fullscreen viewers;
  /// 0.10 keeps the glyph near the edge while leaving enough room on
  /// cropped tile thumbnails.
  static const double marginFraction = 0.10;
}

class WatermarkService {

  /// Adds a watermark (app icon) to the given image file.
  /// [watermarkImageBytes] - PNG/JPEG bytes of the logo to overlay (e.g. from assets).
  /// Position: center (for testing visibility).
  static Future<File> addWatermark(
    File imageFile, {
    required Uint8List watermarkImageBytes,
  }) async {
    try {
      logger.d("🖼️ Starting watermark process for: ${imageFile.path}");

      final imageBytes = await imageFile.readAsBytes();
      logger.d("📁 Image file size: ${imageBytes.length} bytes");

      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        throw Exception("Failed to decode image");
      }

      // Bake any EXIF orientation (e.g. from landscape-held shots on
      // iPhone, which save pixels in sensor orientation + an orientation
      // tag) into the pixels before compositing. This guarantees:
      //   1. the watermark is placed on the user-visible orientation,
      //   2. the re-encoded JPEG displays correctly everywhere, even in
      //      viewers that ignore EXIF (web previews, some thumbnailers).
      final originalImage = img.bakeOrientation(decoded);

      logger.d(
        "🖼️ Original image dimensions (post-bake): ${originalImage.width}x${originalImage.height}",
      );

      final watermarkImage = img.decodeImage(watermarkImageBytes);
      if (watermarkImage == null) {
        throw Exception("Failed to decode watermark image");
      }

      // Clone image for modification
      final watermarkedImage = img.Image.from(originalImage);

      // Anchor the mark to the bottom-right of the photo with proportional
      // size + margin so the baked-in result matches the preview rendered
      // by [PhotoReviewWithLogo] / [ListingCropScreen]. Both surfaces use
      // the same [WatermarkPlacement] fractions.
      final shorterSide = math.min(
        watermarkedImage.width,
        watermarkedImage.height,
      );
      final targetSize = shorterSide * WatermarkPlacement.sizeFraction;
      final marginPx =
          (shorterSide * WatermarkPlacement.marginFraction).round();

      final scaleW = targetSize / watermarkImage.width;
      final scaleH = targetSize / watermarkImage.height;
      final scale = math.min(scaleW, scaleH).clamp(0.0, 2.0);
      final w = (watermarkImage.width * scale).round().clamp(1, 2000);
      final h = (watermarkImage.height * scale).round().clamp(1, 2000);

      final dstX = watermarkedImage.width - w - marginPx;
      final dstY = watermarkedImage.height - h - marginPx;

      img.compositeImage(
        watermarkedImage,
        watermarkImage,
        dstX: dstX.clamp(0, watermarkedImage.width - 1),
        dstY: dstY.clamp(0, watermarkedImage.height - 1),
        dstW: w,
        dstH: h,
        blend: img.BlendMode.alpha,
      );

      logger.d("✅ Watermark composited at ($dstX, $dstY) size ${w}x$h");

      final watermarkedBytes = img.encodeJpg(
        watermarkedImage,
        quality: 80,
      );
      logger.d("💾 Watermarked image size: ${watermarkedBytes.length} bytes");

      final tempPath = "${imageFile.path}_watermarked.jpg";
      final watermarkedFile = File(tempPath);
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      logger.d("💾 Watermarked file saved to: ${watermarkedFile.path}");

      return watermarkedFile;
    } catch (e) {
      logger.d("❌ Error adding watermark: $e");
      logger.d("❌ Stack trace: ${StackTrace.current}");
      return imageFile;
    }
  }

  /// Adds watermark to multiple images
  static Future<List<File>> addWatermarkToMultiple(
    List<File> imageFiles, {
    required Uint8List watermarkImageBytes,
  }) async {
    final watermarkedFiles = <File>[];

    for (final imageFile in imageFiles) {
      try {
        final watermarkedFile = await addWatermark(
          imageFile,
          watermarkImageBytes: watermarkImageBytes,
        );
        watermarkedFiles.add(watermarkedFile);
      } catch (e) {
        logger.d("Error watermarking image ${imageFile.path}: $e");
        watermarkedFiles.add(imageFile);
      }
    }

    return watermarkedFiles;
  }
}
