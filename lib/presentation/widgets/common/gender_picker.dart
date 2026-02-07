import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class GenderPicker extends StatelessWidget {
  const GenderPicker({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.height = 80,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
    this.scrollController,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;
  final FixedExtentScrollController? scrollController;

  Color _getGenderColor(int gender) {
    switch (gender) {
      case 1: // Male
        return Colors.blue;
      case 2: // Female
      default:
        return gender == 0 ? Colors.grey : Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderOptions = includeUnselected ? [1, 2, 0] : [1, 2];
    final initialIndex = genderOptions.indexOf(selectedGender);

    // Use the same styling as metro line picker
    final backgroundColor = theme.colorScheme.surfaceVariant;
    final borderColor = theme.colorScheme.outline;
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;

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
              itemExtent: itemExtent,
              scrollController:
                  scrollController ??
                  FixedExtentScrollController(
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
                      Icon(Icons.male, color: _getGenderColor(1), size: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "male",
                          context,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
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
                      Icon(Icons.female, color: _getGenderColor(2), size: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "female",
                          context,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
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
                          color: _getGenderColor(0),
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
                              color: textColor,
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
