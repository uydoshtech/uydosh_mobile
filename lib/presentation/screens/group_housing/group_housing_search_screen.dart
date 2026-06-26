import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_search_prefs_edit_sheet.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_budget_fit_chip.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
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
  List<ConversationMemberSummary> _groupMembers = const [];
  int? _currentUserId;
  GroupSearchPrefs? _searchPrefs;

  @override
  void initState() {
    super.initState();
    _bloc = ListingsBloc(getIt<IListingService>());
    final initialShortlistCount =
        widget.groupListingDetail.groupContext?.groupShortlistCount;
    if (initialShortlistCount != null) {
      GroupShortlistState().setShortlistCountForGroup(
        widget.groupListingDetail.id,
        initialShortlistCount,
      );
    }
    _scrollController.addListener(_onScroll);
    unawaited(_loadCurrentUserId());
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
    var membersForUi = const <ConversationMemberSummary>[];
    try {
      final members = await getIt<IListingGroupService>().listMembers(
        listingId: detail.id,
      );
      _excludeUserIds = members.map((m) => m.userId).toSet().toList();
      membersForUi = members
          .map(
            (m) => ConversationMemberSummary(
              userId: m.userId,
              name: m.name,
              avatarUrl: m.avatarUrl,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      _excludeUserIds = [detail.userId];
    }
    if (_excludeUserIds.isEmpty) {
      _excludeUserIds = [detail.userId];
    }
    try {
      _searchPrefs = await getIt<IListingGroupService>().getSearchPrefs(
        groupListingId: detail.id,
      );
    } catch (_) {
      _searchPrefs = null;
    }
    if (!mounted) return;
    setState(() => _groupMembers = membersForUi);
    _runSearch();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await SessionManager.getUserId();
    if (!mounted) return;
    setState(() => _currentUserId = userId);
  }

  void _runSearch({bool refresh = false}) {
    final detail = widget.groupListingDetail;
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: detail.price,
      listingTypeCode: ListingTypeCodes.groupForming,
      minPrice: detail.minPrice,
      maxPrice: detail.maxPrice,
    );
    final groupSize =
        detail.groupContext?.groupSizeTarget ?? detail.groupSizeTarget;
    final totalMax = groupSize != null ? bounds.max * groupSize : bounds.max;

    // Prefer the group's shared search area when it has been customized;
    // otherwise fall back to the group-forming listing's own geo.
    final prefs = _searchPrefs;
    final prefStations = prefs?.subwayStationIds ?? const <int>[];
    final useShared = prefs != null &&
        !prefs.isDefault &&
        (prefStations.isNotEmpty || (prefs.locationId ?? 0) > 0);

    _bloc.add(
      ListingsEvent.searchListings(
        listingTypeId: ListingTypeIds.roommateNeeded,
        locationId: useShared ? prefs.locationId : detail.locationId,
        subwayStationId: useShared
            ? (prefStations.length == 1 ? prefStations.first : null)
            : detail.subwayStationId,
        subwayStationIds:
            useShared && prefStations.length > 1 ? prefStations : null,
        subwayLineId: useShared ? null : detail.subwayLineId,
        gender: detail.gender,
        minPrice: bounds.min > 0 ? bounds.min.toDouble() : null,
        maxPrice: totalMax > 0 ? totalMax.toDouble() : null,
        excludeUserIds: _excludeUserIds,
        isRefresh: refresh,
      ),
    );
  }

  Future<void> _editSearchArea() async {
    final detail = widget.groupListingDetail;
    final initial = _searchPrefs ??
        GroupSearchPrefs(
          locationId: detail.locationId,
          subwayStationIds: detail.subwayStationId != null
              ? [detail.subwayStationId!]
              : const [],
          subwayLineIds:
              detail.subwayLineId != null ? [detail.subwayLineId!] : const [],
          isDefault: true,
        );
    final updated = await showGroupSearchPrefsEditSheet(
      context: context,
      groupListingId: detail.id,
      initial: initial,
    );
    if (updated == null || !mounted) return;
    setState(() => _searchPrefs = updated);
    _runSearch(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = _bloc.state;
    final loaded = state.maybeWhen(
      loaded: (l, h, p, t, r) => (l, h, p),
      orElse: () => null,
    );
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
    final perPerson =
        PriceRangeHelper.formatListingPriceRangeWithCurrencyMarker(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: LiquidGlassPlate(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_groupMembers.isNotEmpty) ...[
                        ChatParticipantAvatarStack(
                          participants: _groupMembers,
                          currentUserId: _currentUserId,
                          avatarSize: 24,
                          maxVisible: 5,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          L10n.getWithParams(
                            "group_housing_search_banner",
                            params: {
                              "count": _groupSizeLabel,
                              "budget": perPerson,
                            },
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => GroupHousingFlow.openShortlistSheet(
                            context: context,
                            groupListingId: detail.id,
                            isOwner: detail.groupContext?.isOwner == true,
                            groupListingDetail: detail,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const ThemeIcon(Icons.bookmark, size: 18),
                          label: ListenableBuilder(
                            listenable: GroupShortlistState(),
                            builder: (context, _) {
                              final count = GroupShortlistState()
                                  .shortlistCountForGroup(detail.id);
                              return Text(
                                GroupHousingFlow.savedListingsLabel(count),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _editSearchArea,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const ThemeIcon(Icons.travel_explore, size: 18),
                        label: Text(
                          L10n.get("group_search_area"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                  loaded: (listings, hasMore, page, total, revision) {
                    if (listings.isEmpty) {
                      return UydoshEmptyColumn(
                        title: L10n.get("group_housing_search_empty"),
                      );
                    }
                    return UydoshRefreshIndicator(
                      onRefresh: () async => _runSearch(refresh: true),
                      child: CommonListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        itemSpacing: 12,
                        itemCount: listings.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= listings.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: HouseLoadingIndicator()),
                            );
                          }
                          final listing = listings[index];
                          final fit =
                              GroupHousingBudgetFitHelper.evaluateListing(
                            groupListing: detail,
                            housingListing: listing,
                          );
                          return ListingTile(
                            key: ValueKey(
                              "group-housing-${detail.id}-${listing.id}",
                            ),
                            listing: listing,
                            feedOptimized: true,
                            trailingAction: _GroupShortlistBookmarkAction(
                              groupListingId: detail.id,
                              housingListingId: listing.id,
                            ),
                            footerContent: fit == GroupHousingBudgetFit.unknown
                                ? null
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: GroupBudgetFitChip(fit: fit),
                                  ),
                            onTap: () {
                              unawaited(
                                context.pushListingDetail(
                                  listing.id,
                                  groupHousingContextListingId: detail.id,
                                ),
                              );
                            },
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

class _GroupShortlistBookmarkAction extends StatefulWidget {
  const _GroupShortlistBookmarkAction({
    required this.groupListingId,
    required this.housingListingId,
  });

  final int groupListingId;
  final int housingListingId;

  @override
  State<_GroupShortlistBookmarkAction> createState() =>
      _GroupShortlistBookmarkActionState();
}

class _GroupShortlistBookmarkActionState
    extends State<_GroupShortlistBookmarkAction> {
  var _loading = false;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedInitial();
  }

  @override
  void didUpdateWidget(covariant _GroupShortlistBookmarkAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupListingId != widget.groupListingId ||
        oldWidget.housingListingId != widget.housingListingId) {
      _seeded = false;
      _loading = false;
      _seedInitial();
    }
  }

  Future<void> _seedInitial() async {
    try {
      final isOn = await getIt<IListingGroupService>().isOnShortlist(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
      );
      if (!mounted) return;
      GroupShortlistState().seedShortlisted(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
        isShortlisted: isOn,
      );
    } catch (_) {
      // Keep the action usable; the optimistic toggle will surface failures.
    } finally {
      if (mounted) setState(() => _seeded = true);
    }
  }

  Future<void> _toggle() async {
    if (_loading || !_seeded) return;
    HapticFeedbackUtils.selection();
    setState(() => _loading = true);
    try {
      final nowShortlisted = await GroupShortlistState().toggle(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get(
          nowShortlisted ? "group_shortlist_added" : "group_shortlist_removed",
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: ErrorMessageHelper.sanitizeErrorMessage(e, context: context),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
        [
          GroupShortlistState().listenableFor(
            groupListingId: widget.groupListingId,
            housingListingId: widget.housingListingId,
          ),
          ThemeState(),
        ],
      ),
      builder: (context, _) {
        final isOn = GroupShortlistState().isShortlisted(
          groupListingId: widget.groupListingId,
          housingListingId: widget.housingListingId,
        );
        final isBlueTheme = ThemeState().isBlueTheme;
        final iconColor = isBlueTheme
            ? Colors.white
            : isOn
                ? Theme.of(context).colorScheme.primary
                : AppColors.favoriteInactive;

        return Opacity(
          opacity: _seeded && !_loading ? 1 : 0.55,
          child: SizedBox(
            width: 25,
            height: 25,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: const SizedBox(width: 48, height: 48),
                ),
                IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    reverseDuration: const Duration(milliseconds: 160),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: SizedBox(
                      key: ValueKey(isOn ? "bookmark-on" : "bookmark-off"),
                      width: 25,
                      height: 25,
                      child: Icon(
                        isOn ? Icons.bookmark : Icons.bookmark_border,
                        color: iconColor,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
