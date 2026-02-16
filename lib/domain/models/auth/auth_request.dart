import "package:uy_dosh/base/api/client/json_encodable.dart";

class AuthRequest implements IJsonEncodable {

  AuthRequest({required this.email});
  final String email;

  @override
  Map<String, dynamic> toJson() {
    return {"email": email};
  }
}
