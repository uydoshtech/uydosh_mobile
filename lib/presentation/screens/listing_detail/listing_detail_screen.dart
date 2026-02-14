import "package:uy_dosh/base/logger/logger.dart";
import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/private_room_icon.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/string_helper.dart";
import "package:share_plus/share_plus.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/presentation/screens/edit_listing/edit_listing_screen.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/complaint/create_complaint_screen.dart";
import "package:uy_dosh/presentation/screens/complaint/listing_complaints_screen.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/oauth_dio_configurator.dart";
import "package:uy_dosh/base/api/auth_token_repository.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:http/http.dart" as http;
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/widgets/common/full_screen_photo_viewer.dart";
import "package:uy_dosh/presentation/widgets/common/primary_photo_pill.dart";
import "package:uy_dosh/base/utils/animation_utils.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_compatibility_section.dart";

// Data classes for BlocSelector to reduce unnecessary rebuilds
class _ListingDetailIconsData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ListingDetail? listingDetail;

  const _ListingDetailIconsData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listingDetail,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ListingDetailIconsData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.listingDetail?.id == listingDetail?.id;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        (listingDetail?.id ?? 0).hashCode;
  }
}

class _ListingDetailBodyData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ListingDetail? listingDetail;

  const _ListingDetailBodyData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listingDetail,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ListingDetailBodyData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.listingDetail?.id == listingDetail?.id;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        (listingDetail?.id ?? 0).hashCode;
  }
}

class _CompatibilityResult {
  final int? percent;
  final List<_CompatibilityMatch> matches;
  final List<_CompatibilityDifference> differences;

  const _CompatibilityResult({
    required this.percent,
    required this.matches,
    required this.differences,
  });
}

class _CompatibilityMatch {
  final String labelKey;
  final String label;
  final String value;

  const _CompatibilityMatch({
    required this.labelKey,
    required this.label,
    required this.value,
  });
}

class _CompatibilityDifference {
  final String labelKey;
  final String label;
  final String currentText;
  final String ownerText;

  const _CompatibilityDifference({
    required this.labelKey,
    required this.label,
    required this.currentText,
    required this.ownerText,
  });
}

