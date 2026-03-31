import "package:uy_dosh/base/api/client/json_encodable.dart";

class FirebaseAuthRequest implements IJsonEncodable {
  FirebaseAuthRequest({
    required this.email,
    required this.firebaseUid,
    this.avatarUrl,
  });

  final String email;
  final String firebaseUid;
  /// Google / Firebase profile photo URL (optional). Used to backfill
  /// `avatar_url` when the user has no avatar stored yet.
  final String? avatarUrl;

  @override
  Map<String, dynamic> toJson() => {
    "email": email,
    "firebase_uid": firebaseUid,
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
      "avatar_url": avatarUrl!.trim(),
  };
}
