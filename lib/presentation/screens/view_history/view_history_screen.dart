import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

/// Screen showing listings the user has viewed.
class ViewHistoryScreen extends StatefulWidget {
  const ViewHistoryScreen({super.key});

  @override
  State<ViewHistoryScreen> createState() => _ViewHistoryScreenState();
}

class _ViewHistoryScreenState extends State<ViewHistoryScreen> {
  static const int _pageLimit = 50;

  List<Listing> _viewedListings = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _hasError = false;
  int _currentPage = 1;
  late final IListingService _listingService;

  @override
  void initState() {
    super.initState();
    _listingService = getIt<IListingService>();
    _loadViewedListings(isRefresh: true);
  }

  Future<void> _loadViewedListings({bool isRefresh = false}) async {
    if (!AuthenticationState().isAuthenticated) {
      setState(() {
        _viewedListings = [];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    if (_isLoading) return;

    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _viewedListings.clear();
      });
    }

    setState(() => _isLoading = true);

    try {
      final response = await _listingService.getViewedListings(
        page: _currentPage,
        limit: _pageLimit,
      );

      if (!mounted) return;
      setState(() {
        if (isRefresh) {
          _viewedListings = response.data;
        } else {
          _viewedListings.addAll(response.data);
        }
        _hasMoreData = response.hasMore;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      logger.d("ViewHistoryScreen: Error loading viewed listings: $e");
      if (!mounted) return;
      final isAuthError = e.toString().contains("401") ||
          e.toString().contains("Unauthorized") ||
          e.toString().contains("Invalid or expired session token");

      setState(() {
        if (isRefresh) _viewedListings = [];
        _isLoading = false;
        _hasError = true;
      });

      if (mounted) {
        if (isAuthError) {
          ToastTheme.showInfo(
            context,
            message:
                "Authentication required. Please log in again to view your history.",
          );
        } else {
          ToastTheme.showError(
            context,
            message: L10n.get("unable_to_load_view_history"),
          );
        }
      }
    }
  }

  Future<void> _loadMoreViewedListings() async {
    if (_isLoadingMore || !_hasMoreData) return;
    if (!AuthenticationState().isAuthenticated) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final response = await _listingService.getViewedListings(
        page: _currentPage,
        limit: _pageLimit,
      );

      if (!mounted) return;
      setState(() {
        _viewedListings.addAll(response.data);
        _hasMoreData = response.hasMore;
        _isLoadingMore = false;
      });
    } catch (e) {
      logger.d("ViewHistoryScreen: Error loading more: $e");
      if (mounted) {
        setState(() {
          _currentPage--;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) => Scaffold(
        appBar: CommonAppBar(
          title: L10n.get("view_history_title"),
          showBackButton: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!AuthenticationState().isAuthenticated) {
      return _buildAuthenticationRequiredState();
    }

    if (_isLoading && _viewedListings.isEmpty) {
      return CenteredHouseLoadingIndicator(
        text: L10n.get("loading"),
      );
    }

    if (_hasError && _viewedListings.isEmpty) {
      return _buildErrorState();
    }

    if (_viewedListings.isEmpty) {
      return _buildEmptyState();
    }

    return CommonListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _viewedListings.length,
      itemSpacing: 16.0,
      itemBuilder: (context, index) {
        final listing = _viewedListings[index];
        return ListingTile(
          key: ValueKey(listing.id),
          listing: listing,
          showHeartIcon: true,
        );
      },
      showRefreshIndicator: true,
      onRefresh: () => _loadViewedListings(isRefresh: true),
      showLoadMoreIndicator: _hasMoreData,
      hasMore: _hasMoreData,
      loadMoreIndicator: _isLoadingMore
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeState().isBlueTheme
                        ? BlueThemeColors.buttonPrimary
                        : Colors.black,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: GhostButtonFactory.text(
                  onPressed: _loadMoreViewedListings,
                  text: L10n.get("load_more"),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ThemeIconFactory.display(icon: Icons.history),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: LanguageState(),
                builder: (context, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: L10n.text(
                      "view_history_empty_title",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getEmptyStateTextColor(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildBrowseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseButton() {
    return GhostButtonFactory.iconText(
      onPressed: () => context.pushReplaceMainNavigation(),
      icon: Icons.home,
      text: L10n.get("view_history_browse_button"),
    );
  }

  Widget _buildErrorState() {
    return Builder(
      builder: (context) => Padding(
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
                L10n.get("unable_to_load_view_history"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _getEmptyStateTextColor(),
                ),
              ),
              const SizedBox(height: 24),
              GhostButtonFactory.iconText(
                onPressed: () => _loadViewedListings(isRefresh: true),
                icon: Icons.refresh,
                text: L10n.get("retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticationRequiredState() {
    return Builder(
      builder: (context) => Padding(
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
                L10n.get("auth_required_title"),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getEmptyStateTextColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.get("view_history_auth_prompt"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _getEmptyStateTextColor(),
                ),
              ),
              const SizedBox(height: 24),
              GhostButtonFactory.iconText(
                onPressed: () => context.pushReplaceAuthWizard(),
                icon: Icons.login,
                text: L10n.get("menu_registration"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEmptyStateIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    }
    return AppColors.textGrey400;
  }

  Color _getEmptyStateTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    }
    return AppColors.textGrey600;
  }
}
