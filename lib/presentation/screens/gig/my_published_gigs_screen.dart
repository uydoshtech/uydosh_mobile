import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/gig_hub_feeds_refresh_notifier.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_requests_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_feed_tile_swipe_wrapper.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_offer_tile.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_request_tile.dart";

/// Services vs tasks segments for "what I published".
enum _PublishedTab { services, tasks }

/// Lists gig offers and tasks the signed-in user has posted (`provider_user_id`
/// / `client_user_id` filters on the API).
class MyPublishedGigsScreen extends StatefulWidget {
  const MyPublishedGigsScreen({super.key});

  @override
  State<MyPublishedGigsScreen> createState() => _MyPublishedGigsScreenState();
}

class _MyPublishedGigsScreenState extends State<MyPublishedGigsScreen> {
  int? _userId;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    SessionManager.getUserId().then((id) {
      if (!mounted) return;
      setState(() {
        _userId = id;
        _loadingUser = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(
        appBar: AppBar(
          leading: ThreeDAppBarIconButton.backLeading(context),
          title: Text(L10n.get("gigs_my_published_title")),
        ),
        body: const Center(child: HouseLoadingIndicator()),
      );
    }
    final uid = _userId;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          leading: ThreeDAppBarIconButton.backLeading(context),
          title: Text(L10n.get("gigs_my_published_title")),
        ),
        body: UydoshEmptyColumn(
          icon: Icons.lock_outline_rounded,
          title: L10n.get("gigs_my_published_sign_in"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_my_published_title")),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => GigOffersBloc(getIt<IGigService>())
              ..add(
                FetchGigOffers(providerUserId: uid),
              ),
          ),
          BlocProvider(
            create: (_) => GigRequestsBloc(getIt<IGigService>())
              ..add(
                FetchGigRequests(clientUserId: uid),
              ),
          ),
        ],
        child: _MyPublishedLists(userId: uid),
      ),
    );
  }
}

class _MyPublishedLists extends StatefulWidget {
  const _MyPublishedLists({required this.userId});

  final int userId;

  @override
  State<_MyPublishedLists> createState() => _MyPublishedListsState();
}

