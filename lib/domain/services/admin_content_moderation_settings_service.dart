import "dart:convert";

import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

Map<String, dynamic> _requireJsonMap(dynamic response, String errorMessage) {
  dynamic decoded = response;
  if (response is String) {
    final s = response.trim();
    if (s.isEmpty) {
      throw Exception(errorMessage);
    }
    try {
      decoded = jsonDecode(s);
    } catch (_) {
      throw Exception(errorMessage);
    }
  }
  if (decoded is! Map) {
    throw Exception(errorMessage);
  }
  return Map<String, dynamic>.from(decoded);
}

/// Accepts bool, int, or common string forms (matches relaxed server parsers).
bool _parseBoolLoose(dynamic value, {required bool defaultValue}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final s = value.trim().toLowerCase();
    if (s == "true" || s == "1" || s == "yes") {
      return true;
    }
    if (s == "false" || s == "0" || s == "no") {
      return false;
    }
  }
  return defaultValue;
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

class CustomCameraDisabledResponse {
  CustomCameraDisabledResponse({required this.disabled});

  factory CustomCameraDisabledResponse.fromJson(Map<String, dynamic> json) {
    return CustomCameraDisabledResponse(
      disabled: json["disabled"] as bool? ?? false,
    );
  }

  final bool disabled;
}

class _PatchCustomCameraDisabledRequest implements IJsonEncodable {
  _PatchCustomCameraDisabledRequest({required this.disabled});

  final bool disabled;

  @override
  dynamic toJson() => {"disabled": disabled};
}

class ListingContactsVisibleResponse {
  ListingContactsVisibleResponse({required this.visible});

  factory ListingContactsVisibleResponse.fromJson(Map<String, dynamic> json) {
    return ListingContactsVisibleResponse(
      visible: json["visible"] as bool? ?? false,
    );
  }

  final bool visible;
}

class _PatchListingContactsVisibleRequest implements IJsonEncodable {
  _PatchListingContactsVisibleRequest({required this.visible});

  final bool visible;

  @override
  dynamic toJson() => {"visible": visible};
}

class ListingDescriptionDictationMeterDisabledResponse {
  ListingDescriptionDictationMeterDisabledResponse({required this.disabled});

  factory ListingDescriptionDictationMeterDisabledResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListingDescriptionDictationMeterDisabledResponse(
      disabled: json["disabled"] as bool? ?? false,
    );
  }

  final bool disabled;
}

class _PatchListingDescriptionDictationMeterDisabledRequest
    implements IJsonEncodable {
  _PatchListingDescriptionDictationMeterDisabledRequest(
      {required this.disabled});

  final bool disabled;

  @override
  dynamic toJson() => {"disabled": disabled};
}

class ListingGigModerationQueueResponse {
  ListingGigModerationQueueResponse({required this.enabled});

  factory ListingGigModerationQueueResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListingGigModerationQueueResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: true),
    );
  }

  final bool enabled;
}

class _PatchListingGigModerationQueueRequest implements IJsonEncodable {
  _PatchListingGigModerationQueueRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

class PropertyNavEnabledResponse {
  PropertyNavEnabledResponse({required this.enabled});

  factory PropertyNavEnabledResponse.fromJson(Map<String, dynamic> json) {
    return PropertyNavEnabledResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: false),
    );
  }

  final bool enabled;
}

class _PatchPropertyNavEnabledRequest implements IJsonEncodable {
  _PatchPropertyNavEnabledRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

class WebAppMultipleInstanceCheckEnabledResponse {
  WebAppMultipleInstanceCheckEnabledResponse({required this.enabled});

  factory WebAppMultipleInstanceCheckEnabledResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebAppMultipleInstanceCheckEnabledResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: false),
    );
  }

  final bool enabled;
}

