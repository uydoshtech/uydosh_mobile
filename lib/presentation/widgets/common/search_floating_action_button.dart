import "package:flutter/material.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";

class SearchFloatingActionButton extends StatelessWidget {
  const SearchFloatingActionButton({
    required this.searchFiltersState,
    super.key,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 25.0,
    this.elevation,
    this.replaceCurrentRoute = false,
    this.openedFromHomeScreen = false,
  });

  final SearchFiltersState searchFiltersState;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  final double? elevation;
  final bool replaceCurrentRoute;
  final bool openedFromHomeScreen;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () => _handleSearchPressed(context),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      tooltip:
          tooltip ?? L10n.get("search"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0), // More roundish than default
      ),
      child: Icon(
        Icons.search,
        size: (iconSize ?? 25.0) * 1.1,
      ), // 10% larger icon
    );
  }

  void _handleSearchPressed(BuildContext context) {
    HapticFeedbackUtils.impact();

    // Apply profile-based listing type and gender before showing the sheet
    searchFiltersState.applyProfileValuesForSearchSheet().then((_) {
      if (!context.mounted) return;
      SearchBottomSheetWidget.show(
        context,
        replaceCurrentRoute: replaceCurrentRoute,
        openedFromHomeScreen: openedFromHomeScreen,
        currentListingTypeId: searchFiltersState.selectedListingTypeId,
        currentLocationId: searchFiltersState.selectedLocationIndex,
        currentSubwayStationId: searchFiltersState.selectedStationId,
        currentSubwayLineId: searchFiltersState.selectedSubwayLine,
        currentGender: searchFiltersState.selectedGender,
        currentMinPrice: searchFiltersState.minPrice,
        currentMaxPrice: searchFiltersState.maxPrice,
      );
    });
  }
}
