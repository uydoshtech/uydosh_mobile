import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart" show AppColors, BlueThemeColors;
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class CustomCurvedNavigationBar extends StatefulWidget {
  const CustomCurvedNavigationBar({
    required this.currentIndex, required this.onTap, required this.navigationKey, required this.isAuthenticated, super.key,
    this.hasUnreadMessages = false,
  });

  final int currentIndex;
  final Function(int) onTap;
  final GlobalKey<CurvedNavigationBarState> navigationKey;
  final bool isAuthenticated;
  final bool hasUnreadMessages;

  @override
  State<CustomCurvedNavigationBar> createState() =>
      _CustomCurvedNavigationBarState();
}

class _CustomCurvedNavigationBarState extends State<CustomCurvedNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final items = _buildNavigationItems(widget.isAuthenticated);

    return CurvedNavigationBar(
      key: widget.navigationKey,
      index: _getAdjustedIndex(widget.currentIndex, widget.isAuthenticated),
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
    );
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

  // Build navigation items based on authentication status
  List<Widget> _buildNavigationItems(bool isAuthenticated) {
    // Always show 4 tabs for consistent layout
    // Curved bar positions: Home(0), Favorites(1), Messages(2), Create(3)
    // All items are always visible and clickable, but redirect to auth if not authenticated
    final items = [
      _buildNavigationItem(Icons.home, "home", widget.currentIndex == 0),
      _buildNavigationItem(
        Icons.favorite,
        "favorites",
        widget.currentIndex == 1,
      ), // Favorites always visible, redirects to auth if not authenticated
      _buildConversationsItem(), // Messages always visible, redirects to auth if not authenticated
      _buildNavigationItem(
        Icons.add,
        "create_listing",
        widget.currentIndex == 3,
      ), // Create always visible, redirects to auth if not authenticated
    ];

    return items;
  }

  // Build conversations item (selectable, like other navigation items)
  Widget _buildConversationsItem() {
    final isSelected = widget.currentIndex == 2; // Conversations is at index 2
    final iconColor = isSelected ? Colors.white : _getIconColor(context);
    final textColor = isSelected ? Colors.white : _getTextColor(context);

    final bubbleIcon = ThemeIcon(
      CupertinoIcons.bubble_left_bubble_right,
      size: 28,
      color: iconColor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use the same structure as other navigation items for consistent positioning
        if (isSelected)
          _CurvedNavActiveOrb(
            baseColor: _getButtonBackgroundColor(context),
            child: Stack(
              children: [
                bubbleIcon,
                if (widget.hasUnreadMessages)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: BlinkingDotWidget(
                      color: AppColors.success,
                      size: 13,
                      duration: Duration(milliseconds: 750),
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
              ],
            ),
          )
        else
          Stack(
            children: [
              bubbleIcon,
              if (widget.hasUnreadMessages)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: BlinkingDotWidget(
                    color: AppColors.success,
                    size: 13,
                    duration: Duration(milliseconds: 750),
                    borderColor: Colors.white,
                    borderWidth: 2,
                  ),
                ),
            ],
          ),
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

  // Map the current index to the curved navigation bar index
  int _getAdjustedIndex(int currentIndex, bool isAuthenticated) {
    // Navigation mapping: Home(0), Favorites(1), Conversations(2), Create(3)
    // The curved bar has 4 items: Home(0), Favorites(1), Messages(2), Create(3)
    return currentIndex;
  }

  // Handle navigation taps - redirect to auth if not authenticated for protected features
  void _handleNavigationTap(int index, bool isAuthenticated) {
    // Home item (index 0) - always accessible
    if (index == 0) {
      widget.onTap(0);
      return;
    }

    // Favorites item (index 1) - redirect to auth if not authenticated, then go to home
    if (index == 1) {
      if (isAuthenticated) {
        widget.onTap(1);
      } else {
        _launchAuthWizard(context);
      }
      return;
    }

    // Conversations/Messages item (index 2) - redirect to auth if not authenticated, then go to home
    if (index == 2) {
      if (isAuthenticated) {
        widget.onTap(2);
      } else {
        _launchAuthWizard(context);
      }
      return;
    }

    // Create Listing item (index 3) - redirect to auth if not authenticated, then go to home
    if (index == 3) {
      if (isAuthenticated) {
        widget.onTap(3);
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
      // Blue theme - use lighter blue for curved part
      return BlueThemeColors.primaryLight;
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
      // Blue theme - use darker blue for selected button
      return BlueThemeColors.primaryDark;
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
