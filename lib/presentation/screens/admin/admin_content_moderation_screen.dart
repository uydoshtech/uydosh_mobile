import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_admin_listing_conversations_config.dart";
import "package:uy_dosh/base/config/client_custom_camera_config.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/config/client_home_start_view_config.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/config/client_listing_contacts_config.dart";
import "package:uy_dosh/base/config/client_listing_dictation_meter_config.dart";
import "package:uy_dosh/base/config/client_map_layer_defaults_config.dart";
import "package:uy_dosh/base/config/client_property_feature_config.dart";
import "package:uy_dosh/base/config/client_web_app_multiple_instance_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/admin_feature_flags_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_content_moderation_settings_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

const _kSettingsCategoryExpandDuration = Duration(milliseconds: 200);

class AdminContentModerationScreen extends StatefulWidget {
  const AdminContentModerationScreen({super.key});

  @override
  State<AdminContentModerationScreen> createState() =>
      _AdminContentModerationScreenState();
}

class _AdminContentModerationScreenState
    extends State<AdminContentModerationScreen> {
  final IAdminContentModerationSettingsService _settingsService =
      getIt<IAdminContentModerationSettingsService>();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _blurEnabled = true;
  bool _geminiListingUiEnabled = true;
  bool _isSavingGemini = false;
  bool _lidarRoomScanEnabled = true;
  bool _isSavingLidar = false;
  bool _customCameraEnabled = true;
  bool _isSavingCustomCamera = false;
  bool _dictationMeterEnabled = true;
  bool _isSavingDictationMeter = false;
  bool _listingContactsVisible = false;
  bool _isSavingListingContacts = false;
  bool _listingGigModerationQueueEnabled = true;
  bool _isSavingModerationQueue = false;
  bool _propertyNavEnabled = true;
  bool _isSavingPropertyNav = false;
  bool _webAppMultipleInstanceCheckEnabled = false;
  bool _isSavingWebAppMultipleInstanceCheck = false;
  bool _homeStartsWithMap = true;
  bool _isSavingHomeStartView = false;
  bool _mapDefaultShowDistricts = true;
  bool _mapDefaultShowMetro = true;
  bool _mapDefaultShowUniversities = false;
  bool _isSavingMapLayerDefaults = false;
  bool _adminListingConversationsEnabled = false;
  bool _isSavingAdminListingConversations = false;
  bool _telegramMessageBridgeEnabled = true;
  bool _isSavingTelegramMessageBridge = false;
  bool _roomScanGlbConversionEnabled = true;
  bool _isSavingRoomScanGlbConversion = false;
  int _groupFormingMaxActiveMemberships = 2;
  bool _isSavingGroupFormingLimit = false;
  int _telegramMiniAppDailyListingLimit = 0;
  bool _isSavingTelegramMiniAppDailyListingLimit = false;
  bool _isSavingPriceInsights = false;
  bool _isSavingPushDebug = false;
  bool _isSavingListingMoveToTop = false;
  bool _isSavingTooltips = false;
  final Set<_SettingsCategory> _expandedCategories = {
    _SettingsCategory.appExperience,
  };

  @override
  void initState() {
    super.initState();
    _load();
    AdminFeatureFlagsState().ensureLoaded();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final bulk = await _settingsService.getAdminSettingsBulk();
      _applyLoadedSettings(
        blurEnabled: bulk.contentModerationBlurEnabled,
        geminiHidden: bulk.geminiListingUiHidden,
        lidarDisabled: bulk.lidarRoomScanDisabled,
        cameraDisabled: bulk.customCameraDisabled,
        dictationMeterDisabled: bulk.listingDescriptionDictationMeterDisabled,
        contactsVisible: bulk.listingContactsVisible,
        listingGigModQueueEnabled: bulk.listingGigModerationQueueEnabled,
        propertyNavEnabled: bulk.propertyNavEnabled,
        webAppMultipleInstanceCheckEnabled:
            bulk.webAppMultipleInstanceCheckEnabled,
        homeStartsWithMap:
            bulk.homeStartView == ClientHomeStartViewConfig.mapView,
        mapDefaultShowDistricts: bulk.mapDefaultShowDistricts,
        mapDefaultShowMetro: bulk.mapDefaultShowMetro,
        mapDefaultShowUniversities: bulk.mapDefaultShowUniversities,
        adminListingConversationsEnabled:
            bulk.adminListingConversationsEnabled,
        telegramMessageBridgeEnabled: bulk.telegramMessageBridgeEnabled,
        roomScanGlbConversionEnabled: bulk.roomScanGlbConversionEnabled,
        groupFormingMaxActiveMemberships:
            bulk.groupFormingMaxActiveMemberships,
        telegramMiniAppDailyListingLimit:
            bulk.telegramMiniAppDailyListingLimit,
      );
      return;
    } catch (e) {
      logger.d(
        "Bulk admin settings load failed, falling back to per-setting requests: $e",
      );
    }
    await _loadIndividually();
  }

  /// Fallback for a client build newer than the deployed backend (no
  /// `/admin/settings/bulk` route yet): fetches each setting one at a time.
  Future<void> _loadIndividually() async {
    try {
      final blurRes = await _settingsService.getContentModerationBlurSetting();
      final geminiRes =
          await _settingsService.getGeminiListingUiHiddenSetting();
      final lidarRes = await _settingsService.getLidarRoomScanDisabledSetting();
      final cameraRes = await _settingsService.getCustomCameraDisabledSetting();
      final dictationMeterRes = await _settingsService
          .getListingDescriptionDictationMeterDisabledSetting();
      final contactsRes =
          await _settingsService.getListingContactsVisibleSetting();
      var listingGigModQueueEnabled = true;
      try {
        final modQueueRes =
            await _settingsService.getListingGigModerationQueueSetting();
        listingGigModQueueEnabled = modQueueRes.enabled;
      } catch (e) {
        logger.d(
          "Listing/gig moderation queue setting skipped (is the API updated?): $e",
        );
      }
      var propertyNavEnabled = true;
      try {
        final propertyNavRes =
            await _settingsService.getPropertyNavEnabledSetting();
        propertyNavEnabled = propertyNavRes.enabled;
      } catch (e) {
        logger.d(
          "Property nav enabled setting skipped (is the API updated?): $e",
        );
      }
      var webAppMultipleInstanceCheckEnabled = false;
      try {
        final webAppMultipleInstanceCheckRes = await _settingsService
            .getWebAppMultipleInstanceCheckEnabledSetting();
        webAppMultipleInstanceCheckEnabled =
            webAppMultipleInstanceCheckRes.enabled;
      } catch (e) {
        logger.d(
          "Web app multiple instance check setting skipped (is the API updated?): $e",
        );
      }
      var homeStartsWithMap = true;
      try {
        final homeStartViewRes =
            await _settingsService.getHomeStartViewSetting();
        homeStartsWithMap =
            homeStartViewRes.view == ClientHomeStartViewConfig.mapView;
      } catch (e) {
        logger.d(
          "Home start view setting skipped (is the API updated?): $e",
        );
      }
      var mapDefaultShowDistricts = true;
      var mapDefaultShowMetro = true;
      var mapDefaultShowUniversities = false;
      try {
        final mapLayerDefaultsRes =
            await _settingsService.getMapLayerDefaultsSetting();
        mapDefaultShowDistricts = mapLayerDefaultsRes.districts;
        mapDefaultShowMetro = mapLayerDefaultsRes.metro;
        mapDefaultShowUniversities = mapLayerDefaultsRes.universities;
      } catch (e) {
        logger.d(
          "Map layer defaults setting skipped (is the API updated?): $e",
        );
      }
      var adminListingConversationsEnabled = false;
      try {
        final adminListingChatsRes =
            await _settingsService.getAdminListingConversationsEnabledSetting();
        adminListingConversationsEnabled = adminListingChatsRes.enabled;
      } catch (e) {
        logger.d(
          "Admin listing conversations setting skipped (is the API updated?): $e",
        );
      }
      var telegramMessageBridgeEnabled = true;
      try {
        final telegramBridgeRes =
            await _settingsService.getTelegramMessageBridgeEnabledSetting();
        telegramMessageBridgeEnabled = telegramBridgeRes.enabled;
      } catch (e) {
        logger.d(
          "Telegram message bridge setting skipped (is the API updated?): $e",
        );
      }
      var roomScanGlbConversionEnabled = true;
      try {
        final roomScanGlbRes =
            await _settingsService.getRoomScanGlbConversionEnabledSetting();
        roomScanGlbConversionEnabled = roomScanGlbRes.enabled;
      } catch (e) {
        logger.d(
          "Room scan GLB conversion setting skipped (is the API updated?): $e",
        );
      }
      var groupFormingMaxActiveMemberships = 2;
      try {
        final groupLimitRes =
            await _settingsService.getGroupFormingMaxActiveMembershipsSetting();
        groupFormingMaxActiveMemberships = groupLimitRes.limit;
      } catch (e) {
        logger.d(
          "Group forming membership limit setting skipped (is the API updated?): $e",
        );
      }
      var telegramMiniAppDailyListingLimit = 0;
      try {
        final dailyListingLimitRes = await _settingsService
            .getTelegramMiniAppDailyListingLimitSetting();
        telegramMiniAppDailyListingLimit = dailyListingLimitRes.limit;
      } catch (e) {
        logger.d(
          "Telegram Mini App daily listing limit setting skipped (is the API updated?): $e",
        );
      }
      _applyLoadedSettings(
        blurEnabled: blurRes.enabled,
        geminiHidden: geminiRes.hidden,
        lidarDisabled: lidarRes.disabled,
        cameraDisabled: cameraRes.disabled,
        dictationMeterDisabled: dictationMeterRes.disabled,
        contactsVisible: contactsRes.visible,
        listingGigModQueueEnabled: listingGigModQueueEnabled,
        propertyNavEnabled: propertyNavEnabled,
        webAppMultipleInstanceCheckEnabled: webAppMultipleInstanceCheckEnabled,
        homeStartsWithMap: homeStartsWithMap,
        mapDefaultShowDistricts: mapDefaultShowDistricts,
        mapDefaultShowMetro: mapDefaultShowMetro,
        mapDefaultShowUniversities: mapDefaultShowUniversities,
        adminListingConversationsEnabled: adminListingConversationsEnabled,
        telegramMessageBridgeEnabled: telegramMessageBridgeEnabled,
        roomScanGlbConversionEnabled: roomScanGlbConversionEnabled,
        groupFormingMaxActiveMemberships: groupFormingMaxActiveMemberships,
        telegramMiniAppDailyListingLimit: telegramMiniAppDailyListingLimit,
      );
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyLoadedSettings({
    required bool blurEnabled,
    required bool geminiHidden,
    required bool lidarDisabled,
    required bool cameraDisabled,
    required bool dictationMeterDisabled,
    required bool contactsVisible,
    required bool listingGigModQueueEnabled,
    required bool propertyNavEnabled,
    required bool webAppMultipleInstanceCheckEnabled,
    required bool homeStartsWithMap,
    required bool mapDefaultShowDistricts,
    required bool mapDefaultShowMetro,
    required bool mapDefaultShowUniversities,
    required bool adminListingConversationsEnabled,
    required bool telegramMessageBridgeEnabled,
    required bool roomScanGlbConversionEnabled,
    required int groupFormingMaxActiveMemberships,
    required int telegramMiniAppDailyListingLimit,
  }) {
    setStateIfMounted(() {
      _blurEnabled = blurEnabled;
      // UI is positive: ON means enabled/shown.
      _geminiListingUiEnabled = !geminiHidden;
      _lidarRoomScanEnabled = !lidarDisabled;
      _customCameraEnabled = !cameraDisabled;
      _dictationMeterEnabled = !dictationMeterDisabled;
      _listingContactsVisible = contactsVisible;
      _listingGigModerationQueueEnabled = listingGigModQueueEnabled;
      _propertyNavEnabled = propertyNavEnabled;
      _webAppMultipleInstanceCheckEnabled = webAppMultipleInstanceCheckEnabled;
      _homeStartsWithMap = homeStartsWithMap;
      _mapDefaultShowDistricts = mapDefaultShowDistricts;
      _mapDefaultShowMetro = mapDefaultShowMetro;
      _mapDefaultShowUniversities = mapDefaultShowUniversities;
      _adminListingConversationsEnabled = adminListingConversationsEnabled;
      _telegramMessageBridgeEnabled = telegramMessageBridgeEnabled;
      _roomScanGlbConversionEnabled = roomScanGlbConversionEnabled;
      _groupFormingMaxActiveMemberships = groupFormingMaxActiveMemberships;
      _telegramMiniAppDailyListingLimit = telegramMiniAppDailyListingLimit;
      _isLoading = false;
    });
    ClientGeminiListingUiConfig.applyHidden(hidden: !_geminiListingUiEnabled);
    ClientLidarRoomScanConfig.applyDisabled(disabled: !_lidarRoomScanEnabled);
    ClientCustomCameraConfig.applyDisabled(disabled: !_customCameraEnabled);
    ClientListingDictationMeterConfig.applyDisabled(
      disabled: !_dictationMeterEnabled,
    );
    ClientListingContactsConfig.applyVisible(
      visible: _listingContactsVisible,
    );
    ClientPropertyFeatureConfig.applyEnabled(enabled: propertyNavEnabled);
    ClientWebAppMultipleInstanceConfig.applyEnabled(
      value: webAppMultipleInstanceCheckEnabled,
    );
    ClientHomeStartViewConfig.applyView(
      homeStartsWithMap
          ? ClientHomeStartViewConfig.mapView
          : ClientHomeStartViewConfig.feedView,
    );
    ClientMapLayerDefaultsConfig.apply(
      districts: mapDefaultShowDistricts,
      metro: mapDefaultShowMetro,
      universities: mapDefaultShowUniversities,
    );
    ClientAdminListingConversationsConfig.applyEnabled(
      value: adminListingConversationsEnabled,
    );
  }

  Future<void> _onLidarEnabledChanged(bool value) async {
    if (_isSavingLidar) return;
    setState(() => _isSavingLidar = true);
    try {
      final res = await _settingsService.setLidarRoomScanDisabled(
        // Server stores "disabled", UI is "enabled".
        disabled: !value,
      );
      setStateIfMounted(() {
        _lidarRoomScanEnabled = !res.disabled;
        _isSavingLidar = false;
      });
      ClientLidarRoomScanConfig.applyDisabled(disabled: res.disabled);
    } catch (e) {
      setStateIfMounted(() => _isSavingLidar = false);
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    }
  }

  Future<void> _onRoomScanGlbConversionEnabledChanged(bool value) async {
    if (_isSavingRoomScanGlbConversion) return;
    setState(() => _isSavingRoomScanGlbConversion = true);
    try {
      final res = await _settingsService.setRoomScanGlbConversionEnabled(
        enabled: value,
      );
      setStateIfMounted(() {
        _roomScanGlbConversionEnabled = res.enabled;
        _isSavingRoomScanGlbConversion = false;
      });
    } catch (e) {
      setStateIfMounted(() => _isSavingRoomScanGlbConversion = false);
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    }
  }

  Future<void> _onCustomCameraEnabledChanged(bool value) async {
    if (_isSavingCustomCamera) return;
    setState(() => _isSavingCustomCamera = true);
    try {
      final res = await _settingsService.setCustomCameraDisabled(
        // Server stores "disabled", UI is "enabled".
        disabled: !value,
      );
      setStateIfMounted(() {
        _customCameraEnabled = !res.disabled;
        _isSavingCustomCamera = false;
      });
      ClientCustomCameraConfig.applyDisabled(disabled: res.disabled);
    } catch (e) {
      setStateIfMounted(() => _isSavingCustomCamera = false);
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    }
  }

  Future<void> _onDictationMeterEnabledChanged(bool value) async {
    if (_isSavingDictationMeter) return;
    setState(() => _isSavingDictationMeter = true);
    try {
      final res =
          await _settingsService.setListingDescriptionDictationMeterDisabled(
        disabled: !value,
      );
      setStateIfMounted(() {
        _dictationMeterEnabled = !res.disabled;
        _isSavingDictationMeter = false;
      });
      ClientListingDictationMeterConfig.applyDisabled(disabled: res.disabled);
    } catch (e) {
      setStateIfMounted(() => _isSavingDictationMeter = false);
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    }
  }

  Future<void> _onGeminiEnabledChanged(bool value) async {
    if (_isSavingGemini) return;
    setState(() => _isSavingGemini = true);
    try {
      // Server stores "hidden", UI is "enabled".
      final res = await _settingsService.setGeminiListingUiHidden(
        hidden: !value,
      );
      setStateIfMounted(() {
        _geminiListingUiEnabled = !res.hidden;
        _isSavingGemini = false;
      });
      ClientGeminiListingUiConfig.applyHidden(hidden: res.hidden);
    } catch (e) {
      setStateIfMounted(() => _isSavingGemini = false);
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final res = await _settingsService.setContentModerationBlurEnabled(
        enabled: value,
      );
      setStateIfMounted(() {
        _blurEnabled = res.enabled;
        _isSaving = false;
      });
    } catch (e) {
      setStateIfMounted(() => _isSaving = false);
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    }
  }

  Future<void> _onShowListingContactsChanged(bool value) async {
    if (_isSavingListingContacts) return;
    setState(() => _isSavingListingContacts = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setListingContactsVisible(
        visible: value,
      );
      setStateIfMounted(() {
        _listingContactsVisible = res.visible;
      });
      ClientListingContactsConfig.applyVisible(visible: res.visible);
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingListingContacts = false);
    }
  }

  Future<void> _onListingGigModerationQueueChanged(bool value) async {
    if (_isSavingModerationQueue) return;
    setState(() => _isSavingModerationQueue = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setListingGigModerationQueueEnabled(
        enabled: value,
      );
      setStateIfMounted(() {
        _listingGigModerationQueueEnabled = res.enabled;
      });
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingModerationQueue = false);
    }
  }

  Future<void> _onPropertyNavEnabledChanged(bool value) async {
    if (_isSavingPropertyNav) return;
    setState(() => _isSavingPropertyNav = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setPropertyNavEnabled(enabled: value);
      setStateIfMounted(() {
        _propertyNavEnabled = res.enabled;
      });
      ClientPropertyFeatureConfig.applyEnabled(enabled: res.enabled);
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingPropertyNav = false);
    }
  }

  Future<void> _onWebAppMultipleInstanceCheckChanged(bool value) async {
    if (_isSavingWebAppMultipleInstanceCheck) return;
    setState(() => _isSavingWebAppMultipleInstanceCheck = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setWebAppMultipleInstanceCheckEnabled(
        enabled: value,
      );
      setStateIfMounted(() {
        _webAppMultipleInstanceCheckEnabled = res.enabled;
      });
      ClientWebAppMultipleInstanceConfig.applyEnabled(value: res.enabled);
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingWebAppMultipleInstanceCheck = false);
    }
  }

  Future<void> _onHomeStartsWithMapChanged(bool value) async {
    if (_isSavingHomeStartView) return;
    setState(() => _isSavingHomeStartView = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setHomeStartView(
        view: value
            ? ClientHomeStartViewConfig.mapView
            : ClientHomeStartViewConfig.feedView,
      );
      setStateIfMounted(() {
        _homeStartsWithMap = res.view == ClientHomeStartViewConfig.mapView;
      });
      ClientHomeStartViewConfig.applyView(res.view);
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingHomeStartView = false);
    }
  }

  Future<void> _setMapLayerDefaults({
    bool? districts,
    bool? metro,
    bool? universities,
  }) async {
    if (_isSavingMapLayerDefaults) return;
    final nextDistricts = districts ?? _mapDefaultShowDistricts;
    final nextMetro = metro ?? _mapDefaultShowMetro;
    final nextUniversities = universities ?? _mapDefaultShowUniversities;
    setState(() => _isSavingMapLayerDefaults = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setMapLayerDefaults(
        districts: nextDistricts,
        metro: nextMetro,
        universities: nextUniversities,
      );
      setStateIfMounted(() {
        _mapDefaultShowDistricts = res.districts;
        _mapDefaultShowMetro = res.metro;
        _mapDefaultShowUniversities = res.universities;
      });
      ClientMapLayerDefaultsConfig.apply(
        districts: res.districts,
        metro: res.metro,
        universities: res.universities,
      );
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingMapLayerDefaults = false);
    }
  }

  Future<void> _onAdminListingConversationsEnabledChanged(bool value) async {
    if (_isSavingAdminListingConversations) return;
    setState(() => _isSavingAdminListingConversations = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setAdminListingConversationsEnabled(
        enabled: value,
      );
      setStateIfMounted(() {
        _adminListingConversationsEnabled = res.enabled;
      });
      ClientAdminListingConversationsConfig.applyEnabled(value: res.enabled);
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingAdminListingConversations = false);
    }
  }

  Future<void> _onTelegramMessageBridgeEnabledChanged(bool value) async {
    if (_isSavingTelegramMessageBridge) return;
    setState(() => _isSavingTelegramMessageBridge = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setTelegramMessageBridgeEnabled(
          enabled: value);
      setStateIfMounted(() {
        _telegramMessageBridgeEnabled = res.enabled;
      });
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingTelegramMessageBridge = false);
    }
  }

  Future<void> _setGroupFormingLimit(int value) async {
    if (_isSavingGroupFormingLimit) return;
    final next = value < 1 ? 1 : (value > 10 ? 10 : value);
    if (next == _groupFormingMaxActiveMemberships) return;
    setState(() => _isSavingGroupFormingLimit = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setGroupFormingMaxActiveMemberships(
        limit: next,
      );
      setStateIfMounted(() {
        _groupFormingMaxActiveMemberships = res.limit;
      });
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingGroupFormingLimit = false);
    }
  }

  /// `value == 0` disables the daily cap entirely (unlimited listings).
  Future<void> _setTelegramMiniAppDailyListingLimit(int value) async {
    if (_isSavingTelegramMiniAppDailyListingLimit) return;
    final next = value < 0 ? 0 : (value > 100 ? 100 : value);
    if (next == _telegramMiniAppDailyListingLimit) return;
    setState(() => _isSavingTelegramMiniAppDailyListingLimit = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setTelegramMiniAppDailyListingLimit(
        limit: next,
      );
      setStateIfMounted(() {
        _telegramMiniAppDailyListingLimit = res.limit;
      });
    } catch (e) {
      ToastTheme.showErrorSimple(
        context,
        message: "${L10n.get("admin_content_moderation_save_error")}: $e",
      );
    } finally {
      setStateIfMounted(() => _isSavingTelegramMiniAppDailyListingLimit = false);
    }
  }

  Future<void> _onShowPriceInsightsChanged(bool value) async {
    if (_isSavingPriceInsights) return;
    setState(() => _isSavingPriceInsights = true);
    try {
      HapticFeedbackUtils.impact();
      await AdminFeatureFlagsState().setShowPriceInsights(value);
    } finally {
      setStateIfMounted(() => _isSavingPriceInsights = false);
    }
  }

  Future<void> _onShowPushDebugChanged(bool value) async {
    if (_isSavingPushDebug) return;
    setState(() => _isSavingPushDebug = true);
    try {
      HapticFeedbackUtils.impact();
      await AdminFeatureFlagsState().setShowPushDebug(value);
    } finally {
      setStateIfMounted(() => _isSavingPushDebug = false);
    }
  }

  Future<void> _onShowListingMoveToTopChanged(bool value) async {
    if (_isSavingListingMoveToTop) return;
    setState(() => _isSavingListingMoveToTop = true);
    try {
      HapticFeedbackUtils.impact();
      await AdminFeatureFlagsState().setShowListingMoveToTop(value);
    } finally {
      setStateIfMounted(() => _isSavingListingMoveToTop = false);
    }
  }

  Future<void> _onTooltipsEnabledChanged(bool value) async {
    if (_isSavingTooltips) return;
    setState(() => _isSavingTooltips = true);
    try {
      HapticFeedbackUtils.impact();
      if (value) {
        await TooltipsState().enableAndResetAll();
      } else {
        await TooltipsState().setEnabled(false);
      }
    } finally {
      setStateIfMounted(() => _isSavingTooltips = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_content_moderation_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildBody(context),
      ),
    );
  }

  void _toggleSettingsCategory(_SettingsCategory category) {
    HapticFeedbackUtils.selectionClick();
    setState(() {
      if (!_expandedCategories.remove(category)) {
        _expandedCategories.add(category);
      }
    });
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HouseLoadingIndicator(),
            const SizedBox(height: 16),
            Text(L10n.get("admin_content_moderation_loading")),
          ],
        ),
      );
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              L10n.get("admin_content_moderation_error"),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButtonFactory.text(
              onPressed: _load,
              text: L10n.get("admin_search_analytics_retry"),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ],
        ),
      );
    }
    return ListView(
      children: [
        const SizedBox(height: 4),
        _settingsCategoryCard(
          category: _SettingsCategory.appExperience,
          icon: Icons.tune_outlined,
          titleKey: "admin_settings_category_app_experience",
          children: [
            ListenableBuilder(
              listenable: TooltipsState(),
              builder: (context, _) => _tooltipsTile(context),
            ),
            _homeStartViewTile(context),
            _propertyNavTile(context),
            _webAppMultipleInstanceCheckTile(context),
          ],
        ),
        const SizedBox(height: 16),
        _settingsCategoryCard(
          category: _SettingsCategory.maps,
          icon: Icons.map_outlined,
          titleKey: "admin_settings_category_maps",
          children: [
            _mapLayerDefaultTile(
              context,
              icon: Icons.layers_rounded,
              titleKey: "admin_map_layer_default_districts_title",
              subtitleKey: "admin_map_layer_default_districts_subtitle",
              value: _mapDefaultShowDistricts,
              onChanged: (value) => _setMapLayerDefaults(districts: value),
            ),
            _mapLayerDefaultTile(
              context,
              icon: Icons.directions_subway_rounded,
              titleKey: "admin_map_layer_default_metro_title",
              subtitleKey: "admin_map_layer_default_metro_subtitle",
              value: _mapDefaultShowMetro,
              onChanged: (value) => _setMapLayerDefaults(metro: value),
            ),
            _mapLayerDefaultTile(
              context,
              icon: Icons.school_rounded,
              titleKey: "admin_map_layer_default_universities_title",
              subtitleKey: "admin_map_layer_default_universities_subtitle",
              value: _mapDefaultShowUniversities,
              onChanged: (value) => _setMapLayerDefaults(universities: value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _settingsCategoryCard(
          category: _SettingsCategory.listings,
          icon: Icons.home_work_outlined,
          titleKey: "admin_settings_category_listings",
          children: [
            _listingContactsTile(context),
            _groupFormingLimitTile(context),
            _telegramMiniAppDailyListingLimitTile(context),
            _geminiTile(context),
            _lidarTile(context),
            _roomScanGlbConversionTile(context),
            _customCameraTile(context),
            _dictationMeterTile(context),
          ],
        ),
        const SizedBox(height: 16),
        _settingsCategoryCard(
          category: _SettingsCategory.moderation,
          icon: Icons.verified_user_outlined,
          titleKey: "admin_settings_category_moderation",
          children: [
            _moderationQueueTile(context),
            _contentModerationBlurTile(context),
          ],
        ),
        const SizedBox(height: 16),
        _settingsCategoryCard(
          category: _SettingsCategory.telegram,
          icon: Icons.send_outlined,
          titleKey: "admin_settings_category_telegram",
          children: [
            _telegramMessageBridgeTile(context),
          ],
        ),
        const SizedBox(height: 16),
        _settingsCategoryCard(
          category: _SettingsCategory.adminTools,
          icon: Icons.admin_panel_settings_outlined,
          titleKey: "admin_settings_category_admin_tools",
          children: [
            _adminListingConversationsTile(context),
            ListenableBuilder(
              listenable: AdminFeatureFlagsState(),
              builder: (context, _) => _priceInsightsTile(context),
            ),
            ListenableBuilder(
              listenable: AdminFeatureFlagsState(),
              builder: (context, _) => _listingMoveToTopTile(context),
            ),
            ListenableBuilder(
              listenable: AdminFeatureFlagsState(),
              builder: (context, _) => _pushDebugTile(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _settingsCategoryCard({
    required _SettingsCategory category,
    required IconData icon,
    required String titleKey,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final accent = category.accent(context);
    final expanded = _expandedCategories.contains(category);
    final dividerColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25);

    return ListingDetailTileShell(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _toggleSettingsCategory(category),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    accent.withValues(alpha: expanded ? 0.14 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        color: accent.withValues(alpha: 0.18),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.36),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: ThemeIcon(icon, size: 22, color: accent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        L10n.get(titleKey),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: _kSettingsCategoryExpandDuration,
                      child: ThemeIcon(
                        Icons.keyboard_arrow_down,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: _kSettingsCategoryExpandDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        for (var i = 0; i < children.length; i++) ...[
                          children[i],
                          if (i < children.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 52,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                        ],
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _savingLeading(IconData icon, bool isSaving) {
    return isSaving
        ? UydoshInlineSpinner(
            color: Theme.of(context).colorScheme.onSurface,
            dimension: 24,
          )
        : ThemeIcon(icon);
  }

  TextStyle _subtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  Widget _tooltipsTile(BuildContext context) {
    return ListTile(
      leading: _isSavingTooltips
          ? const Padding(
              padding: EdgeInsets.all(2),
              child: UydoshInlineSpinner(
                color: Colors.white,
                dimension: 24,
                strokeWidth: 2,
              ),
            )
          : const ThemeIcon(Icons.tips_and_updates_outlined),
      title: Text(L10n.get("tooltips_toggle")),
      subtitle: Text(
        L10n.get("tooltips_toggle_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: TooltipsState().enabled,
        enabled: !_isSavingTooltips,
        onChanged: _onTooltipsEnabledChanged,
      ),
    );
  }

  Widget _homeStartViewTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.map_outlined, _isSavingHomeStartView),
      title: Text(L10n.get("admin_app_setting_home_start_map_title")),
      subtitle: Text(
        L10n.get("admin_app_setting_home_start_map_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _homeStartsWithMap,
        enabled: !_isSavingHomeStartView,
        onChanged: _onHomeStartsWithMapChanged,
      ),
    );
  }

  Widget _propertyNavTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(
        Icons.apartment_outlined,
        _isSavingPropertyNav,
      ),
      title: Text(L10n.get("admin_app_setting_property_nav_enabled_title")),
      subtitle: Text(
        L10n.get("admin_app_setting_property_nav_enabled_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _propertyNavEnabled,
        enabled: !_isSavingPropertyNav,
        onChanged: _onPropertyNavEnabledChanged,
      ),
    );
  }

  /// Kill switch for "only one active instance per user": locks every
  /// browser tab except the most recently opened one on the Flutter web
  /// app, and also gates the Telegram Mini App's single-session enforcement
  /// server-side (see `TelegramMiniAppSessionService`). Has no effect on the
  /// native iOS/Android apps.
  Widget _webAppMultipleInstanceCheckTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(
        Icons.tab_unselected_rounded,
        _isSavingWebAppMultipleInstanceCheck,
      ),
      title: Text(
        L10n.get("admin_app_setting_web_multi_instance_check_title"),
      ),
      subtitle: Text(
        L10n.get("admin_app_setting_web_multi_instance_check_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _webAppMultipleInstanceCheckEnabled,
        enabled: !_isSavingWebAppMultipleInstanceCheck,
        onChanged: _onWebAppMultipleInstanceCheckChanged,
      ),
    );
  }

  Widget _mapLayerDefaultTile(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String subtitleKey,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: _savingLeading(icon, _isSavingMapLayerDefaults),
      title: Text(L10n.get(titleKey)),
      subtitle: Text(
        L10n.get(subtitleKey),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: value,
        enabled: !_isSavingMapLayerDefaults,
        onChanged: onChanged,
      ),
    );
  }

  Widget _listingContactsTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.contact_phone, _isSavingListingContacts),
      title: Text(L10n.get("admin_client_settings_show_listing_contacts")),
      subtitle: Text(
        L10n.get("admin_client_settings_show_listing_contacts_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _listingContactsVisible,
        enabled: !_isSavingListingContacts,
        onChanged: _onShowListingContactsChanged,
      ),
    );
  }

  Widget _groupFormingLimitTile(BuildContext context) {
    return ListTile(
      leading:
          _savingLeading(Icons.groups_2_outlined, _isSavingGroupFormingLimit),
      title: Text(
        L10n.get("admin_app_setting_group_forming_membership_limit_title"),
      ),
      subtitle: Text(
        L10n.get("admin_app_setting_group_forming_membership_limit_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: _GroupLimitStepper(
        value: _groupFormingMaxActiveMemberships,
        enabled: !_isSavingGroupFormingLimit,
        onChanged: _setGroupFormingLimit,
      ),
    );
  }

  Widget _telegramMiniAppDailyListingLimitTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(
        Icons.send_time_extension_outlined,
        _isSavingTelegramMiniAppDailyListingLimit,
      ),
      title: Text(
        L10n.get("admin_app_setting_telegram_miniapp_daily_listing_limit_title"),
      ),
      subtitle: Text(
        _telegramMiniAppDailyListingLimit <= 0
            ? L10n.get(
                "admin_app_setting_telegram_miniapp_daily_listing_limit_subtitle_off",
              )
            : L10n.get(
                "admin_app_setting_telegram_miniapp_daily_listing_limit_subtitle_on",
              ),
        style: _subtitleStyle(context),
      ),
      trailing: _NumericLimitStepper(
        value: _telegramMiniAppDailyListingLimit,
        min: 0,
        max: 100,
        zeroLabel: L10n.get("admin_app_setting_limit_off_label"),
        enabled: !_isSavingTelegramMiniAppDailyListingLimit,
        onChanged: _setTelegramMiniAppDailyListingLimit,
      ),
    );
  }

  Widget _geminiTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.auto_awesome_outlined, _isSavingGemini),
      title: Text(L10n.get("admin_client_config_hide_gemini_listing_ui")),
      subtitle: Text(
        L10n.get("admin_client_config_hide_gemini_listing_ui_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _geminiListingUiEnabled,
        enabled: !_isSavingGemini,
        onChanged: _onGeminiEnabledChanged,
      ),
    );
  }

  Widget _lidarTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.view_in_ar, _isSavingLidar),
      title: Text(L10n.get("admin_client_config_disable_lidar_room_scan")),
      subtitle: Text(
        L10n.get("admin_client_config_disable_lidar_room_scan_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _lidarRoomScanEnabled,
        enabled: !_isSavingLidar,
        onChanged: _onLidarEnabledChanged,
      ),
    );
  }

  Widget _roomScanGlbConversionTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(
        Icons.view_in_ar_outlined,
        _isSavingRoomScanGlbConversion,
      ),
      title: Text(L10n.get("admin_client_config_room_scan_glb_conversion")),
      subtitle: Text(
        L10n.get(
          "admin_client_config_room_scan_glb_conversion_description",
        ),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _roomScanGlbConversionEnabled,
        enabled: !_isSavingRoomScanGlbConversion,
        onChanged: _onRoomScanGlbConversionEnabledChanged,
      ),
    );
  }

  Widget _customCameraTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.camera_alt_outlined, _isSavingCustomCamera),
      title: Text(L10n.get("admin_client_config_disable_custom_camera")),
      subtitle: Text(
        L10n.get("admin_client_config_disable_custom_camera_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _customCameraEnabled,
        enabled: !_isSavingCustomCamera,
        onChanged: _onCustomCameraEnabledChanged,
      ),
    );
  }

  Widget _dictationMeterTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.graphic_eq, _isSavingDictationMeter),
      title: Text(L10n.get("admin_client_config_show_listing_dictation_meter")),
      subtitle: Text(
        L10n.get(
            "admin_client_config_show_listing_dictation_meter_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _dictationMeterEnabled,
        enabled: !_isSavingDictationMeter,
        onChanged: _onDictationMeterEnabledChanged,
      ),
    );
  }

  Widget _moderationQueueTile(BuildContext context) {
    return ListTile(
      leading:
          _savingLeading(Icons.fact_check_outlined, _isSavingModerationQueue),
      title: Text(
        L10n.get("admin_app_setting_listing_gig_moderation_queue_title"),
      ),
      subtitle: Text(
        L10n.get("admin_app_setting_listing_gig_moderation_queue_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _listingGigModerationQueueEnabled,
        enabled: !_isSavingModerationQueue,
        onChanged: _onListingGigModerationQueueChanged,
      ),
    );
  }

  Widget _contentModerationBlurTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(Icons.blur_on_outlined, _isSaving),
      title: Text(L10n.get("admin_content_moderation_blur_enabled")),
      trailing: NeumorphicThemeAwareToggle(
        value: _blurEnabled,
        enabled: !_isSaving,
        onChanged: _onChanged,
      ),
    );
  }

  Widget _adminListingConversationsTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(
        Icons.forum_outlined,
        _isSavingAdminListingConversations,
      ),
      title:
          Text(L10n.get("admin_app_setting_listing_owner_conversations_title")),
      subtitle: Text(
        L10n.get("admin_app_setting_listing_owner_conversations_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _adminListingConversationsEnabled,
        enabled: !_isSavingAdminListingConversations,
        onChanged: _onAdminListingConversationsEnabledChanged,
      ),
    );
  }

  Widget _telegramMessageBridgeTile(BuildContext context) {
    return ListTile(
      leading: _savingLeading(
        Icons.sync_alt_outlined,
        _isSavingTelegramMessageBridge,
      ),
      title: Text(L10n.get("admin_app_setting_telegram_bridge_title")),
      subtitle: Text(
        L10n.get("admin_app_setting_telegram_bridge_subtitle"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: _telegramMessageBridgeEnabled,
        enabled: !_isSavingTelegramMessageBridge,
        onChanged: _onTelegramMessageBridgeEnabledChanged,
      ),
    );
  }

  Widget _priceInsightsTile(BuildContext context) {
    final flags = AdminFeatureFlagsState();
    return ListTile(
      leading: _savingLeading(Icons.insights_outlined, _isSavingPriceInsights),
      title: Text(L10n.get("admin_client_settings_show_price_insights")),
      subtitle: Text(
        L10n.get("admin_client_settings_show_price_insights_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: flags.showPriceInsights,
        enabled: !_isSavingPriceInsights,
        onChanged: _onShowPriceInsightsChanged,
      ),
    );
  }

  Widget _listingMoveToTopTile(BuildContext context) {
    final flags = AdminFeatureFlagsState();
    return ListTile(
      leading: _savingLeading(
          CupertinoIcons.arrow_up_circle, _isSavingListingMoveToTop),
      title: Text(L10n.get("admin_client_settings_show_listing_move_to_top")),
      subtitle: Text(
        L10n.get("admin_client_settings_show_listing_move_to_top_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: flags.showListingMoveToTop,
        enabled: !_isSavingListingMoveToTop,
        onChanged: _onShowListingMoveToTopChanged,
      ),
    );
  }

  Widget _pushDebugTile(BuildContext context) {
    final flags = AdminFeatureFlagsState();
    return ListTile(
      leading: _savingLeading(
          Icons.notifications_active_outlined, _isSavingPushDebug),
      title: Text(L10n.get("admin_client_settings_show_push_debug")),
      subtitle: Text(
        L10n.get("admin_client_settings_show_push_debug_description"),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: flags.showPushDebug,
        enabled: !_isSavingPushDebug,
        onChanged: _onShowPushDebugChanged,
      ),
    );
  }
}

enum _SettingsCategory {
  appExperience,
  maps,
  listings,
  moderation,
  telegram,
  adminTools;

  Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (this) {
      case _SettingsCategory.appExperience:
        return isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
      case _SettingsCategory.maps:
        return isDark ? const Color(0xFF4DD0E1) : const Color(0xFF00838F);
      case _SettingsCategory.listings:
        return isDark ? const Color(0xFF69F0AE) : const Color(0xFF00897B);
      case _SettingsCategory.moderation:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
      case _SettingsCategory.telegram:
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF0277BD);
      case _SettingsCategory.adminTools:
        return isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A);
    }
  }
}

class _GroupLimitStepper extends StatelessWidget {
  const _GroupLimitStepper({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final disabledColor = theme.disabledColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            color: enabled && value > 1 ? color : disabledColor,
            onPressed: enabled && value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              "$value",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            color: enabled && value < 10 ? color : disabledColor,
            onPressed:
                enabled && value < 10 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

/// Generic +/- stepper for admin-configurable numeric limits, with an
/// optional [zeroLabel] shown instead of "0" (e.g. "Off" for an unlimited cap).
class _NumericLimitStepper extends StatelessWidget {
  const _NumericLimitStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    this.zeroLabel,
  });

  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final String? zeroLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final disabledColor = theme.disabledColor;
    final label = value == 0 && zeroLabel != null ? zeroLabel! : "$value";
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            color: enabled && value > min ? color : disabledColor,
            onPressed:
                enabled && value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            color: enabled && value < max ? color : disabledColor,
            onPressed:
                enabled && value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
