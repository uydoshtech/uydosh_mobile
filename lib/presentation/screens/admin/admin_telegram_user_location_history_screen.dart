import "dart:async" show unawaited;
import "dart:math";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/dio_api_error_message.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_telegram_mini_app_location_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_alert_dialog.dart";
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
  bool _isDeleting = false;
  /// Whether this user's history was wiped — reported back to the caller
  /// (the Telegram users list) via [Navigator.pop] so it can refresh.
  bool _didDeleteHistory = false;

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
    final hasHistory = (_page?.history ?? const []).isNotEmpty;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_didDeleteHistory);
      },
      child: Scaffold(
        appBar: UydoshAppBar(
          leading: ThreeDAppBarIconButton.backLeading(
            context,
            onPressed: () => Navigator.of(context).pop(_didDeleteHistory),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            if (hasHistory || _isDeleting)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  child: _isDeleting
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : ThreeDAppBarIconButton(
                          iconData: Icons.delete_outline,
                          onPressed: _confirmAndDeleteHistory,
                          semanticsLabel: L10n.get(
                            "admin_telegram_location_delete_tooltip",
                          ),
                        ),
                ),
              ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Future<void> _confirmAndDeleteHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return UydoshAlertDialog(
          scrollable: true,
          title: Text(L10n.get("admin_telegram_location_delete_confirm_title")),
          content: Text(L10n.get("admin_telegram_location_delete_confirm_body")),
          actions: [
            TextButtonThemed(
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(ctx).pop(false);
              },
              child: Text(L10n.get("cancel")),
            ),
            PrimaryButton(
              surfaceGradientBase: theme.colorScheme.error,
              textColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(ctx).pop(true);
              },
              child: Text(L10n.get("delete")),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setStateIfMounted(() => _isDeleting = true);
    try {
      final deletedCount = await _service.deleteHistory(
        telegramUserId: widget.telegramUserId,
      );
      _didDeleteHistory = true;
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.getWithParams(
          "admin_telegram_location_delete_done",
          params: {
            "locations_str": L10n.plural("telegram_locations_count", deletedCount),
          },
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: throwableUserMessage(e));
    } finally {
      setStateIfMounted(() => _isDeleting = false);
    }
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
    final dayGroups = _computeDayGroups(history);
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
                dayGroups: dayGroups,
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
          child: _buildTimelineList(context, history, dayGroups),
        ),
      ],
    );
  }

  /// Most-recent-first timeline, with a date divider inserted every time the
  /// calendar day changes so weeks of pings don't read as one undifferentiated
  /// scroll — mirrors the day-colored grouping drawn on the map above.
  Widget _buildTimelineList(
    BuildContext context,
    List<TelegramMiniAppLocationHistoryPoint> history,
    _DayGroups dayGroups,
  ) {
    final rows = <_TimelineRow>[];
    int? lastGroupIndex;
    for (var i = history.length - 1; i >= 0; i--) {
      final groupIndex = dayGroups.groupIndexForPoint[i];
      if (groupIndex != lastGroupIndex) {
        rows.add(
          _TimelineRow.header(
            date: history[i].createdAt,
            color: dayGroups.colorForPoint[i],
          ),
        );
        lastGroupIndex = groupIndex;
      }
      rows.add(_TimelineRow.point(i));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        final header = row.headerDate;
        if (header != null) {
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 10, bottom: 2),
            child: _DayHeader(date: header, color: row.headerColor!),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _HistoryPointTile(
            index: row.pointIndex!,
            point: history[row.pointIndex!],
            selected: _selectedIndex == row.pointIndex,
            onTap: () => setState(() => _selectedIndex = row.pointIndex),
          ),
        );
      },
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    TelegramMiniAppLocationHistoryPage page,
  ) {
    final theme = Theme.of(context);
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

/// Distinct, saturated-enough-for-white-text colors cycled across consecutive
/// calendar days so a user's trail reads as separate daily segments instead
/// of one continuous line spanning days or weeks.
const List<Color> _dayColorPalette = [
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFF6A1B9A),
  Color(0xFFEF6C00),
  Color(0xFF00838F),
  Color(0xFF4E342E),
  Color(0xFF283593),
  Color(0xFF9E9D24),
  Color(0xFFAD1457),
];

/// Precomputed per-point day-bucket assignment for a chronological (oldest-
/// first) history list, shared by the timeline list (date dividers) and the
/// map (one polyline segment + badge color per day) so both stay in sync.
class _DayGroups {
  const _DayGroups({
    required this.groupIndexForPoint,
    required this.colorForPoint,
    required this.chronologicalGroups,
  });

  /// Same length as the history list; a 0-based, chronologically increasing
  /// id for the calendar day each point falls on.
  final List<int> groupIndexForPoint;

  /// Same length as the history list; the color assigned to that point's day,
  /// cycling through [_dayColorPalette].
  final List<Color> colorForPoint;

  /// Original history indices bucketed by day, in chronological order — used
  /// to draw one polyline per day instead of a single line spanning the
  /// user's entire history.
  final List<List<int>> chronologicalGroups;
}

