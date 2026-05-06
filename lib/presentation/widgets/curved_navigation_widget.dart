import "dart:math" as math;

import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart" show AppColors, BlueThemeColors;
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class CustomCurvedNavigationBar extends StatefulWidget {
  const CustomCurvedNavigationBar({
    required this.currentIndex, required this.onTap, required this.navigationKey, required this.isAuthenticated, super.key,
    this.hasUnreadMessages = false,
    this.incomingMessageTravelDotTrigger = 0,
    this.onCreatePressed,
  });

  final int currentIndex;
  final Function(int) onTap;
  final GlobalKey<CurvedNavigationBarState> navigationKey;
  final bool isAuthenticated;
  final bool hasUnreadMessages;
  final int incomingMessageTravelDotTrigger;

  /// Invoked when the user taps the trailing "+" item. When supplied, the
  /// tap is intercepted before the underlying [CurvedNavigationBar] reacts,
  /// so callers can show a chooser sheet and decide which create flow to
  /// trigger (housing tab vs. push gig-offer route) without the bar
  /// flicker-animating to a tab the user did not actually pick.
  final VoidCallback? onCreatePressed;

  @override
  State<CustomCurvedNavigationBar> createState() =>
      _CustomCurvedNavigationBarState();
}

class _CustomCurvedNavigationBarState extends State<CustomCurvedNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final items = _buildNavigationItems(widget.isAuthenticated);

    return SizedBox(
      height: 70.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                // Item count is fixed (4) post 2026-Q2 nav rework, so the
                // package's cached `_length` no longer needs invalidation.
                child: CurvedNavigationBar(
                  index: widget.currentIndex,
                  height: 70.0,
                  color: _getCurvedColor(context), // Theme-dependent curved color
                  // Active “disk” is drawn by [_CurvedNavActiveOrb] on the selected item;
                  // keep the package [Material] transparent so gradients/shadows show.
                  buttonBackgroundColor: Colors.transparent,
                  backgroundColor: _getBackgroundColor(
                    context,
                  ), // Theme-dependent background color
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 300),
                  onTap: (index) {
                    _handleNavigationTap(index, widget.isAuthenticated);
                  },
                  letIndexChange: (index) {
                    // Allow all index changes - authentication will be handled in _handleNavigationTap
                    // This ensures all navigation items appear clickable and responsive
                    return true;
                  },
                  items: items,
                ),
              ),
              // Tap-overlay over the trailing "+" item. The underlying
              // [CurvedNavigationBar] item count is fixed at 4, so the create
              // button is the right-most quarter of the bar. We capture taps
              // here so the bar doesn't animate the orb across to "+" before
              // the chooser sheet returns — if the user picks "Service" we
              // never want to land on the create-listing tab. Housing-pick
              // intentionally falls through to the standard tab switch via
              // [widget.onTap] from the parent's setState.
              if (widget.onCreatePressed != null)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _handleCreateTap(widget.isAuthenticated);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleCreateTap(bool isAuthenticated) {
    if (!isAuthenticated) {
      _launchAuthWizard(context);
      return;
    }
    widget.onCreatePressed?.call();
  }

  Widget _buildNavigationItem(
    IconData icon,
    String labelKey,
    bool isSelected, {
    bool isDisabled = false,
  }) {
    // For selected items, use white icons to contrast with the black button background
    // For unselected items, use the theme-appropriate icon color
    final iconColor =
        isDisabled
            ? _getDisabledColor(context)
            : isSelected
            ? Colors.white
            : _getIconColor(context);
    final textColor =
        isDisabled ? _getDisabledColor(context) : _getTextColor(context);

    final iconWidget = ThemeIcon(icon, size: 28, color: iconColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          _CurvedNavActiveOrb(
            baseColor: _getButtonBackgroundColor(context),
            child: iconWidget,
          )
        else
          iconWidget,
        if (!isSelected) ...[
          const SizedBox(height: 2),
          ListenableBuilder(
            listenable: LanguageState(),
            builder: (context, child) {
              return Text(
                L10n.get(labelKey),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // Build navigation items. Layout (post 2026-Q2 nav rework):
  //   0 = Housing      (public)
  //   1 = Services hub (public — gates auth at each action boundary)
  //   2 = Messages     (auth required)
  //   3 = Create       (auth required)
  //
  // Favorites was removed from the bar (still reachable from drawer/profile).
  List<Widget> _buildNavigationItems(bool isAuthenticated) {
    return <Widget>[
      _buildNavigationItem(Icons.home, "nav_housing", widget.currentIndex == 0),
      _buildNavigationItem(
        Icons.handyman_outlined,
        "menu_gigs",
        widget.currentIndex == 1,
      ),
      _buildConversationsItem(),
      _buildNavigationItem(
        Icons.add,
        "create_listing",
        widget.currentIndex == 3,
      ),
    ];
  }

  // Build conversations item (selectable, like other navigation items)
  Widget _buildConversationsItem() {
    final isSelected = widget.currentIndex == 2; // Conversations is at index 2
    final iconColor = isSelected ? Colors.white : _getIconColor(context);
    final textColor = isSelected ? Colors.white : _getTextColor(context);
    final unreadColor = ThemeState().unreadIndicatorColor;

    final bubbleIcon = ThemeIcon(
      CupertinoIcons.bubble_left_bubble_right,
      size: 28,
      color: iconColor,
    );

    // IMPORTANT: The badge subtree must be mounted exactly once.
    // Using the same GlobalKey in multiple branches can still collide because
    // CurvedNavigationBar may keep previous/next item subtrees around during
    // its animation frames.
    final iconWithBadge = Stack(
      children: [
        bubbleIcon,
        Positioned(
          right: 0,
          top: 0,
          child: Builder(
            builder: (context) {
              return widget.hasUnreadMessages
                  ? PulseThenBlinkDotWidget(
                      trigger: widget.incomingMessageTravelDotTrigger,
                      color: unreadColor,
                      size: 11,
                      blinkDuration: const Duration(milliseconds: 750),
                      borderColor: Colors.white,
                      borderWidth: 2,
                    )
                  : const SizedBox(width: 11, height: 11);
            },
          ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use the same structure as other navigation items for consistent positioning
        if (isSelected)
          _CurvedNavActiveOrb(
            baseColor: _getButtonBackgroundColor(context),
            child: iconWithBadge,
          )
        else
          iconWithBadge,
        if (!isSelected) ...[
          const SizedBox(height: 2),
          ListenableBuilder(
            listenable: LanguageState(),
            builder: (context, child) {
              return Text(
                L10n.get("conversations"),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  /// Handle a tap on a bar position. Logical indices match bar positions
  /// 1-to-1 since the 2026-Q2 nav rework:
  ///   0 = Housing  (public)
  ///   1 = Services (public — auth gated per-action inside the hub)
  ///   2 = Messages (auth required)
  ///   3 = Create   (auth required)
  void _handleNavigationTap(int barIndex, bool isAuthenticated) {
    switch (barIndex) {
      case 0:
      case 1:
        widget.onTap(barIndex);
        return;
      case 2:
      case 3:
        if (isAuthenticated) {
          widget.onTap(barIndex);
        } else {
          _launchAuthWizard(context);
        }
        return;
    }
  }

  // Launch authentication wizard
  void _launchAuthWizard(BuildContext context) {
    context
        .pushReplaceAuthWizard()
        .then((_) {
          // After successful authentication, redirect to home screen
          // This ensures users go to home instead of their original destination
          if (mounted) {
            widget.onTap(0); // Navigate to home screen (index 0)
          }
        });
  }

  // Theme-dependent color methods
  Color _getCurvedColor(BuildContext context) {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme — deep navy "shelf" that matches the palette's navigation
      // surface token. Reads as a weighted footer instead of a foreign mid-tone
      // blue, and lets the active orb's bright accent do the talking.
      return BlueThemeColors.navigationBackground;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use gray-ish color for curved part
      return Colors.grey[600]!; // Using a medium gray instead of black
    } else {
      // Default theme - use existing light primary
      return AppColors.primaryLight; // This is Color(0xFF9B6DFF)
    }
  }

  Color _getButtonBackgroundColor(BuildContext context) {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme — bright brand blue for the active orb. High contrast against
      // the dark navy bar so the selected tab is immediately legible, and ties
      // the active state to the FAB / brand accent.
      return BlueThemeColors.primaryLight;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use black for selected button
      return Colors.black;
    } else {
      // Default theme - use existing dark primary
      return AppColors.primaryDark; // This is Color(0xFF4A148C)
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme - use primary blue for background
      return BlueThemeColors.primary;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use white for background
      return Colors.white;
    } else {
      // Default theme - use existing primary color
      return AppColors.primary; // This is Color(0xFF673AB7)
    }
  }

  Color _getIconColor(BuildContext context) {
    // Use ThemeState to detect current theme for icon colors
    if (ThemeState().isLightTheme) {
      // Light theme - use white icons for white background
      return Colors.white;
    } else {
      // Dark themes - use white icons for dark backgrounds
      return Colors.white;
    }
  }

  Color _getTextColor(BuildContext context) {
    // Use ThemeState to detect current theme for text colors
    if (ThemeState().isLightTheme) {
      // Light theme - use white text for white background
      return Colors.white;
    } else {
      // Dark themes - use light text for dark backgrounds
      return AppColors.textLight;
    }
  }

  Color _getDisabledColor(BuildContext context) {
    // Use ThemeState to detect current theme for disabled colors
    if (ThemeState().isLightTheme) {
      // Light theme - use semi-transparent black for disabled state
      return Colors.black.withValues(alpha: 0.4);
    } else {
      // Dark themes - use semi-transparent white for disabled state
      return AppColors.textLight.withValues(alpha: 0.4);
    }
  }
}

/// Unread badge that pulses (scale) a few times on [trigger] changes,
/// then continues blinking to attract attention.
class PulseThenBlinkDotWidget extends StatefulWidget {
  const PulseThenBlinkDotWidget({
    required this.trigger,
    super.key,
    this.color = Colors.green,
    this.size = 12.0,
    this.blinkDuration = const Duration(seconds: 2),
    this.borderColor,
    this.borderWidth = 2.0,
    this.pulseCount = 3,
    this.pulseScale = 1.35,
    this.pulseStep = const Duration(milliseconds: 120),
  });

  /// Change this value (e.g. increment) to replay the pulse.
  final int trigger;

  final Color color;
  final double size;

  /// Duration of the blink cycle after the pulse completes.
  final Duration blinkDuration;

  final Color? borderColor;
  final double borderWidth;

  /// How many full grow+shrink pulses to play.
  final int pulseCount;

  /// Maximum scale during pulse.
  final double pulseScale;

  /// Duration of each half-step (grow or shrink).
  final Duration pulseStep;

  @override
  State<PulseThenBlinkDotWidget> createState() => _PulseThenBlinkDotWidgetState();
}

class _PulseThenBlinkDotWidgetState extends State<PulseThenBlinkDotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: _pulseTotalDuration(widget.pulseCount, widget.pulseStep),
  );

  late final AnimationController _blinkController = AnimationController(
    vsync: this,
    duration: widget.blinkDuration,
  );
  late final Animation<double> _blink = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _blinkController, curve: Curves.linear));

  int _lastTrigger = 0;

  static Duration _pulseTotalDuration(int pulseCount, Duration pulseStep) {
    final steps = (pulseCount <= 0) ? 0 : pulseCount * 2;
    return Duration(milliseconds: pulseStep.inMilliseconds * steps);
  }

  @override
  void initState() {
    super.initState();
    _lastTrigger = widget.trigger;
    _blinkController.repeat(reverse: true);

    // If we mount with an already-incremented trigger (e.g. app resumed with
    // unread that just arrived), play the pulse once so it’s noticeable.
    if (_lastTrigger > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _playPulseThenBlink();
      });
    }
  }

  @override
  void didUpdateWidget(covariant PulseThenBlinkDotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.blinkDuration != widget.blinkDuration) {
      _blinkController.duration = widget.blinkDuration;
      if (_blinkController.isAnimating) {
        _blinkController
          ..stop()
          ..repeat(reverse: true);
      }
    }

    // If pulse tuning changed, rebuild controller/animation quickly.
    if (oldWidget.pulseCount != widget.pulseCount ||
        oldWidget.pulseStep != widget.pulseStep) {
      _pulseController.duration =
          _pulseTotalDuration(widget.pulseCount, widget.pulseStep);
    }

    if (widget.trigger == _lastTrigger) return;
    _lastTrigger = widget.trigger;
    _playPulseThenBlink();
  }

  Future<void> _playPulseThenBlink() async {
    if (!mounted) return;

    // Pause blink so the pulse reads clearly.
    _blinkController.stop();

    _pulseController
      ..stop()
      ..reset();

    // Animate a few scale oscillations (reads like "pulse").
    // We implement the oscillation by driving the scale via a sine-like curve:
    // scale = 1 + (pulseScale-1) * sin(pi * t) across each half-step.
    await _pulseController.forward();

    if (!mounted) return;
    _blinkController.repeat(reverse: true);
  }

  double _pulseScaleValue() {
    // Oscillate around 1.0 so we visibly grow AND shrink several times.
    // scale = 1 + a * sin(2π * count * t)
    final count = widget.pulseCount <= 0 ? 0 : widget.pulseCount;
    if (count == 0) return 1.0;
    final a = (widget.pulseScale - 1.0).clamp(0.0, 1.0);
    final t = _pulseController.value;
    final s = math.sin(2 * math.pi * count * t); // -1..1
    return (1.0 + a * s).clamp(0.1, 10.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkController, _pulseController]),
      builder: (context, child) {
        // Blink: hide/show like the existing BlinkingDotWidget behavior.
        if (_blink.value < 0.5 && !_pulseController.isAnimating) {
          return const SizedBox.shrink();
        }

        final scale =
            _pulseController.isAnimating ? _pulseScaleValue() : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(widget.color, Colors.white, 0.32) ?? widget.color,
                  Color.lerp(widget.color, Colors.black, 0.22) ?? widget.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.24),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
              color: widget.borderColor != null ? null : widget.color,
              border: widget.borderColor != null
                  ? Border.all(
                      color: widget.borderColor!,
                      width: widget.borderWidth,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

/// Orb gradient + neumorphic depth + specular wash (no outer halo — unlike FAB).
///
/// Diameter matches the stock bar (28px icon + 8px [Padding] on each side ≈ 44).
/// Slight downward shift brings the disk back toward the curved bar like pre-3D.
class _CurvedNavActiveOrb extends StatelessWidget {
  const _CurvedNavActiveOrb({
    required this.baseColor,
    required this.child,
  });

  final Color baseColor;
  final Widget child;

  static const double _diameter = 44;

  /// Nudges the active disk toward the menu curve (package [Material] read smaller).
  static const double _nudgeTowardCurveY = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(0, _nudgeTowardCurveY),
      child: SizedBox(
        width: _diameter,
        height: _diameter,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    baseColor,
                  ),
                  boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ThreeDSurfaceStyle.surfaceRadialHighlightGradient(
                    theme.brightness,
                  ),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
