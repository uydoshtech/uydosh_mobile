import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class GhostButton extends StatelessWidget {
  const GhostButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.borderWidth = 2.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.textStyle,
    this.isOnboardingButton = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final bool isLoading;
  final bool isDisabled;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final TextStyle? textStyle;
  final bool isOnboardingButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: BorderSide(color: _getBorderColor(), width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: textStyle ?? const TextStyle(fontSize: 18),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                  ),
                )
                : child,
      ),
    );
  }

  // Theme-dependent color method for button background
  Color _getBackgroundColor() {
    if (ThemeState().isLightTheme) {
      return Colors.transparent; // Transparent for light theme (ghost button)
    } else if (ThemeState().isBlueTheme) {
      return Colors.transparent; // Transparent for blue theme (ghost button)
    } else {
      return Colors.transparent; // Default to transparent
    }
  }

  // Theme-dependent color method for button text and icon
  Color _getTextColor() {
    // Use custom text color if provided
    if (textColor != null) {
      return textColor!;
    }

    // Otherwise use theme-dependent color
    if (ThemeState().isLightTheme) {
      return Colors.black; // Black text for light theme (ghost button)
    } else if (ThemeState().isBlueTheme) {
      return Colors.white; // White text for blue theme (ghost button)
    } else {
      return Colors.white; // Default to white text
    }
  }

  // Theme-dependent color method for button border
  Color _getBorderColor() {
    // Use custom border color if provided
    if (borderColor != null) {
      return borderColor!;
    }

    // Otherwise use theme-dependent color
    if (ThemeState().isLightTheme) {
      return Colors.black; // Black border for light theme (ghost button)
    } else if (ThemeState().isBlueTheme) {
      return BlueThemeColors
          .buttonPrimary; // Blue border for blue theme (ghost button)
    } else {
      return BlueThemeColors.buttonPrimary; // Default border color
    }
  }
}

// Convenience factory for common button patterns
class GhostButtonFactory {
  // Icon + Text button
  static Widget iconText({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    Color? iconColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isOnboardingButton = false,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      iconColor: iconColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? textColor, size: iconSize),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Text only button
  static Widget text({
    required VoidCallback? onPressed,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    TextStyle? textStyle,
    bool isOnboardingButton = false,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      child: Text(text),
    );
  }

  // Icon only button
  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? iconColor,
    bool isOnboardingButton = false,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      iconColor: iconColor,
      isOnboardingButton: isOnboardingButton,
      child: Icon(icon, color: iconColor),
    );
  }
}
