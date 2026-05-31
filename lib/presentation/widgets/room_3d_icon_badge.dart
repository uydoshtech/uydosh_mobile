import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Compact 3D-room indicator for listing rows (matches detail screen icon).
class Room3dIconBadge extends StatelessWidget {
  const Room3dIconBadge({
    super.key,
    this.size = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.borderRadius = 8,
    this.label,
    this.labelFontSize = 13,
  });

  final double size;
  final EdgeInsets padding;
  final double borderRadius;

  /// Optional text shown next to the icon (e.g. "3D").
  final String? label;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    // Blue theme uses a very dark primary (#1E3A5F) — same as cards — so the
    // icon must be light (matches other blue-theme row accents).
    final iconColor =
        isBlueTheme ? BlueThemeColors.textPrimary : theme.colorScheme.primary;
    final borderColor = isBlueTheme
        ? BlueThemeColors.textPrimary.withValues(alpha: 0.45)
        : theme.colorScheme.primary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(Icons.view_in_ar, color: iconColor, size: size),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(
              label!,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
