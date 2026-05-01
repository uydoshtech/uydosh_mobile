import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/listing_photo_cropper.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/presentation/screens/camera/custom_camera_screen.dart";
import "package:uy_dosh/presentation/screens/permissions/camera_permission_gate.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/photo_item.dart";
import "package:uy_dosh/presentation/widgets/common/primary_photo_pill.dart";
import "package:uy_dosh/presentation/widgets/common/reorderable_photo_grid.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Photo section used by the edit-listing screen.
///
/// Renders existing (server-side) and newly-picked local photos in a single
/// reorderable grid. The parent keeps the canonical data: [existingPhotos],
/// [selectedPhotos], and now a combined [orderedItems] list that describes
/// the current on-screen order.
///
/// When the user drags a tile, [onReorderItems] fires with the new order so
/// the parent can persist it on save.
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
    this.orderedItems,
    this.onReorderItems,
    this.onMakeNewPhotoPrimary,
    this.maxPhotos = 5,
    this.isRequired = false,
  });

  final List<String> selectedPhotos;
  final Function(List<String>) onPhotosChanged;
  final List<Photo> existingPhotos;
  final Function(int) onDeleteExistingPhoto;
  final Function(int) onMakePhotoPrimary;
  final Function(int)? onMakeNewPhotoPrimary;
  final Set<int> deletingPhotoIds;
  final Set<int> makingPhotoPrimaryIds;
  final int maxPhotos;
  final bool isRequired;

  /// Caller-owned display order. When provided, tiles are rendered in this
  /// order and [onReorderItems] is called on drag. When null, the widget
  /// falls back to the legacy layout (primary existing first, then the rest,
  /// then new photos) and disables drag reordering.
  final List<PhotoItem>? orderedItems;
  final Function(List<PhotoItem> newOrder)? onReorderItems;

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  int? _primaryNewPhotoIndex; // Track which new photo is primary

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await _picker.pickMultiImage(
          maxWidth: 1280,
          maxHeight: 720,
          imageQuality: 75,
        );

        if (images.isNotEmpty) {
          final remainingSlots =
              widget.maxPhotos - widget.selectedPhotos.length;
          final imagesToProcess = images.take(remainingSlots).toList();

          if (imagesToProcess.isNotEmpty) {
            final newPhotos = List<String>.from(widget.selectedPhotos);

            for (final image in imagesToProcess) {
              newPhotos.add(image.path);
            }

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
        // Always use our in-app [CustomCameraScreen] for camera capture.
        // We deliberately do NOT fall back to `image_picker` here even
        // when the server-side `customCameraDisabled` flag is on:
        // `UIImagePickerController` on iOS forces its own (un-themable)
        // "Retake / Use Photo" preview and our branded review screen
        // would then stack on top of it — two previews back-to-back of
        // the exact same photo, which looks broken. Show the rationale,
        // then push our camera, which has the branded review built in.
        final granted = await CameraPermissionGate.ensure(context);
        if (!granted || !mounted) return;

        final capturedPath = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => const CustomCameraScreen(),
            fullscreenDialog: true,
          ),
        );

        if (capturedPath != null) {
          if (widget.selectedPhotos.length < widget.maxPhotos) {
            // Offer crop/rotate right after capture. Cancelling the cropper
            // silently keeps the original photo so we never punish the user
            // for taking a shot they don't want to crop.
            var photoPath = capturedPath;
            if (mounted) {
              final croppedPath = await cropListingPhoto(context, photoPath);
              if (croppedPath != null) photoPath = croppedPath;
            }

            final newPhotos = List<String>.from(widget.selectedPhotos);
            newPhotos.add(photoPath);

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
          title: Text(L10n.get("max_photos_reached")),
          content: Text(L10n.get("max_photos_message")),
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (context) {
        final theme = Theme.of(context);
        const radius = BorderRadius.vertical(top: Radius.circular(20));
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassBottomSheetSurface(
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

    if (_primaryNewPhotoIndex != null) {
      if (index == _primaryNewPhotoIndex) {
        if (newPhotos.isNotEmpty) {
          _primaryNewPhotoIndex = 0;
        } else {
          _primaryNewPhotoIndex = null;
        }
      } else if (index < _primaryNewPhotoIndex!) {
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
    if (_primaryNewPhotoIndex == index) return;

    setState(() {
      _primaryNewPhotoIndex = index;
    });

    widget.onMakeNewPhotoPrimary?.call(index);

    ToastTheme.showSuccess(
      context,
      message: L10n.get("photo_made_primary"),
    );
  }

  String _buildPhotoUrl(String photoUrl) {
    if (photoUrl.startsWith("http")) {
      return photoUrl;
    }
    return "${EnvironmentUtil.basePath}$photoUrl";
  }

  /// Fallback display order when the parent doesn't provide [orderedItems]:
  /// existing primary first, remaining existing next, then new photos.
  List<PhotoItem> _legacyOrderedItems() {
    final items = <PhotoItem>[];
    final photos = widget.existingPhotos;
    final primaryIndex = photos.indexWhere((p) => p.isPrimary);
    if (primaryIndex > 0) {
      items.add(ExistingPhotoItem(photos[primaryIndex]));
      for (var i = 0; i < photos.length; i++) {
        if (i == primaryIndex) continue;
        items.add(ExistingPhotoItem(photos[i]));
      }
    } else {
      for (final p in photos) {
        items.add(ExistingPhotoItem(p));
      }
    }
    for (final path in widget.selectedPhotos) {
      items.add(NewPhotoItem(path));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final orderedItems = widget.orderedItems ?? _legacyOrderedItems();
    final canReorder = widget.orderedItems != null && widget.onReorderItems != null;

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

            if (orderedItems.isNotEmpty) ...[
              ReorderablePhotoGrid(
                itemCount: orderedItems.length,
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.35,
                keyExtractor: (i) => orderedItems[i].stableKey,
                canDrag: canReorder
                    ? (i) {
                        // Don't let the user drag a tile that's mid-flight with
                        // the server (deleting, or being set as primary): its
                        // state is about to change under us.
                        final item = orderedItems[i];
                        if (item is ExistingPhotoItem) {
                          if (widget.deletingPhotoIds.contains(item.photo.id)) {
                            return false;
                          }
                          if (widget.makingPhotoPrimaryIds
                              .contains(item.photo.id)) {
                            return false;
                          }
                        }
                        return true;
                      }
                    : (_) => false,
                onReorder: (from, to) {
                  if (!canReorder) return;
                  final newOrder = List<PhotoItem>.from(orderedItems);
                  final moved = newOrder.removeAt(from);
                  newOrder.insert(to, moved);
                  widget.onReorderItems!(newOrder);
                },
                itemBuilder: (context, index, _) {
                  final item = orderedItems[index];
                  final isFirst = index == 0;
                  if (item is ExistingPhotoItem) {
                    final originalIndex = widget.existingPhotos
                        .indexWhere((p) => p.id == item.photo.id);
                    return _buildExistingPhotoItem(
                      originalIndex < 0 ? 0 : originalIndex,
                      treatAsPrimary: canReorder ? isFirst : false,
                      allowTapToPrimary: !canReorder,
                    );
                  }
                  item as NewPhotoItem;
                  final originalIndex =
                      widget.selectedPhotos.indexOf(item.path);
                  return _buildNewPhotoItem(
                    originalIndex < 0 ? 0 : originalIndex,
                    treatAsPrimary: canReorder
                        ? isFirst
                        : (_primaryNewPhotoIndex == originalIndex &&
                            !widget.existingPhotos.any((p) => p.isPrimary)),
                    allowTapToPrimary: !canReorder,
                  );
                },
              ),

              if (orderedItems.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    L10n.get(canReorder
                        ? "drag_photo_to_reorder"
                        : "tap_photo_to_make_primary"),
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

  Widget _buildExistingPhotoItem(
    int index, {
    bool treatAsPrimary = false,
    bool allowTapToPrimary = true,
  }) {
    final photo = widget.existingPhotos[index];
    final isDeleting = widget.deletingPhotoIds.contains(photo.id);
    final showPrimary = treatAsPrimary || photo.isPrimary;

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
            GestureDetector(
              onTap: !allowTapToPrimary ||
                      widget.makingPhotoPrimaryIds.contains(photo.id)
                  ? null
                  : () {
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
                  memCacheHeight: 400,
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
            if (showPrimary)
              const Positioned(top: 4, left: 4, child: PrimaryPhotoPill()),
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

  Widget _buildNewPhotoItem(
    int index, {
    bool treatAsPrimary = false,
    bool allowTapToPrimary = true,
  }) {
    final photoPath = widget.selectedPhotos[index];
    final isPrimary = treatAsPrimary ||
        (_primaryNewPhotoIndex == index &&
            !widget.existingPhotos.any((photo) => photo.isPrimary));

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
            GestureDetector(
              onTap: allowTapToPrimary
                  ? () {
                      HapticFeedbackUtils.impact();
                      _makeNewPhotoPrimary(index);
                    }
                  : null,
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
            if (isPrimary)
              const Positioned(top: 4, left: 4, child: PrimaryPhotoPill()),
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
