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
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
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
  /// The single chronological day-group index (see [_DayGroups]) currently
  /// expanded in the timeline list — and the only day plotted on the map.
  /// Reset on every load so only the most recent day starts open/visible.
  int? _expandedDayGroup;
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
      final groupCount =
          _computeDayGroups(result.history).chronologicalGroups.length;
      setStateIfMounted(() {
        _page = result;
        _selectedIndex =
            result.history.isEmpty ? null : result.history.length - 1;
        // Most-recent day is the highest chronological group index.
        _expandedDayGroup = groupCount == 0 ? null : groupCount - 1;
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
                      ? Padding(
                          padding: const EdgeInsets.all(14),
                          child: UydoshInlineSpinner(
                            color: Theme.of(context).colorScheme.onSurface,
                            dimension: 20,
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
                expandedGroupIndex: _expandedDayGroup,
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

  /// Most-recent-day-first list of collapsible day sections — mirrors the
  /// day-colored grouping drawn on the map above. Accordion-style: expanding
  /// a day collapses whichever one was open before (since only one day's
  /// pings are ever plotted on the map at a time), and tapping the open day
  /// again collapses it.
  Widget _buildTimelineList(
    BuildContext context,
    List<TelegramMiniAppLocationHistoryPoint> history,
    _DayGroups dayGroups,
  ) {
    final groupCount = dayGroups.chronologicalGroups.length;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: groupCount,
      itemBuilder: (context, i) {
        final groupIndex = groupCount - 1 - i;
        final pointIndices = dayGroups.chronologicalGroups[groupIndex];
        final mostRecentPointIndex = pointIndices.last;
        final expanded = groupIndex == _expandedDayGroup;
        return Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 10, bottom: 2),
          child: _DayGroupSection(
            date: history[mostRecentPointIndex].createdAt,
            color: dayGroups.colorForPoint[mostRecentPointIndex],
            pointCount: pointIndices.length,
            expanded: expanded,
            onToggle: () {
              HapticFeedbackUtils.impact();
              setState(() {
                if (expanded) {
                  _expandedDayGroup = null;
                } else {
                  _expandedDayGroup = groupIndex;
                  _selectedIndex = mostRecentPointIndex;
                }
              });
            },
            children: [
              for (final pointIndex in pointIndices.reversed)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _HistoryPointTile(
                    displayNumber: dayGroups.dayNumberForPoint[pointIndex],
                    point: history[pointIndex],
                    selected: _selectedIndex == pointIndex,
                    onTap: () => setState(() => _selectedIndex = pointIndex),
                  ),
                ),
            ],
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
              UydoshInlineSpinner(
                color: theme.colorScheme.onSurfaceVariant,
                dimension: 12,
                strokeWidth: 1.5,
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

/// Fixed color per day of the week (rather than a palette cycled by
/// chronological position) so, say, every Monday an admin looks at always
/// reads the same blue — easier to recognize a weekly pattern (e.g. "always
/// in this district on Fridays") across a long history than an arbitrary
/// rotating color.
const Map<int, Color> _weekdayColors = {
  DateTime.monday: Color(0xFF1E88E5),
  DateTime.tuesday: Color(0xFF43A047),
  DateTime.wednesday: Color(0xFFE53935),
  DateTime.thursday: Color(0xFF8E24AA),
  DateTime.friday: Color(0xFFFB8C00),
  DateTime.saturday: Color(0xFF00ACC1),
  DateTime.sunday: Color(0xFFD81B60),
};

Color _colorForWeekday(int weekday) =>
    _weekdayColors[weekday] ?? _weekdayColors[DateTime.monday]!;

/// Precomputed per-point day-bucket assignment for a chronological (oldest-
/// first) history list, shared by the timeline list (date dividers) and the
/// map (one polyline segment + badge color per day) so both stay in sync.
class _DayGroups {
  const _DayGroups({
    required this.groupIndexForPoint,
    required this.colorForPoint,
    required this.chronologicalGroups,
    required this.dayNumberForPoint,
  });

  /// Same length as the history list; a 0-based, chronologically increasing
  /// id for the calendar day each point falls on.
  final List<int> groupIndexForPoint;

  /// Same length as the history list; the color assigned to that point's day,
  /// fixed per day-of-week via [_colorForWeekday].
  final List<Color> colorForPoint;

  /// Original history indices bucketed by day, in chronological order — used
  /// to draw one polyline per day instead of a single line spanning the
  /// user's entire history.
  final List<List<int>> chronologicalGroups;

  /// Same length as the history list; this point's 1-based chronological
  /// position within its own calendar day — shown on map badges and list
  /// rows so numbering restarts at 1 every day instead of climbing across
  /// the visitor's entire history.
  final List<int> dayNumberForPoint;
}

_DayGroups _computeDayGroups(List<TelegramMiniAppLocationHistoryPoint> points) {
  final groupIndexForPoint = List<int>.filled(points.length, 0);
  final colorForPoint =
      List<Color>.filled(points.length, _weekdayColors[DateTime.monday]!);
  final dayNumberForPoint = List<int>.filled(points.length, 0);
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
    colorForPoint[i] = _colorForWeekday(day.weekday);
    dayNumberForPoint[i] = chronologicalGroups[groupIndex].length;
  }
  return _DayGroups(
    groupIndexForPoint: groupIndexForPoint,
    colorForPoint: colorForPoint,
    chronologicalGroups: chronologicalGroups,
    dayNumberForPoint: dayNumberForPoint,
  );
}

/// One collapsible calendar-day section in the timeline: a tappable header
/// (colored dot + date + ping count + chevron, matching that day's map
/// badges/polyline) that expands to reveal its [children] point tiles.
class _DayGroupSection extends StatelessWidget {
  const _DayGroupSection({
    required this.date,
    required this.color,
    required this.pointCount,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final DateTime date;
  final Color color;
  final int pointCount;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat("EEEE, d MMM yyyy").format(date),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "($pointCount)",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Divider(color: theme.colorScheme.outlineVariant),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(children: children)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _HistoryPointTile extends StatelessWidget {
  const _HistoryPointTile({
    required this.displayNumber,
    required this.point,
    required this.selected,
    required this.onTap,
  });

  /// 1-based position within this point's own calendar day — matches the
  /// number shown on that ping's map badge (see [_DayGroups.dayNumberForPoint]).
  final int displayNumber;
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
                    "$displayNumber",
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
    required this.expandedGroupIndex,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TelegramMiniAppLocationHistoryPoint> history;
  final _DayGroups dayGroups;
  /// Chronological day-group index (into [_DayGroups.chronologicalGroups])
  /// whose pings alone are plotted — keeps the map to a single day's trail
  /// instead of the visitor's entire history at once. Null when every day
  /// section in the timeline is collapsed, leaving the map empty.
  final int? expandedGroupIndex;
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
  static const int _badgeIconSize = 128;
  static const double _badgeIconRadius = 44;
  static const double _unselectedBadgeScale = 0.85;
  static const double _selectedBadgeScale = 1.1;

  /// Sane zoom bounds re-applied after an SDK bounding-box fit (see
  /// [_fitBoundsToVisibleDay]) so a single ping, or a day's pings clustered
  /// tightly together, doesn't zoom in absurdly close, and a day spanning
  /// the whole city doesn't zoom out past street-level usefulness.
  static const double _minAutoFitZoom = 12.0;
  static const double _maxAutoFitZoom = 18.0;

  YandexMapController? _controller;
  bool _didFitBounds = false;

  /// Numbered-badge icon bytes keyed by history index, generated lazily for
  /// whichever day is currently visible (and cached — see [_generateBadgeIcons])
  /// rather than for the whole history up front, since [BitmapDescriptor.fromBytes]
  /// needs raw PNG bytes synchronously at build time, but rendering them is async.
  final Map<int, Uint8List> _badgeIconBytes = {};

  @override
  void initState() {
    super.initState();
    _generateBadgeIcons();
  }

  @override
  void didUpdateWidget(_TelegramLocationHistoryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.history, widget.history)) {
      // Indices can mean different pings after a reload (e.g. dedup-precision
      // change), so a stale cache could paint the wrong badge/color.
      _badgeIconBytes.clear();
      _generateBadgeIcons();
    }
    if (oldWidget.expandedGroupIndex != widget.expandedGroupIndex) {
      _generateBadgeIcons();
      unawaited(_fitBoundsToVisibleDay(animate: true));
    } else if (oldWidget.selectedIndex != widget.selectedIndex) {
      unawaited(_focusSelected());
    }
  }

  List<int> get _visibleIndices {
    final groupIndex = widget.expandedGroupIndex;
    final groups = widget.dayGroups.chronologicalGroups;
    if (groupIndex == null || groupIndex >= groups.length) {
      return const [];
    }
    return groups[groupIndex];
  }

  Future<void> _generateBadgeIcons() async {
    final colors = widget.dayGroups.colorForPoint;
    final missing = [
      for (final i in _visibleIndices)
        if (!_badgeIconBytes.containsKey(i)) i,
    ];
    if (missing.isEmpty) return;
    final dayNumbers = widget.dayGroups.dayNumberForPoint;
    final entries = await Future.wait([
      for (final i in missing)
        _createBadgeIconBytes(label: "${dayNumbers[i]}", color: colors[i])
            .then((bytes) => MapEntry(i, bytes)),
    ]);
    if (!mounted) return;
    setState(() {
      _badgeIconBytes.addEntries(entries);
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
          fontSize: label.length > 2 ? 34 : 41,
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
      unawaited(_fitBoundsToVisibleDay(animate: false));
    });
  }

  /// Pans/zooms so every ping of the currently expanded day fits in the
  /// viewport. [animate] distinguishes the very first fit (right after the
  /// native map view attaches) from later ones triggered by tapping a
  /// different day header.
  Future<void> _fitBoundsToVisibleDay({required bool animate}) async {
    final controller = _controller;
    final indices = _visibleIndices;
    if (controller == null || indices.isEmpty) return;

    final firstPoint = widget.history[indices.first];
    var minLat = firstPoint.latitude;
    var maxLat = firstPoint.latitude;
    var minLon = firstPoint.longitude;
    var maxLon = firstPoint.longitude;
    for (final index in indices) {
      final point = widget.history[index];
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLon = point.longitude < minLon ? point.longitude : minLon;
      maxLon = point.longitude > maxLon ? point.longitude : maxLon;
    }
    final boundsCenter = Point(
      latitude: (minLat + maxLat) / 2,
      longitude: (minLon + maxLon) / 2,
    );

    if (!animate) {
      // The native map view needs a frame to finish attaching after creation,
      // so it can still report a stale/zero viewport size right here. Asking
      // the SDK to fit a bounding box at this point can zoom out to the whole
      // world instead of panning in close — a manually picked zoom level is
      // independent of viewport size and reliable this early (see
      // YandexMapWidget's own initial-camera handling, which hits the same
      // issue).
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: boundsCenter,
            zoom: _zoomForSpan(
              latSpan: (maxLat - minLat).abs(),
              lonSpan: (maxLon - minLon).abs(),
            ),
          ),
        ),
      );
      return;
    }

    // Later fits (switching days) happen once the map is already laid out
    // with a real viewport, so let the SDK compute the exact camera that
    // shows this day's bounding box — padded a bit further so edge pings,
    // and their badge icons (which extend past the raw coordinate), land
    // comfortably inside the viewport instead of clipping against its edge.
    const animation = MapAnimation(type: MapAnimationType.smooth, duration: 0.4);
    final latPadding = ((maxLat - minLat).abs() * 0.3).clamp(0.0015, 0.02);
    final lonPadding = ((maxLon - minLon).abs() * 0.3).clamp(0.0015, 0.02);
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
      animation: animation,
    );

    // `newGeometry` can pick an arbitrarily tight/loose zoom depending on the
    // padded box; re-clamp it into a sane range for a single day's pings.
    final cameraPosition = await controller.getCameraPosition();
    final clampedZoom =
        cameraPosition.zoom.clamp(_minAutoFitZoom, _maxAutoFitZoom);
    if (clampedZoom != cameraPosition.zoom) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: boundsCenter,
            zoom: clampedZoom,
            azimuth: cameraPosition.azimuth,
            tilt: cameraPosition.tilt,
          ),
        ),
        animation: animation,
      );
    }
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
    final visibleIndices = _visibleIndices;

    // Only the expanded day's pings are drawn — as a single chain colored by
    // that day's weekday — instead of the visitor's entire history at once,
    // which read as unbroken noise once it spanned days/weeks.
    final dayColor = visibleIndices.isEmpty
        ? _weekdayColors[DateTime.monday]!
        : widget.dayGroups.colorForPoint[visibleIndices.first];

    final polylines = <PolylineMapObject>[
      if (visibleIndices.length > 1)
        PolylineMapObject(
          mapId: const MapObjectId("telegram_location_history_polyline"),
          polyline: Polyline(
            points: [
              for (final index in visibleIndices)
                Point(
                  latitude: widget.history[index].latitude,
                  longitude: widget.history[index].longitude,
                ),
            ],
          ),
          strokeColor: dayColor.withValues(alpha: 0.8),
          strokeWidth: 3,
        ),
    ];

    final placemarks = <PlacemarkMapObject>[
      for (final i in visibleIndices)
        if (_badgeIconBytes[i] != null)
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
