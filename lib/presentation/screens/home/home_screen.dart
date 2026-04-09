import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/scroll_utils.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/main.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/common/pulsing_border_wrapper.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
import "package:uy_dosh/presentation/widgets/listing_tile_skeleton.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

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
  bool _isLoadingMore = false;
  bool _isCreatingSearchAlert = false;
  late final VoidCallback _throttledScrollListener;
  late final VoidCallback _resetScrollLoadingState;
  final SearchFiltersState _searchFiltersState = SearchFiltersState();
  final GlobalKey<TutorialTargetWrapperState> _searchButtonTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();

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

    // Initialize search filters state
    _searchFiltersState.initialize();

    // Apply profile-based defaults for listing type and gender when no saved prefs
    _searchFiltersState.ensureProfileDefaultsApplied();

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

    // Re-check tutorial when onboarding toggle changes (e.g. user turns it ON in settings)
    OnboardingState().addListener(_onOnboardingStateChanged);

    getIt<AppAnalyticsService>().logScreenView(screenName: "home");

    // Show search button tutorial on first visit to browse screen (with delay)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _maybeShowSearchTutorial);
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
    routeObserver.unsubscribe(this);
    OnboardingState().removeListener(_onOnboardingStateChanged);
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
    if (widget.isSearchMode) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isSearchMode ? _buildSearchAppBar() : null,
      body: Stack(
        children: [
          BlocListener<ListingsBloc, ListingsState>(
            listener: (context, state) {
              // Reset loading flag when state changes
              state.map(
                initial: (_) {
                  _isLoadingMore = false;
                  _resetScrollLoadingState();
                },
                loading: (_) {
                  _isLoadingMore = false;
                  _resetScrollLoadingState();
                },
                loaded: (_) {
                  _isLoadingMore = false;
                  _resetScrollLoadingState();
                },
                error: (_) {
                  _isLoadingMore = false;
                  _resetScrollLoadingState();
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
                  return widget.isSearchMode
                      ? _buildEmptySearchState()
                      : _buildInitialState();
                }
                return _buildLoadedState(data.listings, data.hasMore);
              },
            ),
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
                  return PulsingBorderWrapper(
                    enabled: AnimationSettingsState().searchPulseEnabled,
                    scaleTo: 1.14,
                    haloColor: ThemeState().isBlueTheme
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.24),
                    haloBlurRadius: ThemeState().isBlueTheme ? 18 : 32,
                    haloSpreadRadius: ThemeState().isBlueTheme ? 0.5 : 1.8,
                    padding: const EdgeInsets.all(2),
                    child: SearchFloatingActionButton(
                      searchFiltersState: _searchFiltersState,
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

  /// Scrollable wrapper so [RefreshIndicator] works when content is shorter than
  /// the viewport (welcome / empty states).
  Widget _buildPullToRefreshAroundFillChild(Widget child) {
    return RefreshIndicator(
      color: _getRefreshIndicatorColor(),
      backgroundColor: _getRefreshIndicatorBackgroundColor(),
      onRefresh: _onFeedPullRefresh,
      child: PullToRefreshStretchHaptics(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: child,
              ),
            ),
          ],
        ),
      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
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
                const SizedBox(height: 36),
                _buildEmptySearchCriteriaSummary(),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: _NotifySearchAlertGhostButton(
                      label: L10n.get("search_alert_notify_me"),
                      onPressed: _isCreatingSearchAlert
                          ? null
                          : _subscribeToSearchAlerts,
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

  Widget _buildEmptySearchCriteriaSummary() {
    final theme = Theme.of(context);
    final lang = L10n.currentLanguage;

    final listingTypeId = widget.useExplicitFiltersOnly
        ? (widget.listingTypeId ?? _searchFiltersState.selectedListingTypeId)
        : _searchFiltersState.selectedListingTypeId;
    final locationId = widget.useExplicitFiltersOnly
        ? widget.locationId
        : _searchFiltersState.selectedLocationIndex;
    final subwayStationId = widget.useExplicitFiltersOnly
        ? widget.subwayStationId
        : _searchFiltersState.selectedStationId;
    final subwayLineId = widget.useExplicitFiltersOnly
        ? widget.subwayLineId
        : _searchFiltersState.selectedSubwayLine;
    final gender = widget.useExplicitFiltersOnly
        ? widget.gender
        : _searchFiltersState.selectedGender;
    final minPrice = widget.useExplicitFiltersOnly
        ? (widget.minPrice ?? 10.0)
        : _searchFiltersState.minPrice;
    final maxPrice = widget.useExplicitFiltersOnly
        ? (widget.maxPrice ?? 500.0)
        : _searchFiltersState.maxPrice;
    final privateRoom = widget.useExplicitFiltersOnly
        ? (widget.privateRoom ?? false)
        : _searchFiltersState.privateRoom;
    final withPhoto = widget.useExplicitFiltersOnly
        ? (widget.withPhoto ?? false)
        : _searchFiltersState.withPhoto;

    final chips = <Widget>[];

    chips.add(
      ListingTypeBadge(
        listingTypeCode: listingTypeId == 1 ? "room_needed" : "roommate_needed",
        fontSize: 13,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
    );

    if (locationId != null && locationId > 0) {
      chips.add(
        _criteriaChip(
          icon: Icons.location_on_outlined,
          text: LocationCache.getLocationShortName(locationId, lang),
          color: AppColors.error,
        ),
      );
    }

    if (subwayStationId != null && subwayStationId > 0) {
      final station = MetroCache.getStationById(subwayStationId);
      chips.add(
        _criteriaChip(
          icon: Icons.train,
          text: MetroCache.getStationDisplayName(subwayStationId, lang),
          color: station == null
              ? theme.colorScheme.onSurfaceVariant
              : AppColors.getMetroLineColor(station.line),
        ),
      );
    } else if (subwayLineId != null && subwayLineId > 0) {
      chips.add(
        _criteriaChip(
          icon: Icons.train_outlined,
          text: MetroCache.getLineName(subwayLineId, lang),
          color: AppColors.getMetroLineColor(subwayLineId),
        ),
      );
    }

    if (gender != null && (gender == 1 || gender == 2)) {
      chips.add(
        _criteriaChip(
          icon: gender == 2 ? Icons.female : Icons.male,
          text: gender == 2 ? L10n.get("female") : L10n.get("male"),
          color: gender == 2 ? AppColors.genderFemale : AppColors.genderMale,
          tintAlpha: 0.12,
        ),
      );
    }

    chips.add(
      PriceRangeBadge(
        minPrice: minPrice.round(),
        maxPrice: maxPrice.round(),
        showCurrency: true,
        showIcon: false,
        isActive: true,
        currencySymbol: "y.e.",
        fontSize: 13,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        activeColor: AppColors.statusActive,
        useTintBackground: true,
        tintAlpha: 0.12,
      ),
    );

    if (privateRoom) {
      chips.add(
        _criteriaChip(
          icon: Icons.lock_outline,
          text: L10n.get("private_room"),
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (withPhoto) {
      chips.add(
        _criteriaChip(
          icon: Icons.photo_camera_outlined,
          text: L10n.get("search_filter_with_photo"),
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _criteriaChip({
    required IconData icon,
    required String text,
    required Color color,
    double tintAlpha = 0.1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: tintAlpha),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: 13,
              height: 1.15,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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

    setState(() => _isCreatingSearchAlert = true);
    try {
      // Match the same filters we use for search dispatch (with safe fallbacks).
      final listingTypeId = widget.useExplicitFiltersOnly
          ? (widget.listingTypeId ?? _searchFiltersState.selectedListingTypeId)
          : _searchFiltersState.selectedListingTypeId;
      final locationId = widget.useExplicitFiltersOnly
          ? widget.locationId
          : _searchFiltersState.selectedLocationIndex;
      final subwayStationId = widget.useExplicitFiltersOnly
          ? widget.subwayStationId
          : _searchFiltersState.selectedStationId;
      final subwayLineId = widget.useExplicitFiltersOnly
          ? widget.subwayLineId
          : _searchFiltersState.selectedSubwayLine;
      final gender = widget.useExplicitFiltersOnly
          ? widget.gender
          : _searchFiltersState.selectedGender;
      final minPrice =
          widget.useExplicitFiltersOnly ? (widget.minPrice ?? 10.0) : _searchFiltersState.minPrice;
      final maxPrice =
          widget.useExplicitFiltersOnly ? (widget.maxPrice ?? 500.0) : _searchFiltersState.maxPrice;
      final privateRoom = widget.useExplicitFiltersOnly
          ? (widget.privateRoom ?? false)
          : _searchFiltersState.privateRoom;
      final withPhoto = widget.useExplicitFiltersOnly
          ? (widget.withPhoto ?? false)
          : _searchFiltersState.withPhoto;

      final err = await getIt<ISearchAlertService>().createAlertForCurrentSearch(
        listingTypeId: listingTypeId,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoomOnly: privateRoom,
        withPhotoOnly: withPhoto,
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

      ToastTheme.showSuccess(context, message: L10n.get("search_alert_created"));
    } finally {
      if (mounted) {
        setState(() => _isCreatingSearchAlert = false);
      }
    }
  }

  Widget _buildLoadingState() {
    return CommonListView(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      itemSpacing: 16.0,
      itemCount: 6,
      itemBuilder: (context, index) => const ListingTileSkeleton(),
    );
  }

  Widget _buildLoadedState(List<Listing> listings, bool hasMore) {
    return RefreshIndicator(
      color: _getRefreshIndicatorColor(),
      backgroundColor: _getRefreshIndicatorBackgroundColor(),
      onRefresh: _onFeedPullRefresh,
      child: PullToRefreshStretchHaptics(
        child: CommonListView(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return ListingTile(
              key: ValueKey(listing.id),
              listing: listing,
              forceFavorite:
                  false, // Home screen listings don"t force favorite state
              showHeartIcon: false, // Don"t show heart icon on home screen
              onFavoriteRemoved: null, // No callback needed for home screen
            );
          },
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          showRefreshIndicator:
              false, // Already handled by RefreshIndicator wrapper
          showLoadMoreIndicator: hasMore,
          hasMore: hasMore,
          loadMoreIndicator: _buildLoadMoreIndicator(),
          cacheExtent:
              500, // Larger cache for smoother scrolling of large tiles
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

  /// Get the color for the refresh indicator arrow and progress
  Color _getRefreshIndicatorColor() {
    final currentTheme = ThemeState().currentTheme;
    if (currentTheme == AppTheme.blueTheme) {
      return Colors.white; // White arrow for blue theme
    }
    return Theme.of(
      context,
    ).colorScheme.primary; // Default theme color for light theme
  }

  /// Get the background color for the refresh indicator
  Color _getRefreshIndicatorBackgroundColor() {
    final currentTheme = ThemeState().currentTheme;
    if (currentTheme == AppTheme.blueTheme) {
      return Colors.white.withValues(
        alpha: 0.2,
      ); // Semi-transparent white background
    }
    return Colors.transparent; // Transparent background for light theme
  }

  /// Build search app bar for search mode
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      title: BlocSelector<ListingsBloc, ListingsState, int?>(
        selector: (state) => state.map(
          initial: (_) => null,
          loading: (_) => null,
          loaded: (loadedState) => loadedState.listings.length,
          error: (_) => null,
        ),
        builder: (context, count) {
          final baseTitle = L10n.get("search_results");
          final titleText = count == null ? baseTitle : "$baseTitle ($count)";
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
      foregroundColor:
          Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const ThemeIcon(Icons.arrow_back),
        onPressed: () {
          HapticFeedbackUtils.impact();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: const [],
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

    final listingTypeId = widget.useExplicitFiltersOnly
        ? widget.listingTypeId
        : _searchFiltersState.selectedListingTypeId;
    final locationId = widget.useExplicitFiltersOnly
        ? widget.locationId
        : _searchFiltersState.selectedLocationIndex;
    final subwayStationId = widget.useExplicitFiltersOnly
        ? widget.subwayStationId
        : _searchFiltersState.selectedStationId;
    final subwayLineId = widget.useExplicitFiltersOnly
        ? widget.subwayLineId
        : _searchFiltersState.selectedSubwayLine;
    final gender = widget.useExplicitFiltersOnly
        ? widget.gender
        : _searchFiltersState.selectedGender;
    final minPrice = widget.useExplicitFiltersOnly
        ? widget.minPrice
        : _searchFiltersState.minPrice;
    final maxPrice = widget.useExplicitFiltersOnly
        ? widget.maxPrice
        : _searchFiltersState.maxPrice;
    final privateRoom = widget.useExplicitFiltersOnly
        ? widget.privateRoom
        : _searchFiltersState.privateRoom;
    final withPhoto = widget.useExplicitFiltersOnly
        ? widget.withPhoto
        : _searchFiltersState.withPhoto;

    // Debug logging to see what values are being passed
    logger.d(
      "HomeScreen._dispatchSearch - subwayStationId: $subwayStationId, subwayLineId: $subwayLineId",
    );
    logger.d(
      "HomeScreen._dispatchSearch - minPrice: $minPrice, maxPrice: $maxPrice",
    );

    listingsBloc.add(
      ListingsEvent.searchListings(
        listingTypeId: listingTypeId,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoom,
        withPhoto: withPhoto,
        isRefresh: isRefresh,
      ),
    );
  }

  /// Calculate total unread count from all conversations
  int _calculateTotalUnreadCount(List<ConversationSummary> conversations) {
    return conversations.fold(0, (sum, conversation) {
      if (conversation.unreadCount != null &&
          conversation.unreadCount! > 0 &&
          conversation.lastMessageSenderId != null) {
        // Only count as unread if the last message was not sent by the current user
        // We need to get the current user ID to properly filter
        return sum + conversation.unreadCount!;
      }
      return sum;
    });
  }
}

/// Notify-me control: expanding ring + bell wiggle on tap.
class _NotifySearchAlertGhostButton extends StatefulWidget {
  const _NotifySearchAlertGhostButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<_NotifySearchAlertGhostButton> createState() =>
      _NotifySearchAlertGhostButtonState();
}

class _NotifySearchAlertGhostButtonState extends State<_NotifySearchAlertGhostButton>
    with TickerProviderStateMixin {
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
      _idleController.value = 0;
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
    final isBlueTheme = ThemeState().isBlueTheme;
    final tapEnabled = _animationSettings.bellTapEnabled;

    return GhostButton(
      onPressed: widget.onPressed == null ? null : _handlePressed,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 21),
      borderRadius: BorderRadius.circular(10),
      borderWidth: isBlueTheme ? 1.5 : 2.0,
      borderColor: isBlueTheme ? Colors.white.withValues(alpha: 0.14) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
                        final turns = _idleBellTurns.value +
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
          Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
