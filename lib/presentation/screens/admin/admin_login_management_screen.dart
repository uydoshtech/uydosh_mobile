import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_apple_sign_in_config.dart";
import "package:uy_dosh/base/config/client_google_sign_in_config.dart";
import "package:uy_dosh/base/config/client_phone_sign_in_config.dart";
import "package:uy_dosh/base/config/client_telegram_sign_in_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_login_management_settings_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

/// Admin-only screen letting admins turn each sign-in provider (Google, Apple,
/// Telegram, phone) on/off platform-wide. Backed by `/admin/settings/*-sign-in-enabled`.
class AdminLoginManagementScreen extends StatefulWidget {
  const AdminLoginManagementScreen({super.key});

  @override
  State<AdminLoginManagementScreen> createState() =>
      _AdminLoginManagementScreenState();
}

class _AdminLoginManagementScreenState
    extends State<AdminLoginManagementScreen> {
  final IAdminLoginManagementSettingsService _settingsService =
      getIt<IAdminLoginManagementSettingsService>();

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  bool _googleEnabled = true;
  bool _isSavingGoogle = false;
  bool _appleEnabled = true;
  bool _isSavingApple = false;
  bool _telegramEnabled = true;
  bool _isSavingTelegram = false;
  bool _phoneEnabled = false;
  bool _isSavingPhone = false;

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
      final googleRes = await _settingsService.getGoogleSignInEnabledSetting();
      final appleRes = await _settingsService.getAppleSignInEnabledSetting();
      final telegramRes =
          await _settingsService.getTelegramSignInEnabledSetting();
      final phoneRes = await _settingsService.getPhoneSignInEnabledSetting();
      setStateIfMounted(() {
        _googleEnabled = googleRes.enabled;
        _appleEnabled = appleRes.enabled;
        _telegramEnabled = telegramRes.enabled;
        _phoneEnabled = phoneRes.enabled;
        _isLoading = false;
      });
      ClientGoogleSignInConfig.applyEnabled(enabled: _googleEnabled);
      ClientAppleSignInConfig.applyEnabled(enabled: _appleEnabled);
      ClientTelegramSignInConfig.applyEnabled(enabled: _telegramEnabled);
      ClientPhoneSignInConfig.applyEnabled(enabled: _phoneEnabled);
    } catch (e, st) {
      logger.d("AdminLoginManagementScreen._load failed: $e\n$st");
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onGoogleChanged(bool value) async {
    if (_isSavingGoogle) return;
    setState(() => _isSavingGoogle = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setGoogleSignInEnabled(enabled: value);
      setStateIfMounted(() => _googleEnabled = res.enabled);
      ClientGoogleSignInConfig.applyEnabled(enabled: res.enabled);
    } catch (e) {
      _showSaveError(e);
    } finally {
      setStateIfMounted(() => _isSavingGoogle = false);
    }
  }

  Future<void> _onAppleChanged(bool value) async {
    if (_isSavingApple) return;
    setState(() => _isSavingApple = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setAppleSignInEnabled(enabled: value);
      setStateIfMounted(() => _appleEnabled = res.enabled);
      ClientAppleSignInConfig.applyEnabled(enabled: res.enabled);
    } catch (e) {
      _showSaveError(e);
    } finally {
      setStateIfMounted(() => _isSavingApple = false);
    }
  }

  Future<void> _onTelegramChanged(bool value) async {
    if (_isSavingTelegram) return;
    setState(() => _isSavingTelegram = true);
    try {
      HapticFeedbackUtils.impact();
      final res =
          await _settingsService.setTelegramSignInEnabled(enabled: value);
      setStateIfMounted(() => _telegramEnabled = res.enabled);
      ClientTelegramSignInConfig.applyEnabled(enabled: res.enabled);
    } catch (e) {
      _showSaveError(e);
    } finally {
      setStateIfMounted(() => _isSavingTelegram = false);
    }
  }

  Future<void> _onPhoneChanged(bool value) async {
    if (_isSavingPhone) return;
    setState(() => _isSavingPhone = true);
    try {
      HapticFeedbackUtils.impact();
      final res = await _settingsService.setPhoneSignInEnabled(
        enabled: value,
      );
      setStateIfMounted(() => _phoneEnabled = res.enabled);
      ClientPhoneSignInConfig.applyEnabled(enabled: res.enabled);
    } catch (e) {
      _showSaveError(e);
    } finally {
      setStateIfMounted(() => _isSavingPhone = false);
    }
  }

  void _showSaveError(Object e) {
    if (!mounted) return;
    ToastTheme.showErrorSimple(
      context,
      message: "${L10n.get("admin_login_management_save_error")}: $e",
    );
  }

  Widget _savingLeading(IconData icon, bool isSaving) {
    return isSaving
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : ThemeIcon(icon);
  }

  TextStyle _subtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  Widget _loginMethodTile({
    required IconData icon,
    required bool isSaving,
    required String titleKey,
    required String subtitleKey,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: _savingLeading(icon, isSaving),
      title: Text(L10n.get(titleKey)),
      subtitle: Text(
        L10n.get(subtitleKey),
        style: _subtitleStyle(context),
      ),
      trailing: NeumorphicThemeAwareToggle(
        value: value,
        enabled: !isSaving,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.25);

    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_login_management_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HouseLoadingIndicator(),
                    const SizedBox(height: 16),
                    Text(L10n.get("admin_login_management_loading")),
                  ],
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          L10n.get("admin_login_management_error"),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      Text(
                        L10n.get("admin_login_management_subtitle"),
                        style: _subtitleStyle(context),
                      ),
                      const SizedBox(height: 16),
                      ListingDetailTileShell(
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.zero,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _loginMethodTile(
                              icon: Icons.g_mobiledata,
                              isSaving: _isSavingGoogle,
                              titleKey: "admin_login_management_google_title",
                              subtitleKey:
                                  "admin_login_management_google_subtitle",
                              value: _googleEnabled,
                              onChanged: _onGoogleChanged,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 52,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            _loginMethodTile(
                              icon: Icons.apple,
                              isSaving: _isSavingApple,
                              titleKey: "admin_login_management_apple_title",
                              subtitleKey:
                                  "admin_login_management_apple_subtitle",
                              value: _appleEnabled,
                              onChanged: _onAppleChanged,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 52,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            _loginMethodTile(
                              icon: Icons.send_outlined,
                              isSaving: _isSavingTelegram,
                              titleKey: "admin_login_management_telegram_title",
                              subtitleKey:
                                  "admin_login_management_telegram_subtitle",
                              value: _telegramEnabled,
                              onChanged: _onTelegramChanged,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 52,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            _loginMethodTile(
                              icon: Icons.phone_android_outlined,
                              isSaving: _isSavingPhone,
                              titleKey: "admin_login_management_phone_title",
                              subtitleKey:
                                  "admin_login_management_phone_subtitle",
                              value: _phoneEnabled,
                              onChanged: _onPhoneChanged,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
