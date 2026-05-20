import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/gig_hub_feeds_refresh_notifier.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/pending_gig_bookings_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_requests_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_feed.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_feed_slivers.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_my_bookings_fab.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_pinned_header_delegate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_feed_tile_swipe_wrapper.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_offer_tile.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_request_tile.dart";

/// Entry point into the gig economy module: a segmented switch flips between
/// a feed of all posted services ([GigOffer]s) and a feed of open tasks
/// ([GigRequest]s) so users can browse both in one place. Plus a quick link
/// into "My bookings".
///
/// Reachable from the main app via `context.pushGigHub()` (see
/// `gig_navigation.dart`) or as the Services tab in the bottom navigation
/// bar (rendered with [embedded] = true so it doesn't draw its own
/// [Scaffold]/[AppBar]).
class GigHubScreen extends StatelessWidget {
  const GigHubScreen({super.key, this.embedded = false});

  /// When true, the screen renders only its body content, suitable for use
  /// inside a tab host (e.g. `MainNavigation`) that already provides the
  /// surrounding [Scaffold] and [AppBar].
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    // Always wrap in fresh blocs so the feeds work whether the screen is
    // hosted in `MainNavigation` (embedded) or pushed standalone.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GigOffersBloc(getIt<IGigService>())..add(const FetchGigOffers()),
        ),
        BlocProvider(
          create: (_) => GigRequestsBloc(getIt<IGigService>())
            ..add(const FetchGigRequests()),
        ),
      ],
      child: _GigHubBody(embedded: embedded),
    );
  }
}

class _GigHubBody extends StatefulWidget {
  const _GigHubBody({required this.embedded});

  final bool embedded;

  @override
  State<_GigHubBody> createState() => _GigHubBodyState();
}

