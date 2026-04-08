import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable navigation/menu row with icon, title, optional subtitle, and trailing arrow.
/// Used in settings, burger menu, and similar list UIs.
class UydoshMenuItem extends StatelessWidget {
  const UydoshMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.iconColor,
    this.textColor,
    this.trailingColor,
    this.trailing,
    this.useHapticFeedback = true,
  });

  final IconData icon;
  final Widget title;
  final VoidCallback onTap;
  final Widget? subtitle;
  final Color? iconColor;
  final Color? textColor;
  final Color? trailingColor;
  final Widget? trailing;
  final bool useHapticFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.iconTheme.color;
    final effectiveTrailing = trailing ??
        ThemeIcon(
          Icons.arrow_forward_ios,
          size: 16,
          color: trailingColor ?? theme.colorScheme.onSurfaceVariant,
        );

    return ListTile(
      leading: ThemeIcon(icon, color: effectiveIconColor),
      title: title,
      subtitle: subtitle,
      trailing: effectiveTrailing,
      onTap: () {
        if (useHapticFeedback) {
          HapticFeedbackUtils.impact();
        }
        onTap();
      },
    );
  }
}
