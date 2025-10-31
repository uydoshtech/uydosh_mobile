import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ProfileDropdownControl extends StatelessWidget {
  const ProfileDropdownControl({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
    this.icon,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<DropdownOption> options;
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
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color:
                      isBlueTheme
                          ? Colors.white
                          : (isLightTheme
                              ? Colors.grey[600]
                              : Colors.grey[400]),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      isBlueTheme
                          ? Colors.white
                          : (isLightTheme
                              ? Colors.grey[800]
                              : Colors.grey[200]),
                ),
                dropdownColor:
                    isBlueTheme
                        ? Colors.blue[600]
                        : (isLightTheme ? Colors.white : Colors.grey[800]),
                items:
                    options.map((option) {
                      return DropdownMenuItem<String?>(
                        value: option.value,
                        child: Text(
                          option.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                isBlueTheme
                                    ? Colors.white
                                    : (isLightTheme
                                        ? Colors.grey[800]
                                        : Colors.grey[200]),
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownOption {
  const DropdownOption({required this.value, required this.label});

  final String? value;
  final String label;
}
