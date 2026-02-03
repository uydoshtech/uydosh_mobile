import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
import "package:uy_dosh/presentation/widgets/listing_tile_skeleton.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/base/utils/scroll_utils.dart";
import "package:uy_dosh/main.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
class _HomeScreenData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Listing> listings;
  final bool hasMore;

  const _HomeScreenData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listings,
    required this.hasMore,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _HomeScreenData &&
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

class HomeScreen extends StatefulWidget {
  final int? listingTypeId;
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool isSearchMode;

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
    this.isSearchMode = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late final VoidCallback _throttledScrollListener;
  late final VoidCallback _resetScrollLoadingState;
  final SearchFiltersState _searchFiltersState = SearchFiltersState();

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

    // Initialize search filters with current parameters if in search mode
    if (widget.isSearchMode) {
      _initializeSearchFilters();
      // Trigger search when screen loads in search mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }

    // Listen to home refresh state for immediate refresh commands
    HomeRefreshState().addListener(_onHomeRefreshStateChanged);
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
      final bloc = context.read<ListingsBloc>();

      if (widget.isSearchMode) {
        // Use search filters for search mode
        bloc.add(
          ListingsEvent.searchListings(
            listingTypeId: _searchFiltersState.selectedListingTypeId,
            locationId: _searchFiltersState.selectedLocationIndex,
            subwayStationId: _searchFiltersState.selectedStationId,
            subwayLineId: _searchFiltersState.selectedSubwayLine,
            gender: _searchFiltersState.selectedGender,
            minPrice: _searchFiltersState.minPrice,
            maxPrice: _searchFiltersState.maxPrice,
            privateRoom: _searchFiltersState.privateRoom,
            isRefresh: true,
          ),
        );
      } else {
        // Use default search for home mode
        bloc.add(const ListingsEvent.searchListings(isRefresh: true));
      }
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
              selector:
                  (state) => state.map(
                    initial:
                        (_) => _HomeScreenData(
                          isLoading: false,
                          hasError: false,
                          errorMessage: "",
                          listings: [],
                          hasMore: false,
                        ),
                    loading:
                        (_) => _HomeScreenData(
                          isLoading: true,
                          hasError: false,
                          errorMessage: "",
                          listings: [],
                          hasMore: false,
                        ),
                    loaded:
                        (loadedState) => _HomeScreenData(
                          isLoading: false,
                          hasError: false,
                          errorMessage: "",
                          listings: loadedState.listings,
                          hasMore: loadedState.hasMore,
                        ),
                    error:
                        (errorState) => _HomeScreenData(
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
          // Positioned floating action button
          Positioned(
            right: 16,
            bottom: 30, // Moved down a bit from 100
            child: SearchFloatingActionButton(
              searchFiltersState: _searchFiltersState,
              replaceCurrentRoute: widget.isSearchMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: _getHomeIconColor()),
          const SizedBox(height: 16),
          LanguageAwareStringHelper.getText(
            "welcome_title",
            context,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getWelcomeTitleColor(),
            ),
          ),
          const SizedBox(height: 8),
          LanguageAwareStringHelper.getText(
            "welcome_subtitle",
            context,
            style: TextStyle(fontSize: 16, color: _getWelcomeSubtitleColor()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: _getHomeIconColor()),
          const SizedBox(height: 16),
          LanguageAwareStringHelper.getText(
            "no_search_results",
            context,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getWelcomeTitleColor(),
            ),
          ),
          const SizedBox(height: 8),
          LanguageAwareStringHelper.getText(
            "try_refining_search",
            context,
            style: TextStyle(fontSize: 16, color: _getWelcomeSubtitleColor()),
          ),
          const SizedBox(height: 24),
          GhostButtonFactory.iconText(
            onPressed:
                () => SearchBottomSheetWidget.show(
                  context,
                  replaceCurrentRoute: true,
                  currentListingTypeId:
                      _searchFiltersState.selectedListingTypeId,
                  currentLocationId: _searchFiltersState.selectedLocationIndex,
                  currentSubwayStationId: _searchFiltersState.selectedStationId,
                  currentSubwayLineId: _searchFiltersState.selectedSubwayLine,
                  currentGender: _searchFiltersState.selectedGender,
                  currentMinPrice: _searchFiltersState.minPrice,
                  currentMaxPrice: _searchFiltersState.maxPrice,
                ),
            icon: Icons.search,
            text: LanguageAwareStringHelper.getCurrent(
              context,
              "refine_search",
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return CommonListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemSpacing: 12.0,
      children: List.generate(6, (index) => const ListingTileSkeleton()),
    );
  }

  Widget _buildLoadedState(List<Listing> listings, bool hasMore) {
    if (listings.isEmpty) {
      return CommonStateBuilder(
        isLoading: false,
        hasError: false,
        isEmpty: true,
        emptyMessage: LanguageAwareStringHelper.getCurrent(
          context,
          "no_listings_found",
        ),
        emptySubtitle: LanguageAwareStringHelper.getCurrent(
          context,
          "try_refreshing",
        ),
        emptyIcon: Icons.home_outlined,
        child: Container(), // This won"t be shown when empty
      );
    }

    return RefreshIndicator(
      color: _getRefreshIndicatorColor(),
      backgroundColor: _getRefreshIndicatorBackgroundColor(),
      onRefresh: () async {
        // Refresh listings
        final bloc = context.read<ListingsBloc>();

        if (widget.isSearchMode) {
          // Use search filters for search mode
          bloc.add(
            ListingsEvent.searchListings(
              listingTypeId: _searchFiltersState.selectedListingTypeId,
              locationId: _searchFiltersState.selectedLocationIndex,
              subwayStationId: _searchFiltersState.selectedStationId,
              subwayLineId: _searchFiltersState.selectedSubwayLine,
              gender: _searchFiltersState.selectedGender,
              minPrice: _searchFiltersState.minPrice,
              maxPrice: _searchFiltersState.maxPrice,
              isRefresh: true,
            ),
          );
        } else {
          // Use default search for home mode
          bloc.add(const ListingsEvent.searchListings(isRefresh: true));
        }
      },
      child: ListenableBuilder(
        listenable: FavoritesState(),
        builder: (context, child) {
          return CommonListView(
            children:
                listings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final listing = entry.value;

                  return ListingTile(
                    listing: listing,
                    forceFavorite:
                        false, // Home screen listings don"t force favorite state
                    showHeartIcon:
                        false, // Don"t show heart icon on home screen
                    onFavoriteRemoved:
                        null, // No callback needed for home screen
                  );
                }).toList(),
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            showRefreshIndicator:
                false, // Already handled by RefreshIndicator wrapper
            showLoadMoreIndicator: hasMore,
            hasMore: hasMore,
            loadMoreIndicator: _buildLoadMoreIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return CenteredHouseLoadingIndicator(
      text: LanguageAwareStringHelper.getCurrent(context, "loading_listings"),
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
        selector:
            (state) => state.map(
              initial: (_) => null,
              loading: (_) => null,
              loaded: (loadedState) => loadedState.listings.length,
              error: (_) => null,
            ),
        builder: (context, count) {
          final baseTitle = LanguageAwareStringHelper.getCurrent(
            context,
            "search_results",
          );
          final titleText =
              count == null ? baseTitle : "$baseTitle ($count)";
          return Text(
            titleText,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          );
        },
      ),
      backgroundColor:
          Theme.of(context).appBarTheme.backgroundColor ??
          (ThemeState().isBlueTheme
              ? BlueThemeColors.surface
              : Theme.of(context).colorScheme.primary),
      foregroundColor:
          Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [],
    );
  }

  /// Perform search using current filters
  void _performSearch() {
    final listingsBloc = context.read<ListingsBloc>();

    // Debug logging to see what values are being passed
    logger.d(
      "HomeScreen._performSearch - subwayStationId: ${_searchFiltersState.selectedStationId}, subwayLineId: ${_searchFiltersState.selectedSubwayLine}",
    );
    logger.d(
      "HomeScreen._performSearch - minPrice: ${_searchFiltersState.minPrice}, maxPrice: ${_searchFiltersState.maxPrice}",
    );

    listingsBloc.add(
      ListingsEvent.searchListings(
        listingTypeId: _searchFiltersState.selectedListingTypeId,
        locationId: _searchFiltersState.selectedLocationIndex,
        subwayStationId: _searchFiltersState.selectedStationId,
        subwayLineId: _searchFiltersState.selectedSubwayLine,
        gender: _searchFiltersState.selectedGender,
        minPrice: _searchFiltersState.minPrice,
        maxPrice: _searchFiltersState.maxPrice,
        privateRoom: _searchFiltersState.privateRoom,
        isRefresh: true, // Ensure this is a fresh search
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
