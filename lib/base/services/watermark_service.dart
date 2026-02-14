import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:uy_dosh/base/logger/logger.dart';

class WatermarkService {
  static const String _watermarkText = 'UyDosh';
  static const int _watermarkPadding = 50;

  /// Adds a watermark to the given image file
  static Future<File> addWatermark(File imageFile) async {
    try {
      logger.d('🖼️ Starting watermark process for: ${imageFile.path}');

      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      logger.d('📁 Image file size: ${imageBytes.length} bytes');

      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      logger.d(
        '🖼️ Original image dimensions: ${originalImage.width}x${originalImage.height}',
      );

      // Create a copy of the image to work with
      final img.Image watermarkedImage = img.copyResize(
        originalImage,
        width: originalImage.width,
        height: originalImage.height,
      );

      // Calculate watermark position - center horizontally at the bottom
      final int watermarkTextWidth =
          _watermarkText.length * 100; // 5x larger: 20 * 5 = 100
      final int watermarkX =
          (watermarkedImage.width - watermarkTextWidth) ~/
          2; // Center horizontally
      final int watermarkY =
          watermarkedImage.height -
          _watermarkPadding -
          150; // 5x larger: 30 * 5 = 150

      logger.d('📍 Watermark position: ($watermarkX, $watermarkY)');
      logger.d(
        '📍 Image dimensions: ${watermarkedImage.width}x${watermarkedImage.height}',
      );
      logger.d('📍 Watermark text width: $watermarkTextWidth');
      logger.d('📍 Watermark text: $_watermarkText');

      // Draw the watermark text with white color and black stroke for visibility
      final whiteColor = img.ColorRgba8(
        255,
        255,
        255,
        255,
      ); // Full opacity white
      final blackColor = img.ColorRgba8(0, 0, 0, 255); // Full opacity black

      logger.d('🎨 Colors - White: $whiteColor, Black: $blackColor');

      // Try different available fonts
      final availableFonts = [img.arial24, img.arial48];
      img.BitmapFont? selectedFont;

      for (final font in availableFonts) {
        selectedFont = font;
        logger.d('✅ Using font: ${font.runtimeType}');
        break;
      }

      selectedFont ??= img.arial24;

      // Draw a solid black background rectangle behind the text for better visibility
      final int bgWidth = watermarkTextWidth + 100; // 5x larger: 20 * 5 = 100
      final int bgHeight = 200; // 5x larger: 40 * 5 = 200
      final int bgX = watermarkX - 50; // 5x larger: 10 * 5 = 50
      final int bgY = watermarkY - 50; // 5x larger: 10 * 5 = 50

      // Fill background rectangle
      for (int x = bgX; x < bgX + bgWidth; x++) {
        for (int y = bgY; y < bgY + bgHeight; y++) {
          if (x >= 0 &&
              x < watermarkedImage.width &&
              y >= 0 &&
              y < watermarkedImage.height) {
            watermarkedImage.setPixel(x, y, blackColor);
          }
        }
      }

      // Draw thick black stroke first for better visibility
      for (int dx = -10; dx <= 10; dx++) {
        // 5x larger: -2 * 5 = -10, 2 * 5 = 10
        for (int dy = -10; dy <= 10; dy++) {
          // 5x larger: -2 * 5 = -10, 2 * 5 = 10
          if (dx != 0 || dy != 0) {
            img.drawString(
              watermarkedImage,
              _watermarkText,
              font: selectedFont,
              x: watermarkX + dx,
              y: watermarkY + dy,
              color: blackColor,
            );
          }
        }
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

      logger.d('✅ Watermark text drawn successfully');

      // Encode the watermarked image with higher compression for lighter files
      final Uint8List watermarkedBytes = img.encodeJpg(
        watermarkedImage,
        quality: 80,
      );
      logger.d('💾 Watermarked image size: ${watermarkedBytes.length} bytes');

      // Create a temporary file for the watermarked image
      final String tempPath = '${imageFile.path}_watermarked.jpg';
      final File watermarkedFile = File(tempPath);
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      logger.d('💾 Watermarked file saved to: ${watermarkedFile.path}');
      logger.d('💾 File exists: ${watermarkedFile.existsSync()}');
      logger.d('💾 File size: ${watermarkedFile.lengthSync()} bytes');
      logger.d('💾 Original file size: ${imageFile.lengthSync()} bytes');
      logger.d(
        '💾 Files are different: ${watermarkedFile.path != imageFile.path}',
      );
      logger.d(
        '💾 Watermarked file is larger: ${watermarkedFile.lengthSync() > imageFile.lengthSync()}',
      );

      return watermarkedFile;
    } catch (e) {
      logger.d('❌ Error adding watermark: $e');
      logger.d('❌ Stack trace: ${StackTrace.current}');

      // If watermarking fails, return the original image
      return imageFile;
    }
  }

  /// Adds watermark to multiple images
  static Future<List<File>> addWatermarkToMultiple(
    List<File> imageFiles,
  ) async {
    final List<File> watermarkedFiles = [];

    for (final File imageFile in imageFiles) {
      try {
        final File watermarkedFile = await addWatermark(imageFile);
        watermarkedFiles.add(watermarkedFile);
      } catch (e) {
        logger.d('Error watermarking image ${imageFile.path}: $e');
        // Add original file if watermarking fails
        watermarkedFiles.add(imageFile);
      }
    }

    return watermarkedFiles;
  }
}
