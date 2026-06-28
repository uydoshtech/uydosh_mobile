// Firebase imports
import "dart:async" show unawaited;
import "dart:ui" show PlatformDispatcher;

import "package:firebase_core/firebase_core.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart" show kDebugMode, kIsWeb, kReleaseMode;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:uy_dosh/base/config/client_custom_camera_config.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/config/client_home_start_view_config.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/config/client_listing_contacts_config.dart";
import "package:uy_dosh/base/config/client_phone_sign_in_config.dart";
import "package:uy_dosh/base/config/client_listing_dictation_meter_config.dart";
import "package:uy_dosh/base/config/client_map_layer_defaults_config.dart";
import "package:uy_dosh/base/state/chat_composer_draft_state.dart";
import "package:uy_dosh/base/constants/app_colors.dart"
    show AppColors, BlueThemeColors, LightThemeColors;
import "package:uy_dosh/base/firebase/app_check_bootstrap.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/log_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/navigation/top_named_route_tracker.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/app_badge_service.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/base/services/google_sign_in_warmup.dart";
import "package:uy_dosh/base/services/reinstall_session_guard.dart";
import "package:uy_dosh/base/services/remote_config_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/app_launch_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/haptic_feedback_state.dart";
import "package:uy_dosh/base/state/home_inline_search_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/sound_effects_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/lifecycle_ticker_mode.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/util/telegram_oauth_web_util.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/firebase_options.dart";
import "package:uy_dosh/l10n/app_localizations.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/conversations_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/onboarding/onboarding_screen.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/screens/permissions/location_permission_gate.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/animated_svg_logo.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/quick_splash_logo.dart";

// Global RouteObserver for handling navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Flag to skip splash screen - automatically skip when running in Chrome/web
bool get kSkipSplashScreen => kIsWeb;

// TEMP (for testing): make home disappear and show the 3D scan welcome page.
const bool kShowRoomPlanWelcomeInsteadOfHome = false;

// TEMP (for testing): show the location permission flow before anything else.
const bool kShowLocationPermissionFirst = false;

Future<void> _bootstrapSearchFiltersColdStart() async {
  await SearchFiltersState().bootstrapColdStart();
}

