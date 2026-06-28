import "dart:async" show unawaited;
import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
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
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/common/notify_search_alert_app_bar_button.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/feed_scroll_scope.dart";
import "package:uy_dosh/base/utils/platform_device.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/applied_search_filters_bar.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";
import "package:uy_dosh/presentation/widgets/listing_tile_skeleton.dart";
import "package:uy_dosh/presentation/screens/home/home_feed_entries.dart";
import "package:uy_dosh/presentation/screens/home/home_feed_placeholder_widgets.dart";
import "package:uy_dosh/presentation/screens/search/search_results_map_screen.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/tutorial/alert_bell_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/tutorial_overlay_manager.dart";

part "home_search_results_shell.dart";
part "home_map_view_state.dart";

/// Matches empty-search Ghost + Primary CTAs (30px bell stack + 14px vertical padding).
const double _kEmptySearchCtaButtonHeight = 58;

// Data class for BlocSelector to reduce unnecessary rebuilds
@immutable
class _HomeScreenData {
  const _HomeScreenData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listings,
    required this.hasMore,
    required this.total,
  });
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Listing> listings;
  final bool hasMore;
  final int? total;

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
        other.hasMore == hasMore &&
        other.total == total;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      Object.hash(hasError, errorMessage),
      _listingsIdsHash(listings),
      Object.hash(hasMore, total),
    );
  }
}

@immutable
class _ResolvedSearchFilters {
  const _ResolvedSearchFilters({
    required this.listingTypeId,
    required this.listingTypeIds,
    required this.locationId,
    required this.subwayStationId,
    required this.subwayLineId,
    required this.gender,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    this.subwayStationIds,
  });

  final int? listingTypeId;
  final List<int>? listingTypeIds;
  final int? locationId;
  final int? subwayStationId;
  final List<int>? subwayStationIds;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;
}

