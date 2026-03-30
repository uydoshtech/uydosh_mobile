import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/services/admin_content_moderation_settings_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";

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
      final res = await _settingsService.getContentModerationBlurSetting();
      if (!mounted) return;
      setState(() {
        _blurEnabled = res.enabled;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
              : const Icon(Icons.blur_on_outlined),
        ),
      ],
    );
  }
}
