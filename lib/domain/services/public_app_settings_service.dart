import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

bool _readPublicSettingBool(Object? value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.trim().toLowerCase();
    return s == "true" || s == "1" || s == "yes";
  }
  return defaultValue;
}

class PublicAppSettingsSnapshot {
  const PublicAppSettingsSnapshot({
    required this.geminiListingUiHidden,
    required this.lidarRoomScanDisabled,
    required this.customCameraDisabled,
    required this.listingContactsVisible,
    required this.listingDescriptionDictationMeterDisabled,
    required this.phoneSignInEnabled,
    required this.googleSignInEnabled,
    required this.appleSignInEnabled,
    required this.telegramSignInEnabled,
    required this.propertyNavEnabled,
    required this.homeStartView,
    required this.mapDefaultShowDistricts,
    required this.mapDefaultShowMetro,
    required this.mapDefaultShowUniversities,
    required this.webAppMultipleInstanceCheckEnabled,
  });

  factory PublicAppSettingsSnapshot.fromJson(Map<String, dynamic> json) {
    return PublicAppSettingsSnapshot(
      geminiListingUiHidden:
          _readPublicSettingBool(json["geminiListingUiHidden"]),
      lidarRoomScanDisabled:
          _readPublicSettingBool(json["lidarRoomScanDisabled"]),
      customCameraDisabled:
          _readPublicSettingBool(json["customCameraDisabled"]),
      listingContactsVisible:
          _readPublicSettingBool(json["listingContactsVisible"]),
      listingDescriptionDictationMeterDisabled: _readPublicSettingBool(
          json["listingDescriptionDictationMeterDisabled"]),
      phoneSignInEnabled: _readPublicSettingBool(json["phoneSignInEnabled"]),
      googleSignInEnabled: _readPublicSettingBool(
        json["googleSignInEnabled"],
        defaultValue: true,
      ),
      appleSignInEnabled: _readPublicSettingBool(
        json["appleSignInEnabled"],
        defaultValue: true,
      ),
      telegramSignInEnabled: _readPublicSettingBool(
        json["telegramSignInEnabled"],
        defaultValue: true,
      ),
      propertyNavEnabled: _readPublicSettingBool(
        json["propertyNavEnabled"],
        defaultValue: true,
      ),
      homeStartView: _readHomeStartView(json["homeStartView"]),
      mapDefaultShowDistricts: _readPublicSettingBool(
          json["mapDefaultShowDistricts"],
          defaultValue: true),
      mapDefaultShowMetro: _readPublicSettingBool(json["mapDefaultShowMetro"],
          defaultValue: true),
      mapDefaultShowUniversities:
          _readPublicSettingBool(json["mapDefaultShowUniversities"]),
      webAppMultipleInstanceCheckEnabled: _readPublicSettingBool(
        json["webAppMultipleInstanceCheckEnabled"],
      ),
    );
  }

  final bool geminiListingUiHidden;
  final bool lidarRoomScanDisabled;
  final bool customCameraDisabled;
  final bool listingContactsVisible;
  final bool listingDescriptionDictationMeterDisabled;
  final bool phoneSignInEnabled;
  final bool googleSignInEnabled;
  final bool appleSignInEnabled;
  final bool telegramSignInEnabled;
  final bool propertyNavEnabled;
  final String homeStartView;
  final bool mapDefaultShowDistricts;
  final bool mapDefaultShowMetro;
  final bool mapDefaultShowUniversities;

  /// When true, the web client locks every browser tab except the most
  /// recently opened one for this origin. Default false.
  final bool webAppMultipleInstanceCheckEnabled;
}

String _readHomeStartView(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == "feed" ? "feed" : "map";
}

abstract class IPublicAppSettingsService {
  /// Single bulk fetch used at cold start; dedupes concurrent callers.
  Future<void> prefetch();

  Future<bool> getGeminiListingUiHidden();

  Future<bool> getLidarRoomScanDisabled();

  Future<bool> getCustomCameraDisabled();

  Future<bool> getListingContactsVisible();

  Future<bool> getListingDescriptionDictationMeterDisabled();

  Future<bool> getPhoneSignInEnabled();

  Future<bool> getGoogleSignInEnabled();

  Future<bool> getAppleSignInEnabled();

  Future<bool> getTelegramSignInEnabled();

  Future<bool> getPropertyNavEnabled();

