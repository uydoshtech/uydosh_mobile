import "dart:io";
import "package:image/image.dart" as img;
import "package:uy_dosh/base/logger/logger.dart";

class WatermarkService {
  static const String _watermarkText = "UyDosh";
  static const int _watermarkPadding = 50;

  /// Adds a watermark to the given image file
  static Future<File> addWatermark(File imageFile) async {
    try {
      logger.d("🖼️ Starting watermark process for: ${imageFile.path}");

      // Read the image file
      final imageBytes = await imageFile.readAsBytes();
      logger.d("📁 Image file size: ${imageBytes.length} bytes");

      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception("Failed to decode image");
      }

      logger.d(
        "🖼️ Original image dimensions: ${originalImage.width}x${originalImage.height}",
      );

      // Clone image for modification (faster than copyResize when not resizing)
      final watermarkedImage = img.Image.from(originalImage);

      // Calculate watermark position - center horizontally at the bottom
      const watermarkTextWidth =
          _watermarkText.length * 100; // 5x larger: 20 * 5 = 100
      final watermarkX =
          (watermarkedImage.width - watermarkTextWidth) ~/
          2; // Center horizontally
      final watermarkY =
          watermarkedImage.height -
          _watermarkPadding -
          150; // 5x larger: 30 * 5 = 150

      logger.d("📍 Watermark position: ($watermarkX, $watermarkY)");
      logger.d(
        "📍 Image dimensions: ${watermarkedImage.width}x${watermarkedImage.height}",
      );
      logger.d("📍 Watermark text width: $watermarkTextWidth");
      logger.d("📍 Watermark text: $_watermarkText");

      // Draw the watermark text with white color and black stroke for visibility
      final whiteColor = img.ColorRgba8(
        255,
        255,
        255,
        255,
      ); // Full opacity white
      final blackColor = img.ColorRgba8(0, 0, 0, 255); // Full opacity black

      logger.d("🎨 Colors - White: $whiteColor, Black: $blackColor");

      // Try different available fonts
      final availableFonts = [img.arial24, img.arial48];
      img.BitmapFont? selectedFont;

      for (final font in availableFonts) {
        selectedFont = font;
        logger.d("✅ Using font: ${font.runtimeType}");
        break;
      }

      selectedFont ??= img.arial24;

      // Draw a solid black background rectangle (fillRect is much faster than pixel loop)
      const bgWidth = watermarkTextWidth + 100;
      const bgHeight = 200;
      final bgX = watermarkX - 50;
      final bgY = watermarkY - 50;
      img.fillRect(
        watermarkedImage,
        x1: bgX,
        y1: bgY,
        x2: bgX + bgWidth,
        y2: bgY + bgHeight,
        color: blackColor,
        alphaBlend: false,
      );

      // Draw black stroke in 8 directions (much faster than 440 drawString calls)
      const strokeOffset = 10;
      const strokeOffsets = [
        (strokeOffset, 0),
        (-strokeOffset, 0),
        (0, strokeOffset),
        (0, -strokeOffset),
        (7, 7),
        (-7, 7),
        (7, -7),
        (-7, -7),
      ];
      for (final (dx, dy) in strokeOffsets) {
        img.drawString(
          watermarkedImage,
          _watermarkText,
          font: selectedFont,
          x: watermarkX + dx,
          y: watermarkY + dy,
          color: blackColor,
        );
      }

      // Draw white text on top
      img.drawString(
        watermarkedImage,
        _watermarkText,
        font: selectedFont,
        x: watermarkX,
        y: watermarkY,
        color: whiteColor,
      );

      logger.d("✅ Watermark text drawn successfully");

      // Encode the watermarked image with higher compression for lighter files
      final watermarkedBytes = img.encodeJpg(
        watermarkedImage,
        quality: 80,
      );
      logger.d("💾 Watermarked image size: ${watermarkedBytes.length} bytes");

      // Create a temporary file for the watermarked image
      final tempPath = "${imageFile.path}_watermarked.jpg";
      final watermarkedFile = File(tempPath);
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      logger.d("💾 Watermarked file saved to: ${watermarkedFile.path}");
      logger.d("💾 File exists: ${watermarkedFile.existsSync()}");
      logger.d("💾 File size: ${watermarkedFile.lengthSync()} bytes");
      logger.d("💾 Original file size: ${imageFile.lengthSync()} bytes");
      logger.d(
        "💾 Files are different: ${watermarkedFile.path != imageFile.path}",
      );
      logger.d(
        "💾 Watermarked file is larger: ${watermarkedFile.lengthSync() > imageFile.lengthSync()}",
      );

      return watermarkedFile;
    } catch (e) {
      logger.d("❌ Error adding watermark: $e");
      logger.d("❌ Stack trace: ${StackTrace.current}");

      // If watermarking fails, return the original image
      return imageFile;
    }
  }

  /// Adds watermark to multiple images
  static Future<List<File>> addWatermarkToMultiple(
    List<File> imageFiles,
  ) async {
    final watermarkedFiles = <File>[];

    for (final imageFile in imageFiles) {
      try {
        final watermarkedFile = await addWatermark(imageFile);
        watermarkedFiles.add(watermarkedFile);
      } catch (e) {
        logger.d("Error watermarking image ${imageFile.path}: $e");
        // Add original file if watermarking fails
        watermarkedFiles.add(imageFile);
      }
    }

    return watermarkedFiles;
  }
}
