import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_ai_enhance_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_amenities_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

class EditListingScreen extends StatefulWidget {

  const EditListingScreen({required this.listingDetail, super.key});
  final ListingDetail listingDetail;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moveInDateController = TextEditingController();
  String _moveInDateValue = "";
  FixedExtentScrollController? _locationScrollController;
  FixedExtentScrollController? _genderScrollController;
  FixedExtentScrollController? _listingTypeScrollController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _metroStationScrollController;
  int _selectedListingTypeId = 2; // 2 = roommate needed, 1 = room needed
  int _selectedGender = 1; // Default to male (1 = male, 2 = female)
  double _price = 50.0;
  bool _isPrivateRoom = false; // Add private room toggle
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  List<SubwayStation> _currentStations = [];
  List<Location> _currentLocations = [];
  bool _isLoadingStations = false;
  bool _isLoadingLocations = false;
  bool _isSubmitting = false;

  // Validation state variables
  bool _showDescriptionError = false;
  bool _showLocationError = false;

  // Amenities state
  final Set<int> _selectedAmenityIds = {};

  // Photos state
  List<String> _selectedPhotos = [];
  List<Photo> _existingPhotos = [];
  final Set<int> _deletingPhotoIds = {}; // Track which photos are being deleted
  final Set<int> _makingPhotoPrimaryIds =
      {}; // Track which photos are being made primary

  @override
  void initState() {
    super.initState();
    _locationScrollController = FixedExtentScrollController(initialItem: 0);
    _initializeForm();
    _genderScrollController = FixedExtentScrollController(
      initialItem: [1, 2].indexOf(_selectedGender).clamp(0, 1),
    );
    _listingTypeScrollController = FixedExtentScrollController(
      initialItem: [2, 1].indexOf(_selectedListingTypeId).clamp(0, 1),
    );
    _metroLineScrollController = FixedExtentScrollController(
      initialItem: _selectedSubwayLine,
    );
    _metroStationScrollController = FixedExtentScrollController(
      initialItem: _selectedStationIndex,
    );
    _loadLocations();
  }

  void _initializeForm() {
    // Pre-populate form with existing listing data
    _titleController.text = widget.listingDetail.title;
    _descriptionController.text = widget.listingDetail.description ?? "";

    // Extract only the date part from moveInDate (remove time component)
    var moveInDate = widget.listingDetail.moveInDate ?? "";
    if (moveInDate.isNotEmpty && moveInDate.contains("T")) {
      moveInDate =
          moveInDate.split("T")[0]; // Take only the date part before "T"
    }
    _moveInDateValue = moveInDate;
    if (_moveInDateValue.isNotEmpty) {
      final parsedDate = DateTime.tryParse(_moveInDateValue);
      _moveInDateController.text =
          parsedDate != null
              ? _formatMoveInDateDisplay(parsedDate)
              : _moveInDateValue;
    }

    _isPrivateRoom = widget.listingDetail.privateRoom ?? false;

    // Initialize validation states
    _showDescriptionError = false;
    _showLocationError = false;

    // Set listing type
    // Convert string code to integer ID: "roommate_needed" -> 2, "room_needed" -> 1
    _selectedListingTypeId =
        widget.listingDetail.listingType.code == "roommate_needed" ? 2 : 1;
  
    // Set price (single value, stored as both min and max)
    _price = widget.listingDetail.price.toDouble();

    // Set gender
    if (widget.listingDetail.gender != null) {
      _selectedGender = widget.listingDetail.gender!;
    }

    // Set subway line and station
    if (widget.listingDetail.subwayStation != null) {
      _selectedSubwayLine = widget.listingDetail.subwayStation!.line;
      _loadStationsForLine(_selectedSubwayLine);
    }

    // Set selected amenities
    if (widget.listingDetail.amenities != null) {
      _selectedAmenityIds.addAll(
        widget.listingDetail.amenities!.map((amenity) => amenity.id).toList(),
      );
    }

    // Set existing photos
    if (widget.listingDetail.photos != null) {
      _existingPhotos = List.from(widget.listingDetail.photos!);
      // Convert existing photo URLs to local paths for PhotoPicker
      // For now, we"ll start with an empty list and handle photo updates separately
      _selectedPhotos = [];
    }
  }

