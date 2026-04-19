import "package:uy_dosh/base/api/client/json_encodable.dart";

class RegisterFcmTokenRequest implements IJsonEncodable {
  RegisterFcmTokenRequest({
    required this.token,
    required this.platform,
    this.deviceId,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
  });

  final String token;
  final String platform;
  final String? deviceId;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;

  @override
  Map<String, dynamic> toJson() => {
        "token": token,
        "platform": platform,
        if (deviceId != null && deviceId!.isNotEmpty) "device_id": deviceId,
        if (deviceModel != null && deviceModel!.isNotEmpty)
          "device_model": deviceModel,
        if (osVersion != null && osVersion!.isNotEmpty) "os_version": osVersion,
        if (appVersion != null && appVersion!.isNotEmpty)
          "app_version": appVersion,
      };
}
