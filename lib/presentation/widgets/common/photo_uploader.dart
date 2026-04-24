import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/config/client_custom_camera_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/presentation/screens/camera/custom_camera_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_photo_pill.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            final newPhotos = List<String>.from(widget.selectedPhotos);
            newPhotos.add(capturedPath);

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
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(context).pop();
              },
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
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final sheetHeight = MediaQuery.sizeOf(context).height * 0.35;
        return SafeArea(
          child: SizedBox(
            height: sheetHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ThemeIcon(
                  CupertinoIcons.photo,
                  size: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                const SizedBox(height: 10),
                Text(
                  L10n.getWithParams(
                    "listing_photos_count",
                    params: {
                      "current":
                          "${(widget.existingPhotos.length + widget.selectedPhotos.length).clamp(0, widget.maxPhotos)}",
                      "max": "${widget.maxPhotos}",
                    },
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ThreeDPillButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    backgroundColor: theme.colorScheme.surface,
                    onPressed: () {
                      HapticFeedbackUtils.impact();
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        const ThemeIcon(
                          Icons.camera_alt_outlined,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            L10n.get("take_photo"),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ThreeDPillButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    backgroundColor: theme.colorScheme.surface,
                    onPressed: () {
                      HapticFeedbackUtils.impact();
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        const ThemeIcon(
                          Icons.photo_library_outlined,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            L10n.get("choose_from_gallery"),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

    // Compute once per build instead of per item (avoids O(n²))
    final (_, orderedToOriginalIndex) =
        _getOrderedExistingPhotosWithIndices();
    final existingCount = widget.existingPhotos.length;
    final selectedCount = widget.selectedPhotos.length;
    final primaryId = widget.existingPhotos
        .where((p) => p.isPrimary)
        .firstOrNull
        ?.id ?? 0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: theme,
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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (widget.selectedPhotos.length < widget.maxPhotos)
                  Builder(
                    builder: (context) {
                      final isLightTheme = ThemeState().isLightTheme;
                      final addButtonBaseColor =
                          isLightTheme
                              ? theme.colorScheme.surface
                              : theme.colorScheme.primary;
                      final addIconColor =
                          isLightTheme ? Colors.black : Colors.white;
                      return Tooltip(
                        message: L10n.get("add_photo"),
                        child: ThreeDPillButton(
                          padding: const EdgeInsets.all(8),
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: addButtonBaseColor,
                          onPressed: () {
                            HapticFeedbackUtils.impact();
                            _showImageSourceDialog();
                          },
                          child: ThemeIcon(
                            Icons.add,
                            color: addIconColor,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Combined photos grid (existing + new photos)
            if (existingCount > 0 || selectedCount > 0) ...[
              GridView.builder(
                key: ValueKey(
                  "combined_photos_${existingCount}_${selectedCount}_$primaryId",
                ),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  // Wider-than-tall tiles shrink row height vs 1:1 squares (less
                  // empty-looking area on edit/create listing with few photos).
                  childAspectRatio: 1.35,
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
              child: ColoredBox(
                color: ThemeState().isBlueTheme
                    ? BlueThemeColors.surface
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: CachedNetworkImage(
                  imageUrl: _buildPhotoUrl(photo.photoUrl),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 400,
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeInCurve: Curves.easeOut,
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  errorWidget:
                      (context, url, error) => ThemeIcon(
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
                          : const ThemeIcon(
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
              child: ColoredBox(
                color: ThemeState().isBlueTheme
                    ? BlueThemeColors.surface
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Image.file(
                  File(photoPath),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  errorBuilder: (context, error, stackTrace) {
                    return ThemeIcon(
                      Icons.broken_image,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    );
                  },
                ),
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
                  child: const ThemeIcon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
