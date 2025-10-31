import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _getPhotoIconBackgroundColor(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _getPhotoIconColor(), width: 1.0),
      ),
      child: Icon(Icons.camera_alt, color: _getPhotoIconColor(), size: size),
    );
  }

  // Theme-dependent color method for photo icon
  Color _getPhotoIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White icon for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black icon for light theme
    } else {
      return AppColors.iconPrimary; // Purple icon for purple theme
    }
  }

  // Theme-dependent color method for photo icon background
  Color _getPhotoIconBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.iconPrimary.withValues(
        alpha: 0.1,
      ); // Semi-transparent purple background
    } else if (ThemeState().isLightTheme) {
      return Colors.transparent; // No background for light theme
    } else {
      return AppColors.iconPrimary.withValues(
        alpha: 0.1,
      ); // Semi-transparent purple background
    }
  }
}
