import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// A reusable component for displaying listing type information
/// Handles both badge display and utility functions for listing types
class ListingTypeBadge extends StatelessWidget {
  const ListingTypeBadge({
    required this.listingTypeCode,
    super.key,
    this.showIcon = true,
    this.showText = true,
    this.fontSize,
    this.padding,
  });

  final String listingTypeCode;
  final bool showIcon;
  final bool showText;
  final double? fontSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final color = ListingTypeHelper.getColor(listingTypeCode);
    final icon = ListingTypeHelper.getIcon(listingTypeCode);
    final text = ListingTypeHelper.getText(context, listingTypeCode);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, color: color, size: 18),
            if (showText) const SizedBox(width: 4),
          ],
          if (showText)
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: fontSize ?? 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper class for listing type utilities
/// Centralizes all listing type logic: colors, icons, text, and ID mapping
class ListingTypeHelper {
  /// Get the color for a listing type code
  static Color getColor(String code) {
    // Check if we"re in blue theme to use better contrasting colors
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

  /// Get the localized text for a listing type code
  static String getText(BuildContext context, String code) {
    final currentLanguage = L10n.currentLanguage;

    switch (code) {
      case "room_needed":
        return AppStrings.get("listing_type_room_needed", currentLanguage);
      case "roommate_needed":
        return AppStrings.get("listing_type_roommate_needed", currentLanguage);
      default:
        return "Unknown";
    }
  }

  /// Convert listing type code to ID (for API calls)
  static int getIdFromCode(String code) {
    switch (code) {
      case "room_needed":
        return 1;
      case "roommate_needed":
        return 2;
      default:
        return 0;
    }
  }

  /// Convert listing type ID to code
  static String getCodeFromId(int id) {
    switch (id) {
      case 1:
        return "room_needed";
      case 2:
        return "roommate_needed";
      default:
        return "unknown";
    }
  }

  /// Get all available listing types
  static List<String> getAllCodes() {
    return ["room_needed", "roommate_needed"];
  }

  /// Get all listing types with their display information
  static List<Map<String, dynamic>> getAllTypes(BuildContext context) {
    return getAllCodes()
        .map(
          (code) => {
            "code": code,
            "id": getIdFromCode(code),
            "text": getText(context, code),
            "color": getColor(code),
            "icon": getIcon(code),
          },
        )
        .toList();
  }
}

/// A simple widget for displaying just the listing type text
/// Useful for dropdown items or simple text display
class ListingTypeText extends StatelessWidget {
  const ListingTypeText({required this.listingTypeCode, super.key, this.style});

  final String listingTypeCode;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = ListingTypeHelper.getText(context, listingTypeCode);
    final color = ListingTypeHelper.getColor(listingTypeCode);

    return Text(
      text,
      style: style ?? TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }
}

/// A dropdown button specifically for selecting listing types
/// Handles all the logic for listing type selection
class ListingTypeDropdown extends StatelessWidget {
  const ListingTypeDropdown({
    required this.selectedValue,
    required this.onChanged,
    super.key,
    this.hintText,
  });

  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final types = ListingTypeHelper.getAllTypes(context);

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          types.map((type) {
            return DropdownMenuItem<String>(
              value: type["code"],
              child: Row(
                children: [
                  Icon(type["icon"], color: type["color"], size: 20),
                  const SizedBox(width: 8),
                  Text(type["text"]),
                ],
              ),
            );
          }).toList(),
    );
  }
}
