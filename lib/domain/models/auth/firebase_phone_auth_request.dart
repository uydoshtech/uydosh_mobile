import "package:uy_dosh/base/api/client/json_encodable.dart";

class FirebasePhoneAuthRequest implements IJsonEncodable {
  FirebasePhoneAuthRequest({
    required this.firebaseUid,
    required this.phoneNumber,
    this.avatarUrl,
  });

  final String firebaseUid;

  /// E.164-formatted phone number, e.g. `+998901234567`. Must match the number
  /// that was verified by `FirebaseAuth.verifyPhoneNumber` on the client.
  final String phoneNumber;

  /// Optional profile photo URL. Only used to backfill `avatar_url` when the
  /// user has no avatar stored yet.
  final String? avatarUrl;

  @override
  Map<String, dynamic> toJson() => {
    "firebase_uid": firebaseUid,
    "phone_number": phoneNumber,
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
      "avatar_url": avatarUrl!.trim(),
  };
}
