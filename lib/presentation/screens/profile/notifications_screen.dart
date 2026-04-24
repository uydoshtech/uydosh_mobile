// ignore_for_file: eol_at_end_of_file

import "package:dio/dio.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart" show kDebugMode;
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
import "package:uy_dosh/presentation/widgets/common/the_dot_drop_menu_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_info_callout_card.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_popup_menu.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

const bool _pushDebugEnabled = kDebugMode;

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
  final Set<int> _itemsBeingRemoved =
      {}; // Track items being removed for animation
  final Map<int, ({SearchAlert alert, int index})> _optimisticallyRemoved =
      {}; // Rollback buffer for optimistic removals

  AuthorizationStatus? _pushStatus;
  bool _pushStatusLoading = false;

  bool _pushDebugExpanded = false;
  bool _pushDebugLoading = false;
  String? _pushPermission;
  String? _apnsTokenPreview;
  String? _fcmTokenPreview;
  bool _hasBackendSessionToken = false;

  Future<void> _loadPushStatus() async {
    final push = getIt<IPushNotificationService>();
    if (!push.isSupported) return;
    setState(() => _pushStatusLoading = true);
    try {
      final status = await push.getNotificationStatus();
      if (!mounted) return;
      setState(() => _pushStatus = status);
    } finally {
      if (!mounted) return;
      setState(() => _pushStatusLoading = false);
    }
  }

  Widget _pushEnableCard(ThemeData theme) {
    final push = getIt<IPushNotificationService>();
    if (!push.isSupported) return const SizedBox.shrink();

    final status = _pushStatus;
    if (status == null) return const SizedBox.shrink();
    final needsEnable = status == AuthorizationStatus.denied ||
        status == AuthorizationStatus.notDetermined;
    if (!needsEnable) return const SizedBox.shrink();

    final bg =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final fg = theme.colorScheme.onSurfaceVariant;
    final isDenied = status == AuthorizationStatus.denied;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 18,
                  color: fg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  L10n.get("menu_enable_notifications"),
                  style: TextStyle(
                    color: fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_pushStatusLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isDenied
                ? L10n.get("notifications_enable_in_settings")
                : L10n.get("search_alert_permission"),
            style: TextStyle(
              color: fg,
              fontSize: 13.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _pushStatusLoading
                  ? null
                  : () async {
                      HapticFeedbackUtils.impact();
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
                          message: L10n.get("notifications_enable_in_settings"),
                        );
                      }
                      await _loadPushStatus();
                    },
              icon: Icon(
                isDenied
                    ? Icons.settings_outlined
                    : Icons.notifications_outlined,
              ),
              label: Text(
                isDenied
                    ? L10n.get("notifications_open_settings")
                    : L10n.get("menu_enable_notifications"),
              ),
            ),
          ),
        ],
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

      if (!mounted) return;
      setState(() {
        _pushPermission = status?.name;
        _apnsTokenPreview = preview(apns);
        _fcmTokenPreview = preview(fcm);
        _hasBackendSessionToken =
            backendToken != null && backendToken.trim().isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pushPermission = "error";
        _apnsTokenPreview = null;
        _fcmTokenPreview = null;
        _hasBackendSessionToken = false;
      });
    } finally {
      if (!mounted) return;
      setState(() => _pushDebugLoading = false);
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
              OutlinedButton(
                onPressed: _pushDebugLoading
                    ? null
                    : () {
                        HapticFeedbackUtils.impact();
                        _refreshPushDebug();
                      },
                child: const Text("Refresh"),
              ),
              OutlinedButton(
                onPressed: _pushDebugLoading
                    ? null
                    : () async {
                        HapticFeedbackUtils.impact();
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
                child: const Text("Request permission + register"),
              ),
              OutlinedButton(
                onPressed: _pushDebugLoading
                    ? null
                    : () async {
                        HapticFeedbackUtils.impact();
                        await getIt<IPushNotificationService>()
                            .registerTokenWithBackend();
                        if (!mounted) return;
                        ToastTheme.showInfoSimple(
                          context,
                          message: "Register attempted",
                        );
                        await _refreshPushDebug();
                      },
                child: const Text("Register now"),
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
          child: TextButton(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              HapticFeedbackUtils.impact();
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
      if (!mounted) return;
      setState(() => _showAlertsExplainer = !dismissed);
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final alerts = await getIt<ISearchAlertService>().listAlerts();
      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _loading = false;
      });
      ActiveSearchAlertsState().syncFromAlerts(alerts);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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
    if (!mounted) return;
    if (!ok) {
      ToastTheme.showError(context, message: L10n.get("error_generic"));
      return;
    }
    setState(() {
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

  Future<void> _deleteAlert(SearchAlert a) async {
    final ok = await getIt<ISearchAlertService>().deleteAlert(alertId: a.id);
    if (!mounted) return;
    if (!ok) {
      ToastTheme.showError(context, message: L10n.get("error_generic"));
      return;
    }
    setState(() => _alerts = _alerts.where((x) => x.id != a.id).toList());
    ActiveSearchAlertsState().syncFromAlerts(_alerts);
  }

  void _deleteAlertAnimated(SearchAlert a, {required int index}) {
    if (!mounted) return;
    if (_itemsBeingRemoved.contains(a.id)) return;

    const duration = Duration(milliseconds: 300);

    // Save for rollback *before* we mutate the list.
    if (!_optimisticallyRemoved.containsKey(a.id)) {
      _optimisticallyRemoved[a.id] = (alert: a, index: index);
    }

    setState(() {
      _itemsBeingRemoved.add(a.id);
    });

    // Optimistically remove from list after the animation finishes.
    Future.delayed(duration, () {
      if (!mounted) return;
      setState(() {
        _itemsBeingRemoved.remove(a.id);
        _alerts = _alerts.where((x) => x.id != a.id).toList();
      });
      ActiveSearchAlertsState().syncFromAlerts(_alerts);
    });

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
      if (mounted) setState(() => _bulkWorking = false);
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
      if (mounted) setState(() => _bulkWorking = false);
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
    final lines = <Widget>[];

    final topRow = <Widget>[];
    if (a.listingTypeId != null) {
      topRow.add(
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
      topRow.add(
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
      topRow.add(
        PriceRangeBadge(
          minPrice: min,
          maxPrice: max,
          currencySymbol: "y.e.",
          showIcon: true,
          iconSize: 18,
          fontSize: 13,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        ),
      );
    }
    if (topRow.isNotEmpty) {
      lines.add(Wrap(spacing: 8, runSpacing: 8, children: topRow));
    }

    final locationAndMetro = <Widget>[];
    if (a.locationId != null) {
      final name = LocationCache.getLocationName(a.locationId!, lang);
      locationAndMetro.add(
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
      locationAndMetro.add(
        _iconTextBadge(
          theme: theme,
          leading: MLetterIcon(size: 18, color: lineColor),
          text: L10n.getWithParams(
            "entire_line_stations",
            params: {"line": name, "count": "$stationsCount"},
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
        locationAndMetro.add(
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
    if (locationAndMetro.isNotEmpty) {
      lines.add(Wrap(spacing: 8, runSpacing: 8, children: locationAndMetro));
    }
    if ((a.privateRoom ?? false) == true) {
      lines.add(
        _iconTextBadge(
          theme: theme,
          icon: Icons.lock_outline,
          text: L10n.get("private_room"),
        ),
      );
    }
    if ((a.withPhoto ?? false) == true) {
      lines.add(
        _iconTextBadge(
          theme: theme,
          icon: Icons.photo_camera_outlined,
          text: L10n.get("search_filter_with_photo"),
        ),
      );
    }
    if (lines.isEmpty) {
      return Text(
        "-",
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    const vGap = 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines.length, (i) {
        final w = lines[i];
        if (i == 0) return w;
        return Padding(
          padding: const EdgeInsets.only(top: vGap),
          child: w,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tooltipsEnabled = TooltipsState().enabled;
    final push = getIt<IPushNotificationService>();
    final themeState = ThemeState();
    final useLiquidGlassAppBar =
        themeState.isBlueTheme || themeState.isLightTheme;
    final showPushEnableCard = push.isSupported &&
        _pushStatus != null &&
        (_pushStatus == AuthorizationStatus.denied ||
            _pushStatus == AuthorizationStatus.notDetermined);
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
                          _alertsExplainer(
                            theme,
                            onClose: _dismissAlertsExplainer,
                            pushStatus: _pushStatus,
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _alertsExplainer(
                                theme,
                                onClose: _dismissAlertsExplainer,
                                pushStatus: _pushStatus,
                              ),
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
                                          ThemeIcon(
                                            a.enabled
                                                ? Icons.notifications
                                                : Icons
                                                    .notifications_none_outlined,
                                            color: ThemeState().isBlueTheme
                                                ? Colors.white
                                                : (a.enabled
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme
                                                        .onSurfaceVariant),
                                          ),
                                          const SizedBox(width: 12),
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
                                          icon: CupertinoIcons.pencil_circle,
                                          padding: EdgeInsets.zero,
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

                        if (!isRemoving) return card;

                        // Collapse + fade only while removing (match Favorites animation).
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 1.0, end: 0.0),
                          duration: duration,
                          curve: Curves.easeInOutCubic,
                          builder: (context, t, child) {
                            return ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: t,
                                child: Opacity(
                                  opacity: t.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: card,
                        );
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