  Future<String> getHomeStartView();

  Future<MapLayerDefaultsSnapshot> getMapLayerDefaults();

  Future<bool> getWebAppMultipleInstanceCheckEnabled();
}

class MapLayerDefaultsSnapshot {
  const MapLayerDefaultsSnapshot({
    required this.districts,
    required this.metro,
    required this.universities,
  });

  final bool districts;
  final bool metro;
  final bool universities;
}

class PublicAppSettingsService implements IPublicAppSettingsService {
  PublicAppSettingsService(this._apiClient);

  final IPublicApiClient _apiClient;

  PublicAppSettingsSnapshot? _cached;
  Future<void>? _loading;

  Future<void> _ensureLoaded() async {
    if (_cached != null) return;
    _loading ??= _fetchAll();
    await _loading;
  }

  Future<void> _fetchAll() async {
    try {
      final response = await _apiClient.get<dynamic>(
        "/app/settings",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is Map) {
        _cached = PublicAppSettingsSnapshot.fromJson(
          Map<String, dynamic>.from(response),
        );
        return;
      }
      _cached = const PublicAppSettingsSnapshot(
        geminiListingUiHidden: false,
        lidarRoomScanDisabled: false,
        customCameraDisabled: false,
        listingContactsVisible: false,
        listingDescriptionDictationMeterDisabled: false,
        phoneSignInEnabled: false,
        googleSignInEnabled: true,
        appleSignInEnabled: true,
        telegramSignInEnabled: true,
        propertyNavEnabled: true,
        homeStartView: "map",
        mapDefaultShowDistricts: true,
        mapDefaultShowMetro: true,
        mapDefaultShowUniversities: false,
        webAppMultipleInstanceCheckEnabled: false,
      );
    } catch (e) {
      logger.d("PublicAppSettingsService._fetchAll: $e");
      rethrow;
    }
  }

  @override
  Future<void> prefetch() => _ensureLoaded();

  @override
  Future<bool> getGeminiListingUiHidden() async {
    await _ensureLoaded();
    return _cached?.geminiListingUiHidden ?? false;
  }

  @override
  Future<bool> getLidarRoomScanDisabled() async {
    await _ensureLoaded();
    return _cached?.lidarRoomScanDisabled ?? false;
  }

  @override
  Future<bool> getCustomCameraDisabled() async {
    await _ensureLoaded();
    return _cached?.customCameraDisabled ?? false;
  }

  @override
  Future<bool> getListingContactsVisible() async {
    await _ensureLoaded();
    return _cached?.listingContactsVisible ?? false;
  }

  @override
  Future<bool> getListingDescriptionDictationMeterDisabled() async {
    await _ensureLoaded();
    return _cached?.listingDescriptionDictationMeterDisabled ?? false;
  }

  @override
  Future<bool> getPhoneSignInEnabled() async {
    await _ensureLoaded();
    return _cached?.phoneSignInEnabled ?? false;
  }

  @override
  Future<bool> getGoogleSignInEnabled() async {
    await _ensureLoaded();
    return _cached?.googleSignInEnabled ?? true;
  }

  @override
  Future<bool> getAppleSignInEnabled() async {
    await _ensureLoaded();
    return _cached?.appleSignInEnabled ?? true;
  }

  @override
  Future<bool> getTelegramSignInEnabled() async {
    await _ensureLoaded();
    return _cached?.telegramSignInEnabled ?? true;
  }

  @override
  Future<bool> getPropertyNavEnabled() async {
    await _ensureLoaded();
    return _cached?.propertyNavEnabled ?? true;
  }

  @override
  Future<String> getHomeStartView() async {
    await _ensureLoaded();
    return _cached?.homeStartView ?? "map";
  }

  @override
  Future<MapLayerDefaultsSnapshot> getMapLayerDefaults() async {
    await _ensureLoaded();
    final cached = _cached;
    return MapLayerDefaultsSnapshot(
      districts: cached?.mapDefaultShowDistricts ?? true,
      metro: cached?.mapDefaultShowMetro ?? true,
      universities: cached?.mapDefaultShowUniversities ?? false,
    );
  }

  @override
  Future<bool> getWebAppMultipleInstanceCheckEnabled() async {
    await _ensureLoaded();
    return _cached?.webAppMultipleInstanceCheckEnabled ?? false;
  }
}
