import "dart:async" show unawaited;

import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart" show AppColors;
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/base/services/google_avatar_backend_sync.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/presentation/screens/gig/publish_gig_screen.dart"
    show GigPublishMode;
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/listing_navigation.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/main.dart" show routeObserver;
import "package:uy_dosh/presentation/router/app_router_keys.dart";
import "package:uy_dosh/presentation/router/main_navigation_widgets.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_screen.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/burger_menu_widget.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    final requestedIndex = widget.initialIndex;
    if (requestedIndex == 3) {
      _currentIndex = 0;
    } else {
      _currentIndex = requestedIndex.clamp(0, 2);
    }
    getIt<IPushNotificationService>().markNavigationShellReady();

    // Handle deep link and push notification tap from cold start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        getIt<DeepLinkService>().handlePendingLink();
        getIt<IPushNotificationService>().handlePendingNotificationTap();
        if (requestedIndex == 3 && _isAuthenticated) {
          context.pushCreateListing();
        }
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
      final googlePhoto = await SessionManager.getGooglePhotoUrl();
      ProfileCompletionState().updateGooglePhotoUrl(googlePhoto);

      // 1) Instant-prime from cache so the UI has completion state without
      //    waiting for the network.
      final cached = await SessionManager.getCachedUserProfile();
      if (cached != null && mounted) {
        ProfileCompletionState().updateFromProfile(cached);
        // Warm the image cache before the AppBar paints with the new URL,
        // so the profile icon doesn't flash through the fallback glyph on
        // the first frame after the cached profile arrives.
        precacheCurrentUserAvatar(
          context,
          ProfileCompletionState().effectiveAvatarUrl,
        );
      }

      // 2) Always refresh from the server so stale cached profiles (e.g.
      //    saved through a flow that didn't also write to SessionManager)
      //    self-heal on the next app launch.
      final fresh = await getIt<IUserProfileService>().getCurrentUserProfile();
      await SessionManager.storeUserProfile(fresh);
      final role = await SessionManager.getUserRole();
      unawaited(
        getIt<AppAnalyticsService>().syncUserProfileProperties(
          profile: fresh,
          role: role,
        ),
      );
      if (mounted) {
        ProfileCompletionState().updateFromProfile(fresh);
        precacheCurrentUserAvatar(
          context,
          ProfileCompletionState().effectiveAvatarUrl,
        );
      }
      await syncGoogleAvatarToBackendIfMissing(existingProfile: fresh);
    } catch (_) {
      // Ignore - profile will be loaded when user opens profile/burger menu
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    getIt<IPushNotificationService>().markNavigationShellNotReady();
    AuthenticationState().removeListener(_authStateListener);
    UnreadMessagesState().removeListener(_unreadMessagesListener);
    ActiveSearchAlertsState()
        .removeListener(_maybeShowNotificationsBellTutorial);
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
          unawaited(
            SearchFiltersState().hydrateFromBackendForCurrentUser().then(
                  (_) =>
                      SearchFiltersState().ensureDefaultFiltersBuiltAndSaved(),
                ),
          );
          unawaited(
            PriceDisplaySettingsState().hydrateFromBackendForCurrentUser(),
          );
        }

        unawaited(ActiveSearchAlertsState().refresh());
      }

      // Auth-gate the protected tabs. Logical indices:
      //   0 = Housing
      //   1 = Favorites while Services is hidden; Services when re-enabled
      //   2 = Messages (auth required)
      if (!_isAuthenticated && mounted && _currentIndex == 2) {
        debugPrint(
          "🔐 AppRouter: User on messages screen but not authenticated, redirecting to auth wizard",
        );
        _redirectToAuthWizard();
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
      if (mounted) {
        precacheCurrentUserAvatar(
          context,
          ProfileCompletionState().effectiveAvatarUrl,
        );
      }

      final completionPercent =
          ProfileCompletionState.completionPercent(profile);
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
    // Split into essentials vs. nice-to-have lifestyle prefs so the prompt
    // can lead with what actually matters and collapse the long tail. See
    // [ProfileCompletionState.essentialFieldKeys].
    final essentialKeys = missingKeys
        .where(ProfileCompletionState.essentialFieldKeys.contains)
        .toList();
    final lifestyleKeys = missingKeys
        .where((k) => !ProfileCompletionState.essentialFieldKeys.contains(k))
        .toList();

    String labelsFor(Iterable<String> keys) => keys
        .map(_labelForMissingProfileFieldKey)
        .where((e) => e.trim().isNotEmpty)
        .join(", ");

    // When essentials are missing, show all of them (typically 1–4) and
    // collapse lifestyle into a "+ N more" footnote. When only lifestyle
    // fields remain, show the first few and collapse the rest the same way.
    const lifestylePreviewCap = 3;
    final String primaryLabels;
    final int hiddenCount;
    if (essentialKeys.isNotEmpty) {
      primaryLabels = labelsFor(essentialKeys);
      hiddenCount = lifestyleKeys.length;
    } else {
      primaryLabels = labelsFor(lifestyleKeys.take(lifestylePreviewCap));
      hiddenCount = (lifestyleKeys.length - lifestylePreviewCap)
          .clamp(0, lifestyleKeys.length);
    }
    final hasAnyMissing = primaryLabels.isNotEmpty || hiddenCount > 0;

    showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassBottomSheetSurface(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flutter's default drag handle is drawn on the sheet's
                    // Material, but we render glass. Draw our own so it reads
                    // correctly on the translucent surface.
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ListenableBuilder(
                          listenable: ThemeState(),
                          builder: (context, child) {
                            final themeState = ThemeState();
                            final iconColor = themeState.isBlueTheme
                                ? Colors.white
                                : theme.colorScheme.onSurface;
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      L10n.get("complete_profile_prompt_body"),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completionPercent / 100,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeState().isBlueTheme
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$completionPercent%",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasAnyMissing) ...[
                      const SizedBox(height: 10),
                      Text(
                        L10n.get("missing_fields_title"),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (primaryLabels.isNotEmpty)
                        Text(
                          primaryLabels,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (hiddenCount > 0) ...[
                        if (primaryLabels.isNotEmpty) const SizedBox(height: 4),
                        Text(
                          L10n.getWithParams(
                            "complete_profile_prompt_more",
                            params: {"count": hiddenCount.toString()},
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GhostButton(
                            width: double.infinity,
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text(
                              L10n.get("complete_profile_prompt_later"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: PrimaryButton(
                            width: double.infinity,
                            onPressed: () async {
                              Navigator.of(sheetContext).pop();
                              if (!mounted) return;
                              final profile =
                                  await SessionManager.getCachedUserProfile();
                              if (profile == null || !mounted) return;
                              final result =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfileScreen(profile: profile),
                                ),
                              );
                              if ((result ?? false) && mounted) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              L10n.get("complete_profile_prompt_cta"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
        return L10n.get("work", fallback: "Work");
      case "cleanliness":
        return L10n.get("cleanliness", fallback: "Cleanliness");
      case "noiseLevel":
        return L10n.get("noise_level", fallback: "Noise level");
      case "sociability":
        return L10n.get("sociability", fallback: "Sociability");
      case "guestsAllowed":
        return L10n.get("guests", fallback: "Guests");
      case "smokingPreference":
        return L10n.get("smoking_preference", fallback: "Smoking");
      case "alcoholPreference":
        return L10n.get("alcohol_preference", fallback: "Alcohol");
      case "cookingHabits":
        return L10n.get("cooking_habits", fallback: "Cooking");
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
  // `_getScreens()` re-allocated all three tab widgets on every one of those
  // rebuilds. The element tree reconciled them correctly, so blocs survived,
  // but Flutter still had to hash + compare three fresh widget instances per
  // rebuild.
  //
  // Strategy:
  //   - Tabs whose constructor args don't depend on mutable state can be built
  //     once, but data-heavy tabs receive a visibility flag so they can defer
  //     their initial fetch while IndexedStack keeps them mounted off-screen.
  //
  // Logical indices: 0=Housing, 1=Favorites/Services, 2=Messages.
  // Create flows are pushed routes via "+" / drawer, not tabs.
  // ---------------------------------------------------------------------------

  List<Widget> _getScreens() {
    final screens = <Widget>[
      // Home uses the [ListingsBloc] from [AppRouter.buildMainNavigation] so
      // the shell AppBar count and the feed stay on the same bloc instance.
      HomeScreen(isHomeTabActive: _currentIndex == 0),
      AppConfig.servicesFeatureEnabled
          ? GigHubScreen(embedded: true, tabVisible: _currentIndex == 1)
          : FavoritesScreen(embedded: true, tabVisible: _currentIndex == 1),
      MessagesInboxScreen(
        showCustomHeader: false,
        mainTabSelected: _currentIndex == 2,
      ),
    ];
    // IndexedStack keeps off-screen tabs mounted. Wrap each tab in TickerMode
    // so repeating animations/controllers do not burn CPU/GPU when hidden.
    return List<Widget>.generate(
      screens.length,
      (i) => TickerMode(enabled: _currentIndex == i, child: screens[i]),
      growable: false,
    );
  }

  /// Open the chooser sheet for the bottom-bar "+" button. Housing and gig
  /// publish both open as pushed routes (no create tab in the shell).
  ///
  /// The bar's tap is intercepted by [CustomCurvedNavigationBar.onCreatePressed]
  /// so dismissing the sheet without picking leaves the active tab untouched.
  void _showCreateChoiceSheet() {
    HapticFeedbackUtils.impact();
    if (!_isAuthenticated) {
      _redirectToAuthWizard();
      return;
    }
    showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return GlassBottomSheetSurface(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      L10n.get("create_choice_title"),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CreateChoiceTile(
                    emoji: "👥",
                    title: L10n.get("listing_type_roommate_needed"),
                    subtitle: L10n.get(
                      "create_choice_roommate_needed_subtitle",
                    ),
                    onTap: () {
                      HapticFeedbackUtils.impact();
                      Navigator.of(sheetContext).pop();
                      if (!mounted) return;
                      context.pushCreateListing(listingTypeId: 2);
                    },
                  ),
                  const SizedBox(height: 8),
                  CreateChoiceTile(
                    emoji: "🏠",
                    title: L10n.get("listing_type_room_needed"),
                    subtitle: L10n.get(
                      "create_choice_room_needed_subtitle",
                    ),
                    onTap: () {
                      HapticFeedbackUtils.impact();
                      Navigator.of(sheetContext).pop();
                      if (!mounted) return;
                      context.pushCreateListing(listingTypeId: 1);
                    },
                  ),
                  if (AppConfig.servicesFeatureEnabled) ...[
                    const SizedBox(height: 8),
                    CreateChoiceTile(
                      emoji: "🛠",
                      title: L10n.get("create_choice_service"),
                      subtitle: L10n.get("create_choice_service_subtitle"),
                      onTap: () {
                        HapticFeedbackUtils.impact();
                        Navigator.of(sheetContext).pop();
                        if (!mounted) return;
                        context.pushPublishGig(
                          initialMode: GigPublishMode.service,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Method to navigate to a specific index (can be called from outside).
  /// Index 3 is legacy: opens the housing create listing route instead of a tab.
  void navigateToIndex(int index) {
    debugPrint("🧭 MainNavigation: navigateToIndex called with index $index");
    if (!mounted) {
      debugPrint("❌ MainNavigation: Widget not mounted, navigation ignored");
      return;
    }
    if (index == 3) {
      context.pushCreateListing();
      return;
    }
    final tabIndex = index.clamp(0, 2);
    debugPrint(
      "🧭 MainNavigation: Setting _currentIndex from $_currentIndex to $tabIndex",
    );
    setState(() {
      _currentIndex = tabIndex;
    });
    _scheduleMaybeShowNotificationsBellTutorial();
    debugPrint(
      "🧭 MainNavigation: Navigation completed, new index: $_currentIndex",
    );
  }

  // Get the appropriate title for the current screen
  Widget _getAppBarTitle() {
    final titleStyle = Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        );
    switch (_currentIndex) {
      case 0:
        return HomeListingsAppBarTitle(titleStyle: titleStyle);
      case 1:
        return L10n.text(
          AppConfig.servicesFeatureEnabled ? "menu_gigs" : "favorites_title",
          style: titleStyle,
        );
      case 2:
        return L10n.text("conversations", style: titleStyle);
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
              onComplete:
                  TutorialState().markNotificationsBellTutorialCompleted,
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
    bool neumorphicSoftUi = false,
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
      neumorphicSoftUi: neumorphicSoftUi,
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final useLiquidGlassAppBar =
            themeState.isBlueTheme || themeState.isLightTheme;
        final appBarTheme = Theme.of(context).appBarTheme;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: themeState.backgroundColor,
          extendBodyBehindAppBar: useLiquidGlassAppBar,
          // Draw bodies under the curved bar so notch/alpha tints show cards and
          // feed — not only [themeState.backgroundColor] (same 0xFF1E3A5F as primary).
          extendBody: themeState.isBlueTheme,
          appBar: UydoshAppBar(
            backgroundColor: useLiquidGlassAppBar
                ? liquidGlassAppBarMaterialColor(context)
                : appBarTheme.backgroundColor,
            surfaceTintColor: useLiquidGlassAppBar
                ? Colors.transparent
                : appBarTheme.surfaceTintColor,
            elevation: useLiquidGlassAppBar ? 0 : null,
            scrolledUnderElevation: useLiquidGlassAppBar ? 0 : null,
            shadowColor: useLiquidGlassAppBar
                ? Colors.transparent
                : appBarTheme.shadowColor,
            forceMaterialTransparency: useLiquidGlassAppBar,
            flexibleSpace: useLiquidGlassAppBar
                ? const LiquidGlassAppBarFlexibleSpace()
                : null,
            foregroundColor: appBarTheme.foregroundColor,
            title: _getAppBarTitle(),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Align(
                alignment: Alignment.center,
                child: _threeDAppBarIconButton(
                  iconData: Icons.menu,
                  onPressed: _openDrawer,
                  semanticsLabel:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              ),
            ),
            actions: [
              ListenableBuilder(
                listenable: Listenable.merge([
                  AuthenticationState(),
                  ActiveSearchAlertsState(),
                ]),
                builder: (context, _) {
                  final signedIn = AuthenticationState().isAuthenticated;
                  if (!signedIn) return const SizedBox.shrink();

                  final activeAlerts =
                      ActiveSearchAlertsState().hasActiveEnabledAlerts;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: TutorialTargetWrapper(
                      key: notificationsBellTutorialKey,
                      child: _threeDAppBarIconButton(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                        // iconData isn't used when iconWidget is provided; keep a stable default.
                        iconData: Icons.notifications_none_outlined,
                        iconWidget: NotificationsBellIcon(active: activeAlerts),
                        onPressed: () {
                          context.pushNotifications();
                        },
                        semanticsLabel: activeAlerts
                            ? "${L10n.get("menu_notifications")}, ${L10n.get("notifications_appbar_semantics_active_alerts")}"
                            : L10n.get("menu_notifications"),
                      ),
                    ),
                  );
                },
              ),
              // Profile button on the right side with proper margin
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TutorialTargetWrapper(
                  key: profileIconTutorialKey,
                  child: ListenableBuilder(
                    listenable: AuthenticationState(),
                    builder: (context, child) {
                      final isAuthenticated =
                          AuthenticationState().isAuthenticated;

                      // Show themed circle when user is not authenticated
                      if (!isAuthenticated) {
                        return _threeDAppBarIconButton(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(999)),
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
                          final hasAvatar = resolveAvatarUrl(
                                ProfileCompletionState().effectiveAvatarUrl,
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
                                padding: hasAvatar
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.all(6),
                                contentSlotSize:
                                    hasAvatar ? kAppBarAvatarContentSize : 28,
                                iconWidget: AppBarProfileIcon(
                                  iconSize:
                                      hasAvatar ? kAppBarAvatarContentSize : 28,
                                  iconColor: ThemeState().isBlueTheme
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (needsCompletion)
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
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
                incomingMessageTravelDotTrigger:
                    _incomingMessageTravelDotTrigger,
                onCreatePressed: _showCreateChoiceSheet,
                onTap: (index) {
                  HapticFeedbackUtils.impact();

                  // Messages (2) is gated inside [CustomCurvedNavigationBar].

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
