import "package:uy_dosh/base/api/client/json_encodable.dart";

class RegisterFcmTokenRequest implements IJsonEncodable {
  RegisterFcmTokenRequest({required this.token, required this.platform});

  final String token;
  final String platform;

  @override
  Map<String, dynamic> toJson() => {
        "token": token,
        "platform": platform,
      };
}
