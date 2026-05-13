import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart" show AppColors, BlueThemeColors;
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/curved_nav_active_orb.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

/// Shell bottom navigation with theme-aware colors for [CurvedNavigationBar].
///
class CustomCurvedNavigationBar extends StatefulWidget {
  const CustomCurvedNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.navigationKey,
    required this.isAuthenticated,
    super.key,
    this.hasUnreadMessages = false,
    this.incomingMessageTravelDotTrigger = 0,
    this.onCreatePressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  /// [GlobalKey] for the underlying [CurvedNavigationBar] (package state), e.g.
  /// to drive its animation API. Must be passed as [CurvedNavigationBar.key].
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

class _NavPalette {
  const _NavPalette({
    required this.curvedBarColor,
    required this.activeOrbBase,
    required this.notchBackground,
    required this.unselectedLabelText,
    required this.disabled,
  });

  final Color curvedBarColor;
  final Color activeOrbBase;
  final Color notchBackground;

  /// Color for captions under unselected tabs.
  final Color unselectedLabelText;
  final Color disabled;

  factory _NavPalette.fromTheme(ThemeState theme) {
    if (theme.isBlueTheme) {
      return _NavPalette(
        curvedBarColor:
            BlueThemeColors.navigationBackground.withValues(alpha: 0.75),
        activeOrbBase: BlueThemeColors.primaryLight,
        notchBackground: BlueThemeColors.primary.withValues(alpha: 0.75),
        unselectedLabelText: AppColors.textLight,
        disabled: AppColors.textLight.withValues(alpha: 0.4),
      );
    }
    if (theme.isLightTheme) {
      return _NavPalette(
        curvedBarColor: Colors.grey[600]!,
        activeOrbBase: Colors.black,
        notchBackground: Colors.white,
        unselectedLabelText: Colors.white,
        disabled: Colors.black.withValues(alpha: 0.4),
      );
    }
    return _NavPalette(
      curvedBarColor: AppColors.primaryLight,
      activeOrbBase: AppColors.primaryDark,
      notchBackground: AppColors.primary,
      unselectedLabelText: AppColors.textLight,
      disabled: AppColors.textLight.withValues(alpha: 0.4),
    );
  }
}

/// Unread dot color — matches [ThemeState]'s `unreadIndicatorColor` extension
/// in `theme_helper.dart` (import avoided here; keep in sync when tuning).
Color _navUnreadIndicatorColor(ThemeState theme) {
  if (theme.isBlueTheme) return const Color(0xFF34D399); // emerald-400
  return AppColors.success;
}

class _CustomCurvedNavigationBarState extends State<CustomCurvedNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final themeState = ThemeState();
    final palette = _NavPalette.fromTheme(themeState);
    final items = _buildNavigationItems(palette, themeState);

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
                  key: widget.navigationKey,
                  index: widget.currentIndex,
                  height: 70.0,
                  color: palette.curvedBarColor,
                  // Active “disk” is drawn by [CurvedNavActiveOrb] on the selected item;
                  // keep the package [Material] transparent so gradients/shadows show.
                  buttonBackgroundColor: Colors.transparent,
                  backgroundColor: palette.notchBackground,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 300),
                  onTap: (index) {
                    _handleNavigationTap(index, widget.isAuthenticated);
                  },
                  // Allow all index changes; authentication is enforced in _handleNavigationTap.
                  letIndexChange: (_) => true,
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

  Widget _columnForNavItem({
    required _NavPalette palette,
    required bool isSelected,
    required String labelKey,
    required Widget icon,
    Color? unselectedLabelColor,
  }) {
    final labelColor = unselectedLabelColor ?? palette.unselectedLabelText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          CurvedNavActiveOrb(
            baseColor: palette.activeOrbBase,
            child: icon,
          )
        else
          icon,
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
                  color: labelColor,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationItem(
    _NavPalette palette,
    IconData icon,
    String labelKey,
    bool isSelected, {
    bool isDisabled = false,
  }) {
    final iconColor = isDisabled ? palette.disabled : Colors.white;

    final iconWidget = ThemeIcon(icon, size: 28, color: iconColor);

    return _columnForNavItem(
      palette: palette,
      isSelected: isSelected,
      labelKey: labelKey,
      icon: iconWidget,
      unselectedLabelColor: isDisabled ? palette.disabled : null,
    );
  }

  // Build navigation items. Layout (post 2026-Q2 nav rework):
  //   0 = Housing      (public)
  //   1 = Services hub (public — gates auth at each action boundary)
  //   2 = Messages     (auth required)
  //   3 = Create       (auth required)
  //
  // Favorites was removed from the bar (still reachable from drawer/profile).
  List<Widget> _buildNavigationItems(
    _NavPalette palette,
    ThemeState themeState,
  ) {
    return <Widget>[
      _buildNavigationItem(palette, Icons.home, "nav_housing", widget.currentIndex == 0),
      _buildNavigationItem(
        palette,
        Icons.handyman_outlined,
        "menu_gigs",
        widget.currentIndex == 1,
      ),
      _buildConversationsItem(palette, themeState),
      _buildNavigationItem(
        palette,
        Icons.add,
        "create_listing",
        widget.currentIndex == 3,
      ),
    ];
  }

  // Build conversations item (selectable, like other navigation items)
  Widget _buildConversationsItem(_NavPalette palette, ThemeState themeState) {
    final isSelected = widget.currentIndex == 2; // Conversations is at index 2
    final unreadColor = _navUnreadIndicatorColor(themeState);

    final bubbleIcon = ThemeIcon(
      CupertinoIcons.bubble_left_bubble_right,
      size: 28,
      color: Colors.white,
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

    return _columnForNavItem(
      palette: palette,
      isSelected: isSelected,
      labelKey: "conversations",
      icon: iconWithBadge,
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
    HapticFeedbackUtils.impact();
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
}
