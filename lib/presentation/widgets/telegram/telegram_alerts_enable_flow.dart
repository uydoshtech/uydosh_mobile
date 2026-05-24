import "dart:async";

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/telegram_bot_alerts_service.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";

/// Prompts the user to start the UyDosh Telegram bot after login or bind.
class TelegramAlertsEnableFlow {
  TelegramAlertsEnableFlow._();

  static Future<void> offerIfNeeded(
    BuildContext context, {
    bool useRootNavigator = false,
  }) async {
    try {
      final status = await getIt<ITelegramBotAlertsService>().fetchStatus();
      if (!status.configured ||
          !status.telegramLinked ||
          status.alertsEnabled) {
        return;
      }
      if (!context.mounted) return;
      await TelegramAlertsEnableBottomSheet.show(
        context,
        useRootNavigator: useRootNavigator,
      );
    } catch (_) {
      // Backend may not have bot alerts configured yet — skip quietly.
    }
  }
}

class TelegramAlertsEnableBottomSheet extends StatefulWidget {
  const TelegramAlertsEnableBottomSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    bool useRootNavigator = false,
  }) {
    HapticFeedbackUtils.impact();
    return showAppBottomSheet<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      showDragHandle: true,
      builder: (context) => const TelegramAlertsEnableBottomSheet(),
    );
  }

  @override
  State<TelegramAlertsEnableBottomSheet> createState() =>
      _TelegramAlertsEnableBottomSheetState();
}

class _TelegramAlertsEnableBottomSheetState
    extends State<TelegramAlertsEnableBottomSheet> with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 2);
  static const _maxPolls = 30;

  bool _isOpening = false;
  bool _isWaiting = false;
  Timer? _pollTimer;
  int _pollCount = 0;

  ITelegramBotAlertsService get _service =>
      getIt<ITelegramBotAlertsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaiting) {
      unawaited(_pollOnce());
    }
  }

  Future<void> _enablePressed() async {
    if (_isOpening || _isWaiting) return;
    setStateIfMounted(() => _isOpening = true);
    try {
      final url = await _service.fetchEnableLinkUrl();
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        ToastTheme.showWarning(
          context,
          message: L10n.get("could_not_open_telegram"),
        );
        return;
      }
      setStateIfMounted(() {
        _isWaiting = true;
        _pollCount = 0;
      });
      _startPolling();
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showWarning(
        context,
        message: L10n.get("telegram_alerts_enable_failed"),
      );
    } finally {
      setStateIfMounted(() => _isOpening = false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_pollOnce());
    });
  }

  Future<void> _pollOnce() async {
    if (!_isWaiting || !mounted) return;
    _pollCount += 1;
    if (_pollCount > _maxPolls) {
      _stopPolling();
      return;
    }
    try {
      final status = await _service.fetchStatus();
      if (!mounted || !status.alertsEnabled) return;
      _stopPolling();
      ToastTheme.showSuccess(
        context,
        message: L10n.get("telegram_alerts_enabled_success"),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      // Keep polling until timeout.
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    setStateIfMounted(() => _isWaiting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GlassBottomSheetSurface(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ThemeIcon(
                Icons.telegram,
                color: const Color(0xFF4DA3E9),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  L10n.get("telegram_alerts_enable_title"),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            L10n.get("telegram_alerts_enable_body"),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (_isWaiting) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const UydoshInlineSpinner(
                  color: Color(0xFF4DA3E9),
                  dimension: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10n.get("telegram_alerts_enable_waiting"),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            onPressed: _enablePressed,
            isLoading: _isOpening,
            isDisabled: _isWaiting,
            child: Text(L10n.get("telegram_alerts_enable_button")),
          ),
          const SizedBox(height: 8),
          GhostButton(
            onPressed: _isOpening
                ? null
                : () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(context).pop();
                  },
            child: Text(L10n.get("complete_profile_prompt_later")),
          ),
        ],
      ),
    );
  }
}
