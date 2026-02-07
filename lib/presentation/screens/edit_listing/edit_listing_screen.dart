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
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:intl/intl.dart";

class EditListingScreen extends StatefulWidget {
  final ListingDetail listingDetail;

  const EditListingScreen({super.key, required this.listingDetail});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moveInDateController = TextEditingController();
  String _moveInDateValue = "";
  FixedExtentScrollController? _locationScrollController;
  int _selectedListingTypeId = 2; // 2 = roommate needed, 1 = room needed
  int _selectedGender = 1; // Default to male (1 = male, 2 = female)
  double _minPrice = 50.0;
  double _maxPrice = 250.0;
  bool _isPrivateRoom = false; // Add private room toggle
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  Set<int> _selectedStationIds = {};
  Set<int> _selectedLocationIds = {};
  List<SubwayStation> _currentStations = [];
  List<Location> _currentLocations = [];
  bool _isLoadingStations = false;
  bool _isLoadingLocations = false;
  bool _isSubmitting = false;

  // Validation state variables
  bool _showTitleError = false;
  bool _showDescriptionError = false;
  bool _showLocationError = false;

  // Amenities state
  final Set<int> _selectedAmenityIds = {};
  final Map<int, AnimationController> _amenityAnimationControllers = {};
  final Map<int, Animation<double>> _amenityScaleAnimations = {};

  // Photos state
  List<String> _selectedPhotos = [];
  List<Photo> _existingPhotos = [];
  Set<int> _deletingPhotoIds = {}; // Track which photos are being deleted
  Set<int> _makingPhotoPrimaryIds =
      {}; // Track which photos are being made primary

  @override
  void initState() {
    super.initState();
    _locationScrollController = FixedExtentScrollController(initialItem: 0);
    _initializeForm();
    _loadLocations();
  }

