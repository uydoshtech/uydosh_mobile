// ignore_for_file: eol_at_end_of_file

import "package:flutter/material.dart";
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

  String _summary(SearchAlert a) {
    final lang = L10n.currentLanguage;
    final parts = <String>[];
    if (a.locationId != null) {
      final name = LocationCache.getLocationName(a.locationId!, lang);
      parts.add("${L10n.get("location")}: $name");
    } else if (a.subwayStationId != null) {
      final name = MetroCache.getStationDisplayName(a.subwayStationId!, lang);
      parts.add("${L10n.get("metro")}: $name");
    } else if (a.subwayLineId != null) {
      final name = MetroCache.getLineName(a.subwayLineId!, lang);
      parts.add("${L10n.get("metro_line")}: $name");
    }
    if (a.gender != null) parts.add("${L10n.get("gender")}: ${a.gender}");
    if (a.minPrice != null || a.maxPrice != null) {
      parts.add("${L10n.get("price")}: ${a.minPrice ?? "-"} - ${a.maxPrice ?? "-"}");
    }
    if ((a.privateRoom ?? false) == true) {
      parts.add(L10n.get("search_filter_private_room"));
    }
    if ((a.withPhoto ?? false) == true) {
      parts.add(L10n.get("search_filter_with_photo"));
    }
    return parts.isEmpty ? "-" : parts.join(" · ");
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
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          Icons.notifications_none,
                          size: 56,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            L10n.get("notifications_empty"),
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
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
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              a.enabled
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_off_outlined,
                              color: a.enabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              L10n.get("search_listings"),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(_summary(a)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: a.enabled,
                                  onChanged: (v) => _toggleEnabled(a, v),
                                ),
                                IconButton(
                                  tooltip: L10n.get("delete"),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () => _deleteAlert(a),
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

