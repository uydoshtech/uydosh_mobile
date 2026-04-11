import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/services/admin_content_moderation_settings_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

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
  bool _geminiListingUiHidden = false;
  bool _isSavingGemini = false;
  bool _lidarRoomScanDisabled = false;
  bool _isSavingLidar = false;

  @override
  void initState() {
    super.initState();
    _load();
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
      if (!mounted) return;
      setState(() {
        _blurEnabled = blurRes.enabled;
        _geminiListingUiHidden = geminiRes.hidden;
        _lidarRoomScanDisabled = lidarRes.disabled;
        _isLoading = false;
      });
      ClientGeminiListingUiConfig.applyHidden(hidden: _geminiListingUiHidden);
      ClientLidarRoomScanConfig.applyDisabled(disabled: _lidarRoomScanDisabled);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onLidarDisabledChanged(bool value) async {
    if (_isSavingLidar) return;
    setState(() => _isSavingLidar = true);
    try {
      final res = await _settingsService.setLidarRoomScanDisabled(
        disabled: value,
      );
      if (!mounted) return;
      setState(() {
        _lidarRoomScanDisabled = res.disabled;
        _isSavingLidar = false;
      });
      ClientLidarRoomScanConfig.applyDisabled(disabled: res.disabled);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingLidar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
      );
    }
  }

  Future<void> _onGeminiHideChanged(bool value) async {
    if (_isSavingGemini) return;
    setState(() => _isSavingGemini = true);
    try {
      final res = await _settingsService.setGeminiListingUiHidden(hidden: value);
      if (!mounted) return;
      setState(() {
        _geminiListingUiHidden = res.hidden;
        _isSavingGemini = false;
      });
      ClientGeminiListingUiConfig.applyHidden(hidden: res.hidden);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingGemini = false);
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
      if (!mounted) return;
      setState(() {
        _blurEnabled = res.enabled;
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${L10n.get("admin_content_moderation_save_error")}: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              onPressed: _load,
              child: Text(L10n.get("admin_search_analytics_retry")),
            ),
          ],
        ),
      );
    }
    return ListView(
      children: [
        Text(
          L10n.get("admin_content_moderation_description"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: Text(L10n.get("admin_content_moderation_blur_enabled")),
          value: _blurEnabled,
          onChanged: _isSaving ? null : _onChanged,
          secondary: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const ThemeIcon(Icons.blur_on_outlined),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(L10n.get("admin_client_config_hide_gemini_listing_ui")),
          subtitle: Text(
            L10n.get("admin_client_config_hide_gemini_listing_ui_description"),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          value: _geminiListingUiHidden,
          onChanged: _isSavingGemini ? null : _onGeminiHideChanged,
          secondary: _isSavingGemini
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const ThemeIcon(Icons.auto_awesome_outlined),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(L10n.get("admin_client_config_disable_lidar_room_scan")),
          subtitle: Text(
            L10n.get("admin_client_config_disable_lidar_room_scan_description"),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          value: _lidarRoomScanDisabled,
          onChanged: _isSavingLidar ? null : _onLidarDisabledChanged,
          secondary: _isSavingLidar
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const ThemeIcon(Icons.view_in_ar),
        ),
      ],
    );
  }
}
