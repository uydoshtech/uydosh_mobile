import "dart:math" as math;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";
import "package:uy_dosh/presentation/widgets/common/description_counter_toolbar.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_form_scroll_body.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_amenities_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/photo_item.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

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
  /// Roommate listing (type 2): single rent amount.
  double _roommatePrice = 0.0;

  /// Room-needed listing (type 1): budget range (API still stores one `price`).
  double _roomBudgetMin = 0.0;
  double _roomBudgetMax = 0.0;

  /// Whether the user has interacted with the price slider at least once.
  bool _priceTouched = false;

  static const double _priceSliderMin = 0.0;
  static const double _priceSliderMax = 1000.0;

  bool get _pricePickerSingleHandle => _selectedListingTypeId == 2;
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
  bool _showPriceError = false;

  static const int _descriptionBaseLines = 4;
  static const int _descriptionExpandedExtraLines = 3;
  bool _isDescriptionExpanded = false;

  /// The most recent auto-generated default title. Used to decide whether the
  /// user has manually edited the title — if `_titleController.text` matches
  /// this value (or is empty), we re-stamp on type/gender changes; otherwise
  /// we preserve the user's edit.
  String _lastGeneratedTitle = "";

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
      final listingTypeIndex =
          listingTypeOptions.indexOf(_selectedListingTypeId);
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
    if (profile?.gender != null &&
        (profile!.gender == 1 || profile.gender == 2)) {
      return profile.gender;
    }
    try {
      profile = await getIt<IUserProfileService>().getCurrentUserProfile();
      if (profile.gender != null &&
          (profile.gender == 1 || profile.gender == 2)) {
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
      _currentLocations = List.from(locations)
        ..sort((a, b) {
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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// When switching to "room needed", seed a sensible range from the scalar rent.
  void _deriveBudgetRangeFromRoommatePrice() {
    final s = _roommatePrice.clamp(_priceSliderMin, _priceSliderMax);
    final hi = math.min(_priceSliderMax, math.max(s + 40, s + 10));
    final lo = math.max(_priceSliderMin, s - 40);
    _roomBudgetMin = lo >= hi ? math.max(_priceSliderMin, hi - 50) : lo;
    _roomBudgetMax = hi;
  }

  /// When switching to "roommate needed", collapse range to a single value.
  void _deriveRoommatePriceFromBudget() {
    final mid = (_roomBudgetMin + _roomBudgetMax) / 2;
    _roommatePrice =
        ((mid / 10).round() * 10.0).clamp(_priceSliderMin, _priceSliderMax);
  }

  int _priceForCreateRequest() {
    if (_selectedListingTypeId == 2) {
      return _roommatePrice.round();
    }
    // Backend listing row has a single `price`; use midpoint of budget range.
    return ((_roomBudgetMin + _roomBudgetMax) / 2).round();
  }

  /// Generate title based on listing type and gender
  String _generateTitle() {
    return L10n.get(
      ListingUtils.presetListingTitleL10nKey(
        listingTypeId: _selectedListingTypeId,
        gender: _selectedGender,
      ),
    );
  }

  static const int _titleMaxLength = 50;
  static const int _titleCounterVisibleAt = 40;

  /// Counter for the Title field: hidden until the user is close to the cap,
  /// then shown as a small subtle "currentLength/maxLength" badge.
  Widget? _buildTitleCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    int? maxLength,
  }) {
    if (currentLength < _titleCounterVisibleAt) return null;
    final cap = maxLength ?? _titleMaxLength;
    final isAtLimit = currentLength >= cap;
    final theme = Theme.of(context);
    final color = isAtLimit
        ? theme.colorScheme.error
        : (ThemeState().isLightTheme
            ? Colors.grey[700]
            : theme.colorScheme.onSurfaceVariant.withOpacity(0.8));
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Text(
        "$currentLength/$cap",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Update title field with the auto-generated default.
  ///
  /// Preserves the user's edits: only overwrites when the field is empty or
  /// still equals the previously-stamped default.
  void _updateTitle() {
    final generatedTitle = _generateTitle();
    final current = _titleController.text;
    final shouldOverwrite =
        current.isEmpty || current == _lastGeneratedTitle;
    if (shouldOverwrite) {
      _titleController.text = generatedTitle;
    }
    _lastGeneratedTitle = generatedTitle;
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
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final theme = Theme.of(context);
        final liquidGlassEnabled =
            themeState.isBlueTheme || themeState.isLightTheme;
        final useLiquidGlassAppBar = widget.showAppBar && liquidGlassEnabled;
        final embeddedInGlassShell = !widget.showAppBar && liquidGlassEnabled;
        final appBarTheme = theme.appBarTheme;
        final scrollTopPad = embeddedInGlassShell
            ? 16.0 + themeState.mainShellGlassExtraTopInset(context)
            : 16.0;

        return Scaffold(
          extendBodyBehindAppBar: useLiquidGlassAppBar,
          appBar: widget.showAppBar
              ? UydoshAppBar(
                  leading: ThreeDAppBarIconButton.backLeading(context),
                  title: L10n.text(
                    "create_listing_title",
                    style: appBarTheme.titleTextStyle?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  backgroundColor: useLiquidGlassAppBar
                      ? liquidGlassAppBarMaterialColor(context)
                      : appBarTheme.backgroundColor,
                  surfaceTintColor: useLiquidGlassAppBar
                      ? Colors.transparent
                      : appBarTheme.surfaceTintColor,
                  elevation: useLiquidGlassAppBar ? 0 : null,
                  scrolledUnderElevation: useLiquidGlassAppBar ? 0 : null,
                  shadowColor: useLiquidGlassAppBar
                      ? Colors.transparent
                      : appBarTheme.shadowColor,
                  forceMaterialTransparency: useLiquidGlassAppBar,
                  flexibleSpace: useLiquidGlassAppBar
                      ? const LiquidGlassAppBarFlexibleSpace()
                      : null,
                  foregroundColor: appBarTheme.foregroundColor,
                )
              : null,
          body: BlocListener<SubwayStationsBloc, SubwayStationsState>(
            listener: (context, state) {
              state.map(
                initial: (_) => setState(() => _isLoadingStations = false),
                loading: (_) => setState(() => _isLoadingStations = true),
                loaded: (loadedState) =>
                    _onStationsLoaded(loadedState.stations),
                error: (_) => setState(() => _isLoadingStations = false),
              );
            },
            child: BlocListener<LocationsBloc, LocationsState>(
              listener: (context, state) {
                state.map(
                  initial: (_) => setState(() => _isLoadingLocations = false),
                  loading: (_) => setState(() => _isLoadingLocations = true),
                  loaded: (loadedState) =>
                      _onLocationsLoaded(loadedState.locations),
                  error: (_) => setState(() => _isLoadingLocations = false),
                );
              },
              child: SafeArea(
                top: !embeddedInGlassShell,
                child: UydoshFormScrollBody(
                  topPadding: scrollTopPad,
                  children: [
                    ListenableBuilder(
                      listenable: AuthenticationState(),
                      builder: (context, child) {
                        final isAuthenticated =
                            AuthenticationState().isAuthenticated;

                        if (isAuthenticated) {
                          return _buildAuthenticatedForm();
                        } else {
                          return _buildUnauthenticatedPrompt();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthenticatedForm() {
    return Column(
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
                      final prevType = _selectedListingTypeId;
                      _selectedListingTypeId = listingTypeId;
                      // Clear photos when switching to "room needed" (listingTypeId == 1)
                      if (listingTypeId == 1) {
                        _selectedPhotos.clear();
                        _primaryPhotoIndex = null;
                      }
                      if (_priceTouched) {
                        if (prevType == 2 && listingTypeId == 1) {
                          _deriveBudgetRangeFromRoommatePrice();
                        } else if (prevType == 1 && listingTypeId == 2) {
                          _deriveRoommatePriceFromBudget();
                        }
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
          isLoadingStations: _isLoadingStations,
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
        PriceRangePicker(
          key: ValueKey<int>(_selectedListingTypeId),
          minPrice: _priceSliderMin,
          maxPrice: _priceSliderMax,
          initialMinPrice:
              _pricePickerSingleHandle ? _roommatePrice : _roomBudgetMin,
          initialMaxPrice:
              _pricePickerSingleHandle ? _roommatePrice : _roomBudgetMax,
          useSinglePrice: _pricePickerSingleHandle,
          showErrorBorder: _showPriceError,
          onPriceRangeChanged: (minPrice, maxPrice) {
            _dismissKeyboard();
            setState(() {
              if (_pricePickerSingleHandle) {
                _roommatePrice = minPrice;
              } else {
                _roomBudgetMin = minPrice;
                _roomBudgetMax = maxPrice;
              }
              _priceTouched = true;
              _showPriceError = false;
            });
          },
        ),
        const SizedBox(height: 10), // Space between price range and title

        // Title Field — pre-filled with auto-generated #TitleName, editable.
        L10n.inputField(
          "listing_title_hint",
          builder: (hintText) => WheelPickerPlateContainer(
            theme: Theme.of(context),
              child: TextFormField(
                controller: _titleController,
                maxLength: _titleMaxLength,
                maxLines: 1,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                        : Colors.grey[400],
                  ),
                border: OutlineInputBorder(
                  borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeState().isLightTheme
                      ? Colors.black
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                buildCounter: _buildTitleCounter,
            ),
          ),
        ),
        const SizedBox(height: 10), // Space between title and description

        // Description Field
        L10n.inputField(
          "listing_description_hint",
          builder: (hintText) => WheelPickerPlateContainer(
            showErrorBorder: _showDescriptionError,
            theme: Theme.of(context),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              reverseDuration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                        : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeState().isLightTheme
                      ? Colors.black
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                minLines: _descriptionBaseLines +
                    (_isDescriptionExpanded
                        ? _descriptionExpandedExtraLines
                        : 0),
                maxLines: _descriptionBaseLines +
                    (_isDescriptionExpanded
                        ? _descriptionExpandedExtraLines
                        : 0),
                maxLength: 1000,
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) {
                  return DescriptionCounterToolbar(
                    controller: _descriptionController,
                    listingTypeId: _selectedListingTypeId,
                    gender: _selectedGender,
                    currentLength: currentLength,
                    maxLength: maxLength ?? 0,
                    isExpanded: _isDescriptionExpanded,
                    onToggleExpanded: () => setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    }),
                    layout: DescriptionCounterToolbarLayout.stack,
                    counterVisibleAtFraction: 0.7,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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

        // Move-in Date and Private Room Row ([IntrinsicHeight] — stretch in scroll).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Move-in Date Field (50% width)
              Expanded(
                child: L10n.inputField(
                  "quick_question_move_in_date",
                  builder: (hintText) => Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
                      context,
                      theme: Theme.of(context),
                    ),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _moveInDateController,
                      builder: (context, value, child) {
                        final isEmpty = value.text.isEmpty;
                        final moveInDateLabel = L10n.get("move_in_date_label");
                        final anyDateText =
                            L10n.get("any_date").replaceAll("\n", " ");
                        final displayValue = isEmpty ? anyDateText : value.text;
                        final displayText = "$moveInDateLabel\n$displayValue";
                        final displayStyle = TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ThemeState().isLightTheme
                              ? Colors.black
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        );
                        final hintStyle = TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeState().isLightTheme
                              ? Colors.black
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        );
                        return GestureDetector(
                          onTap: () async {
                            HapticFeedbackUtils.impact();
                            final firstDate = DateTime.now();
                            final lastDate = DateTime.now().add(
                              const Duration(days: 365),
                            );
                            final existingDate = _moveInDateValue.isNotEmpty
                                ? DateTime.tryParse(_moveInDateValue)
                                : null;
                            final initialDate = existingDate != null &&
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
                              helpText: L10n.get("select_date"),
                              cancelText: L10n.get("cancel"),
                              confirmText: L10n.get("ok"),
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
                                borderRadius:
                                    ThreeDSurfaceStyle.wheelPickerPlateRadius,
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    ThreeDSurfaceStyle.wheelPickerPlateRadius,
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    ThreeDSurfaceStyle.wheelPickerPlateRadius,
                                borderSide: BorderSide(
                                  color: _getBorderColor(),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              prefixIcon: ThemeIcon(
                                CupertinoIcons.calendar,
                                size: 22,
                                color: Theme.of(context).brightness ==
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
                  clipBehavior: Clip.antiAlias,
                  decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
                    context,
                    theme: Theme.of(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ThemeIcon(
                          Icons.lock_outline,
                          color: _isPrivateRoom
                              ? _getBorderColor()
                              : (Theme.of(context).brightness == Brightness.dark
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                L10n.get("private_room")
                                    .replaceFirst(" ", "\n"),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeState().isLightTheme
                                      ? Colors.black
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NeumorphicToggle(
                          value: _isPrivateRoom,
                          activeAccentColor: _getBorderColor(),
                          activeTrackColor: _getBorderColor().withValues(
                            alpha: 0.3,
                          ),
                          inactiveThumbColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.7)
                                  : Colors.grey.shade600,
                          inactiveTrackColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.3)
                                  : Colors.grey.shade300,
                          onChanged: (value) {
                            HapticFeedbackUtils.impact();
                            setState(() {
                              _isPrivateRoom = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            // Drive the grid off `_selectedPhotos` directly (as NewPhotoItem).
            // On reorder we mutate the same list so the submit flow uploads
            // photos in the user's chosen order (index 0 -> primary) without
            // any extra bookkeeping.
            orderedItems: [
              for (final path in _selectedPhotos) NewPhotoItem(path),
            ],
            onReorderItems: (newOrder) {
              setState(() {
                _selectedPhotos = [
                  for (final item in newOrder)
                    if (item is NewPhotoItem) item.path,
                ];
                _primaryPhotoIndex =
                    _selectedPhotos.isEmpty ? null : 0;
              });
            },
            maxPhotos: 5,
            isRequired: false,
          ),

        const SizedBox(height: 29),

        Builder(
          builder: (context) {
            final label = Theme.of(context).textTheme.labelLarge;
            final baseSize = label?.fontSize ?? 14;
            final textStyle =
                label?.copyWith(fontSize: baseSize * 1.2, height: 1.0) ??
                    TextStyle(
                      fontSize: baseSize * 1.2,
                      height: 1.0,
                      fontWeight: FontWeight.w500,
                    );
            return PrimaryButtonFactory.iconText(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting ? Icons.hourglass_empty : Icons.add,
              text: L10n.get(
                _isSubmitting ? "creating_listing" : "create_listing_button",
              ),
              width: double.infinity,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: textStyle,
              isLoading: _isSubmitting,
            );
          },
        ),
        const SizedBox(height: 29),
      ],
    );
  }

  Widget _buildUnauthenticatedPrompt() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
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

    if (title.length > _titleMaxLength) {
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

    // Validate price: user must actively pick a value.
    if (!_priceTouched) {
      ToastTheme.showError(
        context,
        message: L10n.get("price_required"),
      );
      setState(() {
        _showPriceError = true;
      });
      return;
    } else {
      setState(() {
        _showPriceError = false;
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
      logger.d(
        "  price: ${_priceForCreateRequest()} "
        "(${_pricePickerSingleHandle ? "scalar $_roommatePrice" : "range $_roomBudgetMin-$_roomBudgetMax"})",
      );
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
        price: _priceForCreateRequest(),
        description: _descriptionController.text.trim(),
        gender: _selectedGender,
        locationId: selectedLocation.id,
        amenityIds: _selectedAmenityIds.toList(),
        subwayStationId: selectedStation?.id, // Now optional, moved to end
        subwayLineId: _selectedSubwayLine > 0
            ? _selectedSubwayLine
            : null, // Add subway line ID
        moveInDate: _moveInDateValue.isNotEmpty
            ? _moveInDateValue
            : null, // Only send date if selected
        privateRoom: _isPrivateRoom, // Add private room preference
        photoPaths: orderedPhotos.isNotEmpty
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

      if (isIOSDevice &&
          mounted &&
          listingTypeId != 1 &&
          !ClientLidarRoomScanConfig.lidarRoomScanDisabled.value) {
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
        _roommatePrice = 0.0;
        _roomBudgetMin = 0.0;
        _roomBudgetMax = 0.0;
        _priceTouched = false;
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
        _showPriceError = false;
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
