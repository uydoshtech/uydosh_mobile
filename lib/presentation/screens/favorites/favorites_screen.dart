import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/common/auth_required_state.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/roll_up_fade_out.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_offer_tile.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_request_tile.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_tab_ribbon.dart";

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  static const int _pageLimit = 50; // Page size for API calls

  List<Listing> _favoriteListings = [];
  List<GigOffer> _favoriteOffers = [];
  List<GigRequest> _favoriteRequests = [];
  final Set<int> _itemsBeingRemoved =
      {}; // Track items being removed for animation
  final Map<int, ({Listing listing, int index})> _optimisticallyRemoved =
      {}; // Rollback buffer for optimistic removals
  final Map<int, Timer> _listingRemovalCommitTimers =
      {}; // Deferred list removal — must cancel on rollback/dispose

  void _cancelListingRemovalCommitTimer(int listingId) {
    _listingRemovalCommitTimers.remove(listingId)?.cancel();
  }

  void _cancelAllListingRemovalCommitTimers() {
    for (final t in _listingRemovalCommitTimers.values) {
      t.cancel();
    }
    _listingRemovalCommitTimers.clear();
  }

  bool _needsSyncFromDirty = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _offersHasMore = true;
  bool _requestsHasMore = true;
  bool _isLoadingMoreOffers = false;
  bool _isLoadingMoreRequests = false;
  int _offersPage = 1;
  int _requestsPage = 1;
  bool _hasError = false; // Add error state
  int _currentPage = 1;
  late final IFavoriteService _favoriteService;
  late final IGigService _gigService;
  late final TabController _tabController;
  late final VoidCallback _authListener;
  late final VoidCallback _favoritesDirtyListener;
  bool _hasInitialized = false; // Track if initial load has been done
  /// After the first full favorites load (listings + gig sync), pick the first
  /// tab that has at least one item. Only runs once per signed-in session on
  /// this screen until logout (see [_resetInitialization]).
  bool _hasAppliedInitialFavoriteTab = false;
  // Track the previous auth state so the listener only fires a rebuild/reload
  // when the `isAuthenticated` bit actually flips. AuthenticationState emits
  // for unrelated side changes (e.g. token refresh) and previously caused the
  // whole favorites list to reset + re-fetch on every notification.
  bool _lastAuthenticated = false;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "favorites");
    _favoriteService = getIt<IFavoriteService>();
    _gigService = getIt<IGigService>();
    _tabController = TabController(
      length: AppConfig.servicesFeatureEnabled ? 3 : 1,
      vsync: this,
    );

    _lastAuthenticated = AuthenticationState().isAuthenticated;

    _authListener = () {
      if (!mounted) return;
      final isAuth = AuthenticationState().isAuthenticated;
      if (isAuth == _lastAuthenticated) {
        // Auth bit didn't actually change — ignore this notification.
        // (Token refresh, profile hydration, etc. shouldn't reset the list.)
        return;
      }
      _lastAuthenticated = isAuth;
      _resetInitialization();
      if (!isAuth) {
        _cancelAllListingRemovalCommitTimers();
        // Logged out: clear the list so the signed-out empty state shows.
        _favoriteListings = [];
        _favoriteOffers = [];
        _favoriteRequests = [];
        _hasMoreData = true;
        _offersHasMore = true;
        _requestsHasMore = true;
        _offersPage = 1;
        _requestsPage = 1;
        _currentPage = 1;
        _hasError = false;
        _hasAppliedInitialFavoriteTab = false;
      }
      setState(() {});
      if (isAuth) {
        // Logged back in: refresh.
        _loadFavoriteListings(isRefresh: true);
      }
    };

    AuthenticationState().addListener(_authListener);

    _favoritesDirtyListener = () {
      if (!mounted) return;
      if (!AuthenticationState().isAuthenticated) return;
      if (!FavoritesState().isDirty) return;

      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (!isCurrent) {
        _needsSyncFromDirty = true;
        return;
      }

      _needsSyncFromDirty = false;
      _loadFavoriteListings(isRefresh: true);
    };
    FavoritesState().dirtyListenable.addListener(_favoritesDirtyListener);

    _initializeAndLoadFavorites();
  }

  Future<void> _initializeAndLoadFavorites() async {
    // Wait for authentication state to be fully initialized
    if (!AuthenticationState().isInitialized) {
      await AuthenticationState().initialize();
    }

    // Only load favorites if user is authenticated
    if (AuthenticationState().isAuthenticated) {
      _loadFavoriteListings(isRefresh: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload favorites if we haven't initialized yet and user is authenticated
    if (!_hasInitialized &&
        (ModalRoute.of(context)?.isCurrent ?? false) &&
        AuthenticationState().isAuthenticated) {
      _loadFavoriteListings(isRefresh: true);
    }

    // If something was favorited elsewhere (home) while this tab wasn't current,
    // sync once when we become visible again.
    if (_needsSyncFromDirty &&
        (ModalRoute.of(context)?.isCurrent ?? false) &&
        AuthenticationState().isAuthenticated &&
        FavoritesState().isDirty) {
      _needsSyncFromDirty = false;
      _loadFavoriteListings(isRefresh: true);
    }
  }

  @override
  void dispose() {
    _cancelAllListingRemovalCommitTimers();
    // Remove the authentication state listener
    _tabController.dispose();
    AuthenticationState().removeListener(_authListener);
    FavoritesState().dirtyListenable.removeListener(_favoritesDirtyListener);
    super.dispose();
  }

  // Reset initialization flag when user logs out
  void _resetInitialization() {
    _hasInitialized = false;
    _hasAppliedInitialFavoriteTab = false;
  }

  /// Opens the first tab (listings → services → tasks) that has at least one
  /// favorite, once per [FavoritesScreen] visit after data is available.
  void _applyInitialFavoriteTabSelectionIfNeeded() {
    if (!mounted) return;
    if (_hasAppliedInitialFavoriteTab) return;
    if (!AuthenticationState().isAuthenticated) return;

    final firstWithItems = _firstFavoriteTabWithItems();
    _hasAppliedInitialFavoriteTab = true;

    if (firstWithItems == null || firstWithItems == _tabController.index) {
      return;
    }

    _tabController.index = firstWithItems;
    setState(() {});
  }

  /// `null` if every list is empty.
  int? _firstFavoriteTabWithItems() {
    if (_favoriteListings.isNotEmpty) return 0;
    if (!AppConfig.servicesFeatureEnabled) return null;
    if (_favoriteOffers.isNotEmpty) return 1;
    if (_favoriteRequests.isNotEmpty) return 2;
    return null;
  }

  Future<void> _loadFavoriteListings({bool isRefresh = false}) async {
    // Check authentication status first
    if (!AuthenticationState().isAuthenticated) {
      logger.d(
        "❌ FavoritesScreen: User not authenticated, cannot load favorites",
      );
      if (!mounted) return;
      setStateIfMounted(() {
        _favoriteListings = [];
        _isLoading = false;
        _hasError = false; // No error, just not authenticated
      });
      return;
    }

    // Prevent multiple simultaneous calls
    if (_isLoading) {
      logger.d("⚠️ FavoritesScreen: Already loading, skipping duplicate call");
      return;
    }

    if (isRefresh) {
      _cancelAllListingRemovalCommitTimers();
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _favoriteListings.clear();
        _itemsBeingRemoved.clear();
        _optimisticallyRemoved.clear();
      });
    }

    setState(() {
      _isLoading = true;
    });

    // Mark as initialized after first successful load
    if (isRefresh) {
      _hasInitialized = true;
    }

    try {
      // Check if user is authenticated
      final token = await SessionManager.getToken();
      final userId = await SessionManager.getUserId();
      final isAuthenticated = await SessionManager.isAuthenticated();

      logger.d("🔐 FavoritesScreen: Token exists: ${token != null}");
      logger.d("🔐 FavoritesScreen: User ID: $userId");
      logger.d("🔐 FavoritesScreen: Is authenticated: $isAuthenticated");
      if (token != null) {
        logger.d("🔐 FavoritesScreen: Token length: ${token.length}");
      }

      if (!isAuthenticated) {
        logger.d(
          "❌ FavoritesScreen: User not authenticated, cannot load favorites",
        );
        if (!mounted) return;
        setStateIfMounted(() {
          _favoriteListings = [];
          _isLoading = false;
          _hasError = false; // No error, just not authenticated
        });
        return;
      }

      logger.d(
        "🌐 FavoritesScreen: Loading favorites (page $_currentPage, limit: $_pageLimit)",
      );
      final favoriteListings = await _favoriteService.getUserFavorites(
        page: _currentPage,
        limit: _pageLimit,
      );

      setStateIfMounted(() {
        if (isRefresh) {
          _favoriteListings = favoriteListings;
        } else {
          _favoriteListings.addAll(favoriteListings);
        }
        _hasMoreData = favoriteListings.length >=
            _pageLimit; // If we got less than limit, no more data
        _isLoading = false;
        _hasError = false; // Clear error state on success
      });

      // Everything returned by the favorites endpoint is, by definition, a
      // favorite. Seed the global FavoritesState so ListingTile hearts render
      // filled immediately (the /favorites payload doesn't always carry the
      // per-listing isFavorited flag, so syncFromListings alone isn't enough).
      final favoritesState = FavoritesState();
      for (final listing in favoriteListings) {
        unawaited(favoritesState.addToFavorites(listing.id));
      }

      // We've re-synced with backend; clear the dirty flag.
      favoritesState.clearDirty();
      if (AppConfig.servicesFeatureEnabled) {
        unawaited(_syncGigFavoriteLists(isRefresh: isRefresh));
      } else {
        _applyInitialFavoriteTabSelectionIfNeeded();
      }
    } catch (e) {
      logger.d("❌ FavoritesScreen: Error loading favorite listings: $e");

      // Check if this is an authentication error
      final isAuthError = e.toString().contains("401") ||
          e.toString().contains("Unauthorized") ||
          e.toString().contains("Invalid or expired session token");

      setStateIfMounted(() {
        if (isRefresh) {
          _favoriteListings = [];
        }
        _isLoading = false;
        _hasError = true; // Set error state
      });

      // Show appropriate error message based on error type
      String errorMessage;

      if (isAuthError) {
        errorMessage =
            "Authentication required. Please log in again to view your favorites.";
      } else if (e.toString().contains("network") ||
          e.toString().contains("connection")) {
        errorMessage =
            "Network error. Please check your connection and try again.";
      } else {
        errorMessage = L10n.get("unable_to_load_favorites");
      }

      if (isAuthError) {
        ToastTheme.showInfo(context, message: errorMessage);
      } else {
        ToastTheme.showError(context, message: errorMessage);
      }
    }
  }

  Future<void> _syncGigFavoriteLists({required bool isRefresh}) async {
    if (!AppConfig.servicesFeatureEnabled) return;
    if (!AuthenticationState().isAuthenticated) return;
    try {
      if (isRefresh) {
        _offersPage = 1;
        _requestsPage = 1;
      }
      final offers = await _gigService.listFavoriteOffers(
        page: _offersPage,
        limit: _pageLimit,
      );
      final requests = await _gigService.listFavoriteRequests(
        page: _requestsPage,
        limit: _pageLimit,
      );
      if (!mounted) return;
      setStateIfMounted(() {
        if (isRefresh) {
          _favoriteOffers = offers.offers;
          _favoriteRequests = requests.requests;
        } else {
          _favoriteOffers.addAll(offers.offers);
          _favoriteRequests.addAll(requests.requests);
        }
        _offersHasMore = offers.hasMore;
        _requestsHasMore = requests.hasMore;
      });
      final gs = GigFavoritesState();
      for (final o in offers.offers) {
        gs.markOfferFavorited(o.id);
      }
      for (final r in requests.requests) {
        gs.markRequestFavorited(r.id);
      }
    } catch (_) {
      // Non-fatal: housing favorites are primary payload.
    } finally {
      _applyInitialFavoriteTabSelectionIfNeeded();
    }
  }

  Future<void> _loadMoreFavorites() async {
    if (_isLoadingMore || !_hasMoreData) return;

    // Check authentication status
    if (!AuthenticationState().isAuthenticated) {
      logger.d(
        "❌ FavoritesScreen: User not authenticated, cannot load more favorites",
      );
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      logger.d(
        "🌐 FavoritesScreen: Loading more favorites (page $_currentPage)",
      );

      final moreFavorites = await _favoriteService.getUserFavorites(
        page: _currentPage,
        limit: _pageLimit,
      );

      setStateIfMounted(() {
        _favoriteListings.addAll(moreFavorites);
        _hasMoreData = moreFavorites.length >= _pageLimit;
        _isLoadingMore = false;
      });

      logger.d(
        "✅ FavoritesScreen: Loaded ${moreFavorites.length} more favorites (total: ${_favoriteListings.length})",
      );
    } catch (e) {
      logger.d("❌ FavoritesScreen: Error loading more favorites: $e");
      _currentPage--; // Revert page increment
      setStateIfMounted(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreFavoriteOffers() async {
    if (_isLoadingMoreOffers || !_offersHasMore) return;
    if (!AuthenticationState().isAuthenticated) return;
    setState(() => _isLoadingMoreOffers = true);
    try {
      _offersPage++;
      final res = await _gigService.listFavoriteOffers(
        page: _offersPage,
        limit: _pageLimit,
      );
      setStateIfMounted(() {
        _favoriteOffers.addAll(res.offers);
        _offersHasMore = res.hasMore;
        _isLoadingMoreOffers = false;
      });
      final gs = GigFavoritesState();
      for (final o in res.offers) {
        gs.markOfferFavorited(o.id);
      }
    } catch (e) {
      logger.d("❌ FavoritesScreen: Error loading more offers: $e");
      _offersPage--;
      setStateIfMounted(() => _isLoadingMoreOffers = false);
    }
  }

  Future<void> _loadMoreFavoriteRequests() async {
    if (_isLoadingMoreRequests || !_requestsHasMore) return;
    if (!AuthenticationState().isAuthenticated) return;
    setState(() => _isLoadingMoreRequests = true);
    try {
      _requestsPage++;
      final res = await _gigService.listFavoriteRequests(
        page: _requestsPage,
        limit: _pageLimit,
      );
      setStateIfMounted(() {
        _favoriteRequests.addAll(res.requests);
        _requestsHasMore = res.hasMore;
        _isLoadingMoreRequests = false;
      });
      final gs = GigFavoritesState();
      for (final r in res.requests) {
        gs.markRequestFavorited(r.id);
      }
    } catch (e) {
      logger.d("❌ FavoritesScreen: Error loading more tasks: $e");
      _requestsPage--;
      setStateIfMounted(() => _isLoadingMoreRequests = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthenticationState(),
      builder: (context, _) {
        if (widget.embedded) {
          return ListenableBuilder(
            listenable: ThemeState(),
            builder: (context, child) => _buildBody(),
          );
        }

        // Standalone routes from the drawer/profile keep their own AppBar.
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(L10n.get("favorites_title")),
            leading: ThreeDAppBarIconButton.backLeading(context),
          ),
          body: ListenableBuilder(
            listenable: ThemeState(),
            builder: (context, child) => _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    // Check authentication status first
    if (!AuthenticationState().isAuthenticated) {
      return _buildAuthenticationRequiredState();
    }

    if (_isLoading) {
      return CenteredHouseLoadingIndicator(
        text: L10n.get("loading"),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    const listTopPad = 8.0;
    if (!AppConfig.servicesFeatureEnabled) {
      return _buildListingsFavoritesTab(listTopPad);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: LanguageState(),
          builder: (context, _) {
            return AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                return FavoritesTabRibbon(
                  tabController: _tabController,
                  listingsLabel: L10n.get("favorites_tab_listings"),
                  servicesLabel: L10n.get("favorites_tab_services"),
                  tasksLabel: L10n.get("favorites_tab_tasks"),
                );
              },
            );
          },
        ),
        const SizedBox(height: 6),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildListingsFavoritesTab(listTopPad),
              _buildOffersFavoritesTab(listTopPad),
              _buildRequestsFavoritesTab(listTopPad),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingsFavoritesTab(double topPad) {
    if (_favoriteListings.isEmpty) {
      return _buildEmptyState();
    }

    return UydoshRefreshIndicator.mainShell(
      onRefresh: () => _loadFavoriteListings(isRefresh: true),
      edgeOffset: topPad,
      child: PullToRefreshStretchHaptics(
        child: CommonListView(
          padding: EdgeInsets.fromLTRB(16.0, topPad, 16.0, 16.0),
          itemCount: _favoriteListings.length,
          itemSpacing: 16.0,
          itemBuilder: (context, index) {
            final listing = _favoriteListings[index];

            final isRemoving = _itemsBeingRemoved.contains(listing.id);
            const duration = Duration(milliseconds: 300);

            final tile = ListingTile(
              key: ValueKey("fav-${listing.id}-tile"),
              listing: listing,
              forceFavorite: true,
              showHeartIcon: false,
              showFavoriteIndicator: true,
              onFavoriteRemoved: () {
                if (!mounted) return;
                if (!_optimisticallyRemoved.containsKey(listing.id)) {
                  _optimisticallyRemoved[listing.id] = (
                    listing: listing,
                    index: index,
                  );
                }
                setState(() {
                  _itemsBeingRemoved.add(listing.id);
                });

                final id = listing.id;
                _cancelListingRemovalCommitTimer(id);
                _listingRemovalCommitTimers[id] = Timer(duration, () {
                  _listingRemovalCommitTimers.remove(id);
                  setStateIfMounted(() {
                    _itemsBeingRemoved.remove(id);
                    _favoriteListings.removeWhere((l) => l.id == id);
                    _optimisticallyRemoved.remove(id);
                  });
                });
              },
              onFavoriteRemovalFailed: () {
                if (!mounted) return;
                _cancelListingRemovalCommitTimer(listing.id);
                final backup = _optimisticallyRemoved.remove(listing.id);
                if (backup == null) return;

                setState(() {
                  _itemsBeingRemoved.remove(listing.id);
                  final safeIndex = backup.index.clamp(
                    0,
                    _favoriteListings.length,
                  );
                  _favoriteListings.insert(safeIndex, backup.listing);
                });
              },
            );

            if (!isRemoving) return tile;

            return RollUpFadeOut(duration: duration, child: tile);
          },
          showRefreshIndicator: false,
          showLoadMoreIndicator: _hasMoreData,
          hasMore: _hasMoreData,
          loadMoreIndicator: _isLoadingMore
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getLoadingIndicatorColor(),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: GhostButtonFactory.text(
                      onPressed: _loadMoreFavorites,
                      text: L10n.get("load_more"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOffersFavoritesTab(double topPad) {
    if (_favoriteOffers.isEmpty) {
      return _buildGigEmptyTab(
        topPad: topPad,
        icon: Icons.handyman_outlined,
        browseLabelKey: "gigs_browse_title",
      );
    }

    return UydoshRefreshIndicator.mainShell(
      onRefresh: () => _loadFavoriteListings(isRefresh: true),
      edgeOffset: topPad,
      child: PullToRefreshStretchHaptics(
        child: CommonListView(
          padding: EdgeInsets.fromLTRB(16.0, topPad, 16.0, 16.0),
          itemCount: _favoriteOffers.length,
          itemSpacing: 16.0,
          itemBuilder: (context, index) {
            final offer = _favoriteOffers[index];
            return GigOfferTile(
              key: ValueKey("fav-offer-${offer.id}"),
              offer: offer,
              showFavoriteIndicator: true,
              forceFavorite: true,
              onFavoriteRemoved: () {
                setStateIfMounted(() {
                  _favoriteOffers.removeWhere((o) => o.id == offer.id);
                });
              },
              onFavoriteRemovalFailed: () {},
            );
          },
          showRefreshIndicator: false,
          showLoadMoreIndicator: _offersHasMore,
          hasMore: _offersHasMore,
          loadMoreIndicator: _isLoadingMoreOffers
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getLoadingIndicatorColor(),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: GhostButtonFactory.text(
                      onPressed: _loadMoreFavoriteOffers,
                      text: L10n.get("load_more"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRequestsFavoritesTab(double topPad) {
    if (_favoriteRequests.isEmpty) {
      return _buildGigEmptyTab(
        topPad: topPad,
        icon: Icons.assignment_outlined,
        browseLabelKey: "gigs_requests_title",
      );
    }

    return UydoshRefreshIndicator.mainShell(
      onRefresh: () => _loadFavoriteListings(isRefresh: true),
      edgeOffset: topPad,
      child: PullToRefreshStretchHaptics(
        child: CommonListView(
          padding: EdgeInsets.fromLTRB(16.0, topPad, 16.0, 16.0),
          itemCount: _favoriteRequests.length,
          itemSpacing: 16.0,
          itemBuilder: (context, index) {
            final request = _favoriteRequests[index];
            return GigRequestTile(
              key: ValueKey("fav-req-${request.id}"),
              request: request,
              showFavoriteIndicator: true,
              forceFavorite: true,
              onFavoriteRemoved: () {
                setStateIfMounted(() {
                  _favoriteRequests.removeWhere((r) => r.id == request.id);
                });
              },
              onFavoriteRemovalFailed: () {},
            );
          },
          showRefreshIndicator: false,
          showLoadMoreIndicator: _requestsHasMore,
          hasMore: _requestsHasMore,
          loadMoreIndicator: _isLoadingMoreRequests
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getLoadingIndicatorColor(),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: GhostButtonFactory.text(
                      onPressed: _loadMoreFavoriteRequests,
                      text: L10n.get("load_more"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGigEmptyTab({
    required double topPad,
    required IconData icon,
    required String browseLabelKey,
  }) {
    return UydoshRefreshIndicator.mainShell(
      onRefresh: () => _loadFavoriteListings(isRefresh: true),
      edgeOffset: topPad,
      child: PullToRefreshStretchHaptics(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ThemeIconFactory.display(icon: icon),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: LanguageState(),
                      builder: (context, child) {
                        return L10n.text(
                          "favorites_empty_title",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getEmptyStateTextColor(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButtonFactory.iconText(
                      onPressed: () {
                        // Send the user to the Services tab (gig hub).
                        // FavoritesScreen is pushed on top of MainNavigation,
                        // so flipping the bottom-bar index alone is invisible
                        // until we pop this route off. If the global key is
                        // missing (cold start / deep link), rebuild the shell
                        // directly on the Services tab instead of falling back
                        // to the default Housing tab.
                        final mainState = mainNavigationKey.currentState;
                        if (mainState != null) {
                          mainState.navigateToIndex(1);
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => AppRouter.buildMainNavigation(
                                initialIndex: 1,
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icons.work_outline,
                      text: L10n.get(browseLabelKey),
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    const refreshEdge = 8.0;
    return UydoshRefreshIndicator.mainShell(
      onRefresh: () => _loadFavoriteListings(isRefresh: true),
      edgeOffset: refreshEdge,
      child: PullToRefreshStretchHaptics(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ThemeIconFactory.display(icon: Icons.favorite_border),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: LanguageState(),
                      builder: (context, child) {
                        return L10n.text(
                          "favorites_empty_title",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getEmptyStateTextColor(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildThemeAwareButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Builder(
      builder: (context) => AuthRequiredState(
        icon: Icons.error_outline,
        iconColor: _getEmptyStateIconColor(),
        textColor: _getEmptyStateTextColor(),
        onLogin: AuthRequiredState.logoutAndReauthenticate(context),
      ),
    );
  }

  Widget _buildAuthenticationRequiredState() {
    return Builder(
      builder: (context) => AuthRequiredState(
        iconColor: _getEmptyStateIconColor(),
        textColor: _getEmptyStateTextColor(),
        onLogin: () => context.pushReplaceAuthWizard(),
      ),
    );
  }

  // Theme-dependent color method for loading indicators
  Color _getLoadingIndicatorColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary; // Blue for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else {
      return Colors.black; // Default to light theme indicator color
    }
  }

  // Theme-dependent color method for empty state icon
  Color _getEmptyStateIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White for blue theme
    } else {
      return AppColors.textGrey400; // Grey for light theme
    }
  }

  // Theme-dependent color method for empty state text
  Color _getEmptyStateTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White for blue theme
    } else {
      return AppColors.textGrey600; // Grey for light theme
    }
  }

  // Build theme-aware button - use GhostButton for all themes
  Widget _buildThemeAwareButton() {
    void onPressed() {
      // Switch to home tab (listings) - we're already inside MainNavigation
      if (mainNavigationKey.currentState != null) {
        mainNavigationKey.currentState!.navigateToIndex(0);
      } else {
        context.pushReplaceMainNavigation();
      }
    }

    return Builder(
      builder: (context) {
        final label = Theme.of(context).textTheme.labelLarge;
        final baseSize = label?.fontSize ?? 14;
        final textStyle =
            label?.copyWith(fontSize: baseSize * 1.2, height: 1.0) ??
                TextStyle(
                  fontSize: baseSize * 1.2,
                  height: 1.0,
                  fontWeight: FontWeight.w500,
                );
        return PrimaryButtonFactory.iconText(
          onPressed: onPressed,
          icon: Icons.home,
          text: L10n.get("favorites_browse_button"),
          width: double.infinity,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: textStyle,
        );
      },
    );
  }

  // NOTE: backend removal is handled by `ListingTile` via `toggleFavorite()`.
}
