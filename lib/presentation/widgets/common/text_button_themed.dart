import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A themed text button with consistent styling
class TextButtonThemed extends StatelessWidget {
  const TextButtonThemed({
    required this.onPressed, required this.child, super.key,
    this.padding,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;

    return TextButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedbackUtils.impact();
              onPressed!();
            },
      style: TextButton.styleFrom(
        foregroundColor:
            isLightTheme
                ? Colors
                    .black87 // Black text for light theme
                : AppColors.textLight70, // White text for dark theme
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: padding,
      ).merge(style),
      child: child,
    );
  }
}

/// Factory for creating themed text buttons with common patterns
class TextButtonThemedFactory {
  /// Creates a text button with text only
  static Widget text({
    required VoidCallback? onPressed,
    required String text,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
  }) {
    return TextButtonThemed(
      onPressed: onPressed,
      padding: padding,
      style: style,
      child: Text(text),
    );
  }

  /// Creates a text button with icon and text
  static Widget iconText({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
  }) {
    return TextButtonThemed(
      onPressed: onPressed,
      padding: padding,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [ThemeIcon(icon), const SizedBox(width: 8), Text(text)],
      ),
    );
  }

  /// Creates a text button with text and icon (icon on the right)
  static Widget textIcon({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
  }) {
    return TextButtonThemed(
      onPressed: onPressed,
      padding: padding,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(text), const SizedBox(width: 8), ThemeIcon(icon)],
      ),
    );
  }

  /// Creates a text button with icon only
  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
  }) {
    return TextButtonThemed(
      onPressed: onPressed,
      padding: padding,
      style: style,
      child: ThemeIcon(icon),
    );
  }
}
