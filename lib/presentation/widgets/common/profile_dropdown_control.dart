import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_dropdown.dart";

export "package:uy_dosh/presentation/widgets/common/uydosh_dropdown.dart"
    show DropdownOption;

/// Profile-section styled wrapper around [UydoshDropdown].
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
    final isBlueTheme = ThemeState().isBlueTheme;
    final sectionBackground =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceContainerHighest;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: sectionBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: UydoshDropdown(
        label: label,
        value: value,
        options: options,
        onChanged: onChanged,
        icon: icon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
