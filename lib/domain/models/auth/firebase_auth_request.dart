import "package:uy_dosh/base/api/client/json_encodable.dart";

class FirebaseAuthRequest implements IJsonEncodable {
  FirebaseAuthRequest({
    required this.email,
    required this.firebaseUid,
    required this.idToken,
    this.avatarUrl,
  });

  final String email;
  final String firebaseUid;
  final String idToken;

  /// Google / Firebase profile photo URL (optional). Used to backfill
  /// `avatar_url` when the user has no avatar stored yet.
  final String? avatarUrl;

  @override
  Map<String, dynamic> toJson() => {
        "email": email,
        "firebase_uid": firebaseUid,
        "id_token": idToken,
        if (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
          "avatar_url": avatarUrl!.trim(),
      };
}
