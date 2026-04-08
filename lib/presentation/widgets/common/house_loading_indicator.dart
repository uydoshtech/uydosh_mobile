import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A loading indicator that displays a rotating house icon
/// Perfect for real estate and housing apps when loading listings or responses
/// Automatically adapts to the current app theme
class HouseLoadingIndicator extends StatefulWidget {
  const HouseLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.padding,
    this.text,
    this.textStyle,
    this.showText = false,
    this.rotationDuration,
  });

  /// Creates a house loading indicator with text below it
  const HouseLoadingIndicator.withText({
    required this.text,
    super.key,
    this.size,
    this.color,
    this.padding,
    this.textStyle,
    this.showText = true,
    this.rotationDuration,
  });

  final double? size;
  final Color? color;
  final EdgeInsets? padding;
  final String? text;
  final TextStyle? textStyle;
  final bool showText;
  final Duration? rotationDuration;

  @override
  State<HouseLoadingIndicator> createState() => _HouseLoadingIndicatorState();
}

class _HouseLoadingIndicatorState extends State<HouseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration:
          widget.rotationDuration ?? AppConfig.defaultHouseRotationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start the rotation animation
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// Get theme-aware color for the loading indicator
  Color _getThemeAwareColor() {
    // If a specific color is provided, use it
    if (widget.color != null) {
      return widget.color!;
    }

    // Otherwise, automatically detect theme and use appropriate color
    try {
      final themeState = ThemeState();

      Color selectedColor;
      if (themeState.currentTheme == "blue") {
        selectedColor = AppColors.textLight; // White for blue theme
      } else if (themeState.currentTheme == "light") {
        selectedColor = AppColors.textDark; // Black for light theme
      } else {
        selectedColor = AppColors.textLight; // White for non-light theme
      }

      return selectedColor;
    } catch (e) {
      return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _getThemeAwareColor();
    final effectiveSize = widget.size ?? AppConfig.defaultLoadingIndicatorSize;
    final effectivePadding = widget.padding ?? EdgeInsets.zero;

    Widget indicator = AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159, // Full 360° rotation
          child: ThemeIcon(Icons.home, size: effectiveSize, color: effectiveColor),
        );
      },
    );

    if (widget.showText && widget.text != null) {
      indicator = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            widget.text!,
            style:
                widget.textStyle ??
                TextStyle(
                  color: effectiveColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    if (effectivePadding != EdgeInsets.zero) {
      indicator = Padding(padding: effectivePadding, child: indicator);
    }

    return indicator;
  }
}

/// Convenience widget for a centered house loading indicator
class CenteredHouseLoadingIndicator extends StatelessWidget {
  const CenteredHouseLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.text,
    this.textStyle,
    this.rotationDuration,
  });

  final double? size;
  final Color? color;
  final String? text;
  final TextStyle? textStyle;
  final Duration? rotationDuration;

  @override
  Widget build(BuildContext context) {
    // Create a key that changes with the theme to force rebuilds
    final themeState = ThemeState();
    final themeKey = ValueKey(
      "${themeState.currentTheme}_${themeState.isBlueTheme}_${themeState.isLightTheme}",
    );

    return Center(
      key: themeKey,
      child: HouseLoadingIndicator.withText(
        size: size,
        color: color,
        text: text,
        textStyle: textStyle,
        rotationDuration: rotationDuration,
      ),
    );
  }
}
