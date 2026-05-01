import "package:uy_dosh/domain/models/photo.dart";

/// One slot in the edit-listing photo grid: either a photo that already
/// exists on the server (with an id / photo_url) or a new local file the
/// user just picked (still a path on disk, not uploaded yet).
sealed class PhotoItem {
  const PhotoItem();

  /// Stable key used by the reorderable grid to keep element identity across
  /// reorders.
  String get stableKey;
}

class ExistingPhotoItem extends PhotoItem {
  const ExistingPhotoItem(this.photo);
  final Photo photo;

  @override
  String get stableKey => "existing:${photo.id}";
}

class NewPhotoItem extends PhotoItem {
  const NewPhotoItem(this.path);
  final String path;

  @override
  String get stableKey => "new:$path";
}
