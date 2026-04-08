import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.textColor,
    this.textStyle,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? textColor; // Optional text color parameter
  final TextStyle? textStyle; // Optional text style parameter
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: textColor ?? _getTextColor(),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: _getBorderSide(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? _getTextColor(),
                    ),
                  ),
                )
                : child,
      ),
    );
  }

  // Theme-dependent color method for button background
  Color _getBackgroundColor() {
    if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    }
    return BlueThemeColors.buttonPrimary; // Blue for non-light themes
  }

  // Always use white text for solid appearance
  Color _getTextColor() {
    return Colors.white;
  }

  // Theme-dependent border method
  BorderSide? _getBorderSide() {
    return null; // No border for other themes
  }
}

// Convenience factory for common button patterns
class PrimaryButtonFactory {
  // Icon + Text button
  static Widget iconText({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? textColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(icon, size: iconSize),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
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
    Color? textColor,
    TextStyle? textStyle,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Text(text, style: textStyle),
    );
  }

  // Icon only button
  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? textColor,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      textColor: textColor,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: ThemeIcon(icon),
    );
  }
}
