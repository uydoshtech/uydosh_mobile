import "package:flutter/material.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_dropdown.dart";

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
    final style = ListingTypeHelper.getBadgeStyle(listingTypeCode);
    final icon = ListingTypeHelper.getIcon(listingTypeCode);
    final text = ListingTypeHelper.getText(context, listingTypeCode);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            ThemeIcon(icon, color: style.foreground, size: 18),
            if (showText) const SizedBox(width: 4),
          ],
          if (showText)
            Text(
              text,
              style: TextStyle(
                color: style.foreground,
                fontSize: fontSize ?? 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Foreground, border, and fill colors for a listing-type badge.
class ListingTypeBadgeStyle {
  const ListingTypeBadgeStyle({
    required this.foreground,
    required this.border,
    required this.background,
  });

  final Color foreground;
  final Color border;
  final Color background;
}

/// Helper class for listing type utilities
/// Centralizes all listing type logic: colors, icons, text, and ID mapping
class ListingTypeHelper {
  /// High-contrast badge palette for the light theme (pale card surfaces).
  static const _lightRoomNeeded = ListingTypeBadgeStyle(
    foreground: Color(0xFF1565C0),
    border: Color(0xFF1565C0),
    background: Color(0xFFE3F2FD),
  );
  static const _lightRoommateNeeded = ListingTypeBadgeStyle(
    foreground: Color(0xFFE65100),
    border: Color(0xFFE65100),
    background: Color(0xFFFFF3E0),
  );
  static const _lightGroupForming = ListingTypeBadgeStyle(
    foreground: Color(0xFF6A1B9A),
    border: Color(0xFF6A1B9A),
    background: Color(0xFFF3E5F5),
  );

  /// Badge colors tuned for the current theme.
  static ListingTypeBadgeStyle getBadgeStyle(String code) {
    if (ThemeState().isLightTheme) {
      return switch (code) {
        "room_needed" => _lightRoomNeeded,
        "roommate_needed" => _lightRoommateNeeded,
        "group_forming" => _lightGroupForming,
        _ => const ListingTypeBadgeStyle(
          foreground: Colors.grey,
          border: Colors.grey,
          background: Color(0xFFF5F5F5),
        ),
      };
    }

    final color = getColor(code);
    return ListingTypeBadgeStyle(
      foreground: color,
      border: color,
      background: color.withValues(alpha: 0.1),
    );
  }

  /// Get the color for a listing type code
  static Color getColor(String code) {
    if (ThemeState().isLightTheme) {
      return getBadgeStyle(code).foreground;
    }

    // Check if we"re in blue theme to use better contrasting colors
    if (ThemeState().isBlueTheme) {
      switch (code) {
        case "room_needed":
          return BlueThemeColors
              .secondaryLight; // Lighter teal for better contrast
        case "roommate_needed":
          return BlueThemeColors.warning; // Green for better contrast
        case "group_forming":
          return BlueThemeColors.secondaryLight;
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
        case "group_forming":
          return AppColors.primary;
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
      case "group_forming":
        return Icons.groups_2_outlined;
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
      case "group_forming":
        return AppStrings.get("listing_type_group_forming", currentLanguage);
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
        return ListingTypeIds.roommateNeeded;
      case "group_forming":
        return ListingTypeIds.groupForming;
      default:
        return 0;
    }
  }

  /// Convert listing type ID to code
  static String getCodeFromId(int id) {
    switch (id) {
      case 1:
        return "room_needed";
      case ListingTypeIds.roommateNeeded:
        return "roommate_needed";
      case ListingTypeIds.groupForming:
        return "group_forming";
      default:
        return "unknown";
    }
  }

  /// Get all available listing types
  static List<String> getAllCodes() {
    return ["room_needed", "roommate_needed", "group_forming"];
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

    return UydoshDropdownFormField<String>(
      value: selectedValue.isEmpty ? null : selectedValue,
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
                  ThemeIcon(type["icon"], color: type["color"], size: 20),
                  const SizedBox(width: 8),
                  Text(type["text"]),
                ],
              ),
            );
          }).toList(),
    );
  }
}
