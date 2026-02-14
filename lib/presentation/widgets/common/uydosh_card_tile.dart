import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// A reusable card with a list tile (icon, title, optional trailing arrow).
/// Used for section navigation (e.g. admin panel).
class UydoshCardTile extends StatelessWidget {
  const UydoshCardTile({
    required this.icon,
    required this.title,
    super.key,
    this.onTap,
    this.elevation = 3,
    this.borderRadius,
  });

  final IconData icon;
  final Widget title;
  final VoidCallback? onTap;
  final double elevation;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black,
        ),
        title: title,
        trailing:
            onTap != null
                ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                )
                : null,
        onTap:
            onTap != null
                ? () {
                  HapticFeedbackUtils.selectionClick();
                  onTap!();
                }
                : null,
      ),
    );
  }
}
