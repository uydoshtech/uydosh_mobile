import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:uy_dosh/base/constants/app_colors.dart"
    show AppColors, BlueThemeColors, LightThemeColors;

import "package:uy_dosh/base/common/application_settings.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/generated/l10n.dart";

import "package:uy_dosh/base/logger/log_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/onboarding/onboarding_screen.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/animated_svg_logo.dart";

import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Global RouteObserver for handling navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Flag to skip splash screen - automatically skip when running in Chrome/web
bool get kSkipSplashScreen => kIsWeb;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Initialize Firebase
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        logger.d('Firebase initialized successfully');
      } else {
        logger.d('Firebase already initialized, continuing...');
      }
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        logger.d('Firebase already exists, continuing...');
      } else {
        logger.d('Firebase initialization error: $e');
        rethrow;
      }
    }

    // Configure logging based on environment
    LogConfig.instance.printConfig();

    // Initialize language state to load saved language
    await LanguageState().initialize();

    // Initialize authentication state to start listening to auth changes
    logger.d('🔐 Main: Initializing AuthenticationState...');
    await AuthenticationState().initialize();
    logger.d(
      '🔐 Main: AuthenticationState initialized. Current status: ${AuthenticationState().isAuthenticated}',
    );

    // Force refresh authentication status after a delay to ensure Firebase is ready
    Future.delayed(const Duration(seconds: 2), () {
      logger.d('🔐 Main: Force refreshing authentication status...');
      AuthenticationState().refreshAuthenticationStatus();
    });

    // Initialize onboarding state to load saved preferences
    await OnboardingState().initialize();

    // Initialize search filters state to load saved preferences
    await SearchFiltersState().initialize();

    // Initialize theme state to load saved theme
    await ThemeState().initialize();

    // Display saved preferences in console
    logger.d('=== APP STARTUP - SAVED PREFERENCES ===');
    logger.d(
      '🌍 Language: ${LanguageState().currentLanguage} (${LanguageDisplayHelper.getLanguageDisplayName(LanguageState().currentLanguage)})',
    );
    logger.d(
      '🎨 Theme: ${ThemeState().currentTheme} (${ThemeState().currentThemeDisplayName})',
    );
    logger.d(
      '🔐 Authentication: ${AuthenticationState().isAuthenticated ? "AUTHENTICATED" : "NOT AUTHENTICATED"}',
    );
    logger.d(
      '🎓 Onboarding: ${OnboardingState().showOnboarding ? "ENABLED" : "DISABLED"}',
    );
    logger.d(
      '🔍 Search Filters: listingType=${SearchFiltersState().selectedListingTypeId}, location=${SearchFiltersState().selectedLocationIndex}, line=${SearchFiltersState().selectedSubwayLine}, station=${SearchFiltersState().selectedStationIndex}',
    );
    logger.d('========================================');

    await configureDependencies();
    // Bloc.observer = AppBlocObserver.instance(); // Disabled to reduce logging

    runApp(MyApp());
  } catch (e, stackTrace) {
    logger.d('Error during app initialization: $e');
    logger.d('Stack trace: $stackTrace');

    // Fallback to a simple app if dependency injection fails
    runApp(
      MaterialApp(
        title: 'UyDosh',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.primary, // Deep purple background
        ),
        home: const Scaffold(
          body: Center(
            child: Text(
              'App initialization failed. Check console for details.',
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _getInitialScreen() {
    final onboardingState = OnboardingState();
    if (onboardingState.showOnboarding) {
      return const OnboardingScreen();
    } else {
      return AppRouter.initialRoute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        return MaterialApp(
          title: 'UyDosh',
          theme: ThemeState().currentThemeData,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: Locale(IApplicationSettings.currentLang, ''),
          home: kSkipSplashScreen ? _getInitialScreen() : const SplashScreen(),
        );
      },
    );
  }
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

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    // Start text animations after logo animation completes (4000ms + 200ms delay)
    await Future.delayed(const Duration(milliseconds: 4200));
    _titleController.forward();
    _subtitleController.forward(); // Start simultaneously with title

    // Navigate based on onboarding preference after text animations complete
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      final onboardingState = OnboardingState();
      if (onboardingState.showOnboarding) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
        );
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
    if (themeState.isPurpleTheme) {
      return [
        AppColors.primaryLight, // Light purple (#9B6DFF)
        AppColors.primaryDark, // Dark purple (#4A148C)
      ];
    } else if (themeState.isBlueTheme) {
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
    if (themeState.isPurpleTheme || themeState.isBlueTheme) {
      return AppColors.textLight; // White text for dark themes
    } else {
      return LightThemeColors.textPrimary; // Black text for light theme
    }
  }

  /// Get theme-specific secondary text color for the splash screen
  Color _getThemeSecondaryTextColor() {
    final themeState = ThemeState();
    if (themeState.isPurpleTheme || themeState.isBlueTheme) {
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
                        AnimatedSvgLogo(
                          size: 180, // 50% larger (120 * 1.5)
                          animationDuration: const Duration(milliseconds: 4000),
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
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  'splash_subtitle',
                                ),
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
