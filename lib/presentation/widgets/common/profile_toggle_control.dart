import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ProfileToggleControl extends StatelessWidget {
  const ProfileToggleControl({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final isWhiteTheme = !isBlueTheme;
    final sectionBackground =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: sectionBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color:
                  isBlueTheme
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color:
                    isBlueTheme
                        ? Colors.white
                        : theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value ?? false,
            onChanged: onChanged,
            activeColor:
                isBlueTheme
                    ? BlueThemeColors.buttonPrimary
                    : Colors.white,
            activeTrackColor:
                isBlueTheme
                    ? BlueThemeColors.buttonPrimary.withValues(alpha: 0.3)
                    : Colors.black,
            inactiveThumbColor:
                isWhiteTheme ? Colors.white : theme.colorScheme.onSurfaceVariant,
            inactiveTrackColor:
                isWhiteTheme
                    ? theme.colorScheme.outline.withValues(alpha: 0.6)
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            trackOutlineColor:
                isWhiteTheme
                    ? MaterialStateProperty.resolveWith(
                      (states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.transparent
                              : theme.colorScheme.outline,
                    )
                    : null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
