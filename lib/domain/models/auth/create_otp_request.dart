import 'package:uy_dosh/base/api/client/json_encodable.dart';

class CreateOtpRequest implements IJsonEncodable {
  final String email;
  final String type;

  CreateOtpRequest({required this.email, required this.type});

  @override
  dynamic toJson() {
    final Map<String, dynamic> json = {'email': email, 'type': type};

    return json;
  }
}
