import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_slider.dart";

/// Profile-section styled wrapper around [UydoshSlider]. Uses a raised
/// neumorphic surface consistent with the other profile controls.
class ProfileSliderControl extends StatelessWidget {
  const ProfileSliderControl({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    super.key,
    this.icon,
    this.divisions,
    this.labels,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final int min;
  final int max;
  final IconData? icon;
  final int? divisions;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    final currentValue = value ?? min;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: UydoshSlider(
        label: label,
        value: currentValue,
        onChanged: onChanged,
        min: min,
        max: max,
        icon: icon,
        divisions: divisions,
        labels: labels,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
