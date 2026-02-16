import "dart:async";

import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/animation_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

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

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _trainController;
  late Animation<double> _trainMoveAnimation;
  late Animation<double> _trainBounceAnimation;
  late AnimationController _locationController;
  late Animation<double> _locationBounceAnimation;
  late AnimationController _shieldController;
  late Animation<double> _shieldRotateAnimation;

  @override
  void initState() {
    super.initState();
    _setupRotateAnimation();
    _setupTrainAnimation();
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

    // Start the rotation animation when the first page is shown
    _rotateController.repeat(reverse: true);
  }

  void _setupTrainAnimation() {
    _trainController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _trainMoveAnimation = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(parent: _trainController, curve: Curves.easeInOut),
    );

    _trainBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trainController, curve: Curves.elasticOut),
    );

    // Start the train animation
    _trainController.repeat(reverse: true);
  }

  void _setupLocationAnimation() {
    _locationController = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _locationBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _locationController, curve: Curves.easeInOut),
    );

    // Start the location animation
    _locationController.repeat(reverse: true);
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

    _shieldController.repeat(reverse: true);
  }

  void _startAutoSwitchTimer() {
    _autoSwitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _currentPage < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (mounted && _currentPage == 3) {
        // If on last page, navigate to main app
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
      _trainController,
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

  Future<void> _navigateToMainApp() async {
    // Automatically turn off onboarding after it's shown once
    await OnboardingState().turnOffOnboarding();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
    );
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
                        onPressed: _navigateToMainApp,
                        text: LanguageAwareStringHelper.getCurrent(
                          context,
                          "onboarding_skip",
                        ),
                      ),
                    ),
                  ),

                  // Page content
                  Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: 4,
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
                      count: 4,
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
                          TextButtonThemedFactory.text(
                            onPressed: () {
                              HapticFeedbackUtils.impact();
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            text: LanguageAwareStringHelper.getCurrent(
                              context,
                              "onboarding_back",
                            ),
                          )
                        else
                          const SizedBox(width: 60),

                        // Next/Get Started button
                        TextButtonThemedFactory.text(
                          onPressed: () {
                            if (_currentPage < 3) {
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
                          text: LanguageAwareStringHelper.getCurrent(
                            context,
                            _currentPage < 3
                                ? "onboarding_next"
                                : "onboarding_get_started",
                          ),
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
        icon: Icons.home,
        color: onboardingColors.secondary,
        isFirstPage: true,
      ),
      _OnboardingPage(
        titleKey: "onboarding_title_2",
        descriptionKey: "onboarding_subtitle_2",
        icon: Icons.train,
        color: AppColors.secondary,
        isFirstPage: false,
      ),
      _OnboardingPage(
        titleKey: "onboarding_title_3",
        descriptionKey: "onboarding_subtitle_3",
        icon: Icons.security,
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
            _buildHomeImage(colorScheme, onboardingColors)
          else
            _buildIconContainer(page, colorScheme),

          const SizedBox(height: 40),

          // Title
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                LanguageAwareStringHelper.getCurrent(context, page.titleKey),
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
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                LanguageAwareStringHelper.getCurrent(
                  context,
                  page.descriptionKey,
                ),
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
      ),
    );
  }

  Widget _buildHomeImage(
    ColorScheme colorScheme,
    OnboardingColors onboardingColors,
  ) {
    final themeState = ThemeState();
    final houseIconColor =
        themeState.isLightTheme
            ? Colors.black
            : themeState.isBlueTheme
            ? Colors.white
            : AppColors.primary;
    final iconContainerBackground =
        themeState.isBlueTheme
            ? BlueThemeColors.onboardingSecondary
            : onboardingColors.surface;
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: onboardingColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: onboardingColors.text.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: onboardingColors.text.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background house (without container decoration)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Icon(
                    Icons.home,
                    color: houseIconColor,
                    size: 60,
                  ),
                ),
                // Search icon - Updated for light theme
                Positioned(
                  top: 30,
                  right: 30,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconContainerBackground,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: onboardingColors.text.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search,
                      color:
                          onboardingColors
                              .text, // Use theme text color (black for light theme)
                      size: 24,
                    ),
                  ),
                ),
                // Location pin - Updated for light theme
                Positioned(
                  bottom: 35,
                  right: 55,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconContainerBackground,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: onboardingColors.text.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ThemeIconFactory.display(
                      icon: Icons.location_on,
                      color:
                          onboardingColors
                              .text, // Use theme text color (black for light theme)
                      size: 22,
                    ),
                  ),
                ),
                // Heart icon - Updated for light theme
                Positioned(
                  top: 60,
                  left: 40,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconContainerBackground,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: onboardingColors.text.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color:
                          AppColors
                              .favoriteActive, // Keep red heart icon for consistency
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer(_OnboardingPage page, ColorScheme colorScheme) {
    // Special animation for train icon (second page)
    if (page.icon == Icons.train) {
      return AnimatedBuilder(
        animation: _trainController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_trainMoveAnimation.value, 0),
            child: Transform.scale(
              scale: 0.8 + (_trainBounceAnimation.value * 0.2),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: page.color.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Main train icon
                    Center(
                      child: Icon(page.icon, size: 120, color: page.color),
                    ),
                    // Train tracks (subtle background)
                    Positioned(
                      bottom: 30,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: page.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
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
              child: Icon(page.icon, size: 90, color: page.color),
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
                  color: colorScheme.error,
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
      child: Icon(page.icon, size: 60, color: page.color),
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
