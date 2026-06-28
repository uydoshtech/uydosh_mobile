import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Gender selector with side-by-side toggle buttons (male / female).
class GenderPicker extends StatelessWidget {
  const GenderPicker({
    required this.selectedGender,
    required this.onGenderChanged,
    super.key,
    this.height = 56,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
    this.unselectedLabelKey = "not_selected",
    this.scrollController,
    this.useGlassPlate = false,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;
  final String unselectedLabelKey;
  final FixedExtentScrollController? scrollController;
  final bool useGlassPlate;

  List<_GenderOption> get _options {
    if (includeUnselected) {
      return [
        _GenderOption(1, "male", Icons.male, AppColors.genderMale),
        _GenderOption(2, "female", Icons.female, AppColors.genderFemale),
        _GenderOption(
          0,
          unselectedLabelKey,
          Icons.remove_circle_outline,
          AppColors.genderOther,
        ),
      ];
    }
    return [
      _GenderOption(1, "male", Icons.male, AppColors.genderMale),
      _GenderOption(2, "female", Icons.female, AppColors.genderFemale),
    ];
  }

  Widget _buildOptionButton(BuildContext context, _GenderOption option) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final isSelected = selectedGender == option.value;
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    final textColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurface;
    final iconColor = option.iconColor;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        FocusScope.of(context).unfocus();
        HapticFeedbackUtils.impact();
        SendSoundUtils.playSelectionSound();
        onGenderChanged(option.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: includeUnselected ? 8 : 12,
          vertical: includeUnselected ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? null : baseColor,
          gradient: isSelected
              ? ThreeDSurfaceStyle.surfaceGradient(context, baseColor)
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? ThreeDSurfaceStyle.elevatedShadows(context)
              : ThreeDSurfaceStyle.insetRecessedShadows(context),
          border: isSelected
              ? Border.all(
                  color: AuthWizardTheme.getSelectedButtonBorderColor(),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeIcon(option.icon, color: iconColor, size: 20),
            SizedBox(width: includeUnselected ? 6 : 8),
            Flexible(
              child: L10n.text(
                option.labelKey,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: includeUnselected ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    final buttons = Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: includeUnselected ? 8 : 12),
          Expanded(child: _buildOptionButton(context, options[i])),
        ],
      ],
    );

    if (useGlassPlate && ThemeState().usesLiquidGlassChrome) {
      return LiquidGlassPlate(
        height: height,
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        padding: const EdgeInsets.all(4),
        child: buttons,
      );
    }

    return SizedBox(height: height, child: buttons);
  }
}

class _GenderOption {
  const _GenderOption(this.value, this.labelKey, this.icon, this.iconColor);

  final int value;
  final String labelKey;
  final IconData icon;
  final Color iconColor;
}
