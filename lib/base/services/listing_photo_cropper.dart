import "package:flutter/material.dart";
import "package:image_cropper/image_cropper.dart";
import "package:uy_dosh/presentation/screens/camera/listing_crop_screen.dart";

/// Opens the UyDosh-styled Flutter crop screen for a freshly captured/picked
/// listing photo.
///
/// Returns the cropped JPEG file path, or `null` if the user cancelled.
/// Callers typically fall back to the original source path on `null` so
/// cancelling means "skip cropping" rather than "discard photo".
///
/// Previously this delegated to the [ImageCropper] plugin (uCrop on Android,
/// TOCropViewController on iOS), but neither of those exposed enough
/// theming hooks to brand the screen as UyDosh — and the iOS plugin owned
/// the photo canvas, making it impossible to overlay our brand mark over
/// the crop rect. This indirection now opens [ListingCropScreen] which
/// gives us full control over both.
Future<String?> cropListingPhoto(
  BuildContext context,
  String sourcePath, {
  CropAspectRatio? lockedAspectRatio,
}) async {
  final navigator = Navigator.of(context);
  // Convert the legacy [CropAspectRatio] (used by callers that haven't been
  // ported off [image_cropper]'s API yet) into the simple `width/height`
  // double our screen accepts. `null` means free-form cropping.
  final lockedRatio = lockedAspectRatio == null
      ? null
      : lockedAspectRatio.ratioX / lockedAspectRatio.ratioY;
  try {
    return await navigator.push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ListingCropScreen(
          sourcePath: sourcePath,
          lockedAspectRatio: lockedRatio,
        ),
      ),
    );
  } catch (_) {
    // Best-effort: any failure shouldn't block the user from saving the
    // photo as-is. The caller will fall back to the original path when
    // this returns null.
    return null;
  }
}