Future<void> _bootstrapPriceDisplayCurrencyColdStart() async {
  // Load the device-local currency first, then let the account-bound value
  // (when signed in) win so the preference follows the user across logins.
  await PriceDisplaySettingsState().initialize();
  if (!await SessionManager.isAuthenticated()) return;
  await PriceDisplaySettingsState().hydrateFromBackendForCurrentUser();
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Fire-and-forget: locking orientation is a platform-channel call that
    // takes ~5–20 ms but doesn't gate any subsequent step. Awaiting it
    // unnecessarily delays Firebase init and the rest of the cold start.
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );

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

    // Resolve runtime-tunable client config (currently: API base URL) from
    // Firebase Remote Config. Must run BEFORE `configureDependencies()` and
    // any service that issues HTTP requests, so the first network call uses
    // the freshest known URL. Internally never throws — falls back to the
    // SharedPreferences cache or the compile-time default if Firebase RC is
    // unavailable, so this cannot break startup.
    await RemoteConfigService.initialize();

    // iOS: Firebase user can persist in Keychain after uninstall while prefs
    // are cleared — sign out so we do not treat the user as logged in without
    // a backend session. Android: prefs restore is limited via backup_rules.xml.
    await ReinstallSessionGuard.clearStaleFirebaseSessionAfterReinstall();

    // Initialize Crashlytics (iOS/Android only; not supported on web)
    if (!kIsWeb) {
      FlutterError.onError = (errorDetails) {
        // Capture extra diagnostic context (widget tree path, library, error
        // category) as Crashlytics keys + log entries before recording.
        // Stripped iOS release stacks lose the information collector lines
        // that normally pinpoint the offending widget — promoting them to
        // dedicated keys keeps that data visible in the Crashlytics UI.
        _annotateCrashlyticsWithFlutterError(errorDetails);
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
    if (kDebugMode) {
      LogConfig.instance.setConsoleVerbose();
    }
    LogConfig.instance.printConfig();
    if (!kReleaseMode &&
        LogConfig.instance.uiUxLogLevel != AppLogLevel.nothing) {
      logUiUx(
        "trace enabled — open an address field and type 2+ characters",
        tag: "UI/UX",
      );
    }

    // Dependency injection must be configured before any startup tasks that use GetIt
    // (e.g. server-backed client config fetches).
    await configureDependencies();

    SessionManager.onSessionCleared = () async {
      SearchFiltersState().onSessionEnded();
      PriceDisplaySettingsState().onSessionEnded();
      await SearchFiltersState().clearAllFilters(persistRemote: false);
      await HomeInlineSearchState().clearPersistedActiveForLogout();
      await ChatComposerDraftState().clearAll();
    };

    // Keep the OS app icon badge in sync with unread messages.
    // This will get corrected by server-backed refreshes (e.g. inbox load) shortly after launch.
    void syncBadge() {
      getIt<IAppBadgeService>()
          .setBadgeCount(UnreadMessagesState().unreadCount);
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
      UiPerformancePolicy.initialize(),
      ClientHomeStartViewConfig.load(),
      ClientMapLayerDefaultsConfig.load(),
      // Determines splash variant (full animated vs quick static). Cheap:
      // a single SharedPreferences read + PackageInfo lookup.
      AppLaunchState().initialize(),
    ]);
    // Kick off the remote-config loaders now but don't await them. They
    // resolve asynchronously and their consumers already tolerate the
    // default/unloaded shape until the first fetch returns.
    unawaited(getIt<IPublicAppSettingsService>().prefetch());
    unawaited(ClientGeminiListingUiConfig.load());
    unawaited(ClientLidarRoomScanConfig.load());
    unawaited(ClientCustomCameraConfig.load());
    unawaited(ClientListingContactsConfig.load());
    unawaited(ClientListingDictationMeterConfig.load());
    unawaited(ClientPhoneSignInConfig.load());
    // Local SharedPreferences reads — cheap, but still off the critical path.
    unawaited(TutorialState().initialize());
    unawaited(TooltipsState().initialize());
    unawaited(HapticFeedbackState().initialize());
    unawaited(SoundEffectsState().initialize());
    unawaited(AnimationSettingsState().initialize());
    unawaited(ChatComposerDraftState().initialize());
    unawaited(_bootstrapPriceDisplayCurrencyColdStart());
    unawaited(_bootstrapSearchFiltersColdStart());

    if (kDebugMode) {
      logger.d(
        "🔐 Main: AuthenticationState initialized. Current status: ${AuthenticationState().isAuthenticated}",
      );
    }

    // (Removed) Force-refreshing authentication status 2 seconds after launch
    // is redundant: `AuthenticationState().initialize()` is already awaited in
    // the critical-path `Future.wait` above and re-checks the same state. The
    // delayed refresh used to fire a duplicate Firebase Auth check while the
    // user was already on the home screen — wasted CPU/network and a small
    // extra battery hit on every cold start.

    // Display saved preferences in console (debug-only — Dart evaluates
    // string interpolation arguments eagerly, so without this guard the
    // expensive .currentLanguage / .currentTheme / etc. reads + string
    // allocation would still happen on every release cold start before
    // the gated `logger.d` extension short-circuits).
    if (kDebugMode) {
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
        '🚀 Launch: firstEver=${AppLaunchState().isFirstLaunchEver}, '
        'firstOfVersion=${AppLaunchState().isFirstLaunchOfCurrentVersion}, '
        'lastOpenedVersion=${AppLaunchState().lastOpenedVersion}, '
        'currentVersion=${AppLaunchState().currentVersion}',
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
    }

    // Bloc.observer = AppBlocObserver.instance(); // Disabled to reduce logging

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
      unawaited(UiPerformancePolicy.maybeCalibrateAfterStartup());
      // Analytics "app opened" event: deferred from the critical path so the
      // first frame doesn't wait on Firebase Analytics' lazy init.
      unawaited(
        getIt<AppAnalyticsService>().logAppOpened(source: "cold_start"),
      );
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
        // Eagerly warm the GoogleSignIn native plugin so the user's
        // first tap on "Sign in with Google" in the auth wizard doesn't
        // pay the full cold-start cost (1–3s on real devices). Runs in
        // parallel with the splash + onboarding navigation; the wizard
        // also `ensureWarm`s before invoking the system sheet to handle
        // the case where the user reaches it before warm-up finishes.
        unawaited(GoogleSignInWarmup.start());
      } else {
        final webAuth =
            DeepLinkService.tryParseTelegramAuthFromCurrentLocation();
        if (webAuth != null) {
          clearTelegramOAuthQueryFromBrowserUrl();
          deepLinkService.stagePendingTelegramAuth(webAuth);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.push(
              MaterialPageRoute<void>(
                builder: (_) => const AuthWizardScreen(),
              ),
            );
          });
        }
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
            unawaited(
              getIt<AppAnalyticsService>().syncUserPropertiesFromSession(),
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

/// Promote `FlutterErrorDetails` diagnostics (library, context summary, full
/// rendered diagnostics — including the widget chain) to Crashlytics keys and
/// log entries before recording the error. Helps debug release crashes whose
/// frames are stripped of the trailing "Information:" block (e.g. the
/// `Flexible inside Stack` parent-data cast assertion which only points at
/// `Flexible.applyParentData` in the stack trace itself).
void _annotateCrashlyticsWithFlutterError(FlutterErrorDetails details) {
  try {
    final crashlytics = FirebaseCrashlytics.instance;

    // Error category / library tags.
    final library = details.library ?? "unknown";
    crashlytics.setCustomKey("flutter_error_library", library);

    final exceptionText = details.exceptionAsString();
    crashlytics.setCustomKey(
      "flutter_error_exception",
      exceptionText.length > 240
          ? exceptionText.substring(0, 240)
          : exceptionText,
    );

    final ctx = details.context;
    if (ctx != null) {
      // `DiagnosticsNode.toString` keeps the human-readable context label
      // (e.g. "while applying parent data" / "during build" / etc).
      final ctxText = ctx.toString();
      crashlytics.setCustomKey(
        "flutter_error_context",
        ctxText.length > 240 ? ctxText.substring(0, 240) : ctxText,
      );
    }

    final summary = details.summary;
    final summaryText = summary.toString();
    crashlytics.setCustomKey(
      "flutter_error_summary",
      summaryText.length > 240 ? summaryText.substring(0, 240) : summaryText,
    );

    // Render the full diagnostic block (this is where Flutter prints
    // "The relevant error-causing widget was X created by Y", file:line
    // owners, and the widget tree path) and forward it to Crashlytics as
    // log lines. Each `log()` call shows up under the crash's "Logs" tab.
    final buffer = StringBuffer();
    buffer.writeln(details.toString());

    // Also store a small excerpt as a key so it's visible without opening Logs.
    final rendered = buffer.toString();
    crashlytics.setCustomKey(
      "flutter_error_rendered_excerpt",
      rendered.length > 240 ? rendered.substring(0, 240) : rendered,
    );

    // Stack of the exception (already in the report, but echoed here so the
    // log block is self-contained when triaging from the Logs tab).
    if (details.stack != null) {
      buffer.writeln("--- stack ---");
      buffer.writeln(details.stack);
    }
    // Crashlytics caps individual log entries at ~1 KB, so split.
    const chunkSize = 900;
    final text = buffer.toString();
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      crashlytics.log(text.substring(i, end));
    }
  } catch (_) {
    // Never let diagnostic enrichment swallow the original crash.
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
    UiPerformancePolicy.listenable,
  ]);

  Widget _getInitialScreen() {
    if (kShowRoomPlanWelcomeInsteadOfHome) {
      // For testing only. The welcome UI is inside RoomPlanScanScreen.
      return const RoomPlanScanScreen(listingId: 0);
    }
    final onboardingState = OnboardingState();
    final normalInitialScreen = onboardingState.showOnboarding &&
            !onboardingState.hasSeenOnboardingScreens
        ? const OnboardingScreen()
        : AppRouter.initialRoute;
    if (kShowLocationPermissionFirst) {
      return _LocationPermissionStartupPreview(nextScreen: normalInitialScreen);
    }
    if (onboardingState.showOnboarding &&
        !onboardingState.hasSeenOnboardingScreens) {
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
        BlocProvider<ConversationsBloc>(
          create: (_) => ConversationsBloc(getIt<IMessagingService>()),
        ),
        BlocProvider<CurrentUserProfileBloc>(
          create: (_) => CurrentUserProfileBloc(getIt<IUserProfileService>()),
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
            navigatorObservers: [routeObserver, topNamedRouteTracker],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: supportedLocales,
            locale: Locale(LanguageState().currentLanguage, ""),
            home: kShowLocationPermissionFirst
                ? _getInitialScreen()
                : kSkipSplashScreen
                    ? _getInitialScreen()
                    : (AppLaunchState().shouldShowFullSplash
                        ? const SplashScreen()
                        : const QuickSplashScreen()),
            builder: (context, child) {
              Widget subtree = _AchievementUnlockListener(
                navigatorKey: widget.navigatorKey,
                child: _BlocAuthListener(
                  child: child ?? const SizedBox.shrink(),
                ),
              );

              final mediaQuery = MediaQuery.maybeOf(context);
              if (mediaQuery != null) {
                subtree = MediaQuery(
                  data: UiPerformancePolicy.reducedEffectsMediaQuery(
                    mediaQuery,
                  ),
                  child: subtree,
                );
              }

              // Pauses all `vsync`-bound tickers below this point whenever the
              // app is not in `AppLifecycleState.resumed`. Eliminates idle
              // CPU/GPU drain from infinite `repeat()` animations during the
              // `inactive`/`hidden` states (notification shade, Control
              // Center, incoming call UI, brief app-switch peeks) — Flutter's
              // own scheduler only auto-pauses frames in `paused`/`detached`.
              return LifecycleTickerMode(child: subtree);
            },
          );
        },
      ),
    );
  }
}

