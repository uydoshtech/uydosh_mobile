import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/gig_moderation_admin_service.dart";
import "package:uy_dosh/domain/services/listing_moderation_admin_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

String _formatIsoDate(String iso) {
  try {
    final dt = DateTime.parse(iso);
    final d = dt.day.toString().padLeft(2, "0");
    final m = dt.month.toString().padLeft(2, "0");
    return "$d.$m.${dt.year}";
  } catch (_) {
    return iso;
  }
}

String _monthLabel(BuildContext context, DateTime date) {
  final monthKey = switch (date.month) {
    1 => "january",
    2 => "february",
    3 => "march",
    4 => "april",
    5 => "may",
    6 => "june",
    7 => "july",
    8 => "august",
    9 => "september",
    10 => "october",
    11 => "november",
    12 => "december",
    _ => "january",
  };
  return "${L10n.get(monthKey)} ${date.year}";
}

BoxDecoration _softTileDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    gradient: ThreeDSurfaceStyle.surfaceGradient(context, scheme.surface),
    borderRadius: BorderRadius.circular(14),
    boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
  );
}

Widget _monthSeparator(BuildContext context, String label) {
  final scheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: ThreeDSurfaceStyle.surfaceGradient(
              context,
              scheme.surface,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryCards(BuildContext context, PendingModerationSummary? s) {
  if (s == null) return const SizedBox.shrink();

  final oldest = s.oldestWaitingDays;
  final oldestLabel = oldest == null
      ? "—"
      : "$oldest ${L10n.get("admin_listing_moderation_days_short")}";

  return Row(
    children: [
      Expanded(
        child: _SummaryCard(
          title: L10n.get("admin_listing_moderation_summary_total"),
          value: "${s.pendingTotal}",
          icon: Icons.pending_actions_outlined,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _SummaryCard(
          title: L10n.get("admin_listing_moderation_summary_today"),
          value: "${s.pendingSubmittedToday}",
          icon: Icons.today,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _SummaryCard(
          title: L10n.get("admin_listing_moderation_summary_oldest"),
          value: oldestLabel,
          icon: Icons.hourglass_top_outlined,
        ),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThemeIcon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

Widget _buildSectionTitle(BuildContext context, String titleKey, IconData icon) {
  return Row(
    children: [
      ThemeIcon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          L10n.get(titleKey),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

sealed class _GigOfferQueueItem {}

final class _GigOfferMonthHeader extends _GigOfferQueueItem {
  _GigOfferMonthHeader(this.label);
  final String label;
}

final class _GigOfferIndex extends _GigOfferQueueItem {
  _GigOfferIndex(this.index);
  final int index;
}

sealed class _GigRequestQueueItem {}

final class _GigRequestMonthHeader extends _GigRequestQueueItem {
  _GigRequestMonthHeader(this.label);
  final String label;
}

final class _GigRequestIndex extends _GigRequestQueueItem {
  _GigRequestIndex(this.index);
  final int index;
}

class AdminGigModerationQueueScreen extends StatefulWidget {
  const AdminGigModerationQueueScreen({super.key});

  @override
  State<AdminGigModerationQueueScreen> createState() =>
      _AdminGigModerationQueueScreenState();
}

class _AdminGigModerationQueueScreenState extends State<AdminGigModerationQueueScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_gig_moderation_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: L10n.get("admin_gig_moderation_tab_offers")),
            Tab(text: L10n.get("admin_gig_moderation_tab_requests")),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          return TabBarView(
            controller: _tabController,
            children: const [
              _GigOffersModerationTab(),
              _GigRequestsModerationTab(),
            ],
          );
        },
      ),
    );
  }
}

class _GigOffersModerationTab extends StatefulWidget {
  const _GigOffersModerationTab();

  @override
  State<_GigOffersModerationTab> createState() => _GigOffersModerationTabState();
}

class _GigOffersModerationTabState extends State<_GigOffersModerationTab> {
  final IGigModerationAdminService _service = getIt<IGigModerationAdminService>();

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  final List<PendingModerationGigOffer> _rows = [];
  PendingModerationSummary? _summary;
  int _page = 1;
  int _totalPages = 1;
  final Map<int, bool> _expandedById = {};
  int? _approvingId;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final res = await _service.getPendingOffersQueue(page: 1, limit: _pageSize);
      setStateIfMounted(() {
        _rows
          ..clear()
          ..addAll(res.offers);
        _summary = res.summary;
        _page = 1;
        _totalPages = res.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _page >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;
    try {
      final res = await _service.getPendingOffersQueue(
        page: nextPage,
        limit: _pageSize,
      );
      setStateIfMounted(() {
        _rows.addAll(res.offers);
        _summary = res.summary;
        _page = nextPage;
        _totalPages = res.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _isLoadingMore = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  Future<void> _approve(PendingModerationGigOffer row) async {
    if (_approvingId != null) return;
    setState(() => _approvingId = row.id);
    try {
      await _service.approveOffer(row.id);
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.get("admin_gig_moderation_approved_offer_toast")),
        ),
      );
      await _loadFirstPage();
    } catch (e) {
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setStateIfMounted(() => _approvingId = null);
    }
  }

  List<_GigOfferQueueItem> _buildGroupedItems() {
    final items = <_GigOfferQueueItem>[];
    String? lastMonthKey;
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      DateTime? dt;
      try {
        dt = DateTime.parse(r.createdAt);
      } catch (_) {
        dt = null;
      }
      final monthKey = dt != null ? "${dt.year}-${dt.month}" : null;
      if (dt != null && monthKey != null && monthKey != lastMonthKey) {
        items.add(_GigOfferMonthHeader(_monthLabel(context, dt)));
        lastMonthKey = monthKey;
      }
      items.add(_GigOfferIndex(i));
    }
    return items;
  }

  Widget _buildTile(BuildContext context, int index) {
    final row = _rows[index];
    final scheme = Theme.of(context).colorScheme;
    final expanded = _expandedById[row.id] ?? false;
    final busy = _approvingId == row.id;

    final subtitleParts = <String>[
      _formatIsoDate(row.createdAt),
      "${L10n.get("admin_listing_moderation_id")}: ${row.id}",
      if (row.providerName != null && row.providerName!.isNotEmpty)
        "${L10n.get("admin_gig_moderation_provider")}: ${row.providerName}",
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _softTileDecoration(context),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<int>(row.id),
          initiallyExpanded: expanded,
          onExpansionChanged: (v) => setState(() => _expandedById[row.id] = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: ThemeIcon(
            Icons.handyman_outlined,
            size: 22,
            color: scheme.onSurfaceVariant,
          ),
          title: Text(
            row.title.isEmpty
                ? "${L10n.get("admin_listing_moderation_id")} #${row.id}"
                : row.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitleParts.join(" · "),
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 3,
          ),
          trailing: AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: const ThemeIcon(Icons.expand_more),
          ),
          children: [
            if (row.categoryLabel != null && row.categoryLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    row.categoryLabel!,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => context.pushGigOfferDetail(row.id),
                    icon: const ThemeIcon(Icons.open_in_new, size: 18),
                    label: Text(L10n.get("admin_listing_moderation_open")),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : () => _approve(row),
                    icon: busy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const ThemeIcon(Icons.check_circle_outline, size: 18),
                    label: Text(L10n.get("admin_listing_moderation_approve")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_listing_moderation_error"),
      message: _errorMessage,
      messageMaxLines: 3,
      messageOverflow: TextOverflow.ellipsis,
      padding: const EdgeInsets.all(24),
      spacingAfterTitle: 8,
      spacingBeforeButton: 20,
      retryButton: ElevatedButton.icon(
        onPressed: () {
          HapticFeedbackUtils.impact();
          _loadFirstPage();
        },
        icon: const ThemeIcon(Icons.refresh),
        label: Text(L10n.get("admin_listing_moderation_retry")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_hasError) {
      return _buildErrorState(context);
    }
    if (_isLoading && _rows.isEmpty) {
      return CenteredHouseLoadingIndicator(
        text: L10n.get("admin_listing_moderation_loading"),
      );
    }

    if (_rows.isEmpty) {
      return UydoshRefreshIndicator(
        onRefresh: _loadFirstPage,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummaryCards(context, _summary),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      L10n.get("admin_gig_moderation_empty_offers"),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _buildGroupedItems();

    return UydoshRefreshIndicator(
      onRefresh: _loadFirstPage,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryCards(context, _summary),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  "admin_gig_moderation_section_offers",
                  Icons.rule_folder_outlined,
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final it = grouped[index];
                  return switch (it) {
                    _GigOfferMonthHeader(:final label) =>
                      _monthSeparator(context, label),
                    _GigOfferIndex(:final index) => _buildTile(context, index),
                  };
                },
                childCount: grouped.length,
              ),
            ),
          ),
          if (_page < _totalPages)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Center(
                  child: _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton(
                          onPressed: _loadMore,
                          child: Text(
                            L10n.get("admin_listing_moderation_load_more"),
                          ),
                        ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _GigRequestsModerationTab extends StatefulWidget {
  const _GigRequestsModerationTab();

  @override
  State<_GigRequestsModerationTab> createState() =>
      _GigRequestsModerationTabState();
}

class _GigRequestsModerationTabState extends State<_GigRequestsModerationTab> {
  final IGigModerationAdminService _service = getIt<IGigModerationAdminService>();

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  final List<PendingModerationGigRequestRow> _rows = [];
  PendingModerationSummary? _summary;
  int _page = 1;
  int _totalPages = 1;
  final Map<int, bool> _expandedById = {};
  int? _approvingId;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final res =
          await _service.getPendingRequestsQueue(page: 1, limit: _pageSize);
      setStateIfMounted(() {
        _rows
          ..clear()
          ..addAll(res.requests);
        _summary = res.summary;
        _page = 1;
        _totalPages = res.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _page >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;
    try {
      final res = await _service.getPendingRequestsQueue(
        page: nextPage,
        limit: _pageSize,
      );
      setStateIfMounted(() {
        _rows.addAll(res.requests);
        _summary = res.summary;
        _page = nextPage;
        _totalPages = res.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _isLoadingMore = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  Future<void> _approve(PendingModerationGigRequestRow row) async {
    if (_approvingId != null) return;
    setState(() => _approvingId = row.id);
    try {
      await _service.approveRequest(row.id);
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.get("admin_gig_moderation_approved_request_toast")),
        ),
      );
      await _loadFirstPage();
    } catch (e) {
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setStateIfMounted(() => _approvingId = null);
    }
  }

  List<_GigRequestQueueItem> _buildGroupedItems() {
    final items = <_GigRequestQueueItem>[];
    String? lastMonthKey;
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      DateTime? dt;
      try {
        dt = DateTime.parse(r.createdAt);
      } catch (_) {
        dt = null;
      }
      final monthKey = dt != null ? "${dt.year}-${dt.month}" : null;
      if (dt != null && monthKey != null && monthKey != lastMonthKey) {
        items.add(_GigRequestMonthHeader(_monthLabel(context, dt)));
        lastMonthKey = monthKey;
      }
      items.add(_GigRequestIndex(i));
    }
    return items;
  }

  Widget _buildTile(BuildContext context, int index) {
    final row = _rows[index];
    final scheme = Theme.of(context).colorScheme;
    final expanded = _expandedById[row.id] ?? false;
    final busy = _approvingId == row.id;

    final subtitleParts = <String>[
      _formatIsoDate(row.createdAt),
      "${L10n.get("admin_listing_moderation_id")}: ${row.id}",
      if (row.clientName != null && row.clientName!.isNotEmpty)
        "${L10n.get("admin_gig_moderation_client")}: ${row.clientName}",
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _softTileDecoration(context),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>("gig_mod_req_${row.id}"),
          initiallyExpanded: expanded,
          onExpansionChanged: (v) => setState(() => _expandedById[row.id] = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: ThemeIcon(
            Icons.task_alt_outlined,
            size: 22,
            color: scheme.onSurfaceVariant,
          ),
          title: Text(
            row.title.isEmpty
                ? "${L10n.get("admin_listing_moderation_id")} #${row.id}"
                : row.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitleParts.join(" · "),
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 3,
          ),
          trailing: AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: const ThemeIcon(Icons.expand_more),
          ),
          children: [
            if (row.categoryLabel != null && row.categoryLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    row.categoryLabel!,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => context.pushGigRequestDetail(row.id),
                    icon: const ThemeIcon(Icons.open_in_new, size: 18),
                    label: Text(L10n.get("admin_listing_moderation_open")),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : () => _approve(row),
                    icon: busy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const ThemeIcon(Icons.check_circle_outline, size: 18),
                    label: Text(L10n.get("admin_listing_moderation_approve")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_listing_moderation_error"),
      message: _errorMessage,
      messageMaxLines: 3,
      messageOverflow: TextOverflow.ellipsis,
      padding: const EdgeInsets.all(24),
      spacingAfterTitle: 8,
      spacingBeforeButton: 20,
      retryButton: ElevatedButton.icon(
        onPressed: () {
          HapticFeedbackUtils.impact();
          _loadFirstPage();
        },
        icon: const ThemeIcon(Icons.refresh),
        label: Text(L10n.get("admin_listing_moderation_retry")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_hasError) {
      return _buildErrorState(context);
    }
    if (_isLoading && _rows.isEmpty) {
      return CenteredHouseLoadingIndicator(
        text: L10n.get("admin_listing_moderation_loading"),
      );
    }

    if (_rows.isEmpty) {
      return UydoshRefreshIndicator(
        onRefresh: _loadFirstPage,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummaryCards(context, _summary),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      L10n.get("admin_gig_moderation_empty_requests"),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _buildGroupedItems();

    return UydoshRefreshIndicator(
      onRefresh: _loadFirstPage,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryCards(context, _summary),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  "admin_gig_moderation_section_requests",
                  Icons.rule_folder_outlined,
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final it = grouped[index];
                  return switch (it) {
                    _GigRequestMonthHeader(:final label) =>
                      _monthSeparator(context, label),
                    _GigRequestIndex(:final index) => _buildTile(context, index),
                  };
                },
                childCount: grouped.length,
              ),
            ),
          ),
          if (_page < _totalPages)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Center(
                  child: _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton(
                          onPressed: _loadMore,
                          child: Text(
                            L10n.get("admin_listing_moderation_load_more"),
                          ),
                        ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
