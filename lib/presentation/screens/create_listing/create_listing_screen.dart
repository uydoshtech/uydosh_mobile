import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_ai_enhance_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_amenities_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";

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
  FixedExtentScrollController? _genderScrollController;
  FixedExtentScrollController? _listingTypeScrollController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _metroStationScrollController;

  // State variables
  int _selectedListingTypeId = 2; // 2 = roommate needed, 1 = room needed
  int _defaultListingTypeFromProfile = 2; // Profile-based default for reset
  int _selectedGender = 1;
  int _defaultGenderFromProfile = 1; // Profile-based default for reset
  double _price = 50.0;
  bool _isPrivateRoom = false; // Add private room toggle
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  bool _isSubmitting = false;
  bool _isLoadingLocations = false;
  bool _isLoadingStations = false;

  // Validation state variables
  bool _showDescriptionError = false;
  bool _showLocationError = false;

  // Lists
  List<Location> _currentLocations = [];
  List<SubwayStation> _currentStations = [];
  final Set<int> _selectedAmenityIds = {};
  List<String> _selectedPhotos = [];
  int? _primaryPhotoIndex; // Track which photo is primary

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "create_listing");
    _locationScrollController = FixedExtentScrollController(initialItem: 0);
    _genderScrollController = FixedExtentScrollController(initialItem: 0);
    _listingTypeScrollController = FixedExtentScrollController(initialItem: 0);
    _metroLineScrollController = FixedExtentScrollController(
      initialItem: _selectedSubwayLine,
    );
    _metroStationScrollController = FixedExtentScrollController(
      initialItem: _selectedStationIndex,
    );
    _loadLocations();
    _initProfileDefaults();
    // Initialize title with default generated title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTitle();
    });
  }

  /// Set default listing type and gender from profile
  Future<void> _initProfileDefaults() async {
    // Run role and gender fetch in parallel
    final roleFuture = _getUserRole();
    final genderFuture = _getProfileGender();

    final role = await roleFuture;
    final gender = await genderFuture;

    if (!mounted) return;
    final defaultType = role == "tenant" ? 1 : 2;
    final defaultGender = (gender == 1 || gender == 2) ? gender! : 1;
    setState(() {
      _defaultListingTypeFromProfile = defaultType;
      _selectedListingTypeId = defaultType;
      _defaultGenderFromProfile = defaultGender;
      _selectedGender = defaultGender;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final listingTypeOptions = [2, 1];
      final genderOptions = [1, 2];
      final listingTypeIndex = listingTypeOptions.indexOf(_selectedListingTypeId);
      final genderIndex = genderOptions.indexOf(_selectedGender);
      _listingTypeScrollController?.animateToItem(
        listingTypeIndex >= 0 ? listingTypeIndex : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      _genderScrollController?.animateToItem(
        genderIndex >= 0 ? genderIndex : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
    _updateTitle();
  }

  Future<String?> _getUserRole() async {
    var role = await SessionManager.getUserRole();
    if (role != null) return role;
    try {
      final response = await getIt<IOAuthApiClient>()
          .post<Map<String, dynamic>, _EmptyRequest>(
            "/users/verify-session",
            (json) => json as Map<String, dynamic>,
            data: _EmptyRequest(),
          );
      final user = response["user"];
      role = user is Map<String, dynamic> ? user["role"] as String? : null;
      if (role != null) await SessionManager.storeUserRole(role);
      return role;
    } catch (_) {
      return null;
    }
  }

  /// Get profile gender (1 = male, 2 = female). Returns null if not available.
  Future<int?> _getProfileGender() async {
    var profile = await SessionManager.getCachedUserProfile();
    if (profile?.gender != null && (profile!.gender == 1 || profile.gender == 2)) {
      return profile.gender;
    }
    try {
      profile = await getIt<IUserProfileService>().getCurrentUserProfile();
      if (profile.gender != null && (profile.gender == 1 || profile.gender == 2)) {
        return profile.gender;
      }
    } catch (_) {}
    return null;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _metroStationScrollController?.animateToItem(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
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
    final currentLanguage = L10n.currentLanguage;

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
      Colors.brown,
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

    return L10n.get(titleKey);
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

  // Theme-dependent color for control backgrounds (inputs, cards, sections)
  Color _getControlBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.surface;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.white;
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
    _genderScrollController?.dispose();
    _listingTypeScrollController?.dispose();
    _metroLineScrollController?.dispose();
    _metroStationScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.showAppBar
              ? AppBar(
                title: L10n.text(
                  "create_listing_title",
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
                  scrollController: _listingTypeScrollController,
                  onListingTypeChanged: (listingTypeId) {
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
                  scrollController: _genderScrollController,
                  onGenderChanged: (gender) {
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
        ListingFormMetroSection(
          selectedSubwayLine: _selectedSubwayLine,
          selectedStationIndex: _selectedStationIndex,
          currentStations: _currentStations,
          metroLineScrollController: _metroLineScrollController,
          metroStationScrollController: _metroStationScrollController,
          onLineChanged: (index) {
            setState(() {
              _selectedSubwayLine = index;
              if (index > 0) {
                _loadStationsForLine(index);
              } else {
                _currentStations = [];
                _selectedStationIndex = 0;
              }
            });
          },
          onStationChanged: (index) {
            setState(() {
              _selectedStationIndex = index;
              _syncLocationWithStation();
            });
          },
          onDismissKeyboard: _dismissKeyboard,
        ),
        const SizedBox(height: 10), // Space between metro fields and location
        // Location Field - Full Row
        LocationPicker(
          locations: _currentLocations,
          selectedLocationIndex: _selectedLocationIndex,
          scrollController: _locationScrollController,
          onLocationChanged: (locationIndex) {
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
        // Price Field - Single handle, stored as both min and max
        PriceRangePicker(
          minPrice: 10.0,
          maxPrice: 500.0,
          initialMinPrice: _price,
          initialMaxPrice: _price,
          useSinglePrice: true,
          onPriceRangeChanged: (minPrice, maxPrice) {
            _dismissKeyboard();
            setState(() {
              _price = minPrice; // Same value for both in single mode
            });
          },
        ),
        const SizedBox(height: 10), // Space between price range and description

        // Description Field
        L10n.inputField(
          "listing_description_hint",
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
                    fillColor: _getControlBackgroundColor(),
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListingDescriptionAiEnhanceButton(
                            controller: _descriptionController,
                            inlineWithCounter: true,
                          ),
                          const Spacer(),
                          Text(
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
                        ],
                      ),
                    );
                  },
                ),
              ),
        ),
        // Amenities Section
        ListingFormAmenitiesSection(
          selectedAmenityIds: _selectedAmenityIds,
          onAmenityToggled: (amenityId) {
            setState(() {
              if (_selectedAmenityIds.contains(amenityId)) {
                _selectedAmenityIds.remove(amenityId);
              } else {
                _selectedAmenityIds.add(amenityId);
              }
            });
          },
          onDismissKeyboard: _dismissKeyboard,
        ),

        const SizedBox(height: 16),

        // Move-in Date and Private Room Row
        Row(
          children: [
            // Move-in Date Field (50% width)
            Expanded(
              child: L10n.inputField(
                "quick_question_move_in_date",
                builder:
                    (hintText) => Container(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _moveInDateController,
                        builder: (context, value, child) {
                          final isEmpty = value.text.isEmpty;
                          final moveInDateLabel =
                              L10n.get("move_in_date_label");
                          final anyDateText = L10n.get("any_date").replaceAll("\n", " ");
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
                              final firstDate = DateTime.now();
                              final lastDate =
                                  DateTime.now().add(
                                    const Duration(days: 365),
                                  );
                              final existingDate =
                                  _moveInDateValue.isNotEmpty
                                      ? DateTime.tryParse(_moveInDateValue)
                                      : null;
                              final initialDate =
                                  existingDate != null &&
                                          !existingDate.isBefore(firstDate) &&
                                          !existingDate.isAfter(lastDate)
                                      ? existingDate
                                      : firstDate;
                              final picked =
                                  await LanguageAwareDatePicker.showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: firstDate,
                                    lastDate: lastDate,
                                    helpText:
                                        L10n.get("select_date"),
                                        cancelText:
                                        L10n.get("cancel"),
                                        confirmText:
                                        L10n.get("ok"),
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
                                fillColor: _getControlBackgroundColor(),
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
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.outline
                            : Colors.grey[600]!,
                  ),
                  color: _getControlBackgroundColor(),
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
                              L10n.get("private_room").replaceFirst(" ", "\n"),
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
                        activeThumbColor: _getBorderColor(),
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
            existingPhotos: const [], // No existing photos for new listings
            onDeleteExistingPhoto: (index) {}, // No-op for new listings
            onMakePhotoPrimary: (index) {}, // No-op for new listings
            onMakeNewPhotoPrimary:
                _makeNewPhotoPrimary, // Handle new photo primary selection
            deletingPhotoIds: const {}, // No deleting for new listings
            makingPhotoPrimaryIds: const {}, // No making primary for new listings
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
            text: L10n.get(
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            L10n.get("unauthenticated_listing_prompt"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          GhostButtonFactory.iconText(
            onPressed: () => context.pushAuthWizardAndRemoveUntil(),
            icon: Icons.login,
            text: L10n.get("authenticate_to_post_listing"),
            padding: const EdgeInsets.symmetric(vertical: 24),
            textStyle: const TextStyle(fontSize: 18),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
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
        message: L10n.get("title_required"),
      );
      return;
    }

    if (title.length > 50) {
      ToastTheme.showError(
        context,
        message: L10n.get("title_too_long"),
      );
      return;
    }

    // Validate description
    if (description.isEmpty) {
      ToastTheme.showError(
        context,
        message: L10n.get("description_required"),
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
        message: L10n.get("description_too_long"),
      );
      return;
    }

    // Validate location (mandatory)
    if (_selectedLocationIndex < 0) {
      ToastTheme.showError(
        context,
        message: L10n.get("location_required"),
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
      logger.d("  price: $_price");
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
      var orderedPhotos = <String>[];
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
        price: _price.round(),
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

      if (!mounted) return;

      getIt<AppAnalyticsService>().logListingCreated(
        listingTypeId: listingTypeId,
        locationId: selectedLocation.id,
        success: true,
      );

      // Show success message
      ToastTheme.showSuccess(
        context,
        message: L10n.get("listing_created_success"),
      );

      if (isIOSDevice && mounted) {
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => RoomPlanScanScreen(
              listingId: createdListing.id,
            ),
          ),
        );
      }

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedListingTypeId = _defaultListingTypeFromProfile;
        _selectedGender = _defaultGenderFromProfile;
        _price = 50.0;
        _selectedSubwayLine = 0;
        _selectedStationIndex = 0;
        _selectedLocationIndex = -1;
        _currentStations = [];
        _selectedAmenityIds.clear(); // Clear selected amenities
        _selectedPhotos.clear(); // Clear selected photos
        _primaryPhotoIndex = null; // Reset primary photo index
        _isSubmitting = false; // Reset loading state

        // Reset validation errors
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
            context.pushMainNavigationAndRemoveUntil();
          }
        });
      } else {
        // Use the global navigation key to switch to home tab
        if (mainNavigationKey.currentState != null) {
          mainNavigationKey.currentState!.navigateToIndex(0);
        } else {
          // Fallback: use pushAndRemoveUntil if navigation key is not available
          context.pushMainNavigationAndRemoveUntil();
        }
      }
    } catch (e) {
      logger.d("Error creating listing: $e");
      var errorMessage = L10n.get("error_creating_listing");

      // Check if it"s an authentication error
      if (e.toString().contains("401")) {
        errorMessage = L10n.get("authentication_required");
      }

      ToastTheme.showError(context, message: errorMessage);

      // Reset loading state on error
      setState(() {
        _isSubmitting = false;
      });
    }
  }

}

class _EmptyRequest implements IJsonEncodable {
  _EmptyRequest();
  @override
  Map<String, dynamic> toJson() => {};
}
