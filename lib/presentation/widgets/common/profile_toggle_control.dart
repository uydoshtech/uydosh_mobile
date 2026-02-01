import "package:flutter/material.dart";
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
    final isLightTheme = ThemeState().isLightTheme;
    final isBlueTheme = ThemeState().isBlueTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            isBlueTheme
                ? Theme.of(context).colorScheme.primary
                : (isLightTheme ? Colors.grey[50] : Colors.grey[800]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isBlueTheme
                  ? Colors.blue[600]!
                  : (isLightTheme ? Colors.grey[300]! : Colors.grey[600]!),
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
                      : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
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
                        : (isLightTheme ? Colors.grey[800] : Colors.grey[200]),
              ),
            ),
          ),
          Switch(
            value: value ?? false,
            onChanged: onChanged,
            activeColor:
                isLightTheme ? Colors.white : (Colors.blue[600] ?? Colors.blue),
            activeTrackColor: isLightTheme ? Colors.black : Colors.blue[600],
            inactiveThumbColor: isLightTheme ? Colors.grey[400] : null,
            inactiveTrackColor: isLightTheme ? Colors.grey[600] : null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
