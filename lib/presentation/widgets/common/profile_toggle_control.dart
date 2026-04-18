import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_toggle.dart";

/// Profile-section styled wrapper around [UydoshToggle]. Uses a raised
/// neumorphic surface so it matches the other profile controls.
class ProfileToggleControl extends StatelessWidget {
  const ProfileToggleControl({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
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
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: UydoshToggle(
        icon: icon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        iconColor:
            isBlueTheme ? Colors.white : theme.colorScheme.onSurfaceVariant,
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: isBlueTheme ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        value: value ?? false,
        onChanged: onChanged,
      ),
    );
  }
}
