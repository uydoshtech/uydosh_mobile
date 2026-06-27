import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/gig_hub_feeds_refresh_notifier.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/scroll_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_requests_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/router/create_choice_sheet.dart";
import "package:uy_dosh/presentation/screens/gig/publish_gig_screen.dart"
    show GigPublishMode;
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_feed_tile_swipe_wrapper.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_offer_tile.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_request_tile.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

class UserListingsScreen extends StatelessWidget {
  const UserListingsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ListingsBloc(getIt<IListingService>())
            ..add(const ListingsEvent.fetchUserListings(isRefresh: true)),
        ),
        BlocProvider(create: (_) => GigOffersBloc(getIt<IGigService>())),
        BlocProvider(create: (_) => GigRequestsBloc(getIt<IGigService>())),
      ],
      child: _UserListingsScreenBody(embedded: embedded),
    );
  }
}

class _UserListingsData {
  const _UserListingsData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listings,
    required this.hasMore,
  });

  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Listing> listings;
  final bool hasMore;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _UserListingsData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.listings.length == listings.length &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        listings.length.hashCode ^
        hasMore.hashCode;
  }
}

class _UserListingsScreenBody extends StatefulWidget {
  const _UserListingsScreenBody({required this.embedded});

  final bool embedded;

  @override
  State<_UserListingsScreenBody> createState() =>
      _UserListingsScreenBodyState();
}

