import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/dio_api_error_message.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_telegram_mini_app_location_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:yandex_mapkit/yandex_mapkit.dart";

/// Admin screen: chronological device-location history for a single Telegram
/// Mini App visitor — a map of their reported pings plus a matching timeline
/// list below it.
class AdminTelegramUserLocationHistoryScreen extends StatefulWidget {
  const AdminTelegramUserLocationHistoryScreen({
    required this.telegramUserId,
    this.telegramUsername,
    super.key,
  });

  final String telegramUserId;
  final String? telegramUsername;

  @override
  State<AdminTelegramUserLocationHistoryScreen> createState() =>
      _AdminTelegramUserLocationHistoryScreenState();
}

class _AdminTelegramUserLocationHistoryScreenState
    extends State<AdminTelegramUserLocationHistoryScreen> {
  final IAdminTelegramMiniAppLocationService _service =
      getIt<IAdminTelegramMiniAppLocationService>();

  TelegramMiniAppLocationHistoryPage? _page;
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getHistory(
        telegramUserId: widget.telegramUserId,
      );
      setStateIfMounted(() {
        _page = result;
        _selectedIndex =
            result.history.isEmpty ? null : result.history.length - 1;
      });
    } catch (e) {
      setStateIfMounted(() {
        _errorMessage = throwableUserMessage(e);
      });
    } finally {
      setStateIfMounted(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _page?.telegramUsername ?? widget.telegramUsername;
    final title = username != null ? "@$username" : "#${widget.telegramUserId}";

    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (_errorMessage != null) {
      return UydoshErrorRetryColumn(
        title: L10n.get("admin_telegram_locations_error"),
        message: _errorMessage,
        onRetry: _load,
        retryLabel: L10n.get("admin_district_heatmap_retry"),
      );
    }
    final page = _page;
    final history = page?.history ?? const [];
    if (page == null || history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            L10n.get("admin_telegram_location_history_empty"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryHeader(context, page),
        SizedBox(
          height: 300,
          child: _TelegramLocationHistoryMap(
            history: history,
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              // Most-recent-first for the timeline list; the map still draws
              // the polyline in chronological (oldest-first) order.
              final reversedIndex = history.length - 1 - index;
              final point = history[reversedIndex];
              return _HistoryPointTile(
                index: reversedIndex,
                point: point,
                selected: _selectedIndex == reversedIndex,
                onTap: () => setState(() => _selectedIndex = reversedIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    TelegramMiniAppLocationHistoryPage page,
  ) {
    final theme = Theme.of(context);
    final phone = page.history
        .map((h) => h.phoneNumber)
        .firstWhere((p) => p != null, orElse: () => null);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          ThemeIcon(
            Icons.route_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              L10n.getWithParams(
                "admin_telegram_locations_ping_count",
                params: {"count": "${page.total}"},
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (phone != null)
            Row(
              children: [
                ThemeIcon(Icons.phone,
                    size: 16, color: theme.colorScheme.tertiary),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryPointTile extends StatelessWidget {
  const _HistoryPointTile({
    required this.index,
    required this.point,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final TelegramMiniAppLocationHistoryPoint point;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("d MMM yyyy, HH:mm");

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(point.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${point.latitude.toStringAsFixed(6)}, "
                        "${point.longitude.toStringAsFixed(6)}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (point.phoneNumber != null)
                  ThemeIcon(Icons.phone,
                      size: 16, color: theme.colorScheme.tertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal, purpose-built Yandex map for plotting a single user's chronological
/// location pings. Deliberately independent from [YandexMapWidget] (which is
/// tightly coupled to listing/university/metro pins) to avoid overloading that
/// shared production widget with an unrelated data shape.
class _TelegramLocationHistoryMap extends StatefulWidget {
  const _TelegramLocationHistoryMap({
    required this.history,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TelegramMiniAppLocationHistoryPoint> history;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  State<_TelegramLocationHistoryMap> createState() =>
      _TelegramLocationHistoryMapState();
}

class _TelegramLocationHistoryMapState
    extends State<_TelegramLocationHistoryMap> {
  YandexMapController? _controller;
  bool _didFitBounds = false;

  @override
  void didUpdateWidget(_TelegramLocationHistoryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _focusSelected();
    }
  }

  void _onMapCreated(YandexMapController controller) {
    _controller = controller;
    if (!_didFitBounds) {
      _didFitBounds = true;
      _fitBounds();
    }
  }

  Future<void> _fitBounds() async {
    final controller = _controller;
    if (controller == null || widget.history.isEmpty) return;

    var minLat = widget.history.first.latitude;
    var maxLat = widget.history.first.latitude;
    var minLon = widget.history.first.longitude;
    var maxLon = widget.history.first.longitude;
    for (final point in widget.history) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLon = point.longitude < minLon ? point.longitude : minLon;
      maxLon = point.longitude > maxLon ? point.longitude : maxLon;
    }
    final latPadding = ((maxLat - minLat).abs() * 0.2).clamp(0.003, 0.2);
    final lonPadding = ((maxLon - minLon).abs() * 0.2).clamp(0.003, 0.2);

    await controller.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(
          BoundingBox(
            northEast: Point(
              latitude: maxLat + latPadding,
              longitude: maxLon + lonPadding,
            ),
            southWest: Point(
              latitude: minLat - latPadding,
              longitude: minLon - lonPadding,
            ),
          ),
        ),
      ),
      animation:
          const MapAnimation(type: MapAnimationType.smooth, duration: 0.4),
    );
  }

  Future<void> _focusSelected() async {
    final controller = _controller;
    final index = widget.selectedIndex;
    if (controller == null || index == null || index >= widget.history.length) {
      return;
    }
    final point = widget.history[index];
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: point.latitude, longitude: point.longitude),
          zoom: 15,
        ),
      ),
      animation:
          const MapAnimation(type: MapAnimationType.smooth, duration: 0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebFallback(context);
    }

    final theme = Theme.of(context);
    final selected = widget.selectedIndex;

    final polyline = PolylineMapObject(
      mapId: const MapObjectId("telegram_location_history_polyline"),
      polyline: Polyline(
        points: widget.history
            .map((p) => Point(latitude: p.latitude, longitude: p.longitude))
            .toList(),
      ),
      strokeColor: theme.colorScheme.primary.withValues(alpha: 0.75),
      strokeWidth: 3,
    );

    final placemarks = <PlacemarkMapObject>[
      for (var i = 0; i < widget.history.length; i++)
        PlacemarkMapObject(
          mapId: MapObjectId("telegram_location_history_point_$i"),
          point: Point(
            latitude: widget.history[i].latitude,
            longitude: widget.history[i].longitude,
          ),
          opacity: i == selected ? 1 : 0.85,
          consumeTapEvents: true,
          onTap: (_, __) => widget.onSelect(i),
          text: PlacemarkText(
            text: "${i + 1}",
            style: PlacemarkTextStyle(
              size: i == selected ? 13 : 11,
              color: i == selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              outlineColor: theme.colorScheme.surface,
            ),
          ),
        ),
    ];

    return YandexMap(
      mapObjects: [polyline, ...placemarks],
      onMapCreated: _onMapCreated,
    );
  }

  Widget _buildWebFallback(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(
                Icons.map_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                L10n.get("admin_telegram_location_history_map_web_unavailable"),
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
