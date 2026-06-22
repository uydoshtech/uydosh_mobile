import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_telegram_listing_groups_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_telegram_listing_group_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class AdminTelegramListingGroupsScreen extends StatefulWidget {
  const AdminTelegramListingGroupsScreen({super.key});

  @override
  State<AdminTelegramListingGroupsScreen> createState() =>
      _AdminTelegramListingGroupsScreenState();
}

class _AdminTelegramListingGroupsScreenState
    extends State<AdminTelegramListingGroupsScreen> {
  final List<TelegramListingGroup> _groups = [];
  final ScrollController _scrollController = ScrollController();

  TelegramListingGroupsSummary? _summary;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _pageNumber = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetchGroups(loadMore: true);
    }
  }

  Future<void> _fetchGroups({bool loadMore = false}) async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response =
          await getIt<IAdminTelegramListingGroupsService>().getGroups(
        page: _pageNumber,
        limit: _pageSize,
      );

      setStateIfMounted(() {
        _summary = response.summary;
        _groups.addAll(response.groups);
        _hasMore = response.groups.length >= _pageSize;
        if (_hasMore) {
          _pageNumber += 1;
        }
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    _pageNumber = 1;
    _hasMore = true;
    _groups.clear();
    _summary = null;
    await _fetchGroups();
  }

  String _groupTitle(TelegramListingGroup group) {
    switch (group.groupType) {
      case TelegramListingGroupType.telegram:
        return "@${group.groupValue}";
      case TelegramListingGroupType.phone:
        return group.groupValue;
      case TelegramListingGroupType.unknown:
        return L10n.get("admin_telegram_listing_groups_unknown");
    }
  }

  IconData _groupIcon(TelegramListingGroupType type) {
    switch (type) {
      case TelegramListingGroupType.telegram:
        return Icons.alternate_email;
      case TelegramListingGroupType.phone:
        return Icons.phone_outlined;
      case TelegramListingGroupType.unknown:
        return Icons.help_outline;
    }
  }

  void _openGroup(TelegramListingGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminTelegramListingGroupDetailScreen(
          groupType: group.groupType,
          groupValue: group.groupValue,
          title: _groupTitle(group),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_telegram_listing_groups_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? CenteredHouseLoadingIndicator(
              text: L10n.get("admin_telegram_listing_groups_loading"),
            )
          : _hasError
              ? _buildErrorState(context)
              : _buildGroupsList(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_telegram_listing_groups_error"),
      message: _errorMessage,
      onRetry: _refresh,
    );
  }

  Widget _buildGroupsList(BuildContext context) {
    if (_groups.isEmpty) {
      return Center(
        child: Text(
          L10n.get("admin_telegram_listing_groups_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final summary = _summary;
    final itemCount = _groups.length + (summary != null ? 1 : 0);

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemSpacing: 8,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (summary != null && index == 0) {
          return _buildSummaryCard(context, summary);
        }
        final group = _groups[index - (summary != null ? 1 : 0)];
        return _buildGroupTile(context, group);
      },
      showRefreshIndicator: true,
      onRefresh: _refresh,
      showLoadMoreIndicator: _isLoadingMore,
      hasMore: _isLoadingMore,
      loadMoreIndicator: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    TelegramListingGroupsSummary summary,
  ) {
    final theme = Theme.of(context);
    const tileRadius = BorderRadius.all(Radius.circular(16));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: tileRadius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          theme.colorScheme.surface,
        ),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow(
              context,
              labelKey: "admin_telegram_listing_groups_summary_scraped",
              value: summary.scrapedTotal.toString(),
            ),
            _summaryRow(
              context,
              labelKey: "admin_telegram_listing_groups_summary_groups",
              value: summary.groupsTotal.toString(),
            ),
            _summaryRow(
              context,
              labelKey: "admin_telegram_listing_groups_summary_duplicates",
              value: summary.duplicateGroups.toString(),
              highlight: summary.duplicateGroups > 0,
            ),
            _summaryRow(
              context,
              labelKey: "admin_telegram_listing_groups_summary_ungrouped",
              value: summary.ungroupedCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String labelKey,
    required String value,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    final color = highlight ? theme.colorScheme.error : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              L10n.get(labelKey),
              style: TextStyle(
                fontSize: 13,
                color: color ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, TelegramListingGroup group) {
    final theme = Theme.of(context);
    const tileRadius = BorderRadius.all(Radius.circular(16));
    final accent = group.groupType == TelegramListingGroupType.unknown
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: tileRadius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          theme.colorScheme.surface,
        ),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: tileRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: tileRadius,
          onTap: () => _openGroup(group),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ThemeIcon(
                      _groupIcon(group.groupType),
                      size: 20,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _groupTitle(group),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        L10n.getWithParams(
                          "admin_telegram_listing_groups_listing_count",
                          params: {"count": group.listingCount.toString()},
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: group.hasDuplicates
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: group.hasDuplicates
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ThemeIcon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
