// ignore_for_file: eol_at_end_of_file

import "package:flutter/material.dart";
import "package:dio/dio.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/search_alert.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}


class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
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
      final station = MetroCache.getStationById(a.subwayStationId!);
      final name = MetroCache.getStationDisplayName(a.subwayStationId!, lang);
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
    if (a.minPrice != null || a.maxPrice != null) {
      final min = (a.minPrice ?? a.maxPrice ?? 0).round();
      final max = (a.maxPrice ?? a.minPrice ?? 0).round();
      lines.add(
        PriceRangeBadge(
          minPrice: min,
          maxPrice: max,
          currencySymbol: "y.e.",
          fontSize: 13,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        ),
      );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("menu_notifications")),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _summaryWidget(a, theme),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Switch.adaptive(
                                      value: a.enabled,
                                      onChanged: (v) => _toggleEnabled(a, v),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip: L10n.get("delete"),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      icon: ThemeIcon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      onPressed: () => _deleteAlert(a),
                                    ),
                                  ],
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

