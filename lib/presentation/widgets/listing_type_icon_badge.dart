import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A simple icon-only badge for displaying listing type information
/// Shows only the icon without any text, perfect for compact displays
class ListingTypeIconBadge extends StatelessWidget {
  const ListingTypeIconBadge({
    required this.listingTypeCode,
    super.key,
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
  });

  final String listingTypeCode;
  final double size;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final color = ListingTypeHelper.getColor(listingTypeCode);
    final icon = ListingTypeHelper.getIcon(listingTypeCode);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: ThemeIcon(icon, color: color, size: size),
    );
  }
}

/// Helper class for listing type utilities
/// Centralizes all listing type logic: colors, icons, text, and ID mapping
class ListingTypeHelper {
  /// Get the color for a listing type code
  static Color getColor(String code) {
    // Check if we're in blue theme to use better contrasting colors
    if (ThemeState().isBlueTheme) {
      switch (code) {
        case "room_needed":
          return BlueThemeColors
              .secondaryLight; // Lighter teal for better contrast
        case "roommate_needed":
          return BlueThemeColors.warning; // Green for better contrast
        default:
          return BlueThemeColors.iconDisabled;
      }
    } else {
      // Default colors for other themes
      switch (code) {
        case "room_needed":
          return AppColors.primary;
        case "roommate_needed":
          return AppColors.warning;
        default:
          return Colors.grey;
      }
    }
  }

  /// Get the icon for a listing type code
  static IconData getIcon(String code) {
    switch (code) {
      case "room_needed":
        return Icons.home;
      case "roommate_needed":
        return Icons.people;
      default:
        return Icons.help_outline;
    }
  }
}
