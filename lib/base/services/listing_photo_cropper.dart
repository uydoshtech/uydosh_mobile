import "package:flutter/material.dart";
import "package:uy_dosh/presentation/screens/camera/listing_crop_screen.dart";

/// Opens the UyDosh-styled Flutter crop screen for a freshly captured/picked
/// listing photo.
///
/// Returns the cropped JPEG file path, or `null` if the user cancelled.
/// Callers typically fall back to the original source path on `null` so
/// cancelling means "skip cropping" rather than "discard photo".
///
/// Previously this delegated to the `image_cropper` plugin (uCrop on Android,
/// TOCropViewController on iOS), but neither of those exposed enough
/// theming hooks to brand the screen as UyDosh — and the iOS plugin owned
/// the photo canvas, making it impossible to overlay our brand mark over
/// the crop rect. This indirection now opens [ListingCropScreen] which
/// gives us full control over both.
///
/// [lockedAspectRatio] is `width / height`; `null` means free-form cropping.
Future<String?> cropListingPhoto(
  BuildContext context,
  String sourcePath, {
  double? lockedAspectRatio,
}) async {
  final navigator = Navigator.of(context);
  try {
    return await navigator.push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ListingCropScreen(
          sourcePath: sourcePath,
          lockedAspectRatio: lockedAspectRatio,
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
