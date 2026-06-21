import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_budget_fit_chip.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_shortlist_save_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

class GroupHousingSearchScreen extends StatefulWidget {
  const GroupHousingSearchScreen({
    required this.groupListingDetail,
    super.key,
  });

  final ListingDetail groupListingDetail;

  @override
  State<GroupHousingSearchScreen> createState() =>
      _GroupHousingSearchScreenState();
}

class _GroupHousingSearchScreenState extends State<GroupHousingSearchScreen> {
  late final ListingsBloc _bloc;
  final _scrollController = ScrollController();
  List<int> _excludeUserIds = [];

  @override
  void initState() {
    super.initState();
    _bloc = ListingsBloc(getIt<IListingService>());
    _scrollController.addListener(_onScroll);
    _loadParticipantsAndSearch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _loadParticipantsAndSearch() async {
    final detail = widget.groupListingDetail;
    try {
      final members = await getIt<IListingGroupService>().listMembers(
        listingId: detail.id,
      );
      _excludeUserIds = members.map((m) => m.userId).toSet().toList();
    } catch (_) {
      _excludeUserIds = [detail.userId];
    }
    if (_excludeUserIds.isEmpty) {
      _excludeUserIds = [detail.userId];
    }
    if (!mounted) return;
    _runSearch();
  }

  void _runSearch({bool refresh = false}) {
    final detail = widget.groupListingDetail;
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: detail.price,
      listingTypeCode: ListingTypeCodes.groupForming,
      minPrice: detail.minPrice,
      maxPrice: detail.maxPrice,
    );
    final groupSize = detail.groupContext?.groupSizeTarget ?? detail.groupSizeTarget;
    final totalMax = groupSize != null ? bounds.max * groupSize : bounds.max;

    _bloc.add(
      ListingsEvent.searchListings(
        listingTypeId: ListingTypeIds.roommateNeeded,
        locationId: detail.locationId,
        subwayStationId: detail.subwayStationId,
        subwayLineId: detail.subwayLineId,
        gender: detail.gender,
        minPrice: bounds.min > 0 ? bounds.min.toDouble() : null,
        maxPrice: totalMax > 0 ? totalMax.toDouble() : null,
        excludeUserIds: _excludeUserIds,
        isRefresh: refresh,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = _bloc.state;
    final loaded = state.maybeWhen(loaded: (l, h, p, t) => (l, h, p), orElse: () => null);
    if (loaded == null || !loaded.$2) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      _bloc.add(const ListingsEvent.loadMore());
    }
  }

  String get _groupSizeLabel {
    final size = widget.groupListingDetail.groupContext?.groupSizeTarget ??
        widget.groupListingDetail.groupSizeTarget;
    return size?.toString() ?? "?";
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.groupListingDetail;
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: detail.price,
      listingTypeCode: ListingTypeCodes.groupForming,
      minPrice: detail.minPrice,
      maxPrice: detail.maxPrice,
    );
    final perPerson = PriceRangeHelper.formatListingPriceRangeWithCurrency(
      bounds.min,
      bounds.max,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("group_find_housing")),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.getWithParams(
                      "group_housing_search_banner",
                      params: {
                        "count": _groupSizeLabel,
                        "budget": perPerson,
                      },
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => GroupHousingFlow.openShortlistSheet(
                      context: context,
                      groupListingId: detail.id,
                      isOwner: detail.groupContext?.isOwner == true,
                      groupListingDetail: detail,
                    ),
                    icon: const ThemeIcon(Icons.bookmark_outline, size: 18),
                    label: Text(
                      GroupHousingFlow.savedListingsLabel(
                        detail.groupContext?.groupShortlistCount ?? 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ListingsBloc, ListingsState>(
              bloc: _bloc,
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: HouseLoadingIndicator()),
                  loading: () => const Center(child: HouseLoadingIndicator()),
                  error: (message) => UydoshErrorRetryColumn(
                    message: message,
                    onRetry: () => _runSearch(refresh: true),
                  ),
                  loaded: (listings, hasMore, page, total) {
                    if (listings.isEmpty) {
                      return UydoshEmptyColumn(
                        title: L10n.get("group_housing_search_empty"),
                      );
                    }
                    return UydoshRefreshIndicator(
                      onRefresh: () async => _runSearch(refresh: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: listings.length + (hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index >= listings.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: HouseLoadingIndicator()),
                            );
                          }
                          return _HousingSearchResultCard(
                            listing: listings[index],
                            groupListingDetail: detail,
                            groupSizeLabel: _groupSizeLabel,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HousingSearchResultCard extends StatelessWidget {
  const _HousingSearchResultCard({
    required this.listing,
    required this.groupListingDetail,
    required this.groupSizeLabel,
  });

  final Listing listing;
  final ListingDetail groupListingDetail;
  final String groupSizeLabel;

  @override
  Widget build(BuildContext context) {
    final fit = GroupHousingBudgetFitHelper.evaluateListing(
      groupListing: groupListingDetail,
      housingListing: listing,
    );
    final priceLabel = PriceRangeHelper.formatStoredListingPrice(
      storedPrice: listing.price,
      listingTypeCode:
          listing.listingType?.code ?? ListingTypeCodes.roommateNeeded,
      minPrice: listing.minPrice,
      maxPrice: listing.maxPrice,
    );
    final locationLabel = listing.location?.nameEn ??
        listing.location?.nameRu ??
        listing.subwayStation?.nameEn ??
        "";

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushListingDetail(
            listing.id,
            groupHousingContextListingId: groupListingDetail.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceLabel,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (locationLabel.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            locationLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GroupBudgetFitChip(fit: fit),
                ],
              ),
              const SizedBox(height: 10),
              GroupShortlistSaveButton(
                groupListingId: groupListingDetail.id,
                housingListingId: listing.id,
                groupSizeLabel: groupSizeLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
