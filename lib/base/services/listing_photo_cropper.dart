import "package:flutter/material.dart";
import "package:image_cropper/image_cropper.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// Opens the platform native cropper (uCrop on Android, TOCropViewController
/// on iOS) for a freshly captured/picked listing photo.
///
/// Returns the cropped file path, or `null` if the user cancelled. Callers
/// typically fall back to the original source path on `null` so cancelling
/// means "skip cropping" rather than "discard photo".
Future<String?> cropListingPhoto(
  BuildContext context,
  String sourcePath, {
  CropAspectRatio? lockedAspectRatio,
}) async {
  final theme = Theme.of(context);
  final toolbarTitle = L10n.get("crop_listing_photo");
  final doneTitle = L10n.get("crop_done");
  final cancelTitle = L10n.get("crop_cancel");

  try {
    final result = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      // Cap the cropped output so subsequent watermarking + upload stays
      // light. Listing photos are displayed at modest sizes; 1600px on the
      // long side keeps detail without bloating storage.
      maxWidth: 1600,
      maxHeight: 1600,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      aspectRatio: lockedAspectRatio,
      aspectRatioPresets: const [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: toolbarTitle,
          toolbarColor: theme.colorScheme.surface,
          toolbarWidgetColor: theme.colorScheme.onSurface,
          statusBarLight: theme.brightness == Brightness.light,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: theme.colorScheme.primary,
          lockAspectRatio: lockedAspectRatio != null,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: toolbarTitle,
          doneButtonTitle: doneTitle,
          cancelButtonTitle: cancelTitle,
          aspectRatioLockEnabled: lockedAspectRatio != null,
          resetAspectRatioEnabled: lockedAspectRatio == null,
          rotateButtonsHidden: false,
          aspectRatioPickerButtonHidden: lockedAspectRatio != null,
        ),
      ],
    );
    return result?.path;
  } catch (_) {
    // Best-effort: any cropper failure (plugin error, missing activity, etc.)
    // shouldn't block the user from saving the photo as-is. The caller will
    // fall back to the original path when this returns null.
    return null;
  }
}
