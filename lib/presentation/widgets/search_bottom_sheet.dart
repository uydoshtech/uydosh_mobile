import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_toggle.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";
import "package:uy_dosh/presentation/widgets/tutorial/metro_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
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
    this.currentListingTypeId,
    this.currentLocationId,
    this.currentSubwayStationId,
    this.currentSubwayLineId,
    this.currentGender,
    this.currentMinPrice,
    this.currentMaxPrice,
  });
  final bool replaceCurrentRoute;
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

class _SearchBottomSheetContentState extends State<_SearchBottomSheetContent> {
  final SearchFiltersState _searchFiltersState = SearchFiltersState();
  final GlobalKey<TutorialTargetWrapperState> _metroLineTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  final GlobalKey<TutorialTargetWrapperState> _metroStationTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  List<SubwayStation> _currentStations = [];
  List<Location> _currentLocations = [];
  bool _isLoadingStations = false;
  FixedExtentScrollController? _stationPickerController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _locationScrollController;
  Timer? _blinkTimer;
  bool _isBlinking = true;

  @override
  void initState() {
    super.initState();

    logger.d(
      "DEBUG: SearchBottomSheet initState - widget.currentSubwayStationId: ${widget.currentSubwayStationId}, widget.currentSubwayLineId: ${widget.currentSubwayLineId}",
    );
    logger.d(
      "DEBUG: SearchBottomSheet initState - global subwayLine: ${_searchFiltersState.selectedSubwayLine}, global stationId: ${_searchFiltersState.selectedStationId}",
    );

    // Initialize the station picker controller only once
    // Don"t set initialItem here to avoid forcing position 0
    _stationPickerController = FixedExtentScrollController();
    _metroLineScrollController = FixedExtentScrollController(
      initialItem: _searchFiltersState.selectedSubwayLine,
    );
    _locationScrollController = FixedExtentScrollController(
      initialItem: _getInitialLocationItem(),
    );

    // Initialize blink timer
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
      }
    });

    // Use the current search parameters to restore the correct state
    if (widget.currentListingTypeId != null) {
      _searchFiltersState.setListingTypeId(widget.currentListingTypeId!);
    }

    if (widget.currentLocationId != null) {
      _searchFiltersState.setLocationIndex(widget.currentLocationId!);
    }

    if (widget.currentSubwayLineId != null) {
      _searchFiltersState.setSubwayLine(widget.currentSubwayLineId!);
    }

    if (widget.currentSubwayStationId != null) {
      _searchFiltersState.setStationId(widget.currentSubwayStationId!);
    }

    if (widget.currentGender != null) {
      _searchFiltersState.setGender(widget.currentGender!);
    }

    // Restore price range if provided
    if (widget.currentMinPrice != null && widget.currentMaxPrice != null) {
      _searchFiltersState.setPriceRange(
        widget.currentMinPrice!,
        widget.currentMaxPrice!,
      );
    }

    // Load stations if there"s a saved subway line
    if (_searchFiltersState.selectedSubwayLine > 0) {
      final subwayBloc = context.read<SubwayStationsBloc>();
      subwayBloc.add(
        SubwayStationsEvent.fetchSubwayStationsByLine(
          line: _searchFiltersState.selectedSubwayLine,
        ),
      );
      setState(() {
        _isLoadingStations = true;
      });
    }

    // Ensure station selection is reset when opening with only metro line (no specific station)
    if (widget.currentSubwayLineId != null &&
        widget.currentSubwayLineId! > 0 &&
        widget.currentSubwayStationId == null) {
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
    }

    // Show metro tutorial only when onboarding toggle is ON (and not yet completed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (OnboardingState().showOnboarding &&
            !TutorialState().hasCompletedMetroTutorial) {
          _showMetroTutorial();
        }
      });
    });
  }

  void _showMetroTutorial() {
    if (!mounted) return;
    MetroTutorialOverlay.show(
      context,
      metroLineKey: _metroLineTutorialKey,
      metroStationKey: _metroStationTutorialKey,
      onCycleToLine: _animateToMetroLine,
      onCycleToStation: _animateToStation,
      getStationCount: () =>
          _searchFiltersState.selectedSubwayLine == 4 && _currentStations.isNotEmpty
              ? _currentStations.length + 1
              : 0,
      onComplete: () {
        _animateToMetroLine(0);
        TutorialState().markMetroTutorialCompleted();
        // Turn toggle OFF after both tutorials shown so it won't show on next app start
        OnboardingState().setShowOnboarding(false);
      },
    );
  }

  void _animateToMetroLine(int lineIndex) {
    if (!mounted) return;
    setState(() {
      _searchFiltersState.setSubwayLine(lineIndex);
      if (lineIndex > 0) {
        _resetLocationPicker();
        _loadStationsForLine(lineIndex);
      } else {
        _currentStations = [];
        _searchFiltersState.setStationIndex(0);
        _searchFiltersState.setStationId(0);
      }
    });
    _metroLineScrollController?.animateToItem(
      lineIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _animateToStation(int stationIndex) {
    if (!mounted) return;
    final maxIndex = _currentStations.isEmpty ? 0 : _currentStations.length;
    final clampedIndex = stationIndex.clamp(0, maxIndex);
    setState(() {
      if (clampedIndex == 0) {
        _searchFiltersState.setStationIndex(0);
        _searchFiltersState.setStationId(0);
      } else {
        final index = clampedIndex - 1;
        if (index < _currentStations.length) {
          final station = _currentStations[index];
          _searchFiltersState.setStationIndex(index);
          _searchFiltersState.setStationId(station.id);
        }
      }
    });
    if (_stationPickerController?.hasClients ?? false) {
      _stationPickerController!.animateToItem(
        clampedIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    MetroTutorialOverlay.stopCycling();
    _stationPickerController?.dispose();
    _metroLineScrollController?.dispose();
    _locationScrollController?.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  int? _getSelectedLocationId() {
    // selectedLocationIndex > 0 means a location is selected (0 = "Select location")
    if (_searchFiltersState.selectedLocationIndex > 0) {
      // selectedLocationIndex now stores the actual location ID directly
      return _searchFiltersState.selectedLocationIndex;
    }
    return null;
  }

  int _getInitialLocationItem() {
    // If no location is selected, return 0 (first item: "Select location")
    if (_searchFiltersState.selectedLocationIndex <= 0) {
      return 0;
    }

    // Find the index of the selected location ID in the wheel picker
    final selectedLocationId = _searchFiltersState.selectedLocationIndex;
    final locationIndex = _currentLocations.indexWhere(
      (location) => location.id == selectedLocationId,
    );

    // Return the wheel picker index (0 = "Select location", 1 = first location, etc.)
    return locationIndex >= 0 ? locationIndex + 1 : 0;
  }

  int _getLocationIndexFromId(int locationId, List<Location> locations) {
    // If no location is selected, return -1 (unselected)
    if (locationId <= 0) {
      return -1;
    }

    // Find the index of the selected location ID in the provided locations list
    final locationIndex = locations.indexWhere(
      (location) => location.id == locationId,
    );

    // Return the location index (-1 for unselected, 0+ for selected)
    return locationIndex >= 0 ? locationIndex : -1;
  }

  int? _getSelectedSubwayStationId() {
    // Only return station ID if it"s explicitly set and greater than 0
    if (_searchFiltersState.selectedStationId > 0) {
      return _searchFiltersState.selectedStationId;
    }

    // Don"t fall back to index-based selection to prevent auto-selecting first station
    return null;
  }

  // New method to get the initial station item for the wheel picker
  int _getInitialStationItem() {
    logger.d(
      "DEBUG: _getInitialStationItem called - selectedStationId: ${_searchFiltersState.selectedStationId}, stations count: ${_currentStations.length}",
    );

    // If no station is selected or no stations are loaded, return 0 (first item: "Select station")
    if (_searchFiltersState.selectedStationId <= 0 ||
        _currentStations.isEmpty) {
      logger.d(
        "DEBUG: Returning 0 (Select station) - no station selected or no stations loaded",
      );
      return 0;
    }

    // Find the index of the selected station ID in the current stations list
    final selectedStationId = _searchFiltersState.selectedStationId;
    final stationIndex = _currentStations.indexWhere(
      (station) => station.id == selectedStationId,
    );

    // Return the wheel picker index (0 = "Select station", 1 = first station, etc.)
    final result = stationIndex >= 0 ? stationIndex + 1 : 0;
    logger.d(
      "DEBUG: Found station at index $stationIndex, returning wheel picker index: $result",
    );
    return result;
  }

  void _loadStationsForLine(int line) {
    setState(() {
      _searchFiltersState.setSubwayLine(line);
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
      _isLoadingStations = true;
    });

    // When changing metro lines, smoothly reset to position 0
    if (_stationPickerController != null &&
        _stationPickerController!.hasClients) {
      logger.d("DEBUG: Metro line changed, smoothly resetting to position 0");
      _stationPickerController!.animateToItem(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // Trigger the BLoC to fetch stations for the selected line
    context.read<SubwayStationsBloc>().add(
      SubwayStationsEvent.fetchSubwayStationsByLine(line: line),
    );
  }

  /// Resets the location picker to its initial state (no location selected)
  /// and forces a rebuild of the wheel pickers to ensure proper visual reset
  void _resetLocationPicker() {
    setState(() {
      _searchFiltersState.setLocationIndex(0);
    });
    _forceRebuildWheelPickers();
  }

  /// Resets all metro-related filters (line and station) to their initial state
  /// and forces a rebuild of the wheel pickers to ensure proper visual reset
  void _resetMetroPickers() {
    setState(() {
      _searchFiltersState.setSubwayLine(0);
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
      _currentStations = [];
    });
    _resetWheelPickerControllers();
    _forceRebuildWheelPickers();
  }

  void _forceRebuildWheelPickers() {
    // Force rebuild by triggering setState
    setState(() {});
  }

  void _resetWheelPickerControllers() {
    // Only create a new controller if one doesn"t exist
    if (_stationPickerController == null) {
      logger.d(
        "DEBUG: Creating new station picker controller, stations count: ${_currentStations.length}",
      );
      _stationPickerController = FixedExtentScrollController();
    } else {
      logger.d(
        "DEBUG: Keeping existing station picker controller to preserve scroll position",
      );
    }
  }

  /// Restores the picker to the correct position without disrupting scrolling
  void _restoreStationPickerPosition() {
    logger.d("DEBUG: _restoreStationPickerPosition called");
    logger.d("DEBUG: Controller exists: ${_stationPickerController != null}");
    logger.d(
      "DEBUG: Controller has clients: ${_stationPickerController?.hasClients}",
    );
    logger.d(
      "DEBUG: Current selectedStationId: ${_searchFiltersState.selectedStationId}",
    );
    logger.d(
      "DEBUG: Current selectedStationIndex: ${_searchFiltersState.selectedStationIndex}",
    );

    if (_stationPickerController != null &&
        _stationPickerController!.hasClients) {
      final targetPosition = _getInitialStationItem();
      logger.d("DEBUG: Restoring station picker to position: $targetPosition");

      // Use animateToItem for smooth scrolling to the target position
      _stationPickerController!.animateToItem(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      logger.d(
        "DEBUG: Cannot restore position - controller is null or has no clients",
      );
    }
  }

  void _onStationsLoaded(List<SubwayStation> stations) {
    logger.d(
      "DEBUG: _onStationsLoaded called with ${stations.length} stations",
    );
    logger.d(
      "DEBUG: _onStationsLoaded - widget.currentSubwayStationId: ${widget.currentSubwayStationId}",
    );
    logger.d(
      "DEBUG: _onStationsLoaded - global stationId: ${_searchFiltersState.selectedStationId}",
    );

    setState(() {
      _currentStations = stations;
      _isLoadingStations = false;

      // Restore station selection based on available data
      if (stations.isNotEmpty) {
        if (widget.currentSubwayStationId != null) {
          // Case 1: We have a specific station ID from the current search
          final targetStationId = widget.currentSubwayStationId!;
          logger.d(
            "DEBUG: Trying to restore station with ID: $targetStationId",
          );

          // Find this station in the loaded stations list
          final correctIndex = stations.indexWhere(
            (station) => station.id == targetStationId,
          );
          if (correctIndex >= 0) {
            // Update both the index and ID to keep them in sync
            _searchFiltersState.setStationIndex(correctIndex);
            _searchFiltersState.setStationId(targetStationId);
            logger.d(
              "DEBUG: Restored station at index $correctIndex with ID $targetStationId",
            );
          } else {
            _searchFiltersState.setStationIndex(0);
            _searchFiltersState.setStationId(0);
            logger.d("DEBUG: Station not found, reset to index 0");
          }
        } else if (_searchFiltersState.selectedStationId > 0) {
          // Case 2: No widget parameter but we have a global station ID (opening from curved navigation)
          final targetStationId = _searchFiltersState.selectedStationId;
          logger.d(
            "DEBUG: No widget parameter, trying to restore from global state - station ID: $targetStationId",
          );

          // Find this station in the loaded stations list
          final correctIndex = stations.indexWhere(
            (station) => station.id == targetStationId,
          );
          if (correctIndex >= 0) {
            // Update the index to match the current stations list
            _searchFiltersState.setStationIndex(correctIndex);
            logger.d(
              "DEBUG: Restored station from global state at index $correctIndex with ID $targetStationId",
            );
          } else {
            // Station not found in current list, reset
            _searchFiltersState.setStationIndex(0);
            _searchFiltersState.setStationId(0);
            logger.d(
              "DEBUG: Station from global state not found, reset to index 0",
            );
          }
        } else {
          // Case 3: No specific station to restore, keep station unselected
          _searchFiltersState.setStationIndex(0);
          _searchFiltersState.setStationId(0);
          logger.d("DEBUG: No specific station to restore, reset to index 0");
        }
      }
    });

    logger.d(
      "DEBUG: After setState - selectedStationId: ${_searchFiltersState.selectedStationId}, selectedStationIndex: ${_searchFiltersState.selectedStationIndex}",
    );

    // Don"t reset the controller here - it causes scrolling issues
    // Instead, restore the picker to the correct position smoothly
    // Use addPostFrameCallback to ensure setState has completed
    logger.d("DEBUG: Stations loaded, scheduling picker position restoration");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.d("DEBUG: Post frame callback - restoring picker position");
      _restoreStationPickerPosition();
    });
  }

  Color _getLineColor(int line) {
    return AppColors.getMetroLineColor(line);
  }

  Color _getLocationIconColor() {
    if (_searchFiltersState.selectedLocationIndex <= 0) {
      return Colors.grey; // Grey when no location is selected
    }
    // Alternate between different colors based on location index
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[(_searchFiltersState.selectedLocationIndex - 1) %
        colors.length];
  }

  Color _getLocationIconColorForIndex(int index) {
    // Alternate between different colors based on location index
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[(index - 1) % colors.length];
  }

  String _getLocalizedName({String? nameUz, String? nameRu, String? nameEn}) {
    final currentLanguage = LanguageState().currentLanguage;

    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SubwayStationsBloc, SubwayStationsState>(
      listener: (context, state) {
        state.map(
          initial: (_) => setState(() => _isLoadingStations = false),
          loading: (_) => setState(() => _isLoadingStations = true),
          loaded: (loadedState) => _onStationsLoaded(loadedState.stations),
          error: (errorState) => setState(() => _isLoadingStations = false),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7 + 30,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Search header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.get("search_listings"),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search filters
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Listing Type and Gender Selection - Side by Side Wheel Pickers
                          Row(
                            children: [
                              // Listing Type Selection (50% width)
                              Expanded(
                                child: ListingTypePicker(
                                  selectedListingTypeId:
                                      _searchFiltersState.selectedListingTypeId,
                                  onListingTypeChanged: (listingTypeId) {
                                    _searchFiltersState.setListingTypeId(
                                      listingTypeId,
                                    );
                                    setState(() {});
                                  },
                                  useThemeColors: true,
                                  showArrows: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Gender Selection (50% width)
                              Expanded(
                                child: GenderPicker(
                                  selectedGender:
                                      _searchFiltersState.selectedGender,
                                  onGenderChanged: (gender) {
                                    _searchFiltersState.setGender(gender);
                                    setState(() {});
                                  },
                                  useThemeColors: true,
                                  showArrows: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Location filter - Wheel Picker
                          BlocSelector<
                            LocationsBloc,
                            LocationsState,
                            _LocationPickerData
                          >(
                            selector:
                                (state) => state.when(
                                  initial:
                                      () => const _LocationPickerData(
                                        isLoading: false,
                                        hasError: false,
                                        errorMessage: "",
                                        locations: [],
                                      ),
                                  loading:
                                      () => const _LocationPickerData(
                                        isLoading: true,
                                        hasError: false,
                                        errorMessage: "",
                                        locations: [],
                                      ),
                                  loaded:
                                      (locations) => _LocationPickerData(
                                        isLoading: false,
                                        hasError: false,
                                        errorMessage: "",
                                        locations: locations,
                                      ),
                                  error:
                                      (message) => _LocationPickerData(
                                        isLoading: false,
                                        hasError: true,
                                        errorMessage: message,
                                        locations: [],
                                      ),
                                ),
                            builder: (context, data) {
                              if (data.isLoading) {
                                return _buildLocationWheelPlaceholder(
                                  isLoading: true,
                                );
                              }
                              if (data.hasError) {
                                return _buildLocationWheelPlaceholder();
                              }
                              if (data.locations.isEmpty) {
                                return _buildLocationWheelPlaceholder();
                              }
                              return LocationPicker(
                                locations: data.locations,
                                selectedLocationIndex: _getLocationIndexFromId(
                                  _searchFiltersState.selectedLocationIndex,
                                  data.locations,
                                ),
                                scrollController: _locationScrollController,
                                onLocationChanged: (locationIndex) {
                                  if (locationIndex == -1) {
                                    _searchFiltersState.setLocationIndex(0);
                                  } else {
                                    final selectedLocationId =
                                        data.locations[locationIndex].id;
                                    _searchFiltersState.setLocationIndex(
                                      selectedLocationId,
                                    );
                                  }
                                  setState(() {});
                                },
                                useThemeColors: true,
                                sortLocations: false,
                                containerKey:
                                    "location_picker_${_searchFiltersState.selectedSubwayLine}",
                                onMetroReset: _resetMetroPickers,
                                useColoredIcons: true,
                                showArrows: false,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              L10n.get("search_location_or_metro_hint"),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Metro Line and Station Selection - Side by Side Wheel Pickers
                          Row(
                            children: [
                              // Metro Line Selection (50% width)
                              Expanded(
                                child: TutorialTargetWrapper(
                                  key: _metroLineTutorialKey,
                                  child: Container(
                                  key: ValueKey(
                                    "metro_line_picker_${_searchFiltersState.selectedLocationIndex}",
                                  ),
                                  decoration: BoxDecoration(
                                    color: ThemeState().isBlueTheme
                                        ? BlueThemeColors.surface
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  height: 80,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CupertinoPicker(
                                          itemExtent: 40,
                                          scrollController:
                                              _metroLineScrollController,
                                          onSelectedItemChanged: (index) {
                                            HapticFeedbackUtils.impact();
                                            SendSoundUtils.playSelectionSound();
                                            setState(() {
                                              _searchFiltersState.setSubwayLine(
                                                index,
                                              );
                                              // Reset location picker when metro line is selected
                                              // This ensures location and metro filters are mutually exclusive
                                              if (index > 0) {
                                                _resetLocationPicker();
                                              }
                                            });
                                            if (index > 0) {
                                              _loadStationsForLine(index);
                                            } else {
                                              setState(() {
                                                _currentStations = [];
                                                _searchFiltersState
                                                    .setStationIndex(0);
                                                _searchFiltersState
                                                    .setStationId(0);
                                              });
                                            }
                                          },
                                          children: [
                                            // Unselected option
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MLetterIcon(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      L10n.get("select_metro_line"),
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            ThemeState()
                                                                    .isBlueTheme
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Metro line options
                                            ...([
                                              MetroCache.getLineName(
                                                1,
                                                LanguageState().currentLanguage,
                                              ),
                                              MetroCache.getLineName(
                                                2,
                                                LanguageState().currentLanguage,
                                              ),
                                              MetroCache.getLineName(
                                                3,
                                                LanguageState().currentLanguage,
                                              ),
                                              MetroCache.getLineName(
                                                4,
                                                LanguageState().currentLanguage,
                                              ),
                                            ].asMap().entries.map(
                                              (entry) => Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    MLetterIcon(
                                                      color: _getLineColor(
                                                        entry.key + 1,
                                                      ),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        entry.value,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              ThemeState()
                                                                      .isBlueTheme
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                              const SizedBox(width: 12),
                              // Metro Station Selection (50% width) - will show when line is selected
                              Expanded(
                                child: TutorialTargetWrapper(
                                  key: _metroStationTutorialKey,
                                  child:
                                    _searchFiltersState.selectedSubwayLine >
                                                0 &&
                                            _currentStations.isNotEmpty
                                        ? Container(
                                          decoration: BoxDecoration(
                                            color:
                                                ThemeState().isBlueTheme
                                                    ? BlueThemeColors.surface
                                                    : theme
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.outline,
                                            ),
                                          ),
                                          height: 80,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CupertinoPicker(
                                                  key: PageStorageKey(
                                                    "station_picker_${_searchFiltersState.selectedSubwayLine}",
                                                  ),
                                                  itemExtent: 40,
                                                  scrollController:
                                                      _stationPickerController,
                                                  onSelectedItemChanged: (
                                                    index,
                                                  ) {
                                                    HapticFeedbackUtils.impact();
                                                    SendSoundUtils.playSelectionSound();
                                                    setState(() {
                                                      if (index == 0) {
                                                        // "Select station" option
                                                        _searchFiltersState
                                                            .setStationIndex(0);
                                                        _searchFiltersState
                                                            .setStationId(0);
                                                      } else {
                                                        // Get the actual station ID from the selected index
                                                        final stationIndex =
                                                            index - 1;
                                                        if (stationIndex <
                                                            _currentStations
                                                                .length) {
                                                          final selectedStationId =
                                                              _currentStations[stationIndex]
                                                                  .id;
                                                          _searchFiltersState
                                                              .setStationIndex(
                                                                stationIndex,
                                                              );
                                                          _searchFiltersState
                                                              .setStationId(
                                                                selectedStationId,
                                                              );
                                                        }
                                                      }
                                                    });
                                                  },
                                                  children: [
                                                    // "Select station" option
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.train,
                                                            color:
                                                                _searchFiltersState
                                                                            .selectedSubwayLine >
                                                                        0
                                                                    ? _getLineColor(
                                                                      _searchFiltersState
                                                                          .selectedSubwayLine,
                                                                    )
                                                                    : theme
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                            size: 22,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              L10n.get("all_stations_count").replaceAll(
                                                                "{count}",
                                                                "${_currentStations.length}",
                                                              ),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    ThemeState()
                                                                            .isBlueTheme
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Station options
                                                    ..._currentStations.map((
                                                      station,
                                                    ) {
                                                      final transferInfo =
                                                          MetroCache.getTransferStationInfo(
                                                            station.id,
                                                          );
                                                      return Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.train,
                                                              color:
                                                                  _getLineColor(
                                                                    station
                                                                        .line,
                                                                  ),
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                _getLocalizedName(
                                                                  nameUz:
                                                                      station
                                                                          .nameUz,
                                                                  nameRu:
                                                                      station
                                                                          .nameRu,
                                                                  nameEn:
                                                                      station
                                                                          .nameEn,
                                                                ),
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      ThemeState()
                                                                              .isBlueTheme
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            // Add train icon for transfer stations with connected line color
                                                            if (transferInfo !=
                                                                null) ...[
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Icon(
                                                                Icons.train,
                                                                color: _getLineColor(
                                                                  transferInfo["connectedStationLine"],
                                                                ), // Use connected station's line color
                                                                size: 20,
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        : Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.outline,
                                            ),
                                            color: (ThemeState().isBlueTheme
                                                    ? BlueThemeColors.surface
                                                    : theme
                                                        .colorScheme
                                                        .surfaceContainerHighest)
                                                .withValues(alpha: 0.5),
                                          ),
                                          height: 80,
                                          child: Center(
                                            child: Text(
                                              L10n.get("select_metro_line_title"),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ThemeState().isBlueTheme
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          // Explanatory text container - always reserved to prevent interface jerking
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                height: 20, // Fixed height to reserve space

                                child:
                                    _searchFiltersState.selectedSubwayLine >
                                                0 &&
                                            _searchFiltersState
                                                    .selectedStationId ==
                                                0
                                        ? _buildRichTextExplanation(
                                          context,
                                          theme,
                                        )
                                        : const SizedBox.shrink(), // Empty space when text shouldn"t show
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Price Range Picker
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: ThemeState().isBlueTheme
                                  ? BlueThemeColors.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            child: PriceRangePicker(
                              initialMinPrice: _searchFiltersState.minPrice,
                              initialMaxPrice: _searchFiltersState.maxPrice,
                              onPriceRangeChanged: (minPrice, maxPrice) {
                                // Save price range changes to SearchFiltersState
                                _searchFiltersState.setPriceRange(
                                  minPrice,
                                  maxPrice,
                                );
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Private Room Toggle
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: ThemeState().isBlueTheme
                                  ? BlueThemeColors.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            child: UydoshToggle(
                              icon: Icons.lock_outline,
                              title: Text(
                                L10n.get("private_room_only"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      _searchFiltersState.privateRoom
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                              value: _searchFiltersState.privateRoom,
                              onChanged: (value) {
                                HapticFeedbackUtils.impact();
                                _searchFiltersState.setPrivateRoom(value);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Search button - right under metro spinners
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              onPressed: _performSearch,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    L10n.get("search"),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({required Widget child}) {
    return child;
  }

  Widget _buildLocationPlaceholder(String key, {bool isLoading = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.surface
            : theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              L10n.get(key),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          else
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker(List<Location> locations) {
    final theme = Theme.of(context);
    _currentLocations = List.from(locations);

    return Container(
      key: ValueKey(
        "location_picker_${_searchFiltersState.selectedSubwayLine}",
      ),
      decoration: BoxDecoration(
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.surface
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController:
                  _locationScrollController ??
                  FixedExtentScrollController(
                    initialItem: _getInitialLocationItem(),
                  ),
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                setState(() {
                  if (index == 0) {
                    // "Select location" option
                    _searchFiltersState.setLocationIndex(0);
                  } else {
                    // Get the actual location ID from the selected index
                    final locationIndex = index - 1;
                    if (locationIndex < _currentLocations.length) {
                      final selectedLocationId =
                          _currentLocations[locationIndex].id;
                      _searchFiltersState.setLocationIndex(selectedLocationId);
                    }
                  }
                  // Reset metro filters when location is selected
                  // This ensures location and metro filters are mutually exclusive
                  if (index > 0) {
                    _resetMetroPickers();
                  }
                });
              },
              children: [
                // Unselected option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        L10n.get("select_location"),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              ThemeState().isBlueTheme
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Location options
                ..._currentLocations
                    .asMap()
                    .entries
                    .map(
                      (entry) => Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: _getLocationIconColorForIndex(
                                entry.key + 1,
                              ),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _getLocalizedName(
                                  nameUz: entry.value.shortNameUz,
                                  nameRu: entry.value.shortNameRu,
                                  nameEn: entry.value.shortNameEn,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    ,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetroLinePicker() {
    final theme = Theme.of(context);
    final controlBg = ThemeState().isBlueTheme
        ? BlueThemeColors.surface
        : theme.colorScheme.surfaceContainerHighest;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: controlBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: _metroLineScrollController,
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                setState(() {
                  _searchFiltersState.setSubwayLine(index);
                  // Reset location when metro line is selected
                  if (index > 0) {
                    _searchFiltersState.setLocationIndex(0);
                  }
                });
                if (index > 0) {
                  _loadStationsForLine(index);
                  final subwayBloc = context.read<SubwayStationsBloc>();
                  subwayBloc.add(
                    SubwayStationsEvent.fetchSubwayStationsByLine(line: index),
                  );
                } else {
                  setState(() {
                    _currentStations = [];
                  });
                }
              },
              children: [
                // Unselected option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MLetterIcon(
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                        Text(
                          L10n.get("select_metro_line"),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              ThemeState().isBlueTheme
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Metro line options
                ...([
                  MetroCache.getLineName(1, LanguageState().currentLanguage),
                  MetroCache.getLineName(2, LanguageState().currentLanguage),
                  MetroCache.getLineName(3, LanguageState().currentLanguage),
                  MetroCache.getLineName(4, LanguageState().currentLanguage),
                ].asMap().entries.map(
                  (entry) => Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MLetterIcon(
                          color: _getLineColor(entry.key + 1),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  ThemeState().isBlueTheme
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          // Right part with arrows
          Container(
            width: 40,
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

  Widget _buildListingTypeOption(
    int value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isSelected = _searchFiltersState.selectedListingTypeId == value;
    return InkWell(
      onTap: () {
        HapticFeedbackUtils.impact();
        setState(() {
          _searchFiltersState.setListingTypeId(value);
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
          color: isSelected
              ? color
              : (ThemeState().isBlueTheme
                  ? BlueThemeColors.surface
                  : theme.colorScheme.surfaceContainerHighest),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(int gender, String label, Color color) {
    final theme = Theme.of(context);
    final isSelected = _searchFiltersState.selectedGender == gender;
    return InkWell(
      onTap: () {
        HapticFeedbackUtils.impact();
        setState(() {
          _searchFiltersState.setGender(gender);
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
          color: isSelected
              ? color
              : (ThemeState().isBlueTheme
                  ? BlueThemeColors.surface
                  : theme.colorScheme.surfaceContainerHighest),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                gender == 1 ? Icons.male : Icons.female,
                color: isSelected ? Colors.white : color,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationWheelPlaceholder({bool isLoading = false}) {
    final theme = Theme.of(context);
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
      child:
          isLoading
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
                          color:
                              ThemeState().isBlueTheme
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

  Widget _buildLocationWheelPicker(List<Location> locations) {
    final theme = Theme.of(context);
    _currentLocations = List.from(locations);
    final controlBg = ThemeState().isBlueTheme
        ? BlueThemeColors.surface
        : theme.colorScheme.surfaceContainerHighest;

    return Container(
      key: ValueKey(
        "location_picker_${_searchFiltersState.selectedSubwayLine}",
      ),
      decoration: BoxDecoration(
        color: controlBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController:
                  _locationScrollController ??
                  FixedExtentScrollController(
                    initialItem: _getInitialLocationItem(),
                  ),
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                setState(() {
                  if (index == 0) {
                    // "Select location" option
                    _searchFiltersState.setLocationIndex(0);
                  } else {
                    // Get the actual location ID from the selected index
                    final locationIndex = index - 1;
                    if (locationIndex < _currentLocations.length) {
                      final selectedLocationId =
                          _currentLocations[locationIndex].id;
                      _searchFiltersState.setLocationIndex(selectedLocationId);
                    }
                  }
                  // Reset metro filters when location is selected
                  // This ensures location and metro filters are mutually exclusive
                  if (index > 0) {
                    _resetMetroPickers();
                  }
                });
              },
              children: [
                // Unselected option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        L10n.get("select_location"),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Location options
                ..._currentLocations
                    .asMap()
                    .entries
                    .map(
                      (entry) => Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: _getLocationIconColorForIndex(
                                entry.key + 1,
                              ),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _getLocalizedName(
                                  nameUz: entry.value.shortNameUz,
                                  nameRu: entry.value.shortNameRu,
                                  nameEn: entry.value.shortNameEn,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    ,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    HapticFeedbackUtils.impact();

    // Get all current filter values
    final listingTypeId = _searchFiltersState.selectedListingTypeId;
    final locationId = _getSelectedLocationId();
    final subwayStationId = _getSelectedSubwayStationId();
    final subwayLine = _searchFiltersState.selectedSubwayLine;
    final gender = _searchFiltersState.selectedGender;
    final minPrice = _searchFiltersState.minPrice;
    final maxPrice = _searchFiltersState.maxPrice;
    final privateRoom = _searchFiltersState.privateRoom;

    // Debug logging to see what values are being passed
    logger.d(
      "SearchBottomSheet._performSearch - subwayStationId: $subwayStationId, subwayLine: $subwayLine, priceRange: $minPrice-$maxPrice",
    );

    // Debug logging to see what will be passed to HomeScreen
    logger.d(
      "SearchBottomSheet._performSearch - Will create HomeScreen with subwayLineId: $subwayLine, priceRange: $minPrice-$maxPrice",
    );

    // Navigate to home screen with search parameters
    Navigator.pop(context);

    if (widget.replaceCurrentRoute) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => ListingsBloc(getIt<IListingService>()),
                child: HomeScreen(
                  listingTypeId: listingTypeId,
                  locationId: locationId,
                  subwayStationId: subwayStationId,
                  subwayLineId: subwayLine,
                  gender: gender > 0 ? gender : null,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  privateRoom: privateRoom,
                  isSearchMode: true,
                ),
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => ListingsBloc(getIt<IListingService>()),
                child: HomeScreen(
                  listingTypeId: listingTypeId,
                  locationId: locationId,
                  subwayStationId: subwayStationId,
                  subwayLineId: subwayLine,
                  gender: gender > 0 ? gender : null,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  privateRoom: privateRoom,
                  isSearchMode: true,
                ),
              ),
        ),
      );
    }
  }

  /// Builds a RichText widget that supports bold formatting for the explanation text
  Widget _buildRichTextExplanation(BuildContext context, ThemeData theme) {
    final explanationText = L10n.get("all_stations_explanation")
        .replaceAll("{count}", "${_currentStations.length}")
        .replaceAll(
          "{line}",
          MetroCache.getLineName(
            _searchFiltersState.selectedSubwayLine,
            LanguageState().currentLanguage,
          ),
        );

    // Parse the text and create TextSpans for bold formatting
    final spans = <TextSpan>[];
    final boldRegex = RegExp("<b>(.*?)</b>");
    var lastIndex = 0;

    for (final Match match in boldRegex.allMatches(explanationText)) {
      // Add text before the bold tag
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: explanationText.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.normal,
            ),
          ),
        );
      }

      // Add bold and underlined text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationThickness: 1.0,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after the last bold tag
    if (lastIndex < explanationText.length) {
      spans.add(
        TextSpan(
          text: explanationText.substring(lastIndex),
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.normal,
          ),
        ),
      );
    }

    return AnimatedOpacity(
      opacity: _isBlinking ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.center,
      ),
    );
  }
}
