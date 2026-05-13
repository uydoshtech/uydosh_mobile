import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_dropdown.dart";

export "package:uy_dosh/presentation/widgets/common/uydosh_dropdown.dart"
    show DropdownOption, UydoshDropdownChrome, UydoshDropdownFormField;

/// Profile-section styled wrapper around [UydoshDropdown]. Uses a raised
/// neumorphic surface ([ThreeDSurfaceStyle.elevatedShadows]) — no hard border
/// so it reads as a soft plate rather than a flat outlined tile.
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
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: UydoshDropdown(
        label: label,
        value: value,
        options: options,
        onChanged: onChanged,
        icon: icon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