enum _SearchResultsView { list, map }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.listingTypeId,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds,
    this.subwayLineId,
    this.gender,
    this.minPrice,
    this.maxPrice,
    this.privateRoom,
    this.withPhoto,
    this.isSearchMode = false,
    this.useExplicitFiltersOnly = false,
    this.isHomeTabActive = true,
    this.showMapInitially = false,
  });
  final int? listingTypeId;
  final int? locationId;
  final int? subwayStationId;
  final List<int>? subwayStationIds;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;
  final bool isSearchMode;
  final bool useExplicitFiltersOnly;
  final bool showMapInitially;

  /// True when this HomeScreen is the active tab in main navigation (index 0).
  /// Used to ensure tutorials run only when user is on home screen.
  final bool isHomeTabActive;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  List<Listing>? _cachedFeedListingsRef;
  List<HomeFeedEntry>? _cachedFeedEntries;
  bool _isCreatingSearchAlert = false;
  bool _searchCountReady = false;
  bool _searchResultsReady = false;
  bool _searchRefreshInFlight = false;
  final _HomeMapViewState _mapViewState = _HomeMapViewState();
  // Celebration for the header bell is driven by `ActiveSearchAlertsState()`
  // so it also triggers when alerts are created from other screens.
  bool _inlineSearchActive = false;
  bool _inlineSearchClosing = false;
  bool _inlineSearchSpacerExpanded = false;
  int _inlineSearchExitRefreshToken = 0;
  SearchFiltersSnapshot? _lastDispatchedSearchFilters;
  // Window during which a SearchFiltersState change after a fresh login is
  // treated as the post-hydrate update and may auto-activate the inline
  // ribbon. Outside this window we ignore filter changes so we don't
  // surprise the user with the ribbon popping up during normal browsing
  // (e.g. when another part of the app touches a filter setter).
  DateTime? _postLoginActivationDeadline;

  /// True while reloading per-user ribbon-dismiss prefs after a login flip.
  /// Blocks [_onSearchFiltersStateChanged] from auto-opening the ribbon until
  /// the scoped dismiss flag is hydrated (logout clears session before prefs).
  bool _postLoginRibbonDismissHydrating = false;

  /// True while [_rebootstrapAfterLogin] is running; blocks post-hydrate ribbon
  /// auto-activation until dismiss prefs and feed bootstrap have finished.
  bool _postLoginRebootstrapInFlight = false;
  // Tracks the previous value of [AuthenticationState.isAuthenticated] so
  // we react only to real transitions. Without this guard, the Firebase
  // auth listener firing during logout (local session is briefly still
  // valid, so combined-auth stays "true") would look like another login
  // and trigger a stray hydrate that re-applies the previous user's
  // filters mid-logout.
  bool _wasAuthenticated = false;
  static const double _inlineSearchRibbonHeight = 56.0;
  static const double _inlineSearchRibbonToListGap = 8.0;
  static const double _kFabGap = 12.0;
  static const double _kFabSize = SearchFloatingActionButton.fabSize;
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
    if (widget.showMapInitially) {
      unawaited(_activateInitialMapIfRequested());
    }

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

    if (!widget.isSearchMode) {
      unawaited(_bootstrapHomeSearchFilters());
    }

    // Initialize search filters with current parameters if in search mode
    if (widget.isSearchMode) {
      // Trigger search when screen loads in search mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(() async {
          if (!widget.useExplicitFiltersOnly) {
            await _initializeSearchFilters();
          }
          if (!mounted) return;
          _performSearch();
        }());
      });
    }

    // Listen to home refresh state for immediate refresh commands
    HomeRefreshState().addListener(_onHomeRefreshStateChanged);

    // After logout, inline ribbon + filtered bloc path must drop even if this
    // State object outlives the session-clear hook ordering. After login, we
    // also need to re-run the auth-dependent bootstrap so the user's
    // server-side filters and inline ribbon are restored on the same mounted
    // home screen (otherwise the filter chips stay hidden until app restart).
    _wasAuthenticated = AuthenticationState().isAuthenticated;
    AuthenticationState().addListener(_onAuthenticationChanged);

    // Watch the global SearchFiltersState so the chips bar reflects external
    // changes (e.g. backend hydrate triggered by MainNavigation's own auth
    // listener) and so we can auto-activate the ribbon if the freshly
    // hydrated filters indicate a previously-applied search. Without this
    // listener the home rebuilds only when our own [_rebootstrapAfterLogin]
    // path setStates — which may race with hydrate completing through a
    // different code path and leave the home unfiltered after login.
    _searchFiltersState.addListener(_onSearchFiltersStateChanged);

    // Re-check tutorial when onboarding toggle changes (e.g. user turns it ON in settings)
    OnboardingState().addListener(_onOnboardingStateChanged);

    getIt<AppAnalyticsService>().logScreenView(screenName: "home");

    // Show search button tutorial on first visit to browse screen (with delay)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _maybeShowSearchTutorial);
    });
  }

  Future<void> _bootstrapHomeSearchFilters() async {
    // Share the same cold-start bootstrap as main.dart so initialize/hydrate
    // cannot race and reload filters after the user dismissed the ribbon.
    await _searchFiltersState.bootstrapColdStart();

    final authenticated = await SessionManager.isAuthenticated();
    await HomeInlineSearchState().hydrateRibbonDismissedFromPrefs(
      awaitUserScope: authenticated,
    );
    if (HomeInlineSearchState().ribbonDismissedByUser) {
      _searchFiltersState.markPersistedFiltersDismissed();
    }
    await _searchFiltersState.initialize();
    if (!mounted) return;
    if (_shouldSkipInlineSearchBootstrap()) {
      _ensureUnfilteredBrowseFeed();
      return;
    }
    if (await SessionManager.isAuthenticated()) {
      await _searchFiltersState.hydrateFromBackendForCurrentUser();
      unawaited(PriceDisplaySettingsState().hydrateFromBackendForCurrentUser());
    }
    if (!mounted) return;
    if (_shouldSkipInlineSearchBootstrap()) {
      _ensureUnfilteredBrowseFeed();
      return;
    }
    if (!await SessionManager.isAuthenticated()) {
      if (_shouldSkipInlineSearchBootstrap()) {
        await _resetAnonymousHomeSearchState();
        return;
      }
      final restored = await _restoreInlineSearchModeFromPrefs();
      if (restored) return;
      await _resetAnonymousHomeSearchState();
      return;
    }
    final restored = await _restoreInlineSearchModeFromPrefs();
    if (restored) return;
    if (!mounted) return;
    if (widget.isSearchMode) return;
    if (_inlineSearchActive || _inlineSearchClosing) return;
    // Profile defaults (listing type + gender) are seeded when the user opens
    // the search sheet — do not auto-activate the ribbon or filter the feed.
    if (_hasUserAppliedSearchCriteria()) {
      _activateInlineSearch(persistActiveFlag: true);
    } else {
      _ensureUnfilteredBrowseFeed();
    }
  }

  /// Inline filter ribbon for guests is only restored when they previously
  /// committed a search ([HomeInlineSearchState.activePrefsKey]); otherwise
  /// stale logged-in prefs are cleared.
  Future<void> _resetAnonymousHomeSearchState() async {
    _lastDispatchedSearchFilters = null;
    await _searchFiltersState.clearAllFilters(persistRemote: false);
    if (mounted) {
      setState(() {
        _inlineSearchActive = false;
        _inlineSearchClosing = false;
        _inlineSearchSpacerExpanded = false;
        _mapViewState.resetToList();
      });
    }
    HomeInlineSearchState().setMapViewActive(false);
    HomeInlineSearchState().setActive(false);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(HomeInlineSearchState.activePrefsKey, false);
    } catch (_) {}
    _ensureUnfilteredBrowseFeed();
  }

  /// Auto-restore / bootstrap only — not for explicit search-sheet commits.
  bool _canAutoRestoreInlineSearchRibbon() {
    return AuthenticationState().isAuthenticated;
  }

  bool _shouldSkipInlineSearchBootstrap() {
    return HomeInlineSearchState().ribbonDismissedByUser;
  }

  Future<void> _activateInitialMapIfRequested() async {
    final snapshot = _currentListingsSnapshot();
    final changed = await _mapViewState.activateInitialMapIfRequested(
      showMapInitially: widget.showMapInitially,
      initialMapListings: snapshot.listings,
      initialMapTotal: snapshot.total,
    );
    if (!mounted || !changed) return;
    HomeInlineSearchState().setMapViewActive(true);
    setState(() {});
  }

  ({List<Listing> listings, int? total}) _currentListingsSnapshot() {
    return context.read<ListingsBloc>().state.maybeMap(
      loaded: (state) => (listings: state.listings, total: state.total),
      orElse: () => (listings: const <Listing>[], total: null),
    );
  }

  void _openMapViewWithSnapshot(SearchBottomSheetResult result) {
    final snapshot = _currentListingsSnapshot();
    _mapViewState.openMap(
      result,
      initialMapListings: snapshot.listings,
      initialMapTotal: snapshot.total,
    );
    HomeInlineSearchState().setMapViewActive(true);
  }

  Future<bool> openCurrentMapViewFromExternalRequest() async {
    _searchFiltersState.clearPersistedFiltersDismissed();
    unawaited(HomeInlineSearchState().setRibbonDismissedByUser(false));
    setState(() {
      _openMapViewWithSnapshot(_currentSearchResultForViewToggle());
      _inlineSearchActive = true;
      _inlineSearchClosing = false;
      _inlineSearchSpacerExpanded = true;
    });
    HomeInlineSearchState().setActive(true);
    return true;
  }

  /// Re-runs the auth-dependent portion of the bootstrap after the user signs
  /// in while the home screen is already mounted. Without this the inline
  /// filter chips ribbon (and any backend-stored filters) stays hidden because
  /// the original [_bootstrapHomeSearchFilters] short-circuited when the user
  /// was still unauthenticated at app launch.
  ///
  /// Note: the session-clear hook in `main.dart` wipes the local
  /// `home_inline_search_active` prefs flag on logout, so we cannot rely on
  /// it across a logout/login cycle. After hydration we re-activate the
  /// ribbon when the freshly-loaded backend filters indicate the user had a
  /// search applied (any non-default location / metro / price / extras).
  Future<void> _rebootstrapAfterLogin() async {
    if (!mounted) return;
    if (!await SessionManager.isAuthenticated()) return;
    _postLoginRebootstrapInFlight = true;
    try {
      await HomeInlineSearchState().hydrateRibbonDismissedFromPrefs(
        awaitUserScope: true,
      );
      if (HomeInlineSearchState().ribbonDismissedByUser) {
        _searchFiltersState.markPersistedFiltersDismissed();
      }
      if (!mounted) return;
      if (_shouldSkipInlineSearchBootstrap()) {
        _postLoginActivationDeadline = null;
        _ensureUnfilteredBrowseFeed();
        return;
      }
      await _searchFiltersState.hydrateFromBackendForCurrentUser();
      unawaited(PriceDisplaySettingsState().hydrateFromBackendForCurrentUser());
      if (!mounted) return;
      if (_shouldSkipInlineSearchBootstrap()) {
        _postLoginActivationDeadline = null;
        _ensureUnfilteredBrowseFeed();
        return;
      }
      final restored = await _restoreInlineSearchModeFromPrefs();
      if (restored) {
        _postLoginActivationDeadline = null;
        return;
      }
      if (!mounted) return;
      if (_shouldSkipInlineSearchBootstrap()) {
        _postLoginActivationDeadline = null;
        _ensureUnfilteredBrowseFeed();
        return;
      }
      if (widget.isSearchMode) return;
      if (_inlineSearchActive || _inlineSearchClosing) return;
      if (_hasUserAppliedSearchCriteria()) {
        _postLoginActivationDeadline = null;
        _activateInlineSearch(persistActiveFlag: true);
      } else {
        _postLoginActivationDeadline = null;
        _ensureUnfilteredBrowseFeed();
      }
    } finally {
      _postLoginRebootstrapInFlight = false;
    }
  }

  /// True when filters carry user intent beyond the listing-type / gender
  /// defaults (which are auto-derived from profile and don't represent an
  /// active "search").
  bool _hasUserAppliedSearchCriteria() {
    return _searchFiltersState.selectedLocationIndex > 0 ||
        _searchFiltersState.selectedStationId > 0 ||
        _searchFiltersState.selectedStationIdsList.isNotEmpty ||
        _searchFiltersState.minPrice != 0.0 ||
        _searchFiltersState.maxPrice != 1000.0 ||
        _searchFiltersState.privateRoom ||
        _searchFiltersState.withPhoto;
  }

  /// Returns true when the persisted prefs flag was set and we activated the
  /// ribbon; false otherwise. Works for signed-in users and guests who
  /// committed a search in this install (logout clears the pref).
  Future<bool> _restoreInlineSearchModeFromPrefs() async {
    if (widget.isSearchMode) return false;
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(HomeInlineSearchState.activePrefsKey) ?? false;
    if (!mounted) return false;
    if (!active) return false;
    if (HomeInlineSearchState().ribbonDismissedByUser) {
      try {
        await prefs.setBool(HomeInlineSearchState.activePrefsKey, false);
      } catch (_) {}
      return false;
    }
    if (await SessionManager.isAuthenticated()) {
      _activateInlineSearch(persistActiveFlag: false);
    } else {
      _showGuestInlineSearchRibbon();
    }
    return true;
  }

  /// Re-shows the feed ribbon after navigation when the global inline-search
  /// flag is still set but local [State] was rebuilt (e.g. tab switch).
  void _syncInlineSearchUiFromSession() {
    if (widget.isSearchMode) return;
    if (HomeInlineSearchState().ribbonDismissedByUser) return;
    if (!HomeInlineSearchState().isActive) return;
    if (_inlineSearchActive && !_inlineSearchClosing) return;
    if (!mounted) return;
    setState(() {
      _inlineSearchActive = true;
      _inlineSearchClosing = false;
      _inlineSearchSpacerExpanded = true;
    });
  }

  void _showGuestInlineSearchRibbon({bool keepStaleWhileRibbonAnimates = false}) {
    if (!mounted) return;
    setState(() {
      _inlineSearchActive = true;
      _inlineSearchClosing = false;
      _inlineSearchSpacerExpanded = true;
    });
    HomeInlineSearchState().setActive(true);
    _performSearch(keepStaleWhileRibbonAnimates: keepStaleWhileRibbonAnimates);
  }

  /// Flips the home into inline-search mode, animates the ribbon in, and
  /// starts the filtered search immediately so results can load in parallel
  /// with the slide. [ListingsEvent.keepStaleWhileRefreshing] keeps the feed
  /// on `loaded` (no skeleton) so the animation is not interrupted.
  /// When [persistActiveFlag] is true, also writes the prefs flag so the
  /// ribbon survives the next cold start (the prefs path normally already
  /// has it set, hence the parameter).
  void _activateInlineSearch({required bool persistActiveFlag}) {
    if (HomeInlineSearchState().ribbonDismissedByUser) return;
    if (!_canAutoRestoreInlineSearchRibbon()) return;
    setState(() {
      _inlineSearchActive = true;
      _inlineSearchClosing = false;
      _inlineSearchSpacerExpanded = true;
    });
    HomeInlineSearchState().setActive(true);
    unawaited(HomeInlineSearchState().setRibbonDismissedByUser(false));
    if (persistActiveFlag) {
      unawaited(() async {
        try {
          final p = await SharedPreferences.getInstance();
          await p.setBool(HomeInlineSearchState.activePrefsKey, true);
        } catch (_) {}
      }());
    }
    if (mounted) {
      _performSearch(keepStaleWhileRibbonAnimates: true);
    }
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

  void _onAuthenticationChanged() {
    if (!mounted) return;
    final isNow = AuthenticationState().isAuthenticated;
    final wasBefore = _wasAuthenticated;
    _wasAuthenticated = isNow;

    if (isNow) {
      // Distinguish a real auth flip (false → true) from spurious
      // re-notifications. AuthenticationState calls notifyListeners on
      // every status check, so during a normal login the listener fires
      // multiple times: once when Firebase signs the user in (local
      // session not yet present, [SessionManager.isAuthenticated] still
      // returns false), and again after [_storeBackendSession] writes
      // the token and calls [refreshAuthenticationStatus]. We need to
      // run the bootstrap on the second one too — the first one's
      // [_rebootstrapAfterLogin] aborts on the missing token. Use the
      // post-login activation window as the gate for follow-up retries
      // so we don't keep firing hydrate forever.
      if (!wasBefore) {
        // Real flip — open the window and force a rebuild so the auth
        // gate in [_buildInlineFiltersRibbonAnimated] re-evaluates.
        _postLoginActivationDeadline = DateTime.now().add(
          const Duration(seconds: 20),
        );
        _postLoginRibbonDismissHydrating = true;
        setState(() {});
        unawaited(() async {
          await HomeInlineSearchState().hydrateRibbonDismissedFromPrefs(
            awaitUserScope: true,
          );
          if (!mounted) return;
          _postLoginRibbonDismissHydrating = false;
          await _rebootstrapAfterLogin();
        }());
      } else if (_postLoginActivationDeadline != null &&
          DateTime.now().isBefore(_postLoginActivationDeadline!)) {
        // Follow-up notification within the window: retry the bootstrap
        // in case the previous attempt aborted because the token wasn't
        // yet persisted to prefs.
        unawaited(_rebootstrapAfterLogin());
      }
      return;
    }

    if (!wasBefore) {
      // Already-anonymous re-notification — nothing to do.
      return;
    }

    // Real logout. Force a rebuild so the auth gate in
    // [_buildInlineFiltersRibbonAnimated] removes the AnimatedSwitcher
    // subtree in this frame, instead of letting it play a 750ms slide-out
    // with the previous user's chips cached on the outgoing child.
    _postLoginActivationDeadline = null;
    _postLoginRibbonDismissHydrating = false;
    _postLoginRebootstrapInFlight = false;
    if (_inlineSearchActive) {
      _exitInlineSearch(animated: false, recordRibbonDismissed: false);
    } else {
      unawaited(_resetAnonymousHomeSearchState());
    }
  }

  void _onSearchFiltersStateChanged() {
    if (!mounted) return;

    // The embedded map screen owns its listing data; filter singleton updates
    // (e.g. post-login hydration) should not rebuild the map subtree.
    if (!widget.isSearchMode &&
        _mapViewState.view == _SearchResultsView.map) {
      if (_searchFiltersState.persistedFiltersDismissed) {
        _mapViewState.result = null;
        setState(() {});
      }
      return;
    }

    // When the ribbon is visible, rebuild so the chips bar reflects the
    // latest values (filters are read directly off the singleton at build
    // time). Skipping this rebuild when the ribbon isn't shown avoids
    // pointless work while the user is scrolling wheels in the search
    // sheet, which fires a setter on every wheel index update.
    //
    // Important: do NOT rebuild while the ribbon is animating out
    // (`_inlineSearchClosing`). AnimatedSwitcher keeps the outgoing ribbon
    // widget alive; rebuilding during that window would re-read the singleton
    // filters and can cause visible "chip flips" mid-animation (e.g. gender).
    if (_inlineSearchActive && !_inlineSearchClosing) {
      final current = SearchFiltersSnapshot.capture(_searchFiltersState);
      if (_lastDispatchedSearchFilters == null ||
          !_searchFiltersSnapshotEquals(
            current,
            _lastDispatchedSearchFilters!,
          )) {
        _performSearch(keepStaleWhileRibbonAnimates: true);
      } else {
        setState(() {});
      }
    }

    // Auto-activate the inline ribbon if the filter change happened within
    // the post-login window AND the freshly hydrated filters carry user-
    // applied criteria. This catches the race where hydrate completes via
    // [MainNavigation]'s own auth listener and our [_rebootstrapAfterLogin]
    // already finished its (then-stale) heuristic check.
    final deadline = _postLoginActivationDeadline;
    if (deadline == null || DateTime.now().isAfter(deadline)) return;
    if (_postLoginRibbonDismissHydrating) return;
    if (_postLoginRebootstrapInFlight) return;
    if (HomeInlineSearchState().ribbonDismissedByUser) return;
    if (!AuthenticationState().isAuthenticated) return;
    if (widget.isSearchMode) return;
    if (_inlineSearchActive || _inlineSearchClosing) return;
    if (HomeInlineSearchState().ribbonDismissedByUser) return;
    if (!_hasUserAppliedSearchCriteria()) return;
    _postLoginActivationDeadline = null;
    _activateInlineSearch(persistActiveFlag: true);
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

  void _syncFeedEntriesCache(List<Listing> listings) {
    if (identical(_cachedFeedListingsRef, listings)) return;
    _cachedFeedListingsRef = listings;
    _cachedFeedEntries = homeFeedEntriesWithDateHeaders(listings);
  }

  void _clearFeedEntriesCache() {
    _cachedFeedListingsRef = null;
    _cachedFeedEntries = null;
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
  Future<void> _initializeSearchFilters() async {
    if (widget.listingTypeId != null) {
      await _searchFiltersState.setListingTypeId(widget.listingTypeId!);
    }
    if (widget.locationId != null) {
      await _searchFiltersState.setLocationIndex(widget.locationId!);
    }
    if (widget.subwayLineId != null && widget.locationId == null) {
      await _searchFiltersState.setLocationIndex(0);
    }
    if (widget.subwayLineId != null) {
      await _searchFiltersState.setSubwayLine(widget.subwayLineId!);
    }
    if (widget.subwayLineId != null && widget.subwayStationId == null) {
      await _searchFiltersState.setStationIndex(0);
      await _searchFiltersState.setStationId(0);
    }
    if (widget.subwayStationId != null) {
      await _searchFiltersState.setStationId(widget.subwayStationId!);
    }
    if (widget.gender != null) {
      await _searchFiltersState.setGender(widget.gender!);
    }
    if (widget.minPrice != null || widget.maxPrice != null) {
      final minPrice = widget.minPrice ?? _searchFiltersState.minPrice;
      final maxPrice = widget.maxPrice ?? _searchFiltersState.maxPrice;
      await _searchFiltersState.setPriceRange(minPrice, maxPrice);
    }
    if (widget.privateRoom != null) {
      await _searchFiltersState.setPrivateRoom(widget.privateRoom!);
    }
    if (widget.withPhoto != null) {
      await _searchFiltersState.setWithPhoto(widget.withPhoto!);
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isHomeTabActive && widget.isHomeTabActive) {
      _syncInlineSearchUiFromSession();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes using global route observer
    routeObserver.unsubscribe(this);
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
    AuthenticationState().removeListener(_onAuthenticationChanged);
    _searchFiltersState.removeListener(_onSearchFiltersStateChanged);
    HomeRefreshState().removeListener(_onHomeRefreshStateChanged);
    _resetScrollLoadingState();
    ScrollUtils.disposeScrollController(
      _scrollController,
      _throttledScrollListener,
    );
    super.dispose();
  }

  // RouteAware methods
  @override
  void didPopNext() {
    // Called when returning to this screen from another screen
    debugPrint("🏠 HomeScreen: Returning from another screen");
    _syncInlineSearchUiFromSession();
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
    _syncInlineSearchUiFromSession();
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

  void _dispatchFeedRefresh({bool keepStaleWhileRefreshing = false}) {
    if (widget.isSearchMode ||
        _inlineSearchActive ||
        HomeInlineSearchState().isActive) {
      _dispatchSearch(
        isRefresh: true,
        keepStaleWhileRibbonAnimates: keepStaleWhileRefreshing,
      );
    } else {
      _ensureUnfilteredBrowseFeed(
        keepStaleWhileRefreshing: keepStaleWhileRefreshing,
      );
    }
  }

  /// Default home browse feed — no ribbon filter criteria applied. Saved filter
  /// values remain in [SearchFiltersState] for the search sheet / ribbon.
  void _ensureUnfilteredBrowseFeed({bool keepStaleWhileRefreshing = false}) {
    if (widget.isSearchMode ||
        _inlineSearchActive ||
        HomeInlineSearchState().isActive) {
      return;
    }
    if (!mounted) return;
    context.read<ListingsBloc>().add(
          ListingsEvent.searchListings(
            isRefresh: true,
            keepStaleWhileRefreshing: keepStaleWhileRefreshing,
          ),
        );
  }

  Future<void> _onFeedPullRefresh() async {
    try {
      _dispatchFeedRefresh(keepStaleWhileRefreshing: true);
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
            ? (widget.listingTypeId ?? _searchFiltersState.searchListingTypeId)
            : widget.listingTypeId)
        : _searchFiltersState.searchListingTypeId;

    final listingTypeIds =
        fromExplicit ? null : _searchFiltersState.searchListingTypeIds;

    // For location / metro fields we preserve current behavior: if opened with
    // explicit filters, we display/use exactly what was provided (nullable).
    final locationId = fromExplicit
        ? widget.locationId
        : _searchFiltersState.selectedLocationIndex;
    final subwayStationId = fromExplicit
        ? widget.subwayStationId
        : _searchFiltersState.selectedStationId;
    final subwayStationIds = fromExplicit
        ? widget.subwayStationIds
        : _searchFiltersState.searchSubwayStationIds;
    final stationIds = subwayStationIds ?? const <int>[];
    final hasStationFilter = stationIds.isNotEmpty ||
        (subwayStationId != null && subwayStationId > 0);
    final rawSubwayLineId = fromExplicit
        ? widget.subwayLineId
        : _searchFiltersState.selectedSubwayLine;
    final subwayLineId = hasStationFilter ? rawSubwayLineId : null;
    final gender =
        fromExplicit ? widget.gender : _searchFiltersState.selectedGender;

    final minPrice = fromExplicit
        ? (includeSafeFallbacks ? (widget.minPrice ?? 0.0) : widget.minPrice)
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
      listingTypeIds: listingTypeIds,
      locationId: locationId,
      subwayStationId: subwayStationId,
      subwayStationIds: subwayStationIds,
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
    final inSearchContext = widget.isSearchMode ||
        _inlineSearchActive ||
        _mapViewState.view == _SearchResultsView.map;
    final isShowingEmbeddedMap =
        inSearchContext && _mapViewState.view == _SearchResultsView.map;

    Widget listContent;
    if (isShowingEmbeddedMap) {
      // Skip feed bloc subscriptions while the embedded map is fullscreen so
      // background listing refreshes do not rebuild the map subtree.
      listContent = const SizedBox.shrink();
    } else {
      listContent = BlocListener<ListingsBloc, ListingsState>(
        listener: (context, state) {
          // Reset loading flag when state changes
          state.map(
            initial: (_) {
              _resetLoadMoreState();
              _clearFeedEntriesCache();
            },
            loading: (_) {
              _resetLoadMoreState();
            },
            loaded: (loadedState) {
              _resetLoadMoreState();
              _syncFeedEntriesCache(loadedState.listings);
              final shouldUpdateSearchFlags = _searchRefreshInFlight ||
                  (widget.isSearchMode && !_searchResultsReady);
              if (shouldUpdateSearchFlags && mounted) {
                setState(() {
                  _searchRefreshInFlight = false;
                  if (widget.isSearchMode) {
                    _searchResultsReady = true;
                  }
                });
              }
            },
            error: (_) {
              _resetLoadMoreState();
              _clearFeedEntriesCache();
              if (_searchRefreshInFlight && mounted) {
                setState(() => _searchRefreshInFlight = false);
              }
            },
          );
        },
        child: BlocSelector<ListingsBloc, ListingsState, _HomeScreenData>(
          selector: (state) => state.map(
            initial: (_) => _HomeScreenData(
              isLoading: true,
              hasError: false,
              errorMessage: "",
              listings: const [],
              hasMore: false,
              total: null,
            ),
            loading: (_) => const _HomeScreenData(
              isLoading: true,
              hasError: false,
              errorMessage: "",
              listings: [],
              hasMore: false,
              total: null,
            ),
            loaded: (loadedState) => _HomeScreenData(
              isLoading: false,
              hasError: false,
              errorMessage: "",
              listings: loadedState.listings,
              hasMore: loadedState.hasMore,
              total: loadedState.total,
            ),
            error: (errorState) => _HomeScreenData(
              isLoading: false,
              hasError: true,
              errorMessage: errorState.message,
              listings: [],
              hasMore: false,
              total: null,
            ),
          ),
          builder: (context, data) {
            if (data.isLoading) {
              return _buildLoadingState();
            }
            // While the inline-search ribbon animates out we intentionally delay
            // the actual refresh fetch. During that gap, keep the UI in a
            // "loading" presentation to avoid flashing the welcome/empty states.
            if (_inlineSearchClosing && data.listings.isEmpty) {
              return _buildLoadingState();
            }
            if (data.hasError) {
              return _buildErrorState(data.errorMessage);
            }
            if (widget.isSearchMode && !_searchResultsReady) {
              return _buildLoadingState();
            }
            if (_searchRefreshInFlight &&
                data.listings.isEmpty &&
                (widget.isSearchMode ||
                    _inlineSearchActive ||
                    _inlineSearchClosing)) {
              return _buildLoadingState();
            }
            if (data.listings.isEmpty) {
              return (widget.isSearchMode ||
                      _inlineSearchActive ||
                      _inlineSearchClosing)
                  ? _buildEmptySearchState()
                  : _buildInitialState();
            }
            return _buildLoadedState(data.listings, data.hasMore);
          },
        ),
      );
    }

    // In dedicated search results (isSearchMode), show the applied filters bar
    // pinned under the AppBar and push the list content down by its height.
    const searchRibbonHeight = 56.0;
    if (widget.isSearchMode && !isShowingEmbeddedMap) {
      listContent = Padding(
        padding: const EdgeInsets.only(top: searchRibbonHeight),
        child: listContent,
      );
    }

    final mapResult =
        _mapViewState.result ?? _currentSearchResultForViewToggle();
    final initialMapListings = context.select<ListingsBloc, List<Listing>>(
      (bloc) => bloc.state.maybeMap(
        loaded: (state) => state.listings,
        orElse: () => isShowingEmbeddedMap
            ? _mapViewState.initialMapListings
            : const <Listing>[],
      ),
    );
    final initialMapTotal = context.select<ListingsBloc, int?>(
      (bloc) => bloc.state.maybeMap(
        loaded: (state) => state.total,
        orElse: () => isShowingEmbeddedMap ? _mapViewState.initialMapTotal : null,
      ),
    );
    final feedListingsRevision = context.select<ListingsBloc, int>(
      (bloc) => bloc.state.maybeMap(
        loaded: (state) => state.revision,
        orElse: () => -1,
      ),
    );
    final body = _SearchResultsShell(
      listContent: listContent,
      inSearchContext: inSearchContext,
      isSearchMode: widget.isSearchMode,
      isHomeTabActive: widget.isHomeTabActive,
      searchResultsView: _mapViewState.view,
      mapResult: mapResult,
      searchRibbonHeight: searchRibbonHeight,
      inlineRibbonTop: ThemeState().mainShellGlassExtraTopInset(context),
      mapTopPadding: ThemeState().mainShellGlassExtraTopInset(context),
      mapBottomInset: _blueShellExtendBodyBottomInset(context),
      initialMapListings: initialMapListings,
      initialMapTotal: initialMapTotal,
      feedListingsRevision: feedListingsRevision,
      alertFabBottom: _searchAlertFabStackBottom(context),
      searchFiltersState: _searchFiltersState,
      searchButtonTutorialKey: _searchButtonTutorialKey,
      searchModeFiltersRibbonBuilder: (_) => _buildSearchModeFiltersRibbon(),
      inlineFiltersRibbonBuilder: (_) => _buildInlineFiltersRibbonAnimated(),
      onOpenMapView: () =>
          unawaited(_openSearchResultsMap(_currentSearchResultForViewToggle())),
      onOpenInlineSearch: _openInlineSearchFromFab,
      onOpenMapSearch: _openSearchFromEmbeddedMap,
      onOpenFeedFromMap: _returnToFeedFromMap,
      onDismissMapFilterRibbon:
          widget.isSearchMode ? null : _dismissInlineSearchFromMap,
    );

    return Scaffold(
      backgroundColor: ThemeState().backgroundColor,
      appBar: widget.isSearchMode ? _buildSearchAppBar() : null,
      body: body,
    );
  }

  Widget _buildSearchModeFiltersRibbon() {
    final filters = _resolveSearchFilters(
      includeSafeFallbacks: false,
      explicitNullFallsBackToState: true,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LiquidGlassPlate(
        height: 48,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: AppliedSearchFiltersBar(
          onPressed: _openSearchModeFiltersSheet,
          listingTypeId:
              filters.listingTypeId ?? _searchFiltersState.searchListingTypeId,
          listingTypeIds: filters.listingTypeIds ??
              _searchFiltersState.searchListingTypeIds,
          gender: filters.gender,
          locationId: (filters.locationId != null && filters.locationId! > 0)
              ? filters.locationId
              : null,
          subwayStationId:
              (filters.subwayStationId != null && filters.subwayStationId! > 0)
                  ? filters.subwayStationId
                  : null,
          subwayStationIds: filters.subwayStationIds,
          subwayLineId:
              (filters.subwayLineId != null && filters.subwayLineId! > 0)
                  ? filters.subwayLineId
                  : null,
          minPrice: filters.minPrice,
          maxPrice: filters.maxPrice,
          privateRoom: filters.privateRoom,
          withPhoto: filters.withPhoto,
          total: null,
          showLabel: true,
          alignRight: false,
          height: 48,
          chipSize: 34,
        ),
      ),
    );
  }

  SearchBottomSheetResult _currentSearchResultForViewToggle() {
    final filters = _resolveSearchFilters(
      includeSafeFallbacks: false,
      explicitNullFallsBackToState: true,
    );
    final listingTypeId =
        filters.listingTypeId ?? _searchFiltersState.selectedListingTypeId;
    final locationId = filters.locationId != null && filters.locationId! > 0
        ? filters.locationId
        : null;
    final subwayStationId =
        filters.subwayStationId != null && filters.subwayStationId! > 0
            ? filters.subwayStationId
            : null;
    final subwayLineId =
        filters.subwayLineId != null && filters.subwayLineId! > 0
            ? filters.subwayLineId
            : null;

    return SearchBottomSheetResult(
      listingTypeId: listingTypeId,
      locationId: locationId,
      subwayStationId: subwayStationId,
      subwayStationIds: filters.subwayStationIds ?? const [],
      subwayLineId: subwayLineId,
      gender:
          filters.gender != null && filters.gender! > 0 ? filters.gender : null,
      minPrice: filters.minPrice ?? _searchFiltersState.minPrice,
      maxPrice: filters.maxPrice ?? _searchFiltersState.maxPrice,
      privateRoom: filters.privateRoom ?? _searchFiltersState.privateRoom,
      withPhoto: filters.withPhoto ?? _searchFiltersState.withPhoto,
      action: SearchBottomSheetAction.map,
    );
  }

  bool _homeRibbonAnimationsEnabled(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
  }

  Duration _homeRibbonAnimationDuration(BuildContext context) =>
      _homeRibbonAnimationsEnabled(context)
          ? const Duration(milliseconds: 1000)
          : Duration.zero;

  /// Base top padding for home list content when embedded under the main shell
  /// glass header (body draws behind the toolbar). Search mode uses a route
  /// with a normal [AppBar], so the body is already below the status bar —
  /// return 0. The list keeps this stable base and animates spacer item 0 for
  /// the inline ribbon to avoid scroll-metric jumps.
  double _feedBaseTopPadding() {
    if (widget.isSearchMode) return 0;
    return ThemeState().mainShellGlassExtraTopInset(context);
  }

  /// Must match [CustomCurvedNavigationBar] height / package limit (~70).
  static const double _kCurvedBottomBarHeight = 70.0;

  /// Bottom clearance for tabs under [MainNavigation] + blue [Scaffold.extendBody].
  /// Flutter **web** often reports [MediaQuery.padding.bottom] as `0` even when
  /// the curved bar overlaps the body; use at least [_kCurvedBottomBarHeight].
  double _blueShellExtendBodyBottomInset(BuildContext context) {
    if (!widget.isHomeTabActive ||
        !ThemeState().isBlueTheme ||
        widget.isSearchMode) {
      return 0;
    }
    final mq = MediaQuery.of(context);
    return math.max(
      _kCurvedBottomBarHeight,
      math.max(mq.padding.bottom, mq.viewPadding.bottom),
    );
  }

  /// Keeps the last feed items above the curved bar when the shell uses
  /// [Scaffold.extendBody] (Scaffold raises [MediaQuery.padding.bottom] to the
  /// bar height).
  double _feedListBottomPadding(BuildContext context) {
    final shellInset = _blueShellExtendBodyBottomInset(context);
    if (shellInset != 0) {
      return math.max(16.0, shellInset);
    }
    return math.max(16.0, MediaQuery.paddingOf(context).bottom);
  }

  /// Bottom inset for the search / bell FAB column on the housing [Stack].
  ///
  /// [MainNavigation] uses [Scaffold.extendBody] for the blue shell so the
  /// body (and this [Stack]) reaches the screen bottom. A fixed `bottom:` would
  /// then pin to the physical bottom — under the curved bar — instead of
  /// sitting above it like before extendBody.
  double _searchAlertFabStackBottom(BuildContext context) {
    const base = 30.0;
    return base + _blueShellExtendBodyBottomInset(context);
  }

  double _feedRibbonSpacerHeight() {
    if (widget.isSearchMode) return 0;
    return _inlineSearchSpacerExpanded ? _inlineSearchRibbonHeight : 0;
  }

  double _feedTopSpacerVisualHeight({required double trailingSpacing}) {
    return math.max(
      0.0,
      _feedRibbonSpacerHeight() +
          _inlineSearchRibbonToListGap -
          trailingSpacing,
    );
  }

  Widget _buildAnimatedFeedTopSpacer({required double trailingSpacing}) {
    // CommonListView applies `itemSpacing` as bottom padding to each item.
    // If we place a spacer as item 0, it will get that spacing too, which would
    // create an oversized gap between ribbon and first listing.
    //
    // We compensate by subtracting the spacing that will be added after this
    // spacer, so the resulting "visual gap" equals [_inlineSearchRibbonToListGap].
    final targetHeight = _feedTopSpacerVisualHeight(
      trailingSpacing: trailingSpacing,
    );
    return AnimatedContainer(
      duration: _homeRibbonAnimationDuration(context),
      curve: Curves.easeOutCubic,
      height: targetHeight,
    );
  }

  Widget _buildInlineFiltersRibbonAnimated() {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        final enabled = _homeRibbonAnimationsEnabled(context);
        final d = _homeRibbonAnimationDuration(context);
        return AnimatedSwitcher(
          duration: enabled ? d : Duration.zero,
          reverseDuration: enabled ? d : Duration.zero,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            // AnimatedSwitcher already applies switchInCurve/switchOutCurve to
            // [animation]; avoid wrapping in extra CurvedAnimations (leak).
            final slide = Tween<Offset>(
              begin: const Offset(-1.0, 0),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _inlineSearchActive
              ? KeyedSubtree(
                  key: const ValueKey("inline_filters_ribbon"),
                  child: _buildInlineFiltersRibbon(),
                )
              : _inlineSearchClosing
                  ? const SizedBox(
                      key: ValueKey("inline_filters_ribbon_placeholder"),
                      height: _inlineSearchRibbonHeight,
                    )
                  : const SizedBox.shrink(
                      key: ValueKey("inline_filters_ribbon_empty"),
                    ),
        );
      },
    );
  }

  double _fabColumnHeight({required bool includeBellFab}) {
    if (includeBellFab) {
      return _kFabSize + _kFabGap + _kFabSize;
    }
    return _kFabSize;
  }

  /// Extra bottom clearance so empty-search CTAs stay above the search FAB.
  double _emptySearchExtraBottomScrollPadding(BuildContext context) {
    return math.max(
      0.0,
      _searchAlertFabStackBottom(context) +
          _fabColumnHeight(includeBellFab: false) +
          16.0 -
          100.0,
    );
  }

  /// Scrollable wrapper so pull-to-refresh works when content is shorter than
  /// the viewport (welcome / empty states).
  Widget _buildPullToRefreshAroundFillChild(
    Widget child, {
    double extraBottomPadding = 0,
    bool allowUserScroll = true,
  }) {
    final baseTopPad = _feedBaseTopPadding();
    final edgeOffset =
        baseTopPad + _feedRibbonSpacerHeight() + _inlineSearchRibbonToListGap;
    return UydoshRefreshIndicator.mainShell(
      onRefresh: _onFeedPullRefresh,
      edgeOffset: edgeOffset,
      child: PullToRefreshStretchHaptics(
        // Use a single scrollable with a single box child.
        // This avoids a Flutter web edge-case where swapping sliver vs. box
        // scrollables during rebuild can trigger a mouse_tracker assertion.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topSpacerHeight = _feedTopSpacerVisualHeight(
              trailingSpacing: 0,
            );
            final bottomPadding =
                _feedListBottomPadding(context) + extraBottomPadding;
            return ListView(
              controller: _scrollController,
              physics: allowUserScroll
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.0,
                baseTopPad,
                16.0,
                bottomPadding,
              ),
              children: [
                _buildAnimatedFeedTopSpacer(trailingSpacing: 0),
                SizedBox(
                  // Shrink the centering region by the reserved bottom space
                  // (FAB stack + notify tooltip) so empty/welcome content sits
                  // higher and never overlaps the floating buttons.
                  height: (constraints.maxHeight -
                          baseTopPad -
                          topSpacerHeight -
                          bottomPadding)
                      .clamp(0.0, constraints.maxHeight),
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
    final isBlue = ThemeState().isBlueTheme;
    final scheme = Theme.of(context).colorScheme;
    final orbDecoration = isBlue
        ? BoxDecoration(
            color: BlueThemeColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            gradient: ThreeDSurfaceStyle.surfaceGradient(
              context,
              scheme.surface,
            ),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          );
    final orbIconColor = isBlue ? Colors.white : scheme.onSurface;

    return LiquidGlassPlate(
      height: _inlineSearchRibbonHeight,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // Reserve space for the tune icon which is drawn above the chips.
              const SizedBox(width: 18, height: 18),
              // Small breathing room between the tune icon and the first chip.
              const SizedBox(width: 16),
              Expanded(child: _buildInlineFiltersChips()),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: DecoratedBox(
                  decoration: orbDecoration,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 16, color: orbIconColor),
                  ),
                ),
                onPressed: () {
                  HapticFeedbackUtils.impact();
                  _exitInlineSearch();
                },
                tooltip: L10n.get("close"),
              ),
            ],
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Center(
                child: DecoratedBox(
                  decoration: orbDecoration,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.tune, size: 16, color: orbIconColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineFiltersChips() {
    final selectedStationIds = _searchFiltersState.selectedStationIdsList;
    final effectiveSubwayLineId = selectedStationIds.isNotEmpty &&
            _searchFiltersState.selectedSubwayLine > 0
        ? _searchFiltersState.selectedSubwayLine
        : null;

    return AppliedSearchFiltersBar(
      onPressed: _openInlineSearchFromFab,
      listingTypeId: _searchFiltersState.searchListingTypeId,
      listingTypeIds: _searchFiltersState.searchListingTypeIds,
      gender: _searchFiltersState.selectedGender,
      locationId: _searchFiltersState.selectedLocationIndex > 0
          ? _searchFiltersState.selectedLocationIndex
          : null,
      subwayStationId: _searchFiltersState.selectedStationId > 0
          ? _searchFiltersState.selectedStationId
          : null,
      subwayStationIds: _searchFiltersState.searchSubwayStationIds,
      subwayLineId: effectiveSubwayLineId,
      minPrice: _searchFiltersState.minPrice,
      maxPrice: _searchFiltersState.maxPrice,
      privateRoom: _searchFiltersState.privateRoom,
      withPhoto: _searchFiltersState.withPhoto,
      total: null,
      showLabel: false,
      alignRight: false,
      alwaysShowPriceRange: true,
      height: _inlineSearchRibbonHeight,
      // Reserve space so the last chip never scrolls under the trailing close button.
      // (44px tap target + a little breathing room for chip shadows)
      endPadding: 56,
    );
  }

  Widget _buildInitialState() {
    return _buildPullToRefreshAroundFillChild(
      HomeWelcomePlaceholder(
        homeIconColor: _getHomeIconColor(),
        titleColor: _getWelcomeTitleColor(),
        subtitleColor: _getWelcomeSubtitleColor(),
        onRefresh: _dispatchFeedRefresh,
      ),
    );
  }

  Widget _buildEmptySearchState() {
    _maybeShowNoResultsAlertBellTutorial();
    return _buildPullToRefreshAroundFillChild(
      HomeEmptySearchPlaceholder(
        homeIconColor: _getHomeIconColor(),
        titleColor: _getWelcomeTitleColor(),
        onNotifyMe: _isCreatingSearchAlert
            ? null
            : () => unawaited(_subscribeToSearchAlerts()),
        emptySearchCtaHeight: _kEmptySearchCtaButtonHeight,
      ),
      extraBottomPadding: _emptySearchExtraBottomScrollPadding(context),
      allowUserScroll: false,
    );
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

    final alertStationIds = filters.subwayStationIds ?? const <int>[];
    final hasAnyLocationConstraint =
        (filters.locationId != null && filters.locationId! > 0) ||
            (filters.subwayLineId != null && filters.subwayLineId! > 0) ||
            alertStationIds.isNotEmpty ||
            (filters.subwayStationId != null && filters.subwayStationId! > 0);
    if (!hasAnyLocationConstraint) {
      ToastTheme.showError(context, message: L10n.get("search_alert_too_wide"));
      return;
    }

    setState(() => _isCreatingSearchAlert = true);
    try {
      // Coverage by an existing broader alert (e.g. a "whole line" alert
      // already covering this station) is now resolved server-side so the
      // backend can merge against price ranges. The server returns the
      // existing alert when the new request is fully redundant.
      final err =
          await getIt<ISearchAlertService>().createAlertForCurrentSearch(
        listingTypeId:
            filters.listingTypeId ?? _searchFiltersState.selectedListingTypeId,
        locationId: filters.locationId,
        subwayStationId:
            alertStationIds.length > 1 ? null : filters.subwayStationId,
        subwayStationIds: alertStationIds.length > 1 ? alertStationIds : null,
        subwayLineId: filters.subwayLineId,
        gender: filters.gender,
        minPrice: filters.minPrice ?? 0.0,
        maxPrice: filters.maxPrice ?? 1000.0,
        privateRoomOnly: filters.privateRoom ?? false,
        withPhotoOnly: filters.withPhoto ?? false,
      );

      if (!mounted) return;

      if (err != null) {
        if (err == SearchAlertService.alreadyExistsErrorToken) {
          ToastTheme.showWarning(
            context,
            message: L10n.get("search_alert_already_exists"),
            leadingIcon: Icons.notifications_active_outlined,
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
        // Header bell celebration is driven by `ActiveSearchAlertsState()`.
      }

      // Trigger header bell "shake" immediately (don't wait for list refresh).
      ActiveSearchAlertsState().bumpCelebration();
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

      ToastTheme.showSuccess(
        context,
        message: L10n.get("search_alert_created"),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingSearchAlert = false);
      }
    }
  }

  Widget _buildLoadingState() {
    final baseTopPad = _feedBaseTopPadding();
    return CommonListView(
      padding: EdgeInsets.fromLTRB(
        14.0,
        baseTopPad,
        14.0,
        _feedListBottomPadding(context),
      ),
      itemSpacing: 16.0,
      itemCount: 7,
      itemBuilder: (context, index) {
        if (index == 0)
          return _buildAnimatedFeedTopSpacer(trailingSpacing: 16.0);
        return const ListingTileSkeleton();
      },
    );
  }

  Widget _buildLoadedState(List<Listing> listings, bool hasMore) {
    // Slightly tighter than the default 16 so date headers sit closer to cards;
    // must match [trailingSpacing] on the feed top spacer (see [_buildAnimatedFeedTopSpacer]).
    const feedItemSpacing = 12.0;
    final baseTopPad = _feedBaseTopPadding();
    final edgeOffset =
        baseTopPad + _feedRibbonSpacerHeight() + _inlineSearchRibbonToListGap;
    final feedEntries =
        _cachedFeedEntries ?? homeFeedEntriesWithDateHeaders(listings);
    return UydoshRefreshIndicator.mainShell(
      onRefresh: _onFeedPullRefresh,
      edgeOffset: edgeOffset,
      child: FeedScrollScopeHost(
        child: PullToRefreshStretchHaptics(
          child: CommonListView(
            itemSpacing: feedItemSpacing,
            itemCount: feedEntries.length + 1,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              14.0,
              baseTopPad,
              14.0,
              _feedListBottomPadding(context),
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAnimatedFeedTopSpacer(
                  trailingSpacing: feedItemSpacing,
                );
              }
              final entry = feedEntries[index - 1];
              final listing = entry.listing;
              if (listing != null) {
                return ListingTile(
                  key: ValueKey(listing.id),
                  listing: listing,
                  feedOptimized: true,
                  forceFavorite:
                      false, // Home screen listings don't force favorite state
                  showHeartIcon: false, // Don't show heart icon on home screen
                  showFavoriteIndicator:
                      true, // Show small heart when listing is in user favorites
                  onFavoriteRemoved: null, // No callback needed for home screen
                );
              }
              final day = entry.day!;
              final isFirst = entry.isFirstDateHeader!;
              return DateHeaderWidget(
                key: ValueKey(
                  "home-feed-day-${day.year}-${day.month}-${day.day}",
                ),
                dateString: AppDateUtils.formatDateHeader(day, context),
                date: day,
                padding: isFirst
                    ? const EdgeInsets.only(top: 0, bottom: 0)
                    : const EdgeInsets.only(top: 0, bottom: 0),
              );
            },
            controller: _scrollController,
            showRefreshIndicator:
                false, // Already handled by UydoshRefreshIndicator wrapper
            showLoadMoreIndicator: hasMore,
            hasMore: hasMore,
            loadMoreIndicator: _buildLoadMoreIndicator(),
            cacheExtent: isAndroidDevice
                ? 720
                : 500, // Android skips tile blur — can afford a wider cache
          ),
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
      currentSubwayStationIds: _searchFiltersState.selectedStationIdsList,
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

  void _openSearchFromEmbeddedMap() {
    SearchBottomSheetWidget.show(
      context,
      openedFromHomeScreen: widget.isHomeTabActive,
      currentListingTypeId: _searchFiltersState.selectedListingTypeId,
      currentLocationId: _searchFiltersState.selectedLocationIndex,
      currentSubwayStationId: _searchFiltersState.selectedStationId,
      currentSubwayStationIds: _searchFiltersState.selectedStationIdsList,
      currentSubwayLineId: _searchFiltersState.selectedSubwayLine,
      currentGender: _searchFiltersState.selectedGender,
      currentMinPrice: _searchFiltersState.minPrice,
      currentMaxPrice: _searchFiltersState.maxPrice,
      currentPrivateRoom: _searchFiltersState.privateRoom,
      currentWithPhoto: _searchFiltersState.withPhoto,
      primaryAction: SearchBottomSheetAction.map,
      onApply: (result) async {
        if (widget.isSearchMode) {
          await _applySearchModeResult(result);
        } else {
          await _applyInlineSearchResult(result);
        }
      },
    );
  }

  Future<void> _applyInlineSearchResult(SearchBottomSheetResult result) async {
    _searchFiltersState.clearPersistedFiltersDismissed();
    await HomeInlineSearchState().setRibbonDismissedByUser(false);
    await _persistSearchResultFilters(result);

    if (result.action == SearchBottomSheetAction.map) {
      if (!mounted) return;
      setState(() {
        _openMapViewWithSnapshot(result);
        _inlineSearchActive = true;
        _inlineSearchClosing = false;
        _inlineSearchSpacerExpanded = true;
      });
      HomeInlineSearchState().setActive(true);
      unawaited(() async {
        try {
          final p = await SharedPreferences.getInstance();
          await p.setBool(HomeInlineSearchState.activePrefsKey, true);
        } catch (_) {}
      }());
      return;
    }

    if (!mounted) return;
    setState(() {
      _inlineSearchActive = true;
      _inlineSearchClosing = false;
      _inlineSearchSpacerExpanded = true;
      _mapViewState.openFeed(result);
    });
    HomeInlineSearchState().setMapViewActive(false);
    HomeInlineSearchState().setActive(true);
    unawaited(() async {
      try {
        final p = await SharedPreferences.getInstance();
        await p.setBool(HomeInlineSearchState.activePrefsKey, true);
      } catch (_) {}
    }());
    // Dispatch immediately so the feed cannot sit on a stale unfiltered page
    // while SharedPreferences writes finish (pull-to-refresh was fixing that).
    _performSearch(keepStaleWhileRibbonAnimates: true);
  }

  bool _shouldSuppressInlineSearchRestore({
    bool mapFilterRibbonDismissed = false,
  }) {
    return mapFilterRibbonDismissed ||
        HomeInlineSearchState().ribbonDismissedByUser ||
        _searchFiltersState.persistedFiltersDismissed;
  }

  Future<void> _finishFeedReturnWithoutFilters() async {
    _markInlineSearchDismissedSync();
    if (!mounted) return;
    setState(() {
      _inlineSearchActive = false;
      _inlineSearchClosing = false;
      _inlineSearchSpacerExpanded = false;
      _mapViewState.resetToList();
    });
    HomeInlineSearchState().setMapViewActive(false);
    HomeInlineSearchState().setActive(false);
    _lastDispatchedSearchFilters = null;
    unawaited(_persistInlineSearchDismissed());
    _ensureUnfilteredBrowseFeed();
  }

  void _markInlineSearchDismissedSync() {
    _searchFiltersState.markPersistedFiltersDismissed();
    HomeInlineSearchState().markRibbonDismissedInMemory(true);
  }

  Future<void> _persistInlineSearchDismissed() async {
    // Persist dismiss before clearing filters so a quick simulator stop/restart
    // cannot miss the flag and re-hydrate from backend on next launch.
    await HomeInlineSearchState().setRibbonDismissedByUser(true);
    await _searchFiltersState.dismissPersistedSearchFilters();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(HomeInlineSearchState.activePrefsKey, false);
    } catch (_) {}
  }

  /// Clears saved filters and deactivates inline search without leaving map view.
  void _dismissInlineSearchFromMap() {
    _markInlineSearchDismissedSync();
    _searchFiltersState.clearAllFiltersInMemory();
    _mapViewState.result = null;
    if (mounted) {
      setState(() {
        _inlineSearchActive = false;
        _inlineSearchClosing = false;
        _inlineSearchSpacerExpanded = false;
      });
    }
    HomeInlineSearchState().setActive(false);
    _lastDispatchedSearchFilters = null;
    unawaited(_persistInlineSearchDismissed());
    _ensureUnfilteredBrowseFeed();
  }

  /// Clears persisted search filters (local + server when logged in), then
  /// closes inline mode. The Settings toggle "Restore filters on app start" is
  /// unchanged.
  void _exitInlineSearch({
    bool animated = true,
    bool recordRibbonDismissed = true,
  }) {
    final refreshToken = ++_inlineSearchExitRefreshToken;
    if (mounted) {
      setState(() {
        _inlineSearchActive = false;
        // When [animated] is false (e.g. driven by logout), skip the closing
        // placeholder so AnimatedSwitcher does not keep the outgoing ribbon
        // — built with the previous user's filters — visible while it slides
        // away.
        _inlineSearchClosing = animated;
        // Collapse spacer immediately so listings move up during ribbon slide-out.
        _inlineSearchSpacerExpanded = false;
        _mapViewState.resetToList();
      });
    }
    HomeInlineSearchState().setMapViewActive(false);
    HomeInlineSearchState().setActive(false);
    _lastDispatchedSearchFilters = null;
    if (recordRibbonDismissed) {
      _markInlineSearchDismissedSync();
      unawaited(_persistInlineSearchDismissed());
    } else {
      SharedPreferences.getInstance().then((p) async {
        await p.setBool(HomeInlineSearchState.activePrefsKey, false);
      });
    }
    final keepStaleDuringRibbonOut =
        animated && _homeRibbonAnimationsEnabled(context);
    _dispatchFeedRefresh(keepStaleWhileRefreshing: keepStaleDuringRibbonOut);
    final animationsEnabled = animated && _homeRibbonAnimationsEnabled(context);
    unawaited(() async {
      if (animationsEnabled) {
        await Future.delayed(_homeRibbonAnimationDuration(context));
      }
      if (!mounted) return;
      if (_inlineSearchActive) return;
      if (refreshToken != _inlineSearchExitRefreshToken) return;
      setState(() => _inlineSearchClosing = false);
    }());
  }

  void _pushFullSearchResultsRoute() {
    final locationId = _searchFiltersState.selectedLocationIndex;
    final stationId = _searchFiltersState.selectedStationId;
    final stationIds = _searchFiltersState.selectedStationIdsList;
    final lineId =
        stationIds.isNotEmpty && _searchFiltersState.selectedSubwayLine > 0
            ? _searchFiltersState.selectedSubwayLine
            : null;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ListingsBloc(getIt<IListingService>()),
          child: HomeScreen(
            listingTypeId: _searchFiltersState.selectedListingTypeId,
            locationId: locationId > 0 ? locationId : null,
            subwayStationId: stationId > 0 ? stationId : null,
            subwayStationIds: stationIds,
            subwayLineId: lineId,
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
    return const HomeFeedLoadMoreFooter();
  }

  Widget _buildErrorState(String message) {
    return HomeFeedErrorPanel(message: message, onRetry: _dispatchFeedRefresh);
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
      title: BlocConsumer<ListingsBloc, ListingsState>(
        listenWhen: (previous, current) =>
            !_searchCountReady &&
            current.maybeMap(loaded: (_) => true, orElse: () => false),
        listener: (context, state) {
          // Once *new* results arrive, allow showing the count.
          if (!_searchCountReady &&
              state.maybeMap(loaded: (_) => true, orElse: () => false) &&
              mounted) {
            setState(() => _searchCountReady = true);
          }
        },
        builder: (context, state) {
          final baseTitle = L10n.get("search_results");
          final count = (_searchCountReady)
              ? state.maybeMap(loaded: (s) => s.total, orElse: () => null)
              : null;
          final titleText =
              (count == null || count <= 0) ? baseTitle : "$baseTitle ($count)";
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
            child: ListenableBuilder(
              listenable: ActiveSearchAlertsState(),
              builder: (context, _) {
                return NotifySearchAlertAppBarButton(
                  tooltip: L10n.get("search_alert_notify_me"),
                  enabled: !_isCreatingSearchAlert,
                  celebrationTick: ActiveSearchAlertsState().celebrationTick,
                  onPressed: _subscribeToSearchAlerts,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openSearchModeFiltersSheet() {
    SearchBottomSheetWidget.show(
      context,
      replaceCurrentRoute: true,
      openedFromHomeScreen: false,
      currentListingTypeId: _searchFiltersState.selectedListingTypeId,
      currentLocationId: _searchFiltersState.selectedLocationIndex,
      currentSubwayStationId: _searchFiltersState.selectedStationId,
      currentSubwayLineId: _searchFiltersState.selectedSubwayLine,
      currentGender: _searchFiltersState.selectedGender,
      currentMinPrice: _searchFiltersState.minPrice,
      currentMaxPrice: _searchFiltersState.maxPrice,
      currentPrivateRoom: _searchFiltersState.privateRoom,
      currentWithPhoto: _searchFiltersState.withPhoto,
      onApply: (result) async {
        await _applySearchModeResult(result);
      },
    );
  }

  Future<void> _applySearchModeResult(SearchBottomSheetResult result) async {
    await _persistSearchResultFilters(result);

    if (result.action == SearchBottomSheetAction.map) {
      if (!mounted) return;
      setState(() {
        _openMapViewWithSnapshot(result);
      });
      return;
    }

    if (!mounted) return;
    setState(() {});
    _performSearch();
  }

  Future<void> _persistSearchResultFilters(
    SearchBottomSheetResult result,
  ) async {
    await _searchFiltersState.setListingTypeId(result.listingTypeId);
    await _searchFiltersState.setGender(result.gender ?? 0);
    await _searchFiltersState.setPriceRange(result.minPrice, result.maxPrice);
    await _searchFiltersState.setPrivateRoom(result.privateRoom);
    await _searchFiltersState.setWithPhoto(result.withPhoto);

    // Metro line is just a "whole line" marker now; it coexists with both the
    // multi-station selection and a chosen location (filters are combined).
    if (result.subwayLineId != null && (result.subwayLineId ?? 0) > 0) {
      await _searchFiltersState.setSubwayLine(result.subwayLineId!);
    } else {
      await _searchFiltersState.setSubwayLine(0);
    }

    if (result.subwayStationIds.isNotEmpty) {
      await _searchFiltersState.setStationIds(result.subwayStationIds);
    } else if (result.subwayStationId != null &&
        (result.subwayStationId ?? 0) > 0) {
      await _searchFiltersState.setStationId(result.subwayStationId!);
    } else {
      await _searchFiltersState.setStationIds(const []);
    }

    // Location is single-select and now coexists with the metro filters.
    if (result.locationId != null && (result.locationId ?? 0) > 0) {
      await _searchFiltersState.setLocationIndex(result.locationId!);
    } else {
      await _searchFiltersState.setLocationIndex(0);
    }
  }

  Future<void> _openSearchResultsMap(SearchBottomSheetResult result) async {
    if (!mounted) return;
    _searchFiltersState.clearPersistedFiltersDismissed();
    unawaited(HomeInlineSearchState().setRibbonDismissedByUser(false));
    setState(() {
      _openMapViewWithSnapshot(result);
      if (!widget.isSearchMode) {
        _inlineSearchActive = true;
        _inlineSearchClosing = false;
        _inlineSearchSpacerExpanded = true;
      }
    });
    if (!widget.isSearchMode) {
      HomeInlineSearchState().setActive(true);
      unawaited(() async {
        await HomeInlineSearchState().setRibbonDismissedByUser(false);
        try {
          final p = await SharedPreferences.getInstance();
          await p.setBool(HomeInlineSearchState.activePrefsKey, true);
        } catch (_) {}
      }());
    }
  }

  Future<void> _returnToFeedFromMap(
    BuildContext mapContext,
    SearchBottomSheetResult result, {
    bool mapFilterRibbonDismissed = false,
  }) async {
    if (widget.isSearchMode) {
      await _applySearchModeResult(result);
    } else if (_shouldSuppressInlineSearchRestore(
      mapFilterRibbonDismissed: mapFilterRibbonDismissed,
    )) {
      await _finishFeedReturnWithoutFilters();
      return;
    } else {
      await _applyInlineSearchResult(result);
    }
    if (!mounted) return;
    setState(() {
      _mapViewState.openFeed(result);
    });
    HomeInlineSearchState().setMapViewActive(false);
  }

  /// Perform search using current filters
  void _performSearch({bool keepStaleWhileRibbonAnimates = false}) {
    _dispatchSearch(
      isRefresh: true,
      keepStaleWhileRibbonAnimates: keepStaleWhileRibbonAnimates,
    );
  }

  void _dispatchSearch({
    required bool isRefresh,
    bool keepStaleWhileRibbonAnimates = false,
  }) {
    final listingsBloc = context.read<ListingsBloc>();

    // Hide stale search UI from a previous `loaded` state while this new search
    // is being dispatched.
    if (isRefresh && mounted) {
      setState(() {
        _searchCountReady = false;
        final inSearchContext = widget.isSearchMode ||
            _inlineSearchActive ||
            _inlineSearchClosing ||
            HomeInlineSearchState().isActive;
        if (inSearchContext) {
          _searchRefreshInFlight = true;
        }
        if (widget.isSearchMode) {
          _searchResultsReady = false;
        }
      });
    }

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
          keepStaleWhileRefreshing: keepStaleWhileRibbonAnimates,
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

    _lastDispatchedSearchFilters = SearchFiltersSnapshot.capture(
      _searchFiltersState,
    );

    listingsBloc.add(
      ListingsEvent.searchListings(
        listingTypeId:
            filters.listingTypeIds != null ? null : filters.listingTypeId,
        listingTypeIds: filters.listingTypeIds,
        locationId: filters.locationId,
        subwayStationId: filters.subwayStationId,
        subwayStationIds: filters.subwayStationIds,
        subwayLineId: filters.subwayLineId,
        gender: filters.gender,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        privateRoom: filters.privateRoom,
        withPhoto: filters.withPhoto,
        isRefresh: isRefresh,
        keepStaleWhileRefreshing: keepStaleWhileRibbonAnimates,
      ),
    );
  }
}

bool _searchFiltersSnapshotEquals(
  SearchFiltersSnapshot a,
  SearchFiltersSnapshot b,
) {
  return a.selectedListingTypeId == b.selectedListingTypeId &&
      _listEquals(a.searchListingTypeIds, b.searchListingTypeIds) &&
      a.selectedLocationIndex == b.selectedLocationIndex &&
      a.selectedSubwayLine == b.selectedSubwayLine &&
      a.selectedStationIndex == b.selectedStationIndex &&
      a.selectedStationId == b.selectedStationId &&
      _listEquals(a.selectedStationIds, b.selectedStationIds) &&
      a.selectedGender == b.selectedGender &&
      a.minPrice == b.minPrice &&
      a.maxPrice == b.maxPrice &&
      a.privateRoom == b.privateRoom &&
      a.withPhoto == b.withPhoto;
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
