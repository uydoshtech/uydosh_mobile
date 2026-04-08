import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ThemeIcon extends StatelessWidget {
  const ThemeIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.useThemeColor = true,
    this.semanticLabel,
    this.textDirection,
  });

  final IconData? icon;
  final double? size;
  final Color? color;
  final bool useThemeColor;
  final String? semanticLabel;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        return Icon(
          icon,
          size: size,
          color: _resolveColor(theme),
          semanticLabel: semanticLabel,
          textDirection: textDirection,
        );
      },
    );
  }

  Color? _resolveColor(ThemeData theme) {
    if (color != null) return color;
    if (!useThemeColor) return Colors.grey;

    if (ThemeState().isBlueTheme) return Colors.white;
    if (ThemeState().isLightTheme) return Colors.black87;

    return theme.iconTheme.color ?? theme.colorScheme.onSurface;
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
      icon,
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
    return ThemeIcon(icon, size: size, color: color);
  }

  // Action icons (buttons, etc.)
  static Widget action({
    required IconData icon,
    double size = 20.0,
    Color? color,
  }) {
    return ThemeIcon(icon, size: size, color: color);
  }

  // Large display icons
  static Widget display({
    required IconData icon,
    double size = 64.0,
    Color? color,
  }) {
    return ThemeIcon(icon, size: size, color: color);
  }

  // Small detail icons
  static Widget detail({
    required IconData icon,
    double size = 16.0,
    Color? color,
  }) {
    return ThemeIcon(icon, size: size, color: color);
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
      icon,
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
      icon,
      size: size,
      color: amenityColor,
      useThemeColor: amenityColor == null,
    );
  }
}
