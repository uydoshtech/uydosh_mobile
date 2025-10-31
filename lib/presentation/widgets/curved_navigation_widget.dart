import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart"
    show AppColors, BlueThemeColors;
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class CustomCurvedNavigationBar extends StatefulWidget {
  const CustomCurvedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navigationKey,
    required this.isAuthenticated,
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
      buttonBackgroundColor: _getButtonBackgroundColor(
        context,
      ), // Theme-dependent button color
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: iconColor),
        if (!isSelected) ...[
          const SizedBox(height: 2),
          ListenableBuilder(
            listenable: LanguageState(),
            builder: (context, child) {
              return Text(
                LanguageAwareStringHelper.getCurrent(context, labelKey),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use the same structure as other navigation items for consistent positioning
        Stack(
          children: [
            Icon(
              CupertinoIcons.bubble_left_bubble_right,
              size: 28,
              color: iconColor,
            ),
            // Blinking red dot indicator for unread messages
            if (widget.hasUnreadMessages)
              const Positioned(
                right: 0,
                top: 0,
                child: BlinkingDotWidget(
                  color: Colors.red,
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
                LanguageAwareStringHelper.getCurrent(context, "conversations"),
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
    Navigator.of(context)
        .pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthWizardScreen()),
        )
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
      // Purple theme (default) - use existing light purple
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
      // Purple theme (default) - use existing dark purple
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
      // Purple theme (default) - use existing primary purple
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