  void _loadStationsForLine(int line) {
    setState(() {
      _selectedSubwayLine = line;
      _isLoadingStations = true;
    });

    context.read<SubwayStationsBloc>().add(
      SubwayStationsEvent.fetchSubwayStationsByLine(line: line),
    );
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

  void _loadLocations() {
    setState(() {
      _isLoadingLocations = true;
    });

    context.read<LocationsBloc>().add(const LocationsEvent.fetchLocations());
  }

  void _onStationsLoaded(List<SubwayStation> stations) {
    setState(() {
      _currentStations = stations;

      // Find and set the current station index
      if (widget.listingDetail.subwayStation != null) {
        final currentStationId = widget.listingDetail.subwayStation!.id;
        final stationIndex = stations.indexWhere(
          (station) => station.id == currentStationId,
        );
        _selectedStationIndex = stationIndex >= 0 ? stationIndex : 0;
      } else {
        _selectedStationIndex = 0;
      }

      _isLoadingStations = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _metroStationScrollController?.animateToItem(
        _selectedStationIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
    // Sync location with the selected station when stations are loaded
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

      // Find and set the current location index
      if (widget.listingDetail.location != null) {
        final currentLocationId = widget.listingDetail.location!.id;
        final locationIndex = locations.indexWhere(
          (location) => location.id == currentLocationId,
        );
        _selectedLocationIndex = locationIndex >= 0 ? locationIndex : -1;
      } else {
        _selectedLocationIndex = -1;
      }

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationScrollController?.dispose();
    _genderScrollController?.dispose();
    _listingTypeScrollController?.dispose();
    _metroLineScrollController?.dispose();
    _metroStationScrollController?.dispose();
    // Clean up any ongoing operations
    _makingPhotoPrimaryIds.clear();
    _deletingPhotoIds.clear();
    super.dispose();
  }

  Color _getLocationIconColor() {
    if (_selectedLocationIndex < 0) {
      return Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.6); // Use theme color
    }
    // Use theme colors for better consistency
    final colors = [
      Theme.of(context).colorScheme.error, // Red
      Theme.of(context).colorScheme.tertiary, // Orange/Amber
      Theme.of(context).colorScheme.tertiary, // Green
      Theme.of(context).colorScheme.primary, // Primary theme color
      Theme.of(context).colorScheme.secondary, // Secondary theme color
      Theme.of(context).colorScheme.tertiary, // Teal
      Theme.of(context).colorScheme.secondary, // Indigo
      Theme.of(context).colorScheme.secondary, // Pink
    ];
    return colors[_selectedLocationIndex % colors.length];
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: L10n.text(
          "edit_listing",
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onPrimary,
          ),
          onPressed: () {
            HapticFeedbackUtils.impact();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ActionDropdownMenu(
              items: _buildActionMenuItems(),
              icon: Icons.more_vert,
              iconColor:
                  theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onPrimary,
              tooltip: L10n.get("actions"),
            ),
          ),
        ],
      ),
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
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                });
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
                              },
                              useThemeColors: true,
                              showArrows: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Metro Line and Station Selection (Third Row)
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
                    const SizedBox(
                      height: 10,
                    ), // Space between metro fields and location
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
                      useThemeColors: true,
                      useColoredIcons: true,
                      showError: _showLocationError,
                      showArrows: false,
                    ),
                    const SizedBox(
                      height: 10,
                    ), // Space between location and price range
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
                    const SizedBox(
                      height: 10,
                    ), // Space between price range and description

                    // Description Field
                    Container(
                      child: TextFormField(
                        controller: _descriptionController,
                        onChanged: (value) {
                          // Clear error when user types
                          if (_showDescriptionError &&
                              value.trim().isNotEmpty) {
                            setState(() {
                              _showDescriptionError = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: L10n.get("listing_description_hint"),
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.7)
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
                                          ? theme.colorScheme.outline
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
                                          ? theme.colorScheme.outline
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
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
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
                                  : theme.colorScheme.onSurfaceVariant,
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
                                                ? theme.colorScheme
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

                    const SizedBox(height: 10),

                    // Move-in Date and Private Room Row
                    Row(
                      children: [
                        // Move-in Date Field (50% width)
                        Expanded(
                          child: L10n.inputField(
                            "quick_question_move_in_date",
                            builder:
                                (hintText) => Container(
                                  child: ValueListenableBuilder<
                                    TextEditingValue
                                  >(
                                    valueListenable: _moveInDateController,
                                    builder: (context, value, child) {
                                      final isEmpty = value.text.isEmpty;
                                      final moveInDateLabel =
                                          L10n.get("move_in_date_label");
                                      final anyDateText =
                                          L10n.get("any_date").replaceAll("\n", " ");
                                      final displayValue =
                                          isEmpty ? anyDateText : value.text;
                                      final displayText =
                                          "$moveInDateLabel\n$displayValue";
                                      final displayStyle = TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            ThemeState().isLightTheme
                                                ? Colors.black
                                                : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                      );
                                      final hintStyle = TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            ThemeState().isLightTheme
                                                ? Colors.black
                                                : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                      );
                                      return GestureDetector(
                                        onTap: () async {
                                          final firstDate = DateTime.now();
                                          final lastDate =
                                              DateTime.now().add(
                                                const Duration(days: 365),
                                              );
                                          final existingDate =
                                              _moveInDateValue.isNotEmpty
                                                  ? DateTime.tryParse(
                                                    _moveInDateValue,
                                                  )
                                                  : null;
                                          final initialDate =
                                              existingDate != null &&
                                                      !existingDate.isBefore(
                                                        firstDate,
                                                      ) &&
                                                      !existingDate.isAfter(
                                                        lastDate,
                                                      )
                                                  ? existingDate
                                                  : firstDate;
                                          final picked = await LanguageAwareDatePicker.showDatePicker(
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
                                                _formatMoveInDateDisplay(
                                                  picked,
                                                );
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            hintText: hintText,
                                            hintStyle: hintStyle,
                                            hintMaxLines: 2,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? theme
                                                            .colorScheme
                                                            .outline
                                                        : Colors.grey[600]!,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? theme
                                                            .colorScheme
                                                            .outline
                                                        : Colors.grey[600]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: _getBorderColor(),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor:
                                                _getControlBackgroundColor(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 16,
                                                ),
                                            prefixIcon: Icon(
                                              CupertinoIcons.calendar,
                                              size: 22,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? theme
                                                          .colorScheme
                                                          .onSurfaceVariant
                                                      : Colors.grey[600],
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              displayText,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  isEmpty
                                                      ? hintStyle
                                                      : displayStyle,
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
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? theme.colorScheme.outline
                                        : Colors.grey[600]!,
                              ),
                              color:
                                  _getControlBackgroundColor(),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 6.0,
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
                                                ? theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7)
                                                : Colors.grey[600]),
                                      size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          L10n.get("private_room").replaceFirst(" ", "\n"),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                ThemeState().isLightTheme
                                                    ? Colors.black
                                                    : theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
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
                                    activeTrackColor: _getBorderColor()
                                        .withValues(alpha: 0.3),
                                    inactiveThumbColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.7)
                                            : Colors.grey[600],
                                    inactiveTrackColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.3)
                                            : Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Photos Section
                    PhotoUploader(
                      selectedPhotos: _selectedPhotos,
                      onPhotosChanged: (photos) {
                        logger.d("=== PHOTO SELECTION CHANGED ===");
                        logger.d("Previous selected photos: $_selectedPhotos");
                        logger.d("New selected photos: $photos");
                        setState(() {
                          _selectedPhotos = photos;
                        });
                        logger.d("Updated _selectedPhotos: $_selectedPhotos");
                      },
                      existingPhotos: _existingPhotos,
                      onDeleteExistingPhoto: _deleteExistingPhoto,
                      onMakePhotoPrimary: _makePhotoPrimary,
                      onMakeNewPhotoPrimary: _makeNewPhotoPrimary,
                      deletingPhotoIds: _deletingPhotoIds,
                      makingPhotoPrimaryIds: _makingPhotoPrimaryIds,
                      maxPhotos: 5,
                      isRequired: false,
                    ),

                    const SizedBox(height: 20),

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

                    // Update Button
                    Container(
                      child: GhostButtonFactory.iconText(
                        onPressed:
                            _isSubmitting
                                ? null
                                : _submitForm, // Disable when submitting
                        icon: Icons.save,
                        text: L10n.get(
                          _isSubmitting
                              ? "updating_listing"
                              : "update_listing_button",
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        isLoading: _isSubmitting,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
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

    if (title.length > 25) {
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

      // Update listing using the service
      final listingService = getIt<IListingService>();

      // First, update the listing details (without photos)
      await listingService.updateListing(
        listingId: widget.listingDetail.id,
        title: _titleController.text.trim(),
        listingTypeId: listingTypeId,
        price: _price.round(),
        description: _descriptionController.text.trim(),
        gender: _selectedGender,
        locationId: selectedLocation.id,
        amenityIds: _selectedAmenityIds.toList(),
        subwayStationId: selectedStation?.id, // Made optional, moved to end
        subwayLineId:
            _selectedSubwayLine > 0
                ? _selectedSubwayLine
                : null, // Add subway line ID
        moveInDate: _moveInDateValue.isNotEmpty
            ? _moveInDateValue
            : null, // Add move-in date
        privateRoom: _isPrivateRoom, // Add private room preference
        photoPaths: null, // Don"t upload photos during listing update
      );

      // Then, upload new photos separately if any were selected
      if (_selectedPhotos.isNotEmpty) {
        try {
          logger.d("=== UPLOADING NEW PHOTOS FOR UPDATED LISTING ===");
          logger.d("New photo count: ${_selectedPhotos.length}");
          logger.d("New photo paths: $_selectedPhotos");
          logger.d("Existing photos count: ${_existingPhotos.length}");

          // Create isPrimary flags (first new photo is primary if no existing photos)
          final isPrimaryFlags = List<bool>.generate(
            _selectedPhotos.length,
            (index) =>
                _existingPhotos.isEmpty &&
                index ==
                    0, // First new photo is primary only if no existing photos
          );

          logger.d("IsPrimary flags: $isPrimaryFlags");

          // Upload new photos
          await listingService.uploadListingPhotos(
            listingId: widget.listingDetail.id,
            photoPaths: _selectedPhotos,
            isPrimaryFlags: isPrimaryFlags,
          );

          logger.d("✅ All new photos uploaded successfully");
        } catch (photoError) {
          logger.d("⚠️ Warning: New photos failed to upload: $photoError");
          ToastTheme.showError(
            context,
            message: L10n.get("error_uploading_photos"),
          );
          // Don"t fail the entire listing update if photos fail
        }
      } else {
        logger.d("No new photos to upload");
      }

      // Show success message
      ToastTheme.showSuccess(
        context,
        message: L10n.get("listing_updated_success"),
      );

      // Clear all error states on success
      setState(() {
        _showDescriptionError = false;
        _showLocationError = false;
      });

      // Clear selected photos after successful update
      _selectedPhotos.clear();

      // Mark home screen for refresh since we updated a listing
      HomeRefreshState().markForRefresh();

      // Navigate back to listing detail screen with updated flag
      Navigator.of(context).pop(true); // true indicates listing was updated
    } catch (e) {
      var errorMessage = L10n.get("error_updating_listing");

      // Check if it"s an authentication error
      if (e.toString().contains("401")) {
        errorMessage = L10n.get("authentication_required");
      }

      ToastTheme.showError(context, message: errorMessage);
    } finally {
      // Reset loading state
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<ActionMenuItem> _buildActionMenuItems() {
    return [
      ActionMenuItem(
        value: "save",
        icon: Icons.save,
        textKey: "save_changes",
        onPressed:
            _isSubmitting ? () {} : _submitForm, // Disable when submitting
      ),
    ];
  }

  Future<void> _deleteExistingPhoto(int index) async {
    final photo = _existingPhotos[index];

    // Prevent deletion if this is the last photo and photos are required
    if (_existingPhotos.length <= 1) {
      ToastTheme.showError(
        context,
        message: L10n.get("cannot_delete_last_photo"),
      );
      return;
    }

    // Show confirmation dialog
    final shouldDelete = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "delete_photo",
      messageKey: "delete_photo_confirmation",
    );

    if (shouldDelete ?? false) {
      try {
        // Show loading state
        setState(() {
          _deletingPhotoIds.add(photo.id);
        });

        // Create listing service instance
        final listingService = getIt<IListingService>();

        // Delete photo from server
        await listingService.deletePhoto(
          listingId: widget.listingDetail.id,
          photoId: photo.id,
        );

        // Check if we need to handle primary photo promotion before removing the photo
        final wasPrimaryPhoto = photo.isPrimary;
        final remainingPhotosCount =
            _existingPhotos.length - 1; // -1 because we"re about to remove one
        final shouldPromoteNewPrimary =
            wasPrimaryPhoto && remainingPhotosCount > 0;
        int? newPrimaryPhotoId;

        if (shouldPromoteNewPrimary) {
          // Get the ID of the photo that will become primary (first remaining photo)
          newPrimaryPhotoId = _existingPhotos[0].id;
        }

        // Remove photo from local state
        setState(() {
          _existingPhotos.removeAt(index);
          _deletingPhotoIds.remove(photo.id);

          // If we deleted the primary photo and there are remaining photos,
          // automatically promote the first photo to primary
          if (shouldPromoteNewPrimary) {
            // First, ensure no other photos are marked as primary
            for (var i = 0; i < _existingPhotos.length; i++) {
              if (_existingPhotos[i].isPrimary) {
                _existingPhotos[i] = _existingPhotos[i].copyWith(
                  isPrimary: false,
                );
              }
            }

            // Update the first photo to be primary
            _existingPhotos[0] = _existingPhotos[0].copyWith(isPrimary: true);

            // Show notification to user about the automatic primary photo change
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ToastTheme.showSuccess(
                context,
                message: L10n.get("new_primary_photo_selected"),
              );
            });
          } else if (wasPrimaryPhoto && remainingPhotosCount == 0) {
            // If we deleted the last photo (which was primary), show a different message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ToastTheme.showSuccess(
                context,
                message: L10n.get("last_photo_deleted"),
              );
            });
          }
        });

        // Update backend for new primary photo if needed (do this after setState)
        if (shouldPromoteNewPrimary && newPrimaryPhotoId != null) {
          _updatePrimaryPhotoInBackend(newPrimaryPhotoId);
        }

        // Show success message
        ToastTheme.showSuccess(
          context,
          message: L10n.get("photo_deleted_success"),
        );
      } catch (e) {
        // Hide loading state
        setState(() {
          _deletingPhotoIds.remove(photo.id);
        });

        // Show error message
        ToastTheme.showError(
          context,
          message: L10n.get("error_deleting_photo"),
        );
      }
    }
  }

  /// Updates the primary photo in the backend when automatically promoting a photo
  /// after the previous primary photo was deleted
  Future<void> _updatePrimaryPhotoInBackend(int newPrimaryPhotoId) async {
    try {
      // Create listing service instance
      final listingService = getIt<IListingService>();

      // Call backend API to set the new primary photo
      await listingService.setPrimaryPhoto(
        listingId: widget.listingDetail.id,
        photoId: newPrimaryPhotoId,
      );
    } catch (e) {
      // Don"t show error to user since this is an automatic operation
      // The local state is already updated, so the UI will still work
    }
  }

  Future<void> _makePhotoPrimary(int index) async {
    final photo = _existingPhotos[index];

    // Don"t do anything if photo is already primary
    if (photo.isPrimary) return;

    try {
      // Show loading state
      setState(() {
        _makingPhotoPrimaryIds.add(photo.id);
      });

      // Create listing service instance
      final listingService = getIt<IListingService>();

      // Call backend API to set photo as primary
      await listingService.setPrimaryPhoto(
        listingId: widget.listingDetail.id,
        photoId: photo.id,
      );

      // Update local state to reflect the change
      setState(() {
        // Update all photos to set isPrimary to false
        for (var i = 0; i < _existingPhotos.length; i++) {
          _existingPhotos[i] = _existingPhotos[i].copyWith(
            isPrimary: i == index,
          );
        }
        // Remove from loading state
        _makingPhotoPrimaryIds.remove(photo.id);
      });

      // Show success message
      ToastTheme.showSuccess(
        context,
        message: L10n.get("photo_made_primary"),
      );
    } catch (e) {
      // Remove from loading state on error
      setState(() {
        _makingPhotoPrimaryIds.remove(photo.id);
      });

      // Show error message
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic"),
      );
    }
  }

  void _makeNewPhotoPrimary(int index) {
    // This method is called when a new photo is made primary
    // We need to clear primary status from existing photos
    setState(() {
      // Clear primary status from all existing photos
      for (var i = 0; i < _existingPhotos.length; i++) {
        _existingPhotos[i] = _existingPhotos[i].copyWith(isPrimary: false);
      }
    });
  }
}
