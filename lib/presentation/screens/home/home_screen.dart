import "dart:async" show unawaited;
import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/home_inline_search_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/scroll_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/main.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/common/notify_search_alert_app_bar_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/applied_search_filters_bar.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
import "package:uy_dosh/presentation/widgets/listing_tile_skeleton.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/tutorial/alert_bell_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/tutorial_overlay_manager.dart";

/// Matches empty-search Ghost + Primary CTAs (30px bell stack + 14px vertical padding).
const double _kEmptySearchCtaButtonHeight = 58;

// Data class for BlocSelector to reduce unnecessary rebuilds
class _HomeScreenData {
  const _HomeScreenData({
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

  static bool _listingsIdsEqual(List<Listing> a, List<Listing> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  static int _listingsIdsHash(List<Listing> listings) {
    var h = listings.length;
    for (final l in listings) {
      h = Object.hash(h, l.id);
    }
    return h;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _HomeScreenData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        _listingsIdsEqual(other.listings, listings) &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      Object.hash(hasError, errorMessage),
      _listingsIdsHash(listings),
      hasMore,
    );
  }
}

class _ResolvedSearchFilters {
  const _ResolvedSearchFilters({
    required this.listingTypeId,
    required this.locationId,
    required this.subwayStationId,
    required this.subwayLineId,
    required this.gender,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
  });

  final int? listingTypeId;
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.listingTypeId,
    this.locationId,
    this.subwayStationId,
    this.subwayLineId,
    this.gender,
    this.minPrice,
    this.maxPrice,
    this.privateRoom,
    this.withPhoto,
    this.isSearchMode = false,
    this.useExplicitFiltersOnly = false,
    this.isHomeTabActive = true,
  });
  final int? listingTypeId;
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;
  final bool isSearchMode;
  final bool useExplicitFiltersOnly;

  /// True when this HomeScreen is the active tab in main navigation (index 0).
  /// Used to ensure tutorials run only when user is on home screen.
  final bool isHomeTabActive;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  bool _isCreatingSearchAlert = false;
  int _searchAlertCelebrationTick = 0;
  bool _inlineSearchActive = false;
  static const double _inlineSearchRibbonHeight = 56.0;
  late final VoidCallback _throttledScrollListener;
  late final VoidCallback _resetScrollLoadingState;
  final SearchFiltersState _searchFiltersState = SearchFiltersState();
  final GlobalKey<TutorialTargetWrapperState> _searchButtonTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  final GlobalKey<TutorialTargetWrapperState> _alertBellTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  bool _noResultsAlertTutorialShownThisSession = false;

