import "package:uy_dosh/base/logger/logger.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/base/cache/amenities_cache.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/common/amenity_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:intl/intl.dart";

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _moveInDateController = TextEditingController();
  String _moveInDateValue = "";
  FixedExtentScrollController? _locationScrollController;

  // State variables
  int _selectedListingTypeId = 2; // 2 = roommate needed, 1 = room needed
  int _selectedGender = 1;
  double _minPrice = 50.0;
  double _maxPrice = 200.0;
  bool _isPrivateRoom = false; // Add private room toggle
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  bool _isSubmitting = false;
  bool _isLoadingLocations = false;
  bool _isLoadingStations = false;

  // Validation state variables
  bool _showTitleError = false;
  bool _showDescriptionError = false;
  bool _showLocationError = false;

  // Lists
  List<Location> _currentLocations = [];
  List<SubwayStation> _currentStations = [];
  Set<int> _selectedAmenityIds = {};
  List<String> _selectedPhotos = [];
  int? _primaryPhotoIndex; // Track which photo is primary

  @override
  void initState() {
    super.initState();
    _locationScrollController = FixedExtentScrollController(initialItem: 0);
    _loadLocations();
    // Initialize title with default generated title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTitle();
    });
  }

  void _loadStationsForLine(int line) {
    setState(() {
      _selectedSubwayLine = line;
      _isLoadingStations = true;
    });

    // Trigger the BLoC to fetch stations for the selected line
    context.read<SubwayStationsBloc>().add(
      SubwayStationsEvent.fetchSubwayStationsByLine(line: line),
    );
  }

  void _loadLocations() {
    setState(() {
      _isLoadingLocations = true;
    });

    // Trigger the BLoC to fetch locations
    context.read<LocationsBloc>().add(const LocationsEvent.fetchLocations());
  }

  String _formatMoveInDateDisplay(DateTime date) {
    final locale = LanguageState().currentLanguage;
    try {
      return _capitalizeMonth(
        DateFormat("d MMMM yyyy", locale).format(date),
      );
    } catch (_) {
      return _capitalizeMonth(DateFormat("d MMMM yyyy").format(date));
    }
  }

  String _capitalizeMonth(String dateText) {
    final parts = dateText.split(" ");
    if (parts.length < 2) {
      return dateText;
    }
    final month = parts[1];
    if (month.isEmpty) {
      return dateText;
    }
    parts[1] = "${month.substring(0, 1).toUpperCase()}${month.substring(1)}";
    return parts.join(" ");
  }

  void _onStationsLoaded(List<SubwayStation> stations) {
    setState(() {
      _currentStations = stations;
      _selectedStationIndex = 0;
      _isLoadingStations = false;
    });
    // Sync location with the first station when stations are loaded
    _syncLocationWithStation();
  }

  /// Sync location picker with the selected subway station's location_id
  void _syncLocationWithStation() {
    if (_currentStations.isNotEmpty &&
        _selectedStationIndex >= 0 &&
        _selectedStationIndex < _currentStations.length) {
      final selectedStation = _currentStations[_selectedStationIndex];
      final stationLocationId = selectedStation.locationId;

      // Find the location index that matches the station's location_id
      final locationIndex = _currentLocations.indexWhere(
        (location) => location.id == stationLocationId,
      );

      if (locationIndex >= 0) {
        setState(() {
          _selectedLocationIndex = locationIndex;
        });

        // Animate the location picker to the correct position
        // +1 because the first item is the "unselected" option
        _locationScrollController?.animateToItem(
          locationIndex + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onLocationsLoaded(List<Location> locations) {
    setState(() {
      // Sort locations alphabetically by localized name
      _currentLocations = List.from(locations)..sort((a, b) {
        final aName = _getLocalizedName(
          nameUz: a.shortNameUz,
          nameRu: a.shortNameRu,
          nameEn: a.shortNameEn,
        );
        final bName = _getLocalizedName(
          nameUz: b.shortNameUz,
          nameRu: b.shortNameRu,
          nameEn: b.shortNameEn,
        );
        return aName.compareTo(bName);
      });
      _selectedLocationIndex = -1; // Keep unselected
      _isLoadingLocations = false;
    });
  }

  // Helper method to get the appropriate name based on current language
  String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    String? shortName,
  }) {
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );

    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? shortName ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? shortName ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? shortName ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? shortName ?? "Unknown";
    }
  }

  Color _getLineColor(int line) {
    return AppColors.getMetroLineColor(line);
  }

  Color _getLocationIconColor() {
    if (_selectedLocationIndex < 0) {
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
    return colors[_selectedLocationIndex % colors.length];
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// Generate title based on listing type and gender
  String _generateTitle() {
    String titleKey;

    if (_selectedListingTypeId == 2) {
      // Roommate needed
      if (_selectedGender == 1) {
        // Male
        titleKey = "title_male_roommate";
      } else {
        // Female
        titleKey = "title_female_roommate";
      }
    } else {
      // Room needed
      if (_selectedGender == 1) {
        // Male
        titleKey = "title_male_room";
      } else {
        // Female
        titleKey = "title_female_room";
      }
    }

    return LanguageAwareStringHelper.getCurrent(context, titleKey);
  }

  /// Update title field with generated title
  void _updateTitle() {
    final generatedTitle = _generateTitle();
    _titleController.text = generatedTitle;
  }

  // Theme-dependent color method for header background
  Color _getHeaderBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.surface; // Dark blue surface for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.white; // White for light theme
    } else {
      return Colors.white; // Default to light theme background
    }
  }

  // Theme-dependent color method for primary buttons
  Color _getPrimaryButtonColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary; // Blue for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else {
      return Colors.black; // Default to light theme button color
    }
  }

  // Theme-dependent color method for icons
  Color _getIconColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary; // Blue for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else {
      return Colors.black; // Default to light theme icon color
    }
  }

  // Theme-dependent color method for loading indicators
  Color _getLoadingIndicatorColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary; // Blue for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else {
      return Colors.black; // Default to light theme indicator color
    }
  }

  // Theme-dependent color method for borders
  Color _getBorderColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary; // Blue for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black for light theme
    } else {
      return Colors.black; // Default to light theme border color
    }
  }

  // Theme-dependent color method for amenity selections
  void _makeNewPhotoPrimary(int index) {
    setState(() {
      _primaryPhotoIndex = index;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.showAppBar
              ? AppBar(
                title: LanguageAwareStringHelper.getText(
                  "create_listing_title",
                  context,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
      body: BlocListener<SubwayStationsBloc, SubwayStationsState>(
        listener: (context, state) {
          state.map(
            initial: (_) => setState(() => _isLoadingStations = false),
            loading: (_) => setState(() => _isLoadingStations = true),
            loaded: (loadedState) => _onStationsLoaded(loadedState.stations),
            error: (_) => setState(() => _isLoadingStations = false),
          );
        },
        child: BlocListener<LocationsBloc, LocationsState>(
          listener: (context, state) {
            state.map(
              initial: (_) => setState(() => _isLoadingLocations = false),
              loading: (_) => setState(() => _isLoadingLocations = true),
              loaded:
                  (loadedState) => _onLocationsLoaded(loadedState.locations),
              error: (_) => setState(() => _isLoadingLocations = false),
            );
          },
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Show different content based on authentication status
                    ListenableBuilder(
                      listenable: AuthenticationState(),
                      builder: (context, child) {
                        final isAuthenticated =
                            AuthenticationState().isAuthenticated;

                        if (isAuthenticated) {
                          // Show the regular form for authenticated users
                          return _buildAuthenticatedForm();
                        } else {
                          // Show authentication prompt for unauthenticated users
                          return _buildUnauthenticatedPrompt();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 0,
        ), // Reduced from 16 to 0 to remove space between header and selection containers
        // Listing Type and Gender Selection - Side by Side
        Container(
          child: Row(
            children: [
              // Listing Type Selection (50% width)
              Expanded(
                child: ListingTypePicker(
                  selectedListingTypeId: _selectedListingTypeId,
                  onListingTypeChanged: (int listingTypeId) {
                    setState(() {
                      _selectedListingTypeId = listingTypeId;
                      // Clear photos when switching to "room needed" (listingTypeId == 1)
                      if (listingTypeId == 1) {
                        _selectedPhotos.clear();
                        _primaryPhotoIndex = null;
                      }
                    });
                    _updateTitle();
                  },
                  useThemeColors: true,
                  showArrows: false,
                ),
              ),
              const SizedBox(width: 12),
              // Gender Selection (50% width)
              Expanded(
                child: GenderPicker(
                  selectedGender: _selectedGender,
                  onGenderChanged: (int gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                    _updateTitle();
                  },
                  useThemeColors: true,
                  showArrows: false,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10), // Space between gender and metro fields
        // Metro Line and Station Selection
        Container(
          child: Row(
            children: [
              // Metro Line Selection (50% width)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: _selectedSubwayLine,
                          ),
                          onSelectedItemChanged: (index) {
                            _dismissKeyboard();
                            HapticFeedbackUtils.impact();
                            setState(() {
                              _selectedSubwayLine =
                                  index; // 0 = unselected, 1-4 = line numbers
                            });
                            if (index > 0) {
                              _loadStationsForLine(index);
                            } else {
                              setState(() {
                                _currentStations = [];
                                _selectedStationIndex = 0;
                              });
                            }
                          },
                          children: [
                            // Unselected option
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MLetterIcon(color: Colors.grey, size: 20),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: LanguageAwareStringHelper.getText(
                                      "select_metro_line_optional",
                                      context,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            ThemeState().isLightTheme
                                                ? Colors.black.withOpacity(0.7)
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Metro line options - match Metro screen style
                            ...([
                              MetroCache.getLineName(
                                1,
                                LanguageAwareStringHelper.getCurrentLanguage(
                                  context,
                                ),
                              ),
                              MetroCache.getLineName(
                                2,
                                LanguageAwareStringHelper.getCurrentLanguage(
                                  context,
                                ),
                              ),
                              MetroCache.getLineName(
                                3,
                                LanguageAwareStringHelper.getCurrentLanguage(
                                  context,
                                ),
                              ),
                              MetroCache.getLineName(
                                4,
                                LanguageAwareStringHelper.getCurrentLanguage(
                                  context,
                                ),
                              ),
                            ].asMap().entries.map(
                              (entry) => Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MLetterIcon(
                                      color: _getLineColor(entry.key + 1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              ThemeState().isLightTheme
                                                  ? Colors.black
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                        ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Metro Station Selection (50% width) - will show when line is selected
              Expanded(
                child:
                    _selectedSubwayLine > 0 && _currentStations.isNotEmpty
                        ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          height: 80,
                          child: Row(
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 40,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: _selectedStationIndex,
                                  ),
                                  onSelectedItemChanged: (index) {
                                    _dismissKeyboard();
                                    HapticFeedbackUtils.impact();
                                    setState(() {
                                      _selectedStationIndex = index;
                                      // Sync location picker with selected station's location_id
                                      _syncLocationWithStation();
                                    });
                                  },
                                  children:
                                      _currentStations.map((station) {
                                        final transferInfo =
                                            MetroCache.getTransferStationInfo(
                                              station.id,
                                            );
                                        return Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.train,
                                                color: _getLineColor(
                                                  station.line,
                                                ),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  _getLocalizedName(
                                                    nameUz: station.nameUz,
                                                    nameRu: station.nameRu,
                                                    nameEn: station.nameEn,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ThemeState()
                                                                .isLightTheme
                                                            ? Colors.black
                                                            : Theme.of(
                                                                  context,
                                                                )
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // Add train icon for transfer stations with connected line color
                                              if (transferInfo != null) ...[
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.train,
                                                  color: _getLineColor(
                                                    transferInfo['connectedStationLine'],
                                                  ), // Use connected station's line color
                                                  size: 20,
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.5),
                          ),
                          height: 80,
                          child: Center(
                            child: Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "select_metro_line_title",
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    ThemeState().isLightTheme
                                        ? Colors.black.withOpacity(0.7)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10), // Space between metro fields and location
        // Location Field - Full Row
        LocationPicker(
          locations: _currentLocations,
          selectedLocationIndex: _selectedLocationIndex,
          scrollController: _locationScrollController,
          onLocationChanged: (int locationIndex) {
            setState(() {
              _selectedLocationIndex = locationIndex;
              // Clear location error when user selects a location
              if (_showLocationError && locationIndex >= 0) {
                _showLocationError = false;
              }
            });
          },
          isLoading: _isLoadingLocations,
          isRequired: true,
          useThemeColors: true,
          useColoredIcons: true,
          showError: _showLocationError,
          showArrows: false,
        ),
        const SizedBox(height: 10), // Space between location and price range
        // Price Range Field - Full Row
        PriceRangePicker(
          minPrice: 10.0,
          maxPrice: 500.0,
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
          onPriceRangeChanged: (minPrice, maxPrice) {
            _dismissKeyboard();
            setState(() {
              _minPrice = minPrice;
              _maxPrice = maxPrice;
            });
          },
        ),
        const SizedBox(height: 10), // Space between price range and description

        // Description Field
        LanguageAwareStringHelper.getInputField(
          "listing_description_hint",
          context,
          builder:
              (hintText) => Container(
                child: TextFormField(
                  controller: _descriptionController,
                  onChanged: (value) {
                    if (_showDescriptionError && value.trim().isNotEmpty) {
                      setState(() {
                        _showDescriptionError = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                              : Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            _showDescriptionError
                                ? Colors.red
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[600]!),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            _showDescriptionError
                                ? Colors.red
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[600]!),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            _showDescriptionError
                                ? Colors.red
                                : _getBorderColor(),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    color:
                        ThemeState().isLightTheme
                            ? Colors.black
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 5,
                  maxLength: 1000,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) {
                    final max = maxLength ?? 0;
                    final isNearLimit =
                        max > 0 && (currentLength / max) >= 0.9;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "$currentLength/$maxLength",
                        style: TextStyle(
                          color:
                              isNearLimit
                                  ? Colors.red
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.7)
                                      : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
        ),
        // Amenities Section
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.outline
                      : AppColors.borderGrey600,
            ),
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _getOrderedAmenities()
                          .map(
                            (amenity) => AmenityToggle(
                              amenity: amenity,
                              isSelected: _selectedAmenityIds.contains(amenity.id),
                              onTap: () {
                                _dismissKeyboard();
                                setState(() {
                                  if (_selectedAmenityIds.contains(amenity.id)) {
                                    _selectedAmenityIds.remove(amenity.id);
                                  } else {
                                    _selectedAmenityIds.add(amenity.id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Move-in Date and Private Room Row
        Row(
          children: [
            // Move-in Date Field (50% width)
            Expanded(
              child: LanguageAwareStringHelper.getInputField(
                "quick_question_move_in_date",
                context,
                builder:
                    (hintText) => Container(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _moveInDateController,
                        builder: (context, value, child) {
                          final isEmpty = value.text.isEmpty;
                          final moveInDateLabel =
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "move_in_date_label",
                              );
                          final anyDateText = LanguageAwareStringHelper.getCurrent(
                            context,
                            "any_date",
                          ).replaceAll('\n', ' ');
                          final displayValue = isEmpty ? anyDateText : value.text;
                          final displayText = "$moveInDateLabel\n$displayValue";
                          final displayStyle = TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                ThemeState().isLightTheme
                                    ? Colors.black
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                          );
                          final hintStyle = TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                ThemeState().isLightTheme
                                    ? Colors.black
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                          );
                          return GestureDetector(
                            onTap: () async {
                              HapticFeedbackUtils.impact();
                              final DateTime? picked =
                                  await LanguageAwareDatePicker.showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                    helpText:
                                        LanguageAwareStringHelper.getCurrent(
                                          context,
                                          "select_date",
                                        ),
                                    cancelText:
                                        LanguageAwareStringHelper.getCurrent(
                                          context,
                                          "cancel",
                                        ),
                                    confirmText:
                                        LanguageAwareStringHelper.getCurrent(
                                          context,
                                          "ok",
                                        ),
                                  );
                              if (picked != null) {
                                _moveInDateValue =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                _moveInDateController.text =
                                    _formatMoveInDateDisplay(picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                hintText: hintText,
                                hintStyle: hintStyle,
                                hintMaxLines: 2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.outline
                                            : Colors.grey[600]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.outline
                                            : Colors.grey[600]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: _getBorderColor(),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.surfaceVariant
                                        : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.calendar,
                                  size: 22,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                          : Colors.grey[600],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  displayText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: isEmpty ? hintStyle : displayStyle,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Private Room Toggle (50% width)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.outline
                            : Colors.grey[600]!,
                  ),
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color:
                            _isPrivateRoom
                                ? _getBorderColor()
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.7)
                                    : Colors.grey[600]),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "private_room",
                              ).replaceFirst(" ", "\n"),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    ThemeState().isLightTheme
                                        ? Colors.black
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPrivateRoom,
                        onChanged: (value) {
                          HapticFeedbackUtils.impact();
                          setState(() {
                            _isPrivateRoom = value;
                          });
                        },
                        activeColor: _getBorderColor(),
                        activeTrackColor: _getBorderColor().withValues(
                          alpha: 0.3,
                        ),
                        inactiveThumbColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                                : Colors.grey[600],
                        inactiveTrackColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.3)
                                : Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Photos Section - Only show for roommate needed listings (not for room needed)
        if (_selectedListingTypeId !=
            1) // Hide for "room needed" (listingTypeId == 1)
          PhotoUploader(
            selectedPhotos: _selectedPhotos,
            onPhotosChanged: (photos) {
              setState(() {
                _selectedPhotos = photos;
                // If this is the first photo, make it primary
                if (photos.isNotEmpty && _primaryPhotoIndex == null) {
                  _primaryPhotoIndex = 0;
                }
              });
            },
            existingPhotos: [], // No existing photos for new listings
            onDeleteExistingPhoto: (index) {}, // No-op for new listings
            onMakePhotoPrimary: (index) {}, // No-op for new listings
            onMakeNewPhotoPrimary:
                _makeNewPhotoPrimary, // Handle new photo primary selection
            deletingPhotoIds: {}, // No deleting for new listings
            makingPhotoPrimaryIds: {}, // No making primary for new listings
            maxPhotos: 5,
            isRequired: false,
          ),

        const SizedBox(height: 16),

        // Submit Button
        Container(
          child: PrimaryButtonFactory.iconText(
            onPressed:
                _isSubmitting ? null : _submitForm, // Disable when submitting
            icon: _isSubmitting ? Icons.hourglass_empty : Icons.add,
            text: LanguageAwareStringHelper.getCurrent(
              context,
              _isSubmitting ? "creating_listing" : "create_listing_button",
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            isLoading: _isSubmitting,
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedPrompt() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "unauthenticated_listing_prompt",
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          GhostButtonFactory.iconText(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AuthWizardScreen()),
                (route) => false,
              );
            },
            icon: Icons.login,
            text: LanguageAwareStringHelper.getCurrent(
              context,
              "authenticate_to_post_listing",
            ),
            padding: const EdgeInsets.symmetric(vertical: 24),
            textStyle: const TextStyle(fontSize: 18),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    HapticFeedbackUtils.impact();

    // Prevent multiple submissions
    if (_isSubmitting) return;

    // Custom validation with toast messages
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Validate title
    if (title.isEmpty) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "title_required",
        ),
      );
      setState(() {
        _showTitleError = true;
      });
      return;
    } else {
      setState(() {
        _showTitleError = false;
      });
    }

    if (title.length > 50) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "title_too_long",
        ),
      );
      return;
    }

    // Validate description
    if (description.isEmpty) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "description_required",
        ),
      );
      setState(() {
        _showDescriptionError = true;
      });
      return;
    } else {
      setState(() {
        _showDescriptionError = false;
      });
    }

    if (description.length > 1000) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "description_too_long",
        ),
      );
      return;
    }

    // Validate location (mandatory)
    if (_selectedLocationIndex < 0) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "location_required",
        ),
      );
      setState(() {
        _showLocationError = true;
      });
      return;
    } else {
      setState(() {
        _showLocationError = false;
      });
    }

    // Metro line and station are now optional - no validation required

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the selected location and station (if available)
      final selectedLocation = _currentLocations[_selectedLocationIndex];
      final selectedStation =
          _selectedSubwayLine > 0 && _currentStations.isNotEmpty
              ? _currentStations[_selectedStationIndex]
              : null;

      // Determine listing type ID based on selection
      final listingTypeId = _selectedListingTypeId;

      // Log the request details
      logger.d("=== HTTP REQUEST DETAILS ===");
      logger.d("Method: POST");
      logger.d("URL: /listings");
      logger.d("Headers:");
      logger.d("  Content-Type: application/json");
      logger.d("  Authorization: Bearer <access_token>");
      logger.d("Request Body:");
      logger.d("  title: \"${_titleController.text.trim()}\"");
      logger.d("  listingTypeId: $listingTypeId");
      logger.d("  minPrice: $_minPrice");
      logger.d("  maxPrice: $_maxPrice");
      logger.d("  description: \"${_descriptionController.text.trim()}\"");
      logger.d(
        "  subwayStationId: ${selectedStation?.id ?? "null (optional)"}",
      );
      logger.d(
        "  subwayLineId: ${_selectedSubwayLine > 0 ? _selectedSubwayLine : "null (optional)"}",
      );
      logger.d("  locationId: ${selectedLocation.id}");
      logger.d("  amenityIds: ${_selectedAmenityIds.toList()}");
      logger.d(
        "Selected Location: ${selectedLocation.shortName} (ID: ${selectedLocation.id})",
      );
      logger.d(
        "Selected Station: ${selectedStation?.nameEn ?? "None selected"} (ID: ${selectedStation?.id ?? "null"})",
      );

      logger.d("==========================");

      // Get the listing service from dependency injection
      final listingService = getIt<IListingService>();

      // Reorder photos so primary photo comes first (only for roommate needed listings)
      List<String> orderedPhotos = [];
      if (_selectedListingTypeId != 1) {
        // Only process photos for roommate needed listings
        orderedPhotos = List.from(_selectedPhotos);
        if (_primaryPhotoIndex != null &&
            _primaryPhotoIndex! > 0 &&
            orderedPhotos.isNotEmpty) {
          final primaryPhoto = orderedPhotos.removeAt(_primaryPhotoIndex!);
          orderedPhotos.insert(0, primaryPhoto);
        }
      }

      final createdListing = await listingService.createListing(
        title: _titleController.text.trim(),
        listingTypeId: listingTypeId,
        minPrice: _minPrice.round(),
        maxPrice: _maxPrice.round(),
        description: _descriptionController.text.trim(),
        gender: _selectedGender,
        locationId: selectedLocation.id,
        amenityIds: _selectedAmenityIds.toList(),
        subwayStationId: selectedStation?.id, // Now optional, moved to end
        subwayLineId:
            _selectedSubwayLine > 0
                ? _selectedSubwayLine
                : null, // Add subway line ID
        moveInDate: _moveInDateValue.isNotEmpty
            ? _moveInDateValue
            : null, // Only send date if selected
        privateRoom: _isPrivateRoom, // Add private room preference
        photoPaths:
            orderedPhotos.isNotEmpty
                ? orderedPhotos
                : null, // Upload photos with primary first (only for roommate needed)
      );

      // Show success message
      ToastTheme.showSuccess(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "listing_created_success",
        ),
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedListingTypeId = 2;
        _selectedGender = 1;
        _minPrice = 50.0;
        _maxPrice = 200.0;
        _selectedSubwayLine = 0;
        _selectedStationIndex = 0;
        _selectedLocationIndex = -1;
        _currentStations = [];
        _selectedAmenityIds.clear(); // Clear selected amenities
        _selectedPhotos.clear(); // Clear selected photos
        _primaryPhotoIndex = null; // Reset primary photo index
        _isSubmitting = false; // Reset loading state

        // Reset validation errors
        _showTitleError = false;
        _showDescriptionError = false;
        _showLocationError = false;
      });

      // Regenerate title with default values
      _updateTitle();

      // Force home screen to refresh since we created a new listing
      HomeRefreshState().forceRefreshNow();

      // Navigate back to home screen after successful listing creation
      if (widget.showAppBar) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (mainNavigationKey.currentState != null) {
            mainNavigationKey.currentState!.navigateToIndex(0);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
              (route) => false,
            );
          }
        });
      } else {
        // Use the global navigation key to switch to home tab
        if (mainNavigationKey.currentState != null) {
          mainNavigationKey.currentState!.navigateToIndex(0);
        } else {
          // Fallback: use pushAndRemoveUntil if navigation key is not available
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
            (route) => false,
          );
        }
      }
    } catch (e) {
      logger.d("Error creating listing: $e");
      String errorMessage = LanguageAwareStringHelper.getCurrent(
        context,
        "error_creating_listing",
      );

      // Check if it"s an authentication error
      if (e.toString().contains("401")) {
        errorMessage = LanguageAwareStringHelper.getCurrent(
          context,
          "authentication_required",
        );
      }

      ToastTheme.showError(context, message: errorMessage);

      // Reset loading state on error
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<Amenity> _getOrderedAmenities() {
    return AmenitiesCache.getDefaultOrderedAmenities();
  }
}
