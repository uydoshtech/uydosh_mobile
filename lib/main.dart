// Firebase imports
import "dart:async" show unawaited;
import "dart:ui" show PlatformDispatcher;

import "package:firebase_core/firebase_core.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart" show kDebugMode, kIsWeb;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:uy_dosh/base/config/client_custom_camera_config.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart"
    show AppColors, BlueThemeColors, LightThemeColors;
import "package:uy_dosh/base/firebase/app_check_bootstrap.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/log_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/app_badge_service.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/sound_effects_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/firebase_options.dart";
import "package:uy_dosh/l10n/app_localizations.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/onboarding/onboarding_screen.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/animated_svg_logo.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

// Global RouteObserver for handling navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Flag to skip splash screen - automatically skip when running in Chrome/web
bool get kSkipSplashScreen => kIsWeb;

// TEMP (for testing): make home disappear and show the 3D scan welcome page.
const bool kShowRoomPlanWelcomeInsteadOfHome = false;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Image cache budget. Flutter's default is 1000 images / 100MB. We cap
    // count at 400 (plenty for a feed + detail browsing) but keep 100MB of
    // bytes so users browsing many high-res listing photos don't evict
    // currently-on-screen images and trigger a re-decode storm.
    imageCache.maximumSize = 400;
    imageCache.maximumSizeBytes = 100 << 20; // 100 MB

    // Initialize Firebase
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        logger.d("Firebase initialized successfully");
      } else {
        logger.d("Firebase already initialized, continuing...");
      }
    } catch (e) {
      if (e.toString().contains("duplicate-app")) {
        logger.d("Firebase already exists, continuing...");
      } else {
        logger.d("Firebase initialization error: $e");
        rethrow;
      }
    }

    // Activate App Check BEFORE any Firebase Auth call (phone verification
    // requires it). Safe to await — non-fatal if it fails.
    await AppCheckBootstrap.activate();

    // Initialize Crashlytics (iOS/Android only; not supported on web)
    if (!kIsWeb) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        FlutterError.presentError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Configure logging based on environment
    LogConfig.instance.printConfig();

    // Dependency injection must be configured before any startup tasks that use GetIt
    // (e.g. server-backed client config fetches).
    await configureDependencies();

    // Keep the OS app icon badge in sync with unread messages.
    // This will get corrected by server-backed refreshes (e.g. inbox load) shortly after launch.
    void syncBadge() {
      getIt<IAppBadgeService>().setBadgeCount(UnreadMessagesState().unreadCount);
    }
    UnreadMessagesState().addListener(syncBadge);
    syncBadge();

    // Split startup into (must-block-first-frame) and (deferrable) work:
    //
    //   Critical path — needed for correct rendering on the very first build:
    //     * LanguageState   (splash subtitle localization)
    //     * ThemeState      (splash gradient + colors)
    //     * AuthenticationState (drives _getInitialScreen / BlocAuthListener)
    //     * OnboardingState     (drives _getInitialScreen decision)
    //
    //   Deferred — consumed only on later screens, or in response to user
    //   interaction. Pushed to `addPostFrameCallback` so the first paint
    //   happens sooner (measurable improvement on slow devices + web).
    await Future.wait([
      LanguageState().initialize(),
      AuthenticationState().initialize(),
      OnboardingState().initialize(),
      ThemeState().initialize(),
    ]);
    // Kick off the remote-config loaders now but don't await them. They
    // resolve asynchronously and their consumers already tolerate the
    // default/unloaded shape until the first fetch returns.
    unawaited(ClientGeminiListingUiConfig.load());
    unawaited(ClientLidarRoomScanConfig.load());
    unawaited(ClientCustomCameraConfig.load());
    // Local SharedPreferences reads — cheap, but still off the critical path.
    unawaited(TutorialState().initialize());
    unawaited(TooltipsState().initialize());
    unawaited(HapticFeedbackState().initialize());
    unawaited(SoundEffectsState().initialize());
    unawaited(AnimationSettingsState().initialize());
    unawaited(SearchFiltersState().initialize());

    logger.d(
      "🔐 Main: AuthenticationState initialized. Current status: ${AuthenticationState().isAuthenticated}",
    );

    // Force refresh authentication status after a delay to ensure Firebase is ready
    Future.delayed(const Duration(seconds: 2), () {
      logger.d("🔐 Main: Force refreshing authentication status...");
      AuthenticationState().refreshAuthenticationStatus();
    });

    // Display saved preferences in console
    logger.d("=== APP STARTUP - SAVED PREFERENCES ===");
    logger.d(
      "🌍 Language: ${LanguageState().currentLanguage} (${LanguageDisplayHelper.getLanguageDisplayName(LanguageState().currentLanguage)})",
    );
    logger.d(
      "🎨 Theme: ${ThemeState().currentTheme} (${ThemeState().currentThemeDisplayName})",
    );
    logger.d(
      '🔐 Authentication: ${AuthenticationState().isAuthenticated ? "AUTHENTICATED" : "NOT AUTHENTICATED"}',
    );
    logger.d(
      '🎓 Onboarding: ${OnboardingState().showOnboarding ? "ENABLED" : "DISABLED"}',
    );
    logger.d(
      '📳 Haptics: ${HapticFeedbackState().isEnabled ? "ENABLED" : "DISABLED"}',
    );
    logger.d(
      '🔊 Sound effects: ${SoundEffectsState().isEnabled ? "ENABLED" : "DISABLED"}',
    );
    logger.d(
      "🔍 Search Filters: listingType=${SearchFiltersState().selectedListingTypeId}, location=${SearchFiltersState().selectedLocationIndex}, line=${SearchFiltersState().selectedSubwayLine}, station=${SearchFiltersState().selectedStationIndex}",
    );
    logger.d("========================================");

    // Bloc.observer = AppBlocObserver.instance(); // Disabled to reduce logging

    getIt<AppAnalyticsService>().logAppOpened(source: "cold_start");

    final navigatorKey = GlobalKey<NavigatorState>();
    getIt.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);

    // Register DeepLinkService synchronously (cheap) but defer its actual
    // initialize() call to after the first frame — it sets up platform
    // channels / stream listeners and isn't needed until the user navigates.
    final deepLinkService = DeepLinkService(navigatorKey: navigatorKey);
    getIt.registerSingleton<DeepLinkService>(deepLinkService);

    // Defer expensive post-startup side-effects (push notifications, deep
    // link wiring, analytics user-id hydration) until the splash/first
    // screen is already painting. Keeps the cold-start critical path short.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb) {
        try {
          await getIt<IPushNotificationService>().initialize();
          if (AuthenticationState().isAuthenticated) {
            unawaited(
              getIt<IPushNotificationService>().registerTokenWithBackend(),
            );
          }
        } catch (e) {
          logger.d("Push notification init failed: $e");
        }
        unawaited(deepLinkService.initialize());
      }
      // Warm up UI sound effects so the first refresh/like has no latency.
      unawaited(SoundService().preload());
      if (AuthenticationState().isAuthenticated) {
        try {
          final userId = await SessionManager.getBackendUserId();
          if (userId != null) {
            unawaited(
              getIt<AppAnalyticsService>().setUserId(userId.toString()),
            );
          }
        } catch (e) {
          logger.d("Analytics userId hydrate failed: $e");
        }
      }
    });

    runApp(MyApp(navigatorKey: navigatorKey));
  } catch (e, stackTrace) {
    logger.d("Error during app initialization: $e");
    logger.d("Stack trace: $stackTrace");

    // Fallback to a simple app if dependency injection fails
    runApp(
      MaterialApp(
        title: "UyDosh",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.primary, // Deep primary background
        ),
        home: const Scaffold(
          body: Center(
            child: Text(
              "App initialization failed. Check console for details.",
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Cache the merged listenable so we don't allocate a new
  // `_CombiningListenable` on every `build()` (the ListenableBuilder below is
  // rebuilt on every theme/locale change).
  late final Listenable _themeAndLocaleListenable = Listenable.merge([
    ThemeState(),
    LanguageState(),
  ]);

  Widget _getInitialScreen() {
    if (kShowRoomPlanWelcomeInsteadOfHome) {
      // For testing only. The welcome UI is inside RoomPlanScanScreen.
      return const RoomPlanScanScreen(listingId: 0);
    }
    final onboardingState = OnboardingState();
    if (onboardingState.showOnboarding && !onboardingState.hasSeenOnboardingScreens) {
      return const OnboardingScreen();
    } else {
      return AppRouter.initialRoute;
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocProviders are hoisted ABOVE the theme/locale ListenableBuilder.
    // Previously they lived inside `MaterialApp.builder`, which meant the
    // provider widgets (and their subtree) were reconstructed on every
    // theme/locale tick. `BlocProvider.create` only fires once per element
    // life, so the blocs themselves were preserved — but the provider
    // widgets around them were re-instantiated and reconciled on every
    // rebuild. Hoisting removes that busywork and also keeps the provider
    // references identity-stable for anything outside the ListenableBuilder
    // that might want to read them.
    return MultiBlocProvider(
      providers: [
        BlocProvider<MessagingBloc>(
          create: (_) => MessagingBloc(
            getIt<IMessagingService>(),
            getIt<IGamificationService>(),
          ),
        ),
        BlocProvider<CurrentUserProfileBloc>(
          create: (_) =>
              CurrentUserProfileBloc(getIt<IUserProfileService>()),
        ),
      ],
      child: ListenableBuilder(
        listenable: _themeAndLocaleListenable,
        builder: (context, child) {
          return MaterialApp(
            title: "UyDosh",
            theme: ThemeState().currentThemeData,
            debugShowCheckedModeBanner: false,
            navigatorKey: widget.navigatorKey,
            navigatorObservers: [routeObserver],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: supportedLocales,
            locale: Locale(LanguageState().currentLanguage, ""),
            home: kSkipSplashScreen ? _getInitialScreen() : const SplashScreen(),
            builder: (context, child) {
              return _AchievementUnlockListener(
                navigatorKey: widget.navigatorKey,
                child: _BlocAuthListener(
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Shows achievement unlock popup when set from anywhere (e.g. MessagingBloc).
class _AchievementUnlockListener extends StatelessWidget {
  const _AchievementUnlockListener({
    required this.child,
    this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AchievementUnlockState(),
      builder: (context, _) {
        final pending = AchievementUnlockState().pendingAchievement;
        if (pending != null) {
          // Clear immediately so we don't trigger duplicate shows from other listeners
          AchievementUnlockState().clearPendingAchievement();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Use overlay context from root Navigator - the builder's context is
            // an ancestor of Navigator, so showModalBottomSheet needs a context
            // that is a descendant of Navigator (e.g. when ProfileScreen is pushed).
            final overlayContext = navigatorKey?.currentState?.overlay?.context;
            final contextToUse = overlayContext ?? context;
            AchievementUnlockBottomSheet.show(
              contextToUse,
              achievement: pending,
              onDismiss: () =>
                  AchievementUnlockState().clearPendingAchievement(),
            );
          });
        }
        return child;
      },
    );
  }
}

/// Listens to authentication state and resets shared blocs on logout.
class _BlocAuthListener extends StatefulWidget {
  const _BlocAuthListener({required this.child});

  final Widget child;

  @override
  State<_BlocAuthListener> createState() => _BlocAuthListenerState();
}

class _BlocAuthListenerState extends State<_BlocAuthListener> {
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated = AuthenticationState().isAuthenticated;
    AuthenticationState().addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    AuthenticationState().removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    final isAuthenticated = AuthenticationState().isAuthenticated;
    if (_wasAuthenticated && !isAuthenticated && mounted) {
      context.read<CurrentUserProfileBloc>().add(
            const CurrentUserProfileEvent.reset(),
          );
      context.read<MessagingBloc>().add(ClearConversations());
    }
    _wasAuthenticated = isAuthenticated;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _subtitleSlideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Text animation controllers
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedbackUtils.strongImpact();
      }
    });

    _subtitleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedbackUtils.strongImpact();
      }
    });

    // Title slides in from left with fast easing
    _titleSlideAnimation = Tween<double>(
      begin: -2.5, // Start from far outside left screen border
      end: 0.0, // End at center
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeOutCubic, // Fast easing
      ),
    );

    // Subtitle slides in from right with fast easing
    _subtitleSlideAnimation = Tween<double>(
      begin: 2.5, // Start from far outside right screen border
      end: 0.0, // End at center
    ).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeOutCubic, // Fast easing
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Be defensive: on some iOS versions a long, fully-transparent splash can
    // look like a "black screen". Show content immediately, then animate.
    _fadeController.forward();
    _titleController.forward();
    _subtitleController.forward();

    // Navigate based on onboarding preference after a short display window.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      final onboardingState = OnboardingState();
      if (onboardingState.showOnboarding && !onboardingState.hasSeenOnboardingScreens) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        context.pushReplaceMainNavigation();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  /// Get theme-specific gradient colors for the splash screen background
  List<Color> _getThemeGradientColors() {
    final themeState = ThemeState();
    if (themeState.isBlueTheme) {
      return [
        BlueThemeColors.primaryLight, // Light blue (#3A7BBF)
        BlueThemeColors.primaryDark, // Dark blue (#142A45)
      ];
    } else {
      // Light theme - use subtle gradient
      return [
        LightThemeColors.background, // White (#FFFFFF)
        LightThemeColors.surface, // Very light gray (#F8F9FA)
      ];
    }
  }

  /// Get theme-specific text colors for the splash screen
  Color _getThemeTextColor() {
    final themeState = ThemeState();
    if (themeState.isBlueTheme) {
      return AppColors.textLight; // White text for dark themes
    } else {
      return LightThemeColors.textPrimary; // Black text for light theme
    }
  }

  /// Get theme-specific secondary text color for the splash screen
  Color _getThemeSecondaryTextColor() {
    final themeState = ThemeState();
    if (themeState.isBlueTheme) {
      return AppColors.textLight70; // White with 70% opacity for dark themes
    } else {
      return LightThemeColors.textSecondary; // Medium gray for light theme
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getThemeGradientColors(),
                stops: const [0.0, 1.0],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _fadeController,
                  _titleController,
                  _subtitleController,
                ]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ), // Add top spacing
                        // Animated SVG Logo
                        const AnimatedSvgLogo(
                          size: 180, // 50% larger (120 * 1.5)
                          animationDuration: Duration(milliseconds: 4000),
                        ),
                        const SizedBox(height: 0),
                        // Title animation
                        Transform.translate(
                          offset: Offset(
                            _titleSlideAnimation.value *
                                MediaQuery.of(context).size.width *
                                0.5,
                            0,
                          ),
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Uy",
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width < 400
                                                ? 28
                                                : 32,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFF0000), // Red (255, 0, 0)
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Dosh",
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width < 400
                                                ? 28
                                                : 32,
                                        fontWeight: FontWeight.bold,
                                        color: _getThemeTextColor(),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Subtitle animation
                        Transform.translate(
                          offset: Offset(
                            _subtitleSlideAnimation.value *
                                MediaQuery.of(context).size.width *
                                0.5,
                            0,
                          ),
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: Text(
                                L10n.get("splash_subtitle"),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                          ? 12.8
                                          : 14.4, // 20% smaller (16*0.8, 18*0.8)
                                  color: _getThemeSecondaryTextColor(),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
