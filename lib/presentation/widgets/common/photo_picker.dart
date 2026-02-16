import "dart:io";

import "package:flutter/material.dart";
import "package:image/image.dart" as img;
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/services/watermark_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/primary_photo_pill.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({
    required this.selectedPhotos,
    required this.onPhotosChanged,
    super.key,
    this.onMakePhotoPrimary, // Optional callback
    this.maxPhotos = 5,
    this.isRequired = false,
  });

  final List<String> selectedPhotos;
  final Function(List<String>) onPhotosChanged;
  final Function(int)?
  onMakePhotoPrimary; // Add callback for making photo primary
  final int maxPhotos;
  final bool isRequired;

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingImage = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // For gallery, allow multiple image selection
        final images = await _picker.pickMultiImage(
          maxWidth: 1280, // Reduced from 1920 for lighter images
          maxHeight: 720, // Reduced from 1080 for lighter images
          imageQuality: 75, // Reduced from 85 for lighter images
        );

        if (images.isNotEmpty) {
          // Check if adding these images would exceed the limit
          final remainingSlots =
              widget.maxPhotos - widget.selectedPhotos.length;
          final imagesToProcess = images.take(remainingSlots).toList();

          if (imagesToProcess.isNotEmpty) {
            // Show loading indicator
            setState(() {
              _isProcessingImage = true;
            });

            try {
              final newPhotos = List<String>.from(widget.selectedPhotos);

              // Process each selected image
              for (final image in imagesToProcess) {
                try {
                  // Add watermark to the image
                  debugPrint(
                    "🖼️ Starting watermark process for: ${image.path}",
                  );
                  final originalFile = File(image.path);
                  debugPrint("📁 Original file path: ${originalFile.path}");
                  debugPrint(
                    "📁 Original file exists: ${originalFile.existsSync()}",
                  );
                  debugPrint(
                    "📁 Original file size: ${originalFile.lengthSync()} bytes",
                  );

                  // Test: Let"s also verify the image can be read and processed
                  try {
                    final testBytes = await originalFile.readAsBytes();
                    debugPrint(
                      "🧪 Test: Image bytes read successfully: ${testBytes.length} bytes",
                    );

                    // Try to decode the image to verify it"s valid
                    final testImage = img.decodeImage(testBytes);
                    if (testImage != null) {
                      debugPrint(
                        "🧪 Test: Image decoded successfully: ${testImage.width}x${testImage.height}",
                      );
                    } else {
                      debugPrint("❌ Test: Image decoding failed");
                    }
                  } catch (testError) {
                    debugPrint(
                      "❌ Test: Error reading/decoding image: $testError",
                    );
                  }

                  final watermarkedFile = await WatermarkService.addWatermark(
                    originalFile,
                  );
                  debugPrint(
                    "✅ Watermark process completed for: ${image.path}",
                  );
                  debugPrint(
                    "📁 Watermarked file path: ${watermarkedFile.path}",
                  );
                  debugPrint(
                    "📁 Watermarked file exists: ${watermarkedFile.existsSync()}",
                  );
                  debugPrint(
                    "📁 Watermarked file size: ${watermarkedFile.lengthSync()} bytes",
                  );
                  debugPrint(
                    "📁 Original file size: ${originalFile.lengthSync()} bytes",
                  );
                  debugPrint(
                    "📁 Files are different: ${watermarkedFile.path != originalFile.path}",
                  );

                  newPhotos.add(watermarkedFile.path);
                  debugPrint("✅ Photo added to list: ${watermarkedFile.path}");
                } catch (e) {
                  debugPrint("❌ Error adding watermark for ${image.path}: $e");
                  debugPrint("❌ Stack trace: ${StackTrace.current}");
                  // If watermarking fails, add the original image
                  newPhotos.add(image.path);
                  debugPrint(
                    "⚠️ Added original image due to watermark failure: ${image.path}",
                  );
                }
              }

              widget.onPhotosChanged(newPhotos);
              debugPrint("✅ All photos processed and added to list");
            } catch (e) {
              debugPrint("❌ Error processing multiple images: $e");
              debugPrint("❌ Stack trace: ${StackTrace.current}");
            } finally {
              // Hide loading indicator
              setState(() {
                _isProcessingImage = false;
              });
            }
          } else {
            _showMaxPhotosDialog();
          }
        }
      } else {
        // For camera, keep single image selection
        final image = await _picker.pickImage(
          source: source,
          maxWidth: 1280, // Reduced from 1920 for lighter images
          maxHeight: 720, // Reduced from 1080 for lighter images
          imageQuality: 75, // Reduced from 85 for lighter images
        );

        if (image != null) {
          if (widget.selectedPhotos.length < widget.maxPhotos) {
            // Show loading indicator
            setState(() {
              _isProcessingImage = true;
            });

            try {
              // Add watermark to the image
              debugPrint("🖼️ Starting watermark process...");
              final originalFile = File(image.path);
              debugPrint("📁 Original file path: ${originalFile.path}");
              debugPrint(
                "📁 Original file exists: ${originalFile.existsSync()}",
              );
              debugPrint(
                "📁 Original file size: ${originalFile.lengthSync()} bytes",
              );

              // Test: Let"s also verify the image can be read and processed
              try {
                final testBytes = await originalFile.readAsBytes();
                debugPrint(
                  "🧪 Test: Image bytes read successfully: ${testBytes.length} bytes",
                );

                // Try to decode the image to verify it"s valid
                final testImage = img.decodeImage(testBytes);
                if (testImage != null) {
                  debugPrint(
                    "🧪 Test: Image decoded successfully: ${testImage.width}x${testImage.height}",
                  );
                } else {
                  debugPrint("❌ Test: Image decoding failed");
                }
              } catch (testError) {
                debugPrint("❌ Test: Error reading/decoding image: $testError");
              }

              final watermarkedFile = await WatermarkService.addWatermark(
                originalFile,
              );
              debugPrint("✅ Watermark process completed");
              debugPrint("📁 Watermarked file path: ${watermarkedFile.path}");
              debugPrint(
                "📁 Watermarked file exists: ${watermarkedFile.existsSync()}",
              );
              debugPrint(
                "📁 Watermarked file size: ${watermarkedFile.lengthSync()} bytes",
              );

              final newPhotos = List<String>.from(widget.selectedPhotos);
              newPhotos.add(watermarkedFile.path);
              widget.onPhotosChanged(newPhotos);
              debugPrint("✅ Photo added to list: ${watermarkedFile.path}");
            } catch (e) {
              debugPrint("❌ Error adding watermark: $e");
              debugPrint("❌ Stack trace: ${StackTrace.current}");
              // If watermarking fails, add the original image
              final newPhotos = List<String>.from(widget.selectedPhotos);
              newPhotos.add(image.path);
              widget.onPhotosChanged(newPhotos);
              debugPrint("⚠️ Added original image due to watermark failure");
            } finally {
              // Hide loading indicator
              setState(() {
                _isProcessingImage = false;
              });
            }
          } else {
            _showMaxPhotosDialog();
          }
        }
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint("Error picking image: $e");
    }
  }

  void _removePhoto(int index) {
    final newPhotos = List<String>.from(widget.selectedPhotos);
    newPhotos.removeAt(index);
    widget.onPhotosChanged(newPhotos);
  }

  void _makePhotoPrimary(int index) {
    if (index == 0) return; // Already primary

    // Add haptic feedback
    HapticFeedbackUtils.impact();

    final newPhotos = List<String>.from(widget.selectedPhotos);
    final photoToMakePrimary = newPhotos.removeAt(index);
    newPhotos.insert(0, photoToMakePrimary); // Move to first position
    widget.onPhotosChanged(newPhotos);
  }

  // Helper method to get photos in correct order (primary first)
  List<String> _getOrderedPhotos() {
    // For PhotoPicker, the first photo is always considered primary
    // so we don"t need to reorder, but we"ll keep this method for consistency
    return widget.selectedPhotos;
  }

  void _showMaxPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "photo_limit_reached",
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Text(
            "${LanguageAwareStringHelper.getCurrent(context, "photo_limit_reached")} (${widget.maxPhotos})",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LanguageAwareStringHelper.getCurrent(context, "close"),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    if (_isProcessingImage) return; // Don"t show dialog if processing

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DecoratedBox(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, size: 28),
                  title: Text(
                    LanguageAwareStringHelper.getCurrent(context, "take_photo"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, size: 28),
                  title: Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "choose_from_gallery",
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.outline
                  : AppColors.borderGrey600,
        ),
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with label and add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "listing_photos_label",
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.black,
                    ),
                  ),
                ),
                if (widget.selectedPhotos.length < widget.maxPhotos)
                  IconButton(
                    onPressed:
                        _isProcessingImage ? null : _showImageSourceDialog,
                    icon: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            _isProcessingImage
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.38)
                                : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child:
                            _isProcessingImage
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.38),
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                      ),
                    ),
                    tooltip:
                        _isProcessingImage
                            ? "Processing..."
                            : LanguageAwareStringHelper.getCurrent(
                              context,
                              "add_photo",
                            ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Photos grid
            if (widget.selectedPhotos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: _getOrderedPhotos().length,
                    itemBuilder: (context, index) {
                      return _buildPhotoItem(index);
                    },
                  ),
                  // Instruction text
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      LanguageAwareStringHelper.getCurrent(
                        context,
                        "tap_photo_to_make_primary",
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7)
                                : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),

            // Empty state
            if (widget.selectedPhotos.isEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3)
                            : Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 32,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5)
                                : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LanguageAwareStringHelper.getCurrent(
                          context,
                          "add_photo",
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.5)
                                  : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Photo count
            if (_getOrderedPhotos().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "${_getOrderedPhotos().length}/${widget.maxPhotos}",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7)
                            : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    final orderedPhotos = _getOrderedPhotos();
    final isPrimary = index == 0; // First photo in ordered list is primary

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3)
                      : Colors.grey[300]!,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              onTap: () {
                // Mark photo as primary by reordering
                _makePhotoPrimary(index);
              },
              child: Image.file(
                File(orderedPhotos[index]),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Primary photo indicator
        if (isPrimary)
          const Positioned(top: 4, left: 4, child: PrimaryPhotoPill()),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 0, 0, 0.9),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