class ListingDetailScreen extends StatefulWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late AnimationController _warningBlinkController;
  late Animation<double> _warningBlinkAnimation;
  late PageController _pageController;
  late ScrollController _scrollController;
  final GlobalKey _compatibilitySectionKey = GlobalKey();

  // Loading state for toggle button
  bool _isToggling = false;

  // Loading state for delete button
  bool _isDeleting = false;

  // Loading state for complaints count
  bool _isLoadingComplaintsCount = false;
  int? _complaintsCount;
  int? _complaintsCountListingId;

  // Compatibility state
  bool _isLoadingCompatibility = false;
  int? _compatibilityListingUserId;
  int? _compatibilityPercent;
  List<_CompatibilityMatch> _compatibilityMatches = [];
  List<_CompatibilityDifference> _compatibilityDifferences = [];
  String? _compatibilityError;


  @override
  void initState() {
    super.initState();

    // Initialize user listing state
    UserListingState().initialize();

    // Refresh user ID to ensure we have the current user
    UserListingState().refreshUserId();

    // Initialize favorites state
    FavoritesState().initialize();

    // Initialize heart animation with optimized controller
    _heartAnimationController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _heartScaleAnimation = AnimationUtils.createScaleAnimation(
      controller: _heartAnimationController,
      begin: 1.0,
      end: 1.3,
    );

    _warningBlinkController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _warningBlinkAnimation = AnimationUtils.createFadeAnimation(
      controller: _warningBlinkController,
      begin: 0.25,
      end: 1.0,
      curve: Curves.easeInOut,
    );
    _warningBlinkController.repeat(reverse: true);

    // Initialize page controller for photo carousel
    _pageController = PageController();
    _scrollController = ScrollController();

    // Fetch listing details
    context.read<ListingDetailBloc>().add(
      ListingDetailEvent.fetchListingDetail(id: widget.listingId),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Favorite status check is now handled by BlocListener when data loads
  }

  @override
  void dispose() {
    AnimationUtils.disposeAnimationController(_heartAnimationController);
    AnimationUtils.disposeAnimationController(_warningBlinkController);
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Toggle listing active status
  Future<void> _toggleListingActive(int listingId) async {
    try {
      logger.d(
        "🔄 Starting toggle listing active status for listing ID: $listingId",
      );

      // Set loading state and update UI
      setState(() {
        _isToggling = true;
      });
      logger.d("🔄 Loading state set, button should now show loading...");

      // Show loading state on button (no toast)
      logger.d("🔄 Toggling listing status...");

      // Hardcoded direct API call to the working endpoint
      final token = await SessionManager.getToken();
      if (token == null) {
        throw Exception("No authentication token");
      }

      logger.d("🔄 Making direct API call to toggle listing...");
      logger.d(
        "🔄 URL: ${EnvironmentUtil.basePath}/listings/$listingId/toggle-active",
      );
      logger.d("🔄 Method: PATCH (correct method for updating resources)");
      logger.d("🔄 Token: ${token.substring(0, 20)}...");
      logger.d(
        "🔄 Headers: Authorization: Bearer ${token.substring(0, 20)}..., Content-Type: application/json",
      );

      logger.d("🔄 Sending HTTP PATCH request...");
      final response = await http.patch(
        Uri.parse(
          "${EnvironmentUtil.basePath}/listings/$listingId/toggle-active",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      logger.d("🔄 HTTP request completed!");
      logger.d("🔄 Response status code: ${response.statusCode}");
      logger.d("🔄 Response headers: ${response.headers}");
      logger.d("🔄 Response body length: ${response.body.length}");
      logger.d("🔄 Response body: \"${response.body}\"");

      if (response.statusCode == 200) {
        logger.d("✅ SUCCESS: HTTP 200 response received");
        logger.d("✅ Response indicates successful toggle");
      } else {
        logger.d("❌ ERROR: HTTP ${response.statusCode} response received");
        logger.d("❌ This indicates the request failed");
      }

      final success = response.statusCode == 200;

      if (success) {
        logger.d("✅ Toggle successful");

        // Update the listing data in the BLoC state to reflect the new status
        if (mounted) {
          logger.d("🔄 Updating listing data in BLoC state...");

          // Get current state and update the listing"s isActive status
          final currentState = context.read<ListingDetailBloc>().state;
          currentState.map(
            initial:
                (_) => logger.d("🔄 Current state: initial - cannot update"),
            loading:
                (_) => logger.d("🔄 Current state: loading - cannot update"),
            loaded: (loadedState) {
              logger.d(
                "🔄 Current listing active status: ${loadedState.listingDetail.isActive}",
              );
              logger.d(
                "🔄 About to update to: ${!loadedState.listingDetail.isActive}",
              );

              // Create updated listing with toggled status
              final updatedListing = loadedState.listingDetail.copyWith(
                isActive: !loadedState.listingDetail.isActive,
              );

              // Emit the updated state
              context.read<ListingDetailBloc>().emit(
                ListingDetailState.loaded(listingDetail: updatedListing),
              );

              logger.d("✅ Listing status updated in BLoC state");
            },
            error:
                (errorState) =>
                    logger.d("🔄 Current state: error - cannot update"),
          );
        }

        // Mark home screen for refresh to reflect the status change
        HomeRefreshState().markForRefresh();

        // Reset loading state
        setState(() {
          _isToggling = false;
        });
        logger.d(
          "✅ Loading state reset, button should now be interactive again",
        );
      } else {
        logger.d("❌ Toggle failed - HTTP status was not 200");
        logger.d("❌ HTTP status: ${response.statusCode}");
        logger.d("❌ Response body: \"${response.body}\"");
        throw Exception(
          "Failed to toggle listing active status - HTTP ${response.statusCode}",
        );
      }
    } catch (e) {
      logger.d("❌ Error toggling listing active status: $e");
      logger.d("❌ Error type: ${e.runtimeType}");
      logger.d("❌ Error details: $e");

      // Show error message
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "error_deactivating_listing",
        ),
      );
    } finally {
      // Always reset loading state, even if there was an error
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
        logger.d("🔄 Loading state reset in finally block");
      }
    }
  }

  // Pulsate heart animation when adding to favorites
  void _pulsateHeart() {
    // Pulsate 3 times
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse().then((_) {
        _heartAnimationController.forward().then((_) {
          _heartAnimationController.reverse().then((_) {
            _heartAnimationController.forward().then((_) {
              _heartAnimationController.reverse();
            });
          });
        });
      });
    });
  }

  // Check favorite status from server and sync with global state
  Future<void> _checkFavoriteStatusFromServer() async {
    // First check if user is authenticated
    final authState = AuthenticationState();
    if (!authState.isAuthenticated) {
      return;
    }

    // Then check if user listing state is initialized
    final userListingState = UserListingState();
    if (!userListingState.isInitialized ||
        userListingState.currentUserId == null) {
      return;
    }

    // Get the current listing user ID to check ownership
    final listingUserId = _getCurrentListingUserId();
    if (listingUserId == null) {
      return;
    }

    // If user is the owner, they can"t have favorites, so no need to check
    if (userListingState.isOwner(listingUserId)) {
      return;
    }

    try {
      final favoriteService = FavoriteService(
        OAuthApiClient(
          configurator: OAuthDioConfigurator(tokenRepo: AuthTokenRepository()),
        ),
      );

      final isFavorite = await favoriteService.checkIfFavorited(
        widget.listingId,
      );

      if (mounted) {
        // Update global favorites state to keep it in sync with server
        final favoritesState = FavoritesState();

        if (isFavorite) {
          await favoritesState.addToFavorites(widget.listingId);
        } else {
          await favoritesState.removeFromFavorites(widget.listingId);
        }
      }
    } catch (e) {
      logger.e("Error checking favorite status from server: $e");
      // Don"t show error to user for this check, just log it
      // The heart icon will show as unfavorited by default
    }
  }

  Future<void> _loadComplaintCount(int listingId) async {
    if (_isLoadingComplaintsCount && _complaintsCountListingId == listingId) {
      return;
    }

    setState(() {
      _isLoadingComplaintsCount = true;
      _complaintsCountListingId = listingId;
    });

    try {
      final complaintService = getIt<IComplaintService>();
      final count = await complaintService.getListingComplaintsCount(listingId);

      if (!mounted) return;
      setState(() {
        _complaintsCount = count;
        _isLoadingComplaintsCount = false;
      });
    } catch (e) {
      logger.d("Error loading complaints count: $e");
      if (!mounted) return;
      setState(() {
        _isLoadingComplaintsCount = false;
      });
    }
  }

  Future<void> _loadCompatibility(int listingUserId) async {
    final authState = AuthenticationState();
    if (!authState.isAuthenticated) {
      return;
    }

    if (_isLoadingCompatibility &&
        _compatibilityListingUserId == listingUserId) {
      return;
    }

    setState(() {
      _isLoadingCompatibility = true;
      _compatibilityListingUserId = listingUserId;
      _compatibilityError = null;
      _compatibilityPercent = null;
      _compatibilityMatches = [];
      _compatibilityDifferences = [];
    });

    try {
      final userProfileService = getIt<IUserProfileService>();
      final profiles = await Future.wait([
        userProfileService.getCurrentUserProfile(),
        userProfileService.getUserProfile(listingUserId),
      ]);

      final currentProfile = profiles[0];
      final ownerProfile = profiles[1];
      final result = _calculateCompatibility(currentProfile, ownerProfile);

      if (!mounted) return;
      setState(() {
        _compatibilityPercent = result.percent;
        _compatibilityMatches = result.matches;
        _compatibilityDifferences = result.differences;
        _isLoadingCompatibility = false;
      });
    } catch (e) {
      logger.d("Error loading compatibility: $e");
      if (!mounted) return;
      setState(() {
        _isLoadingCompatibility = false;
        _compatibilityPercent = null;
        _compatibilityMatches = [];
        _compatibilityDifferences = [];
        _compatibilityError = e.toString();
      });
    }
  }

  _CompatibilityResult _calculateCompatibility(
    UserProfile currentProfile,
    UserProfile ownerProfile,
  ) {
    int total = 0;
    int matched = 0;
    final matches = <_CompatibilityMatch>[];
    final differences = <_CompatibilityDifference>[];

    void compare<T>({
      required String labelKey,
      required T? currentValue,
      required T? ownerValue,
      required bool Function(T a, T b) isMatch,
      required String Function(T value) formatValue,
    }) {
      if (currentValue == null || ownerValue == null) {
        return;
      }

      total += 1;
      final label = LanguageAwareStringHelper.getCurrent(context, labelKey);
      final currentText = formatValue(currentValue);
      final ownerText = formatValue(ownerValue);

      if (isMatch(currentValue, ownerValue)) {
        matched += 1;
        matches.add(
          _CompatibilityMatch(
            labelKey: labelKey,
            label: label,
            value: currentText,
          ),
        );
      } else {
        differences.add(
          _CompatibilityDifference(
            labelKey: labelKey,
            label: label,
            currentText: currentText,
            ownerText: ownerText,
          ),
        );
      }
    }

    compare<int>(
      labelKey: "cleanliness",
      currentValue: currentProfile.cleanliness,
      ownerValue: ownerProfile.cleanliness,
      isMatch: (a, b) => (a - b).abs() <= 1,
      formatValue: _formatCleanlinessLevel,
    );

    compare<int>(
      labelKey: "noise_level",
      currentValue: currentProfile.noiseLevel,
      ownerValue: ownerProfile.noiseLevel,
      isMatch: (a, b) => (a - b).abs() <= 1,
      formatValue: _formatNoiseLevel,
    );

    compare<int>(
      labelKey: "sociability",
      currentValue: currentProfile.sociability,
      ownerValue: ownerProfile.sociability,
      isMatch: (a, b) => (a - b).abs() <= 1,
      formatValue: _formatSociabilityLevel,
    );

    compare<bool>(
      labelKey: "guests_allowed",
      currentValue: currentProfile.guestsAllowed,
      ownerValue: ownerProfile.guestsAllowed,
      isMatch: (a, b) => a == b,
      formatValue: _formatBooleanPreference,
    );

    compare<String>(
      labelKey: "smoking_preference",
      currentValue: currentProfile.smokingPreference,
      ownerValue: ownerProfile.smokingPreference,
      isMatch: (a, b) => a == b,
      formatValue: _formatSmokingPreference,
    );

    compare<String>(
      labelKey: "alcohol_preference",
      currentValue: currentProfile.alcoholPreference,
      ownerValue: ownerProfile.alcoholPreference,
      isMatch: (a, b) => a == b,
      formatValue: _formatAlcoholPreference,
    );

    compare<bool>(
      labelKey: "cooking_habits",
      currentValue: currentProfile.cookingHabits,
      ownerValue: ownerProfile.cookingHabits,
      isMatch: (a, b) => a == b,
      formatValue: _formatCookingHabits,
    );

    compare<bool>(
      labelKey: "pets_preference",
      currentValue: currentProfile.petsPreference,
      ownerValue: ownerProfile.petsPreference,
      isMatch: (a, b) => a == b,
      formatValue: _formatPetsPreference,
    );

    compare<String>(
      labelKey: "wakeup_time",
      currentValue: currentProfile.wakeupTime,
      ownerValue: ownerProfile.wakeupTime,
      isMatch: (a, b) => a == b,
      formatValue: _formatDayPreference,
    );

    compare<String>(
      labelKey: "sleep_time",
      currentValue: currentProfile.sleepTime,
      ownerValue: ownerProfile.sleepTime,
      isMatch: (a, b) => a == b,
      formatValue: _formatDayPreference,
    );

    compare<bool>(
      labelKey: "employed",
      currentValue: currentProfile.employed,
      ownerValue: ownerProfile.employed,
      isMatch: (a, b) => a == b,
      formatValue: _formatBooleanPreference,
    );

    final percent = total > 0 ? ((matched / total) * 100).round() : null;
    return _CompatibilityResult(
      percent: percent,
      matches: matches,
      differences: differences,
    );
  }

  String _formatBooleanPreference(bool value) {
    return LanguageAwareStringHelper.getCurrent(
      context,
      value ? "yes" : "no",
    );
  }

  String _formatCookingHabits(bool value) {
    return LanguageAwareStringHelper.getCurrent(
      context,
      value ? "cook" : "dont_cook",
    );
  }

  String _formatPetsPreference(bool value) {
    return LanguageAwareStringHelper.getCurrent(
      context,
      value ? "pets_okay" : "pets_not_okay",
    );
  }


  String _formatDayPreference(String value) {
    switch (value) {
      case "morning":
      case "evening":
      case "night":
        return LanguageAwareStringHelper.getCurrent(context, value);
      default:
        return value;
    }
  }

  String _formatSmokingPreference(String value) {
    const map = {
      "non-smoker": "non_smoker",
      "occasional": "occasional_smoker",
      "regular": "regular_smoker",
    };
    final key = map[value];
    return key == null
        ? value
        : LanguageAwareStringHelper.getCurrent(context, key);
  }

  String _formatAlcoholPreference(String value) {
    const map = {
      "non-drinker": "non_drinker",
      "occasional": "occasional_drinker",
      "regular": "regular_drinker",
    };
    final key = map[value];
    return key == null
        ? value
        : LanguageAwareStringHelper.getCurrent(context, key);
  }

  String _formatCleanlinessLevel(int value) {
    const keys = [
      "very_messy",
      "messy",
      "average",
      "clean",
      "very_clean",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return LanguageAwareStringHelper.getCurrent(context, keys[index]);
  }

  String _formatNoiseLevel(int value) {
    const keys = [
      "very_quiet",
      "quiet",
      "average",
      "loud",
      "very_loud",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return LanguageAwareStringHelper.getCurrent(context, keys[index]);
  }

  String _formatSociabilityLevel(int value) {
    const keys = [
      "very_introverted",
      "introverted",
      "balanced",
      "extroverted",
      "very_extroverted",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return LanguageAwareStringHelper.getCurrent(context, keys[index]);
  }

  String _buildComplaintsButtonLabel() {
    final base = LanguageAwareStringHelper.getCurrent(
      context,
      "view_listing_complaints",
    );

    if (_isLoadingComplaintsCount && _complaintsCount == null) {
      return "$base ...";
    }
    if (_complaintsCount != null) {
      final countText = LanguageAwareStringHelper.getCurrent(
        context,
        "complaints_count_short",
      ).replaceAll("{count}", _complaintsCount!.toString());
      return "$base • $countText";
    }
    return base;
  }

  // Helper method to get the appropriate name based on current language
  String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    required String language,
  }) {
    switch (language) {
      case "uz":
        return nameUz ??
            nameRu ??
            nameEn ??
            LanguageAwareStringHelper.getCurrent(context, "unknown");
      case "ru":
        return nameRu ??
            nameUz ??
            nameEn ??
            LanguageAwareStringHelper.getCurrent(context, "unknown");
      case "en":
        return nameRu ??
            nameUz ??
            nameEn ??
            LanguageAwareStringHelper.getCurrent(context, "unknown");
      default:
        return nameRu ??
            nameUz ??
            nameEn ??
            LanguageAwareStringHelper.getCurrent(context, "unknown");
    }
  }

  void _shareListing() {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;

    currentState.map(
      initial:
          (_) => _showShareError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_listing_not_loaded",
            ),
          ),
      loading:
          (_) => _showShareError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_listing_still_loading",
            ),
          ),
      loaded: (loadedState) => _performShare(loadedState.listingDetail),
      error:
          (errorState) => _showShareError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_loading_listing_details",
            ),
          ),
    );
  }

  void _performShare(ListingDetail listingDetail) {
    final currentLanguage = LanguageState().currentLanguage;

    // Build share text based on current language
    String shareText = _buildShareText(listingDetail, currentLanguage);

    // Share the text
    Share.share(shareText, subject: _getShareSubject(currentLanguage));
  }

  String _buildShareText(ListingDetail listingDetail, String language) {
    final title = _getLocalizedName(
      nameUz: listingDetail.title,
      nameRu: listingDetail.title,
      nameEn: listingDetail.title,
      language: language,
    );

    final description = listingDetail.description ?? "";
    final minPrice = listingDetail.minPrice;
    final maxPrice = listingDetail.maxPrice;

    // Build location info
    String locationInfo = "";
    if (listingDetail.location != null) {
      final locationName = _getLocalizedName(
        nameUz: listingDetail.location!.nameUz,
        nameRu: listingDetail.location!.nameRu,
        nameEn: listingDetail.location!.nameEn,
        language: language,
      );
      locationInfo = "\n📍 $locationName";
    }

    // Build listing type info
    String typeInfo = "";
    if (listingDetail.listingType != null) {
      final typeName = _getLocalizedName(
        nameUz: listingDetail.listingType!.nameUz,
        nameRu: listingDetail.listingType!.nameRu,
        nameEn: listingDetail.listingType!.nameEn,
        language: language,
      );
      typeInfo = "\n🏠 $typeName";
    }

    // Build subway station info
    String subwayInfo = "";
    if (listingDetail.subwayStation != null) {
      final stationName = _getLocalizedName(
        nameUz: listingDetail.subwayStation!.nameUz,
        nameRu: listingDetail.subwayStation!.nameRu,
        nameEn: listingDetail.subwayStation!.nameEn,
        language: language,
      );
      subwayInfo = "\n🚇 $stationName";
    }

    return """$title$typeInfo$locationInfo$subwayInfo

${description.isNotEmpty ? "$description\n" : ""}💰 $minPrice-$maxPrice y.e.

📱 ${LanguageAwareStringHelper.getCurrent(context, "check_out_listing_on_uydosh")}""";
  }

  String _buildPhotoUrl(String photoUrl) {
    logger.d("🔍 [Photo URL] Original photoUrl: $photoUrl");

    // If the URL is already absolute, return it as is
    if (photoUrl.startsWith("http://") || photoUrl.startsWith("https://")) {
      logger.d("🔍 [Photo URL] Already absolute, returning: $photoUrl");
      return photoUrl;
    }

    // If it"s a relative URL, prepend the base URL
    // Since images are stored on EC2 instance, they should be served from the same domain
    // You can configure this base URL in your app config
    final fullUrl = "${EnvironmentUtil.basePath}$photoUrl";
    logger.d("🔍 [Photo URL] Constructed full URL: $fullUrl");
    return fullUrl;
  }

  void _openFullScreenPhotoViewer(int initialIndex) {
    final currentState = context.read<ListingDetailBloc>().state;
    currentState.map(
      initial: (_) => null,
      loading: (_) => null,
      loaded: (loadedState) {
        final photos = loadedState.listingDetail.photos;
        if (photos != null && photos.isNotEmpty) {
          // Use ordered photos for the fullscreen viewer
          final orderedPhotos = _getOrderedPhotos(photos);
          final photoUrls =
              orderedPhotos
                  .map((photo) => photo.photoUrl)
                  .toList()
                  .cast<String>();

          // Adjust the initial index based on the new order
          final orderedInitialIndex = orderedPhotos.indexWhere(
            (photo) => photos.indexOf(photo) == initialIndex,
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => FullScreenPhotoViewer(
                    photoUrls: photoUrls,
                    initialIndex:
                        orderedInitialIndex >= 0 ? orderedInitialIndex : 0,
                    baseUrl: EnvironmentUtil.basePath,
                  ),
            ),
          );
        }
      },
      error: (_) => null,
    );
  }

  // Helper method to get photos in correct order (primary first)
  List<dynamic> _getOrderedPhotos(List<dynamic> photos) {
    final List<dynamic> orderedPhotos = List.from(photos);

    // Find the primary photo and move it to the front
    final primaryPhotoIndex = orderedPhotos.indexWhere(
      (photo) => photo.isPrimary,
    );
    if (primaryPhotoIndex != -1 && primaryPhotoIndex != 0) {
      // Remove primary photo from current position and insert at beginning
      final primaryPhoto = orderedPhotos.removeAt(primaryPhotoIndex);
      orderedPhotos.insert(0, primaryPhoto);
    }

    return orderedPhotos;
  }

  String _getShareSubject(String language) {
    switch (language) {
      case "uz":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "share_subject_uz",
        );
      case "ru":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "share_subject_ru",
        );
      case "en":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "share_subject_en",
        );
      default:
        return LanguageAwareStringHelper.getCurrent(
          context,
          "share_subject_en",
        );
    }
  }

  void _showShareError(String message) {
    ToastTheme.showError(context, message: message);
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthWizardScreen()),
    );
  }

  void _editListing() {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;

    currentState.map(
      initial:
          (_) => _showEditError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_listing_not_loaded",
            ),
          ),
      loading:
          (_) => _showEditError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_listing_still_loading",
            ),
          ),
      loaded: (loadedState) => _navigateToEdit(loadedState.listingDetail),
      error:
          (errorState) => _showEditError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_loading_listing_details",
            ),
          ),
    );
  }

  void _navigateToEdit(ListingDetail listingDetail) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider<SubwayStationsBloc>(
                  create:
                      (context) =>
                          SubwayStationsBloc(getIt<ISubwayStationService>()),
                ),
                BlocProvider<LocationsBloc>(
                  create: (context) => LocationsBloc(getIt<ILocationService>()),
                ),
              ],
              child: EditListingScreen(listingDetail: listingDetail),
            ),
      ),
    );

    // If the listing was updated, refresh the data
    if (result == true) {
      // Mark home screen for refresh since listing was updated
      HomeRefreshState().markForRefresh();

      // Force a complete refresh by clearing the state first
      context.read<ListingDetailBloc>().emit(
        const ListingDetailState.initial(),
      );

      // Then fetch fresh data from server
      context.read<ListingDetailBloc>().add(
        ListingDetailEvent.fetchListingDetail(id: widget.listingId),
      );

      // Force UI rebuild to ensure changes are visible
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showEditError(String message) {
    ToastTheme.showError(context, message: message);
  }

  void _toggleFeatureListing() async {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;

    currentState.map(
      initial:
          (_) => _showFeatureError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_listing_not_loaded",
            ),
          ),
      loading:
          (_) => _showFeatureError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_listing_still_loading",
            ),
          ),
      loaded: (loadedState) => _performToggleFeature(loadedState.listingDetail),
      error:
          (errorState) => _showFeatureError(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_loading_listing_details",
            ),
          ),
    );
  }

  void _performToggleFeature(ListingDetail listingDetail) async {
    try {
      // Show loading state
      setState(() {
        _isToggling = true;
      });

      // Call the toggle feature listing service
      final listingService = getIt<IListingService>();
      final success = await listingService.toggleFeatureListing(
        listingDetail.id,
        ListingUtils.isCurrentlyFeaturedDetail(listingDetail),
      );

      if (success) {
        // Show success message based on current state
        final message =
            ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
                ? LanguageAwareStringHelper.getCurrent(
                  context,
                  "unfeature_listing_success",
                )
                : LanguageAwareStringHelper.getCurrent(
                  context,
                  "feature_listing_success",
                );

        ToastTheme.showSuccess(context, message: message);

        // Update the listing detail with new featured state
        final updatedListingDetail = listingDetail.copyWith(
          featuredAt:
              !ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
                  ? DateTime.now().toIso8601String()
                  : null,
        );

        // Update the bloc state
        context.read<ListingDetailBloc>().add(
          ListingDetailEvent.updateListingDetail(
            listingDetail: updatedListingDetail,
          ),
        );

        // Mark home screen for refresh since listing featured state changed
        HomeRefreshState().markForRefresh();
      } else {
        _showFeatureError(
          LanguageAwareStringHelper.getCurrent(
            context,
            "feature_listing_error",
          ),
        );
      }
    } catch (e) {
      logger.e("Error toggling feature listing: $e");
      _showFeatureError(
        LanguageAwareStringHelper.getCurrent(context, "feature_listing_error"),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  void _showFeatureError(String message) {
    ToastTheme.showError(context, message: message);
  }

  void _toggleFavorite() async {
    // Add haptic feedback
    HapticFeedbackUtils.impact();

    final favoritesState = FavoritesState();
    final isFavorite = favoritesState.isFavorite(widget.listingId);

    // Store current state to determine if we're adding or removing
    final wasFavorite = isFavorite;

    // If we're adding to favorites, trigger animation immediately
    if (!wasFavorite) {
      _pulsateHeart();
    }

    // Call API to toggle favorite
    try {
      final favoriteService = FavoriteService(
        OAuthApiClient(
          configurator: OAuthDioConfigurator(tokenRepo: AuthTokenRepository()),
        ),
      );

      final success = await favoriteService.toggleFavorite(widget.listingId);

      if (success) {
        // Update global state to keep it in sync
        await favoritesState.toggleFavorite(widget.listingId);

        // Show success message
        ToastTheme.showSuccess(
          context,
          message:
              wasFavorite
                  ? LanguageAwareStringHelper.getCurrent(
                    context,
                    "removed_from_favorites",
                  )
                  : LanguageAwareStringHelper.getCurrent(
                    context,
                    "added_to_favorites",
                  ),
        );
      } else {
        // Show error message to user
        if (context.mounted) {
          ToastTheme.showError(
            context,
            message: LanguageAwareStringHelper.getCurrent(
              context,
              "favorite_toggle_network_error",
            ),
          );
        }
      }
    } catch (e) {
      logger.d("❌ Error toggling favorite: $e");
      // Show error message to user
      if (context.mounted) {
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "favorite_toggle_network_error",
          ),
        );
      }
    }
  }

  List<ActionMenuItem> _buildActionMenuItems(
    ListingDetail listingDetail, {
    required bool isAdmin,
  }) {
    final userListingState = UserListingState();
    final isOwner = userListingState.isOwner(listingDetail.user.id);
    final authState = AuthenticationState();
    final isAuthenticated = authState.isAuthenticated;
    final menuEnabled = isAuthenticated;

    List<ActionMenuItem> items = [];

    if (!isAuthenticated) {
      items.add(
        ActionMenuItem(
          value: "sign_in",
          icon: Icons.login,
          textKey: "sign_in",
          onPressed: _navigateToSignIn,
        ),
      );
    }

    // Chat option - only show when authenticated and not owner
    if (!isOwner) {
      items.add(
        ActionMenuItem(
          value: "chat",
          icon: CupertinoIcons.bubble_left_bubble_right,
          textKey: "chat",
          onPressed: () => _startConversation(listingDetail),
          enabled: isAuthenticated,
        ),
      );
    }

    // Profile option - only show when not owner
    if (!isOwner) {
      items.add(
        ActionMenuItem(
          value: "profile",
          icon: Icons.person_outline,
          textKey: "profile",
          onPressed:
              () => _navigateToProfile(
                listingDetail.user.id,
                phoneNumber: listingDetail.user.phone,
              ),
          enabled: menuEnabled,
        ),
      );
    }

    // Favorite option - only show when authenticated and not owner
    if (!isOwner) {
      final favoritesState = FavoritesState();
      final isFavorite = favoritesState.isFavorite(widget.listingId);

      items.add(
        ActionMenuItem(
          value: "favorite",
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          textKey: isFavorite ? "remove_from_favorites" : "add_to_favorites",
          onPressed: _toggleFavorite,
          iconColor: isFavorite ? AppColors.favoriteActive : null,
          enabled: isAuthenticated,
        ),
      );
    }

    // Edit option - only show for listing owner
    if (isOwner) {
      items.add(
        ActionMenuItem(
          value: "edit",
          icon: Icons.edit,
          textKey: "edit",
          onPressed: _editListing,
        ),
      );
    }

    // Deactivate/Activate option - only show for listing owner
    if (isOwner) {
      items.add(
        ActionMenuItem(
          value: "toggle_active",
          icon: listingDetail.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
          textKey: listingDetail.isActive ? "deactivate_listing" : "activate_listing",
          onPressed: () => _showToggleActiveConfirmation(listingDetail.id),
        ),
      );
    }

    // Delete option - show for listing owner or admin
    if (isOwner || isAdmin) {
      items.add(
        ActionMenuItem(
          value: "delete",
          icon: Icons.delete_outline,
          textKey: "delete_listing",
          onPressed: () => _showDeleteConfirmation(listingDetail.id),
          iconColor: Colors.red,
        ),
      );
    }

    // Share option - always show
    items.add(
      ActionMenuItem(
        value: "share",
        icon: Icons.ios_share,
        textKey: "share",
        onPressed: _shareListing,
        enabled: menuEnabled,
      ),
    );

    // Complain option - only show when not owner
    if (!isOwner) {
      items.add(
        ActionMenuItem(
          value: "complain",
          icon: CupertinoIcons.exclamationmark_circle_fill,
          textKey: "complain",
          onPressed: () => _createComplaint(listingDetail),
          enabled: menuEnabled,
          iconColor: Colors.red,
          textColor: Colors.red,
        ),
      );
    }

    return items;
  }

  void _createComplaint(ListingDetail listingDetail) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider<ComplaintBloc>(
              create: (context) => ComplaintBloc(getIt<IComplaintService>()),
              child: CreateComplaintScreen(listingId: listingDetail.id),
            ),
      ),
    );

    // If complaint was created successfully, show a message
    if (result == true) {
      ToastTheme.showSuccess(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "complaint_created_success",
        ),
      );
      _loadComplaintCount(listingDetail.id);
    }
  }

  void _viewListingComplaints(int listingId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider<ComplaintBloc>(
              create: (context) => ComplaintBloc(getIt<IComplaintService>()),
              child: ListingComplaintsScreen(listingId: listingId),
            ),
      ),
    );
  }

  void _startConversation(ListingDetail listingDetail) async {
    try {
      logger.d("🚀 [Frontend] Starting conversation creation process...");

      // Refresh user listing state to ensure we have current user ID
      await UserListingState().refreshUserId();

      // Get current user ID
      final currentUserId = await SessionManager.getUserId();
      logger.d("🔍 [Frontend] Current user ID: $currentUserId");

      if (currentUserId == null) {
        logger.d("❌ [Frontend] No current user ID found");
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_not_authenticated",
          ),
        );
        return;
      }

      // Check if user is trying to message themselves
      if (currentUserId == listingDetail.user.id) {
        logger.d("❌ [Frontend] User trying to message themselves");
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_cannot_message_self",
          ),
        );
        return;
      }

      logger.d("📋 [Frontend] Conversation details:");
      logger.d("   - Listing ID: ${listingDetail.id}");
      logger.d("   - Listing Title: ${listingDetail.title}");
      logger.d("   - Initiator ID (current user): $currentUserId");
      logger.d("   - Participant ID (listing owner): ${listingDetail.user.id}");
      logger.d("   - Participant Email: ${listingDetail.user.email ?? "N/A"}");
      logger.d("   - Participant Phone: ${listingDetail.user.phone ?? "N/A"}");

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: HouseLoadingIndicator()),
      );

      logger.d("🌐 [Frontend] Making API call to create conversation...");

      // Create conversation
      final messagingService = getIt<IMessagingService>();

      try {
        final conversation = await messagingService.createConversation(
          listingId: listingDetail.id,
          participantId: listingDetail.user.id,
        );

        logger.d("✅ [Frontend] Conversation created successfully!");
        logger.d("   - Conversation ID: ${conversation.id}");
        logger.d("   - Created at: ${conversation.createdAt}");
        logger.d("   - Conversation type: ${conversation.runtimeType}");
        logger.d("   - Conversation details: $conversation");

        // Hide loading
        if (mounted) Navigator.of(context).pop();

        // Navigate to chat screen
        if (mounted) {
          logger.d("🧭 [Frontend] Navigating to chat screen...");
          logger.d(
            "🧭 [Frontend] Conversation ID for navigation: ${conversation.id}",
          );
          try {
            final chatScreen = ChatScreen(
              conversationId: conversation.id,
              listingId: widget.listingId,
              otherUserInitials: StringHelper.extractInitials(
                listingDetail.user.email,
              ),
              otherUserName: listingDetail.user.email,
              otherUserId: listingDetail.user.id,
            );
            logger.d("🧭 [Frontend] ChatScreen created successfully");
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => chatScreen));
            logger.d("🧭 [Frontend] Navigation completed successfully");
          } catch (navigationError) {
            logger.d("❌ [Frontend] Navigation error: $navigationError");
            logger.d(
              "❌ [Frontend] Navigation error type: ${navigationError.runtimeType}",
            );
            ToastTheme.showError(
              context,
              message: "Failed to open chat: $navigationError",
            );
          }
        }

        // Show success message
        ToastTheme.showSuccess(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "conversation_created",
          ),
        );
        return; // Exit early on success
      } catch (e) {
        logger.d("⚠️ [Frontend] Conversation creation failed: $e");
        logger.d("⚠️ [Frontend] Error type: ${e.runtimeType}");
        logger.d("⚠️ [Frontend] Error toString: ${e.toString()}");

        // Check if it"s a "conversation already exists" error
        // The error might be wrapped in an Exception, so we need to check the original DioException
        final errorMessage = e.toString();
        logger.d("🔍 [Frontend] Checking error message: $errorMessage");

        // Check for the specific error message that appears in the HTTP response
        // The error message is in the DioException response data, not in the toString()
        final containsExactMessage = errorMessage.contains(
          "Conversation already exists for this listing and participants",
        );
        final containsPartialMessage = errorMessage.contains(
          "Conversation already exists",
        );
        final containsGenericMessage = errorMessage.contains("already exists");

        // Check for DioException with 400 status (which indicates "already exists")
        final isDioException400 =
            errorMessage.contains("DioException") &&
            errorMessage.contains("400");

        logger.d("🔍 [Frontend] Contains exact message: $containsExactMessage");
        logger.d(
          "🔍 [Frontend] Contains partial message: $containsPartialMessage",
        );
        logger.d(
          "🔍 [Frontend] Contains generic message: $containsGenericMessage",
        );
        logger.d("🔍 [Frontend] Is DioException 400: $isDioException400");

        // Consider it an "already exists" error if we can detect it
        bool isAlreadyExistsError =
            containsExactMessage ||
            containsPartialMessage ||
            containsGenericMessage ||
            isDioException400;

        logger.d(
          "🔍 [Frontend] Is already exists error: $isAlreadyExistsError",
        );

        if (isAlreadyExistsError) {
          logger.d(
            "🔄 [Frontend] Conversation already exists, trying to find existing conversation...",
          );

          // Check if user is authenticated before making API calls
          final isAuthenticated = await SessionManager.isAuthenticated();
          if (!isAuthenticated) {
            logger.d(
              "❌ ListingDetailScreen: User not authenticated, cannot check for existing conversation",
            );
            return;
          }

          // Try to find existing conversation
          try {
            final conversations = await messagingService.getConversations(
              page: 1,
              limit: 100,
            );
            final existingConversation = conversations.data.firstWhere(
              (conv) =>
                  conv.listingId == listingDetail.id &&
                  (conv.initiatorId == currentUserId ||
                      conv.participantId == currentUserId),
              orElse: () => throw Exception("Conversation not found in list"),
            );

            logger.d(
              "✅ [Frontend] Found existing conversation: ${existingConversation.id}",
            );

            // Hide loading
            if (mounted) Navigator.of(context).pop();

            // Navigate to existing conversation
            if (mounted) {
              logger.d("🧭 [Frontend] Navigating to existing chat screen...");
              try {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => ChatScreen(
                          conversationId: existingConversation.id,
                          listingId: widget.listingId,
                          otherUserInitials: StringHelper.extractInitials(
                            existingConversation.otherUserName,
                          ),
                          otherUserName: existingConversation.otherUserName,
                          otherUserId:
                              existingConversation.initiatorId == currentUserId
                                  ? existingConversation.participantId
                                  : existingConversation.initiatorId,
                          otherUserAvatar: existingConversation.otherUserAvatar,
                        ),
                  ),
                );
              } catch (navigationError) {
                logger.d("❌ [Frontend] Navigation error: $navigationError");
                ToastTheme.showError(
                  context,
                  message: "Failed to open chat: $navigationError",
                );
              }
            }

            // Show info message
            ToastTheme.showInfo(
              context,
              message: LanguageAwareStringHelper.getCurrent(
                context,
                "opening_existing_conversation",
              ),
            );
            return; // Exit early on success
          } catch (findError) {
            logger.d(
              "❌ [Frontend] Could not find existing conversation: $findError",
            );
            // Fall through to show error
          }
        }

        // Re-throw the original error to be handled by outer catch
        rethrow;
      }
    } catch (e) {
      logger.d("❌ [Frontend] Error creating conversation: $e");
      logger.d("❌ [Frontend] Error type: ${e.runtimeType}");
      logger.d("❌ [Frontend] Error details: $e");

      // Hide loading if still showing
      if (mounted) Navigator.of(context).pop();

      // Show error message with details
      String errorMessage = LanguageAwareStringHelper.getCurrent(
        context,
        "conversation_failed",
      );
      if (e.toString().contains("DioException")) {
        errorMessage = "Network error: ${e.toString()}";
      } else {
        errorMessage = "Error: ${e.toString()}";
      }

      ToastTheme.showError(context, message: errorMessage);
    }
  }

  Future<void> _confirmOpenInYandexMaps(ListingDetail listingDetail) async {
    final shouldOpen = await CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: "open_in_yandex_maps",
      messageKey: "open_in_yandex_maps_confirmation",
      confirmButtonKey: "confirm",
    );

    if (shouldOpen ?? false) {
      await _openInYandexMaps(listingDetail);
    }
  }

  Future<void> _openInYandexMaps(ListingDetail listingDetail) async {
    try {
      // Get coordinates from the listing detail
      final coordinates = _getCoordinatesFromListing(listingDetail);
      if (coordinates == null) {
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_loading_listing_details",
          ),
        );
        return;
      }

      final latitude = coordinates["latitude"]!;
      final longitude = coordinates["longitude"]!;

      // Create Yandex Maps URL
      final yandexMapsUrl =
          "https://yandex.com/maps/?pt=$longitude,$latitude&z=16&l=map";

      final uri = Uri.parse(yandexMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ToastTheme.showError(
          context,
          message: "Could not open Yandex Maps",
        );
      }
    } catch (e) {
      logger.e("Error opening Yandex Maps: $e");
      ToastTheme.showError(
        context,
        message: "Error opening Yandex Maps",
      );
    }
  }

  Map<String, double>? _getCoordinatesFromListing(ListingDetail listingDetail) {
    // Try to get coordinates from metro station first (highest priority)
    if (listingDetail.subwayStation != null) {
      // Try to get coordinates by station ID first
      final coordsById = MetroCache.getMetroStationCoordinatesById(
        listingDetail.subwayStation!.id,
      );
      if (coordsById != null) {
        return coordsById;
      }

      // Fallback to name-based lookup
      final stationName =
          listingDetail.subwayStation?.nameEn ??
          listingDetail.subwayStation?.nameRu ??
          listingDetail.subwayStation?.nameUz;

      if (stationName != null && stationName.isNotEmpty) {
        final coordsByName = MetroCache.getMetroStationCoordinatesByName(
          stationName,
        );
        if (coordsByName != null) {
          return coordsByName;
        }
      }
    }

    // Try to get coordinates from location (lower priority)
    if (listingDetail.location != null) {
      // Try to get coordinates by location ID first
      final coordsById = LocationCache.getLocationCoordinatesById(
        listingDetail.location!.id,
      );
      if (coordsById != null) {
        return coordsById;
      }

      // Fallback to name-based lookup
      final locationName =
          listingDetail.location?.nameEn ??
          listingDetail.location?.nameRu ??
          listingDetail.location?.nameUz;

      if (locationName != null && locationName.isNotEmpty) {
        final coordsByName = LocationCache.getLocationCoordinatesByName(
          locationName,
        );
        if (coordsByName != null) {
          return coordsByName;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingDetailBloc, ListingDetailState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          loading: (_) {},
          loaded: (loadedState) {
            // Check favorite status after listing data is loaded
            _checkFavoriteStatusFromServer();
            _loadComplaintCount(loadedState.listingDetail.id);
            final isOwner = UserListingState().isOwner(
              loadedState.listingDetail.user.id,
            );
            if (!isOwner) {
              _loadCompatibility(loadedState.listingDetail.user.id);
            }
          },
          error: (_) {},
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _getAppBarBackgroundColor(),
          foregroundColor:
              Theme.of(context).appBarTheme.foregroundColor ??
              AppColors.textLight,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              HapticFeedbackUtils.impact();
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            children: [
              // Title on the left
              Expanded(
                child: LanguageAwareStringHelper.getText(
                  "listing_details",
                  context,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
              // Icons on the right side of the title
              BlocSelector<
                ListingDetailBloc,
                ListingDetailState,
                _ListingDetailIconsData
              >(
                selector:
                    (state) => state.map(
                      initial:
                          (_) => _ListingDetailIconsData(
                            isLoading: true,
                            hasError: false,
                            errorMessage: "",
                            listingDetail: null,
                          ),
                      loading:
                          (_) => _ListingDetailIconsData(
                            isLoading: true,
                            hasError: false,
                            errorMessage: "",
                            listingDetail: null,
                          ),
                      loaded:
                          (loadedState) => _ListingDetailIconsData(
                            isLoading: false,
                            hasError: false,
                            errorMessage: "",
                            listingDetail: loadedState.listingDetail,
                          ),
                      error:
                          (errorState) => _ListingDetailIconsData(
                            isLoading: false,
                            hasError: true,
                            errorMessage: errorState.message,
                            listingDetail: null,
                          ),
                    ),
                builder: (context, data) {
                  if (data.isLoading || data.listingDetail == null) {
                    return const SizedBox.shrink(); // No icons while loading
                  }

                  final listingDetail = data.listingDetail!;
                  final isAuthenticated =
                      AuthenticationState().isAuthenticated;
                  if (!isAuthenticated) {
                    return ActionDropdownMenu(
                      items: _buildActionMenuItems(
                        listingDetail,
                        isAdmin: false,
                      ),
                    );
                  }
                  return FutureBuilder<String?>(
                    future: SessionManager.getUserRole(),
                    builder: (context, snapshot) {
                      final isAdmin = snapshot.data == "admin";
                      return ActionDropdownMenu(
                        items: _buildActionMenuItems(
                          listingDetail,
                          isAdmin: isAdmin,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: BlocSelector<
          ListingDetailBloc,
          ListingDetailState,
          _ListingDetailBodyData
        >(
          selector:
              (state) => state.map(
                initial:
                    (_) => _ListingDetailBodyData(
                      isLoading: true,
                      hasError: false,
                      errorMessage: "",
                      listingDetail: null,
                    ),
                loading:
                    (_) => _ListingDetailBodyData(
                      isLoading: true,
                      hasError: false,
                      errorMessage: "",
                      listingDetail: null,
                    ),
                loaded:
                    (loadedState) => _ListingDetailBodyData(
                      isLoading: false,
                      hasError: false,
                      errorMessage: "",
                      listingDetail: loadedState.listingDetail,
                    ),
                error:
                    (errorState) => _ListingDetailBodyData(
                      isLoading: false,
                      hasError: true,
                      errorMessage: errorState.message,
                      listingDetail: null,
                    ),
              ),
          builder: (context, data) {
            if (data.isLoading) {
              return data.listingDetail == null
                  ? _buildInitialState()
                  : _buildLoadingState();
            }
            if (data.hasError) {
              return _buildErrorState(data.errorMessage);
            }
            return _buildLoadedState(data.listingDetail!);
          },
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return CenteredHouseLoadingIndicator(
      text: LanguageAwareStringHelper.getCurrent(
        context,
        "loading_listing_details",
      ),
    );
  }

  Widget _buildLoadingState() {
    return CenteredHouseLoadingIndicator(
      text: LanguageAwareStringHelper.getCurrent(
        context,
        "loading_listing_details",
      ),
      textStyle: TextStyle(
        color: _getLoadingTextColor(),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLoadedState(ListingDetail listingDetail) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final currentLanguage = LanguageState().currentLanguage;

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section - moved to very top
              if (listingDetail.photos != null &&
                  listingDetail.photos!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photos Carousel
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount:
                                _getOrderedPhotos(listingDetail.photos!).length,
                            onPageChanged: (index) {
                              // Optional: Add any page change logic here
                            },
                            itemBuilder: (context, index) {
                              final orderedPhotos = _getOrderedPhotos(
                                listingDetail.photos!,
                              );
                              final photo = orderedPhotos[index];
                              logger.d(
                                "🖼️ [Photo] Photo $index: id=${photo.id}, url=${photo.photoUrl}, isPrimary=${photo.isPrimary}",
                              );
                              return GestureDetector(
                                onTap: () {
                                  // Find the original index in the original photos list for the fullscreen viewer
                                  final originalIndex = listingDetail.photos!
                                      .indexOf(photo);
                                  _openFullScreenPhotoViewer(originalIndex);
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          // Photo with caching
                                          CachedNetworkImage(
                                            imageUrl: _buildPhotoUrl(
                                              photo.photoUrl,
                                            ),
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            memCacheWidth: 400,
                                            memCacheHeight: 400,
                                            fadeInDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            fadeInCurve: Curves.easeOut,
                                            placeholder:
                                                (context, url) => Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey[600],
                                                    size: 48,
                                                  ),
                                                ),
                                          ),
                                          // Fullscreen indicator
                                          Positioned(
                                            bottom: 12,
                                            right: 12,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.6,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.fullscreen,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          // Photo counter
                                          if (_getOrderedPhotos(
                                                listingDetail.photos!,
                                              ).length >
                                              1)
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "${index + 1}/${_getOrderedPhotos(listingDetail.photos!).length}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Page indicators
                        if (_getOrderedPhotos(listingDetail.photos!).length >
                            1) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count:
                                  _getOrderedPhotos(
                                    listingDetail.photos!,
                                  ).length,
                              effect: WormEffect(
                                dotColor: Colors.grey[300]!,
                                activeDotColor: _getIconColor(),
                                dotHeight: 8,
                                dotWidth: 8,
                                spacing: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Unified Listing Detail Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Listing Type and Price
                      Row(
                        children: [
                          // Listing Type Tag
                          if (listingDetail.listingType != null) ...[
                            ListingTypeBadge(
                              listingTypeCode: listingDetail.listingType.code,
                              fontSize: 14,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          // Gender Badge
                          if (listingDetail.gender != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    ThemeState().isLightTheme
                                        ? null
                                        : _getGenderColor(
                                          listingDetail.gender!,
                                        ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getGenderColor(listingDetail.gender!),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ThemeIconFactory.detail(
                                    icon: _getGenderIcon(listingDetail.gender!),
                                    color: _getGenderColor(listingDetail.gender!),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _getGenderText(
                                      listingDetail.gender!,
                                      context,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getGenderColor(
                                        listingDetail.gender!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          // Price Range Tag
                          PriceRangeBadge(
                            minPrice: listingDetail.minPrice,
                            maxPrice: listingDetail.maxPrice,
                            isActive: listingDetail.isActive,
                            fontSize: 13,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            currencySymbol: "y.e.",
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        listingDetail.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Description
                      if (listingDetail.description != null &&
                          listingDetail.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          listingDetail.description!,
                          style: TextStyle(
                            fontSize: 16,
                            color: _getDescriptionTextColor(),
                          ),
                        ),
                      ],

                      // Private Room Information
                      if (listingDetail.privateRoom != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ThemeIconFactory.detail(
                              icon: Icons.lock_outline,
                              color: _getPrivateRoomIconColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "private_room",
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _getLocationTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Location Information
                      if (listingDetail.location != null ||
                          listingDetail.subwayStation != null) ...[
                        if (listingDetail.location != null) ...[
                          ListenableBuilder(
                            listenable: LanguageState(),
                            builder: (context, child) {
                              return Row(
                                children: [
                                  ThemeIconFactory.detail(
                                    icon: Icons.location_on,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getLocalizedName(
                                        nameUz: listingDetail.location!.nameUz,
                                        nameRu: listingDetail.location!.nameRu,
                                        nameEn: listingDetail.location!.nameEn,
                                        language: currentLanguage,
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _getLocationTextColor(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (listingDetail.subwayStation != null)
                            const SizedBox(height: 8)
                          else
                            const SizedBox(height: 20),
                        ],
                        if (listingDetail.subwayStation != null) ...[
                          ListenableBuilder(
                            listenable: LanguageState(),
                            builder: (context, child) {
                              return _buildSubwayStationDisplay(
                                listingDetail.subwayStation!,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

                      // Amenities Section
                      if (listingDetail.amenities != null &&
                          listingDetail.amenities!.isNotEmpty) ...[

                        // Amenities Grid
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              listingDetail.amenities!
                                  .map(
                                    (amenity) => _buildAmenityChip(
                                      amenity,
                                      currentLanguage,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Additional Information
                      // Move-in Date
                      if (listingDetail.moveInDate != null &&
                          listingDetail.moveInDate!.isNotEmpty) ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                child: ThemeIconFactory.detail(
                                  icon: CupertinoIcons.square_arrow_right,
                                  color: _getDateIconColor(),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${LanguageAwareStringHelper.getCurrent(context, "move_in_date_label")} ${_formatMoveInDate(context, listingDetail.moveInDate!)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _getDateTextColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Publishing Date
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: ThemeIconFactory.detail(
                                icon: Icons.schedule,
                                color: _getDateIconColor(),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${LanguageAwareStringHelper.getCurrent(context, "publication_date")} ${AppDateUtils.formatDateWithShortMonth(
                                context,
                                DateTime.parse(listingDetail.createdAt),
                              )}",
                              style: TextStyle(
                                fontSize: 15,
                                color: _getDateTextColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Map Section - moved to bottom
              if (listingDetail.location != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map Header
                        Row(
                          children: [
                            ThemeIconFactory.detail(
                              icon: CupertinoIcons.placemark_fill,
                              color: _getIconColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "location_on_map",
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getDescriptionTextColor(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Map Widget
                        YandexMapWidget(
                          apiKey: AppConfig.yandexMapsApiKey,
                          height: 250,
                          listingDetail: listingDetail,
                        ),
                        const SizedBox(height: 16),
                        // Open in Yandex Maps Button
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              HapticFeedbackUtils.impact();
                              _confirmOpenInYandexMaps(listingDetail);
                            },
                            icon: Icon(
                              Icons.link,
                              size: 18,
                              color: _getYandexButtonColor(),
                            ),
                            label: Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "open_in_yandex_maps",
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _getYandexButtonColor(),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _getYandexButtonColor(),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (!UserListingState().isOwner(listingDetail.user.id))
                ListingDetailCompatibilitySection(
                  listingDetail: listingDetail,
                  scrollController: _scrollController,
                  sectionKey: _compatibilitySectionKey,
                  compatibilityPercent: _compatibilityPercent,
                  isLoadingCompatibility: _isLoadingCompatibility,
                  compatibilityError: _compatibilityError,
                  matches: _compatibilityMatches
                      .map(
                        (m) => CompatibilityMatch(
                          labelKey: m.labelKey,
                          label: m.label,
                          value: m.value,
                        ),
                      )
                      .toList(),
                  differences: _compatibilityDifferences
                      .map(
                        (d) => CompatibilityDifference(
                          labelKey: d.labelKey,
                          label: d.label,
                          currentText: d.currentText,
                          ownerText: d.ownerText,
                        ),
                      )
                      .toList(),
                ),
              if (_complaintsCount != null && _complaintsCount! > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _viewListingComplaints(listingDetail.id),
                        icon: FadeTransition(
                          opacity: _warningBlinkAnimation,
                          child: const Icon(Icons.report_outlined),
                        ),
                        label: FadeTransition(
                          opacity: _warningBlinkAnimation,
                          child: Text(
                            _buildComplaintsButtonLabel(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // WiFi error icon with gradient colors
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.warning, AppColors.favoriteActive],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ThemeIconFactory.display(
              icon: Icons.wifi_off_rounded,
              size: 49,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_loading_listing_details",
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_internet_connection",
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.textLight70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GhostButtonFactory.iconText(
            onPressed: () {
              context.read<ListingDetailBloc>().add(
                ListingDetailEvent.fetchListingDetail(id: widget.listingId),
              );
            },
            icon: Icons.refresh_rounded,
            text: LanguageAwareStringHelper.getCurrent(context, "retry"),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );
  }

  Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  // Build subway station display with transfer station support
  Widget _buildSubwayStationDisplay(SubwayStationDetail station) {
    final transferInfo = MetroCache.getTransferStationInfo(station.id);

    if (transferInfo != null) {
      // This is a transfer station - show both stations with <-> icon
      final connectedStation = SubwayStationDetail(
        id: transferInfo["connectedStationId"],
        nameUz: transferInfo["connectedStationName"],
        nameRu: transferInfo["connectedStationNameRu"],
        nameEn: transferInfo["connectedStationNameEn"],
        line: transferInfo["connectedStationLine"],
      );

      return Row(
        children: [
          Icon(Icons.train, color: _getLineColor(station.line), size: 20),
          const SizedBox(width: 4),
          Text(
            _getLocalizedName(
              nameUz: station.nameUz,
              nameRu: station.nameRu,
              nameEn: station.nameEn,
              language: LanguageState().currentLanguage,
            ),
            style: TextStyle(fontSize: 15, color: _getLocationTextColor()),
          ),
          const SizedBox(width: 4),
          Icon(Icons.swap_horiz, color: _getLocationTextColor(), size: 16),
          const SizedBox(width: 4),
          Icon(Icons.train, color: _getLineColor(connectedStation.line), size: 20),
          const SizedBox(width: 4),
          Text(
            _getLocalizedName(
              nameUz: connectedStation.nameUz,
              nameRu: connectedStation.nameRu,
              nameEn: connectedStation.nameEn,
              language: LanguageState().currentLanguage,
            ),
            style: TextStyle(fontSize: 15, color: _getLocationTextColor()),
          ),
        ],
      );
    } else {
      // Regular station - show normally
      return Row(
        children: [
          Icon(Icons.train, color: _getLineColor(station.line), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getLocalizedName(
                nameUz: station.nameUz,
                nameRu: station.nameRu,
                nameEn: station.nameEn,
                language: LanguageState().currentLanguage,
              ),
              style: TextStyle(fontSize: 15, color: _getLocationTextColor()),
            ),
          ),
        ],
      );
    }
  }

  Color _getGenderColor(int gender) {
    switch (gender) {
      case 1: // Male
        return AppColors.genderMale;
      case 2: // Female
        return AppColors.genderFemale;
      default:
        return AppColors.textGrey;
    }
  }

  String _getGenderText(int gender, BuildContext context) {
    switch (gender) {
      case 1:
        return LanguageAwareStringHelper.getCurrent(context, "male");
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "female");
      default:
        return LanguageAwareStringHelper.getCurrent(context, "other");
    }
  }

  IconData _getGenderIcon(int gender) {
    switch (gender) {
      case 1: // Male
        return Icons.male;
      case 2: // Female
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  void _navigateToProfile(int userId, {String? phoneNumber}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create:
                  (context) =>
                      ListingOwnerProfileBloc(getIt<IUserProfileService>()),
              child: ListingOwnerProfileScreen(
                userId: userId,
                phoneNumber: phoneNumber,
              ),
            ),
      ),
    );
  }

  Widget _buildAmenityChip(Amenity amenity, String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _getAmenityChipBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getAmenityChipBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIconFactory.detail(
            icon: _getAmenityIcon(amenity),
            size: 18,
            color: _getAmenityIconColor(),
          ),
          const SizedBox(width: 6),
          Text(
            _getAmenityLocalizedName(amenity, language),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _getAmenityIconColor(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(Amenity amenity) {
    if (amenity.code != null && amenity.code!.isNotEmpty) {
      return AmenityIconHelper.getIcon(amenity.code!);
    }
    return Icons.home; // Default icon
  }

  String _getAmenityLocalizedName(Amenity amenity, String language) {
    switch (language) {
      case "ru":
        return amenity.nameRu;
      case "uz":
        return amenity.nameUz;
      case "en":
      default:
        return amenity.nameEn;
    }
  }

  // Theme-dependent color methods for amenities
  Color _getAmenityIconColor() {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme - use white for icons
      return AppColors.textLight;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use black for icons and text
      return Colors.black;
    } else {
      // Default theme - use primary icon color
      return AppColors.iconPrimary; // This is Color(0xFF6B46C1)
    }
  }

  Color _getAmenityChipBackgroundColor() {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme - use semi-transparent white background
      return AppColors.textLight.withValues(alpha: 0.1);
    } else if (ThemeState().isLightTheme) {
      // Light theme - use white background
      return Colors.white;
    } else {
      // Default theme - use semi-transparent primary background
      return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  Color _getAmenityChipBorderColor() {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme - use white border
      return AppColors.textLight;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use black border
      return Colors.black;
    } else {
      // Default theme - use primary border
      return AppColors.primary;
    }
  }

  // Theme-dependent color method for description text
  Color _getDescriptionTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textGrey; // Default grey for light theme
    }
  }

  // Theme-dependent color method for location and metro text
  Color _getLocationTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87; // Default dark text for light theme
    }
  }

  // Theme-dependent color method for date text
  Color _getDateTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87; // Default dark text for light theme
    }
  }

  // Theme-dependent color method for date icon
  Color _getDateIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textGrey600; // Default grey for light theme
    }
  }

  // Move-in date helper method
  String _formatMoveInDate(BuildContext context, String moveInDate) {
    try {
      final date = DateTime.parse(moveInDate);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return LanguageAwareStringHelper.getCurrent(context, "today");
      } else if (difference == 1) {
        return LanguageAwareStringHelper.getCurrent(context, "tomorrow");
      } else if (difference > 0 && difference <= 7) {
        return AppStrings.getWithParams(
          "in_days",
          LanguageState().currentLanguage,
          params: {"days": difference.toString()},
        );
      } else {
        // Format as "MMM dd, yyyy" for dates more than a week away
        final monthKeys = [
          "january",
          "february",
          "march",
          "april",
          "may",
          "june",
          "july",
          "august",
          "september",
          "october",
          "november",
          "december",
        ];
        final localizedMonth = LanguageAwareStringHelper.getCurrent(
          context,
          monthKeys[date.month - 1],
        );
        return "${localizedMonth.substring(0, 3)} ${date.day}, ${date.year}";
      }
    } catch (e) {
      // If parsing fails, return the raw string
      return moveInDate;
    }
  }

  // Theme-dependent color method for app bar background
  Color _getAppBarBackgroundColor() {
    // Use the theme"s AppBar background color instead of hardcoded colors
    return Theme.of(context).appBarTheme.backgroundColor ?? AppColors.primary;
  }

  // Theme-dependent color method for primary buttons
  Color _getPrimaryButtonColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.buttonPrimary; // Blue for blue theme
    } else {
      return AppColors.primary; // Primary for non-blue theme
    }
  }

  // Theme-dependent color method for loading indicator
  Color _getLoadingIndicatorColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.buttonPrimary; // Blue for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else {
      return AppColors.primary; // Primary for non-blue theme
    }
  }

  // Theme-dependent color method for loading text
  Color _getLoadingTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White text for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black text for light theme
    } else {
      return AppColors.primary; // Primary text for non-blue theme
    }
  }

  // Theme-dependent color method for icons
  Color _getIconColor() {
    if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else if (ThemeState().isBlueTheme) {
      return Colors.white; // White for blue theme
    } else {
      return AppColors.primary; // Primary for non-blue theme
    }
  }

  // Theme-dependent color method for private room icon
  Color _getPrivateRoomIconColor() {
    if (ThemeState().isLightTheme) {
      return AppColors.primary; // Primary for light theme
    } else if (ThemeState().isBlueTheme) {
      return Colors.white; // White for blue theme
    } else {
      return AppColors.primary; // Primary for non-blue theme
    }
  }

  // Theme-dependent color method for button foreground
  Color _getButtonForegroundColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.buttonPrimary; // Blue for blue theme
    } else {
      return AppColors.primary; // Primary for non-blue theme
    }
  }

  // Theme-dependent color method for Yandex Maps button
  Color _getYandexButtonColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else {
      return AppColors.textDark;
    }
  }

  // Helper method to get the current listing"s user ID
  int? _getCurrentListingUserId() {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;
    return currentState.map(
      initial: (_) => null,
      loading: (_) => null,
      loaded: (loadedState) => loadedState.listingDetail.userId,
      error: (_) => null,
    );
  }

  // Show toggle active confirmation dialog
  void _showToggleActiveConfirmation(int listingId) {
    final currentState = context.read<ListingDetailBloc>().state;
    final isCurrentlyActive = currentState.map(
      initial: (_) => false,
      loading: (_) => false,
      loaded: (loadedState) => loadedState.listingDetail.isActive,
      error: (_) => false,
    );

    final titleKey = isCurrentlyActive ? "deactivate_listing" : "activate_listing";
    final messageKey = isCurrentlyActive ? "deactivate_listing_confirmation" : "activate_listing_confirmation";

    CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: titleKey,
      messageKey: messageKey,
      confirmButtonKey: isCurrentlyActive ? "deactivate" : "activate",
      onConfirm: () => _toggleListingActive(listingId),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(int listingId) {
    CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "delete_listing",
      messageKey: "delete_listing_confirmation",
      onConfirm: () => _deleteListing(listingId),
    );
  }

  // Delete listing method
  Future<void> _deleteListing(int listingId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Get the listing service from dependency injection
      final listingService = getIt<IListingService>();

      // Call the delete API
      final success = await listingService.deleteListing(listingId);

      if (success) {
        // Show success message
        ToastTheme.showSuccess(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "delete_listing_success",
          ),
        );

        // Mark home screen for refresh to reflect the deletion
        HomeRefreshState().markForRefresh();

        // Navigate back to home screen
        Navigator.of(context).pop();
      } else {
        throw Exception("Delete operation failed");
      }
    } catch (e) {
      logger.d("❌ Error deleting listing: $e");

      // Show error message
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "delete_listing_error",
        ),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
