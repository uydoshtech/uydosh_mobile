import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";

/// Location picker section for the search bottom sheet.
class SearchBottomSheetLocationSection extends StatelessWidget {
  const SearchBottomSheetLocationSection({
    required this.searchFiltersState,
    required this.locationScrollController,
    required this.getLocationIndexFromId,
    required this.onLocationChanged,
    required this.onMetroReset,
    super.key,
  });

  final SearchFiltersState searchFiltersState;
  final FixedExtentScrollController? locationScrollController;
  final int Function(int locationId, List<Location> locations)
      getLocationIndexFromId;
  final void Function(int? locationIndex) onLocationChanged;
  final VoidCallback onMetroReset;

  @override
  Widget build(BuildContext context) {
    final locations = LocationCache.getAllLocations();

    return LocationPicker(
      locations: locations,
      selectedLocationIndex: getLocationIndexFromId(
        searchFiltersState.selectedLocationIndex,
        locations,
      ),
      scrollController: locationScrollController,
      onLocationChanged: (locationIndex) {
        if (locationIndex == -1) {
          onLocationChanged(null);
        } else {
          onLocationChanged(locations[locationIndex].id);
        }
      },
      useThemeColors: true,
      sortLocations: false,
      containerKey: "location_picker_${searchFiltersState.selectedSubwayLine}",
      onMetroReset: onMetroReset,
      useColoredIcons: true,
      showArrows: false,
      useGlassPlate: true,
    );
  }
}
