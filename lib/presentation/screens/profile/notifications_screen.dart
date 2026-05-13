// ignore_for_file: eol_at_end_of_file

import "package:dio/dio.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart"
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/search_alert.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/roll_up_fade_out.dart";
import "package:uy_dosh/presentation/widgets/common/the_dot_drop_menu_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_info_callout_card.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_popup_menu.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

const bool _pushDebugEnabled = true;

// Force-show the "Enable notifications" tile on web (Chrome) so the layout can
// be tested without deploying to a real device. Push is not actually supported
// on web; the button just won't do anything meaningful there.
const bool _forceShowPushEnableCard = kIsWeb;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _bulkWorking = false;
  List<SearchAlert> _alerts = const [];
  bool _showAlertsExplainer = true;
  bool _alertsExplainerClosing = false;
  final Set<int> _itemsBeingRemoved =
      {}; // Track items being removed for animation
  final Map<int, ({SearchAlert alert, int index})> _optimisticallyRemoved =
      {}; // Rollback buffer for optimistic removals

  /// Per-alert step counter for swipe-to-delete haptics (matches inbox archive).
  final Map<int, int> _alertSwipeHapticStepById = {};

  AuthorizationStatus? _pushStatus;
  bool _pushStatusLoading = false;

  bool _pushDebugExpanded = false;
  bool _pushDebugLoading = false;
  String? _pushPermission;
  String? _apnsTokenPreview;
  String? _fcmTokenPreview;
  String? _fcmTokenFull;
  bool _hasBackendSessionToken = false;

  Future<void> _loadPushStatus() async {
    final push = getIt<IPushNotificationService>();
    if (!push.isSupported) return;
    setState(() => _pushStatusLoading = true);
    try {
      final status = await push.getNotificationStatus();
      setStateIfMounted(() => _pushStatus = status);
    } finally {
      setStateIfMounted(() => _pushStatusLoading = false);
    }
  }

  String _platformPushLabel() {
    if (kIsWeb) return "iOS/Android";
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return "iOS";
      case TargetPlatform.android:
        return "Android";
      default:
        return "iOS/Android";
    }
  }

  Widget _pushEnableCard(ThemeData theme) {
    final push = getIt<IPushNotificationService>();
    if (!push.isSupported && !_forceShowPushEnableCard) {
      return const SizedBox.shrink();
    }

    final status = _pushStatus;
    if (status == null && !_forceShowPushEnableCard) {
      return const SizedBox.shrink();
    }
    final needsEnable = _forceShowPushEnableCard ||
        status == AuthorizationStatus.denied ||
        status == AuthorizationStatus.notDetermined;
    if (!needsEnable) return const SizedBox.shrink();

    final isDenied = status == AuthorizationStatus.denied;

    // Warning-tinted "alert" tile, matching the orange ToastTheme.showWarning toast.
    final cardBg = AppColors.warning;

    const fg = Color(0xFF1F1300);

    final buttonFg = Color(0xFF1F1300);
    final buttonBg = Colors.white.withValues(alpha: 0.18);

    final platformLabel = _platformPushLabel();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardBg),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 20,
                    color: fg,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10n.getWithParams(
                      "notifications_push_off_title",
                      params: {"platform": platformLabel},
                    ),
                    style: const TextStyle(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (_pushStatusLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                borderRadius: BorderRadius.circular(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                surfaceGradientBase: buttonBg,
                textColor: buttonFg,
                onPressed: _pushStatusLoading
                    ? null
                    : () async {
                        if (isDenied) {
                          await openAppSettings();
                          if (!mounted) return;
                          await _loadPushStatus();
                          return;
                        }
                        final ok = await push.requestPermissionAndRegister();
                        if (!mounted) return;
                        if (ok) {
                          ToastTheme.showSuccess(
                            context,
                            message: L10n.get("notifications_enabled"),
                          );
                        } else {
                          ToastTheme.showInfo(
                            context,
                            message:
                                L10n.get("notifications_enable_in_settings"),
                          );
                        }
                        await _loadPushStatus();
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDenied
                          ? Icons.settings_outlined
                          : Icons.notifications_outlined,
                      color: buttonFg,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isDenied
                            ? L10n.get("notifications_open_settings")
                            : L10n.get("menu_enable_notifications"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: buttonFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshPushDebug() async {
    setState(() => _pushDebugLoading = true);
    try {
      final status =
          await getIt<IPushNotificationService>().getNotificationStatus();
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      final fcm = await FirebaseMessaging.instance.getToken();
      final backendToken = await SessionManager.getToken();

      String? preview(String? token) {
        if (token == null || token.isEmpty) return null;
        final head = token.length > 18 ? token.substring(0, 18) : token;
        return "$head… (len=${token.length})";
      }

      setStateIfMounted(() {
        _pushPermission = status?.name;
        _fcmTokenFull = fcm;
        _apnsTokenPreview = preview(apns);
        _fcmTokenPreview = preview(fcm);
        _hasBackendSessionToken =
            backendToken != null && backendToken.trim().isNotEmpty;
      });
    } catch (_) {
      setStateIfMounted(() {
        _pushPermission = "error";
        _fcmTokenFull = null;
        _apnsTokenPreview = null;
        _fcmTokenPreview = null;
        _hasBackendSessionToken = false;
      });
    } finally {
      setStateIfMounted(() => _pushDebugLoading = false);
    }
  }

  Widget _pushDebugPanel(ThemeData theme) {
    if (!_pushDebugEnabled) {
      return const SizedBox.shrink();
    }
    final mono = theme.textTheme.bodySmall?.copyWith(
      fontFamily: "Menlo",
      height: 1.25,
    );

    return Container(
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        initiallyExpanded: _pushDebugExpanded,
        onExpansionChanged: (v) async {
          setState(() => _pushDebugExpanded = v);
          if (v) {
            await _refreshPushDebug();
          }
        },
        title: const Text("Push debug (dev)"),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          if (_pushDebugLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Text("permission: ${_pushPermission ?? "unknown"}", style: mono),
          Text(
            "backend session token: ${_hasBackendSessionToken ? "yes" : "no"}",
            style: mono,
          ),
          Text("APNs token: ${_apnsTokenPreview ?? "null"}", style: mono),
          Text("FCM token: ${_fcmTokenPreview ?? "null"}", style: mono),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GhostButtonFactory.text(
                onPressed: _pushDebugLoading ? null : _refreshPushDebug,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                text: "Refresh",
                neumorphicSoftUi: true,
              ),
              GhostButtonFactory.text(
                onPressed: _pushDebugLoading
                    ? null
                    : () async {
                        final ok = await getIt<IPushNotificationService>()
                            .requestPermissionAndRegister();
                        if (!mounted) return;
                        ToastTheme.showInfoSimple(
                          context,
                          message: ok
                              ? "Push enabled + register attempted"
                              : "Not enabled",
                        );
                        await _refreshPushDebug();
                      },
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                text: "Request permission + register",
                neumorphicSoftUi: true,
              ),
              GhostButtonFactory.text(
                onPressed: _pushDebugLoading
                    ? null
                    : () async {
                        await getIt<IPushNotificationService>()
                            .registerTokenWithBackend();
                        if (!mounted) return;
                        ToastTheme.showInfoSimple(
                          context,
                          message: "Register attempted",
                        );
                        await _refreshPushDebug();
                      },
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                text: "Register now",
                neumorphicSoftUi: true,
              ),
              GhostButtonFactory.text(
                onPressed: _pushDebugLoading
                    ? null
                    : () async {
                        setState(() => _pushDebugLoading = true);
                        try {
                          final r = await getIt<IPushNotificationService>()
                              .sendTestPushToToken(_fcmTokenFull ?? "");
                          if (!mounted) return;
                          final disabled = r["disabled"] == true;
                          final success = r["success"];
                          final failure = r["failure"];
                          final err = r["error"];
                          final errCode =
                              err is Map ? (err["code"]?.toString()) : null;
                          final errMsg =
                              err is Map ? (err["message"]?.toString()) : null;
                          ToastTheme.showInfoSimple(
                            context,
                            message: disabled
                                ? "Server push disabled (Firebase Admin not initialized)"
                                : errCode != null
                                    ? "Send failed ($errCode): ${errMsg ?? "unknown"}"
                                    : "Test push sent to this device (success=$success, failure=$failure)",
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _pushDebugLoading = false);
                          }
                        }
                      },
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                text: "Send test push",
                neumorphicSoftUi: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertsExplainer(
    ThemeData theme, {
    required VoidCallback onClose,
    required AuthorizationStatus? pushStatus,
  }) {
    final fg = theme.colorScheme.onSurfaceVariant;
    final push = getIt<IPushNotificationService>();
    // If status hasn't loaded (or failed to load), assume notifications are not enabled
    // so the tip doesn't incorrectly promise push notifications.
    final needsEnable = push.isSupported &&
        (pushStatus == null ||
            pushStatus == AuthorizationStatus.denied ||
            pushStatus == AuthorizationStatus.notDetermined);
    final isDenied = pushStatus == AuthorizationStatus.denied;
    final isEnabled = push.isSupported && !needsEnable;
    final messageStyle = TextStyle(color: fg, fontSize: 14, height: 1.25);
    return UydoshInfoCalloutCard(
      onClose: onClose,
      message: needsEnable
          ? Text(
              isDenied
                  ? L10n.get("notifications_enable_in_settings")
                  : L10n.get("search_alert_permission"),
              style: messageStyle,
            )
          : L10n.text(
              isEnabled
                  ? "notifications_alerts_explainer_enabled"
                  : "notifications_alerts_explainer",
              style: messageStyle,
            ),
      extra: Padding(
        padding: const EdgeInsets.only(top: 6, left: 25),
        child: SizedBox(
          width: double.infinity,
          child: TextButtonThemed(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              if (needsEnable && !isDenied) {
                final ok = await push.requestPermissionAndRegister();
                if (!mounted) return;
                if (ok) {
                  ToastTheme.showSuccess(
                    context,
                    message: L10n.get("notifications_enabled"),
                  );
                } else {
                  ToastTheme.showInfo(
                    context,
                    message: L10n.get("notifications_enable_in_settings"),
                  );
                }
                await _loadPushStatus();
                return;
              }
              await openAppSettings();
            },
            child: Builder(
              builder: (context) {
                final color = DefaultTextStyle.of(context).style.color ??
                    Theme.of(context).colorScheme.primary;
                return IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        needsEnable && !isDenied
                            ? L10n.get("menu_enable_notifications")
                            : L10n.get("notifications_open_settings"),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        height: 1.5,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _DottedLinePainter(color: color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getIt<AppAnalyticsService>().logScreenView(screenName: "notifications");
    _loadPushStatus();
    _loadAlertsExplainerVisibility();
    _load();
    if (_pushDebugEnabled) {
      _refreshPushDebug();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning from iOS/Android settings (or any background), the user
    // may have toggled the system notifications permission. Re-check so the
    // "Enable notifications" card / explainer reflects the current status.
    if (state == AppLifecycleState.resumed) {
      _loadPushStatus();
      if (_pushDebugEnabled && _pushDebugExpanded) {
        _refreshPushDebug();
      }
    }
  }

  Future<void> _loadAlertsExplainerVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Persist default so it's visible/adjustable in device storage.
      if (!prefs.containsKey(
          TooltipsState.keyNotificationsAlertsExplainerDismissed)) {
        await prefs.setBool(
            TooltipsState.keyNotificationsAlertsExplainerDismissed, false);
      }
      final dismissed = prefs.getBool(
              TooltipsState.keyNotificationsAlertsExplainerDismissed) ??
          false;
      setStateIfMounted(() => _showAlertsExplainer = !dismissed);
    } catch (_) {
      // If prefs are unavailable, keep default (show).
    }
  }

  Future<void> _dismissAlertsExplainer() async {
    setState(() => _showAlertsExplainer = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          TooltipsState.keyNotificationsAlertsExplainerDismissed, true);
    } catch (_) {}
  }

  Future<void> _closeAlertsExplainerAnimated() async {
    if (_alertsExplainerClosing || !_showAlertsExplainer) return;
    const duration = Duration(milliseconds: 300);
    setState(() => _alertsExplainerClosing = true);
    await Future.delayed(duration);
    if (!mounted) return;
    await _dismissAlertsExplainer();
    if (!mounted) return;
    setStateIfMounted(() => _alertsExplainerClosing = false);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final alerts = await getIt<ISearchAlertService>().listAlerts();
      setStateIfMounted(() {
        _alerts = alerts;
        _loading = false;
      });
      ActiveSearchAlertsState().syncFromAlerts(alerts);
    } catch (e) {
      setStateIfMounted(() => _loading = false);
      if (e is DioException && e.response?.statusCode == 401) {
        ToastTheme.showError(
          context,
          message: L10n.get("search_alert_login_required"),
        );
        return;
      }
      ToastTheme.showError(context, message: L10n.get("error_generic"));
    }
  }

  Future<void> _toggleEnabled(SearchAlert a, bool enabled) async {
    final ok = await getIt<ISearchAlertService>().setAlertEnabled(
      alertId: a.id,
      enabled: enabled,
    );
    if (!ok) {
      ToastTheme.showError(context, message: L10n.get("error_generic"));
      return;
    }
    setStateIfMounted(() {
      _alerts = _alerts
          .map(
            (x) => x.id == a.id
                ? SearchAlert.fromJson(_toJson(x, enabled: enabled))
                : x,
          )
          .toList();
    });
    ActiveSearchAlertsState().syncFromAlerts(_alerts);
  }

  void _deleteAlertAnimated(
    SearchAlert a, {
    required int index,
    bool animatedListTile = true,
  }) {
    if (!mounted) return;
    if (_itemsBeingRemoved.contains(a.id)) return;

    const duration = Duration(milliseconds: 300);

    // Save for rollback *before* we mutate the list.
    if (!_optimisticallyRemoved.containsKey(a.id)) {
      _optimisticallyRemoved[a.id] = (alert: a, index: index);
    }

    if (animatedListTile) {
      setState(() {
        _itemsBeingRemoved.add(a.id);
      });

      // Optimistically remove from list after the animation finishes.
      Future.delayed(duration, () {
        setStateIfMounted(() {
          _itemsBeingRemoved.remove(a.id);
          _alerts = _alerts.where((x) => x.id != a.id).toList();
        });
        ActiveSearchAlertsState().syncFromAlerts(_alerts);
      });
    } else {
      // [Dismissible] already slid the row off — drop from data immediately.
      setState(() {
        _alerts = _alerts.where((x) => x.id != a.id).toList();
      });
      ActiveSearchAlertsState().syncFromAlerts(_alerts);
    }

    // Delete on backend; rollback on failure.
    () async {
      final ok = await getIt<ISearchAlertService>().deleteAlert(alertId: a.id);
      if (!mounted) return;
      if (ok) {
        _optimisticallyRemoved.remove(a.id);
        return;
      }

      final backup = _optimisticallyRemoved.remove(a.id);
      if (backup == null) return;

      setState(() {
        _itemsBeingRemoved.remove(a.id);
        final safeIndex = backup.index.clamp(0, _alerts.length);
        _alerts = List<SearchAlert>.from(_alerts)
          ..insert(safeIndex, backup.alert);
      });
      ActiveSearchAlertsState().syncFromAlerts(_alerts);
      ToastTheme.showError(context, message: L10n.get("error_generic"));
    }();
  }

  /// Trailing swipe (end→start, i.e. left in LTR) with stepped haptics like
  /// the messages inbox archive-swipe pattern.
  Widget _wrapSearchAlertSwipeDelete({
    required Widget child,
    required SearchAlert alert,
    required int alertIndex,
  }) {
    final ts = ThemeState();
    final swipeFgColor = ts.isBlueTheme ? Colors.white : AppColors.error;
    final swipeBgColor = ts.isBlueTheme
        ? AppColors.error.withValues(alpha: 0.38)
        : AppColors.error.withValues(alpha: 0.2);

    return Dismissible(
      key: ValueKey("search-alert-swipe-${alert.id}"),
      direction: DismissDirection.endToStart,
      onUpdate: (details) {
        if (_bulkWorking) return;
        final steps = 7;
        final currentStep = (details.progress * steps).floor();
        final lastStep = _alertSwipeHapticStepById[alert.id] ?? 0;

        if (currentStep > lastStep) {
          for (var i = lastStep; i < currentStep; i++) {
            HapticFeedbackUtils.selectionClick();
          }
          _alertSwipeHapticStepById[alert.id] = currentStep;
        } else if (currentStep <= 0 && lastStep != 0) {
          _alertSwipeHapticStepById[alert.id] = 0;
        }
      },
      confirmDismiss: (_) async {
        if (_bulkWorking) return false;
        return true;
      },
      onDismissed: (_) {
        _alertSwipeHapticStepById.remove(alert.id);
        HapticFeedbackUtils.tapticChain();
        _deleteAlertAnimated(
          alert,
          index: alertIndex,
          animatedListTile: false,
        );
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 22),
        decoration: BoxDecoration(
          color: swipeBgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeIcon(Icons.delete_outline, color: swipeFgColor),
            const SizedBox(width: 8),
            Text(
              L10n.get("delete"),
              style: TextStyle(
                color: swipeFgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: child,
    );
  }

  Future<void> _disableAllAlerts() async {
    if (_bulkWorking) return;
    if (_alerts.isEmpty) return;

    final confirmed = await CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: "notifications_disable_all_title",
      messageKey: "notifications_disable_all_message",
      confirmButtonKey: "disable",
      isDestructive: false,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _bulkWorking = true);
    try {
      var failed = 0;
      for (final a in _alerts) {
        if (a.enabled == false) continue;
        final ok = await getIt<ISearchAlertService>().setAlertEnabled(
          alertId: a.id,
          enabled: false,
        );
        if (!ok) failed++;
      }
      if (!mounted) return;

      if (failed > 0) {
        ToastTheme.showError(context, message: L10n.get("error_generic"));
      }

      setState(() {
        _alerts = _alerts
            .map((x) => SearchAlert.fromJson(_toJson(x, enabled: false)))
            .toList();
      });
      ActiveSearchAlertsState().syncFromAlerts(_alerts);
    } finally {
      setStateIfMounted(() => _bulkWorking = false);
    }
  }

  Future<void> _deleteAllAlerts() async {
    if (_bulkWorking) return;
    if (_alerts.isEmpty) return;

    final confirmed = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "notifications_delete_all_title",
      messageKey: "notifications_delete_all_message",
    );
    if (confirmed != true || !mounted) return;

    setState(() => _bulkWorking = true);
    try {
      var failed = 0;
      for (final a in List<SearchAlert>.from(_alerts)) {
        final ok =
            await getIt<ISearchAlertService>().deleteAlert(alertId: a.id);
        if (!ok) failed++;
      }
      if (!mounted) return;

      if (failed > 0) {
        ToastTheme.showError(context, message: L10n.get("error_generic"));
        await _load();
        return;
      }
      setState(() => _alerts = const []);
      ActiveSearchAlertsState().syncFromAlerts(_alerts);
    } finally {
      setStateIfMounted(() => _bulkWorking = false);
    }
  }

  int? _subwayStationIdForBottomSheet(SearchAlert a) {
    if (a.subwayStationId != null && a.subwayStationId! > 0) {
      return a.subwayStationId;
    }
    final ids = a.subwayStationIds;
    if (ids != null && ids.isNotEmpty) {
      return ids.first;
    }
    return null;
  }

  int? _subwayLineIdForBottomSheet(SearchAlert a) {
    final sid = _subwayStationIdForBottomSheet(a);
    if (sid != null && sid > 0) {
      final st = MetroCache.getStationById(sid);
      if (st != null) {
        return st.line;
      }
    }
    if (a.subwayLineId != null && a.subwayLineId! > 0) {
      return a.subwayLineId;
    }
    return null;
  }

  Map<String, dynamic> _toJson(SearchAlert a, {bool? enabled}) => {
        "id": a.id,
        "enabled": enabled ?? a.enabled,
        "listing_type_id": a.listingTypeId,
        "location_id": a.locationId,
        "subway_station_id": a.subwayStationId,
        "subway_station_ids": a.subwayStationIds,
        "subway_line_id": a.subwayLineId,
        "gender": a.gender,
        "min_price": a.minPrice,
        "max_price": a.maxPrice,
        "private_room": a.privateRoom,
        "with_photo": a.withPhoto,
      };

  Future<void> _openAlertResults(SearchAlert a) async {
    if (!mounted) return;

    // Sync global search filters so the search sheet / results summary match.
    final s = SearchFiltersState();

    final listingTypeId = a.listingTypeId ?? s.selectedListingTypeId;
    final locationId = a.locationId;

    final resolvedStationId = _subwayStationIdForBottomSheet(a);
    final resolvedLineId = _subwayLineIdForBottomSheet(a);
    final hasMultipleStations =
        a.subwayStationIds != null && (a.subwayStationIds?.length ?? 0) > 1;

    // Prefer the line filter when the alert targets multiple stations ("entire line").
    final subwayStationId = (resolvedStationId != null && !hasMultipleStations)
        ? resolvedStationId
        : null;
    final subwayLineId = (subwayStationId == null) ? resolvedLineId : null;

    // Best-effort keep persistent state aligned.
    // These setters are async; we don't want to block navigation on prefs writes.
    s.setListingTypeId(listingTypeId);
    s.setLocationIndex(locationId ?? 0);
    s.setSubwayLine(subwayLineId ?? 0);
    s.setStationId(subwayStationId ?? 0);
    if (a.gender != null) {
      s.setGender(a.gender!);
    }
    if (a.minPrice != null || a.maxPrice != null) {
      s.setPriceRange(a.minPrice ?? s.minPrice, a.maxPrice ?? s.maxPrice);
    }
    if (a.privateRoom != null) {
      s.setPrivateRoom(a.privateRoom!);
    }
    if (a.withPhoto != null) {
      s.setWithPhoto(a.withPhoto!);
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ListingsBloc(getIt<IListingService>()),
          child: HomeScreen(
            listingTypeId: listingTypeId,
            locationId: locationId,
            subwayStationId: subwayStationId,
            subwayLineId: subwayLineId,
            gender: a.gender,
            minPrice: a.minPrice,
            maxPrice: a.maxPrice,
            privateRoom: a.privateRoom,
            withPhoto: a.withPhoto,
            isSearchMode: true,
          ),
        ),
      ),
    );
  }

  Widget _iconTextBadge({
    required ThemeData theme,
    required String text,
    IconData? icon,
    Widget? leading,
    Color? color,
  }) {
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    final resolvedLeading =
        leading ?? (icon != null ? ThemeIcon(icon, size: 16, color: c) : null);
    assert(resolvedLeading != null, "Provide either icon or leading");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          resolvedLeading!,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: 13,
                height: 1.15,
                color: c,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryWidget(SearchAlert a, ThemeData theme) {
    final lang = L10n.currentLanguage;
    final chips = <Widget>[];

    if (a.listingTypeId != null) {
      chips.add(
        ListingTypeBadge(
          listingTypeCode: ListingTypeHelper.getCodeFromId(a.listingTypeId!),
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        ),
      );
    }
    if (a.gender != null) {
      final genderText = a.gender == 2 ? L10n.get("female") : L10n.get("male");
      final genderIcon = a.gender == 2 ? Icons.female : Icons.male;
      chips.add(
        _iconTextBadge(
          theme: theme,
          icon: genderIcon,
          text: genderText,
          color: a.gender == 2 ? AppColors.genderFemale : AppColors.genderMale,
        ),
      );
    }
    if (a.minPrice != null || a.maxPrice != null) {
      final min = (a.minPrice ?? a.maxPrice ?? 0).round();
      final max = (a.maxPrice ?? a.minPrice ?? 0).round();
      chips.add(
        PriceRangeBadge(
          minPrice: min,
          maxPrice: max,
          currencySymbol: "y.e.",
          showCurrency: false,
          showIcon: true,
          iconSize: 18,
          fontSize: 13,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          useTintBackground: true,
          tintAlpha: 0.1,
        ),
      );
    }

    if (a.locationId != null) {
      final name = LocationCache.getLocationName(a.locationId!, lang);
      chips.add(
        _iconTextBadge(
          theme: theme,
          icon: Icons.location_on_outlined,
          text: name,
          color: AppColors.error,
        ),
      );
    }
    // Use the same resolution logic as the edit sheet so the card matches
    // what the user sees when tapping "Edit".
    final resolvedStationId = _subwayStationIdForBottomSheet(a);
    final resolvedLineId = _subwayLineIdForBottomSheet(a);

    // If the alert targets multiple stations (typically "entire line"),
    // prefer rendering the line badge instead of an arbitrary first station.
    final hasMultipleStations =
        a.subwayStationIds != null && (a.subwayStationIds?.length ?? 0) > 1;

    if (resolvedLineId != null &&
        (resolvedStationId == null || hasMultipleStations)) {
      final name = MetroCache.getLineName(resolvedLineId, lang);
      final lineColor = AppColors.getMetroLineColor(resolvedLineId);
      final stationsCount =
          MetroCache.getStationsForLine(resolvedLineId).length;
      chips.add(
        _iconTextBadge(
          theme: theme,
          leading: MLetterIcon(size: 18, color: lineColor),
          text: L10n.plural(
            "entire_line_stations",
            stationsCount,
            params: {"line": name},
          ),
          color: lineColor,
        ),
      );
    } else if (resolvedStationId != null) {
      final stationId = resolvedStationId;
      final station = MetroCache.getStationById(stationId);
      final name = MetroCache.getStationDisplayName(stationId, lang);
      // Avoid rendering an "empty" metro badge when cache can't resolve the id.
      if (name.trim().isNotEmpty) {
        chips.add(
          _iconTextBadge(
            theme: theme,
            icon: Icons.train,
            text: name,
            color: station == null
                ? theme.colorScheme.onSurfaceVariant
                : AppColors.getMetroLineColor(station.line),
          ),
        );
      }
    }
    if ((a.privateRoom ?? false) == true) {
      chips.add(
        _iconTextBadge(
          theme: theme,
          icon: Icons.lock_outline,
          text: L10n.get("private_room"),
        ),
      );
    }
    if ((a.withPhoto ?? false) == true) {
      chips.add(
        _iconTextBadge(
          theme: theme,
          icon: Icons.photo_camera_outlined,
          text: L10n.get("search_filter_with_photo"),
        ),
      );
    }
    if (chips.isEmpty) {
      return Text(
        "-",
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tooltipsEnabled = TooltipsState().enabled;
    final push = getIt<IPushNotificationService>();
    final themeState = ThemeState();
    final useLiquidGlassAppBar =
        themeState.isBlueTheme || themeState.isLightTheme;
    final showPushEnableCard = _forceShowPushEnableCard ||
        (push.isSupported &&
            _pushStatus != null &&
            (_pushStatus == AuthorizationStatus.denied ||
                _pushStatus == AuthorizationStatus.notDetermined));
    final showAlertsExplainer =
        tooltipsEnabled && _showAlertsExplainer && !showPushEnableCard;

    final topInset = MediaQuery.of(context).padding.top;
    final contentTopPadding =
        useLiquidGlassAppBar ? (topInset + kToolbarHeight + 8) : 8.0;

    return Scaffold(
      extendBodyBehindAppBar: useLiquidGlassAppBar,
      appBar: _buildAppBar(useLiquidGlassAppBar),
      body: _loading
          ? const Center(child: HouseLoadingIndicator())
          : UydoshRefreshIndicator(
              onRefresh: () async {
                await Future.wait([_load(), _loadPushStatus()]);
              },
              child: _alerts.isEmpty
                  ? ListView(
                      padding:
                          EdgeInsets.fromLTRB(16, contentTopPadding, 16, 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (showPushEnableCard) ...[
                          _pushEnableCard(theme),
                          const SizedBox(height: 12),
                        ],
                        if (showAlertsExplainer)
                          Builder(
                            builder: (context) {
                              final explainer = _alertsExplainer(
                                theme,
                                onClose: _closeAlertsExplainerAnimated,
                                pushStatus: _pushStatus,
                              );
                              if (_alertsExplainerClosing) {
                                return RollUpFadeOut(child: explainer);
                              }
                              return explainer;
                            },
                          ),
                        if (_pushDebugEnabled) ...[
                          const SizedBox(height: 12),
                          _pushDebugPanel(theme),
                        ],
                        const SizedBox(height: 36),
                        ThemeIcon(
                          Icons.notifications_none,
                          size: 56,
                          color: ThemeState().isBlueTheme
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            L10n.get("notifications_empty"),
                            style: TextStyle(
                              color: ThemeState().isBlueTheme
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding:
                          EdgeInsets.fromLTRB(16, contentTopPadding, 16, 16),
                      itemCount:
                          _alerts.length + (showAlertsExplainer ? 1 : 0) + 1,
                      separatorBuilder: (_, i) =>
                          SizedBox(height: i == 0 ? 12 : 16),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showPushEnableCard) ...[
                                _pushEnableCard(theme),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        }
                        final adjustedIndex = i - 1;
                        final showExplainer = showAlertsExplainer;
                        if (showExplainer && adjustedIndex == 0) {
                          final explainer = _alertsExplainer(
                            theme,
                            onClose: _closeAlertsExplainerAnimated,
                            pushStatus: _pushStatus,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_alertsExplainerClosing)
                                RollUpFadeOut(child: explainer)
                              else
                                explainer,
                              if (_pushDebugEnabled) ...[
                                const SizedBox(height: 12),
                                _pushDebugPanel(theme),
                              ],
                            ],
                          );
                        }

                        final a =
                            _alerts[adjustedIndex - (showExplainer ? 1 : 0)];
                        final alertIndex =
                            adjustedIndex - (showExplainer ? 1 : 0);
                        final themeState = ThemeState();
                        final isRemoving = _itemsBeingRemoved.contains(a.id);
                        const duration = Duration(milliseconds: 300);

                        final card = Theme(
                          data: theme.copyWith(
                            cardTheme: theme.cardTheme.copyWith(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              surfaceTintColor: Colors.transparent,
                              color: themeState.isLightTheme
                                  ? themeState.cardColor
                                  : (themeState.isBlueTheme
                                      ? BlueThemeColors.surface
                                      : theme.colorScheme.surface),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          child: ListingDetailTileShell(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _bulkWorking
                                    ? null
                                    : () => _openAlertResults(a),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Tooltip(
                                            message: a.enabled
                                                ? L10n.get("disable")
                                                : L10n.get("enable"),
                                            child: InkResponse(
                                              radius: 22,
                                              onTap: _bulkWorking
                                                  ? null
                                                  : () {
                                                      HapticFeedbackUtils
                                                          .impact();
                                                      _toggleEnabled(
                                                        a,
                                                        !a.enabled,
                                                      );
                                                    },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: ThemeIcon(
                                                  a.enabled
                                                      ? Icons.notifications
                                                      : Icons
                                                          .notifications_off_outlined,
                                                  color: ThemeState()
                                                          .isBlueTheme
                                                      ? (a.enabled
                                                          ? Colors.white
                                                          : Colors.white
                                                              .withValues(
                                                              alpha: 0.45,
                                                            ))
                                                      : (a.enabled
                                                          ? theme.colorScheme
                                                              .primary
                                                          : theme.colorScheme
                                                              .onSurfaceVariant
                                                              .withValues(
                                                              alpha: 0.55,
                                                            )),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                0,
                                                4,
                                                48,
                                                4,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    a.enabled
                                                        ? L10n.get(
                                                            "notifications_alert_match_header",
                                                          )
                                                        : L10n.get(
                                                            "notifications_alert_match_header_paused",
                                                          ),
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      height: 1.2,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.1,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _summaryWidget(a, theme),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: TheDotDropMenuButton<String>(
                                          enabled: !_bulkWorking,
                                          padding: EdgeInsets.zero,
                                          visualScale: 0.8,
                                          onSelected: (value) {
                                            if (value == "toggle") {
                                              _toggleEnabled(a, !a.enabled);
                                            } else if (value == "delete") {
                                              _deleteAlertAnimated(
                                                a,
                                                index: alertIndex,
                                              );
                                            }
                                          },
                                          itemBuilder: (menuContext) {
                                            final isEnabled = a.enabled;
                                            return [
                                              PopupMenuItem(
                                                value: "toggle",
                                                child: UydoshPopupMenuItemRow(
                                                  icon: isEnabled
                                                      ? Icons
                                                          .notifications_off_outlined
                                                      : Icons
                                                          .notifications_active_outlined,
                                                  text: isEnabled
                                                      ? L10n.get("disable")
                                                      : L10n.get("enable"),
                                                  enabled: true,
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: "delete",
                                                child: UydoshPopupMenuItemRow(
                                                  icon: Icons.delete_outline,
                                                  text: L10n.get("delete"),
                                                  enabled: true,
                                                  destructive: true,
                                                ),
                                              ),
                                            ];
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        final wrapped = _wrapSearchAlertSwipeDelete(
                          child: card,
                          alert: a,
                          alertIndex: alertIndex,
                        );

                        if (!isRemoving) return wrapped;

                        // Collapse + fade only while removing (match Favorites animation).
                        return RollUpFadeOut(duration: duration, child: wrapped);
                      },
                    ),
            ),
      backgroundColor: ThemeState().backgroundColor,
    );
  }

  PreferredSizeWidget _buildAppBar(bool useLiquidGlassAppBar) {
    final appBarTheme = Theme.of(context).appBarTheme;

    return UydoshAppBar(
      leading: ThreeDAppBarIconButton.backLeading(context),
      title: Text(L10n.get("menu_notifications")),
      backgroundColor: useLiquidGlassAppBar
          ? liquidGlassAppBarMaterialColor(context)
          : appBarTheme.backgroundColor,
      surfaceTintColor: useLiquidGlassAppBar
          ? Colors.transparent
          : appBarTheme.surfaceTintColor,
      elevation: useLiquidGlassAppBar ? 0 : null,
      scrolledUnderElevation: useLiquidGlassAppBar ? 0 : null,
      shadowColor:
          useLiquidGlassAppBar ? Colors.transparent : appBarTheme.shadowColor,
      forceMaterialTransparency: useLiquidGlassAppBar,
      flexibleSpace:
          useLiquidGlassAppBar ? const LiquidGlassAppBarFlexibleSpace() : null,
      foregroundColor: appBarTheme.foregroundColor,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TheDotDropMenuButton<String>(
            enabled: !_loading && !_bulkWorking,
            onSelected: (value) {
              if (value == "disable_all") {
                _disableAllAlerts();
              } else if (value == "delete_all") {
                _deleteAllAlerts();
              }
            },
            itemBuilder: (menuContext) {
              final enabled = _alerts.isNotEmpty;
              return [
                PopupMenuItem(
                  value: "disable_all",
                  enabled: enabled,
                  child: UydoshPopupMenuItemRow(
                    icon: Icons.notifications_off_outlined,
                    text: L10n.get("notifications_disable_all"),
                    enabled: enabled,
                  ),
                ),
                PopupMenuItem(
                  value: "delete_all",
                  enabled: enabled,
                  child: UydoshPopupMenuItemRow(
                    icon: Icons.delete_outline,
                    text: L10n.get("notifications_delete_all"),
                    enabled: enabled,
                    destructive: true,
                  ),
                ),
              ];
            },
          ),
        ),
        if (_bulkWorking)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double dotRadius = 0.75;
    const double gap = 3.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double step = dotRadius * 2 + gap;
    final double y = size.height / 2;
    for (double x = dotRadius; x <= size.width; x += step) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