  void _initializeForm() {
    // Pre-populate form with existing listing data
    _titleController.text = widget.listingDetail.title;
    _descriptionController.text = widget.listingDetail.description ?? "";

    // Extract only the date part from moveInDate (remove time component)
    String moveInDate = widget.listingDetail.moveInDate ?? "";
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
    _showTitleError = false;
    _showDescriptionError = false;
    _showLocationError = false;

    // Set listing type
    if (widget.listingDetail.listingType != null) {
      // Convert string code to integer ID: "roommate_needed" -> 2, "room_needed" -> 1
      _selectedListingTypeId =
          widget.listingDetail.listingType!.code == "roommate_needed" ? 2 : 1;
    }

    // Set price range
    _minPrice = widget.listingDetail.minPrice.toDouble();
    _maxPrice = widget.listingDetail.maxPrice.toDouble();

    // Set gender
    if (widget.listingDetail.gender != null) {
      _selectedGender = widget.listingDetail.gender!;
    }

    // Set subway line and station
    if (widget.listingDetail.subwayStation != null) {
      _selectedSubwayLine = widget.listingDetail.subwayStation!.line;
      _loadStationsForLine(_selectedSubwayLine);
    }

    if (widget.listingDetail.subwayStationIds != null &&
        widget.listingDetail.subwayStationIds!.isNotEmpty) {
      _selectedStationIds.addAll(widget.listingDetail.subwayStationIds!);
    } else if (widget.listingDetail.subwayStationId != null) {
      _selectedStationIds.add(widget.listingDetail.subwayStationId!);
    }

    if (widget.listingDetail.locationIds != null &&
        widget.listingDetail.locationIds!.isNotEmpty) {
      _selectedLocationIds.addAll(widget.listingDetail.locationIds!);
    } else if (widget.listingDetail.locationId != null) {
      _selectedLocationIds.add(widget.listingDetail.locationId!);
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
    // Sync location with the selected station when stations are loaded
    if (!_isRoomNeeded) {
      _syncLocationWithStation();
    }
  }

  /// Sync location picker with the selected subway station's location_id
  void _syncLocationWithStation() {
    if (_isRoomNeeded) {
      return;
    }
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

      if (_isRoomNeeded) {
        _selectedLocationIndex = -1;
      } else {
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

  AnimationController _getAmenityAnimationController(int amenityId) {
    if (!_amenityAnimationControllers.containsKey(amenityId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      _amenityAnimationControllers[amenityId] = controller;
      _amenityScaleAnimations[amenityId] = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }
    return _amenityAnimationControllers[amenityId]!;
  }

  void _animateAmenityTap(int amenityId) {
    final controller = _getAmenityAnimationController(amenityId);
    // Scale up and then back down
    controller.forward().then((_) {
      controller.reverse();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationScrollController?.dispose();
    // Dispose all amenity animation controllers
    for (final controller in _amenityAnimationControllers.values) {
      controller.dispose();
    }
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

  bool get _isRoomNeeded => _selectedListingTypeId == 1;

  SubwayStation? _getCurrentSelectedStation() {
    if (_selectedSubwayLine <= 0 || _currentStations.isEmpty) {
      return null;
    }
    if (_selectedStationIndex < 0 ||
        _selectedStationIndex >= _currentStations.length) {
      return null;
    }
    return _currentStations[_selectedStationIndex];
  }

  void _addSelectedStation() {
    final station = _getCurrentSelectedStation();
    if (station == null) {
      return;
    }
    setState(() {
      _selectedStationIds.add(station.id);
      _showLocationError = false;
    });
  }

  void _addSelectedLineStations() {
    if (_selectedSubwayLine <= 0) {
      return;
    }
    final stations = MetroCache.getStationsForLine(_selectedSubwayLine);
    if (stations.isEmpty) {
      return;
    }
    setState(() {
      _selectedStationIds.addAll(stations.map((station) => station.id));
      _showLocationError = false;
    });
  }

  List<SubwayStation> _getSelectedStations() {
    final stations = _selectedStationIds
        .map(MetroCache.getStationById)
        .whereType<SubwayStation>()
        .toList();
    stations.sort((a, b) {
      if (a.line != b.line) {
        return a.line.compareTo(b.line);
      }
      return a.ordinal.compareTo(b.ordinal);
    });
    return stations;
  }

  bool _hasFullLineSelected(int line) {
    if (line <= 0) {
      return false;
    }
    final lineStations = MetroCache.getStationsForLine(line);
    if (lineStations.isEmpty) {
      return false;
    }
    final lineStationIds = lineStations.map((station) => station.id).toSet();
    return lineStationIds.difference(_selectedStationIds).isEmpty;
  }

  String _getLineName(int line) {
    return MetroCache.getLineName(
      line,
      LanguageAwareStringHelper.getCurrentLanguage(context),
    );
  }

  void _removeLineStations(int line) {
    final lineStations = MetroCache.getStationsForLine(line);
    if (lineStations.isEmpty) {
      return;
    }
    setState(() {
      _selectedStationIds.removeAll(lineStations.map((station) => station.id));
    });
  }

  String _getLocationNameById(int locationId) {
    for (final location in _currentLocations) {
      if (location.id == locationId) {
        return _getLocalizedName(
          nameUz: location.shortNameUz,
          nameRu: location.shortNameRu,
          nameEn: location.shortNameEn,
        );
      }
    }
    return "Unknown";
  }

  void _showLocationMultiSelectSheet() {
    final selectedIds = Set<int>.from(_selectedLocationIds);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final locations = List<Location>.from(_currentLocations);
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "select_districts",
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedIds
                                  ..clear()
                                  ..addAll(locations.map((location) => location.id));
                              });
                            },
                            child: Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "select_all",
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedIds.clear();
                              });
                            },
                            child: Text(
                              LanguageAwareStringHelper.getCurrent(
                                context,
                                "clear",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        itemCount: locations.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 8,
                          childAspectRatio: 4,
                        ),
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final isSelected = selectedIds.contains(location.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedIds.add(location.id);
                                } else {
                                  selectedIds.remove(location.id);
                                }
                              });
                            },
                            title: Text(
                              _getLocalizedName(
                                nameUz: location.shortNameUz,
                                nameRu: location.shortNameRu,
                                nameEn: location.shortNameEn,
                              ),
                            ),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "cancel",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLocationIds = selectedIds;
                                  _showLocationError = false;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "ok",
                                ),
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
          },
        );
      },
    );
  }

  Widget _buildSelectedStationsChips() {
    if (_selectedStationIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final stations = _getSelectedStations();
    final selectedLines = stations.map((station) => station.line).toSet();
    final fullLineSelections =
        selectedLines.where(_hasFullLineSelected).toList()..sort();
    final fullLineStationIds = <int>{};
    for (final line in fullLineSelections) {
      fullLineStationIds.addAll(
        MetroCache.getStationsForLine(line).map((station) => station.id),
      );
    }
    final displayStations = stations
        .where((station) => !fullLineStationIds.contains(station.id))
        .toList();
    if (displayStations.isEmpty && fullLineSelections.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        ...fullLineSelections.map((line) {
          return Chip(
            avatar: MLetterIcon(color: _getLineColor(line), size: 18),
            label: Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "line_all_stations",
              ).replaceAll("{line}", _getLineName(line)),
            ),
            onDeleted: () => _removeLineStations(line),
          );
        }),
        ...displayStations.map((station) {
          final stationName = _getLocalizedName(
            nameUz: station.nameUz,
            nameRu: station.nameRu,
            nameEn: station.nameEn,
          );
          return Chip(
            avatar: Icon(
              Icons.train,
              size: 18,
              color: _getLineColor(station.line),
            ),
            label: Text(stationName),
            onDeleted: () {
              setState(() {
                _selectedStationIds.remove(station.id);
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildSelectedLocationsChips() {
    if (_selectedLocationIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final locations = _selectedLocationIds.toList()
      ..sort((a, b) => _getLocationNameById(a).compareTo(_getLocationNameById(b)));
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children:
          locations.map((locationId) {
            return Chip(
              avatar: const Icon(
                Icons.location_on,
                size: 18,
                color: AppColors.error,
              ),
              label: Text(_getLocationNameById(locationId)),
              shape: StadiumBorder(
                side: BorderSide(color: _getBorderColor(), width: 1),
              ),
              onDeleted: () {
                setState(() {
                  _selectedLocationIds.remove(locationId);
                });
              },
            );
          }).toList(),
    );
  }

  Widget _buildMultiLocationSelector() {
    final hasSelections = _selectedLocationIds.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _showLocationMultiSelectSheet,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _showLocationError && !hasSelections
                        ? Colors.red
                        : Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "selected_districts_count",
                    ).replaceAll("{count}", _selectedLocationIds.length.toString()),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          ThemeState().isLightTheme
                              ? Colors.black.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_selectedLocationIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSelectedLocationsChips(),
        ],
        if (_showLocationError &&
            _selectedLocationIds.isEmpty &&
            _selectedStationIds.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "location_or_station_required",
            ),
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
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
        title: LanguageAwareStringHelper.getText(
          "edit_listing",
          context,
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
              tooltip: LanguageAwareStringHelper.getCurrent(context, "actions"),
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
                              onListingTypeChanged: (int listingTypeId) {
                                setState(() {
                                  _selectedListingTypeId = listingTypeId;
                                  _showLocationError = false;
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
                              onGenderChanged: (int gender) {
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
                    Container(
                      child: Row(
                        children: [
                          // Metro Line Selection (50% width)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
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
                                          FixedExtentScrollController(
                                            initialItem: _selectedSubwayLine,
                                          ),
                                      onSelectedItemChanged: (index) {
                                        _dismissKeyboard();
                                        HapticFeedbackUtils.impact();
                                        setState(() {
                                          _selectedSubwayLine = index;
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MLetterIcon(
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  LanguageAwareStringHelper.getCurrent(
                                                    context,
                                                    "select_metro_line",
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ThemeState()
                                                                .isLightTheme
                                                            ? Colors.black
                                                                .withOpacity(
                                                                  0.7,
                                                                )
                                                            : Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                                  .isLightTheme
                                                              ? Colors.black
                                                              : Theme.of(
                                                                    context,
                                                                  )
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                          const SizedBox(width: 12),
                          // Metro Station Selection (50% width) - will show when line is selected
                          Expanded(
                            child:
                                _selectedSubwayLine > 0 &&
                                        _currentStations.isNotEmpty
                                    ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: theme.colorScheme.outline,
                                        ),
                                        color: theme.colorScheme.surfaceVariant,
                                      ),
                                      height: 80,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 40,
                                              scrollController:
                                                  FixedExtentScrollController(
                                                    initialItem:
                                                        _selectedStationIndex,
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
                                                  _currentStations
                                                      .map(
                                                        (station) => Center(
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
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        ThemeState().isLightTheme
                                                                            ? Colors.black
                                                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: theme.colorScheme.outline,
                                        ),
                                        color: theme.colorScheme.surfaceVariant
                                            .withOpacity(0.5),
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
                                                    ? Colors.black.withOpacity(
                                                      0.7,
                                                    )
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ), // Space between metro fields and location
                    // Location Field - Full Row
                    if (_isRoomNeeded) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed:
                                    _selectedSubwayLine > 0
                                        ? _addSelectedLineStations
                                        : null,
                                icon: const Icon(Icons.playlist_add),
                                label: Text(
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "add_metro_line",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed:
                                    _getCurrentSelectedStation() != null
                                        ? _addSelectedStation
                                        : null,
                                icon: const Icon(Icons.add),
                                label: Text(
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "add_metro_station",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildSelectedStationsChips(),
                    ],
                    if (_isRoomNeeded)
                      _buildMultiLocationSelector()
                    else
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
                        useThemeColors: true,
                        useColoredIcons: true,
                        showError: _showLocationError,
                        showArrows: false,
                      ),
                    const SizedBox(
                      height: 10,
                    ), // Space between location and price range
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
                          hintText: LanguageAwareStringHelper.getCurrent(
                            context,
                            "listing_description_hint",
                          ),
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
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? theme.colorScheme.surfaceVariant
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
                                            ? theme.colorScheme
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

                    const SizedBox(height: 10),

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
                                  child: ValueListenableBuilder<
                                    TextEditingValue
                                  >(
                                    valueListenable: _moveInDateController,
                                    builder: (context, value, child) {
                                      final isEmpty = value.text.isEmpty;
                                      final moveInDateLabel =
                                          LanguageAwareStringHelper.getCurrent(
                                            context,
                                            "move_in_date_label",
                                          );
                                      final anyDateText =
                                          LanguageAwareStringHelper.getCurrent(
                                            context,
                                            "any_date",
                                          ).replaceAll('\n', ' ');
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
                                          final DateTime?
                                          picked = await LanguageAwareDatePicker.showDatePicker(
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
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? theme
                                                        .colorScheme
                                                        .surfaceVariant
                                                    : Colors.white,
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
                          child: Container(
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
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? theme.colorScheme.surfaceVariant
                                      : Colors.white,
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
                                    activeColor: _getBorderColor(),
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
                      onPhotosChanged: (List<String> photos) {
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? theme.colorScheme.outline
                                  : AppColors.borderGrey600,
                        ),
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? theme.colorScheme.surfaceVariant
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
                                        (amenity) =>
                                            _buildAmenityToggle(amenity),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
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
                        text: LanguageAwareStringHelper.getCurrent(
                          context,
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

    if (title.length > 25) {
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

    // Validate location
    if (_isRoomNeeded) {
      final hasLocations = _selectedLocationIds.isNotEmpty;
      final hasStations = _selectedStationIds.isNotEmpty;
      if (!hasLocations && !hasStations) {
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "location_or_station_required",
          ),
        );
        setState(() {
          _showLocationError = true;
        });
        return;
      }
      setState(() {
        _showLocationError = false;
      });
    } else {
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
    }

    // Metro line and station are now optional - no validation required

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the selected location and station (if available)
      final selectedLocation =
          (!_isRoomNeeded && _selectedLocationIndex >= 0)
              ? _currentLocations[_selectedLocationIndex]
              : null;
      final selectedStation =
          !_isRoomNeeded &&
                  _selectedSubwayLine > 0 &&
                  _currentStations.isNotEmpty
              ? _currentStations[_selectedStationIndex]
              : null;
      final selectedStationIds =
          _isRoomNeeded ? (_selectedStationIds.toList()..sort()) : <int>[];
      final selectedLocationIds =
          _isRoomNeeded ? (_selectedLocationIds.toList()..sort()) : <int>[];
      final primaryLocationId =
          _isRoomNeeded
              ? (selectedLocationIds.isNotEmpty
                  ? selectedLocationIds.first
                  : null)
              : selectedLocation?.id;
      final primaryStationId =
          _isRoomNeeded
              ? (selectedStationIds.isNotEmpty
                  ? selectedStationIds.first
                  : null)
              : selectedStation?.id;

      // Determine listing type ID based on selection
      final listingTypeId = _selectedListingTypeId;

      // Update listing using the service
      final listingService = getIt<IListingService>();

      // First, update the listing details (without photos)
      logger.d("=== UPDATE LISTING CLIENT PAYLOAD ===");
      logger.d("  listingId: ${widget.listingDetail.id}");
      logger.d("  listingTypeId: $listingTypeId");
      logger.d("  subwayStationId: ${primaryStationId ?? "null"}");
      logger.d("  subwayStationIds: $selectedStationIds");
      logger.d("  subwayLineId: ${_isRoomNeeded ? "null (multi-select)" : (_selectedSubwayLine > 0 ? _selectedSubwayLine : "null")}");
      logger.d("  locationId: ${primaryLocationId ?? "null"}");
      logger.d("  locationIds: $selectedLocationIds");
      logger.d("=====================================");
      final effectiveLocationIds =
          selectedLocationIds.isNotEmpty
              ? selectedLocationIds
              : (primaryLocationId != null ? [primaryLocationId] : <int>[]);
      final effectiveStationIds =
          selectedStationIds.isNotEmpty
              ? selectedStationIds
              : (primaryStationId != null ? [primaryStationId] : <int>[]);
      await listingService.updateListing(
        listingId: widget.listingDetail.id,
        title: _titleController.text.trim(),
        listingTypeId: listingTypeId,
        minPrice: _minPrice.round(),
        maxPrice: _maxPrice.round(),
        description: _descriptionController.text.trim(),
        gender: _selectedGender,
        locationId: primaryLocationId,
        amenityIds: _selectedAmenityIds.toList(),
        subwayStationId: primaryStationId, // Made optional, moved to end
        subwayLineId:
            _isRoomNeeded
                ? null
                : (_selectedSubwayLine > 0 ? _selectedSubwayLine : null), // Add subway line ID
        subwayStationIds:
            effectiveStationIds.isNotEmpty ? effectiveStationIds : null,
        locationIds: effectiveLocationIds.isNotEmpty ? effectiveLocationIds : null,
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
          final List<bool> isPrimaryFlags = List.generate(
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
            message: LanguageAwareStringHelper.getCurrent(
              context,
              "error_uploading_photos",
            ),
          );
          // Don"t fail the entire listing update if photos fail
        }
      } else {
        logger.d("No new photos to upload");
      }

      // Show success message
      ToastTheme.showSuccess(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "listing_updated_success",
        ),
      );

      // Clear all error states on success
      setState(() {
        _showTitleError = false;
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
      String errorMessage = LanguageAwareStringHelper.getCurrent(
        context,
        "error_updating_listing",
      );

      // Check if it"s an authentication error
      if (e.toString().contains("401")) {
        errorMessage = LanguageAwareStringHelper.getCurrent(
          context,
          "authentication_required",
        );
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

  Widget _buildAmenityToggle(Amenity amenity) {
    final isSelected = _selectedAmenityIds.contains(amenity.id);
    // Initialize animation controller for this amenity
    _getAmenityAnimationController(amenity.id);
    final scaleAnimation = _amenityScaleAnimations[amenity.id]!;

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: InkWell(
            onTap: () {
              // Dismiss keyboard
              _dismissKeyboard();

              // Add haptic feedback
              HapticFeedbackUtils.impact();

              // Trigger animation
              _animateAmenityTap(amenity.id);

              setState(() {
                if (isSelected) {
                  _selectedAmenityIds.remove(amenity.id);
                } else {
                  _selectedAmenityIds.add(amenity.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAmenityIcon(amenity),
                    size: 18,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getAmenityLocalizedName(amenity),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Amenity> _getOrderedAmenities() {
    return AmenitiesCache.getDefaultOrderedAmenities();
  }

  IconData _getAmenityIcon(Amenity amenity) {
    if (amenity.code != null && amenity.code!.isNotEmpty) {
      return AmenityIconHelper.getIcon(amenity.code!);
    }
    return Icons.home; // Default icon
  }

  String _getAmenityLocalizedName(Amenity amenity) {
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );

    switch (currentLanguage) {
      case "ru":
        return amenity.nameRu;
      case "uz":
        return amenity.nameUz;
      case "en":
      default:
        return amenity.nameEn;
    }
  }

  void _deleteExistingPhoto(int index) async {
    final photo = _existingPhotos[index];

    // Prevent deletion if this is the last photo and photos are required
    if (_existingPhotos.length <= 1) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "cannot_delete_last_photo",
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldDelete = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "delete_photo",
      messageKey: "delete_photo_confirmation",
    );

    if (shouldDelete == true) {
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
            for (int i = 0; i < _existingPhotos.length; i++) {
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
                message: LanguageAwareStringHelper.getCurrent(
                  context,
                  "new_primary_photo_selected",
                ),
              );
            });
          } else if (wasPrimaryPhoto && remainingPhotosCount == 0) {
            // If we deleted the last photo (which was primary), show a different message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ToastTheme.showSuccess(
                context,
                message: LanguageAwareStringHelper.getCurrent(
                  context,
                  "last_photo_deleted",
                ),
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
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "photo_deleted_success",
          ),
        );
      } catch (e) {
        // Hide loading state
        setState(() {
          _deletingPhotoIds.remove(photo.id);
        });

        // Show error message
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_deleting_photo",
          ),
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

  void _makePhotoPrimary(int index) async {
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
        for (int i = 0; i < _existingPhotos.length; i++) {
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
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "photo_made_primary",
        ),
      );
    } catch (e) {
      // Remove from loading state on error
      setState(() {
        _makingPhotoPrimaryIds.remove(photo.id);
      });

      // Show error message
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(context, "error_generic"),
      );
    }
  }

  void _makeNewPhotoPrimary(int index) {
    // This method is called when a new photo is made primary
    // We need to clear primary status from existing photos
    setState(() {
      // Clear primary status from all existing photos
      for (int i = 0; i < _existingPhotos.length; i++) {
        _existingPhotos[i] = _existingPhotos[i].copyWith(isPrimary: false);
      }
    });
  }
}