class _PatchWebAppMultipleInstanceCheckEnabledRequest
    implements IJsonEncodable {
  _PatchWebAppMultipleInstanceCheckEnabledRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

class HomeStartViewResponse {
  HomeStartViewResponse({required this.view});

  factory HomeStartViewResponse.fromJson(Map<String, dynamic> json) {
    final rawView = json["view"]?.toString().trim().toLowerCase();
    return HomeStartViewResponse(view: rawView == "feed" ? "feed" : "map");
  }

  final String view;
}

class _PatchHomeStartViewRequest implements IJsonEncodable {
  _PatchHomeStartViewRequest({required this.view});

  final String view;

  @override
  dynamic toJson() => {"view": view};
}

class MapLayerDefaultsResponse {
  MapLayerDefaultsResponse({
    required this.districts,
    required this.metro,
    required this.universities,
  });

  factory MapLayerDefaultsResponse.fromJson(Map<String, dynamic> json) {
    return MapLayerDefaultsResponse(
      districts: _parseBoolLoose(json["districts"], defaultValue: true),
      metro: _parseBoolLoose(json["metro"], defaultValue: true),
      universities: _parseBoolLoose(json["universities"], defaultValue: false),
    );
  }

  final bool districts;
  final bool metro;
  final bool universities;
}

class _PatchMapLayerDefaultsRequest implements IJsonEncodable {
  _PatchMapLayerDefaultsRequest({
    required this.districts,
    required this.metro,
    required this.universities,
  });

  final bool districts;
  final bool metro;
  final bool universities;

  @override
  dynamic toJson() => {
        "districts": districts,
        "metro": metro,
        "universities": universities,
      };
}

class AdminListingConversationsEnabledResponse {
  AdminListingConversationsEnabledResponse({required this.enabled});

  factory AdminListingConversationsEnabledResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminListingConversationsEnabledResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: false),
    );
  }

  final bool enabled;
}

class _PatchAdminListingConversationsEnabledRequest implements IJsonEncodable {
  _PatchAdminListingConversationsEnabledRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

class TelegramMessageBridgeEnabledResponse {
  TelegramMessageBridgeEnabledResponse({required this.enabled});

  factory TelegramMessageBridgeEnabledResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TelegramMessageBridgeEnabledResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: true),
    );
  }

  final bool enabled;
}

class _PatchTelegramMessageBridgeEnabledRequest implements IJsonEncodable {
  _PatchTelegramMessageBridgeEnabledRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

class RoomScanGlbConversionEnabledResponse {
  RoomScanGlbConversionEnabledResponse({required this.enabled});

  factory RoomScanGlbConversionEnabledResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoomScanGlbConversionEnabledResponse(
      enabled: _parseBoolLoose(json["enabled"], defaultValue: true),
    );
  }

  final bool enabled;
}

class _PatchRoomScanGlbConversionEnabledRequest implements IJsonEncodable {
  _PatchRoomScanGlbConversionEnabledRequest({required this.enabled});

  final bool enabled;

  @override
  dynamic toJson() => {"enabled": enabled};
}

class GroupFormingMaxActiveMembershipsResponse {
  GroupFormingMaxActiveMembershipsResponse({required this.limit});

  factory GroupFormingMaxActiveMembershipsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json["limit"];
    final parsed =
        raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? "");
    return GroupFormingMaxActiveMembershipsResponse(
      limit: parsed == null || parsed < 1 ? 2 : parsed,
    );
  }

  final int limit;
}

class _PatchGroupFormingMaxActiveMembershipsRequest implements IJsonEncodable {
  _PatchGroupFormingMaxActiveMembershipsRequest({required this.limit});

  final int limit;

  @override
  dynamic toJson() => {"limit": limit};
}

/// `limit == 0` means no daily cap is enforced on Telegram Mini App listing creation.
class TelegramMiniAppDailyListingLimitResponse {
  TelegramMiniAppDailyListingLimitResponse({required this.limit});

  factory TelegramMiniAppDailyListingLimitResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json["limit"];
    final parsed =
        raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? "");
    return TelegramMiniAppDailyListingLimitResponse(
      limit: parsed == null || parsed < 0 ? 0 : parsed,
    );
  }

  final int limit;
}

class _PatchTelegramMiniAppDailyListingLimitRequest implements IJsonEncodable {
  _PatchTelegramMiniAppDailyListingLimitRequest({required this.limit});

  final int limit;

  @override
  dynamic toJson() => {"limit": limit};
}