class _LocationPermissionStartupPreview extends StatefulWidget {
  const _LocationPermissionStartupPreview({
    required this.nextScreen,
  });

  final Widget nextScreen;

  @override
  State<_LocationPermissionStartupPreview> createState() =>
      _LocationPermissionStartupPreviewState();
}

class _LocationPermissionStartupPreviewState
    extends State<_LocationPermissionStartupPreview> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runGate());
    });
  }

  Future<void> _runGate() async {
    await LocationPermissionGate.ensure(context);
    if (!mounted) return;
    setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return widget.nextScreen;
    return const Scaffold(
      backgroundColor: BlueThemeColors.primary,
      body: SizedBox.expand(),
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
      context.read<ConversationsBloc>().add(const ConversationsClear());
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

    getIt<AppAnalyticsService>().logScreenView(screenName: "splash");

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
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    // Start text animations after logo animation completes (2500ms + 200ms delay)
    await Future.delayed(const Duration(milliseconds: 2700));
    _titleController.forward();
    _subtitleController.forward(); // Start simultaneously with title

    // Navigate after text animations finish. The title/subtitle slide-in is
    // ~800ms; we then hold for an extra 2s (1s register + 1s read) so the
    // slogan is comfortably readable on first launch / version upgrade
    // before we move on.
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      final onboardingState = OnboardingState();
      if (onboardingState.showOnboarding &&
          !onboardingState.hasSeenOnboardingScreens) {
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
        // `sizeOf` subscribes only to size changes (orientation/window
        // resize), unlike `MediaQuery.of` which also rebuilds for keyboard
        // insets, padding, textScaler, etc. Splash doesn't care about any of
        // those, so this drops needless rebuilds.
        final size = MediaQuery.sizeOf(context);
        final width = size.width;
        final isNarrow = width < 400;

        // Pre-build the static title widget once and reuse it via the
        // `child` slot of the title `AnimatedBuilder` below — only the
        // `Transform.translate` offset needs to recompute per tick, so the
        // RichText/TextSpan/Container subtree no longer rebuilds at 60 fps.
        final titleWidget = Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: width * 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Uy",
                    style: TextStyle(
                      fontSize: isNarrow ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF0000),
                      letterSpacing: 2,
                    ),
                  ),
                  TextSpan(
                    text: "Dosh",
                    style: TextStyle(
                      fontSize: isNarrow ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: _getThemeTextColor(),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final subtitleWidget = Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: width * 0.8),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              L10n.get("splash_subtitle"),
              style: TextStyle(
                fontSize: isNarrow ? 12.8 : 14.4,
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
        );

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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.25),
                    const AnimatedSvgLogo(
                      size: 180,
                      animationDuration: Duration(milliseconds: 2500),
                    ),
                    const SizedBox(height: 0),
                    // Title slide: only this AnimatedBuilder rebuilds per
                    // title-controller tick, and only the Transform itself is
                    // rebuilt — the RichText subtree is passed via `child`.
                    AnimatedBuilder(
                      animation: _titleSlideAnimation,
                      child: titleWidget,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _titleSlideAnimation.value * width * 0.5,
                            0,
                          ),
                          child: child,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _subtitleSlideAnimation,
                      child: subtitleWidget,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _subtitleSlideAnimation.value * width * 0.5,
                            0,
                          ),
                          child: child,
                        );
                      },
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
}

