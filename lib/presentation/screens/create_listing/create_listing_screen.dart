import "dart:async";
import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:geolocator/geolocator.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/room_plan_capability.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/services/yandex_geosuggest_service.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/create_listing/post_create_listing_search_alerts.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_search_alerts.dart";
import "package:uy_dosh/presentation/screens/permissions/notification_permission_gate.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";
import "package:uy_dosh/presentation/widgets/common/applied_search_filters_bar.dart";
import "package:uy_dosh/presentation/widgets/common/description_counter_toolbar.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/group_size_target_picker.dart";
import "package:uy_dosh/presentation/widgets/common/labeled_field_overlay.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_form_scroll_body.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_amenities_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/multi_location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/multi_station_picker.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/photo_item.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/publish_consent_gate.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_plate_text_form_field.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/unsaved_changes_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_address_suggest_field.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({
    super.key,
    this.showAppBar = false,
    this.initialListingTypeId,
  });

  final bool showAppBar;
  final int? initialListingTypeId;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

enum _LocationSearchMode { metro, district }

class _CreateListingScreenState extends State<CreateListingScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _moveInDateController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();
  String _moveInDateValue = "";
  String? _identifiedAddressText;
  double? _addressLatitude;
  double? _addressLongitude;

  // Wizard navigation
  final PageController _pageController = PageController();
  static const int _stepCount = 4;
  int _currentStep = 0;
  FixedExtentScrollController? _locationScrollController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _metroStationScrollController;

  // State variables
  int _selectedListingTypeId = 2; // 2 = roommate needed, 1 = room needed
  int _defaultListingTypeFromProfile = 2; // Profile-based default for reset
  int _selectedGender = 1;
  int _defaultGenderFromProfile = 1; // Profile-based default for reset
  /// Roommate listing (type 2): single rent amount.
  double _roommatePrice = 10.0;

  /// Room-needed and group-forming listings: budget range (API stores midpoint).
  double _roomBudgetMin = 10.0;
  double _roomBudgetMax = 50.0;

  /// Whether the user has interacted with the price slider at least once.
  bool _priceTouched = false;

  static const double _priceSliderMin = 10.0;
  static const double _priceSliderMax = 1000.0;
  static const double _priceSliderInitialVisibleMax = 500.0;
  static const double _priceSliderExpansionStep = 100.0;

  int? get _initialListingTypeId {
    final id = widget.initialListingTypeId;
    return id == 1 || id == 2 || id == ListingTypeIds.groupForming ? id : null;
  }

  bool get _isGroupFormingFlow =>
      _selectedListingTypeId == ListingTypeIds.groupForming;

  bool get _isRoommateNeededFlow =>
      _selectedListingTypeId == ListingTypeIds.roommateNeeded;

  /// Listings can be close to several metro stations. Element 0 is persisted
  /// as the primary station for older API consumers.
  bool get _supportsMultiStation =>
      _selectedListingTypeId == ListingTypeIds.roomNeeded ||
      _isRoommateNeededFlow ||
      _isGroupFormingFlow;

  /// Demand-side flows can search across several districts. Supply-side
  /// roommate listings describe one apartment, so district mode stays singular.
  bool get _supportsMultiLocation =>
      _selectedListingTypeId == ListingTypeIds.roomNeeded ||
      _isGroupFormingFlow;

  int _groupSizeTarget = 3;

  bool get _pricePickerSingleHandle => _isRoommateNeededFlow;
  bool _isPrivateRoom = false; // Add private room toggle
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  _LocationSearchMode _locationSearchMode = _LocationSearchMode.metro;
  bool _isSubmitting = false;
  bool _isResolvingCurrentLocation = false;
  bool _isLoadingLocations = false;
  bool _isLoadingStations = false;

  // Validation state variables
  bool _showDescriptionError = false;
  bool _showLocationError = false;
  bool _showPriceError = false;

  static const int _descriptionBaseLines = 4;
  static const int _descriptionExpandedExtraLines = 3;
  bool _isDescriptionExpanded = true;

  /// The most recent auto-generated default title. Used to decide whether the
  /// user has manually edited the title — if `_titleController.text` matches
  /// this value (or is empty), we re-stamp on listing-type changes; otherwise
  /// we preserve the user's edit.
  String _lastGeneratedTitle = "";

  // Lists
  List<Location> _currentLocations = [];
  List<SubwayStation> _currentStations = [];

  /// Multi-station selection shown as chips for demand-side flows
  /// (room-needed / group-forming). Order matters: element 0 is the primary
  /// station persisted on the listing row.
  final List<SubwayStation> _selectedSearchStations = [];
  List<int> _baselineSearchStationIds = [];

  /// Multi-location selection shown as chips for demand-side flows when the
  /// author chooses "By district" instead of "By metro". Order matters:
  /// element 0 is the primary location persisted on the listing row.
  final List<Location> _selectedSearchLocations = [];
  List<int> _baselineSearchLocationIds = [];

  /// Caches every station object seen across lines so the multi-select control
  /// (which reports ids) can be mapped back to full [SubwayStation]s, including
  /// ones selected on a line the user has since scrolled away from.
  final Map<int, SubwayStation> _stationCache = {};

  final Set<int> _selectedAmenityIds = {};
  List<String> _selectedPhotos = [];
  int? _primaryPhotoIndex; // Track which photo is primary

  /// When true, [Navigator.pop] after a successful create is allowed despite a
  /// dirty form (same pattern as [EditListingScreen]).
  bool _allowPopWithoutConfirm = false;

  bool _baselineCaptured = false;
  String _baselineTitle = "";
  String _baselineDescription = "";
  String _baselineAddressText = "";
  int _baselineListingTypeId = 2;
  double _baselineRoommatePrice = 10.0;
  double _baselineRoomBudgetMin = 10.0;
  double _baselineRoomBudgetMax = 50.0;
  bool _baselinePriceTouched = false;
  bool _baselinePrivateRoom = false;
  String _baselineMoveInDateValue = "";
  int _baselineSelectedSubwayLine = 0;
  int _baselineSelectedStationIndex = 0;
  int _baselineSelectedLocationIndex = -1;
  _LocationSearchMode _baselineLocationSearchMode = _LocationSearchMode.metro;
  Set<int> _baselineAmenityIds = {};
  List<String> _baselineSelectedPhotos = [];

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "create_listing");
    _titleController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
    _moveInDateController.addListener(_markDirty);
    _addressTextController.addListener(_onAddressTextChanged);
    final initialListingTypeId = _initialListingTypeId;
    if (initialListingTypeId != null) {
      _selectedListingTypeId = initialListingTypeId;
      _defaultListingTypeFromProfile = initialListingTypeId;
    }
    _locationScrollController = FixedExtentScrollController(initialItem: 0);
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
    final tenantLikeRole = role == "tenant" || role == "service_requester";
    final defaultType = tenantLikeRole ? 1 : 2;
    final defaultGender = (gender == 1 || gender == 2) ? gender! : 1;
    setState(() {
      final initialListingTypeId = _initialListingTypeId;
      _defaultListingTypeFromProfile = initialListingTypeId ?? defaultType;
      _selectedListingTypeId = initialListingTypeId ?? defaultType;
      _defaultGenderFromProfile = defaultGender;
      _selectedGender = defaultGender;
    });
    _updateTitle();
    _captureBaseline();
  }

  void _markDirty() {
    if (mounted) setState(() {});
  }

  void _onAddressTextChanged() {
    if (_identifiedAddressText != null &&
        _normListingText(_addressTextController.text) !=
            _normListingText(_identifiedAddressText)) {
      _identifiedAddressText = null;
      _addressLatitude = null;
      _addressLongitude = null;
    }
    _markDirty();
  }

  void _captureBaseline() {
    _baselineTitle = _titleController.text;
    _baselineDescription = _descriptionController.text;
    _baselineAddressText = _addressTextController.text;
    _baselineListingTypeId = _selectedListingTypeId;
    _baselineRoommatePrice = _roommatePrice;
    _baselineRoomBudgetMin = _roomBudgetMin;
    _baselineRoomBudgetMax = _roomBudgetMax;
    _baselinePriceTouched = _priceTouched;
    _baselinePrivateRoom = _isPrivateRoom;
    _baselineMoveInDateValue = _moveInDateValue;
    _baselineSelectedSubwayLine = _selectedSubwayLine;
    _baselineSelectedStationIndex = _selectedStationIndex;
    _baselineSelectedLocationIndex = _selectedLocationIndex;
    _baselineLocationSearchMode = _locationSearchMode;
    _baselineSearchStationIds =
        _selectedSearchStations.map((s) => s.id).toList();
    _baselineSearchLocationIds =
        _selectedSearchLocations.map((l) => l.id).toList();
    _baselineAmenityIds = Set<int>.from(_selectedAmenityIds);
    _baselineSelectedPhotos = List<String>.from(_selectedPhotos);
    _baselineCaptured = true;
  }

  String _normListingText(String? s) => (s ?? "").trim();

  int? _currentLocationId() {
    if (_selectedLocationIndex < 0 ||
        _selectedLocationIndex >= _currentLocations.length) {
      return null;
    }
    return _currentLocations[_selectedLocationIndex].id;
  }

  int? _currentSubwayStationId() {
    if (_selectedSubwayLine <= 0 || _currentStations.isEmpty) return null;
    if (_selectedStationIndex < 0 ||
        _selectedStationIndex >= _currentStations.length) {
      return null;
    }
    return _currentStations[_selectedStationIndex].id;
  }

  /// Receives the full set of selected station ids from [MultiStationPicker]
  /// and rebuilds the [SubwayStation] objects (id order preserved; element 0 is
  /// the primary station persisted on the listing).
  void _onSearchStationsSelected(List<int> ids) {
    setState(() {
      _selectedSearchLocations.clear();
      final incomingIds = ids.toSet();
      final addedIds = <int>{};
      final next = <SubwayStation>[];
      for (final station in _selectedSearchStations) {
        if (incomingIds.contains(station.id) && addedIds.add(station.id)) {
          next.add(station);
        }
      }
      for (final id in ids) {
        if (!addedIds.add(id)) continue;
        final station = _stationCache[id] ??
            _selectedSearchStations
                .where((s) => s.id == id)
                .cast<SubwayStation?>()
                .firstWhere((s) => s != null, orElse: () => null);
        if (station != null) next.add(station);
      }
      _selectedSearchStations
        ..clear()
        ..addAll(next);
      if (_showLocationError && next.isNotEmpty) {
        _showLocationError = false;
      }
    });
  }

  void _removeSearchStation(int stationId) {
    HapticFeedbackUtils.impact();
    setState(() {
      _selectedSearchStations.removeWhere((s) => s.id == stationId);
    });
  }

  void _onSearchLocationsSelected(List<int> ids) {
    setState(() {
      _selectedSearchStations.clear();
      _selectedSubwayLine = 0;
      _currentStations = [];
      _selectedStationIndex = 0;

      final next = <Location>[];
      for (final id in ids) {
        final location = _currentLocations
            .where((l) => l.id == id)
            .cast<Location?>()
            .firstWhere((l) => l != null, orElse: () => null);
        if (location != null) next.add(location);
      }
      _selectedSearchLocations
        ..clear()
        ..addAll(next);
      _selectedLocationIndex = next.isEmpty
          ? -1
          : _currentLocations.indexWhere((l) => l.id == next.first.id);
      if (_showLocationError && next.isNotEmpty) {
        _showLocationError = false;
      }
    });
  }

  void _removeSearchLocation(int locationId) {
    HapticFeedbackUtils.impact();
    setState(() {
      _selectedSearchLocations.removeWhere((l) => l.id == locationId);
      _selectedLocationIndex = _selectedSearchLocations.isEmpty
          ? -1
          : _currentLocations.indexWhere(
              (l) => l.id == _selectedSearchLocations.first.id,
            );
    });
  }

  bool _searchStationsMatchBaseline() {
    final currentIds = _selectedSearchStations.map((s) => s.id).toList();
    if (currentIds.length != _baselineSearchStationIds.length) return false;
    for (var i = 0; i < currentIds.length; i++) {
      if (currentIds[i] != _baselineSearchStationIds[i]) return false;
    }
    return true;
  }

  bool _searchLocationsMatchBaseline() {
    final currentIds = _selectedSearchLocations.map((l) => l.id).toList();
    if (currentIds.length != _baselineSearchLocationIds.length) return false;
    for (var i = 0; i < currentIds.length; i++) {
      if (currentIds[i] != _baselineSearchLocationIds[i]) return false;
    }
    return true;
  }

  int? _baselineLocationId() {
    if (_baselineSelectedLocationIndex < 0 ||
        _baselineSelectedLocationIndex >= _currentLocations.length) {
      return null;
    }
    return _currentLocations[_baselineSelectedLocationIndex].id;
  }

  int? _baselineSubwayStationId() {
    if (_baselineSelectedSubwayLine <= 0 || _currentStations.isEmpty) {
      return null;
    }
    if (_baselineSelectedStationIndex < 0 ||
        _baselineSelectedStationIndex >= _currentStations.length) {
      return null;
    }
    return _currentStations[_baselineSelectedStationIndex].id;
  }

  bool _amenityIdsMatchBaseline() {
    if (_baselineAmenityIds.length != _selectedAmenityIds.length) return false;
    for (final id in _baselineAmenityIds) {
      if (!_selectedAmenityIds.contains(id)) return false;
    }
    return true;
  }

  bool _photosMatchBaseline() {
    if (_baselineSelectedPhotos.length != _selectedPhotos.length) return false;
    for (var i = 0; i < _baselineSelectedPhotos.length; i++) {
      if (_baselineSelectedPhotos[i] != _selectedPhotos[i]) return false;
    }
    return true;
  }

  bool _isPriceDirty() {
    if (_priceTouched != _baselinePriceTouched) return true;
    if (!_priceTouched) return false;
    if (_selectedListingTypeId == 2) {
      return _roommatePrice != _baselineRoommatePrice;
    }
    return _roomBudgetMin != _baselineRoomBudgetMin ||
        _roomBudgetMax != _baselineRoomBudgetMax;
  }

  List<String> _computeChangedFieldLabels() {
    final changed = <String>[];

    void addLabel(String key, {required String fallback}) {
      var label = L10n.get(key, fallback: fallback).trim();
      label = label.replaceAll(RegExp(r":\s*$"), "").trim();
      changed.add(label.isEmpty ? fallback : label);
    }

    if (_normListingText(_titleController.text) !=
        _normListingText(_baselineTitle)) {
      addLabel("listing_title_label", fallback: "Title");
    }
    if (_normListingText(_descriptionController.text) !=
        _normListingText(_baselineDescription)) {
      addLabel("listing_description_label", fallback: "Description");
    }
    if (_normListingText(_addressTextController.text) !=
        _normListingText(_baselineAddressText)) {
      addLabel("listing_address_text_label", fallback: "Address");
    }
    if (_selectedListingTypeId != _baselineListingTypeId) {
      addLabel("listing_type_label", fallback: "Listing type");
    }
    if (_isPriceDirty()) {
      addLabel("listing_price_label", fallback: "Price");
    }
    if (_isPrivateRoom != _baselinePrivateRoom) {
      addLabel("private_room", fallback: "Private room");
    }
    if (_moveInDateValue != _baselineMoveInDateValue) {
      addLabel("move_in_date_label", fallback: "Move-in date");
    }
    if (!_supportsMultiLocation &&
        _locationSearchMode == _LocationSearchMode.district &&
        !_isLoadingLocations &&
        _currentLocationId() != _baselineLocationId()) {
      addLabel("location", fallback: "Location");
    }
    if (!_isLoadingStations &&
        (_locationSearchMode == _LocationSearchMode.metro ||
            _baselineLocationSearchMode == _LocationSearchMode.metro)) {
      final curLine = _selectedSubwayLine > 0 ? _selectedSubwayLine : null;
      final baseLine =
          _baselineSelectedSubwayLine > 0 ? _baselineSelectedSubwayLine : null;
      if (_currentSubwayStationId() != _baselineSubwayStationId() ||
          curLine != baseLine) {
        addLabel("select_metro_line_optional", fallback: "Metro");
      }
    }
    if (!_searchStationsMatchBaseline()) {
      addLabel("select_metro_line_optional", fallback: "Metro");
    }
    if (_locationSearchMode != _baselineLocationSearchMode ||
        !_searchLocationsMatchBaseline()) {
      addLabel("location", fallback: "Location");
    }
    if (!_amenityIdsMatchBaseline()) {
      addLabel("amenities", fallback: "Amenities");
    }
    if (!_photosMatchBaseline()) {
      addLabel("listing_photos_label", fallback: "Photos");
    }

    return changed;
  }

  bool _isFormDirty() {
    if (!_baselineCaptured) return false;

    if (_normListingText(_titleController.text) !=
        _normListingText(_baselineTitle)) {
      return true;
    }
    if (_normListingText(_descriptionController.text) !=
        _normListingText(_baselineDescription)) {
      return true;
    }
    if (_normListingText(_addressTextController.text) !=
        _normListingText(_baselineAddressText)) {
      return true;
    }
    if (_selectedListingTypeId != _baselineListingTypeId) return true;
    if (_isPriceDirty()) return true;
    if (_isPrivateRoom != _baselinePrivateRoom) return true;
    if (_moveInDateValue != _baselineMoveInDateValue) return true;

    if (!_supportsMultiLocation &&
        _locationSearchMode == _LocationSearchMode.district &&
        !_isLoadingLocations &&
        _currentLocationId() != _baselineLocationId()) {
      return true;
    }

    if (!_isLoadingStations &&
        (_locationSearchMode == _LocationSearchMode.metro ||
            _baselineLocationSearchMode == _LocationSearchMode.metro)) {
      final curLine = _selectedSubwayLine > 0 ? _selectedSubwayLine : null;
      final baseLine =
          _baselineSelectedSubwayLine > 0 ? _baselineSelectedSubwayLine : null;
      if (_currentSubwayStationId() != _baselineSubwayStationId() ||
          curLine != baseLine) {
        return true;
      }
    }

    if (!_searchStationsMatchBaseline()) return true;
    if (_locationSearchMode != _baselineLocationSearchMode) return true;
    if (!_searchLocationsMatchBaseline()) return true;
    if (!_amenityIdsMatchBaseline()) return true;
    if (!_photosMatchBaseline()) return true;

    return false;
  }

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    // While inside the wizard, a back gesture/button steps back instead of
    // leaving the screen.
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
      return;
    }
    final changedFields = _computeChangedFieldLabels();
    final leave = await UnsavedChangesDialog.show(
      context,
      changedFieldLabels: changedFields,
    );
    if (!mounted || !leave) return;
    Navigator.of(context).pop(result);
  }

  /// Top-right close action: leaves the wizard entirely (rather than stepping
  /// back), surfacing the same unsaved-changes confirmation when the form is
  /// dirty.
  Future<void> _closeWizard() async {
    HapticFeedbackUtils.impact();
    if (_isFormDirty()) {
      final changedFields = _computeChangedFieldLabels();
      final leave = await UnsavedChangesDialog.show(
        context,
        changedFieldLabels: changedFields,
      );
      if (!mounted || !leave) return;
    }
    if (!mounted) return;
    // Use pop() (not maybePop()) so this bypasses the PopScope step-back guard
    // and leaves the wizard entirely, regardless of the current step. The
    // unsaved-changes confirmation has already been handled above.
    setState(() => _allowPopWithoutConfirm = true);
    Navigator.of(context).pop();
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
      for (final station in stations) {
        _stationCache[station.id] = station;
      }
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

  Future<void> _useCurrentLocationForAddress() async {
    if (_isResolvingCurrentLocation) return;
    HapticFeedbackUtils.impact();
    _dismissKeyboard();

    setState(() => _isResolvingCurrentLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ToastTheme.showWarning(
          context,
          message: L10n.get("location_services_disabled"),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ToastTheme.showWarning(
          context,
          message: L10n.get("location_permission_denied"),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );

      final result = await getIt<YandexGeosuggestService>().reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
        lang: L10n.currentLanguage,
      );

      if (!mounted) return;
      if (result.hasAddress) {
        final address = result.addressText!.trim();
        setState(() {
          _identifiedAddressText = address;
          _addressLatitude = position.latitude;
          _addressLongitude = position.longitude;
        });
        _addressTextController.text = address;
        return;
      }

      ToastTheme.showError(
        context,
        message: L10n.get("current_location_address_failed"),
      );
    } on TimeoutException {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("current_location_address_failed"),
      );
    } catch (e, st) {
      logger.w("Failed to resolve current location address",
          error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("current_location_address_failed"),
      );
    } finally {
      if (mounted) {
        setState(() => _isResolvingCurrentLocation = false);
      }
    }
  }

  int _priceForCreateRequest() {
    if (_pricePickerSingleHandle) {
      return _roommatePrice.round();
    }
    // Backend listing row has a single `price`; use midpoint of budget range.
    return ((_roomBudgetMin + _roomBudgetMax) / 2).round();
  }

  ({int min, int max}) _priceBoundsForCreateRequest() {
    if (_pricePickerSingleHandle) {
      final p = _roommatePrice.round();
      return (min: p, max: p);
    }
    return (min: _roomBudgetMin.round(), max: _roomBudgetMax.round());
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
    final shouldOverwrite = current.isEmpty || current == _lastGeneratedTitle;
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

  Color _getCurrentLocationIconColor() {
    if (ThemeState().isLightTheme) {
      return Colors.black;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  // Theme-dependent color method for amenity selections
  void _makeNewPhotoPrimary(int index) {
    setState(() {
      _primaryPhotoIndex = index;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_markDirty);
    _descriptionController.removeListener(_markDirty);
    _moveInDateController.removeListener(_markDirty);
    _addressTextController.removeListener(_onAddressTextChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _moveInDateController.dispose();
    _addressTextController.dispose();
    _locationScrollController?.dispose();
    _metroLineScrollController?.dispose();
    _metroStationScrollController?.dispose();
    _pageController.dispose();
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
        // Keep the wizard header close to the app bar. The body is already
        // wrapped in a SafeArea, so adding a full toolbar height here creates
        // an oversized gap under the liquid-glass title.
        final scrollTopPad = embeddedInGlassShell
            ? 4.0 + themeState.mainShellGlassExtraTopInset(context)
            : useLiquidGlassAppBar
                ? 12.0
                : 16.0;

        return PopScope(
          canPop:
              _allowPopWithoutConfirm || (_currentStep == 0 && !_isFormDirty()),
          onPopInvokedWithResult: _onPopInvoked,
          child: Scaffold(
            extendBodyBehindAppBar: useLiquidGlassAppBar,
            appBar: widget.showAppBar
                ? UydoshAppBar(
                    leading: ThreeDAppBarIconButton.backLeading(
                      context,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: L10n.text(
                      _isGroupFormingFlow
                          ? "create_group_title"
                          : "create_listing_title",
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
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Center(
                          child: ThreeDAppBarIconButton(
                            iconData: Icons.close,
                            onPressed: _closeWizard,
                            semanticsLabel: L10n.get("close"),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(999)),
                          ),
                        ),
                      ),
                    ],
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
                  child: KeyboardDismissScope(
                    child: ListenableBuilder(
                      listenable: AuthenticationState(),
                      builder: (context, child) {
                        if (AuthenticationState().isAuthenticated) {
                          return _buildWizard(scrollTopPad);
                        }
                        return UydoshFormScrollBody(
                          topPadding: scrollTopPad,
                          children: [_buildUnauthenticatedPrompt()],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Wizard scaffold
  // ===========================================================================

  /// Localized title for the step at [index].
  String _stepTitle(int index) {
    switch (index) {
      case 0:
        return L10n.get("wizard_step_location");
      case 1:
        return L10n.get("wizard_step_details");
      case 2:
        return L10n.get("wizard_step_description");
      default:
        return L10n.get("wizard_step_review");
    }
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _stepCount) return;
    _dismissKeyboard();
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
    setState(() => _currentStep = index);
  }

  void _goToNextStep() {
    HapticFeedbackUtils.impact();
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < _stepCount - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  /// Per-step gate. Surfaces a toast + inline error for the first invalid
  /// field and returns false so navigation past the step is blocked.
  bool _validateStep(int index) {
    switch (index) {
      case 0: // Location
        if (_supportsMultiStation &&
            _locationSearchMode == _LocationSearchMode.metro &&
            _selectedSearchStations.isEmpty) {
          ToastTheme.showError(context, message: _locationRequiredMessage());
          setState(() => _showLocationError = true);
          return false;
        }
        if (_supportsMultiLocation &&
            _locationSearchMode == _LocationSearchMode.district &&
            _selectedSearchLocations.isEmpty) {
          ToastTheme.showError(context, message: _locationRequiredMessage());
          setState(() => _showLocationError = true);
          return false;
        }
        if (!_supportsMultiStation &&
            _locationSearchMode == _LocationSearchMode.metro &&
            _currentSubwayStationId() == null) {
          ToastTheme.showError(context, message: _locationRequiredMessage());
          setState(() => _showLocationError = true);
          return false;
        }
        if (!_supportsMultiLocation &&
            _locationSearchMode == _LocationSearchMode.district &&
            _selectedLocationIndex < 0) {
          ToastTheme.showError(context, message: _locationRequiredMessage());
          setState(() => _showLocationError = true);
          return false;
        }
        setState(() => _showLocationError = false);
        return true;
      case 1: // Details — price is the only required field
        if (!_priceTouched) {
          ToastTheme.showError(context, message: L10n.get("price_required"));
          setState(() => _showPriceError = true);
          return false;
        }
        if (_priceForCreateRequest() < 1) {
          ToastTheme.showError(
            context,
            message: L10n.get("listing_price_minimum"),
          );
          setState(() => _showPriceError = true);
          return false;
        }
        setState(() => _showPriceError = false);
        return true;
      case 2: // Description — title + description required
        final title = _titleController.text.trim();
        final description = _descriptionController.text.trim();
        if (title.isEmpty) {
          ToastTheme.showError(context, message: L10n.get("title_required"));
          return false;
        }
        if (title.length > _titleMaxLength) {
          ToastTheme.showError(context, message: L10n.get("title_too_long"));
          return false;
        }
        if (description.isEmpty) {
          ToastTheme.showError(
            context,
            message: L10n.get("description_required"),
          );
          setState(() => _showDescriptionError = true);
          return false;
        }
        if (description.length > 1000) {
          ToastTheme.showError(
            context,
            message: L10n.get("description_too_long"),
          );
          return false;
        }
        setState(() => _showDescriptionError = false);
        return true;
      default:
        return true;
    }
  }

  String _locationRequiredMessage() {
    return switch (_locationSearchMode) {
      _LocationSearchMode.metro => L10n.get("location_metro_required"),
      _LocationSearchMode.district => L10n.get("location_district_required"),
    };
  }

  Widget _buildWizard(double topPad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, topPad, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Surface the type chosen before entering the wizard as a compact
              // badge throughout the flow.
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ListingTypeBadge(
                  listingTypeCode: ListingTypeHelper.getCodeFromId(
                    _selectedListingTypeId,
                  ),
                  useShortLabel: true,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _buildStepProgress(),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentStep = index),
            children: [
              _buildStepLocation(),
              _buildStepDetails(),
              _buildStepDescription(),
              _buildStepReview(),
            ],
          ),
        ),
        _buildWizardNavBar(),
      ],
    );
  }

  Widget _buildStepProgress() {
    final theme = Theme.of(context);
    final accent = _getBorderColor();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < _stepCount; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _currentStep
                        ? accent
                        : theme.colorScheme.outline.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _stepTitle(_currentStep),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ThemeState().isLightTheme
                      ? Colors.black
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              L10n.getWithParams(
                "wizard_step_counter",
                params: {
                  "current": "${_currentStep + 1}",
                  "total": "$_stepCount",
                },
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWizardNavBar() {
    final theme = Theme.of(context);
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _stepCount - 1;
    final label = theme.textTheme.labelLarge;
    final baseSize = label?.fontSize ?? 14;
    final textStyle = label?.copyWith(fontSize: baseSize * 1.1, height: 1.0) ??
        TextStyle(
          fontSize: baseSize * 1.1,
          height: 1.0,
          fontWeight: FontWeight.w500,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isFirst) ...[
            Expanded(
              child: GhostButtonFactory.iconText(
                onPressed:
                    _isSubmitting ? null : () => _goToStep(_currentStep - 1),
                icon: Icons.arrow_back,
                text: L10n.get("wizard_back"),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: textStyle,
                borderColor: Colors.transparent,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: isLast
                ? PrimaryButtonFactory.iconText(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting ? Icons.hourglass_empty : Icons.add,
                    text: L10n.get(
                      _isSubmitting
                          ? "creating_listing"
                          : "create_listing_button",
                    ),
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textStyle,
                    isLoading: _isSubmitting,
                  )
                : PrimaryButtonFactory.textIcon(
                    onPressed: _goToNextStep,
                    text: L10n.get("wizard_next"),
                    icon: Icons.arrow_forward,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textStyle,
                  ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Step 1 — Location (metro + location)
  // ===========================================================================

  Widget _buildStepLocation() {
    return UydoshFormScrollBody(
      topPadding: 12,
      children: [
        _buildLocationModeToggle(),
        const SizedBox(height: 12),
        if (_locationSearchMode == _LocationSearchMode.metro &&
            _supportsMultiStation) ...[
          MultiStationPicker(
            selectedSubwayLine: _selectedSubwayLine,
            currentStations: _currentStations,
            selectedStationIds:
                _selectedSearchStations.map((s) => s.id).toSet(),
            metroLineScrollController: _metroLineScrollController,
            isLoadingStations: _isLoadingStations,
            onSubwayLineChanged: (index) {
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
            onStationsSelected: _onSearchStationsSelected,
          ),
          if (_selectedSearchStations.isNotEmpty) _buildSelectedStationChips(),
        ] else if (_locationSearchMode == _LocationSearchMode.district &&
            _supportsMultiLocation) ...[
          MultiLocationPicker(
            locations: _currentLocations,
            selectedLocationIds:
                _selectedSearchLocations.map((l) => l.id).toSet(),
            isLoading: _isLoadingLocations,
            accentColor: _getBorderColor(),
            getLocationName: (location) => _getLocalizedName(
              nameUz: location.shortNameUz,
              nameRu: location.shortNameRu,
              nameEn: location.shortNameEn,
              shortName: location.shortName,
            ),
            onLocationsSelected: _onSearchLocationsSelected,
          ),
          if (_selectedSearchLocations.isNotEmpty)
            _buildSelectedLocationChips(),
        ] else if (_locationSearchMode == _LocationSearchMode.metro) ...[
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
                if (_showLocationError && index > 0) {
                  _showLocationError = false;
                }
              });
            },
            onStationChanged: (index) {
              setState(() {
                _selectedStationIndex = index;
                _syncLocationWithStation();
                _showLocationError = false;
              });
            },
            onDismissKeyboard: _dismissKeyboard,
            pickerHeight: 132,
          ),
        ] else ...[
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
        ],
        if (_isRoommateNeededFlow) ...[
          const SizedBox(height: 12),
          LabeledFieldOverlay(
            label: L10n.get("listing_address_field_label"),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: YandexAddressSuggestField(
                      hintText: L10n.get("listing_address_text_label"),
                      controller: _addressTextController,
                      dirtyOutlineColor: _getBorderColor(),
                      decoration: UydoshPlateFieldDecoration.forHint(
                        context,
                        hintText: L10n.get("listing_address_text_label"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 56,
                    child: Tooltip(
                      message: L10n.get("use_current_location"),
                      child: Semantics(
                        button: true,
                        label: L10n.get("use_current_location"),
                        child: OutlinedButton(
                          onPressed: _isResolvingCurrentLocation
                              ? null
                              : _useCurrentLocationForAddress,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _getBorderColor(),
                            side: BorderSide(color: _getBorderColor()),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(56, 56),
                          ),
                          child: _isResolvingCurrentLocation
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.my_location,
                                  size: 20,
                                  color: _getCurrentLocationIconColor(),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationModeToggle() {
    final accent = _getBorderColor();
    final selectedIndex =
        _locationSearchMode == _LocationSearchMode.metro ? 0 : 1;
    final selectedTextColor =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final unselectedTextColor = ThemeState().unselectedTabTextColor;

    const height = 52.0;
    const thumbInset = 2.0;
    const innerRadius = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final innerTrack =
            (constraints.maxWidth - thumbInset * 2).clamp(0.0, double.infinity);
        final segmentWidth = innerTrack / 2;
        final thumbLeft = thumbInset + selectedIndex * segmentWidth;

        final thumbDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(innerRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.38),
              accent.withValues(alpha: 0.58),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 12,
              spreadRadius: 0.4,
              offset: const Offset(0, 4),
            ),
          ],
        );

        return LiquidGlassPlate(
          height: height,
          borderRadius: BorderRadius.circular(height / 2),
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: thumbLeft,
                top: thumbInset,
                bottom: thumbInset,
                width: segmentWidth,
                child: DecoratedBox(decoration: thumbDecoration),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          _setLocationSearchMode(_LocationSearchMode.metro),
                      child: SizedBox(
                        height: height,
                        child: _LocationModeTabContent(
                          isSelected:
                              _locationSearchMode == _LocationSearchMode.metro,
                          label: L10n.get("wizard_location_mode_metro"),
                          icon: Icons.train,
                          selectedTextColor: selectedTextColor,
                          unselectedTextColor: unselectedTextColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          _setLocationSearchMode(_LocationSearchMode.district),
                      child: SizedBox(
                        height: height,
                        child: _LocationModeTabContent(
                          isSelected: _locationSearchMode ==
                              _LocationSearchMode.district,
                          label: L10n.get("wizard_location_mode_district"),
                          icon: Icons.location_on,
                          selectedTextColor: selectedTextColor,
                          unselectedTextColor: unselectedTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _setLocationSearchMode(_LocationSearchMode mode) {
    if (_locationSearchMode == mode) return;
    HapticFeedbackUtils.impact();
    setState(() {
      _locationSearchMode = mode;
      _showLocationError = false;
      if (mode == _LocationSearchMode.metro) {
        _selectedSearchLocations.clear();
        _selectedLocationIndex = -1;
      } else {
        _selectedSearchStations.clear();
        _selectedSubwayLine = 0;
        _selectedStationIndex = 0;
        _currentStations = [];
        _selectedLocationIndex = _selectedSearchLocations.isEmpty
            ? -1
            : _currentLocations.indexWhere(
                (l) => l.id == _selectedSearchLocations.first.id,
              );
      }
    });
  }

  /// Removable chips for each station the author wants to live near.
  Widget _buildSelectedStationChips() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              L10n.getWithParams(
                "wizard_stations_count",
                params: {"count": "${_selectedSearchStations.length}"},
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final station in _selectedSearchStations)
                _buildStationChip(station),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationChip(SubwayStation station) {
    final theme = Theme.of(context);
    final accent = AppColors.getMetroLineColor(station.line);
    final name = _getLocalizedName(
      nameUz: station.nameUz,
      nameRu: station.nameRu,
      nameEn: station.nameEn,
    );
    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeState().isLightTheme
                  ? Colors.black
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _removeSearchStation(station.id),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close, size: 14, color: accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedLocationChips() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              L10n.getWithParams(
                "wizard_locations_count",
                params: {"count": "${_selectedSearchLocations.length}"},
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final location in _selectedSearchLocations)
                _buildLocationChip(location),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(Location location) {
    final theme = Theme.of(context);
    final accent = _getBorderColor();
    final name = _getLocalizedName(
      nameUz: location.shortNameUz,
      nameRu: location.shortNameRu,
      nameEn: location.shortNameEn,
      shortName: location.shortName,
    );
    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeState().isLightTheme
                  ? Colors.black
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _removeSearchLocation(location.id),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close, size: 14, color: accent),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Step 2 — Details (price, amenities, move-in date, private room)
  // ===========================================================================

  Widget _buildStepDetails() {
    return UydoshFormScrollBody(
      topPadding: 12,
      children: [
        if (_isGroupFormingFlow) ...[
          LabeledFieldOverlay(
            label: L10n.get("group_size_target_label"),
            child: GroupSizeTargetPicker(
              groupSizeTarget: _groupSizeTarget,
              onChanged: (value) {
                setState(() => _groupSizeTarget = value);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        PriceRangePicker(
          key: ValueKey<int>(_selectedListingTypeId),
          title: L10n.get(
            _pricePickerSingleHandle
                ? "price_picker_single_title"
                : "price_picker_range_title",
          ),
          minPrice: _priceSliderMin,
          maxPrice: _priceSliderMax,
          initialVisibleMaxPrice: _priceSliderInitialVisibleMax,
          maxExpansionStep: _priceSliderExpansionStep,
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
        if (!_isGroupFormingFlow) ...[
          const SizedBox(height: 16),
          // Amenities Section
          LabeledFieldOverlay(
            label: L10n.get("amenities"),
            child: ListingFormAmenitiesSection(
              listingTypeId: _selectedListingTypeId,
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
          ),
        ],
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
                              setState(() {
                                _moveInDateValue =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                _moveInDateController.text =
                                    _formatMoveInDateDisplay(picked);
                              });
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
              if (!_isGroupFormingFlow) ...[
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
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Step 3 — Description (title, description, photos)
  // ===========================================================================

  Widget _buildStepDescription() {
    return UydoshFormScrollBody(
      topPadding: 12,
      children: [
        // Title Field — pre-filled with auto-generated #TitleName, editable.
        L10n.inputField(
          "listing_title_hint",
          builder: (hintText) => LabeledFieldOverlay(
            label: L10n.get("listing_title_label"),
            child: UydoshPlateTextFormField(
              hintText: hintText,
              controller: _titleController,
              maxLength: _titleMaxLength,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              buildCounter: _buildTitleCounter,
            ),
          ),
        ),
        const SizedBox(height: 10), // Space between title and description

        // Description Field
        L10n.inputField(
          "listing_description_hint",
          builder: (hintText) => LabeledFieldOverlay(
            label: L10n.get("listing_description_label"),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              reverseDuration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              // [AnimatedSize] defaults clip while lerping; footer + transcript
              // growth would hide text until animation finished / refocus.
              clipBehavior: Clip.none,
              child: UydoshPlateTextFormField(
                hintText: hintText,
                showErrorBorder: _showDescriptionError,
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: UydoshPlateFieldDecoration.forHint(
                  context,
                  hintText: hintText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                clipBehavior: Clip.none,
                onChanged: (value) {
                  if (_showDescriptionError && value.trim().isNotEmpty) {
                    setState(() {
                      _showDescriptionError = false;
                    });
                  }
                },
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
                    onTranscriptInserted: () => setState(() {}),
                    layout: DescriptionCounterToolbarLayout.stack,
                    counterVisibleAtFraction: 0.7,
                    debugShowTapBounds: false,
                  );
                },
              ),
            ),
          ),
        ),

        // Photos Section - roommate listings only (not group_forming / room_needed)
        if (_selectedListingTypeId != 1 && !_isGroupFormingFlow) ...[
          const SizedBox(height: 16),
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
                _primaryPhotoIndex = _selectedPhotos.isEmpty ? null : 0;
              });
            },
            isRequired: false,
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // Step 4 — Review (read-only summary with edit jumps)
  // ===========================================================================

  Widget _buildStepReview() {
    final theme = Theme.of(context);
    final notSet = L10n.get("wizard_review_not_set");
    final locationValue = _reviewLocationValue();
    return UydoshFormScrollBody(
      topPadding: 12,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            L10n.get("wizard_review_subtitle"),
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _summaryTile(
          label: _summaryLabel("listing_type_label", fallback: "Listing type"),
          value: _reviewListingTypeValue(),
        ),
        if (_isGroupFormingFlow)
          _summaryTile(
            label: _summaryLabel("group_size_target_label",
                fallback: "Group size"),
            value: L10n.plural("group_size_target_option", _groupSizeTarget),
            stepIndex: 1,
          ),
        _summaryTile(
          label: _summaryLabel("location", fallback: "Location"),
          value: locationValue ?? notSet,
          stepIndex: 0,
        ),
        if (_isRoommateNeededFlow)
          _summaryTile(
            label: _summaryLabel("listing_address_text_label",
                fallback: "Address"),
            value: _addressTextController.text.trim().isEmpty
                ? notSet
                : _addressTextController.text.trim(),
            stepIndex: 0,
          ),
        if (_supportsMultiStation &&
            _locationSearchMode == _LocationSearchMode.metro &&
            _selectedSearchStations.isNotEmpty)
          _summaryTile(
            label: _summaryLabel(
              "wizard_selected_stations",
              fallback: "Selected stations",
            ),
            value: _reviewStationsValue(),
            stepIndex: 0,
          ),
        _summaryTile(
          label: _summaryLabel(
            _isGroupFormingFlow
                ? "group_budget_per_person_label"
                : "listing_price_label",
            fallback: "Price",
          ),
          value: _priceTouched ? _reviewPriceValue() : notSet,
          stepIndex: 1,
        ),
        _summaryTile(
          label: _summaryLabel("move_in_date_label", fallback: "Move-in date"),
          value:
              _moveInDateValue.isNotEmpty ? _moveInDateController.text : notSet,
          stepIndex: 1,
        ),
        if (!_isGroupFormingFlow)
          _summaryTile(
            label: _summaryLabel("private_room", fallback: "Private room"),
            value: _isPrivateRoom
                ? L10n.get("yes", fallback: "Yes")
                : L10n.get("no", fallback: "No"),
            stepIndex: 1,
          ),
        if (!_isGroupFormingFlow)
          _summaryTile(
            label: _summaryLabel("amenities", fallback: "Amenities"),
            value: _selectedAmenityIds.isEmpty
                ? notSet
                : L10n.getWithParams(
                    "wizard_amenities_count",
                    params: {"count": "${_selectedAmenityIds.length}"},
                  ),
            stepIndex: 1,
          ),
        _summaryTile(
          label: _summaryLabel("listing_title_label", fallback: "Title"),
          value: _titleController.text.trim().isEmpty
              ? notSet
              : _titleController.text.trim(),
          stepIndex: 2,
        ),
        _summaryTile(
          label: _summaryLabel("listing_description_label",
              fallback: "Description"),
          value: _descriptionController.text.trim().isEmpty
              ? notSet
              : _descriptionController.text.trim(),
          stepIndex: 2,
        ),
        if (_selectedListingTypeId != 1 && !_isGroupFormingFlow) ...[
          _summaryTile(
            label: _summaryLabel("listing_photos_label", fallback: "Photos"),
            value: _selectedPhotos.isEmpty
                ? notSet
                : L10n.getWithParams(
                    "wizard_photos_count",
                    params: {"count": "${_selectedPhotos.length}"},
                  ),
            stepIndex: 2,
          ),
          if (_selectedPhotos.isNotEmpty) _reviewPhotoStrip(),
        ],
      ],
    );
  }

  /// Localized field label with any trailing ":" stripped (some AppStrings
  /// labels end with a colon, which reads awkwardly in the summary list).
  String _summaryLabel(String key, {required String fallback}) {
    final s = L10n.get(key, fallback: fallback).trim();
    final cleaned = s.replaceAll(RegExp(r":\s*$"), "").trim();
    return cleaned.isEmpty ? fallback : cleaned;
  }

  String _reviewListingTypeValue() {
    String typeKey;
    switch (_selectedListingTypeId) {
      case ListingTypeIds.roommateNeeded:
        typeKey = "listing_type_roommate_needed";
      case ListingTypeIds.groupForming:
        typeKey = "listing_type_short_group_forming";
      default:
        typeKey = "listing_type_room_needed";
    }
    return L10n.get(typeKey);
  }

  String _reviewStationsValue() {
    return _selectedSearchStations
        .map(
          (s) => _getLocalizedName(
            nameUz: s.nameUz,
            nameRu: s.nameRu,
            nameEn: s.nameEn,
          ),
        )
        .join(", ");
  }

  String _reviewLocationsValue() {
    return _selectedSearchLocations
        .map(
          (l) => _getLocalizedName(
            nameUz: l.shortNameUz,
            nameRu: l.shortNameRu,
            nameEn: l.shortNameEn,
            shortName: l.shortName,
          ),
        )
        .join(", ");
  }

  String _reviewPriceValue() {
    if (_pricePickerSingleHandle) {
      return "${_roommatePrice.round()}";
    }
    return "${_roomBudgetMin.round()}–${_roomBudgetMax.round()}";
  }

  String? _reviewLocationValue() {
    if (_locationSearchMode == _LocationSearchMode.district &&
        _supportsMultiLocation) {
      return _selectedSearchLocations.isEmpty ? null : _reviewLocationsValue();
    }
    if (_locationSearchMode == _LocationSearchMode.metro &&
        _supportsMultiStation) {
      return _selectedSearchStations.isEmpty
          ? null
          : L10n.get("wizard_location_mode_metro");
    }
    if (_locationSearchMode == _LocationSearchMode.metro) {
      if (_selectedSubwayLine <= 0 ||
          _currentStations.isEmpty ||
          _selectedStationIndex < 0 ||
          _selectedStationIndex >= _currentStations.length) {
        return null;
      }
      final station = _currentStations[_selectedStationIndex];
      final stationName = _getLocalizedName(
        nameUz: station.nameUz,
        nameRu: station.nameRu,
        nameEn: station.nameEn,
      );
      return L10n.getWithParams(
        "wizard_metro_value",
        params: {"line": "$_selectedSubwayLine", "station": stationName},
      );
    }
    if (_selectedLocationIndex < 0 ||
        _selectedLocationIndex >= _currentLocations.length) {
      return null;
    }
    final loc = _currentLocations[_selectedLocationIndex];
    final name = _getLocalizedName(
      nameUz: loc.shortNameUz,
      nameRu: loc.shortNameRu,
      nameEn: loc.shortNameEn,
    );
    return name;
  }

  Widget _summaryTile({
    required String label,
    required String value,
    int? stepIndex,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: stepIndex == null ? null : () => _goToStep(stepIndex),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
            context,
            theme: theme,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ThemeState().isLightTheme
                            ? Colors.black
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (stepIndex != null) ...[
                const SizedBox(width: 8),
                ThemeIcon(
                  Icons.edit_outlined,
                  size: 18,
                  color: _getBorderColor(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewPhotoStrip() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _goToStep(2),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
            context,
            theme: theme,
          ),
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _selectedPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final photoPath = _selectedPhotos[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: ThemeState().isBlueTheme
                        ? BlueThemeColors.surface
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Image.file(
                      File(photoPath),
                      width: 96,
                      height: 72,
                      fit: BoxFit.cover,
                      cacheWidth: 240,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: 96,
                          height: 72,
                          child: Center(
                            child: ThemeIcon(
                              Icons.broken_image,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
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

  Future<void> _maybeOfferPostCreateSearchAlert(
    ListingDetail createdListing,
  ) async {
    if (!mounted) return;

    final suggestion =
        PostCreateListingSearchAlertSuggestion.fromListing(createdListing);
    if (suggestion == null) return;

    final shouldCreate = await _showPostCreateSearchAlertSheet(suggestion);
    if (!mounted || shouldCreate != true) return;

    final result = await PostCreateListingSearchAlerts.create(suggestion);
    if (!mounted) return;

    switch (result.kind) {
      case PostCreateListingSearchAlertSaveKind.created:
        ActiveSearchAlertsState().bumpCelebration();
        await ActiveSearchAlertsState().refresh();
        if (!mounted) return;

        final push = getIt<IPushNotificationService>();
        if (push.isSupported) {
          final notificationsEnabled = await NotificationPermissionGate.ensure(
            context,
            allowSkipPersistsAcrossLaunches: false,
          );
          if (!mounted) return;
          if (!notificationsEnabled) {
            ToastTheme.showWarning(
              context,
              message: L10n.get("search_alert_permission"),
            );
          }
        }

        ToastTheme.showSuccess(
          context,
          message: L10n.get("search_alert_created"),
          leadingIcon: Icons.notifications_active_outlined,
        );
      case PostCreateListingSearchAlertSaveKind.alreadyExists:
        ToastTheme.showWarning(
          context,
          message: L10n.get("search_alert_already_exists"),
          leadingIcon: Icons.notifications_active_outlined,
        );
      case PostCreateListingSearchAlertSaveKind.failed:
        ToastTheme.showError(
          context,
          message: result.error == null || result.error == "error"
              ? L10n.get("search_alert_failed")
              : result.error!,
        );
    }
  }

  Future<bool?> _showPostCreateSearchAlertSheet(
    PostCreateListingSearchAlertSuggestion suggestion,
  ) {
    return showAppBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LiquidGlassPlate(
            borderRadius: BorderRadius.circular(20),
            sigma: 18,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          L10n.get("search_alert_cta_title"),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ThreeDAppBarIconButton(
                        iconData: Icons.close,
                        onPressed: () => Navigator.of(context).pop(false),
                        semanticsLabel: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L10n.get("search_alert_bell_hint"),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppliedSearchFiltersBar(
                    onPressed: () {},
                    listingTypeId: suggestion.listingTypeId,
                    gender: suggestion.gender,
                    locationId: suggestion.locationId,
                    subwayStationId: suggestion.subwayStationId,
                    subwayStationIds: suggestion.subwayStationIds,
                    subwayLineId: suggestion.subwayLineId,
                    minPrice: suggestion.minPrice,
                    maxPrice: suggestion.maxPrice,
                    privateRoom: suggestion.privateRoomOnly,
                    withPhoto: suggestion.withPhotoOnly,
                    total: null,
                    showLabel: false,
                    alignRight: false,
                    height: 46,
                    chipSize: 34,
                    alwaysShowPriceRange: true,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    height: 52,
                    borderRadius: BorderRadius.circular(16),
                    child: Text(L10n.get("search_alert_cta_create")),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(L10n.get("skip")),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

    // Validate location/search area (mandatory)
    if (_supportsMultiStation &&
        _locationSearchMode == _LocationSearchMode.metro &&
        _selectedSearchStations.isEmpty) {
      ToastTheme.showError(
        context,
        message: _locationRequiredMessage(),
      );
      setState(() {
        _showLocationError = true;
      });
      return;
    } else if (_supportsMultiLocation &&
        _locationSearchMode == _LocationSearchMode.district &&
        _selectedSearchLocations.isEmpty) {
      ToastTheme.showError(
        context,
        message: _locationRequiredMessage(),
      );
      setState(() {
        _showLocationError = true;
      });
      return;
    } else if (!_supportsMultiStation &&
        _locationSearchMode == _LocationSearchMode.metro &&
        _currentSubwayStationId() == null) {
      ToastTheme.showError(
        context,
        message: _locationRequiredMessage(),
      );
      setState(() {
        _showLocationError = true;
      });
      return;
    } else if (!_supportsMultiLocation &&
        _locationSearchMode == _LocationSearchMode.district &&
        _selectedLocationIndex < 0) {
      ToastTheme.showError(
        context,
        message: _locationRequiredMessage(),
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

    if (_priceForCreateRequest() < 1) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_price_minimum"),
      );
      setState(() {
        _showPriceError = true;
      });
      return;
    }

    // Metro line and station are now optional - no validation required

    final consentAccepted = await PublishConsentGate.ensureAccepted(context);
    if (!mounted || !consentAccepted) return;

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the selected location and station (if available)
      final selectedLocation = _selectedLocationIndex >= 0 &&
              _selectedLocationIndex < _currentLocations.length
          ? _currentLocations[_selectedLocationIndex]
          : null;
      final selectedStation =
          _selectedSubwayLine > 0 && _currentStations.isNotEmpty
              ? _currentStations[_selectedStationIndex]
              : null;

      // Demand-side flows persist either station ids or district ids. The UI
      // toggle makes these mutually exclusive; element 0 doubles as the primary
      // single field for backward-compatible display/search.
      final usesMetroMode = _locationSearchMode == _LocationSearchMode.metro;
      final usesDistrictMode =
          _locationSearchMode == _LocationSearchMode.district;
      final multiStationIds = _supportsMultiStation &&
              usesMetroMode &&
              _selectedSearchStations.isNotEmpty
          ? _selectedSearchStations.map((s) => s.id).toList()
          : null;
      final multiLocationIds = _supportsMultiLocation &&
              usesDistrictMode &&
              _selectedSearchLocations.isNotEmpty
          ? _selectedSearchLocations.map((l) => l.id).toList()
          : null;
      final primaryStation = multiStationIds != null
          ? _selectedSearchStations.first
          : usesDistrictMode
              ? null
              : selectedStation;
      final primaryLocation = multiLocationIds != null
          ? _selectedSearchLocations.first
          : usesMetroMode
              ? null
              : selectedLocation;
      final effectiveSubwayLineId = multiStationIds != null
          ? _selectedSearchStations.first.line
          : usesDistrictMode
              ? null
              : (_selectedSubwayLine > 0 ? _selectedSubwayLine : null);
      final addressText =
          _isRoommateNeededFlow ? _addressTextController.text.trim() : "";
      final addressLatitude = addressText.isNotEmpty && _isRoommateNeededFlow
          ? _addressLatitude
          : null;
      final addressLongitude = addressText.isNotEmpty && _isRoommateNeededFlow
          ? _addressLongitude
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
        "  subwayStationId: ${primaryStation?.id ?? "null (optional)"}",
      );
      logger.d(
        "  subwayLineId: ${effectiveSubwayLineId ?? "null (optional)"}",
      );
      logger.d("  locationId: ${primaryLocation?.id ?? "null (optional)"}");
      logger.d("  locationIds: ${multiLocationIds ?? "null"}");
      logger.d(
        "  addressText: ${addressText.isEmpty ? "null" : "\"$addressText\""}",
      );
      logger.d(
        "  addressLatitude: ${addressLatitude?.toStringAsFixed(8) ?? "null"}",
      );
      logger.d(
        "  addressLongitude: ${addressLongitude?.toStringAsFixed(8) ?? "null"}",
      );
      logger.d("  amenityIds: ${_selectedAmenityIds.toList()}");
      logger.d(
        "Selected Location: ${primaryLocation?.shortName ?? "None selected"} (ID: ${primaryLocation?.id ?? "null"})",
      );
      logger.d(
        "Selected Station: ${primaryStation?.nameEn ?? "None selected"} (ID: ${primaryStation?.id ?? "null"})",
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

      final priceBounds = _priceBoundsForCreateRequest();
      final createdListing = await listingService.createListing(
        title: _titleController.text.trim(),
        listingTypeId: listingTypeId,
        price: _priceForCreateRequest(),
        minPrice: priceBounds.min,
        maxPrice: priceBounds.max,
        description: _descriptionController.text.trim(),
        gender: _selectedGender,
        locationId: primaryLocation?.id,
        locationIds: multiLocationIds,
        addressText: addressText.isEmpty ? null : addressText,
        addressLatitude: addressLatitude,
        addressLongitude: addressLongitude,
        amenityIds: _selectedAmenityIds.toList(),
        subwayStationId: primaryStation?.id, // Now optional, moved to end
        subwayStationIds: multiStationIds, // Multi-station (demand-side flows)
        subwayLineId: effectiveSubwayLineId, // Add subway line ID
        moveInDate: _moveInDateValue.isNotEmpty
            ? _moveInDateValue
            : null, // Only send date if selected
        privateRoom: _isPrivateRoom,
        photoPaths: orderedPhotos.isNotEmpty ? orderedPhotos : null,
        groupSizeTarget: _isGroupFormingFlow ? _groupSizeTarget : null,
      );

      if (_isGroupFormingFlow) {
        unawaited(
            GroupHousingSearchAlerts.ensureForGroupListing(createdListing));
      }

      if (!mounted) return;

      getIt<AppAnalyticsService>().logListingCreated(
        listingTypeId: listingTypeId,
        locationId: primaryLocation?.id,
        success: true,
      );
      unawaited(getIt<AppAnalyticsService>().refreshHasActiveListingProperty());

      // Show success message
      ToastTheme.showSuccess(
        context,
        message: L10n.get("listing_created_success"),
      );

      if (isIOSDevice &&
          mounted &&
          listingTypeId != 1 &&
          !ClientLidarRoomScanConfig.lidarRoomScanDisabled.value) {
        final canScan = await RoomPlanCapability.isSupportedOnDevice();
        if (canScan && mounted) {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => RoomPlanScanScreen(
                listingId: createdListing.id,
              ),
            ),
          );
        }
      }

      await _maybeOfferPostCreateSearchAlert(createdListing);
      if (!mounted) return;

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _addressTextController.clear();
      setState(() {
        _selectedListingTypeId = _defaultListingTypeFromProfile;
        _selectedGender = _defaultGenderFromProfile;
        _roommatePrice = 10.0;
        _roomBudgetMin = 10.0;
        _roomBudgetMax = 50.0;
        _priceTouched = false;
        _isPrivateRoom = false;
        _selectedSubwayLine = 0;
        _selectedStationIndex = 0;
        _selectedLocationIndex = -1;
        _identifiedAddressText = null;
        _addressLatitude = null;
        _addressLongitude = null;
        _currentStations = [];
        _selectedSearchStations.clear(); // Clear multi-station chips
        _baselineSearchStationIds = [];
        _selectedSearchLocations.clear(); // Clear multi-location chips
        _baselineSearchLocationIds = [];
        _locationSearchMode = _LocationSearchMode.metro;
        _selectedAmenityIds.clear(); // Clear selected amenities
        _selectedPhotos.clear(); // Clear selected photos
        _primaryPhotoIndex = null; // Reset primary photo index
        _isSubmitting = false; // Reset loading state

        // Reset validation errors
        _showDescriptionError = false;
        _showLocationError = false;
        _showPriceError = false;

        // Reset the wizard back to the first step.
        _currentStep = 0;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }

      // Regenerate title with default values
      _updateTitle();

      // Force home screen to refresh since we created a new listing
      HomeRefreshState().forceRefreshNow();

      // Return to the screen that opened create, then show housing feed.
      if (widget.showAppBar) {
        setState(() => _allowPopWithoutConfirm = true);
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          mainNavigationKey.currentState?.navigateToIndex(0);
        });
      } else {
        mainNavigationKey.currentState?.navigateToIndex(0);
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

class _LocationModeTabContent extends StatelessWidget {
  const _LocationModeTabContent({
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.selectedTextColor,
    required this.unselectedTextColor,
  });

  final bool isSelected;
  final String label;
  final IconData icon;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  @override
  Widget build(BuildContext context) {
    final targetColor = isSelected ? selectedTextColor : unselectedTextColor;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      opacity: isSelected ? 1.0 : 0.82,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        scale: isSelected ? 1.0 : 0.96,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(
                icon,
                color: targetColor,
                size: 22,
                useThemeColor: false,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: targetColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRequest implements IJsonEncodable {
  _EmptyRequest();
  @override
  Map<String, dynamic> toJson() => {};
}