class _UserListingsScreenBodyState extends State<_UserListingsScreenBody>
    with TickerProviderStateMixin {
  static const double _listTopPad = 8.0;

  final ScrollController _listingsScrollController = ScrollController();
  final ScrollController _servicesScrollController = ScrollController();
  final ScrollController _tasksScrollController = ScrollController();

  late final TabController _tabController;
  late final VoidCallback _throttledListingsScrollListener;
  late final VoidCallback _resetListingsScrollLoadingState;

  int? _userId;
  bool _loadingUserId = true;
  bool _didAutoSelectInitialTab = false;

  Color _emptyStateTitleColor() =>
      ThemeState().isBlueTheme ? AppColors.textLight : AppColors.textGrey600;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "user_listings");
    _tabController = TabController(length: 3, vsync: this);

    final scrollListenerData =
        ScrollUtils.createThrottledScrollListenerWithReset(
      scrollController: _listingsScrollController,
      onLoadMore: _loadMoreListings,
      shouldLoadMore: _shouldLoadMoreListings,
    );
    _throttledListingsScrollListener = scrollListenerData.listener;
    _resetListingsScrollLoadingState = scrollListenerData.resetLoadingState;
    _listingsScrollController.addListener(_throttledListingsScrollListener);

    _servicesScrollController.addListener(_onServicesScroll);
    _tasksScrollController.addListener(_onTasksScroll);
    getIt<GigHubFeedsRefreshNotifier>().addListener(_onHubFeedsRefreshSignal);

    AuthenticationState().initialize();
    FavoritesState().initialize();
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    unawaited(_loadUserIdAndGigs());
  }

  Future<void> _loadUserIdAndGigs() async {
    final id = await SessionManager.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = id;
      _loadingUserId = false;
    });
    if (id == null) return;
    context.read<GigOffersBloc>().add(FetchGigOffers(providerUserId: id));
    context.read<GigRequestsBloc>().add(FetchGigRequests(clientUserId: id));
  }

  @override
  void dispose() {
    getIt<GigHubFeedsRefreshNotifier>()
        .removeListener(_onHubFeedsRefreshSignal);
    _resetListingsScrollLoadingState();
    ScrollUtils.disposeScrollController(
      _listingsScrollController,
      _throttledListingsScrollListener,
    );
    _servicesScrollController.removeListener(_onServicesScroll);
    _tasksScrollController.removeListener(_onTasksScroll);
    _servicesScrollController.dispose();
    _tasksScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onHubFeedsRefreshSignal() {
    final userId = _userId;
    if (!mounted || userId == null) return;
    final signal = getIt<GigHubFeedsRefreshNotifier>().lastSignal;
    if (signal.refreshServices) {
      context.read<GigOffersBloc>().add(
            FetchGigOffers(refresh: true, providerUserId: userId),
          );
    }
    if (signal.refreshTasks) {
      context.read<GigRequestsBloc>().add(
            FetchGigRequests(refresh: true, clientUserId: userId),
          );
    }
  }

  void _onServicesScroll() {
    if (!_servicesScrollController.hasClients) return;
    if (_servicesScrollController.position.pixels >=
        _servicesScrollController.position.maxScrollExtent - 200) {
      context.read<GigOffersBloc>().add(const LoadMoreGigOffers());
    }
  }

  void _onTasksScroll() {
    if (!_tasksScrollController.hasClients) return;
    if (_tasksScrollController.position.pixels >=
        _tasksScrollController.position.maxScrollExtent - 200) {
      context.read<GigRequestsBloc>().add(const LoadMoreGigRequests());
    }
  }

  bool _shouldLoadMoreListings() {
    try {
      final state = context.read<ListingsBloc>().state;
      return state.map(
        initial: (_) => false,
        loading: (_) => false,
        loaded: (loadedState) => loadedState.hasMore,
        error: (_) => false,
      );
    } catch (_) {
      return false;
    }
  }

  void _loadMoreListings() {
    context.read<ListingsBloc>().add(
          const ListingsEvent.fetchUserListings(isRefresh: false),
        );
  }

  Future<void> _refreshListings() async {
    context.read<ListingsBloc>().add(
          const ListingsEvent.fetchUserListings(isRefresh: true),
        );
  }

  Future<void> _refreshServices() async {
    final userId = _userId;
    if (userId == null) return;
    final bloc = context.read<GigOffersBloc>();
    bloc.add(FetchGigOffers(refresh: true, providerUserId: userId));
    await bloc.stream
        .where((s) => s is GigOffersLoaded || s is GigOffersError)
        .first;
  }

  Future<void> _refreshTasks() async {
    final userId = _userId;
    if (userId == null) return;
    final bloc = context.read<GigRequestsBloc>();
    bloc.add(FetchGigRequests(refresh: true, clientUserId: userId));
    await bloc.stream
        .where((s) => s is GigRequestsLoaded || s is GigRequestsError)
        .first;
  }

  Future<void> _refreshAllTabs() async {
    await Future.wait([
      _refreshListings(),
      _refreshServices(),
      _refreshTasks(),
    ]);
  }

  void _tryAutoSelectInitialTab() {
    if (_didAutoSelectInitialTab || !mounted) return;

    final listingsState = context.read<ListingsBloc>().state;
    final offersState = context.read<GigOffersBloc>().state;
    final requestsState = context.read<GigRequestsBloc>().state;

    final listingsSettled = listingsState.maybeMap(
      loaded: (_) => true,
      error: (_) => true,
      orElse: () => false,
    );
    final offersSettled =
        offersState is GigOffersLoaded || offersState is GigOffersError;
    final requestsSettled =
        requestsState is GigRequestsLoaded || requestsState is GigRequestsError;
    if (!listingsSettled || !offersSettled || !requestsSettled) return;

    final hasListings = listingsState.maybeMap(
      loaded: (s) => s.listings.isNotEmpty,
      orElse: () => false,
    );
    final hasServices =
        offersState is GigOffersLoaded && offersState.offers.isNotEmpty;
    final hasTasks =
        requestsState is GigRequestsLoaded && requestsState.requests.isNotEmpty;

    _didAutoSelectInitialTab = true;

    final nextIndex = hasListings
        ? 0
        : hasServices
            ? 1
            : hasTasks
                ? 2
                : 0;
    if (nextIndex != _tabController.index) {
      _tabController.index = nextIndex;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = MultiBlocListener(
      listeners: [
        BlocListener<ListingsBloc, ListingsState>(
          listener: (_, __) {
            _resetListingsScrollLoadingState();
            _tryAutoSelectInitialTab();
          },
        ),
        BlocListener<GigOffersBloc, GigOffersState>(
          listener: (_, __) => _tryAutoSelectInitialTab(),
        ),
        BlocListener<GigRequestsBloc, GigRequestsState>(
          listener: (_, __) => _tryAutoSelectInitialTab(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Services/tasks are temporarily removed from this screen.
          // ListenableBuilder(
          //   listenable: LanguageState(),
          //   builder: (context, _) {
          //     return AnimatedBuilder(
          //       animation: _tabController,
          //       builder: (context, _) {
          //         return FavoritesTabRibbon(
          //           tabController: _tabController,
          //           listingsLabel: L10n.get("favorites_tab_listings"),
          //           servicesLabel: L10n.get("favorites_tab_services"),
          //           tasksLabel: L10n.get("favorites_tab_tasks"),
          //         );
          //       },
          //     );
          //   },
          // ),
          // const SizedBox(height: 6),
          Expanded(
            child: _buildListingsTab(),
            // child: TabBarView(
            //   controller: _tabController,
            //   children: [
            //     _buildListingsTab(),
            //     _buildServicesTab(),
            //     _buildTasksTab(),
            //   ],
            // ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: CommonAppBar(
        title: L10n.get("menu_my_listings"),
        showBackButton: true,
        liquidGlass: true,
      ),
      body: body,
    );
  }

  Widget _buildListingsTab() {
    return BlocSelector<ListingsBloc, ListingsState, _UserListingsData>(
      selector: (state) => state.map(
        initial: (_) => const _UserListingsData(
          isLoading: false,
          hasError: false,
          errorMessage: "",
          listings: [],
          hasMore: false,
        ),
        loading: (_) => const _UserListingsData(
          isLoading: true,
          hasError: false,
          errorMessage: "",
          listings: [],
          hasMore: false,
        ),
        loaded: (loadedState) => _UserListingsData(
          isLoading: false,
          hasError: false,
          errorMessage: "",
          listings: loadedState.listings,
          hasMore: loadedState.hasMore,
        ),
        error: (errorState) => _UserListingsData(
          isLoading: false,
          hasError: true,
          errorMessage: errorState.message,
          listings: [],
          hasMore: false,
        ),
      ),
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: HouseLoadingIndicator());
        }
        if (data.hasError) {
          return _buildListingsErrorState(data.errorMessage);
        }
        if (data.listings.isEmpty) {
          return _buildListingsEmptyState();
        }

        return UydoshRefreshIndicator(
          onRefresh: _refreshListings,
          child: PullToRefreshStretchHaptics(
            child: CommonListView(
              controller: _listingsScrollController,
              padding: const EdgeInsets.fromLTRB(16, _listTopPad, 16, 16),
              itemCount: data.listings.length + (data.hasMore ? 1 : 0),
              itemSpacing: 16,
              itemBuilder: (context, index) {
                if (index >= data.listings.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: HouseLoadingIndicator()),
                  );
                }
                final listing = data.listings[index];
                return ListingTile(
                  key: ValueKey(listing.id),
                  listing: listing,
                  forceFavorite: false,
                  showHeartIcon: false,
                  showActiveStatus: true,
                );
              },
              showRefreshIndicator: false,
              showLoadMoreIndicator: false,
              cacheExtent: 500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    if (_loadingUserId) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (_userId == null) {
      return UydoshEmptyColumn(
        icon: Icons.lock_outline_rounded,
        title: L10n.get("gigs_my_published_sign_in"),
      );
    }

    return BlocBuilder<GigOffersBloc, GigOffersState>(
      builder: (context, state) {
        if (state is GigOffersLoading || state is GigOffersInitial) {
          return const Center(child: HouseLoadingIndicator());
        }
        if (state is GigOffersError) {
          return _buildGigErrorState(
            message: state.message,
            onRetry: () => context.read<GigOffersBloc>().add(
                  FetchGigOffers(providerUserId: _userId),
                ),
          );
        }
        if (state is GigOffersLoaded) {
          if (state.offers.isEmpty) {
            return UydoshRefreshIndicator(
              onRefresh: _refreshServices,
              child: _buildGigEmptyState(
                icon: Icons.handyman_outlined,
                titleKey: "gigs_my_published_empty_services",
                publishMode: GigPublishMode.service,
              ),
            );
          }
          return UydoshRefreshIndicator(
            onRefresh: _refreshServices,
            child: PullToRefreshStretchHaptics(
              child: ListView.separated(
                controller: _servicesScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, _listTopPad, 16, 32),
                itemCount: state.offers.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.offers.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: HouseLoadingIndicator()),
                    );
                  }
                  final offer = state.offers[i];
                  return GigFeedTileSwipeWrapper(
                    entityId: offer.id,
                    enabled: UserListingState().isOwner(offer.providerUserId),
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    dismissKeyPrefix: "gig-offer-mine",
                    confirmTitleKey: "gigs_offer_delete_title",
                    confirmMessageKey: "gigs_offer_delete_message",
                    successMessageKey: "gigs_offer_delete_success",
                    errorMessageKey: "gigs_offer_delete_failed",
                    onConfirmDelete: (s) => s.deleteOffer(offer.id),
                    onRemovedFromList: () {
                      context.read<GigOffersBloc>().add(
                            RemoveGigOfferFromList(offer.id),
                          );
                    },
                    child: GigOfferTile(offer: offer),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTasksTab() {
    if (_loadingUserId) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (_userId == null) {
      return UydoshEmptyColumn(
        icon: Icons.lock_outline_rounded,
        title: L10n.get("gigs_my_published_sign_in"),
      );
    }

    return BlocBuilder<GigRequestsBloc, GigRequestsState>(
      builder: (context, state) {
        if (state is GigRequestsLoading || state is GigRequestsInitial) {
          return const Center(child: HouseLoadingIndicator());
        }
        if (state is GigRequestsError) {
          return _buildGigErrorState(
            message: state.message,
            onRetry: () => context.read<GigRequestsBloc>().add(
                  FetchGigRequests(clientUserId: _userId),
                ),
          );
        }
        if (state is GigRequestsLoaded) {
          if (state.requests.isEmpty) {
            return UydoshRefreshIndicator(
              onRefresh: _refreshTasks,
              child: _buildGigEmptyState(
                icon: Icons.assignment_outlined,
                titleKey: "gigs_my_published_empty_tasks",
                publishMode: GigPublishMode.task,
              ),
            );
          }
          return UydoshRefreshIndicator(
            onRefresh: _refreshTasks,
            child: PullToRefreshStretchHaptics(
              child: ListView.separated(
                controller: _tasksScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, _listTopPad, 16, 32),
                itemCount: state.requests.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.requests.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: HouseLoadingIndicator()),
                    );
                  }
                  final request = state.requests[i];
                  return ListenableBuilder(
                    listenable: UserListingState(),
                    builder: (context, _) {
                      final canSwipe =
                          UserListingState().isOwner(request.clientUserId) &&
                              request.status == GigRequestStatus.open;
                      return GigFeedTileSwipeWrapper(
                        entityId: request.id,
                        enabled: canSwipe,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        dismissKeyPrefix: "gig-request-mine",
                        confirmTitleKey: "gigs_request_delete_title",
                        confirmMessageKey: "gigs_request_delete_message",
                        successMessageKey: "gigs_request_delete_success",
                        errorMessageKey: "gigs_request_delete_failed",
                        onConfirmDelete: (s) => s.cancelRequest(request.id),
                        onRemovedFromList: () {
                          context.read<GigRequestsBloc>().add(
                                RemoveGigRequestFromList(request.id),
                              );
                        },
                        child: GigRequestTile(
                          request: request,
                          onDetailClosed: (feedNeedsRefresh) {
                            if (!feedNeedsRefresh || _userId == null) return;
                            context.read<GigRequestsBloc>().add(
                                  FetchGigRequests(
                                    refresh: true,
                                    clientUserId: _userId,
                                  ),
                                );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildListingsEmptyState() {
    return UydoshRefreshIndicator(
      onRefresh: _refreshListings,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeIconFactory.display(icon: Icons.home_outlined),
                  const SizedBox(height: 16),
                  Text(
                    L10n.get("my_listings_empty_state"),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _emptyStateTitleColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final label = Theme.of(context).textTheme.labelLarge;
                      final baseSize = label?.fontSize ?? 14;
                      final textStyle = label?.copyWith(
                            fontSize: baseSize * 1.2,
                            height: 1.0,
                          ) ??
                          TextStyle(
                            fontSize: baseSize * 1.2,
                            height: 1.0,
                            fontWeight: FontWeight.w500,
                          );
                      return PrimaryButtonFactory.iconText(
                        onPressed: () {
                          unawaited(showCreateChoiceSheet(context));
                        },
                        icon: Icons.add,
                        text: L10n.get("create_listing_button"),
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: textStyle,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGigEmptyState({
    required IconData icon,
    required String titleKey,
    required GigPublishMode publishMode,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIconFactory.display(icon: icon),
                const SizedBox(height: 16),
                Text(
                  L10n.get(titleKey),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: _emptyStateTitleColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButtonFactory.iconText(
                  onPressed: () async {
                    await context.pushPublishGig(initialMode: publishMode);
                    if (!mounted) return;
                    await _refreshAllTabs();
                  },
                  icon: Icons.add,
                  text: L10n.get("gigs_publish_screen_title"),
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListingsErrorState(String errorMessage) {
    return Builder(
      builder: (context) => UydoshErrorRetryColumn(
        iconColor: AppColors.error,
        title: L10n.get("error"),
        titleStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
        message: ErrorMessageHelper.sanitizeErrorMessage(
          errorMessage,
          context: context,
        ),
        messageStyle: TextStyle(
          fontSize: 14,
          color: AppColors.getThemeAwareTextColor(context).withOpacity(0.7),
        ),
        spacingAfterIcon: 24,
        spacingAfterTitle: 12,
        spacingBeforeButton: 20,
        retryButton: GhostButtonFactory.text(
          onPressed: _refreshListings,
          text: L10n.get("retry"),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGigErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return UydoshErrorRetryColumn(
      icon: Icons.error_outline_rounded,
      iconSize: 48,
      message: message,
      onRetry: onRetry,
      retryLabel: L10n.get("gigs_retry"),
      padding: const EdgeInsets.all(24),
    );
  }
}
