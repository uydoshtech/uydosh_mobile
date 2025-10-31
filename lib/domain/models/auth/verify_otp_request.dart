import 'package:uy_dosh/base/api/client/json_encodable.dart';

class VerifyOtpRequest implements IJsonEncodable {
  final String email;
  final String code;
  final String type;

  VerifyOtpRequest({
    required this.email,
    required this.code,
    required this.type,
  });

  @override
  dynamic toJson() {
    return {'email': email, 'code': code, 'type': type};
  }
}
