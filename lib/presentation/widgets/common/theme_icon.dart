import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ThemeIcon extends StatelessWidget {
  const ThemeIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.useThemeColor = true,
    this.semanticLabel,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final bool useThemeColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: _getIconColor(),
      semanticLabel: semanticLabel,
    );
  }

  // Theme-dependent icon color
  Color _getIconColor() {
    // If explicit color is provided, use it
    if (color != null) {
      return color!;
    }

    // If not using theme color, return default
    if (!useThemeColor) {
      return Colors.grey;
    }

    // Theme-aware colors
    if (ThemeState().isLightTheme) {
      return Colors.black87; // Dark icons for light theme
    } else if (ThemeState().isBlueTheme) {
      return Colors.white; // White icons for blue theme
    } else {
      return Colors.white; // Default icons for non-light theme
    }
  }
}

// Convenience factory for common icon patterns
class ThemeIconFactory {
  // Basic theme-aware icon
  static Widget icon({
    required IconData icon,
    double? size,
    Color? color,
    bool useThemeColor = true,
    String? semanticLabel,
  }) {
    return ThemeIcon(
      icon: icon,
      size: size,
      color: color,
      useThemeColor: useThemeColor,
      semanticLabel: semanticLabel,
    );
  }

  // Navigation icons with consistent sizing
  static Widget navigation({
    required IconData icon,
    double size = 24.0,
    Color? color,
  }) {
    return ThemeIcon(icon: icon, size: size, color: color);
  }

  // Action icons (buttons, etc.)
  static Widget action({
    required IconData icon,
    double size = 20.0,
    Color? color,
  }) {
    return ThemeIcon(icon: icon, size: size, color: color);
  }

  // Large display icons
  static Widget display({
    required IconData icon,
    double size = 64.0,
    Color? color,
  }) {
    return ThemeIcon(icon: icon, size: size, color: color);
  }

  // Small detail icons
  static Widget detail({
    required IconData icon,
    double size = 16.0,
    Color? color,
  }) {
    return ThemeIcon(icon: icon, size: size, color: color);
  }

  // Status icons with semantic colors
  static Widget status({
    required IconData icon,
    double size = 20.0,
    bool isSuccess = false,
    bool isWarning = false,
    bool isError = false,
    bool isInfo = false,
  }) {
    Color? statusColor;

    if (isSuccess) {
      statusColor = AppColors.statusActive;
    } else if (isWarning) {
      statusColor = AppColors.warning;
    } else if (isError) {
      statusColor = AppColors.error;
    } else if (isInfo) {
      statusColor = AppColors.primary;
    }

    return ThemeIcon(
      icon: icon,
      size: size,
      color: statusColor,
      useThemeColor: statusColor == null,
    );
  }

  // Amenity icons with consistent styling
  static Widget amenity({
    required IconData icon,
    double size = 24.0,
    bool isSelected = false,
  }) {
    Color? amenityColor;

    if (isSelected) {
      amenityColor = AppColors.primary;
    }

    return ThemeIcon(
      icon: icon,
      size: size,
      color: amenityColor,
      useThemeColor: amenityColor == null,
    );
  }
}
