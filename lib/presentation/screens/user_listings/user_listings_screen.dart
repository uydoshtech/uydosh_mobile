import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/scroll_utils.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/create_listing/create_listing_screen.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
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

class UserListingsScreen extends StatefulWidget {
  const UserListingsScreen({super.key});

  @override
  State<UserListingsScreen> createState() => _UserListingsScreenState();
}

class _UserListingsScreenState extends State<UserListingsScreen> {
  final ScrollController _scrollController = ScrollController();
  late final VoidCallback _throttledScrollListener;
  late final VoidCallback _resetScrollLoadingState;

  @override
  void initState() {
    super.initState();
    // Fetch user listings when screen initializes
    context.read<ListingsBloc>().add(
      const ListingsEvent.fetchUserListings(isRefresh: true),
    );

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
  }

  @override
  void dispose() {
    ScrollUtils.disposeScrollController(_scrollController);
    super.dispose();
  }

  /// Determines if more listings should be loaded
  bool _shouldLoadMore() {
    try {
      final bloc = context.read<ListingsBloc>();
      final state = bloc.state;

      return state.map(
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
      bloc.add(const ListingsEvent.fetchUserListings(isRefresh: false));
    } catch (e) {
      debugPrint("Error loading more listings: $e");
    }
  }

  Future<void> _onRefresh() async {
    context.read<ListingsBloc>().add(
      const ListingsEvent.fetchUserListings(isRefresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: L10n.get("menu_my_listings"),
        showBackButton: true,
      ),
      body: BlocListener<ListingsBloc, ListingsState>(
        listener: (context, state) {
          // Reset scroll loading state when bloc state changes
          _resetScrollLoadingState();
        },
        child: BlocSelector<ListingsBloc, ListingsState, _UserListingsData>(
          selector:
              (state) => state.map(
                initial:
                    (_) => const _UserListingsData(
                      isLoading: false,
                      hasError: false,
                      errorMessage: "",
                      listings: [],
                      hasMore: false,
                    ),
                loading:
                    (_) => const _UserListingsData(
                      isLoading: true,
                      hasError: false,
                      errorMessage: "",
                      listings: [],
                      hasMore: false,
                    ),
                loaded:
                    (loadedState) => _UserListingsData(
                      isLoading: false,
                      hasError: false,
                      errorMessage: "",
                      listings: loadedState.listings,
                      hasMore: loadedState.hasMore,
                    ),
                error:
                    (errorState) => _UserListingsData(
                      isLoading: false,
                      hasError: true,
                      errorMessage: errorState.message,
                      listings: [],
                      hasMore: false,
                    ),
              ),
          builder: (context, data) {
            if (data.isLoading) {
              return const Center(
                child: HouseLoadingIndicator(),
              );
            }

            if (data.hasError) {
              return _buildErrorState(data.errorMessage);
            }

            if (data.listings.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CommonListView(
                controller: _scrollController,
                itemCount: data.listings.length + (data.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= data.listings.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: HouseLoadingIndicator(),
                      ),
                    );
                  }
                  final listing = data.listings[index];
                  return ListingTile(
                    key: ValueKey(listing.id),
                    listing: listing,
                    forceFavorite:
                        false, // User listings don"t force favorite state
                    showHeartIcon:
                        false, // Don"t show heart icon on user listings screen
                    showActiveStatus: true, // Show active/inactive badge
                    onFavoriteRemoved:
                        null, // No callback needed for user listings
                  );
                },
                showRefreshIndicator: false, // We"re handling refresh manually
                showLoadMoreIndicator: false, // We"re handling load more manually
                cacheExtent: 500, // Larger cache for smoother scrolling of large tiles
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemeIconFactory.display(icon: Icons.home_outlined),
          const SizedBox(height: 16),
          Text(
            L10n.get("no_listings_found"),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You haven't created any listings yet.",
            style: TextStyle(fontSize: 14, color: AppColors.textGrey500),
          ),
          const SizedBox(height: 24),
          GhostButtonFactory.iconText(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => BlocProvider(
                        create:
                            (context) =>
                                SubwayStationsBloc(
                                  getIt<ISubwayStationService>(),
                                ),
                        child: BlocProvider(
                          create:
                              (context) =>
                                  LocationsBloc(getIt<ILocationService>()),
                          child: const CreateListingScreen(showAppBar: true),
                        ),
                      ),
                ),
              );
            },
            icon: Icons.add,
            text: L10n.get("create_listing"),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemeIconFactory.status(
            icon: Icons.error_outline,
            size: 64,
            isError: true,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.get("error"),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.statusInactive,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ErrorMessageHelper.sanitizeErrorMessage(errorMessage),
            style: const TextStyle(fontSize: 14, color: AppColors.textGrey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GhostButtonFactory.text(
            onPressed: _onRefresh,
            text: L10n.get("retry"),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );
  }
}
