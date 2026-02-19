import "package:uy_dosh/base/api/client/json_encodable.dart";

class FirebaseAuthRequest implements IJsonEncodable {
  FirebaseAuthRequest({required this.email, required this.firebaseUid});

  final String email;
  final String firebaseUid;

  @override
  Map<String, dynamic> toJson() => {
    "email": email,
    "firebase_uid": firebaseUid,
  };
}
