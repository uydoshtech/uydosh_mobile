import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

class ContentModerationBlurResponse {
  ContentModerationBlurResponse({required this.enabled});

  factory ContentModerationBlurResponse.fromJson(Map<String, dynamic> json) {
    return ContentModerationBlurResponse(
      enabled: json["enabled"] as bool? ?? true,
    );
  }

  final bool enabled;
}

class _PatchContentModerationBlurRequest implements IJsonEncodable {
  _PatchContentModerationBlurRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

abstract class IAdminContentModerationSettingsService {
  Future<ContentModerationBlurResponse> getContentModerationBlurSetting();

  Future<ContentModerationBlurResponse> setContentModerationBlurEnabled({
    required bool enabled,
  });
}

class AdminContentModerationSettingsService
    implements IAdminContentModerationSettingsService {
  AdminContentModerationSettingsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<ContentModerationBlurResponse> getContentModerationBlurSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/content-moderation-blur",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected response from content moderation settings");
      }
      return ContentModerationBlurResponse.fromJson(response);
    } catch (e) {
      logger.d("Error loading content moderation blur setting: $e");
      rethrow;
    }
  }

  @override
  Future<ContentModerationBlurResponse> setContentModerationBlurEnabled({
    required bool enabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/content-moderation-blur",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchContentModerationBlurRequest(enabled: enabled),
      );
      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected response from content moderation settings");
      }
      return ContentModerationBlurResponse.fromJson(response);
    } catch (e) {
      logger.d("Error updating content moderation blur setting: $e");
      rethrow;
    }
  }
}
