import "dart:io";
import "dart:math";

import "package:image_picker/image_picker.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

final _rand = Random();

/// Copies a gallery/camera [XFile] into a unique file under the app temp dir.
///
/// The OS / image_picker often hands out paths that may be reused or rotated;
/// using the path as a [PhotoItem.stableKey] or list identity then collides.
/// Copying immediately keeps thumbnails, reorder keys, and uploads consistent.
Future<String> materializePickedPhotoToUniqueFile(XFile picked) async {
  final dir = await getTemporaryDirectory();
  final base =
      "listing_pick_${DateTime.now().microsecondsSinceEpoch}_${_rand.nextInt(1 << 30)}";
  final ext = p.extension(picked.path);
  final safeExt = ext.isNotEmpty && ext.length <= 8 ? ext : ".jpg";
  final destPath = p.join(dir.path, "$base$safeExt");
  await File(picked.path).copy(destPath);
  return destPath;
}
