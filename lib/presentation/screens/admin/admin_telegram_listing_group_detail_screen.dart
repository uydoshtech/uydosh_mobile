import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/admin_telegram_listing_groups_service.dart";
import "package:uy_dosh/presentation/screens/home/home_feed_entries.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

class AdminTelegramListingGroupDetailScreen extends StatefulWidget {
  const AdminTelegramListingGroupDetailScreen({
    required this.groupType,
    required this.groupValue,
    required this.title,
    super.key,
  });

  final TelegramListingGroupType groupType;
  final String groupValue;

  /// Pre-formatted, human-readable group label shown in the app bar.
  final String title;

  @override
  State<AdminTelegramListingGroupDetailScreen> createState() =>
      _AdminTelegramListingGroupDetailScreenState();
}

class _AdminTelegramListingGroupDetailScreenState
    extends State<AdminTelegramListingGroupDetailScreen> {
  final List<Listing> _listings = [];
  final Set<int> _listingIds = {};
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _pageNumber = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
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
      _fetchListings(loadMore: true);
    }
  }

  Future<void> _fetchListings({bool loadMore = false}) async {
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
          await getIt<IAdminTelegramListingGroupsService>().getGroupListings(
        groupType: widget.groupType,
        groupValue: widget.groupValue,
        page: _pageNumber,
        limit: _pageSize,
      );

      setStateIfMounted(() {
        final newItems =
            response.data.where((item) => _listingIds.add(item.id)).toList();
        _listings.addAll(newItems);
        _hasMore = newItems.isNotEmpty && response.data.length >= _pageSize;
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
    _listings.clear();
    _listingIds.clear();
    await _fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    final headerCount = _listings.length;
    final titleWithCount = "${widget.title} ($headerCount)";
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          titleWithCount,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _hasError
              ? _buildErrorState(context)
              : _buildListings(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_telegram_listing_groups_error"),
      message: _errorMessage,
      onRetry: _refresh,
    );
  }

  Widget _buildListings(BuildContext context) {
    if (_listings.isEmpty) {
      return Center(
        child: Text(
          L10n.get("admin_telegram_listing_groups_detail_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final feedEntries = homeFeedEntriesWithDateHeaders(_listings);

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: feedEntries.length,
      itemSpacing: 8,
      itemBuilder: (context, index) {
        final entry = feedEntries[index];
        final listing = entry.listing;
        if (listing != null) {
          return ListingTile(key: ValueKey(listing.id), listing: listing);
        }
        final day = entry.day!;
        return DateHeaderWidget(
          key: ValueKey(
            "telegram-group-day-${day.year}-${day.month}-${day.day}",
          ),
          dateString: AppDateUtils.formatDateHeader(day, context),
          date: day,
        );
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
}
