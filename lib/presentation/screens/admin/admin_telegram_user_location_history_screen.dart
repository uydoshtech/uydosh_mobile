import "dart:math";
import "dart:typed_data";
import "dart:ui" as ui;

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
  /// Fits roughly 5 compact [_HistoryPointTile] rows before scrolling, leaving the
  /// rest of the screen for the map above.
  static const double _historyListVisibleHeight = 232;

  final IAdminTelegramMiniAppLocationService _service =
      getIt<IAdminTelegramMiniAppLocationService>();

  /// Decimal places used to merge consecutive near-duplicate points, admin-tunable
  /// via [_DedupPrecisionButton]; see [IAdminTelegramMiniAppLocationService.getHistory].
  static const List<int> _dedupPrecisionOptions = [2, 3, 4, 5, 6];

  TelegramMiniAppLocationHistoryPage? _page;
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedIndex;
  int _dedupPrecision = 4;

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
        dedupPrecision: _dedupPrecision,
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

  void _onDedupPrecisionChanged(int precision) {
    if (precision == _dedupPrecision) return;
    setState(() => _dedupPrecision = precision);
    _load();
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
    // Only block on the full-screen loading/error states for the very first
    // load. Once we have a page, keep the map/list mounted across reloads
    // (e.g. changing the merge-distance dropdown) instead of tearing them
    // down — besides being jarring, recreating the Yandex map view mid-layout
    // made its initial camera fit unreliable.
    if (_isLoading && _page == null) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (_errorMessage != null && _page == null) {
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _TelegramLocationHistoryMap(
                history: history,
                selectedIndex: _selectedIndex,
                onSelect: (index) => setState(() => _selectedIndex = index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        // Fixed height (not Expanded) so the map above gets most of the screen;
        // the rest of the timeline is still reachable by scrolling.
        SizedBox(
          height: _historyListVisibleHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
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
          _DedupPrecisionButton(
            precision: _dedupPrecision,
            options: _dedupPrecisionOptions,
            loading: _isLoading,
            onChanged: _onDedupPrecisionChanged,
          ),
          if (phone != null) const SizedBox(width: 8),
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

/// Compact control letting an admin tune how aggressively consecutive
/// near-duplicate points are merged into one row (see [TelegramMiniAppLocationHistoryPoint.repeatCount]).
class _DedupPrecisionButton extends StatelessWidget {
  const _DedupPrecisionButton({
    required this.precision,
    required this.options,
    required this.onChanged,
    this.loading = false,
  });

  final int precision;
  final List<int> options;
  final bool loading;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<int>(
      initialValue: precision,
      enabled: !loading,
      onSelected: onChanged,
      tooltip: L10n.get("admin_telegram_location_dedup_title"),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<int>(
            value: option,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  child: option == precision
                      ? const Icon(Icons.check, size: 16)
                      : null,
                ),
                Text(_formatDedupDistance(option)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeIcon(
              Icons.merge_type,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              L10n.getWithParams(
                "admin_telegram_location_dedup_button",
                params: {"distance": _formatDedupDistance(precision)},
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (loading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

/// Picks a Yandex MapKit zoom level that comfortably fits a bounding box of the
/// given lat/lon span (in degrees) with a little breathing room, so a user's
/// trail — however tightly or widely spread out — pans in close by default
/// instead of leaving the whole map zoomed out.
double _zoomForSpan({required double latSpan, required double lonSpan}) {
  final span = max(latSpan, lonSpan);
  const thresholds = <double>[
    0.0008,
    0.0015,
    0.003,
    0.006,
    0.012,
    0.025,
    0.05,
    0.1,
    0.2,
    0.4,
    0.8,
    1.6,
  ];
  var zoom = 17.0;
  for (final threshold in thresholds) {
    if (span <= threshold) return zoom;
    zoom -= 1;
  }
  return zoom;
}

/// Approximate ground distance (at the equator) that a difference of [precision]
/// decimal places in latitude/longitude represents. Purely a display label — the
/// actual merge math lives in the backend's `collapseConsecutiveDuplicates`.
String _formatDedupDistance(int precision) {
  final meters = 111320 / pow(10, precision);
  if (meters >= 1000) return "${(meters / 1000).toStringAsFixed(1)} km";
  if (meters >= 10) return "${meters.round()} m";
  return "${meters.toStringAsFixed(1)} m";
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
    final timeFormat = DateFormat("HH:mm");
    final isRepeated = point.repeatCount > 1;
    final timeLabel = isRepeated
        ? "${dateFormat.format(point.createdAt)} – ${timeFormat.format(point.lastSeenAt)}"
        : dateFormat.format(point.createdAt);

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${point.latitude.toStringAsFixed(6)}, "
                        "${point.longitude.toStringAsFixed(6)}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRepeated) ...[
                  _RepeatCountBadge(
                      count: point.repeatCount, selected: selected),
                  const SizedBox(width: 8),
                ],
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

/// Small "×N" chip marking a timeline entry that collapses N consecutive raw
/// pings which all landed on the exact same coordinates.
class _RepeatCountBadge extends StatelessWidget {
  const _RepeatCountBadge({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          "×$count",
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
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
  static const int _badgeIconSize = 72;
  static const double _badgeIconRadius = 24;

  YandexMapController? _controller;
  bool _didFitBounds = false;

  /// Numbered-badge icon bytes keyed by the 1-based label ("1", "2", ...).
  /// Built once up front since [BitmapDescriptor.fromBytes] needs raw PNG
  /// bytes synchronously at build time, but rendering them is async.
  final Map<String, Uint8List> _badgeIconBytes = {};
  bool _iconsReady = false;

  @override
  void initState() {
    super.initState();
    _generateBadgeIcons();
  }

  @override
  void didUpdateWidget(_TelegramLocationHistoryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _focusSelected();
    }
    if (oldWidget.history.length != widget.history.length) {
      _generateBadgeIcons();
    }
  }

  Future<void> _generateBadgeIcons() async {
    final labels = {
      for (var i = 0; i < widget.history.length; i++) "${i + 1}",
    };
    final entries = await Future.wait(
      labels.map(
        (label) async => MapEntry(label, await _createBadgeIconBytes(label)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _badgeIconBytes
        ..clear()
        ..addEntries(entries);
      _iconsReady = true;
    });
  }

  /// Draws a solid black circle (with a thin white outline for contrast
  /// against dark map tiles) with the ping's index in white, bold text.
  Future<Uint8List> _createBadgeIconBytes(String label) async {
    const size = _badgeIconSize;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const center = Offset(size / 2, size / 2);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _badgeIconRadius + 4, outlinePaint);

    final circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _badgeIconRadius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 16 : 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    try {
      final image = await picture.toImage(size, size);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
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

    // Centering on a manually picked zoom level (rather than asking the SDK to
    // fit a bounding box) keeps this independent of the map view's current
    // layout size — fitting a bounding box right as the view first appears
    // could read a stale/zero viewport size and zoom out to fit the whole
    // world instead of panning in close to the pins.
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2,
          ),
          zoom: _zoomForSpan(
            latSpan: (maxLat - minLat).abs(),
            lonSpan: (maxLon - minLon).abs(),
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
      if (_iconsReady)
        for (var i = 0; i < widget.history.length; i++)
          PlacemarkMapObject(
            mapId: MapObjectId("telegram_location_history_point_$i"),
            point: Point(
              latitude: widget.history[i].latitude,
              longitude: widget.history[i].longitude,
            ),
            opacity: 1,
            consumeTapEvents: true,
            onTap: (_, __) => widget.onSelect(i),
            zIndex: i == selected ? 1 : 0,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(
                  _badgeIconBytes["${i + 1}"]!,
                ),
                scale: i == selected ? 0.85 : 0.65,
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
