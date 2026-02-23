import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";

/// Data class for BlocSelector to reduce unnecessary rebuilds
class _LocationPickerData {
  const _LocationPickerData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.locations,
  });
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Location> locations;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _LocationPickerData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.locations.length == locations.length;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        locations.length.hashCode;
  }
}

/// Location picker section for the search bottom sheet.
class SearchBottomSheetLocationSection extends StatelessWidget {
  const SearchBottomSheetLocationSection({
    super.key,
    required this.searchFiltersState,
    required this.locationScrollController,
    required this.getLocationIndexFromId,
    required this.onLocationChanged,
    required this.onMetroReset,
  });

  final SearchFiltersState searchFiltersState;
  final FixedExtentScrollController? locationScrollController;
  final int Function(int locationId, List<Location> locations)
      getLocationIndexFromId;
  final void Function(int? locationIndex) onLocationChanged;
  final VoidCallback onMetroReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<LocationsBloc, LocationsState, _LocationPickerData>(
      selector: (state) => state.when(
        initial: () => const _LocationPickerData(
          isLoading: false,
          hasError: false,
          errorMessage: "",
          locations: [],
        ),
        loading: () => const _LocationPickerData(
          isLoading: true,
          hasError: false,
          errorMessage: "",
          locations: [],
        ),
        loaded: (locations) => _LocationPickerData(
          isLoading: false,
          hasError: false,
          errorMessage: "",
          locations: locations,
        ),
        error: (message) => _LocationPickerData(
          isLoading: false,
          hasError: true,
          errorMessage: message,
          locations: [],
        ),
      ),
      builder: (context, data) {
        if (data.isLoading) {
          return _buildLocationWheelPlaceholder(theme, isLoading: true);
        }
        if (data.hasError) {
          return _buildLocationWheelPlaceholder(theme);
        }
        if (data.locations.isEmpty) {
          return _buildLocationWheelPlaceholder(theme);
        }
        return LocationPicker(
          locations: data.locations,
          selectedLocationIndex: getLocationIndexFromId(
            searchFiltersState.selectedLocationIndex,
            data.locations,
          ),
          scrollController: locationScrollController,
          onLocationChanged: (locationIndex) {
            if (locationIndex == -1) {
              onLocationChanged(null);
            } else {
              onLocationChanged(data.locations[locationIndex].id);
            }
          },
          useThemeColors: true,
          sortLocations: false,
          containerKey:
              "location_picker_${searchFiltersState.selectedSubwayLine}",
          onMetroReset: onMetroReset,
          useColoredIcons: true,
          showArrows: false,
        );
      },
    );
  }

  static Widget _buildLocationWheelPlaceholder(
    ThemeData theme, {
    bool isLoading = false,
  }) {
    final controlBg = ThemeState().isBlueTheme
        ? BlueThemeColors.surface
        : theme.colorScheme.surfaceContainerHighest;
    return Container(
      decoration: BoxDecoration(
        color: controlBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      height: 80,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      L10n.get("select_location"),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeState().isBlueTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
