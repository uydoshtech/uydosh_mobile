import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class PhotoIcon extends StatelessWidget {
  const PhotoIcon({
    super.key,
    this.size = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.borderRadius = 6,
  });

  final double size;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconColor = _photoIconColor();
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _photoIconBackgroundColor(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: iconColor, width: 1.0),
      ),
      child: ThemeIcon(Icons.camera_alt, color: iconColor, size: size),
    );
  }

  Color _photoIconColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White icon for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black icon for light theme
    } else {
      return AppColors.iconPrimary; // Primary icon for default theme
    }
  }

  Color _photoIconBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.iconPrimary.withValues(
        alpha: 0.1,
      ); // Semi-transparent primary background
    } else if (ThemeState().isLightTheme) {
      return Colors.transparent; // No background for light theme
    } else {
      return AppColors.iconPrimary.withValues(
        alpha: 0.1,
      ); // Semi-transparent primary background
    }
  }
}
