import 'package:uy_dosh/base/api/client/json_encodable.dart';

class AuthRequest implements IJsonEncodable {
  final String email;

  AuthRequest({required this.email});

  @override
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