class _MyPublishedListsState extends State<_MyPublishedLists> {
  _PublishedTab _tab = _PublishedTab.services;
  bool _didAutoSelectInitialTab = false;
  final _servicesScroll = ScrollController();
  final _tasksScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _servicesScroll.addListener(_onServicesScroll);
    _tasksScroll.addListener(_onTasksScroll);
    getIt<GigHubFeedsRefreshNotifier>().addListener(_onHubFeedsRefreshSignal);
  }

  @override
  void dispose() {
    getIt<GigHubFeedsRefreshNotifier>()
        .removeListener(_onHubFeedsRefreshSignal);
    _servicesScroll.dispose();
    _tasksScroll.dispose();
    super.dispose();
  }

  void _onHubFeedsRefreshSignal() {
    if (!mounted) return;
    context.read<GigOffersBloc>().add(
          FetchGigOffers(
            refresh: true,
            providerUserId: widget.userId,
          ),
        );
    context.read<GigRequestsBloc>().add(
          FetchGigRequests(
            refresh: true,
            clientUserId: widget.userId,
          ),
        );
  }

  void _onServicesScroll() {
    if (!_servicesScroll.hasClients) return;
    if (_servicesScroll.position.pixels >=
        _servicesScroll.position.maxScrollExtent - 200) {
      context.read<GigOffersBloc>().add(const LoadMoreGigOffers());
    }
  }

  void _onTasksScroll() {
    if (!_tasksScroll.hasClients) return;
    if (_tasksScroll.position.pixels >=
        _tasksScroll.position.maxScrollExtent - 200) {
      context.read<GigRequestsBloc>().add(const LoadMoreGigRequests());
    }
  }

  void _onTabChanged(_PublishedTab next) {
    if (next == _tab) return;
    setState(() => _tab = next);
  }

  /// Open tasks when services are empty (or failed) but tasks have rows.
  void _tryAutoSelectInitialTab() {
    if (_didAutoSelectInitialTab || !mounted) return;
    final offersState = context.read<GigOffersBloc>().state;
    final requestsState = context.read<GigRequestsBloc>().state;

    final offersSettled =
        offersState is GigOffersLoaded || offersState is GigOffersError;
    final requestsSettled = requestsState is GigRequestsLoaded ||
        requestsState is GigRequestsError;
    if (!offersSettled || !requestsSettled) return;

    final hasServices = offersState is GigOffersLoaded &&
        offersState.offers.isNotEmpty;
    final hasTasks = requestsState is GigRequestsLoaded &&
        requestsState.requests.isNotEmpty;

    _didAutoSelectInitialTab = true;

    if (!hasServices && hasTasks) {
      setState(() => _tab = _PublishedTab.tasks);
    }
  }

  Future<void> _refreshServices() async {
    final bloc = context.read<GigOffersBloc>();
    bloc.add(
      FetchGigOffers(
        refresh: true,
        providerUserId: widget.userId,
      ),
    );
    await bloc.stream
        .where((s) => s is GigOffersLoaded || s is GigOffersError)
        .first;
  }

  Future<void> _refreshTasks() async {
    final bloc = context.read<GigRequestsBloc>();
    bloc.add(
      FetchGigRequests(
        refresh: true,
        clientUserId: widget.userId,
      ),
    );
    await bloc.stream
        .where((s) => s is GigRequestsLoaded || s is GigRequestsError)
        .first;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GigOffersBloc, GigOffersState>(
          listener: (_, __) => _tryAutoSelectInitialTab(),
        ),
        BlocListener<GigRequestsBloc, GigRequestsState>(
          listener: (_, __) => _tryAutoSelectInitialTab(),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: NeumorphicSegmentedSwitch<_PublishedTab>(
              value: _tab,
              onChanged: _onTabChanged,
              entries: [
                SegmentedSwitchEntry(
                  value: _PublishedTab.services,
                  label: L10n.get("gigs_my_published_tab_services"),
                  icon: Icons.handyman_outlined,
                ),
                SegmentedSwitchEntry(
                  value: _PublishedTab.tasks,
                  label: L10n.get("gigs_my_published_tab_tasks"),
                  icon: Icons.assignment_outlined,
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab == _PublishedTab.services ? 0 : 1,
              children: [
                _ServicesListView(
                  scrollController: _servicesScroll,
                  userId: widget.userId,
                  onRefresh: _refreshServices,
                ),
                _TasksListView(
                  scrollController: _tasksScroll,
                  userId: widget.userId,
                  onRefresh: _refreshTasks,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesListView extends StatelessWidget {
  const _ServicesListView({
    required this.scrollController,
    required this.userId,
    required this.onRefresh,
  });

  final ScrollController scrollController;
  final int userId;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GigOffersBloc, GigOffersState>(
      builder: (context, state) {
        if (state is GigOffersLoading || state is GigOffersInitial) {
          return const Center(child: HouseLoadingIndicator());
        }
        if (state is GigOffersError) {
          return _ErrorBody(
            message: state.message,
            onRetry: () => context.read<GigOffersBloc>().add(
                  FetchGigOffers(providerUserId: userId),
                ),
          );
        }
        if (state is GigOffersLoaded) {
          if (state.offers.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: UydoshEmptyColumn(
                icon: Icons.handyman_outlined,
                title: L10n.get("gigs_my_published_empty_services"),
                fillViewportForRefresh: true,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TasksListView extends StatelessWidget {
  const _TasksListView({
    required this.scrollController,
    required this.userId,
    required this.onRefresh,
  });

  final ScrollController scrollController;
  final int userId;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GigRequestsBloc, GigRequestsState>(
      builder: (context, state) {
        if (state is GigRequestsLoading || state is GigRequestsInitial) {
          return const Center(child: HouseLoadingIndicator());
        }
        if (state is GigRequestsError) {
          return _ErrorBody(
            message: state.message,
            onRetry: () => context.read<GigRequestsBloc>().add(
                  FetchGigRequests(clientUserId: userId),
                ),
          );
        }
        if (state is GigRequestsLoaded) {
          if (state.requests.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: UydoshEmptyColumn(
                icon: Icons.assignment_outlined,
                title: L10n.get("gigs_my_published_empty_tasks"),
                fillViewportForRefresh: true,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
                    final canSwipe = UserListingState().isOwner(
                          request.clientUserId,
                        ) &&
                        request.status == GigRequestStatus.open;
                    return GigFeedTileSwipeWrapper(
                      entityId: request.id,
                      enabled: canSwipe,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16)),
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
                        onDetailClosed: (removed) {
                          if (!removed) return;
                          context.read<GigRequestsBloc>().add(
                                FetchGigRequests(
                                  refresh: true,
                                  clientUserId: userId,
                                ),
                              );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButtonFactory.text(
              onPressed: onRetry,
              text: L10n.get("gigs_retry"),
            ),
          ],
        ),
      ),
    );
  }
}
