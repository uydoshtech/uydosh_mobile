import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class GenderPicker extends StatelessWidget {
  const GenderPicker({
    required this.selectedGender, required this.onGenderChanged, super.key,
    this.height = 80,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;

  Color _getItemTextColor(BuildContext context, int gender) {
    final theme = Theme.of(context);
    final isSelected = selectedGender == gender;
    // Selected item: white (matches region/university spinners)
    if (isSelected && ThemeState().isBlueTheme) {
      return Colors.white;
    }
    // Unselected in blue theme: dimmer text
    if (ThemeState().isBlueTheme) {
      return theme.colorScheme.onSurfaceVariant;
    }
    return ThemeState().isBlueTheme ? Colors.white : Colors.black;
  }

  Color _getGenderIconColor(BuildContext context, int gender, bool isSelected) {
    final theme = Theme.of(context);
    // Selected item: bright green (matches region/university spinners)
    if (isSelected && ThemeState().isBlueTheme) {
      return BlueThemeColors.iconSuccess;
    }
    // Unselected in blue theme: dimmer colors
    if (ThemeState().isBlueTheme) {
      return theme.colorScheme.onSurfaceVariant;
    }
    switch (gender) {
      case 1:
        return Colors.blue;
      case 2:
      default:
        return gender == 0 ? Colors.grey : Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderOptions = includeUnselected ? [1, 2, 0] : [1, 2];
    final initialIndex = genderOptions.indexOf(selectedGender);

    // Use the same styling as region and university spinners in edit profile
    final isBlueTheme = ThemeState().isBlueTheme;
    final backgroundColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      height: height,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              key: ValueKey(selectedGender),
              itemExtent: itemExtent,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex >= 0 ? initialIndex : 0,
              ),
              onSelectedItemChanged: (index) {
                // Dismiss keyboard if it's open
                FocusScope.of(context).unfocus();
                // Provide haptic feedback
                HapticFeedbackUtils.impact();
                // Update the selected gender
                onGenderChanged(genderOptions[index]);
              },
              children: [
                // Male option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: _getGenderIconColor(context, 1, selectedGender == 1),
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "male",
                          context,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getItemTextColor(context, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Female option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: _getGenderIconColor(context, 2, selectedGender == 2),
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "female",
                          context,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getItemTextColor(context, 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (includeUnselected)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color: _getGenderIconColor(context, 0, selectedGender == 0),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: LanguageAwareStringHelper.getText(
                            "not_selected",
                            context,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _getItemTextColor(context, 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Right part with arrows - same as metro line picker
          if (showArrows)
            Container(
              width: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
