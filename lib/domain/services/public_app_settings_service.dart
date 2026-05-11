import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

abstract class IPublicAppSettingsService {
  Future<bool> getGeminiListingUiHidden();

  Future<bool> getLidarRoomScanDisabled();

  Future<bool> getCustomCameraDisabled();

  Future<bool> getListingContactsVisible();

  Future<bool> getListingDescriptionDictationMeterDisabled();
}

class PublicAppSettingsService implements IPublicAppSettingsService {
  PublicAppSettingsService(this._apiClient);

  final IPublicApiClient _apiClient;

  @override
  Future<bool> getGeminiListingUiHidden() async {
    try {
      final response = await _apiClient.get<dynamic>(
        "/app/settings/gemini-listing-ui-hidden",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map["hidden"] as bool? ?? false;
      }
      return false;
    } catch (e) {
      logger.d("PublicAppSettingsService.getGeminiListingUiHidden: $e");
      rethrow;
    }
  }

  @override
  Future<bool> getLidarRoomScanDisabled() async {
    try {
      final response = await _apiClient.get<dynamic>(
        "/app/settings/lidar-room-scan-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map["disabled"] as bool? ?? false;
      }
      return false;
    } catch (e) {
      logger.d("PublicAppSettingsService.getLidarRoomScanDisabled: $e");
      rethrow;
    }
  }

  @override
  Future<bool> getCustomCameraDisabled() async {
    try {
      final response = await _apiClient.get<dynamic>(
        "/app/settings/custom-camera-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map["disabled"] as bool? ?? false;
      }
      return false;
    } catch (e) {
      logger.d("PublicAppSettingsService.getCustomCameraDisabled: $e");
      rethrow;
    }
  }

  @override
  Future<bool> getListingContactsVisible() async {
    try {
      final response = await _apiClient.get<dynamic>(
        "/app/settings/listing-contacts-visible",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map["visible"] as bool? ?? false;
      }
      return false;
    } catch (e) {
      logger.d("PublicAppSettingsService.getListingContactsVisible: $e");
      rethrow;
    }
  }

  @override
  Future<bool> getListingDescriptionDictationMeterDisabled() async {
    try {
      final response = await _apiClient.get<dynamic>(
        "/app/settings/listing-description-dictation-meter-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map["disabled"] as bool? ?? false;
      }
      return false;
    } catch (e) {
      logger.d("PublicAppSettingsService.getListingDescriptionDictationMeterDisabled: $e");
      rethrow;
    }
  }
}
