import "dart:async";

import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/screens/permissions/notification_permission_gate.dart";
import "package:uy_dosh/base/utils/animation_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed_centered.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSwitchTimer;
  bool _navigatingToMainApp = false;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _locationController;
  late Animation<double> _locationBounceAnimation;
  late AnimationController _shieldController;
  late Animation<double> _shieldRotateAnimation;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "onboarding");
    getIt<AppAnalyticsService>().logOnboardingStarted();
    _setupRotateAnimation();
    _setupLocationAnimation();
    _setupShieldAnimation();
    _startAutoSwitchTimer();
  }

  void _setupRotateAnimation() {
    _rotateController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rotateAnimation = Tween<double>(
      begin: -0.3, // -15 degrees in radians
      end: 0.3, // 15 degrees in radians
    ).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  void _setupLocationAnimation() {
    _locationController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _locationBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _locationController, curve: Curves.easeInOut),
    );
  }

  void _setupShieldAnimation() {
    _shieldController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _shieldRotateAnimation = Tween<double>(
      begin: -0.3,
      end: 0.3,
    ).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDecorativeLoops();
  }

  void _syncDecorativeLoops() {
    final enabled = UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    final controllers = [
      _rotateController,
      _locationController,
      _shieldController,
    ];
    for (final controller in controllers) {
      if (enabled) {
        if (!controller.isAnimating) {
          controller.repeat(reverse: true);
        }
      } else {
        controller.stop();
        controller.value = 0.5;
      }
    }
  }

  void _startAutoSwitchTimer() {
    // Do not restart the timer once we've already kicked off the
    // navigate-to-main-app flow — otherwise it can re-enter
    // `_navigateToMainApp` while we're awaiting the notification gate.
    if (_navigatingToMainApp) return;
    _autoSwitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _navigatingToMainApp) {
        timer.cancel();
        return;
      }
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_currentPage == 2) {
        // If on last page, navigate to main app. `_navigateToMainApp`
        // cancels the timer itself; we still cancel here to make the
        // periodic callback strictly one-shot in this branch.
        timer.cancel();
        _navigateToMainApp();
      }
    });
  }

  @override
  void dispose() {
    _autoSwitchTimer?.cancel();
    _pageController.dispose();
    AnimationUtils.disposeAnimationControllers([
      _rotateController,
      _locationController,
      _shieldController,
    ]);
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Reset the auto-switch timer when user manually changes pages
    _autoSwitchTimer?.cancel();
    _startAutoSwitchTimer();
  }

  Future<void> _navigateToMainApp({bool skipped = false}) async {
    // Re-entry guard. The 5s auto-switch timer keeps firing while the
    // user reads the notification rationale, so without this latch we'd
    // queue up multiple `_navigateToMainApp()` calls — each pushing its
    // own NotificationPermissionGate and then `pushReplaceMainNavigation`,
    // which manifests as the home screen being pushed twice.
    if (_navigatingToMainApp) return;
    _navigatingToMainApp = true;
    // Belt-and-suspenders: also kill the timer up front so we don't even
    // re-enter the periodic callback while we await the gate.
    _autoSwitchTimer?.cancel();
    _autoSwitchTimer = null;

    if (skipped) {
      getIt<AppAnalyticsService>()
          .logOnboardingSkipped(pageIndex: _currentPage);
    } else {
      getIt<AppAnalyticsService>().logOnboardingCompleted(pageCount: 3);
    }
    // Mark onboarding screens as seen (toggle is turned OFF after search tutorial)
    await OnboardingState().markOnboardingScreensSeen();

    // Surface the notification rationale once at the end of onboarding
    // (only if we've never asked before). Skipped users still see it —
    // they bailed out of the *intro slides*, not out of the app, so it's
    // still worth opting them in to search alerts. Failures here are
    // non-fatal: we always proceed to main navigation regardless.
    if (mounted && !await NotificationPermissionGate.hasPromptedBefore()) {
      if (!mounted) return;
      await NotificationPermissionGate.ensure(
        context,
        allowSkipPersistsAcrossLaunches: true,
      );
    }

    if (!mounted) return;
    context.pushReplaceMainNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        // Get onboarding-specific colors based on current theme
        final onboardingColors = _getOnboardingColors(theme);

        // Use the exact original gradient colors for the default theme
        final gradientColors = _getGradientColors(theme);

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButtonThemedFactory.text(
                        onPressed: () => _navigateToMainApp(skipped: true),
                        text: L10n.get("onboarding_skip"),
                      ),
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return _buildPage(index, colorScheme, onboardingColors);
                      },
                    ),
                  ),

                  // Bottom section with indicators and buttons
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Page indicator
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 8,
                            dotColor: onboardingColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                            activeDotColor: onboardingColors.text,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button (only show if not on first page)
                            if (_currentPage > 0)
                              TextButtonThemedCenteredFactory.iconText(
                                onPressed: () {
                                  HapticFeedbackUtils.impact();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: Icons.chevron_left,
                                text: L10n.get("onboarding_back"),
                              )
                            else
                              const SizedBox(width: 60),

                            // Next/Get Started button
                            TextButtonThemedCenteredFactory.textIcon(
                              onPressed: () {
                                HapticFeedbackUtils.impact();
                                if (_currentPage < 2) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _navigateToMainApp();
                                }
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              text: L10n.get(
                                _currentPage < 2
                                    ? "onboarding_next"
                                    : "onboarding_get_started",
                              ),
                              icon: Icons.chevron_right,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(
    int pageIndex,
    ColorScheme colorScheme,
    OnboardingColors onboardingColors,
  ) {
    final pages = [
      _OnboardingPage(
        titleKey: "onboarding_title_1",
        descriptionKey: "onboarding_subtitle_1",
        icon: Icons.groups,
        color: onboardingColors.secondary,
        isFirstPage: true,
      ),
      _OnboardingPage(
        titleKey: "onboarding_title_2",
        descriptionKey: "onboarding_subtitle_2",
        // Combined metro + district page uses the pin animation.
        icon: Icons.security,
        // Keep the original "pin" red accent.
        color: colorScheme.error,
        isFirstPage: false,
      ),
      _OnboardingPage(
        titleKey: "onboarding_title_4",
        descriptionKey: "onboarding_subtitle_4",
        icon: Icons.verified_user,
        color: AppColors.secondary,
        isFirstPage: false,
      ),
    ];

    final page = pages[pageIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or Icon container
          if (page.isFirstPage)
            _buildCommunityImage()
          else
            _buildIconContainer(page, colorScheme),

          const SizedBox(height: 40),

          LayoutBuilder(
            builder: (context, constraints) {
              // Slightly reduce side margins so longer locales wrap more naturally.
              final horizontalPadding = (constraints.maxWidth * 0.12).clamp(
                24.0,
                40.0,
              );

              return Column(
                children: [
                  // Title
                  Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Text(
                        L10n.get(page.titleKey),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: onboardingColors.text,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Text(
                        L10n.get(page.descriptionKey),
                        style: TextStyle(
                          fontSize: 18,
                          color: onboardingColors.textSecondary,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityImage() {
    final themeState = ThemeState();
    final isBlueTheme = themeState.isBlueTheme;
    final peopleIconColor = themeState.isLightTheme
        ? Colors.black
        : isBlueTheme
            ? Colors.white
            : AppColors.primary;
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: ThemeIcon(
                Icons.groups,
                color: peopleIconColor,
                size: 198,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer(_OnboardingPage page, ColorScheme colorScheme) {
    // Special animation for shield icon (fourth page) - rotate back and forth, 1.5x size
    if (page.icon == Icons.verified_user) {
      return AnimatedBuilder(
        animation: _shieldController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shieldRotateAnimation.value,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: page.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(90),
                border: Border.all(
                  color: page.color.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ThemeIcon(page.icon, size: 90, color: page.color),
            ),
          );
        },
      );
    }

    // Special animation for security icon (third page) with location pin as main icon
    if (page.icon == Icons.security) {
      return AnimatedBuilder(
        animation: _locationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -10 * _locationBounceAnimation.value),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: page.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: page.color.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: ThemeIconFactory.display(
                  icon: Icons.location_on,
                  color: page.color,
                  size: 160,
                ),
              ),
            ),
          );
        },
      );
    }

    // Regular icon container for other icons
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: page.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: page.color.withValues(alpha: 0.3), width: 2),
      ),
      child: ThemeIcon(page.icon, size: 60, color: page.color),
    );
  }

  /// Get onboarding-specific colors based on the current theme
  OnboardingColors _getOnboardingColors(ThemeData theme) {
    final themeState = ThemeState();

    if (themeState.isLightTheme) {
      return const OnboardingColors(
        primary: LightThemeColors.onboardingPrimary,
        secondary: LightThemeColors.onboardingSecondary,
        surface: LightThemeColors.onboardingSurface,
        background: LightThemeColors.onboardingBackground,
        card: LightThemeColors.onboardingCard,
        text: LightThemeColors.onboardingText,
        textSecondary: LightThemeColors.onboardingTextSecondary,
      );
    } else if (themeState.isBlueTheme) {
      return const OnboardingColors(
        primary: BlueThemeColors.onboardingPrimary,
        secondary: BlueThemeColors.onboardingSecondary,
        surface: BlueThemeColors.onboardingSurface,
        background: BlueThemeColors.onboardingBackground,
        card: BlueThemeColors.onboardingCard,
        text: BlueThemeColors.onboardingText,
        textSecondary: BlueThemeColors.onboardingTextSecondary,
      );
    } else {
      // Default theme
      return const OnboardingColors(
        primary: AppColors.onboardingPrimary,
        secondary: AppColors.onboardingSecondary,
        surface: AppColors.onboardingSurface,
        background: AppColors.onboardingBackground,
        card: AppColors.onboardingCard,
        text: AppColors.onboardingText,
        textSecondary: AppColors.onboardingTextSecondary,
      );
    }
  }

  /// Get the gradient colors for the background
  /// For the default theme, uses the exact original colors: primaryLight and primaryDark
  List<Color> _getGradientColors(ThemeData theme) {
    final themeState = ThemeState();

    if (themeState.isLightTheme) {
      // Use ultra-light gradient for light theme - much lighter background
      return LightThemeColors.ultraLightGradient;
    } else if (themeState.isBlueTheme) {
      return [
        BlueThemeColors.onboardingPrimary,
        BlueThemeColors.onboardingSurface,
      ];
    } else {
      // Default theme - use the exact original gradient colors
      return [
        AppColors.primaryLight, // #9B6DFF (Light Purple)
        AppColors.primaryDark, // #4A148C (Dark Purple)
      ];
    }
  }
}

/// Colors specifically designed for the onboarding screen
class OnboardingColors {
  const OnboardingColors({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.card,
    required this.text,
    required this.textSecondary,
  });
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color background;
  final Color card;
  final Color text;
  final Color textSecondary;
}

class _OnboardingPage {
  _OnboardingPage({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    this.isFirstPage = false,
  });
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;
  final bool isFirstPage;
}
