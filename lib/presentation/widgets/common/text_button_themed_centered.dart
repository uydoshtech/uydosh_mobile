import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/button_icon_label.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A themed text button where the label stays centered even with icons.
class TextButtonThemedCentered extends StatelessWidget {
  const TextButtonThemedCentered({
    required this.onPressed,
    required this.child,
    super.key,
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
            isLightTheme ? Colors.black87 : AppColors.textLight70,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: padding,
      ).merge(style),
      child: child,
    );
  }
}

class TextButtonThemedCenteredFactory {
  static Widget iconText({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
    double iconSize = 24,
  }) {
    final slotWidth = iconSize + 8;
    return TextButtonThemedCentered(
      onPressed: onPressed,
      padding: padding,
      style: style,
      child: ButtonIconLabel(
        slotWidth: slotWidth,
        leading: ThemeIcon(icon, size: iconSize),
        label: Text(text),
      ),
    );
  }

  static Widget textIcon({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
    double iconSize = 24,
  }) {
    final slotWidth = iconSize + 8;
    return TextButtonThemedCentered(
      onPressed: onPressed,
      padding: padding,
      style: style,
      child: ButtonIconLabel(
        slotWidth: slotWidth,
        trailing: ThemeIcon(icon, size: iconSize),
        label: Text(text),
      ),
    );
  }
}

