import "package:uy_dosh/base/api/client/json_encodable.dart";

class VerifyOtpRequest implements IJsonEncodable {

  VerifyOtpRequest({
    required this.email,
    required this.code,
    required this.type,
  });
  final String email;
  final String code;
  final String type;

  @override
  dynamic toJson() {
    return {"email": email, "code": code, "type": type};
  }
}
