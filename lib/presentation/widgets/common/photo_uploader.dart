import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_photo_pill.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

class PhotoUploader extends StatefulWidget {

  const PhotoUploader({
    required this.selectedPhotos,
    required this.onPhotosChanged,
    required this.existingPhotos,
    required this.onDeleteExistingPhoto,
    required this.onMakePhotoPrimary,
    required this.deletingPhotoIds,
    required this.makingPhotoPrimaryIds,
    super.key,
    this.onMakeNewPhotoPrimary, // Optional callback for new photos
    this.maxPhotos = 5,
    this.isRequired = false,
  });
  final List<String> selectedPhotos;
  final Function(List<String>) onPhotosChanged;
  final List<Photo> existingPhotos;
  final Function(int) onDeleteExistingPhoto;
  final Function(int) onMakePhotoPrimary;
  final Function(int)? onMakeNewPhotoPrimary; // New callback for new photos
  final Set<int> deletingPhotoIds;
  final Set<int> makingPhotoPrimaryIds;
  final int maxPhotos;
  final bool isRequired;

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  int? _primaryNewPhotoIndex; // Track which new photo is primary

  // Animation controller for the + icon scale (stretch and shrink)
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation (stretch and shrink like amenities)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Create scale animation that stretches to 1.2 and shrinks back to 1.0
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // Method to trigger the scale animation
  void _triggerScaleAnimation() {
    // Scale up and then back down
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // For gallery, allow multiple image selection
        final images = await _picker.pickMultiImage(
          maxWidth: 1280,
          maxHeight: 720,
          imageQuality: 75,
        );

        if (images.isNotEmpty) {
          // Check if adding these images would exceed the limit
          final remainingSlots =
              widget.maxPhotos - widget.selectedPhotos.length;
          final imagesToProcess = images.take(remainingSlots).toList();

          if (imagesToProcess.isNotEmpty) {
            final newPhotos = List<String>.from(widget.selectedPhotos);

            // Add each selected image
            for (final image in imagesToProcess) {
              newPhotos.add(image.path);
            }

            // If this is the first photo being added AND no existing photos, make it primary
            if (widget.selectedPhotos.isEmpty &&
                newPhotos.isNotEmpty &&
                widget.existingPhotos.isEmpty) {
              _primaryNewPhotoIndex = 0;
            }

            widget.onPhotosChanged(newPhotos);
          } else {
            _showMaxPhotosDialog();
          }
        }
      } else {
        // For camera, keep single image selection
        final image = await _picker.pickImage(
          source: source,
          maxWidth: 1280,
          maxHeight: 720,
          imageQuality: 75,
        );

        if (image != null) {
          if (widget.selectedPhotos.length < widget.maxPhotos) {
            final newPhotos = List<String>.from(widget.selectedPhotos);
            newPhotos.add(image.path);

            // If this is the first photo being added AND no existing photos, make it primary
            if (widget.selectedPhotos.isEmpty &&
                widget.existingPhotos.isEmpty) {
              _primaryNewPhotoIndex = 0;
            }

            widget.onPhotosChanged(newPhotos);
          } else {
            _showMaxPhotosDialog();
          }
        }
      }
    } catch (e) {
      ToastTheme.showError(
        context,
        message: L10n.get("error_picking_photo"),
      );
    }
  }

  void _showMaxPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            L10n.get("max_photos_reached"),
          ),
          content: Text(
            L10n.get("max_photos_message"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(L10n.get("ok")),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    size: 30, // Increased from 20 to 30 (1.5x)
                  ),
                  title: Text(
                    L10n.get("take_photo"),
                    style: const TextStyle(
                      fontSize: 18, // Increased from 12 to 18 (1.5x)
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    size: 30, // Increased from 20 to 30 (1.5x)
                  ),
                  title: Text(
                    L10n.get("choose_from_gallery"),
                    style: const TextStyle(
                      fontSize: 18, // Increased from 12 to 18 (1.5x)
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteNewPhoto(int index) {
    final newPhotos = List<String>.from(widget.selectedPhotos);
    newPhotos.removeAt(index);

    // Handle primary photo reassignment
    if (_primaryNewPhotoIndex != null) {
      if (index == _primaryNewPhotoIndex) {
        // Primary photo was deleted, reassign to first remaining photo
        if (newPhotos.isNotEmpty) {
          _primaryNewPhotoIndex = 0;
        } else {
          _primaryNewPhotoIndex = null; // No photos left
        }
      } else if (index < _primaryNewPhotoIndex!) {
        // Photo before primary was deleted, adjust index
        _primaryNewPhotoIndex = _primaryNewPhotoIndex! - 1;
      }
    }

    widget.onPhotosChanged(newPhotos);
    ToastTheme.showSuccess(
      context,
      message: L10n.get("photo_deleted_success"),
    );
  }

  void _makeNewPhotoPrimary(int index) {
    if (_primaryNewPhotoIndex == index) return; // Already primary

    setState(() {
      _primaryNewPhotoIndex = index;
    });

    // Call the callback if provided
    if (widget.onMakeNewPhotoPrimary != null) {
      widget.onMakeNewPhotoPrimary!(index);
    }

    // Show success message
    ToastTheme.showSuccess(
      context,
      message: L10n.get("photo_made_primary"),
    );
  }

  String _buildPhotoUrl(String photoUrl) {
    if (photoUrl.startsWith("http")) {
      return photoUrl;
    }
    // Convert relative URL to absolute URL
    return "${EnvironmentUtil.basePath}$photoUrl";
  }

  /// Returns [orderedPhotos, orderedToOriginalIndex].
  /// orderedPhotos: display order (primary first).
  /// orderedToOriginalIndex[i]: original index for callbacks.
  (List<Photo> orderedPhotos, List<int> orderedToOriginalIndex)
      _getOrderedExistingPhotosWithIndices() {
    final photos = widget.existingPhotos;
    final primaryIndex = photos.indexWhere((p) => p.isPrimary);
    if (primaryIndex == -1 || primaryIndex == 0) {
      return (
        List<Photo>.from(photos),
        List.generate(photos.length, (i) => i),
      );
    }
    final ordered = [
      photos[primaryIndex],
      ...photos.sublist(0, primaryIndex),
      ...photos.sublist(primaryIndex + 1),
    ];
    final indices = [
      primaryIndex,
      ...List.generate(primaryIndex, (i) => i),
      ...List.generate(
        photos.length - primaryIndex - 1,
        (i) => i + primaryIndex + 1,
      ),
    ];
    return (ordered, indices);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final controlBgColor = ThemeState().isBlueTheme
        ? BlueThemeColors.surface
        : theme.colorScheme.surfaceContainerHighest;

    // Compute once per build instead of per item (avoids O(n²))
    final (_, orderedToOriginalIndex) =
        _getOrderedExistingPhotosWithIndices();
    final existingCount = widget.existingPhotos.length;
    final selectedCount = widget.selectedPhotos.length;
    final primaryId = widget.existingPhotos
        .where((p) => p.isPrimary)
        .firstOrNull
        ?.id ?? 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
        color: controlBgColor,
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
                          theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurfaceVariant
                              : Colors.black,
                    ),
                  ),
                ),
                if (widget.selectedPhotos.length < widget.maxPhotos)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: IconButton(
                          onPressed: () {
                            HapticFeedbackUtils.impact();
                            _triggerScaleAnimation();
                            _showImageSourceDialog();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          tooltip: L10n.get("add_photo"),
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Combined photos grid (existing + new photos)
            if (existingCount > 0 || selectedCount > 0) ...[
              GridView.builder(
                key: ValueKey(
                  "combined_photos_${existingCount}_${selectedCount}_$primaryId",
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: existingCount + selectedCount,
                itemBuilder: (context, index) {
                  if (index < existingCount) {
                    final originalIndex = orderedToOriginalIndex[index];
                    return _buildExistingPhotoItem(originalIndex);
                  } else {
                    return _buildNewPhotoItem(index - existingCount);
                  }
                },
              ),

              // Instruction text below the combined grid
              if (widget.existingPhotos.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    L10n.get("tap_photo_to_make_primary"),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              // Instruction text for new photos
              if (widget.selectedPhotos.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    L10n.get("tap_photo_to_make_primary"),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExistingPhotoItem(int index) {
    final photo = widget.existingPhotos[index];
    final isDeleting = widget.deletingPhotoIds.contains(photo.id);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Photo image - tappable to make primary
            GestureDetector(
              onTap:
                  widget.makingPhotoPrimaryIds.contains(photo.id)
                      ? null
                      : () {
                        // Add haptic feedback
                        HapticFeedbackUtils.impact();
                        widget.onMakePhotoPrimary(index);
                      },
              child: CachedNetworkImage(
                imageUrl: _buildPhotoUrl(photo.photoUrl),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                memCacheHeight: 400,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeInCurve: Curves.easeOut,
                placeholder:
                    (context, url) => ColoredBox(
                      color: ThemeState().isBlueTheme
                          ? BlueThemeColors.surface
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => ColoredBox(
                      color: ThemeState().isBlueTheme
                          ? BlueThemeColors.surface
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
              ),
            ),
            // Overlay loader when making photo primary
            if (widget.makingPhotoPrimaryIds.contains(photo.id))
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const HouseLoadingIndicator(
                          size: 32,
                          color: Colors.white,
                          rotationDuration: Duration(milliseconds: 1000),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          L10n.get("making_primary"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Primary photo indicator
            if (photo.isPrimary)
              const Positioned(top: 4, left: 4, child: PrimaryPhotoPill()),
            // Delete button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap:
                    isDeleting
                        ? null
                        : () => widget.onDeleteExistingPhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        isDeleting
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.38)
                            : Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child:
                      isDeleting
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.38),
                              ),
                            ),
                          )
                          : const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPhotoItem(int index) {
    final photoPath = widget.selectedPhotos[index];
    // Only show primary badge if no existing photos have primary status
    final isPrimary =
        _primaryNewPhotoIndex == index &&
        !widget.existingPhotos.any((photo) => photo.isPrimary);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isPrimary
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Photo image - tappable to make primary
            GestureDetector(
              onTap: () {
                HapticFeedbackUtils.impact();
                _makeNewPhotoPrimary(index);
              },
              child: Image.file(
                File(photoPath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 400,
                cacheHeight: 400,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: ThemeState().isBlueTheme
                        ? BlueThemeColors.surface
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
            // Primary photo indicator
            if (isPrimary)
              const Positioned(top: 4, left: 4, child: PrimaryPhotoPill()),
            // Delete button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _deleteNewPhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
