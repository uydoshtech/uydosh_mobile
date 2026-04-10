// ignore_for_file: eol_at_end_of_file

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/search_alert.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/theme_toggle.dart";

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}


class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  bool _bulkWorking = false;
  List<SearchAlert> _alerts = const [];

  @override
  void initState() {
    super.initState();
    _load();
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
  }

  Future<void> _deleteAlert(SearchAlert a) async {
    final ok = await getIt<ISearchAlertService>().deleteAlert(alertId: a.id);
    if (!mounted) return;
    if (!ok) {
      ToastTheme.showError(context, message: L10n.get("error_generic"));
      return;
    }
    setState(() => _alerts = _alerts.where((x) => x.id != a.id).toList());
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
        final ok = await getIt<ISearchAlertService>().deleteAlert(alertId: a.id);
        if (!ok) failed++;
      }
      if (!mounted) return;

      if (failed > 0) {
        ToastTheme.showError(context, message: L10n.get("error_generic"));
        await _load();
        return;
      }
      setState(() => _alerts = const []);
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

  Future<void> _openEditSheet(SearchAlert a) async {
    if (_bulkWorking) return;
    final filters = SearchFiltersState();
    await filters.initialize();
    if (!mounted) return;
    final snap = SearchFiltersSnapshot.capture(filters);
    bool? saved;
    try {
      final stationId = _subwayStationIdForBottomSheet(a);
      final lineId = _subwayLineIdForBottomSheet(a);
      saved = await SearchBottomSheetWidget.show(
        context,
        editingAlertId: a.id,
        currentListingTypeId: a.listingTypeId ?? 2,
        currentLocationId: a.locationId,
        currentSubwayStationId: stationId,
        currentSubwayLineId: lineId,
        currentGender: a.gender ?? 1,
        currentMinPrice: a.minPrice ?? 10,
        currentMaxPrice: a.maxPrice ?? 500,
        currentPrivateRoom: a.privateRoom ?? false,
        currentWithPhoto: a.withPhoto ?? false,
      );
    } finally {
      await filters.restoreToSnapshot(snap);
    }
    if (!mounted) return;
    if (saved != null && saved) {
      await _load();
    }
  }

  /// Foreground for popup menu rows (M3 uses [PopupMenuThemeData.labelTextStyle]).
  Color _popupMenuItemColor(BuildContext menuContext, {required bool enabled}) {
    final pop = Theme.of(menuContext).popupMenuTheme;
    final states =
        enabled ? const <WidgetState>{} : <WidgetState>{WidgetState.disabled};
    final fromLabel = pop.labelTextStyle?.resolve(states);
    if (fromLabel?.color != null) {
      return fromLabel!.color!;
    }
    final ts = pop.textStyle;
    final fallback = ts?.color;
    if (fallback != null) {
      return enabled ? fallback : fallback.withValues(alpha: 0.38);
    }
    return Theme.of(menuContext).colorScheme.primary;
  }

  TextStyle? _popupMenuItemTextStyle(BuildContext menuContext, {required bool enabled}) {
    final pop = Theme.of(menuContext).popupMenuTheme;
    final states =
        enabled ? const <WidgetState>{} : <WidgetState>{WidgetState.disabled};
    return pop.labelTextStyle?.resolve(states) ?? pop.textStyle;
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

  Widget _iconTextBadge({
    required ThemeData theme,
    IconData? icon,
    Widget? leading,
    required String text,
    Color? color,
  }) {
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    final resolvedLeading = leading ?? (icon != null ? ThemeIcon(icon, size: 16, color: c) : null);
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
    if (topRow.isNotEmpty) {
      lines.add(Wrap(spacing: 8, runSpacing: 8, children: topRow));
    }

    if (a.minPrice != null || a.maxPrice != null) {
      final min = (a.minPrice ?? a.maxPrice ?? 0).round();
      final max = (a.maxPrice ?? a.minPrice ?? 0).round();
      lines.add(
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
    if (a.subwayStationId != null) {
      final stationId = a.subwayStationId!;
      if (stationId > 0) {
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
    } else if (a.subwayLineId != null) {
      final name = MetroCache.getLineName(a.subwayLineId!, lang);
      final lineColor = AppColors.getMetroLineColor(a.subwayLineId!);
      final stationsCount = MetroCache.getStationsForLine(a.subwayLineId!).length;
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
    final isBlueTheme = ThemeState().isBlueTheme;

    final cardBorderColor = isBlueTheme
        ? Colors.white.withValues(alpha: 0.16)
        : (theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.08));

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("menu_notifications")),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ListenableBuilder(
              listenable: AnimationSettingsState(),
              builder: (context, _) {
                final enableMotion = AnimationSettingsState().uiAnimationsEnabled;
                final style =
                    enableMotion
                        ? null
                        : const AnimationStyle(
                            duration: Duration.zero,
                            reverseDuration: Duration.zero,
                          );

                return PopupMenuButton<String>(
                  enabled: !_loading && !_bulkWorking,
                  icon: const ThemeIcon(Icons.more_vert),
                  popUpAnimationStyle: style,
                  onSelected: (value) {
                    switch (value) {
                      case "disable_all":
                        _disableAllAlerts();
                        break;
                      case "delete_all":
                        _deleteAllAlerts();
                        break;
                    }
                  },
                  itemBuilder: (menuContext) {
                    final enabled = _alerts.isNotEmpty;
                    return [
                      PopupMenuItem(
                        value: "disable_all",
                        enabled: enabled,
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 20,
                              color: _popupMenuItemColor(
                                menuContext,
                                enabled: enabled,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              L10n.get("notifications_disable_all"),
                              style: _popupMenuItemTextStyle(
                                menuContext,
                                enabled: enabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete_all",
                        enabled: enabled,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color:
                                  enabled
                                      ? AppColors.errorDark
                                      : _popupMenuItemColor(
                                        menuContext,
                                        enabled: false,
                                      ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              L10n.get("notifications_delete_all"),
                              style:
                                  enabled
                                      ? _popupMenuItemTextStyle(
                                        menuContext,
                                        enabled: true,
                                      )?.copyWith(
                                        color: AppColors.errorDark,
                                      )
                                      : _popupMenuItemTextStyle(
                                        menuContext,
                                        enabled: false,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                );
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
      ),
      body: _loading
          ? const Center(child: HouseLoadingIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _alerts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 48),
                        ThemeIcon(
                          Icons.notifications_none,
                          size: 56,
                          color:
                              ThemeState().isBlueTheme
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            L10n.get("notifications_empty"),
                            style: TextStyle(
                              color:
                                  ThemeState().isBlueTheme
                                      ? Colors.white70
                                      : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final a = _alerts[i];
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: cardBorderColor, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ThemeIcon(
                                  a.enabled
                                      ? Icons.notifications_active_outlined
                                      : Icons.notifications_off_outlined,
                                  color: ThemeState().isBlueTheme
                                      ? Colors.white
                                      : (a.enabled
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: _bulkWorking ? null : () => _openEditSheet(a),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
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
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  // Pull the controls slightly away from the card edge.
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ThemeToggle(
                                        value: a.enabled,
                                        onChanged: (v) => _toggleEnabled(a, v),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        tooltip: L10n.get("delete"),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 44,
                                          minHeight: 44,
                                        ),
                                        icon: ThemeIcon(
                                          Icons.delete_outline,
                                          size: 32, // ~30% larger than default
                                          color: theme.colorScheme.error,
                                        ),
                                        onPressed: () => _deleteAlert(a),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      backgroundColor: ThemeState().isBlueTheme
          ? BlueThemeColors.surface
          : theme.colorScheme.surface,
    );
  }
}

