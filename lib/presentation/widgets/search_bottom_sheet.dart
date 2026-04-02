import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_filter_section.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_location_section.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_metro_section.dart";
import "package:uy_dosh/presentation/widgets/tutorial/metro_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

part "search_bottom_sheet/search_bottom_sheet_state.dart";

/// Reusable search bottom sheet widget that can be used throughout the app
///
/// Features:
/// - Location and metro filters are mutually exclusive
/// - When metro line is selected, location picker is reset
/// - When location is selected, metro filters are reset
/// - Wheel pickers are automatically reset to initial positions
class SearchBottomSheetWidget {
  /// Shows the search bottom sheet with all available filters
  static void show(
    BuildContext context, {
    bool replaceCurrentRoute = false,
    bool openedFromHomeScreen = false,
    int? currentListingTypeId,
    int? currentLocationId,
    int? currentSubwayStationId,
    int? currentSubwayLineId,
    int? currentGender,
    double? currentMinPrice,
    double? currentMaxPrice,
  }) {
    // Try to get existing blocs from context to avoid redundant fetches
    ListingsBloc? existingListingsBloc;
    LocationsBloc? existingLocationsBloc;
    try {
      existingListingsBloc = context.read<ListingsBloc>();
    } catch (_) {
      existingListingsBloc = null;
    }
    try {
      existingLocationsBloc = context.read<LocationsBloc>();
    } catch (_) {
      existingLocationsBloc = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder:
          (context) => MultiBlocProvider(
            providers: [
              // Provide ListingsBloc - either existing or new one
              existingListingsBloc != null
                  ? BlocProvider.value(value: existingListingsBloc)
                  : BlocProvider(
                    create: (context) => ListingsBloc(getIt<IListingService>()),
                  ),
              // Provide LocationsBloc - reuse if available to avoid refetch
              existingLocationsBloc != null
                  ? BlocProvider.value(value: existingLocationsBloc)
                  : BlocProvider(
                    create: (context) {
                      final locationsBloc = LocationsBloc(
                        getIt<ILocationService>(),
                      );
                      locationsBloc.add(const LocationsEvent.fetchLocations());
                      return locationsBloc;
                    },
                  ),
              BlocProvider(
                create:
                    (context) =>
                        SubwayStationsBloc(getIt<ISubwayStationService>()),
              ),
            ],
            child: _SearchBottomSheetContent(
              replaceCurrentRoute: replaceCurrentRoute,
              openedFromHomeScreen: openedFromHomeScreen,
              currentListingTypeId: currentListingTypeId,
              currentLocationId: currentLocationId,
              currentSubwayStationId: currentSubwayStationId,
              currentSubwayLineId: currentSubwayLineId,
              currentGender: currentGender,
              currentMinPrice: currentMinPrice,
              currentMaxPrice: currentMaxPrice,
            ),
          ),
    );
  }
}

class _SearchBottomSheetContent extends StatefulWidget {

  const _SearchBottomSheetContent({
    this.replaceCurrentRoute = false,
    this.openedFromHomeScreen = false,
    this.currentListingTypeId,
    this.currentLocationId,
    this.currentSubwayStationId,
    this.currentSubwayLineId,
    this.currentGender,
    this.currentMinPrice,
    this.currentMaxPrice,
  });
  final bool replaceCurrentRoute;
  final bool openedFromHomeScreen;
  final int? currentListingTypeId;
  final int? currentLocationId;
  final int? currentSubwayStationId;
  final int? currentSubwayLineId;
  final int? currentGender;
  final double? currentMinPrice;
  final double? currentMaxPrice;

  @override
  State<_SearchBottomSheetContent> createState() =>
      _SearchBottomSheetContentState();
}
