import "package:uy_dosh/base/logger/logger.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/session_manager.dart";

import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const int _pageLimit = 50; // Page size for API calls

  List<Listing> _favoriteListings = [];
  Set<int> _itemsBeingRemoved = {}; // Track items being removed for animation
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _hasError = false; // Add error state
  int _currentPage = 1;
  late final IFavoriteService _favoriteService;
  late final VoidCallback _authListener;
  bool _hasInitialized = false; // Track if initial load has been done

  @override
  void initState() {
    super.initState();
    _favoriteService = getIt<IFavoriteService>();

    // Create and store the authentication state listener
    _authListener = () {
      if (mounted) {
        // Reset initialization when auth state changes
        _resetInitialization();
        setState(() {});
      }
    };

    // Listen to authentication state changes
    AuthenticationState().addListener(_authListener);

    // Wait for authentication state to be initialized, then check if we should load favorites
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
        ModalRoute.of(context)?.isCurrent == true &&
        AuthenticationState().isAuthenticated) {
      _loadFavoriteListings(isRefresh: true);
    }
  }

  @override
  void dispose() {
    // Remove the authentication state listener
    AuthenticationState().removeListener(_authListener);
    super.dispose();
  }

  // Reset initialization flag when user logs out
  void _resetInitialization() {
    _hasInitialized = false;
  }

  Future<void> _loadFavoriteListings({bool isRefresh = false}) async {
    // Check authentication status first
    if (!AuthenticationState().isAuthenticated) {
      logger.d(
        "❌ FavoritesScreen: User not authenticated, cannot load favorites",
      );
      setState(() {
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
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _favoriteListings.clear();
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
        logger.d(
          "🔐 FavoritesScreen: Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
        );
      }

      if (!isAuthenticated) {
        logger.d(
          "❌ FavoritesScreen: User not authenticated, cannot load favorites",
        );
        setState(() {
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

      setState(() {
        if (isRefresh) {
          _favoriteListings = favoriteListings;
        } else {
          _favoriteListings.addAll(favoriteListings);
        }
        _hasMoreData =
            favoriteListings.length >=
            _pageLimit; // If we got less than limit, no more data
        _isLoading = false;
        _hasError = false; // Clear error state on success
      });
    } catch (e) {
      logger.d("❌ FavoritesScreen: Error loading favorite listings: $e");

      // Check if this is an authentication error
      final isAuthError =
          e.toString().contains("401") ||
          e.toString().contains("Unauthorized") ||
          e.toString().contains("Invalid or expired session token");

      setState(() {
        if (isRefresh) {
          _favoriteListings = [];
        }
        _isLoading = false;
        _hasError = true; // Set error state
      });

      // Show appropriate error message based on error type
      if (mounted) {
        String errorMessage;
        String actionLabel;
        VoidCallback? action;

        if (isAuthError) {
          errorMessage =
              "Authentication required. Please log in again to view your favorites.";
          actionLabel = "Log In";
          action = () async {
            // Use centralized logout service
            await LogoutService().performLogout(context);
            // Navigate to auth wizard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthWizardScreen()),
            );
          };
        } else if (e.toString().contains("network") ||
            e.toString().contains("connection")) {
          errorMessage =
              "Network error. Please check your connection and try again.";
          actionLabel = "Retry";
          action = () => _loadFavoriteListings(isRefresh: true);
        } else {
          errorMessage = LanguageAwareStringHelper.getCurrent(
            context,
            "unable_to_load_favorites",
          );
          actionLabel = "Retry";
          action = () => _loadFavoriteListings(isRefresh: true);
        }

        if (isAuthError) {
          ToastTheme.showInfo(context, message: errorMessage);
        } else {
          ToastTheme.showError(context, message: errorMessage);
        }
      }
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

      setState(() {
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
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    // Check authentication status first
    if (!AuthenticationState().isAuthenticated) {
      return _buildAuthenticationRequiredState();
    }

    if (_isLoading) {
      return CenteredHouseLoadingIndicator(
        text: LanguageAwareStringHelper.getCurrent(context, "loading"),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_favoriteListings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadFavoriteListings(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _favoriteListings.length + (_hasMoreData ? 1 : 0),
        addAutomaticKeepAlives:
            false, // Prevents keeping off-screen items alive
        addRepaintBoundaries: false, // Reduces repaint overhead
        itemBuilder: (context, index) {
          // Show "load more" indicator at the end
          if (index == _favoriteListings.length) {
            if (_isLoadingMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getLoadingIndicatorColor(),
                    ),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: GhostButtonFactory.text(
                    onPressed: _loadMoreFavorites,
                    text: LanguageAwareStringHelper.getCurrent(
                      context,
                      "load_more",
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              );
            }
          }

          final listing = _favoriteListings[index];

          return AnimatedContainer(
            key: ValueKey(listing.id),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _itemsBeingRemoved.contains(listing.id) ? 0 : null,
            margin: EdgeInsets.only(
              bottom: _itemsBeingRemoved.contains(listing.id) ? 0 : 12.0,
            ),
            child:
                _itemsBeingRemoved.contains(listing.id)
                    ? const SizedBox.shrink()
                    : ListingTile(
                      key: ValueKey(
                        listing.id,
                      ), // Add key for better performance
                      listing: listing,
                      forceFavorite:
                          true, // Force red heart for all listings on favorites screen
                      showHeartIcon:
                          true, // Show heart icon on favorites screen
                      onFavoriteRemoved: () {
                        // Start the collapse animation
                        setState(() {
                          _itemsBeingRemoved.add(listing.id);
                        });

                        // Remove from favorites after animation
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _removeFromFavorites(listing.id);
                        });
                      },
                    ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ThemeIconFactory.display(icon: Icons.favorite_border),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: LanguageState(),
                    builder: (context, child) {
                      return LanguageAwareStringHelper.getText(
                        "favorites_empty_title",
                        context,
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
    );
  }

  Widget _buildErrorState() {
    return Builder(
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: _getEmptyStateIconColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Authentication Required",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getEmptyStateTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please log in again to view your favorites. Your session may have expired.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getEmptyStateTextColor(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GhostButtonFactory.iconText(
                    onPressed: () async {
                      // Use centralized logout service
                      await LogoutService().performLogout(context);
                      // Navigate to auth wizard
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AuthWizardScreen(),
                        ),
                      );
                    },
                    icon: Icons.login,
                    text: "Log In Again",
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAuthenticationRequiredState() {
    return Builder(
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: _getEmptyStateIconColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Authentication Required",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getEmptyStateTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please log in to view your favorites.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getEmptyStateTextColor(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GhostButtonFactory.iconText(
                    onPressed: () {
                      // Navigate to auth wizard
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AuthWizardScreen(),
                        ),
                      );
                    },
                    icon: Icons.login,
                    text: "Log In",
                  ),
                ],
              ),
            ),
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
      return AppColors.primary; // Purple for purple theme
    }
  }

  // Theme-dependent color method for empty state icon
  Color _getEmptyStateIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White for blue theme
    } else {
      return AppColors.textGrey400; // Grey for purple theme
    }
  }

  // Theme-dependent color method for empty state text
  Color _getEmptyStateTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White for blue theme
    } else {
      return AppColors.textGrey600; // Grey for purple theme
    }
  }

  // Build theme-aware button - use GhostButton for all themes
  Widget _buildThemeAwareButton() {
    final onPressed = () {
      // Navigate to home screen to browse listings
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    };

    // Use GhostButton for all themes - it"s already theme-aware
    return GhostButtonFactory.iconText(
      onPressed: onPressed,
      icon: Icons.home,
      text: LanguageAwareStringHelper.getCurrent(
        context,
        "favorites_browse_button",
      ),
    );
  }

  Future<void> _removeFromFavorites(int listingId) async {
    // Check authentication status
    if (!AuthenticationState().isAuthenticated) {
      logger.d(
        "❌ FavoritesScreen: User not authenticated, cannot remove from favorites",
      );
      return;
    }

    if (mounted) {
      setState(() {
        _itemsBeingRemoved.remove(listingId);
        _favoriteListings.removeWhere((listing) => listing.id == listingId);
      });
    }

    try {
      await _favoriteService.removeFromFavorites(listingId);
      logger.d(
        "✅ FavoritesScreen: Successfully removed listing $listingId from favorites",
      );
    } catch (e) {
      logger.d(
        "❌ FavoritesScreen: Error removing listing $listingId from favorites: $e",
      );
      if (mounted) {
        ToastTheme.showError(
          context,
          message: "Failed to remove from favorites.",
        );
      }
    }
  }
}