/// All settings shown on the "Настройки клиента" admin screen, fetched in a
/// single request (`GET /admin/settings/bulk`) instead of ~16 sequential ones.
class AdminSettingsBulkResponse {
  AdminSettingsBulkResponse({
    required this.contentModerationBlurEnabled,
    required this.geminiListingUiHidden,
    required this.lidarRoomScanDisabled,
    required this.customCameraDisabled,
    required this.listingDescriptionDictationMeterDisabled,
    required this.listingContactsVisible,
    required this.listingGigModerationQueueEnabled,
    required this.propertyNavEnabled,
    required this.webAppMultipleInstanceCheckEnabled,
    required this.homeStartView,
    required this.mapDefaultShowDistricts,
    required this.mapDefaultShowMetro,
    required this.mapDefaultShowUniversities,
    required this.adminListingConversationsEnabled,
    required this.telegramMessageBridgeEnabled,
    required this.roomScanGlbConversionEnabled,
    required this.groupFormingMaxActiveMemberships,
    required this.telegramMiniAppDailyListingLimit,
  });

  factory AdminSettingsBulkResponse.fromJson(Map<String, dynamic> json) {
    final rawView =
        json["homeStartView"]?.toString().trim().toLowerCase();
    final rawGroupLimit = json["groupFormingMaxActiveMemberships"];
    final parsedGroupLimit = rawGroupLimit is num
        ? rawGroupLimit.toInt()
        : int.tryParse(rawGroupLimit?.toString() ?? "");
    final rawDailyLimit = json["telegramMiniAppDailyListingLimit"];
    final parsedDailyLimit = rawDailyLimit is num
        ? rawDailyLimit.toInt()
        : int.tryParse(rawDailyLimit?.toString() ?? "");
    return AdminSettingsBulkResponse(
      contentModerationBlurEnabled:
          json["contentModerationBlurEnabled"] as bool? ?? true,
      geminiListingUiHidden: json["geminiListingUiHidden"] as bool? ?? false,
      lidarRoomScanDisabled: json["lidarRoomScanDisabled"] as bool? ?? false,
      customCameraDisabled: json["customCameraDisabled"] as bool? ?? false,
      listingDescriptionDictationMeterDisabled:
          json["listingDescriptionDictationMeterDisabled"] as bool? ?? false,
      listingContactsVisible: json["listingContactsVisible"] as bool? ?? false,
      listingGigModerationQueueEnabled: _parseBoolLoose(
        json["listingGigModerationQueueEnabled"],
        defaultValue: true,
      ),
      propertyNavEnabled: _parseBoolLoose(
        json["propertyNavEnabled"],
        defaultValue: false,
      ),
      webAppMultipleInstanceCheckEnabled: _parseBoolLoose(
        json["webAppMultipleInstanceCheckEnabled"],
        defaultValue: false,
      ),
      homeStartView: rawView == "feed" ? "feed" : "map",
      mapDefaultShowDistricts: _parseBoolLoose(
        json["mapDefaultShowDistricts"],
        defaultValue: true,
      ),
      mapDefaultShowMetro: _parseBoolLoose(
        json["mapDefaultShowMetro"],
        defaultValue: true,
      ),
      mapDefaultShowUniversities: _parseBoolLoose(
        json["mapDefaultShowUniversities"],
        defaultValue: false,
      ),
      adminListingConversationsEnabled: _parseBoolLoose(
        json["adminListingConversationsEnabled"],
        defaultValue: false,
      ),
      telegramMessageBridgeEnabled: _parseBoolLoose(
        json["telegramMessageBridgeEnabled"],
        defaultValue: true,
      ),
      roomScanGlbConversionEnabled: _parseBoolLoose(
        json["roomScanGlbConversionEnabled"],
        defaultValue: true,
      ),
      groupFormingMaxActiveMemberships:
          parsedGroupLimit == null || parsedGroupLimit < 1
              ? 2
              : parsedGroupLimit,
      telegramMiniAppDailyListingLimit:
          parsedDailyLimit == null || parsedDailyLimit < 0 ? 0 : parsedDailyLimit,
    );
  }

  final bool contentModerationBlurEnabled;
  final bool geminiListingUiHidden;
  final bool lidarRoomScanDisabled;
  final bool customCameraDisabled;
  final bool listingDescriptionDictationMeterDisabled;
  final bool listingContactsVisible;
  final bool listingGigModerationQueueEnabled;
  final bool propertyNavEnabled;
  final bool webAppMultipleInstanceCheckEnabled;
  final String homeStartView;
  final bool mapDefaultShowDistricts;
  final bool mapDefaultShowMetro;
  final bool mapDefaultShowUniversities;
  final bool adminListingConversationsEnabled;
  final bool telegramMessageBridgeEnabled;
  final bool roomScanGlbConversionEnabled;
  final int groupFormingMaxActiveMemberships;
  final int telegramMiniAppDailyListingLimit;
}

