import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/config/client_custom_camera_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/watermark_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/camera/custom_camera_screen.dart";
import "package:uy_dosh/presentation/widgets/common/primary_photo_pill.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

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

  static Uint8List? _cachedWatermarkBytes;

  Future<Uint8List> _loadWatermarkBytes() async {
    if (_cachedWatermarkBytes != null) return _cachedWatermarkBytes!;
    final data = await rootBundle.load("assets/icon/app_logo.png");
    _cachedWatermarkBytes = Uint8List.fromList(
      data.buffer.asUint8List().toList(),
    );
    return _cachedWatermarkBytes!;
  }

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
              final watermarkBytes = await _loadWatermarkBytes();

              // Process images in parallel for faster gallery selection
              final results = await Future.wait(
                imagesToProcess.map((image) async {
                  try {
                    final watermarkedFile = await WatermarkService.addWatermark(
                      File(image.path),
                      watermarkImageBytes: watermarkBytes,
                    );
                    return watermarkedFile.path;
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint(
                        "Error adding watermark for ${image.path}: $e",
                      );
                    }
                    return image.path;
                  }
                }),
              );
              newPhotos.addAll(results);
              widget.onPhotosChanged(newPhotos);
            } catch (e) {
              if (kDebugMode) {
                debugPrint("Error processing multiple images: $e");
              }
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
        // Default: native camera via image_picker. If the admin switch is
        // flipped on, use our in-app custom camera (watermark overlay).
        String? capturedPath;
        if (ClientCustomCameraConfig.customCameraDisabled.value) {
          capturedPath = await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (_) => const CustomCameraScreen(),
              fullscreenDialog: true,
            ),
          );
        } else {
          final image = await _picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1280,
            maxHeight: 720,
            imageQuality: 75,
          );
          capturedPath = image?.path;
        }

        if (capturedPath != null) {
          if (widget.selectedPhotos.length < widget.maxPhotos) {
            // Show loading indicator
            setState(() {
              _isProcessingImage = true;
            });

            try {
              final watermarkBytes = await _loadWatermarkBytes();
              final watermarkedFile = await WatermarkService.addWatermark(
                File(capturedPath),
                watermarkImageBytes: watermarkBytes,
              );
              final newPhotos = List<String>.from(widget.selectedPhotos);
              newPhotos.add(watermarkedFile.path);
              widget.onPhotosChanged(newPhotos);
            } catch (e) {
              if (kDebugMode) {
                debugPrint("Error adding watermark: $e");
              }
              final newPhotos = List<String>.from(widget.selectedPhotos);
              newPhotos.add(capturedPath);
              widget.onPhotosChanged(newPhotos);
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
      if (kDebugMode) {
        debugPrint("Error picking image: $e");
      }
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
            L10n.get("photo_limit_reached"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Text(
            "${L10n.get("photo_limit_reached")} (${widget.maxPhotos})",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                L10n.get("close"),
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
                  leading: const ThemeIcon(Icons.camera_alt, size: 28),
                  title: Text(
                    L10n.get("take_photo"),
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
                  leading: const ThemeIcon(Icons.photo_library, size: 28),
                  title: Text(
                    L10n.get("choose_from_gallery"),
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
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.surface
            : (Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.white),
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
                    L10n.get("listing_photos_label"),
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
                                : const ThemeIcon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                      ),
                    ),
                    tooltip:
                        _isProcessingImage
                            ? "Processing..."
                            : L10n.get("add_photo"),
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
                      L10n.get("tap_photo_to_make_primary"),
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
                  color: ThemeState().isBlueTheme
                      ? BlueThemeColors.surface.withValues(alpha: 0.5)
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5)
                          : Colors.grey[100]),
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
                      ThemeIcon(
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
                        L10n.get("add_photo"),
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
              child: ColoredBox(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey.shade200,
                child: Image.file(
                  File(orderedPhotos[index]),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  // Pass only cacheWidth so Flutter preserves the source
                  // aspect ratio in the raster (setting both cacheWidth and
                  // cacheHeight forces the bitmap into that exact box and
                  // can distort portrait photos).
                  cacheWidth: 400,
                ),
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
                child: ThemeIcon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
