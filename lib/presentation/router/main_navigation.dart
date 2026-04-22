import "dart:async" show unawaited;

import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart" show AppColors;
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/base/services/google_avatar_backend_sync.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/main.dart" show routeObserver;
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/router/app_router_keys.dart";
import "package:uy_dosh/presentation/screens/create_listing/create_listing_screen.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_screen.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/burger_menu_widget.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/curved_navigation_widget.dart";
import "package:uy_dosh/presentation/widgets/tutorial/alert_bell_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

/// Public state so other parts of the app can switch tabs via `mainNavigationKey`.
class MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver, RouteAware {
  late int _currentIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  bool _isAuthenticated = false;
  int _incomingMessageTravelDotTrigger = 0;
  int _lastObservedUnreadCount = 0;
  DateTime? _lastTravelDotPlayedAt;

  bool _profileCompletionPromptShown = false;
  bool _checkingProfileCompletion = false;
  bool _notificationsBellTutorialShownThisSession = false;
  bool _notificationsBellTutorialPending = false;

  late final VoidCallback _authStateListener;
  late final VoidCallback _unreadMessagesListener;

  void _scheduleMaybeShowNotificationsBellTutorial() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowNotificationsBellTutorial();
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Handle deep link and push notification tap from cold start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        getIt<DeepLinkService>().handlePendingLink();
        getIt<IPushNotificationService>().handlePendingNotificationTap();
      }
    });

    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Listen to global authentication state changes. Stored in a field so
    // we can remove it in dispose() — otherwise each remount of
    // MainNavigation leaks another listener onto the global singleton.
    _authStateListener = () {
      if (mounted) {
        _checkAuthenticationStatus();
      }
    };
    AuthenticationState().addListener(_authStateListener);

    _lastObservedUnreadCount = UnreadMessagesState().unreadCount;
    _unreadMessagesListener = _onUnreadMessagesChanged;
    UnreadMessagesState().addListener(_unreadMessagesListener);

    // Show notifications bell tutorial once the user has at least one alert.
    ActiveSearchAlertsState().addListener(_maybeShowNotificationsBellTutorial);

    // Re-attempt notifications bell tutorial when tutorial progress changes
    // (e.g. user completes the search tutorial, which is a prerequisite).
    TutorialState().addListener(_maybeShowNotificationsBellTutorial);

    // Check initial authentication status
    _checkAuthenticationStatus();

    // Initialize profile completion state from cache when authenticated
    _initProfileCompletionFromCache();

    // If alerts are already active by the time main navigation mounts (or the
    // listener fired earlier while AppBar target wasn't mounted), ensure we
    // still attempt to show the tutorial once the AppBar is visible.
    _scheduleMaybeShowNotificationsBellTutorial();
  }

  Future<void> _initProfileCompletionFromCache() async {
    if (!AuthenticationState().isAuthenticated) return;
    try {
      // 1) Instant-prime from cache so the UI has completion state without
      //    waiting for the network.
      final cached = await SessionManager.getCachedUserProfile();
      if (cached != null && mounted) {
        ProfileCompletionState().updateFromProfile(cached);
      }

      // 2) Always refresh from the server so stale cached profiles (e.g.
      //    saved through a flow that didn't also write to SessionManager)
      //    self-heal on the next app launch.
      final fresh = await getIt<IUserProfileService>().getCurrentUserProfile();
      await SessionManager.storeUserProfile(fresh);
      if (mounted) {
        ProfileCompletionState().updateFromProfile(fresh);
      }
      await syncGoogleAvatarToBackendIfMissing(existingProfile: fresh);
    } catch (_) {
      // Ignore - profile will be loaded when user opens profile/burger menu
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AuthenticationState().removeListener(_authStateListener);
    UnreadMessagesState().removeListener(_unreadMessagesListener);
    ActiveSearchAlertsState().removeListener(_maybeShowNotificationsBellTutorial);
    TutorialState().removeListener(_maybeShowNotificationsBellTutorial);
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onUnreadMessagesChanged() {
    final current = UnreadMessagesState().unreadCount;
    final previous = _lastObservedUnreadCount;
    _lastObservedUnreadCount = current;

    // Play when unread increases and the user isn't currently on Messages tab.
    // (This is more robust than only 0 -> >0; many users already have unread.)
    if (current > previous && _currentIndex != 2) {
      final now = DateTime.now();
      final last = _lastTravelDotPlayedAt;
      // Additional global cooldown (even if multiple increments happen quickly).
      if (last != null && now.difference(last) < const Duration(seconds: 8)) {
        return;
      }
      _lastTravelDotPlayedAt = now;
      if (mounted) {
        setState(() {
          _incomingMessageTravelDotTrigger += 1;
        });
      }
    }
  }

  @override
  void didPopNext() {
    // We became visible again after a pushed route was popped (e.g. back from
    // search results). Re-attempt tutorials that depend on the main AppBar.
    _scheduleMaybeShowNotificationsBellTutorial();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isAuthenticated) {
      unawaited(ActiveSearchAlertsState().refresh());
    }
  }

  // Check authentication status and adjust current index if needed
  Future<void> _checkAuthenticationStatus() async {
    try {
      final wasAuthenticated = _isAuthenticated;
      final authState = AuthenticationState();

      // Just read the current state without refreshing (to avoid infinite loops)
      _isAuthenticated = authState.isAuthenticated;

      // Only log when authentication state changes
      if (wasAuthenticated != _isAuthenticated) {
        debugPrint(
          "🔐 AppRouter: Auth state changed - was: $wasAuthenticated, now: $_isAuthenticated",
        );
        debugPrint(
          "🔐 AppRouter: Firebase user: ${FirebaseAuth.instance.currentUser?.email ?? "null"}",
        );

        // If user logged out (was authenticated but now is not), redirect to home
        if (wasAuthenticated && !_isAuthenticated) {
          debugPrint(
            "🔐 AppRouter: User logged out, redirecting to home screen",
          );

          // Pop any pushed screens (like ProfileScreen) and redirect to home
          if (mounted && Navigator.of(context).canPop()) {
            debugPrint("🔐 AppRouter: Popping pushed screens...");
            Navigator.of(context).pop();
          }

          // Redirect to home screen
          setState(() {
            _currentIndex = 0; // Redirect to home screen
          });
        } else if (!wasAuthenticated && _isAuthenticated) {
          debugPrint("🔐 AppRouter: User logged in, forcing UI rebuild");
          setState(() {
            // Force UI rebuild to update navigation bar
          });
          _maybeShowProfileCompletionPrompt();
        }

        unawaited(ActiveSearchAlertsState().refresh());
      }

      // Check if we need to redirect to auth wizard
      if (!_isAuthenticated && mounted) {
        // Check if we"re on a screen that requires authentication
        if (_currentIndex == 1) {
          // Favorites screen
          debugPrint(
            "🔐 AppRouter: User on favorites screen but not authenticated, redirecting to auth wizard",
          );
          _redirectToAuthWizard();
        } else if (_currentIndex == 2) {
          // Messages screen
          debugPrint(
            "🔐 AppRouter: User on messages screen but not authenticated, redirecting to auth wizard",
          );
          _redirectToAuthWizard();
        } else if (_currentIndex == 3) {
          // Create Listing screen
          debugPrint(
            "🔐 AppRouter: User on create listing screen but not authenticated, redirecting to auth wizard",
          );
          _redirectToAuthWizard();
        }
      }
    } catch (e) {
      debugPrint("❌ Auth check error: $e");
      _isAuthenticated = false;
      unawaited(ActiveSearchAlertsState().refresh());
    }
  }

  Future<void> _maybeShowProfileCompletionPrompt() async {
    if (_profileCompletionPromptShown || _checkingProfileCompletion) {
      return;
    }
    if (!_isAuthenticated) return;

    // Don't prompt blocked users - they can't save profile edits (403)
    if (await SessionManager.getIsUserBlocked()) return;

    _checkingProfileCompletion = true;
    try {
      var profile = await SessionManager.getCachedUserProfile();
      profile ??= await getIt<IUserProfileService>().getCurrentUserProfile();
      await SessionManager.storeUserProfile(profile);

      ProfileCompletionState().updateFromProfile(profile);

      final completionPercent = ProfileCompletionState.completionPercent(profile);
      if (completionPercent >= 100) return;

      _profileCompletionPromptShown = true;
      if (!mounted) return;
      final profileToShow = profile;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showProfileCompletionPrompt(context, completionPercent, profileToShow);
      });
    } catch (_) {
      // Ignore failures to avoid blocking navigation.
    } finally {
      _checkingProfileCompletion = false;
    }
  }

  void _showProfileCompletionPrompt(
    BuildContext context,
    int completionPercent,
    UserProfile profile,
  ) {
    final missingKeys = ProfileCompletionState.getMissingFields(profile);
    final missingLabels = missingKeys.map(_labelForMissingProfileFieldKey).toList()
      ..removeWhere((e) => e.trim().isEmpty);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ListenableBuilder(
                    listenable: ThemeState(),
                    builder: (context, child) {
                      final themeState = ThemeState();
                      final iconColor =
                          themeState.isBlueTheme ? Colors.white : Colors.black;
                      return ThemeIcon(
                        Icons.person,
                        color: iconColor,
                        size: 22,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      L10n.get("complete_profile_prompt_title"),
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                L10n.get("complete_profile_prompt_body"),
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionPercent / 100,
                  minHeight: 8,
                  backgroundColor: Theme.of(sheetContext)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeState().isBlueTheme
                        ? Colors.white
                        : Theme.of(sheetContext).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$completionPercent%",
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (missingLabels.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  L10n.get("missing_fields_title"),
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  // Usually only 1 field (e.g. 94%), but keep it robust.
                  missingLabels.join(", "),
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                      },
                      child: Text(
                        L10n.get("complete_profile_prompt_later"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        if (!mounted) return;
                        final profile =
                            await SessionManager.getCachedUserProfile();
                        if (profile == null || !mounted) return;
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(profile: profile),
                          ),
                        );
                        if ((result ?? false) && mounted) {
                          setState(() {});
                        }
                      },
                      child: Text(
                        L10n.get("complete_profile_prompt_cta"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Map `ProfileCompletionState.getMissingFields()` keys to localized field labels.
  /// Keep in sync with `ProfileCompletionState.getMissingFields`.
  static String _labelForMissingProfileFieldKey(String key) {
    switch (key) {
      case "name":
        return L10n.get("name", fallback: "Name");
      case "gender":
        return L10n.get("gender", fallback: "Gender");
      case "region":
        return L10n.get("im_from", fallback: "Region");
      case "university":
        return L10n.get("university", fallback: "University");
      case "aboutMe":
        return L10n.get("about_me", fallback: "About me");
      case "telegram":
        return L10n.get("telegram", fallback: "Telegram");
      case "employed":
        return L10n.get("employed", fallback: "Employed");
      case "cleanliness":
        return L10n.get("cleanliness", fallback: "Cleanliness");
      case "noiseLevel":
        return L10n.get("noise_level", fallback: "Noise level");
      case "sociability":
        return L10n.get("sociability", fallback: "Sociability");
      case "guestsAllowed":
        return L10n.get("guests_allowed", fallback: "Guests allowed");
      case "smokingPreference":
        return L10n.get("smoking_preference", fallback: "Smoking");
      case "alcoholPreference":
        return L10n.get("alcohol_preference", fallback: "Alcohol");
      case "cookingHabits":
        return L10n.get("cooking_habits", fallback: "Cooking habits");
      case "petsPreference":
        return L10n.get("pets_preference", fallback: "Pets preference");
      case "wakeupTime":
        return L10n.get("wakeup_time", fallback: "Wake-up time");
      case "sleepTime":
        return L10n.get("sleep_time", fallback: "Sleep time");
      default:
        return key;
    }
  }

  // Redirect to auth wizard
  void _redirectToAuthWizard() {
    if (mounted) {
      context.pushReplaceAuthWizard().then((_) {
        // After successful authentication, ensure we're on home screen
        if (mounted) {
          setState(() {
            _currentIndex = 0; // Navigate to home screen
          });
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Tab screen memoization
  //
  // `build()` of MainNavigation is called whenever `setState` fires — and
  // that happens for many reasons unrelated to the active tab (auth state
  // changes, profile-completion ticks, unread-badge pulses, etc.). Previously
  // `_getScreens()` re-allocated all four tab widgets on every one of those
  // rebuilds. The element tree reconciled them correctly, so blocs survived,
  // but Flutter still had to hash + compare four fresh widget instances per
  // rebuild.
  //
  // Strategy:
  //   - Tabs whose constructor args don't depend on mutable state (Favorites,
  //     Create Listing) are built ONCE in initState and stored as `late final`
  //     fields. Identity-stable, so Flutter's short-circuit on `oldWidget ==
  //     newWidget` kicks in immediately.
  //   - Tabs whose args DO depend on `_currentIndex` (Home, Messages) must be
  //     rebuilt so `isHomeTabActive` / `mainTabSelected` stay accurate — those
  //     flags drive `didUpdateWidget` logic (tutorials, conversation refetch)
  //     which breaks if we feed them stale values.
  // ---------------------------------------------------------------------------
  late final Widget _favoritesTab = const FavoritesScreen();
  late final Widget _createListingTab = BlocProvider(
    create: (_) => SubwayStationsBloc(getIt<ISubwayStationService>()),
    child: BlocProvider(
      create: (_) => LocationsBloc(getIt<ILocationService>()),
      child: const CreateListingScreen(),
    ),
  );

  List<Widget> _getScreens() {
    return [
      BlocProvider(
        create: (context) {
          final bloc = ListingsBloc(getIt<IListingService>());
          bloc.add(const ListingsEvent.searchListings(isRefresh: true));
          return bloc;
        },
        child: HomeScreen(isHomeTabActive: _currentIndex == 0),
      ),
      _favoritesTab,
      MessagesInboxScreen(
        showCustomHeader: false,
        mainTabSelected: _currentIndex == 2,
      ),
      _createListingTab,
    ];
  }

  /// Method to navigate to a specific index (can be called from outside).
  void navigateToIndex(int index) {
    debugPrint("🧭 MainNavigation: navigateToIndex called with index $index");
    if (mounted) {
      debugPrint(
        "🧭 MainNavigation: Setting _currentIndex from $_currentIndex to $index",
      );
      setState(() {
        _currentIndex = index;
      });
      _scheduleMaybeShowNotificationsBellTutorial();
      debugPrint(
        "🧭 MainNavigation: Navigation completed, new index: $_currentIndex",
      );
    } else {
      debugPrint("❌ MainNavigation: Widget not mounted, navigation ignored");
    }
  }

  // Get the appropriate title for the current screen
  Widget _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return L10n.text(
          "home",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      case 1:
        return L10n.text(
          "favorites_title",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      case 2:
        return L10n.text(
          "conversations",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      case 3:
        return L10n.text(
          "create_listing_title",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _maybeShowNotificationsBellTutorial() {
    if (!mounted) return;
    if (_notificationsBellTutorialShownThisSession) return;
    if (_notificationsBellTutorialPending) return;
    // Only show when the user is actually on the Home tab and the main
    // navigation route is the visible (top) route.
    if (_currentIndex != 0) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    if (!AuthenticationState().isAuthenticated) return;
    if (!ActiveSearchAlertsState().hasActiveEnabledAlerts) return;
    // Gate on the first (search) tutorial being completed so the two overlays
    // cannot race on cold start. Once the search tutorial finishes,
    // TutorialState notifies and this method is re-evaluated.
    if (!TutorialState().hasCompletedSearchTutorial) return;

    _notificationsBellTutorialPending = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var shown = false;
      try {
        // Give the app bar action time to mount.
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;

        await TutorialState().initialize();
        if (!mounted) return;
        if (TutorialState().hasCompletedNotificationsBellTutorial) return;

        for (var attempt = 0; attempt < 8; attempt++) {
          if (!mounted) return;
          if (notificationsBellTutorialKey.currentContext != null) {
            _notificationsBellTutorialShownThisSession = true;
            shown = true;
            AlertBellTutorialOverlay.show(
              context,
              alertBellKey: notificationsBellTutorialKey,
              descriptionKey: "tutorial_notifications_bell_description",
              onComplete: TutorialState().markNotificationsBellTutorialCompleted,
            );
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
      } finally {
        // If we failed to show (e.g. bell target not mounted yet), allow a
        // later retry when state changes again or on subsequent refreshes.
        if (mounted && !shown) {
          _notificationsBellTutorialPending = false;
        } else {
          _notificationsBellTutorialPending = false;
        }
      }
    });
  }

  /// Shared 3D chrome for app bar icon-only actions (drawer, notifications, profile).
  Widget _threeDAppBarIconButton({
    required IconData iconData,
    required VoidCallback onPressed,
    required String semanticsLabel,
    double iconSize = 26,
    BorderRadius? borderRadius,
    Widget? iconWidget,
    EdgeInsets padding = const EdgeInsets.all(6),
    double contentSlotSize = 28,
  }) {
    return ThreeDAppBarIconButton(
      iconData: iconData,
      onPressed: onPressed,
      semanticsLabel: semanticsLabel,
      iconSize: iconSize,
      borderRadius: borderRadius,
      iconWidget: iconWidget,
      padding: padding,
      contentSlotSize: contentSlotSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final useLiquidGlassAppBar = themeState.isBlueTheme || themeState.isLightTheme;
        final appBarTheme = Theme.of(context).appBarTheme;
        return Scaffold(
          extendBodyBehindAppBar: useLiquidGlassAppBar,
          appBar: UydoshAppBar(
            backgroundColor:
                useLiquidGlassAppBar
                    ? Colors.transparent
                    : appBarTheme.backgroundColor,
            surfaceTintColor:
                useLiquidGlassAppBar ? Colors.transparent : appBarTheme.surfaceTintColor,
            elevation: useLiquidGlassAppBar ? 0 : null,
            scrolledUnderElevation: useLiquidGlassAppBar ? 0 : null,
            shadowColor:
                useLiquidGlassAppBar ? Colors.transparent : appBarTheme.shadowColor,
            forceMaterialTransparency: useLiquidGlassAppBar,
            flexibleSpace:
                useLiquidGlassAppBar
                    ? const LiquidGlassAppBarFlexibleSpace()
                    : null,
            foregroundColor: appBarTheme.foregroundColor,
        title: _getAppBarTitle(),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Align(
            alignment: Alignment.center,
            child: Builder(
              builder: (scaffoldContext) {
                return _threeDAppBarIconButton(
                  iconData: Icons.menu,
                  onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                  semanticsLabel:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ListenableBuilder(
              listenable: Listenable.merge([
                AuthenticationState(),
                ActiveSearchAlertsState(),
              ]),
              builder: (context, _) {
                final signedIn = AuthenticationState().isAuthenticated;
                final activeAlerts =
                    signedIn && ActiveSearchAlertsState().hasActiveEnabledAlerts;
                return TutorialTargetWrapper(
                  key: notificationsBellTutorialKey,
                  child: _threeDAppBarIconButton(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    iconData: activeAlerts
                        ? Icons.notifications
                        : Icons.notifications_none_outlined,
                    onPressed: () {
                      if (!AuthenticationState().isAuthenticated) {
                        context.pushReplaceAuthWizard();
                        return;
                      }
                      context.pushNotifications();
                    },
                    semanticsLabel: activeAlerts
                        ? "${L10n.get("menu_notifications")}, ${L10n.get("notifications_appbar_semantics_active_alerts")}"
                        : L10n.get("menu_notifications"),
                  ),
                );
              },
            ),
          ),
          // Profile button on the right side with proper margin
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TutorialTargetWrapper(
              key: profileIconTutorialKey,
              child: ListenableBuilder(
                listenable: AuthenticationState(),
                builder: (context, child) {
                  final isAuthenticated = AuthenticationState().isAuthenticated;

                  // Show themed circle when user is not authenticated
                  if (!isAuthenticated) {
                    return _threeDAppBarIconButton(
                      borderRadius: const BorderRadius.all(Radius.circular(999)),
                      iconData: Icons.person_outline,
                      onPressed: () {
                        context.pushReplaceAuthWizard().then((_) {
                          if (mounted) {
                            setState(() {
                              _currentIndex = 0;
                            });
                          }
                        });
                      },
                      semanticsLabel: L10n.get("profile"),
                      iconSize: 28,
                    );
                  }

                  // Show just the person icon (no circle) when user is authenticated
                  return ListenableBuilder(
                    listenable: Listenable.merge([
                      ThemeState(),
                      ProfileCompletionState(),
                    ]),
                    builder: (context, child) {
                      final needsCompletion =
                          ProfileCompletionState().needsProfileCompletion;
                      final hasAvatar =
                          resolveAvatarUrl(
                            ProfileCompletionState().cachedAvatarUrl,
                          ) !=
                          null;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _threeDAppBarIconButton(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(999),
                            ),
                            iconData: Icons.person_outline,
                            onPressed: () => context.pushProfile(),
                            semanticsLabel: L10n.get("profile"),
                            iconSize: 28,
                            padding:
                                hasAvatar
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.all(6),
                            contentSlotSize: hasAvatar ? 40 : 28,
                            iconWidget: AppBarProfileIcon(
                              iconSize: hasAvatar ? 40 : 28,
                              iconColor:
                                  ThemeState().isBlueTheme
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                          if (needsCompletion)
                            Positioned(
                              right: 5,
                              top: 22,
                              child: BlinkingDotWidget(
                                color: AppColors.success,
                                size: 12,
                                duration: const Duration(milliseconds: 750),
                                borderColor:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade300,
                                borderWidth: 2,
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
          drawer: const BurgerMenuWidget(),
          onDrawerChanged: (isOpened) {
            if (isOpened) HapticFeedbackUtils.impact();
          },
          body: IndexedStack(index: _currentIndex, children: _getScreens()),
          bottomNavigationBar: ListenableBuilder(
            listenable: UnreadMessagesState(),
            builder: (context, child) {
              return CustomCurvedNavigationBar(
                currentIndex: _currentIndex,
                navigationKey: _bottomNavigationKey,
                isAuthenticated: _isAuthenticated,
                hasUnreadMessages: UnreadMessagesState().hasUnreadMessages,
                incomingMessageTravelDotTrigger: _incomingMessageTravelDotTrigger,
                onTap: (index) {
                  HapticFeedbackUtils.impact();

                  // Handle authentication requirements
                  if ((index == 1 || index == 2) && !_isAuthenticated) {
                    // Favorites and Conversations require authentication
                    return; // Don"t navigate, stay on current screen
                  }

                  // Allow navigation to all tabs
                  setState(() {
                    _currentIndex = index;
                  });
                  _scheduleMaybeShowNotificationsBellTutorial();
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Global key to access MainNavigation state
final GlobalKey<MainNavigationState> mainNavigationKey =
    GlobalKey<MainNavigationState>();
