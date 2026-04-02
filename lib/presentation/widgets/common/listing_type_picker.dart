import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";

/// Listing type picker - same pattern as LocationPicker: uses persistent scroll
/// controller (from parent or own) so the wheel scrolls smoothly with sound.
class ListingTypePicker extends StatefulWidget {
  const ListingTypePicker({
    required this.selectedListingTypeId,
    required this.onListingTypeChanged,
    super.key,
    this.height = 80,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
    this.scrollController,
  });

  final int selectedListingTypeId;
  final ValueChanged<int> onListingTypeChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;
  final FixedExtentScrollController? scrollController;

  @override
  State<ListingTypePicker> createState() => _ListingTypePickerState();
}

class _ListingTypePickerState extends State<ListingTypePicker> {
  FixedExtentScrollController? _ownScrollController;

  List<int> get _listingTypeOptions =>
      widget.includeUnselected ? [2, 1, 0] : [2, 1];

  FixedExtentScrollController get _effectiveController {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    _ownScrollController ??= FixedExtentScrollController(
      initialItem: _indexOf(widget.selectedListingTypeId),
    );
    return _ownScrollController!;
  }

  int _indexOf(int id) {
    final i = _listingTypeOptions.indexOf(id);
    return i >= 0 ? i : 0;
  }

  @override
  void didUpdateWidget(ListingTypePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == null &&
        oldWidget.selectedListingTypeId != widget.selectedListingTypeId &&
        (_ownScrollController?.hasClients ?? false)) {
      final idx = _indexOf(widget.selectedListingTypeId);
      if (idx != _ownScrollController!.selectedItem) {
        _ownScrollController!.animateToItem(
          idx,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _ownScrollController?.dispose();
    super.dispose();
  }

  Color _getItemTextColor(BuildContext context, int listingTypeId) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedListingTypeId == listingTypeId;
    if (isSelected && ThemeState().isBlueTheme) {
      return Colors.white;
    }
    if (ThemeState().isBlueTheme) {
      return theme.colorScheme.onSurfaceVariant;
    }
    return ThemeState().isBlueTheme ? Colors.white : Colors.black;
  }

  Color _getListingTypeColor(int listingTypeId) {
    switch (listingTypeId) {
      case 2:
        return AppColors.metroLine1;
      case 1:
        return AppColors.metroLine2;
      default:
        return listingTypeId == 0 ? Colors.grey : AppColors.metroLine1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: widget.itemExtent,
              scrollController: _effectiveController,
              onSelectedItemChanged: (index) {
                FocusScope.of(context).unfocus();
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                widget.onListingTypeChanged(_listingTypeOptions[index]);
              },
              children: [
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
                        child: L10n.text(
                          "listing_type_roommate_needed",
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
                        child: L10n.text(
                          "listing_type_room_needed",
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
                if (widget.includeUnselected)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color: _getListingTypeColor(0),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: L10n.text(
                            "not_selected",
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
          if (widget.showArrows)
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
