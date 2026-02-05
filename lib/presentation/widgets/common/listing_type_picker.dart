import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ListingTypePicker extends StatelessWidget {
  const ListingTypePicker({
    required this.selectedListingTypeId,
    required this.onListingTypeChanged,
    this.height = 80,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    super.key,
  });

  final int selectedListingTypeId;
  final ValueChanged<int> onListingTypeChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;

  Color _getListingTypeColor(int listingTypeId) {
    // Use metro line colors for listing types
    switch (listingTypeId) {
      case 2: // Roommate needed
        return AppColors.metroLine1; // Red
      case 1: // Room needed
        return AppColors.metroLine2; // Blue
      default:
        return AppColors.metroLine1; // Red as default
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              scrollController: FixedExtentScrollController(
                initialItem: selectedListingTypeId == 2 ? 0 : 1,
              ),
              onSelectedItemChanged: (index) {
                // Dismiss keyboard if it"s open
                FocusScope.of(context).unfocus();
                // Provide haptic feedback
                HapticFeedbackUtils.impact();
                // Update the selected listing type ID (2 = roommate needed, 1 = room needed)
                onListingTypeChanged(index == 0 ? 2 : 1);
              },
              children: [
                // Roommate needed option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        color: _getListingTypeColor(2),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "listing_type_roommate_needed",
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
                // Room needed option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home,
                        color: _getListingTypeColor(1),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "listing_type_room_needed",
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
