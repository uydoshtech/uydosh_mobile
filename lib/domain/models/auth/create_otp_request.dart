import "package:uy_dosh/base/api/client/json_encodable.dart";

class CreateOtpRequest implements IJsonEncodable {

  CreateOtpRequest({required this.email, required this.type});
  final String email;
  final String type;

  @override
  dynamic toJson() {
    final json = <String, dynamic>{"email": email, "type": type};

    return json;
  }
}
