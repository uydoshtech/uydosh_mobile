import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

Map<String, dynamic> _requireJsonMap(dynamic response, String errorMessage) {
  if (response is! Map) {
    throw Exception(errorMessage);
  }
  return Map<String, dynamic>.from(response);
}

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

class GeminiListingUiHiddenResponse {
  GeminiListingUiHiddenResponse({required this.hidden});

  factory GeminiListingUiHiddenResponse.fromJson(Map<String, dynamic> json) {
    return GeminiListingUiHiddenResponse(
      hidden: json["hidden"] as bool? ?? false,
    );
  }

  final bool hidden;
}

class _PatchGeminiListingUiHiddenRequest implements IJsonEncodable {
  _PatchGeminiListingUiHiddenRequest({required this.hidden});

  final bool hidden;

  @override
  dynamic toJson() => {"hidden": hidden};
}

class LidarRoomScanDisabledResponse {
  LidarRoomScanDisabledResponse({required this.disabled});

  factory LidarRoomScanDisabledResponse.fromJson(Map<String, dynamic> json) {
    return LidarRoomScanDisabledResponse(
      disabled: json["disabled"] as bool? ?? false,
    );
  }

  final bool disabled;
}

class _PatchLidarRoomScanDisabledRequest implements IJsonEncodable {
  _PatchLidarRoomScanDisabledRequest({required this.disabled});

  final bool disabled;

  @override
  dynamic toJson() => {"disabled": disabled};
}

abstract class IAdminContentModerationSettingsService {
  Future<ContentModerationBlurResponse> getContentModerationBlurSetting();

  Future<ContentModerationBlurResponse> setContentModerationBlurEnabled({
    required bool enabled,
  });

  Future<GeminiListingUiHiddenResponse> getGeminiListingUiHiddenSetting();

  Future<GeminiListingUiHiddenResponse> setGeminiListingUiHidden({
    required bool hidden,
  });

  Future<LidarRoomScanDisabledResponse> getLidarRoomScanDisabledSetting();

  Future<LidarRoomScanDisabledResponse> setLidarRoomScanDisabled({
    required bool disabled,
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
      return ContentModerationBlurResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from content moderation settings",
        ),
      );
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
      return ContentModerationBlurResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from content moderation settings",
        ),
      );
    } catch (e) {
      logger.d("Error updating content moderation blur setting: $e");
      rethrow;
    }
  }

  @override
  Future<GeminiListingUiHiddenResponse> getGeminiListingUiHiddenSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/gemini-listing-ui-hidden",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return GeminiListingUiHiddenResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from gemini listing UI settings",
        ),
      );
    } catch (e) {
      logger.d("Error loading gemini listing UI hidden setting: $e");
      rethrow;
    }
  }

  @override
  Future<GeminiListingUiHiddenResponse> setGeminiListingUiHidden({
    required bool hidden,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/gemini-listing-ui-hidden",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchGeminiListingUiHiddenRequest(hidden: hidden),
      );
      return GeminiListingUiHiddenResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from gemini listing UI settings",
        ),
      );
    } catch (e) {
      logger.d("Error updating gemini listing UI hidden setting: $e");
      rethrow;
    }
  }

  @override
  Future<LidarRoomScanDisabledResponse> getLidarRoomScanDisabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/lidar-room-scan-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return LidarRoomScanDisabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from LiDAR room scan settings",
        ),
      );
    } catch (e) {
      logger.d("Error loading LiDAR room scan disabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<LidarRoomScanDisabledResponse> setLidarRoomScanDisabled({
    required bool disabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/lidar-room-scan-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchLidarRoomScanDisabledRequest(disabled: disabled),
      );
      return LidarRoomScanDisabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from LiDAR room scan settings",
        ),
      );
    } catch (e) {
      logger.d("Error updating LiDAR room scan disabled setting: $e");
      rethrow;
    }
  }
}