  @override
  void initState() {
    super.initState();

    // Create optimized scroll listener with throttling and reset capability
    final scrollListenerData =
        ScrollUtils.createThrottledScrollListenerWithReset(
      scrollController: _scrollController,
      onLoadMore: _loadMoreListings,
      shouldLoadMore: _shouldLoadMore,
    );

    _throttledScrollListener = scrollListenerData.listener;
    _resetScrollLoadingState = scrollListenerData.resetLoadingState;

    _scrollController.addListener(_throttledScrollListener);

    // Initialize authentication and favorites state
    AuthenticationState().initialize();
    FavoritesState().initialize();
    // Need current user id so listing tiles can hide the favorite control
    // on the user's own listings.
    UserListingState().initialize();

    unawaited(_bootstrapHomeSearchFilters());

    // Initialize search filters with current parameters if in search mode
    if (widget.isSearchMode) {
      if (!widget.useExplicitFiltersOnly) {
        _initializeSearchFilters();
      }
      // Trigger search when screen loads in search mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }

    // Listen to home refresh state for immediate refresh commands
    HomeRefreshState().addListener(_onHomeRefreshStateChanged);

    // After logout, inline ribbon + filtered bloc path must drop even if this
    // State object outlives the session-clear hook ordering.
    AuthenticationState().addListener(_onAuthenticationChangedForInlineSearch);

    // Re-check tutorial when onboarding toggle changes (e.g. user turns it ON in settings)
    OnboardingState().addListener(_onOnboardingStateChanged);

    getIt<AppAnalyticsService>().logScreenView(screenName: "home");

    // Show search button tutorial on first visit to browse screen (with delay)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _maybeShowSearchTutorial);
    });
  }

  Future<void> _bootstrapHomeSearchFilters() async {
    await _searchFiltersState.initialize();
    if (!mounted) return;
    if (await SessionManager.isAuthenticated()) {
      await _searchFiltersState.hydrateFromBackendForCurrentUser();
    }
    if (!mounted) return;
    await _searchFiltersState.ensureProfileDefaultsApplied();
    if (!mounted) return;
    await _restoreInlineSearchModeFromPrefs();
  }

  Future<void> _restoreInlineSearchModeFromPrefs() async {
    if (widget.isSearchMode) return; // dedicated results screen manages itself
    if (!await SessionManager.isAuthenticated()) return;
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(HomeInlineSearchState.activePrefsKey) ?? false;
    if (!mounted) return;
    if (!active) return;
    setState(() => _inlineSearchActive = true);
    HomeInlineSearchState().setActive(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _performSearch();
    });
  }

  void _onOnboardingStateChanged() {
    if (mounted && OnboardingState().showOnboarding) {
      // Only schedule tutorial when home tab is active and screen is visible
      if (widget.isHomeTabActive &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        Future.delayed(const Duration(seconds: 2), _maybeShowSearchTutorial);
      }
    }
  }

  void _onAuthenticationChangedForInlineSearch() {
    if (!mounted) return;
    if (AuthenticationState().isAuthenticated) return;
    if (!_inlineSearchActive) return;
    _exitInlineSearch();
  }

  /// Shows the first tutorial (search button) only on the home screen's main
  /// browse view. Skipped when in search results (isSearchMode), other tabs, or other screens.
  void _maybeShowSearchTutorial() {
    if (!mounted) return;
    if (!widget.isHomeTabActive) return; // Only when home tab is active
    if (!(ModalRoute.of(context)?.isCurrent ?? false))
      return; // Only when home route is visible
    if (widget.isSearchMode) return; // Only on home browse, not search results
    if (!AuthenticationState().isAuthenticated)
      return; // Only when user is logged in
    if (OnboardingState().showOnboarding &&
        !TutorialState().hasCompletedSearchTutorial) {
      _showSearchTutorial();
    }
  }

  void _showSearchTutorial() {
    if (!mounted) return;
    SearchTutorialOverlay.show(
      context,
      searchButtonKey: _searchButtonTutorialKey,
      profileIconKey: AppRouter.profileIconTutorialKey,
      onComplete: TutorialState().markSearchTutorialCompleted,
    );
  }

  void _resetLoadMoreState() {
    _resetScrollLoadingState();
  }

  void _onHomeRefreshStateChanged() {
    final refreshState = HomeRefreshState();
    if (refreshState.forceRefresh && mounted) {
      debugPrint(
        "🏠 HomeScreen: Force refresh detected, refreshing listings immediately...",
      );
      _refreshListings();
      refreshState.clearRefreshFlag();
    }
  }

  /// Initialize search filters with widget parameters
  void _initializeSearchFilters() {
    if (widget.listingTypeId != null) {
      _searchFiltersState.setListingTypeId(widget.listingTypeId!);
    }
    if (widget.locationId != null) {
      _searchFiltersState.setLocationIndex(widget.locationId!);
    }
    if (widget.subwayLineId != null && widget.locationId == null) {
      _searchFiltersState.setLocationIndex(0);
    }
    if (widget.subwayLineId != null) {
      _searchFiltersState.setSubwayLine(widget.subwayLineId!);
    }
    if (widget.subwayLineId != null && widget.subwayStationId == null) {
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
    }
    if (widget.subwayStationId != null) {
      _searchFiltersState.setStationId(widget.subwayStationId!);
    }
    if (widget.gender != null) {
      _searchFiltersState.setGender(widget.gender!);
    }
    if (widget.minPrice != null || widget.maxPrice != null) {
      final minPrice = widget.minPrice ?? _searchFiltersState.minPrice;
      final maxPrice = widget.maxPrice ?? _searchFiltersState.maxPrice;
      _searchFiltersState.setPriceRange(minPrice, maxPrice);
    }
    if (widget.privateRoom != null) {
      _searchFiltersState.setPrivateRoom(widget.privateRoom!);
    }
    if (widget.withPhoto != null) {
      _searchFiltersState.setWithPhoto(widget.withPhoto!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes using global route observer
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // If a tutorial is currently showing and we leave the screen, make sure it
    // cannot linger into the next route (which can result in two overlays).
    TutorialOverlayManager().dismissActive();
    routeObserver.unsubscribe(this);
    OnboardingState().removeListener(_onOnboardingStateChanged);
    AuthenticationState().removeListener(_onAuthenticationChangedForInlineSearch);
    HomeRefreshState().removeListener(_onHomeRefreshStateChanged);
    ScrollUtils.disposeScrollController(_scrollController);
    super.dispose();
  }

  // RouteAware methods
  @override
  void didPopNext() {
    // Called when returning to this screen from another screen
    debugPrint("🏠 HomeScreen: Returning from another screen");
    _checkAndRefreshIfNeeded();
    // Re-check tutorial when returning (e.g. user may have turned onboarding ON in settings)
    Future.delayed(const Duration(milliseconds: 300), _maybeShowSearchTutorial);
  }

  @override
  void didPushNext() {
    // Called when navigating away from this screen
    debugPrint("🏠 HomeScreen: Navigating away from home screen");
    TutorialOverlayManager().dismissActive();
  }

  @override
  void didPop() {
    // Called when this screen is popped
    debugPrint("🏠 HomeScreen: Home screen was popped");
  }

  @override
  void didPush() {
    // Called when this screen is pushed
    debugPrint("🏠 HomeScreen: Home screen was pushed");
    _checkAndRefreshIfNeeded();
  }

  /// Check if refresh is needed and refresh if so
  void _checkAndRefreshIfNeeded() {
    final refreshState = HomeRefreshState();
    if (refreshState.shouldRefresh) {
      debugPrint(
        "🏠 HomeScreen: Refresh flag detected, refreshing listings...",
      );
      _refreshListings();
      refreshState.clearRefreshFlag();
    } else {
      debugPrint("🏠 HomeScreen: No refresh needed");
    }
  }

  /// Refresh listings when returning to home screen
  void _refreshListings() {
    try {
      _dispatchFeedRefresh();
    } catch (e) {
      debugPrint("Error refreshing listings: $e");
    }
  }

  void _dispatchFeedRefresh() {
    if (widget.isSearchMode || _inlineSearchActive) {
      _dispatchSearch(isRefresh: true);
    } else {
      context.read<ListingsBloc>().add(
            const ListingsEvent.searchListings(isRefresh: true),
          );
    }
  }

  Future<void> _onFeedPullRefresh() async {
    try {
      _dispatchFeedRefresh();
    } catch (e) {
      debugPrint("Error refreshing listings: $e");
    }
  }

  /// Determines if more listings should be loaded
  bool _shouldLoadMore() {
    try {
      final bloc = context.read<ListingsBloc>();
      final currentState = bloc.state;

      return currentState.map(
        initial: (_) => false,
        loading: (_) => false,
        loaded: (loadedState) => loadedState.hasMore,
        error: (_) => false,
      );
    } catch (e) {
      return false;
    }
  }

  /// Loads more listings with proper error handling
  void _loadMoreListings() {
    try {
      final bloc = context.read<ListingsBloc>();
      bloc.add(const ListingsEvent.loadMore());
    } catch (e) {
      debugPrint("Error loading more listings: $e");
    }
  }

  _ResolvedSearchFilters _resolveSearchFilters({
    required bool includeSafeFallbacks,
    required bool explicitNullFallsBackToState,
  }) {
    final fromExplicit = widget.useExplicitFiltersOnly;

    final listingTypeId = fromExplicit
        ? (explicitNullFallsBackToState
            ? (widget.listingTypeId ??
                _searchFiltersState.selectedListingTypeId)
            : widget.listingTypeId)
        : _searchFiltersState.selectedListingTypeId;

    // For location / metro fields we preserve current behavior: if opened with
    // explicit filters, we display/use exactly what was provided (nullable).
    final locationId = fromExplicit
        ? widget.locationId
        : _searchFiltersState.selectedLocationIndex;
    final subwayStationId = fromExplicit
        ? widget.subwayStationId
        : _searchFiltersState.selectedStationId;
    final subwayLineId = fromExplicit
        ? widget.subwayLineId
        : _searchFiltersState.selectedSubwayLine;
    final gender =
        fromExplicit ? widget.gender : _searchFiltersState.selectedGender;

    final minPrice = fromExplicit
        ? (includeSafeFallbacks ? (widget.minPrice ?? 10.0) : widget.minPrice)
        : _searchFiltersState.minPrice;
    final maxPrice = fromExplicit
        ? (includeSafeFallbacks ? (widget.maxPrice ?? 1000.0) : widget.maxPrice)
        : _searchFiltersState.maxPrice;

    final privateRoom = fromExplicit
        ? (includeSafeFallbacks
            ? (widget.privateRoom ?? false)
            : widget.privateRoom)
        : _searchFiltersState.privateRoom;
    final withPhoto = fromExplicit
        ? (includeSafeFallbacks
            ? (widget.withPhoto ?? false)
            : widget.withPhoto)
        : _searchFiltersState.withPhoto;

    return _ResolvedSearchFilters(
      listingTypeId: listingTypeId,
      locationId: locationId,
      subwayStationId: subwayStationId,
      subwayLineId: subwayLineId,
      gender: gender,
      minPrice: minPrice,
      maxPrice: maxPrice,
      privateRoom: privateRoom,
      withPhoto: withPhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listContent = BlocListener<ListingsBloc, ListingsState>(
      listener: (context, state) {
        // Reset loading flag when state changes
        state.map(
          initial: (_) {
            _resetLoadMoreState();
          },
          loading: (_) {
            _resetLoadMoreState();
          },
          loaded: (_) {
            _resetLoadMoreState();
          },
          error: (_) {
            _resetLoadMoreState();
          },
        );
      },
      child: BlocSelector<ListingsBloc, ListingsState, _HomeScreenData>(
        selector: (state) => state.map(
          initial: (_) => const _HomeScreenData(
            isLoading: false,
            hasError: false,
            errorMessage: "",
            listings: [],
            hasMore: false,
          ),
          loading: (_) => const _HomeScreenData(
            isLoading: true,
            hasError: false,
            errorMessage: "",
            listings: [],
            hasMore: false,
          ),
          loaded: (loadedState) => _HomeScreenData(
            isLoading: false,
            hasError: false,
            errorMessage: "",
            listings: loadedState.listings,
            hasMore: loadedState.hasMore,
          ),
          error: (errorState) => _HomeScreenData(
            isLoading: false,
            hasError: true,
            errorMessage: errorState.message,
            listings: [],
            hasMore: false,
          ),
        ),
        builder: (context, data) {
          if (data.isLoading) {
            return _buildLoadingState();
          }
          if (data.hasError) {
            return _buildErrorState(data.errorMessage);
          }
          if (data.listings.isEmpty) {
            return (widget.isSearchMode || _inlineSearchActive)
                ? _buildEmptySearchState()
                : _buildInitialState();
          }
          return _buildLoadedState(data.listings, data.hasMore);
        },
      ),
    );

    return Scaffold(
      backgroundColor: ThemeState().backgroundColor,
      appBar: widget.isSearchMode ? _buildSearchAppBar() : null,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          listContent,
          if (!widget.isSearchMode && _inlineSearchActive)
            Positioned(
              left: 12,
              right: 12,
              top: ThemeState().mainShellGlassExtraTopInset(context),
              child: _buildInlineFiltersRibbon(),
            ),
          // Positioned floating action button (wrapped for tutorial targeting)
          Positioned(
            right: 16,
            bottom: 30, // Moved down a bit from 100
            child: TutorialTargetWrapper(
              key: _searchButtonTutorialKey,
              child: ListenableBuilder(
                listenable: AnimationSettingsState(),
                builder: (context, _) {
                  return TutorialPulseWrapper(
                    enabled: false,
                    variant: TutorialPulseVariant.floatingActionButton,
                    child: SearchFloatingActionButton(
                      searchFiltersState: _searchFiltersState,
                      onPressed: widget.isSearchMode ? null : _openInlineSearchFromFab,
                      iconData: Icons.search,
                      replaceCurrentRoute: widget.isSearchMode,
                      openedFromHomeScreen: widget.isHomeTabActive,
                      elevation: ThemeState().isBlueTheme ? null : 8,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Extra top inset when the home feed sits under the main shell glass header.
  /// Search mode pushes a route with a normal [AppBar], so the body is already
  /// below the status bar — do not add status-bar padding again.
  double _feedListGlassTopInset() {
    // In main navigation (glass header), body renders behind the header.
    // We pad list content down so it doesn't sit under the header/ribbon.
    if (widget.isSearchMode) return 0;
    final base = ThemeState().mainShellGlassExtraTopInset(context);
    if (_inlineSearchActive) {
      return base + _inlineSearchRibbonHeight + 8.0;
    }
    return base;
  }

  /// When the inline filter ribbon is on, skip the extra 16px so the gap under
  /// the ribbon matches the 8px used above it (`mainShellGlassExtraTopInset`).
  double _feedListTopPadding() {
    final inset = _feedListGlassTopInset();
    if (_inlineSearchActive) return inset;
    return 16.0 + inset;
  }

  /// Scrollable wrapper so pull-to-refresh works when content is shorter than
  /// the viewport (welcome / empty states).
  Widget _buildPullToRefreshAroundFillChild(Widget child) {
    final topPad = _feedListTopPadding();
    return UydoshRefreshIndicator.mainShell(
      onRefresh: _onFeedPullRefresh,
      edgeOffset: topPad,
      child: PullToRefreshStretchHaptics(
        // Use a single scrollable with a single box child.
        // This avoids a Flutter web edge-case where swapping sliver vs. box
        // scrollables during rebuild can trigger a mouse_tracker assertion.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.0, topPad, 16.0, 16.0),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: Center(child: child),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInlineFiltersRibbon() {
    return LiquidGlassPlate(
      height: _inlineSearchRibbonHeight,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Row(
        children: [
          const ThemeIcon(Icons.tune, size: 18),
          const SizedBox(width: 10),
          Expanded(child: _buildInlineFiltersChips()),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const ThemeIcon(Icons.close, size: 16),
            onPressed: () {
              HapticFeedbackUtils.impact();
              _exitInlineSearch();
            },
            tooltip: L10n.get("close"),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineFiltersChips() {
    return AppliedSearchFiltersBar(
      onPressed: _openInlineSearchFromFab,
      listingTypeId: _searchFiltersState.selectedListingTypeId,
      gender: _searchFiltersState.selectedGender,
      locationId: _searchFiltersState.selectedLocationIndex > 0
          ? _searchFiltersState.selectedLocationIndex
          : null,
      subwayStationId: _searchFiltersState.selectedStationId > 0
          ? _searchFiltersState.selectedStationId
          : null,
      subwayLineId: _searchFiltersState.selectedSubwayLine > 0
          ? _searchFiltersState.selectedSubwayLine
          : null,
      minPrice: _searchFiltersState.minPrice,
      maxPrice: _searchFiltersState.maxPrice,
      privateRoom: _searchFiltersState.privateRoom,
      withPhoto: _searchFiltersState.withPhoto,
      total: null,
      showLabel: false,
      alignRight: false,
      height: _inlineSearchRibbonHeight,
      // Reserve space so the last chip never scrolls under the trailing close button.
      // (44px tap target + a little breathing room for chip shadows)
      endPadding: 56,
    );
  }

  Widget _buildInitialState() {
    return _buildPullToRefreshAroundFillChild(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemeIcon(Icons.home, size: 64, color: _getHomeIconColor()),
          const SizedBox(height: 16),
          L10n.text(
            "welcome_title",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getWelcomeTitleColor(),
            ),
          ),
          const SizedBox(height: 8),
          L10n.text(
            "welcome_subtitle",
            style: TextStyle(fontSize: 16, color: _getWelcomeSubtitleColor()),
          ),
          const SizedBox(height: 24),
          GhostButtonFactory.iconText(
            onPressed: _dispatchFeedRefresh,
            icon: Icons.refresh,
            text: L10n.get("refresh"),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            neumorphicSoftUi: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    _maybeShowNoResultsAlertBellTutorial();
    return _buildPullToRefreshAroundFillChild(
      Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIcon(
                  Icons.search_off,
                  size: 64,
                  color: _getHomeIconColor(),
                ),
                const SizedBox(height: 16),
                L10n.text(
                  "no_search_results",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getWelcomeTitleColor(),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GhostButtonFactory.iconText(
                          onPressed: _handleClearFiltersFromEmptyState,
                          icon: Icons.filter_alt_off,
                          text: L10n.get("search_clear_filters"),
                          height: _kEmptySearchCtaButtonHeight,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          neumorphicSoftUi: true,
                        ),
                        const SizedBox(height: 12),
                        _NotifySearchAlertGhostButton(
                          height: _kEmptySearchCtaButtonHeight,
                          label: L10n.get("search_alert_notify_me"),
                          onPressed: _isCreatingSearchAlert
                              ? null
                              : _subscribeToSearchAlerts,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClearFiltersFromEmptyState() async {
    await _searchFiltersState.clearAllFilters();
    await _searchFiltersState.ensureProfileDefaultsApplied();
    if (!mounted) return;
    // Clearing filters implies leaving inline-search mode entirely.
    _exitInlineSearch();
  }

  void _maybeShowNoResultsAlertBellTutorial() {
    if (!mounted) return;
    if (_noResultsAlertTutorialShownThisSession) return;
    if (!widget.isSearchMode) return;
    if (!AuthenticationState().isAuthenticated) return;

    _noResultsAlertTutorialShownThisSession = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Give the route a moment to fully appear before measuring the AppBar action.
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await TutorialState().initialize();
      if (!mounted) return;
      if (TutorialState().hasCompletedAlertBellTutorial) return;

      // The AppBar actions can mount slightly after the body; retry a few times
      // to ensure the bell target exists before showing the spotlight.
      for (var attempt = 0; attempt < 5; attempt++) {
        if (!mounted) return;
        if (_alertBellTutorialKey.currentContext != null) {
          AlertBellTutorialOverlay.show(
            context,
            alertBellKey: _alertBellTutorialKey,
            onComplete: () {
              TutorialState().markAlertBellTutorialCompleted();
            },
          );
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
    });
  }

  Future<void> _subscribeToSearchAlerts() async {
    if (!mounted) return;

    if (!AuthenticationState().isAuthenticated) {
      ToastTheme.showError(
        context,
        message: L10n.get("search_alert_login_required"),
      );
      return;
    }

    final filters = _resolveSearchFilters(
      includeSafeFallbacks: true,
      explicitNullFallsBackToState: true,
    );

    final hasAnyLocationConstraint =
        (filters.locationId != null && filters.locationId! > 0) ||
            (filters.subwayLineId != null && filters.subwayLineId! > 0) ||
            (filters.subwayStationId != null && filters.subwayStationId! > 0);
    if (!hasAnyLocationConstraint) {
      ToastTheme.showError(
        context,
        message: L10n.get("search_alert_too_wide"),
      );
      return;
    }

    setState(() => _isCreatingSearchAlert = true);
    try {
      // Prevent creating a station-level alert when the user already has a
      // broader alert that covers the same station (e.g. an "entire line"
      // alert).
      final stationId = filters.subwayStationId;
      if (stationId != null && stationId > 0) {
        final alerts = await getIt<ISearchAlertService>().listAlerts();
        if (!mounted) return;

        final station = MetroCache.getStationById(stationId);
        final stationLineId = station?.line;

        final coveredByExisting = alerts.any((a) {
          final ids = a.subwayStationIds;
          if (ids != null && ids.contains(stationId)) return true;

          if (stationLineId == null) return false;

          // Consider a "line" alert if it targets the line and doesn't
          // explicitly target a single station.
          final isLineAlert =
              a.subwayLineId != null &&
              a.subwayLineId == stationLineId &&
              (a.subwayStationId == null || a.subwayStationId! <= 0) &&
              (ids == null || ids.length > 1);
          return isLineAlert;
        });

        if (coveredByExisting) {
          final lang = L10n.currentLanguage;
          final stationName =
              MetroCache.getStationDisplayName(stationId, lang).trim();
          final lineName = stationLineId == null
              ? ""
              : MetroCache.getLineName(stationLineId, lang).trim();

          ToastTheme.showWarning(
            context,
            message: (stationName.isEmpty || lineName.isEmpty)
                ? L10n.get("search_alert_station_already_covered")
                : L10n.getWithParams(
                    "search_alert_station_already_covered_by_line",
                    params: {"station": stationName, "line": lineName},
                  ),
          );
          return;
        }
      }

      final err =
          await getIt<ISearchAlertService>().createAlertForCurrentSearch(
        listingTypeId:
            filters.listingTypeId ?? _searchFiltersState.selectedListingTypeId,
        locationId: filters.locationId,
        subwayStationId: filters.subwayStationId,
        subwayLineId: filters.subwayLineId,
        gender: filters.gender,
        minPrice: filters.minPrice ?? 10.0,
        maxPrice: filters.maxPrice ?? 1000.0,
        privateRoomOnly: filters.privateRoom ?? false,
        withPhotoOnly: filters.withPhoto ?? false,
      );

      if (!mounted) return;

      if (err != null) {
        if (err == SearchAlertService.alreadyExistsErrorToken) {
          ToastTheme.showSuccess(
            context,
            message: L10n.get("search_alert_already_exists"),
          );
        } else {
          ToastTheme.showError(
            context,
            message: err == "error" ? L10n.get("search_alert_failed") : err,
          );
        }
        return;
      }

      if (mounted) {
        setState(() => _searchAlertCelebrationTick++);
      }

      await ActiveSearchAlertsState().refresh();

      // Ensure notifications are enabled (or guide user to settings).
      final push = getIt<IPushNotificationService>();
      if (push.isSupported) {
        final ok = await push.requestPermissionAndRegister();
        if (!mounted) return;
        if (!ok) {
          ToastTheme.showWarning(
            context,
            message: L10n.get("search_alert_permission"),
          );
        }
      }

      ToastTheme.showSuccess(context,
          message: L10n.get("search_alert_created"));
    } finally {
      if (mounted) {
        setState(() => _isCreatingSearchAlert = false);
      }
    }
  }

  Widget _buildLoadingState() {
    final topPad = _feedListTopPadding();
    return CommonListView(
      padding: EdgeInsets.fromLTRB(14.0, topPad, 14.0, 16.0),
      itemSpacing: 16.0,
      itemCount: 6,
      itemBuilder: (context, index) => const ListingTileSkeleton(),
    );
  }

  Widget _buildLoadedState(List<Listing> listings, bool hasMore) {
    final topPadding = _feedListTopPadding();
    return UydoshRefreshIndicator.mainShell(
      onRefresh: _onFeedPullRefresh,
      edgeOffset: topPadding,
      child: PullToRefreshStretchHaptics(
        child: CommonListView(
          itemCount: listings.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            14.0,
            topPadding,
            14.0,
            16.0,
          ),
          itemBuilder: (context, index) {
            final listing = listings[index];
            return ListingTile(
              key: ValueKey(listing.id),
              listing: listing,
              forceFavorite:
                  false, // Home screen listings don"t force favorite state
              showHeartIcon: false, // Don"t show heart icon on home screen
              showFavoriteIndicator:
                  true, // Show small heart when listing is in user favorites
              onFavoriteRemoved: null, // No callback needed for home screen
            );
          },
          controller: _scrollController,
          showRefreshIndicator:
              false, // Already handled by UydoshRefreshIndicator wrapper
          showLoadMoreIndicator: hasMore,
          hasMore: hasMore,
          loadMoreIndicator: _buildLoadMoreIndicator(),
          cacheExtent:
              500, // Larger cache for smoother scrolling of large tiles
        ),
      ),
    );
  }

  // Inline filter chips are rendered via `_buildInlineFiltersRibbon()`.

  void _openInlineSearchFromFab() {
    SearchBottomSheetWidget.show(
      context,
      openedFromHomeScreen: widget.isHomeTabActive,
      currentListingTypeId: _searchFiltersState.selectedListingTypeId,
      currentLocationId: _searchFiltersState.selectedLocationIndex,
      currentSubwayStationId: _searchFiltersState.selectedStationId,
      currentSubwayLineId: _searchFiltersState.selectedSubwayLine,
      currentGender: _searchFiltersState.selectedGender,
      currentMinPrice: _searchFiltersState.minPrice,
      currentMaxPrice: _searchFiltersState.maxPrice,
      currentPrivateRoom: _searchFiltersState.privateRoom,
      currentWithPhoto: _searchFiltersState.withPhoto,
      onApply: (result) {
        // Persist filter writes deterministically (important for web reloads).
        _applyInlineSearchResult(result);
      },
    );
  }

  Future<void> _applyInlineSearchResult(SearchBottomSheetResult result) async {
    await _searchFiltersState.setListingTypeId(result.listingTypeId);
    await _searchFiltersState.setGender(result.gender ?? 0);
    await _searchFiltersState.setPriceRange(result.minPrice, result.maxPrice);
    await _searchFiltersState.setPrivateRoom(result.privateRoom);
    await _searchFiltersState.setWithPhoto(result.withPhoto);

    if (result.subwayLineId != null && (result.subwayLineId ?? 0) > 0) {
      await _searchFiltersState.setLocationIndex(0);
      await _searchFiltersState.setSubwayLine(result.subwayLineId!);
    } else {
      await _searchFiltersState.setSubwayLine(0);
    }

    if (result.subwayStationId != null && (result.subwayStationId ?? 0) > 0) {
      await _searchFiltersState.setStationId(result.subwayStationId!);
    } else {
      await _searchFiltersState.setStationId(0);
    }

    if (result.locationId != null && (result.locationId ?? 0) > 0) {
      await _searchFiltersState.setLocationIndex(result.locationId!);
      await _searchFiltersState.setSubwayLine(0);
      await _searchFiltersState.setStationId(0);
    }

    if (!mounted) return;
    setState(() => _inlineSearchActive = true);
    HomeInlineSearchState().setActive(true);
    final p = await SharedPreferences.getInstance();
    await p.setBool(HomeInlineSearchState.activePrefsKey, true);
    if (!mounted) return;
    _performSearch();
  }

  void _exitInlineSearch() {
    if (mounted) {
      setState(() => _inlineSearchActive = false);
    }
    HomeInlineSearchState().setActive(false);
    SharedPreferences.getInstance().then((p) async {
      await p.setBool(HomeInlineSearchState.activePrefsKey, false);
    });
    _dispatchFeedRefresh();
  }

  // NOTE: We intentionally do NOT clear persisted filters when dismissing the
  // ribbon; it only exits inline-search mode and shows the full feed.

  void _pushFullSearchResultsRoute() {
    final locationId = _searchFiltersState.selectedLocationIndex;
    final stationId = _searchFiltersState.selectedStationId;
    final lineId = _searchFiltersState.selectedSubwayLine;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ListingsBloc(getIt<IListingService>()),
          child: HomeScreen(
            listingTypeId: _searchFiltersState.selectedListingTypeId,
            locationId: locationId > 0 ? locationId : null,
            subwayStationId: stationId > 0 ? stationId : null,
            subwayLineId: lineId > 0 ? lineId : null,
            gender: _searchFiltersState.selectedGender,
            minPrice: _searchFiltersState.minPrice,
            maxPrice: _searchFiltersState.maxPrice,
            privateRoom: _searchFiltersState.privateRoom,
            withPhoto: _searchFiltersState.withPhoto,
            isSearchMode: true,
            isHomeTabActive: false,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return CenteredHouseLoadingIndicator(
      text: L10n.get("loading_listings"),
    );
  }

  Widget _buildErrorState(String message) {
    return CommonStateBuilder(
      isLoading: false,
      hasError: true,
      isEmpty: false,
      errorMessage: message,
      errorAction: ThreeDPillButton(
        onPressed: _dispatchFeedRefresh,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThemeIcon(Icons.refresh, size: 18),
            const SizedBox(width: 8),
            Text(L10n.get("retry"), style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: Container(), // This won"t be shown when there"s an error
    );
  }

  Color _getHomeIconColor() {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey;
  }

  Color _getWelcomeTitleColor() {
    return Theme.of(context).textTheme.titleLarge?.color ?? Colors.black;
  }

  Color _getWelcomeSubtitleColor() {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey;
  }

  /// Build search app bar for search mode
  PreferredSizeWidget _buildSearchAppBar() {
    final appBarFg =
        Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;
    return UydoshAppBar(
      title: BlocSelector<ListingsBloc, ListingsState, int?>(
        selector: (state) => state.map(
          initial: (_) => null,
          loading: (_) => null,
          loaded: (loadedState) => loadedState.total,
          error: (_) => null,
        ),
        builder: (context, count) {
          final baseTitle = L10n.get("search_results");
          final titleText =
              (count == null || count <= 0) ? baseTitle : "$baseTitle: $count";
          return Text(
            titleText,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          );
        },
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
          (ThemeState().isBlueTheme
              ? BlueThemeColors.surface
              : Theme.of(context).colorScheme.primary),
      foregroundColor: appBarFg,
      elevation: 0,
      leading: widget.isSearchMode
          ? ThreeDAppBarIconButton.backLeading(
              context,
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            )
          : ThreeDAppBarIconButton.leadingSlot(
              child: ThreeDAppBarIconButton(
                iconData: Icons.close,
                onPressed: _exitInlineSearch,
                semanticsLabel: L10n.get("close"),
              ),
            ),
      actions: [
        if (!widget.isSearchMode)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ThreeDAppBarIconButton(
              iconData: Icons.open_in_new,
              onPressed: _pushFullSearchResultsRoute,
              semanticsLabel: L10n.get("search_results"),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TutorialTargetWrapper(
            key: _alertBellTutorialKey,
            child: NotifySearchAlertAppBarButton(
              tooltip: L10n.get("search_alert_notify_me"),
              enabled: !_isCreatingSearchAlert,
              celebrationTick: _searchAlertCelebrationTick,
              onPressed: _subscribeToSearchAlerts,
            ),
          ),
        ),
      ],
    );
  }

  /// Perform search using current filters
  void _performSearch() {
    _dispatchSearch(isRefresh: true);
  }

  void _dispatchSearch({required bool isRefresh}) {
    final listingsBloc = context.read<ListingsBloc>();

    // When opened from metro map with only station: use station-only API (no transfer expansion, no other filters)
    final isStationOnlyFromMap = widget.useExplicitFiltersOnly &&
        widget.subwayStationId != null &&
        widget.listingTypeId == null &&
        widget.locationId == null &&
        widget.subwayLineId == null &&
        widget.gender == null &&
        widget.minPrice == null &&
        widget.maxPrice == null &&
        widget.privateRoom == null &&
        widget.withPhoto == null;

    if (isStationOnlyFromMap) {
      listingsBloc.add(
        ListingsEvent.fetchListingsBySubwayStation(
          subwayStationId: widget.subwayStationId!,
          isRefresh: isRefresh,
        ),
      );
      return;
    }

    final filters = _resolveSearchFilters(
      includeSafeFallbacks: false,
      explicitNullFallsBackToState: false,
    );

    // Debug logging to see what values are being passed
    if (kDebugMode) {
      logger.d(
        "HomeScreen._dispatchSearch - subwayStationId: ${filters.subwayStationId}, subwayLineId: ${filters.subwayLineId}",
      );
      logger.d(
        "HomeScreen._dispatchSearch - minPrice: ${filters.minPrice}, maxPrice: ${filters.maxPrice}",
      );
    }

    listingsBloc.add(
      ListingsEvent.searchListings(
        listingTypeId: filters.listingTypeId,
        locationId: filters.locationId,
        subwayStationId: filters.subwayStationId,
        subwayLineId: filters.subwayLineId,
        gender: filters.gender,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        privateRoom: filters.privateRoom,
        withPhoto: filters.withPhoto,
        isRefresh: isRefresh,
      ),
    );
  }

}

/// Notify-me control: expanding ring + bell wiggle on tap.
class _NotifySearchAlertGhostButton extends StatefulWidget {
  const _NotifySearchAlertGhostButton({
    required this.height,
    required this.label,
    required this.onPressed,
  });

  final double height;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_NotifySearchAlertGhostButton> createState() =>
      _NotifySearchAlertGhostButtonState();
}

class _NotifySearchAlertGhostButtonState
    extends State<_NotifySearchAlertGhostButton> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bellTurns;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final AnimationController _idleController;
  late final Animation<double> _idleBellTurns;
  late final AnimationSettingsState _animationSettings;

  @override
  void initState() {
    super.initState();
    _animationSettings = AnimationSettingsState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    );
    _idleBellTurns = Tween<double>(begin: -0.012, end: 0.012).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 624),
    );
    _bellTurns = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.09).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.09, end: 0.055).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.055, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 30,
      ),
    ]).animate(_controller);
    _ringScale = Tween<double>(begin: 1, end: 2.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.72, curve: Curves.easeOut),
      ),
    );
    _ringOpacity = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.88, curve: Curves.easeOut),
      ),
    );

    _animationSettings.addListener(_syncFromSettings);
    _syncFromSettings();
  }

  void _syncFromSettings() {
    if (!mounted) return;
    final idleEnabled = _animationSettings.bellIdleEnabled;
    if (idleEnabled) {
      if (!_idleController.isAnimating) {
        _idleController.repeat(reverse: true);
      }
    } else {
      _idleController.stop();
      // 0 maps to tween begin (slightly rotated). Keep midpoint as "rest" angle.
      _idleController.value = 0.5;
    }

    final tapEnabled = _animationSettings.bellTapEnabled;
    if (!tapEnabled) {
      _controller.stop();
      _controller.value = 0;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _animationSettings.removeListener(_syncFromSettings);
    _controller.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _handlePressed() {
    if (widget.onPressed == null) return;
    if (_animationSettings.bellTapEnabled) {
      _controller.forward(from: 0);
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = theme.colorScheme.primary;
    final idleEnabled = _animationSettings.bellIdleEnabled;
    final tapEnabled = _animationSettings.bellTapEnabled;

    final label = theme.textTheme.labelLarge;
    final baseSize = label?.fontSize ?? 14;
    final textStyle =
        label?.copyWith(fontSize: baseSize * 1.2, height: 1.0) ??
        TextStyle(
          fontSize: baseSize * 1.2,
          height: 1.0,
          fontWeight: FontWeight.w500,
        );

    return PrimaryButton(
      onPressed: widget.onPressed == null ? null : _handlePressed,
      height: widget.height,
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (tapEnabled)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return IgnorePointer(
                        child: Opacity(
                          opacity: _ringOpacity.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: _ringScale.value,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ringColor.withValues(alpha: 0.85),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                AnimatedBuilder(
                  animation: Listenable.merge([_idleController, _controller]),
                  builder: (context, child) {
                    final turns =
                        (idleEnabled ? _idleBellTurns.value : 0.0) +
                        (tapEnabled ? _bellTurns.value : 0.0);
                    return Transform.rotate(
                      angle: turns * 2 * math.pi,
                      alignment: Alignment.topCenter,
                      child: child,
                    );
                  },
                  child: const ThemeIcon(
                    Icons.notifications_active,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