abstract class IAdminContentModerationSettingsService {
  /// Fetches every setting on the admin screen in a single request.
  Future<AdminSettingsBulkResponse> getAdminSettingsBulk();

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

  Future<CustomCameraDisabledResponse> getCustomCameraDisabledSetting();

  Future<CustomCameraDisabledResponse> setCustomCameraDisabled({
    required bool disabled,
  });

  Future<ListingContactsVisibleResponse> getListingContactsVisibleSetting();

  Future<ListingContactsVisibleResponse> setListingContactsVisible({
    required bool visible,
  });

  Future<ListingDescriptionDictationMeterDisabledResponse>
      getListingDescriptionDictationMeterDisabledSetting();

  Future<ListingDescriptionDictationMeterDisabledResponse>
      setListingDescriptionDictationMeterDisabled({required bool disabled});

  Future<ListingGigModerationQueueResponse>
      getListingGigModerationQueueSetting();

  Future<ListingGigModerationQueueResponse>
      setListingGigModerationQueueEnabled({
    required bool enabled,
  });

  Future<PropertyNavEnabledResponse> getPropertyNavEnabledSetting();

  Future<PropertyNavEnabledResponse> setPropertyNavEnabled({
    required bool enabled,
  });

  Future<WebAppMultipleInstanceCheckEnabledResponse>
      getWebAppMultipleInstanceCheckEnabledSetting();

  Future<WebAppMultipleInstanceCheckEnabledResponse>
      setWebAppMultipleInstanceCheckEnabled({required bool enabled});

  Future<HomeStartViewResponse> getHomeStartViewSetting();

  Future<HomeStartViewResponse> setHomeStartView({required String view});

  Future<MapLayerDefaultsResponse> getMapLayerDefaultsSetting();

  Future<MapLayerDefaultsResponse> setMapLayerDefaults({
    required bool districts,
    required bool metro,
    required bool universities,
  });

  Future<AdminListingConversationsEnabledResponse>
      getAdminListingConversationsEnabledSetting();

  Future<AdminListingConversationsEnabledResponse>
      setAdminListingConversationsEnabled({required bool enabled});

  Future<TelegramMessageBridgeEnabledResponse>
      getTelegramMessageBridgeEnabledSetting();

  Future<TelegramMessageBridgeEnabledResponse> setTelegramMessageBridgeEnabled(
      {required bool enabled});

  Future<RoomScanGlbConversionEnabledResponse>
      getRoomScanGlbConversionEnabledSetting();

  Future<RoomScanGlbConversionEnabledResponse>
      setRoomScanGlbConversionEnabled({required bool enabled});

  Future<GroupFormingMaxActiveMembershipsResponse>
      getGroupFormingMaxActiveMembershipsSetting();

  Future<GroupFormingMaxActiveMembershipsResponse>
      setGroupFormingMaxActiveMemberships({required int limit});

  Future<TelegramMiniAppDailyListingLimitResponse>
      getTelegramMiniAppDailyListingLimitSetting();

  Future<TelegramMiniAppDailyListingLimitResponse>
      setTelegramMiniAppDailyListingLimit({required int limit});
}

