import "dart:io";
import "dart:typed_data";

import "package:image/image.dart" as img;
import "package:uy_dosh/base/logger/logger.dart";

class WatermarkService {
  /// Watermark takes ~40% of the shorter image dimension for high visibility on physical devices.
  static const double _watermarkFraction = 0.40;

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

      // Resize watermark to ~40% of shorter image side (very visible on physical devices)
      final targetSize = (watermarkedImage.width < watermarkedImage.height
              ? watermarkedImage.width
              : watermarkedImage.height) *
          _watermarkFraction;
      final scaleW = targetSize / watermarkImage.width;
      final scaleH = targetSize / watermarkImage.height;
      final scale = (scaleW < scaleH ? scaleW : scaleH).clamp(0.0, 2.0);
      final w = (watermarkImage.width * scale).round().clamp(1, 2000);
      final h = (watermarkImage.height * scale).round().clamp(1, 2000);

      // Center position (for testing visibility)
      final dstX = (watermarkedImage.width - w) ~/ 2;
      final dstY = (watermarkedImage.height - h) ~/ 2;

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
