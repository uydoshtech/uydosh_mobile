import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_custom_camera_config.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/config/client_listing_contacts_config.dart";
import "package:uy_dosh/base/config/client_listing_dictation_meter_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/admin_feature_flags_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_content_moderation_settings_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

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
  bool _isSavingPriceInsights = false;
  bool _isSavingTooltips = false;

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
      final blurRes = await _settingsService.getContentModerationBlurSetting();
      final geminiRes =
          await _settingsService.getGeminiListingUiHiddenSetting();
      final lidarRes =
          await _settingsService.getLidarRoomScanDisabledSetting();
      final cameraRes = await _settingsService.getCustomCameraDisabledSetting();
      final dictationMeterRes =
          await _settingsService.getListingDescriptionDictationMeterDisabledSetting();
      final contactsRes =
          await _settingsService.getListingContactsVisibleSetting();
      setStateIfMounted(() {
        _blurEnabled = blurRes.enabled;
        // UI is positive: ON means enabled/shown.
        _geminiListingUiEnabled = !geminiRes.hidden;
        _lidarRoomScanEnabled = !lidarRes.disabled;
        _customCameraEnabled = !cameraRes.disabled;
        _dictationMeterEnabled = !dictationMeterRes.disabled;
        _listingContactsVisible = contactsRes.visible;
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
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
      );
    }
  }

  Future<void> _onDictationMeterEnabledChanged(bool value) async {
    if (_isSavingDictationMeter) return;
    setState(() => _isSavingDictationMeter = true);
    try {
      final res = await _settingsService.setListingDescriptionDictationMeterDisabled(
        disabled: !value,
      );
      setStateIfMounted(() {
        _dictationMeterEnabled = !res.disabled;
        _isSavingDictationMeter = false;
      });
      ClientListingDictationMeterConfig.applyDisabled(disabled: res.disabled);
    } catch (e) {
      setStateIfMounted(() => _isSavingDictationMeter = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
      );
    } finally {
      setStateIfMounted(() => _isSavingListingContacts = false);
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

  Widget _neumorphicRow(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: Theme.of(context).cardTheme.copyWith(
          margin: EdgeInsets.zero,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      child: ListingDetailTileShell(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: child,
      ),
    );
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
            FilledButton(
              onPressed: () {
                HapticFeedbackUtils.impact();
                _load();
              },
              child: Text(L10n.get("admin_search_analytics_retry")),
            ),
          ],
        ),
      );
    }
    return ListView(
      children: [
        const SizedBox(height: 4),
        ListenableBuilder(
          listenable: TooltipsState(),
          builder: (context, _) {
            return _neumorphicRow(
              ListTile(
                leading: _isSavingTooltips
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const ThemeIcon(Icons.tips_and_updates_outlined),
                title: Text(L10n.get("tooltips_toggle")),
                subtitle: Text(
                  L10n.get("tooltips_toggle_description"),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: NeumorphicThemeAwareToggle(
                  value: TooltipsState().enabled,
                  enabled: !_isSavingTooltips,
                  onChanged: _onTooltipsEnabledChanged,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _neumorphicRow(
          ListTile(
            leading: _isSavingListingContacts
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const ThemeIcon(Icons.contact_phone),
            title: Text(
              L10n.get("admin_client_settings_show_listing_contacts"),
            ),
            subtitle: Text(
              L10n.get(
                "admin_client_settings_show_listing_contacts_description",
              ),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: NeumorphicThemeAwareToggle(
              value: _listingContactsVisible,
              enabled: !_isSavingListingContacts,
              onChanged: _onShowListingContactsChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: AdminFeatureFlagsState(),
          builder: (context, _) {
            final flags = AdminFeatureFlagsState();
            return _neumorphicRow(
              ListTile(
                leading: _isSavingPriceInsights
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const ThemeIcon(Icons.insights_outlined),
                title: Text(
                  L10n.get("admin_client_settings_show_price_insights"),
                ),
                subtitle: Text(
                  L10n.get(
                    "admin_client_settings_show_price_insights_description",
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: NeumorphicThemeAwareToggle(
                  value: flags.showPriceInsights,
                  enabled: !_isSavingPriceInsights,
                  onChanged: _onShowPriceInsightsChanged,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _neumorphicRow(
          ListTile(
            leading: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const ThemeIcon(Icons.blur_on_outlined),
            title: Text(L10n.get("admin_content_moderation_blur_enabled")),
            trailing: NeumorphicThemeAwareToggle(
              value: _blurEnabled,
              enabled: !_isSaving,
              onChanged: _onChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _neumorphicRow(
          ListTile(
            leading: _isSavingGemini
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const ThemeIcon(Icons.auto_awesome_outlined),
            title: Text(L10n.get("admin_client_config_hide_gemini_listing_ui")),
            subtitle: Text(
              L10n.get("admin_client_config_hide_gemini_listing_ui_description"),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: NeumorphicThemeAwareToggle(
              value: _geminiListingUiEnabled,
              enabled: !_isSavingGemini,
              onChanged: _onGeminiEnabledChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _neumorphicRow(
          ListTile(
            leading: _isSavingLidar
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const ThemeIcon(Icons.view_in_ar),
            title: Text(L10n.get("admin_client_config_disable_lidar_room_scan")),
            subtitle: Text(
              L10n.get("admin_client_config_disable_lidar_room_scan_description"),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: NeumorphicThemeAwareToggle(
              value: _lidarRoomScanEnabled,
              enabled: !_isSavingLidar,
              onChanged: _onLidarEnabledChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _neumorphicRow(
          ListTile(
            leading: _isSavingCustomCamera
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const ThemeIcon(Icons.camera_alt_outlined),
            title: Text(L10n.get("admin_client_config_disable_custom_camera")),
            subtitle: Text(
              L10n.get("admin_client_config_disable_custom_camera_description"),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: NeumorphicThemeAwareToggle(
              value: _customCameraEnabled,
              enabled: !_isSavingCustomCamera,
              onChanged: _onCustomCameraEnabledChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _neumorphicRow(
          ListTile(
            leading: _isSavingDictationMeter
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const ThemeIcon(Icons.graphic_eq),
            title: Text(L10n.get("admin_client_config_show_listing_dictation_meter")),
            subtitle: Text(
              L10n.get("admin_client_config_show_listing_dictation_meter_description"),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: NeumorphicThemeAwareToggle(
              value: _dictationMeterEnabled,
              enabled: !_isSavingDictationMeter,
              onChanged: _onDictationMeterEnabledChanged,
            ),
          ),
        ),
      ],
    );
  }
}