/// Static, fast-display splash for warm/repeat launches.
///
/// Shown when [AppLaunchState.shouldShowFullSplash] is `false` (i.e. not the
/// first launch ever and not the first launch of a new app version). Renders
/// the same final composition as [SplashScreen] using [QuickSplashLogo], but
/// without the multi-stage logo animation, slide-in text, or haptic feedback.
/// A short fade-in keeps the transition smooth, then we navigate onward.
class QuickSplashScreen extends StatefulWidget {
  const QuickSplashScreen({super.key});

  @override
  State<QuickSplashScreen> createState() => _QuickSplashScreenState();
}

class _QuickSplashScreenState extends State<QuickSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    getIt<AppAnalyticsService>().logScreenView(screenName: "splash_quick");

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _start();
  }

  Future<void> _start() async {
    _fadeController.forward();
    // Brief hold so the static branding is actually perceptible, then move
    // on. Keep this snappy — the whole point of the quick splash is speed.
    // Trimmed from 1700ms → 1000ms; with the 300ms fade-in, total time on
    // splash is ~1s end-to-end on warm starts.
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final onboardingState = OnboardingState();
    if (onboardingState.showOnboarding &&
        !onboardingState.hasSeenOnboardingScreens) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      context.pushReplaceMainNavigation();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Color> _gradientColors() {
    final themeState = ThemeState();
    if (themeState.isBlueTheme) {
      return [
        BlueThemeColors.primaryLight,
        BlueThemeColors.primaryDark,
      ];
    }
    return [
      LightThemeColors.background,
      LightThemeColors.surface,
    ];
  }

  Color _textColor() {
    final themeState = ThemeState();
    return themeState.isBlueTheme
        ? AppColors.textLight
        : LightThemeColors.textPrimary;
  }

  Color _secondaryTextColor() {
    final themeState = ThemeState();
    return themeState.isBlueTheme
        ? AppColors.textLight70
        : LightThemeColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        final width = size.width;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors(),
                stops: const [0.0, 1.0],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.25),
                    const QuickSplashLogo(size: 180),
                    const SizedBox(height: 0),
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: width * 0.9),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Uy",
                                style: TextStyle(
                                  fontSize: width < 400 ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF0000),
                                  letterSpacing: 2,
                                ),
                              ),
                              TextSpan(
                                text: "Dosh",
                                style: TextStyle(
                                  fontSize: width < 400 ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: _textColor(),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: width * 0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          L10n.get("splash_subtitle"),
                          style: TextStyle(
                            fontSize: width < 400 ? 12.8 : 14.4,
                            color: _secondaryTextColor(),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
