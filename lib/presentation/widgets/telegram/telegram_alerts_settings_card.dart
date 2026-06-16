import "dart:async";

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/config/telegram_bot_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/open_telegram_bot_start_link.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/telegram_bot_alerts_service.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

String get _telegramBotHandle => "@${TelegramBotConfig.botUsername}";

Widget _textWithBoldBotName(String text, TextStyle style) {
  final handle = _telegramBotHandle;
  if (!text.contains(handle)) {
    return Text(text, style: style);
  }

  final spans = <TextSpan>[];
  var start = 0;
  var index = text.indexOf(handle);
  while (index != -1) {
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }
    spans.add(
      TextSpan(
        text: handle,
        style: style.copyWith(fontWeight: FontWeight.w700),
      ),
    );
    start = index + handle.length;
    index = text.indexOf(handle, start);
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return Text.rich(TextSpan(style: style, children: spans));
}

/// Notifications settings tile: open @uydosh_bot to opt in (separate from login).
class TelegramAlertsSettingsCard extends StatefulWidget {
  const TelegramAlertsSettingsCard({super.key});

  @override
  State<TelegramAlertsSettingsCard> createState() =>
      _TelegramAlertsSettingsCardState();
}

class _TelegramAlertsSettingsCardState extends State<TelegramAlertsSettingsCard>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 2);
  static const _maxPolls = 30;

  bool? _alertsEnabled;
  bool _opening = false;
  bool _disabling = false;
  bool _waiting = false;
  bool _connectedExpanded = false;
  Timer? _pollTimer;
  int _pollCount = 0;

  ITelegramBotAlertsService get _service => getIt<ITelegramBotAlertsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadStatus());
      if (_waiting) unawaited(_pollOnce());
    }
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _service.fetchStatus();
      if (!mounted) return;
      if (status.alertsEnabled && _waiting) {
        _onAlertsEnabled();
        return;
      }
      setStateIfMounted(() {
        _alertsEnabled = status.alertsEnabled;
        if (!status.alertsEnabled) _connectedExpanded = false;
      });
    } catch (_) {
      if (!mounted) return;
      setStateIfMounted(() {
        _alertsEnabled ??= false;
      });
    }
  }

  /// Handles the transition to "alerts enabled" while waiting for the user to
  /// finish opting in via the bot. This is synchronous and guarded by
  /// `_waiting` so that concurrent callers (the periodic poll timer and the
  /// app-resume handler) only ever show the success toast once.
  void _onAlertsEnabled() {
    if (!_waiting || !mounted) return;
    _pollTimer?.cancel();
    setStateIfMounted(() {
      _alertsEnabled = true;
      _waiting = false;
      _connectedExpanded = false;
    });
    ToastTheme.showSuccess(
      context,
      message: L10n.get("telegram_alerts_enabled_success"),
    );
  }

  Future<void> _openBot() async {
    if (_opening || _waiting) return;
    HapticFeedbackUtils.impact();
    setStateIfMounted(() => _opening = true);
    try {
      try {
        final link = await _service.fetchEnableLink();
        final ok = await openTelegramBotStartLink(
          botUsername: link.botUsername,
          startParam: link.startParam,
          httpsUrl: link.url,
        );
        if (!mounted) return;
        if (!ok) {
          ToastTheme.showWarning(
            context,
            message: L10n.get("could_not_open_telegram"),
          );
          return;
        }
      } catch (_) {
        final fallback = Uri.parse(
          "https://t.me/${TelegramBotConfig.botUsername}",
        );
        final ok = await launchUrl(
          fallback,
          mode: LaunchMode.externalApplication,
        );
        if (!mounted) return;
        if (!ok) {
          ToastTheme.showWarning(
            context,
            message: L10n.get("could_not_open_telegram"),
          );
          return;
        }
      }

      setStateIfMounted(() {
        _waiting = true;
        _pollCount = 0;
      });
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(_pollInterval, (_) {
        unawaited(_pollOnce());
      });
    } finally {
      setStateIfMounted(() => _opening = false);
    }
  }

  Future<void> _pollOnce() async {
    if (!_waiting || !mounted) return;
    _pollCount += 1;
    if (_pollCount > _maxPolls) {
      setStateIfMounted(() => _waiting = false);
      _pollTimer?.cancel();
      return;
    }
    try {
      final status = await _service.fetchStatus();
      if (!mounted || !status.alertsEnabled) return;
      _onAlertsEnabled();
    } catch (_) {}
  }

  Future<void> _disableAlerts() async {
    if (_disabling) return;
    HapticFeedbackUtils.impact();
    setStateIfMounted(() => _disabling = true);
    try {
      await _service.disableAlerts();
      if (!mounted) return;
      setStateIfMounted(() {
        _alertsEnabled = false;
        _connectedExpanded = false;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("telegram_alerts_disabled_success"),
      );
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("telegram_alerts_disable_failed"),
      );
    } finally {
      setStateIfMounted(() => _disabling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_alertsEnabled == null) {
      return _loadingCard(context);
    }
    if (_alertsEnabled == true) {
      return _connectedCard(context);
    }

    return _connectCard(context);
  }

  Widget _loadingCard(BuildContext context) {
    const fg = Color(0xFF0A3050);
    const cardBg = Color(0xFF4DA3E9);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardBg),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            const Icon(Icons.telegram, size: 22, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                L10n.get("telegram_alerts_settings_title"),
                style: const TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            UydoshInlineSpinner(
              color: fg.withValues(alpha: 0.85),
              dimension: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _connectedCard(BuildContext context) {
    const fg = Color(0xFF0D3B1E);
    const cardBg = Color(0xFFB8E6C8);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardBg),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedbackUtils.impact();
                  setStateIfMounted(
                    () => _connectedExpanded = !_connectedExpanded,
                  );
                },
                child: Row(
                  children: [
                    const ThemeIcon(Icons.telegram, size: 22, color: fg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        L10n.get("telegram_alerts_connected"),
                        style: const TextStyle(
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _connectedExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 22,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
              if (_connectedExpanded) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    surfaceGradientBase: Colors.white.withValues(alpha: 0.22),
                    textColor: fg,
                    isLoading: _disabling,
                    onPressed: _disableAlerts,
                    child: Text(L10n.get("telegram_alerts_disable_button")),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectCard(BuildContext context) {
    const fg = Color(0xFF0A3050);
    const cardBg = Color(0xFF4DA3E9);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardBg),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.telegram, size: 22, color: fg),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10n.get("telegram_alerts_settings_title"),
                    style: const TextStyle(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _textWithBoldBotName(
              L10n.get("telegram_alerts_settings_body"),
              TextStyle(
                color: fg.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (_waiting) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  UydoshInlineSpinner(
                    color: fg.withValues(alpha: 0.85),
                    dimension: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _textWithBoldBotName(
                      L10n.get("telegram_alerts_settings_waiting"),
                      TextStyle(
                        color: fg.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                borderRadius: BorderRadius.circular(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                surfaceGradientBase: Colors.white.withValues(alpha: 0.22),
                textColor: fg,
                isLoading: _opening,
                isDisabled: _waiting,
                onPressed: _openBot,
                child: Builder(
                  builder: (context) => _textWithBoldBotName(
                    L10n.get("telegram_alerts_settings_button"),
                    DefaultTextStyle.of(context).style,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