class _GigHubBodyState extends State<_GigHubBody> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  GigHubFeed _feed = GigHubFeed.services;

  /// Single source of truth for the category filter applied to both feeds.
  /// `null` = "All", which corresponds to "no `category_id` query param".
  int? _selectedCategoryId;

  /// Category list comes from [GigCategoryCache] — a static, admin-ordered
  /// snapshot of `gig_categories` shipped with the app. Synchronous, so
  /// the chip ribbon renders on the first frame with no loading state.
  final List<GigCategory> _categories = GigCategoryCache.getOrdered();

  void _onAuthForPendingBookings() {
    unawaited(PendingGigBookingsState().refresh());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthenticationState().addListener(_onAuthForPendingBookings);
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    unawaited(PendingGigBookingsState().refresh());
    _scrollController.addListener(_onScroll);
    getIt<GigHubFeedsRefreshNotifier>().addListener(_onPublishFlowClosed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(PendingGigBookingsState().refresh());
    }
  }

  @override
  void dispose() {
    AuthenticationState().removeListener(_onAuthForPendingBookings);
    WidgetsBinding.instance.removeObserver(this);
    getIt<GigHubFeedsRefreshNotifier>().removeListener(_onPublishFlowClosed);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Refetch feeds after a publish flow closes (see [GigHubFeedsRefreshSignal]).
  void _onPublishFlowClosed() {
    if (!mounted) return;
    final signal = getIt<GigHubFeedsRefreshNotifier>().lastSignal;
    if (signal.refreshServices) {
      context.read<GigOffersBloc>().add(
            FetchGigOffers(
              refresh: true,
              categoryId: _selectedCategoryId,
            ),
          );
    }
    if (signal.refreshTasks) {
      context.read<GigRequestsBloc>().add(
            FetchGigRequests(
              refresh: true,
              categoryId: _selectedCategoryId,
            ),
          );
    }
    unawaited(PendingGigBookingsState().refresh());
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      switch (_feed) {
        case GigHubFeed.services:
          context.read<GigOffersBloc>().add(const LoadMoreGigOffers());
        case GigHubFeed.tasks:
          context.read<GigRequestsBloc>().add(const LoadMoreGigRequests());
      }
    }
  }

  void _onFeedChanged(GigHubFeed next) {
    if (next == _feed) return;
    setState(() => _feed = next);
    // Jump back to the top when switching feeds so the user lands at the
    // start of the new list rather than at a stale offset.
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    // If the destination feed's bloc was loaded under a different category
    // (e.g. user changed category on the active feed but never visited the
    // other), refetch so it reflects the current filter.
    _ensureFeedMatchesSelectedCategory(next);
  }

  void _ensureFeedMatchesSelectedCategory(GigHubFeed feed) {
    switch (feed) {
      case GigHubFeed.services:
        final s = context.read<GigOffersBloc>().state;
        if (s is GigOffersLoaded && s.categoryId == _selectedCategoryId) {
          return;
        }
        context.read<GigOffersBloc>().add(
              FetchGigOffers(categoryId: _selectedCategoryId),
            );
      case GigHubFeed.tasks:
        final s = context.read<GigRequestsBloc>().state;
        if (s is GigRequestsLoaded && s.categoryId == _selectedCategoryId) {
          return;
        }
        context.read<GigRequestsBloc>().add(
              FetchGigRequests(categoryId: _selectedCategoryId),
            );
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (categoryId == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    UiFeedbackUtils.selection();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    // Refetch the active feed immediately for instant feedback; the inactive
    // feed self-heals via [_ensureFeedMatchesSelectedCategory] when the user
    // switches to it.
    switch (_feed) {
      case GigHubFeed.services:
        context.read<GigOffersBloc>().add(
              FetchGigOffers(categoryId: categoryId),
            );
      case GigHubFeed.tasks:
        context.read<GigRequestsBloc>().add(
              FetchGigRequests(categoryId: categoryId),
            );
    }
  }

  Future<void> _onRefresh() async {
    switch (_feed) {
      case GigHubFeed.services:
        context.read<GigOffersBloc>().add(
              FetchGigOffers(
                refresh: true,
                categoryId: _selectedCategoryId,
              ),
            );
      case GigHubFeed.tasks:
        context.read<GigRequestsBloc>().add(
              FetchGigRequests(
                refresh: true,
                categoryId: _selectedCategoryId,
              ),
            );
    }
    await PendingGigBookingsState().refresh();
  }

  /// Empty-state icon: category glyph when a filter chip is selected, otherwise
  /// the generic feed icon ("All").
  IconData _emptyStateIcon({required IconData allFeedIcon}) {
    final id = _selectedCategoryId;
    if (id == null) {
      return allFeedIcon;
    }
    for (final c in _categories) {
      if (c.id == id) {
        return gigCategoryIcon(c.code);
      }
    }
    return allFeedIcon;
  }

  /// Height of [CustomCurvedNavigationBar] / package bar (see shell widget).
  static const double _kCurvedBottomBarHeight = 70.0;

  /// When embedded in [MainNavigation] with the blue shell, [Scaffold.extendBody]
  /// lets the tab paint under the curved bar. Prefer [MediaQuery.padding.bottom]
  /// from the shell [_BodyBuilder], but on **web** it is often `0`; keep at least
  /// [_kCurvedBottomBarHeight] so FABs are not tucked under the nav layer.
  double _mainShellExtendBodyBottomInset(BuildContext context) {
    if (!widget.embedded || !ThemeState().isBlueTheme) {
      return 0;
    }
    final mq = MediaQuery.of(context);
    final fromView = math.max(mq.padding.bottom, mq.viewPadding.bottom);
    return math.max(_kCurvedBottomBarHeight, fromView);
  }

  @override
  Widget build(BuildContext context) {
    // When hosted inside `MainNavigation`, the shell uses
    // `extendBodyBehindAppBar`, so this body would render under the app bar
    // unless we offset by the device top padding the same way other main
    // tabs (e.g. Favorites, Home) do.
    // Match [MessagesInboxScreen._buildTabbedConversationsList]: outer
    // `Padding(top: mainShellGlassExtraTopInset)` only — the first 8 px below
    // the shell header come from `EdgeInsets.fromLTRB(16, 8, 16, 12)` around
    // the toggle (not duplicated here).
    final topPad = widget.embedded
        ? ThemeState().mainShellGlassExtraTopInset(context)
        : 16.0;

    final body = ListenableBuilder(
      listenable: AuthenticationState(),
      builder: (context, _) {
        final signedIn = AuthenticationState().isAuthenticated;
        final shellBottomInset = _mainShellExtendBodyBottomInset(context);
        // Single "My bookings" control (label + circular button) when signed in.
        final bottomClearance =
            (signedIn ? 104.0 : 16.0) + shellBottomInset;

        final scrollable = UydoshRefreshIndicator.mainShell(
          onRefresh: _onRefresh,
          edgeOffset: topPad,
          child: PullToRefreshStretchHaptics(
            child: CustomScrollView(
              controller: _scrollController,
              // Allow pull-to-refresh even when the body is short / empty.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Pinned header keeps the feed switch + category ribbon visible
                // while the underlying list scrolls, so users can change feed or
                // category without scrolling back to the top first.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: GigHubPinnedHeaderDelegate(
                    topPadding: topPad,
                    feed: _feed,
                    onFeedChanged: _onFeedChanged,
                    categories: _categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                ..._buildFeedSlivers(context, bottomClearance),
                // Bottom padding clears the floating bookings control when shown.
                SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomClearance),
                ),
              ],
            ),
          ),
        );

        // Place the FAB ourselves (instead of using `Scaffold.floatingActionButton`)
        // so it works identically whether the screen is embedded inside the
        // tab host's `Scaffold` or pushed standalone.
        return Stack(
          children: [
            Positioned.fill(child: scrollable),
            if (signedIn)
              Positioned(
                right: 16,
                bottom: 16 + shellBottomInset,
                child: const GigHubMyBookingsFab(),
              ),
          ],
        );
      },
    );

    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_hub_title")),
        actions: [
          ListenableBuilder(
            listenable: Listenable.merge([
              AuthenticationState(),
              ActiveSearchAlertsState(),
            ]),
            builder: (context, _) {
              final signedIn = AuthenticationState().isAuthenticated;
              if (!signedIn) return const SizedBox.shrink();

              final activeAlerts =
                  ActiveSearchAlertsState().hasActiveEnabledAlerts;
              return IconButton(
                tooltip: L10n.get("menu_notifications"),
                icon: Icon(
                  activeAlerts
                      ? Icons.notifications_active
                      : Icons.notifications_none_outlined,
                ),
                onPressed: () => context.pushNotifications(),
              );
            },
          ),
        ],
      ),
      body: body,
    );
  }

  List<Widget> _buildFeedSlivers(
    BuildContext context,
    double bottomClearanceForFab,
  ) {
    switch (_feed) {
      case GigHubFeed.services:
        return _servicesFeedSlivers(bottomClearanceForFab);
      case GigHubFeed.tasks:
        return _tasksFeedSlivers(bottomClearanceForFab);
    }
  }

  List<Widget> _servicesFeedSlivers(double bottomClearanceForFab) {
    return [
      BlocBuilder<GigOffersBloc, GigOffersState>(
        builder: (context, state) {
          if (state is GigOffersLoading || state is GigOffersInitial) {
            return const GigHubLoadingSliver();
          }
          if (state is GigOffersError) {
            return GigHubErrorSliver(
              message: state.message,
              onRetry: () =>
                  context.read<GigOffersBloc>().add(const FetchGigOffers()),
            );
          }
          if (state is GigOffersLoaded) {
            if (state.offers.isEmpty) {
              return GigHubEmptySliver(
                icon: _emptyStateIcon(allFeedIcon: Icons.handyman_outlined),
                message: L10n.get("gigs_browse_empty"),
                bottomPadding: bottomClearanceForFab,
              );
            }
            final itemCount = state.offers.length + (state.hasMore ? 1 : 0);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList.separated(
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.offers.length) {
                    return const GigHubLoadingMoreFooter();
                  }
                  final offer = state.offers[i];
                  return ListenableBuilder(
                    listenable: UserListingState(),
                    builder: (context, _) {
                      final isOwner = UserListingState().isOwner(
                        offer.providerUserId,
                      );
                      return GigFeedTileSwipeWrapper(
                        entityId: offer.id,
                        enabled: isOwner,
                        notifyGigHubFeedsOnDelete: false,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        dismissKeyPrefix: "gig-offer-hub",
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
                        child: GigOfferTile(
                          offer: offer,
                          showFavoriteIndicator: PeerInteractionEligibility
                              .mayInteractWithPublisher(
                            publisherUserId: offer.providerUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }

  List<Widget> _tasksFeedSlivers(double bottomClearanceForFab) {
    return [
      BlocBuilder<GigRequestsBloc, GigRequestsState>(
        builder: (context, state) {
          if (state is GigRequestsLoading || state is GigRequestsInitial) {
            return const GigHubLoadingSliver();
          }
          if (state is GigRequestsError) {
            return GigHubErrorSliver(
              message: state.message,
              onRetry: () =>
                  context.read<GigRequestsBloc>().add(const FetchGigRequests()),
            );
          }
          if (state is GigRequestsLoaded) {
            if (state.requests.isEmpty) {
              return GigHubEmptySliver(
                icon: _emptyStateIcon(allFeedIcon: Icons.assignment_outlined),
                message: L10n.get("gigs_requests_empty"),
                bottomPadding: bottomClearanceForFab,
              );
            }
            final itemCount = state.requests.length + (state.hasMore ? 1 : 0);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList.separated(
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.requests.length) {
                    return const GigHubLoadingMoreFooter();
                  }
                  final request = state.requests[i];
                  return ListenableBuilder(
                    listenable: UserListingState(),
                    builder: (context, _) {
                      final isOwner = UserListingState().isOwner(
                            request.clientUserId,
                          ) &&
                          request.status == GigRequestStatus.open;
                      return GigFeedTileSwipeWrapper(
                        entityId: request.id,
                        enabled: isOwner,
                        notifyGigHubFeedsOnDelete: false,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        dismissKeyPrefix: "gig-request-hub",
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
                          showFavoriteIndicator: PeerInteractionEligibility
                              .mayInteractWithPublisher(
                            publisherUserId: request.clientUserId,
                          ),
                          onDetailClosed: (feedNeedsRefresh) {
                            if (!feedNeedsRefresh) return;
                            context.read<GigRequestsBloc>().add(
                                  FetchGigRequests(
                                    refresh: true,
                                    categoryId: _selectedCategoryId,
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
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }
}
