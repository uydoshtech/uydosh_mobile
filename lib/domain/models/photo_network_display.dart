import "package:uy_dosh/domain/models/photo.dart";

extension PhotoNetworkDisplayUrl on Photo {
  /// Same filesystem path may be reused after a replace/delete on the server.
  /// Varies the request URL so [CachedNetworkImage] cannot serve a stale bitmap.
  String get networkDisplayPhotoUrl {
    final raw = photoUrl;
    final sep = raw.contains("?") ? "&" : "?";
    return "$raw${sep}photo_id=$id";
  }
}