_DayGroups _computeDayGroups(List<TelegramMiniAppLocationHistoryPoint> points) {
  final groupIndexForPoint = List<int>.filled(points.length, 0);
  final colorForPoint =
      List<Color>.filled(points.length, _dayColorPalette.first);
  final chronologicalGroups = <List<int>>[];
  DateTime? currentDay;
  for (var i = 0; i < points.length; i++) {
    final createdAt = points[i].createdAt;
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    if (currentDay == null || day != currentDay) {
      chronologicalGroups.add([]);
      currentDay = day;
    }
    final groupIndex = chronologicalGroups.length - 1;
    chronologicalGroups[groupIndex].add(i);
    groupIndexForPoint[i] = groupIndex;
    colorForPoint[i] = _dayColorPalette[groupIndex % _dayColorPalette.length];
  }
  return _DayGroups(
    groupIndexForPoint: groupIndexForPoint,
    colorForPoint: colorForPoint,
    chronologicalGroups: chronologicalGroups,
  );
}

/// A single row in the timeline list: either a day-divider header or a point
/// tile, so [ListView.builder] can lazily build a flat list that still reads
/// as day-grouped sections.
class _TimelineRow {
  const _TimelineRow.header({required DateTime date, required Color color})
      : headerDate = date,
        headerColor = color,
        pointIndex = null;

  const _TimelineRow.point(int index)
      : pointIndex = index,
        headerDate = null,
        headerColor = null;

  final DateTime? headerDate;
  final Color? headerColor;
  final int? pointIndex;
}

/// Date divider shown above the first (most recent) entry of each calendar
/// day in the timeline, colored to match that day's map badges/polyline.
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.color});

  final DateTime date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat("EEEE, d MMM yyyy").format(date),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(color: theme.colorScheme.outlineVariant),
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
    required this.dayGroups,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TelegramMiniAppLocationHistoryPoint> history;
  final _DayGroups dayGroups;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  State<_TelegramLocationHistoryMap> createState() =>
      _TelegramLocationHistoryMapState();
}

class _TelegramLocationHistoryMapState
    extends State<_TelegramLocationHistoryMap> {
  // Rendered at a high backing resolution and then scaled down (see
  // [_unselectedBadgeScale]/[_selectedBadgeScale]) so the numbers stay crisp
  // instead of blurring into an illegible smudge once shrunk onto the map.
  static const int _badgeIconSize = 108;
  static const double _badgeIconRadius = 36;
  static const double _unselectedBadgeScale = 0.5;
  static const double _selectedBadgeScale = 0.65;

  YandexMapController? _controller;
  bool _didFitBounds = false;

  /// Numbered-badge icon bytes keyed by history index. Built once up front
  /// since [BitmapDescriptor.fromBytes] needs raw PNG bytes synchronously at
  /// build time, but rendering them is async.
  final Map<int, Uint8List> _badgeIconBytes = {};
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
    if (!identical(oldWidget.history, widget.history)) {
      _generateBadgeIcons();
    }
  }

  Future<void> _generateBadgeIcons() async {
    final history = widget.history;
    final colors = widget.dayGroups.colorForPoint;
    final entries = await Future.wait([
      for (var i = 0; i < history.length; i++)
        _createBadgeIconBytes(label: "${i + 1}", color: colors[i])
            .then((bytes) => MapEntry(i, bytes)),
    ]);
    if (!mounted) return;
    setState(() {
      _badgeIconBytes
        ..clear()
        ..addEntries(entries);
      _iconsReady = true;
    });
  }

  /// Draws a solid circle — filled with that ping's day color, with a thick
  /// white outline for contrast against both light and dark map tiles — with
  /// the ping's index in bold white text.
  Future<Uint8List> _createBadgeIconBytes({
    required String label,
    required Color color,
  }) async {
    const size = _badgeIconSize;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const center = Offset(size / 2, size / 2);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _badgeIconRadius + 6, outlinePaint);

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _badgeIconRadius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 28 : 34,
          fontWeight: FontWeight.w900,
          height: 1,
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
    if (_didFitBounds) return;
    _didFitBounds = true;
    // The native map view needs a frame to finish attaching after creation —
    // calling moveCamera synchronously here is unreliable and can leave the
    // map at its default, fully-zoomed-out world view (see YandexMapWidget's
    // own onMapCreated handler, which follows the same pattern).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_fitBounds());
    });
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

    final selected = widget.selectedIndex;

    // One polyline segment per calendar day — colors match that day's badges
    // — instead of a single line connecting every ping across the user's
    // entire history, which reads as unbroken noise once it spans days/weeks.
    final polylines = <PolylineMapObject>[
      for (var g = 0; g < widget.dayGroups.chronologicalGroups.length; g++)
        if (widget.dayGroups.chronologicalGroups[g].length > 1)
          PolylineMapObject(
            mapId: MapObjectId("telegram_location_history_polyline_$g"),
            polyline: Polyline(
              points: [
                for (final index in widget.dayGroups.chronologicalGroups[g])
                  Point(
                    latitude: widget.history[index].latitude,
                    longitude: widget.history[index].longitude,
                  ),
              ],
            ),
            strokeColor:
                _dayColorPalette[g % _dayColorPalette.length]
                    .withValues(alpha: 0.8),
            strokeWidth: 3,
          ),
    ];

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
                image: BitmapDescriptor.fromBytes(_badgeIconBytes[i]!),
                scale: i == selected
                    ? _selectedBadgeScale
                    : _unselectedBadgeScale,
              ),
            ),
          ),
    ];

    return YandexMap(
      mapObjects: [...polylines, ...placemarks],
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