class AdminContentModerationSettingsService
    implements IAdminContentModerationSettingsService {
  AdminContentModerationSettingsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<AdminSettingsBulkResponse> getAdminSettingsBulk() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/bulk",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return AdminSettingsBulkResponse.fromJson(
        _requireJsonMap(response, "Unexpected response from bulk settings"),
      );
    } catch (e) {
      logger.d("Error loading bulk admin settings: $e");
      rethrow;
    }
  }

  @override
  Future<ContentModerationBlurResponse>
      getContentModerationBlurSetting() async {
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
  Future<GeminiListingUiHiddenResponse>
      getGeminiListingUiHiddenSetting() async {
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
  Future<LidarRoomScanDisabledResponse>
      getLidarRoomScanDisabledSetting() async {
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

  @override
  Future<CustomCameraDisabledResponse> getCustomCameraDisabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/custom-camera-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return CustomCameraDisabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from custom camera settings",
        ),
      );
    } catch (e) {
      logger.d("Error loading custom camera disabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<CustomCameraDisabledResponse> setCustomCameraDisabled({
    required bool disabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/custom-camera-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchCustomCameraDisabledRequest(disabled: disabled),
      );
      return CustomCameraDisabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from custom camera settings",
        ),
      );
    } catch (e) {
      logger.d("Error updating custom camera disabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<ListingContactsVisibleResponse>
      getListingContactsVisibleSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/listing-contacts-visible",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return ListingContactsVisibleResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from listing contacts settings",
        ),
      );
    } catch (e) {
      logger.d("Error loading listing contacts visible setting: $e");
      rethrow;
    }
  }

  @override
  Future<ListingContactsVisibleResponse> setListingContactsVisible({
    required bool visible,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/listing-contacts-visible",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchListingContactsVisibleRequest(visible: visible),
      );
      return ListingContactsVisibleResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from listing contacts settings",
        ),
      );
    } catch (e) {
      logger.d("Error updating listing contacts visible setting: $e");
      rethrow;
    }
  }

  @override
  Future<ListingDescriptionDictationMeterDisabledResponse>
      getListingDescriptionDictationMeterDisabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/listing-description-dictation-meter-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return ListingDescriptionDictationMeterDisabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from dictation meter settings",
        ),
      );
    } catch (e) {
      logger.d("Error loading dictation meter disabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<ListingDescriptionDictationMeterDisabledResponse>
      setListingDescriptionDictationMeterDisabled({
    required bool disabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/listing-description-dictation-meter-disabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchListingDescriptionDictationMeterDisabledRequest(
          disabled: disabled,
        ),
      );
      return ListingDescriptionDictationMeterDisabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from dictation meter settings",
        ),
      );
    } catch (e) {
      logger.d("Error updating dictation meter disabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<ListingGigModerationQueueResponse>
      getListingGigModerationQueueSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/listing-gig-moderation-queue",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return ListingGigModerationQueueResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from listing/gig moderation queue setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading listing/gig moderation queue setting: $e");
      rethrow;
    }
  }

  @override
  Future<ListingGigModerationQueueResponse>
      setListingGigModerationQueueEnabled({
    required bool enabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/listing-gig-moderation-queue",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchListingGigModerationQueueRequest(enabled: enabled),
      );
      return ListingGigModerationQueueResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from listing/gig moderation queue setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating listing/gig moderation queue setting: $e");
      rethrow;
    }
  }

  @override
  Future<PropertyNavEnabledResponse> getPropertyNavEnabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/property-nav-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return PropertyNavEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from property nav setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading property nav enabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<PropertyNavEnabledResponse> setPropertyNavEnabled({
    required bool enabled,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/property-nav-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchPropertyNavEnabledRequest(enabled: enabled),
      );
      return PropertyNavEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from property nav setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating property nav enabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<WebAppMultipleInstanceCheckEnabledResponse>
      getWebAppMultipleInstanceCheckEnabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/web-app-multiple-instance-check-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return WebAppMultipleInstanceCheckEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from web app multiple instance check setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading web app multiple instance check setting: $e");
      rethrow;
    }
  }

  @override
  Future<WebAppMultipleInstanceCheckEnabledResponse>
      setWebAppMultipleInstanceCheckEnabled({required bool enabled}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/web-app-multiple-instance-check-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchWebAppMultipleInstanceCheckEnabledRequest(
          enabled: enabled,
        ),
      );
      return WebAppMultipleInstanceCheckEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from web app multiple instance check setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating web app multiple instance check setting: $e");
      rethrow;
    }
  }

  @override
  Future<HomeStartViewResponse> getHomeStartViewSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/home-start-view",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return HomeStartViewResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from home start view setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading home start view setting: $e");
      rethrow;
    }
  }

  @override
  Future<HomeStartViewResponse> setHomeStartView({required String view}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/home-start-view",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchHomeStartViewRequest(view: view),
      );
      return HomeStartViewResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from home start view setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating home start view setting: $e");
      rethrow;
    }
  }

  @override
  Future<MapLayerDefaultsResponse> getMapLayerDefaultsSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/map-layer-defaults",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return MapLayerDefaultsResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from map layer defaults setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading map layer defaults setting: $e");
      rethrow;
    }
  }

  @override
  Future<MapLayerDefaultsResponse> setMapLayerDefaults({
    required bool districts,
    required bool metro,
    required bool universities,
  }) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/map-layer-defaults",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchMapLayerDefaultsRequest(
          districts: districts,
          metro: metro,
          universities: universities,
        ),
      );
      return MapLayerDefaultsResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from map layer defaults setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating map layer defaults setting: $e");
      rethrow;
    }
  }

  @override
  Future<AdminListingConversationsEnabledResponse>
      getAdminListingConversationsEnabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/admin-listing-conversations-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return AdminListingConversationsEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from admin listing conversations setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading admin listing conversations enabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<AdminListingConversationsEnabledResponse>
      setAdminListingConversationsEnabled({required bool enabled}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/admin-listing-conversations-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchAdminListingConversationsEnabledRequest(enabled: enabled),
      );
      return AdminListingConversationsEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from admin listing conversations setting",
        ),
      );
    } catch (e) {
      logger
          .d("Error updating admin listing conversations enabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramMessageBridgeEnabledResponse>
      getTelegramMessageBridgeEnabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/telegram-message-bridge-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return TelegramMessageBridgeEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from Telegram message bridge setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading Telegram message bridge setting: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramMessageBridgeEnabledResponse> setTelegramMessageBridgeEnabled(
      {required bool enabled}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/telegram-message-bridge-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchTelegramMessageBridgeEnabledRequest(enabled: enabled),
      );
      return TelegramMessageBridgeEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from Telegram message bridge setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating Telegram message bridge setting: $e");
      rethrow;
    }
  }

  @override
  Future<RoomScanGlbConversionEnabledResponse>
      getRoomScanGlbConversionEnabledSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/room-scan-glb-conversion-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return RoomScanGlbConversionEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from room scan GLB conversion setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading room scan GLB conversion enabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<RoomScanGlbConversionEnabledResponse>
      setRoomScanGlbConversionEnabled({required bool enabled}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/room-scan-glb-conversion-enabled",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchRoomScanGlbConversionEnabledRequest(enabled: enabled),
      );
      return RoomScanGlbConversionEnabledResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from room scan GLB conversion setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating room scan GLB conversion enabled setting: $e");
      rethrow;
    }
  }

  @override
  Future<GroupFormingMaxActiveMembershipsResponse>
      getGroupFormingMaxActiveMembershipsSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/group-forming-max-active-memberships",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return GroupFormingMaxActiveMembershipsResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from group forming membership limit setting",
        ),
      );
    } catch (e) {
      logger.d("Error loading group forming membership limit setting: $e");
      rethrow;
    }
  }

  @override
  Future<GroupFormingMaxActiveMembershipsResponse>
      setGroupFormingMaxActiveMemberships({required int limit}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/group-forming-max-active-memberships",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchGroupFormingMaxActiveMembershipsRequest(limit: limit),
      );
      return GroupFormingMaxActiveMembershipsResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from group forming membership limit setting",
        ),
      );
    } catch (e) {
      logger.d("Error updating group forming membership limit setting: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramMiniAppDailyListingLimitResponse>
      getTelegramMiniAppDailyListingLimitSetting() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/settings/telegram-miniapp-daily-listing-limit",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      return TelegramMiniAppDailyListingLimitResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from Telegram Mini App daily listing limit setting",
        ),
      );
    } catch (e) {
      logger.d(
        "Error loading Telegram Mini App daily listing limit setting: $e",
      );
      rethrow;
    }
  }

  @override
  Future<TelegramMiniAppDailyListingLimitResponse>
      setTelegramMiniAppDailyListingLimit({required int limit}) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, IJsonEncodable>(
        "/admin/settings/telegram-miniapp-daily-listing-limit",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _PatchTelegramMiniAppDailyListingLimitRequest(limit: limit),
      );
      return TelegramMiniAppDailyListingLimitResponse.fromJson(
        _requireJsonMap(
          response,
          "Unexpected response from Telegram Mini App daily listing limit setting",
        ),
      );
    } catch (e) {
      logger.d(
        "Error updating Telegram Mini App daily listing limit setting: $e",
      );
      rethrow;
    }
  }
}
