import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

class AdminUserListingsScreen extends StatefulWidget {
  const AdminUserListingsScreen({
    required this.userId,
    super.key,
    this.userEmail,
  });

  final int userId;
  final String? userEmail;

  @override
  State<AdminUserListingsScreen> createState() =>
      _AdminUserListingsScreenState();
}

class _AdminUserListingsScreenState extends State<AdminUserListingsScreen> {
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
      final response = await getIt<IListingService>().getListingsByUserId(
        userId: widget.userId,
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
    final title = L10n.get("admin_user_listings_title");
    final titleWithCount = "$title ($headerCount)";
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          titleWithCount,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (widget.userEmail != null && widget.userEmail!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    "${L10n.get("admin_user_listings_user")}: ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.userEmail!,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _hasError
                    ? _buildErrorState(context)
                    : _buildListings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_user_listings_error"),
      message: _errorMessage,
      onRetry: _refresh,
    );
  }

  Widget _buildListings(BuildContext context) {
    if (_listings.isEmpty) {
      return Center(
        child: Text(
          L10n.get("admin_user_listings_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _listings.length,
      itemSpacing: 8,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return ListingTile(listing: listing);
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
