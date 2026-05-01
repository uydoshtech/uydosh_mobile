import "dart:async";
import "dart:math" as math;

import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/description_counter_toolbar.dart";
import "package:uy_dosh/presentation/widgets/common/unsaved_changes_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_form_scroll_body.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_amenities_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

class EditListingScreen extends StatefulWidget {
  const EditListingScreen({required this.listingDetail, super.key});
  final ListingDetail listingDetail;

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

  static const int _descriptionBaseLines = 4;
  static const int _descriptionExpandedExtraLines = 3;
  bool _isDescriptionExpanded = false;

  // Amenities state
  final Set<int> _selectedAmenityIds = {};

  // Photos state
  List<String> _selectedPhotos = [];
  List<Photo> _existingPhotos = [];
  final Set<int> _deletingPhotoIds = {}; // Track which photos are being deleted
  final Set<int> _makingPhotoPrimaryIds =
      {}; // Track which photos are being made primary

  /// Set to true if the 3D scan screen reports an upload/edit happened.
  bool _roomScanChanged = false;

  /// When true, [Navigator.pop] after a successful save is allowed despite dirty form.
  bool _allowPopWithoutConfirm = false;

  // The save-pulse and room-scan-icon-rotation controllers used to live here
  // and run forever for the entire lifetime of the screen, even when nothing
  // was dirty / nothing was being scanned. They now live inside their own
  // widgets ([_PulsingSaveButton] and [_RoomScanIconRotator]) so the tickers
  // only run while their consumer is actually visible. See those widgets at
  // the bottom of this file.

  void _markDirty() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "edit_listing");
    _titleController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
    _moveInDateController.addListener(_markDirty);
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

  Widget _buildRotatingRoomScanIcon() {
    return _RoomScanIconRotator(
      child: ThemeIcon(
        Icons.view_in_ar,
        color: ThemeState().isBlueTheme ? Colors.white : null,
      ),
    );
  }

  Future<void> _openRoomScan() async {
    HapticFeedbackUtils.impact();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => RoomPlanScanScreen(listingId: widget.listingDetail.id),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      setState(() => _roomScanChanged = true);
    }
  }

  Widget _buildNeumorphicRoomScanButton() {
    final text = L10n.get(
      (_roomScanChanged ||
              (widget.listingDetail.pointCloudUrl?.isNotEmpty ?? false))
          ? "replace_room_scan_3d"
          : "add_room_scan_3d",
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: ThreeDPillButton(
        neumorphicSoftUi: true,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onPressed: () => unawaited(_openRoomScan()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRotatingRoomScanIcon(),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text shown in the single description field (matches API: main `description` or per-language columns).
  String _descriptionForEditing(ListingDetail d) {
    final main = d.description?.trim();
    if (main != null && main.isNotEmpty) return d.description!;
    switch (L10n.currentLanguage) {
      case "ru":
        return d.descriptionRu?.trim() ?? "";
      case "uz":
        return d.descriptionUz?.trim() ?? "";
      case "en":
        return d.descriptionEn?.trim() ?? "";
      default:
        return d.descriptionRu?.trim() ??
            d.descriptionEn?.trim() ??
            d.descriptionUz?.trim() ??
            "";
    }
  }

  void _initializeForm() {
    // Pre-populate form with existing listing data
    _titleController.text = widget.listingDetail.title;
    _descriptionController.text = _descriptionForEditing(widget.listingDetail);

    // Extract only the date part from moveInDate (remove time component)
    var moveInDate = widget.listingDetail.moveInDate ?? "";
    if (moveInDate.isNotEmpty && moveInDate.contains("T")) {
      moveInDate =
          moveInDate.split("T")[0]; // Take only the date part before "T"
    }
    _moveInDateValue = moveInDate;
    if (_moveInDateValue.isNotEmpty) {
      final parsedDate = DateTime.tryParse(_moveInDateValue);
      _moveInDateController.text = parsedDate != null
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
    // Only derive location from the station when the listing has no saved
    // location; otherwise the wheel must match [listingDetail.location] like
    // the detail screen (station.location_id can differ).
    if (widget.listingDetail.location == null) {
      _syncLocationWithStation();
    }
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

      // Index must be into [_currentLocations] (sorted), not the raw API list.
      if (widget.listingDetail.location != null) {
        final currentLocationId = widget.listingDetail.location!.id;
        final locationIndex = _currentLocations.indexWhere(
          (location) => location.id == currentLocationId,
        );
        _selectedLocationIndex = locationIndex >= 0 ? locationIndex : -1;
      } else {
        _selectedLocationIndex = -1;
      }

      _isLoadingLocations = false;
    });
    if (widget.listingDetail.location == null) {
      _syncLocationWithStation();
    }
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
    _titleController.removeListener(_markDirty);
    _descriptionController.removeListener(_markDirty);
    _moveInDateController.removeListener(_markDirty);
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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
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

  String _normListingText(String? s) => (s ?? "").trim();

  List<String> _computeChangedFieldLabels({
    required ListingDetail baseline,
    required int? currentLocationId,
    required int? currentSubwayStationId,
    required int? currentSubwayLineId,
  }) {
    final changed = <String>[];

    void addLabel(String key, {required String fallback}) {
      var label = L10n.get(key, fallback: fallback).trim();
      // Many labels in AppStrings end with ":" (e.g. Move-in date:). Strip for lists.
      label = label.replaceAll(RegExp(r":\s*$"), "").trim();
      changed.add(label.isEmpty ? fallback : label);
    }

    if (_normListingText(_titleController.text) !=
        _normListingText(baseline.title)) {
      addLabel("listing_title_label", fallback: "Title");
    }
    if (_normListingText(_descriptionController.text) !=
        _normListingText(_descriptionForEditing(baseline))) {
      addLabel("listing_description_label", fallback: "Description");
    }

    final baselineTypeId =
        baseline.listingType.code == "roommate_needed" ? 2 : 1;
    if (_selectedListingTypeId != baselineTypeId) {
      addLabel("listing_type_label", fallback: "Listing type");
    }

    final baselineGender = baseline.gender ?? 1;
    if (_selectedGender != baselineGender) {
      addLabel("gender", fallback: "Gender");
    }

    if (_price.round() != baseline.price) {
      addLabel("listing_price_label", fallback: "Price");
    }

    if (_isPrivateRoom != (baseline.privateRoom ?? false)) {
      addLabel("private_room", fallback: "Private room");
    }

    if (_moveInDateValue != _baselineMoveInDate(baseline)) {
      addLabel("move_in_date_label", fallback: "Move-in date");
    }

    if (baseline.locationId != currentLocationId) {
      addLabel("location", fallback: "Location");
    }

    if (baseline.subwayStationId != currentSubwayStationId ||
        baseline.subwayLineId != currentSubwayLineId) {
      addLabel("select_metro_line_optional", fallback: "Metro");
    }

    if (!_amenityIdsMatchBaseline()) {
      addLabel("amenities", fallback: "Amenities");
    }

    if (_selectedPhotos.isNotEmpty) {
      addLabel("listing_photos_label", fallback: "Photos");
    }

    if (_roomScanChanged) {
      addLabel("room_scan_title", fallback: "3D scan");
    }

    return changed;
  }

  String _baselineMoveInDate(ListingDetail d) {
    var moveInDate = d.moveInDate ?? "";
    if (moveInDate.isNotEmpty && moveInDate.contains("T")) {
      moveInDate = moveInDate.split("T")[0];
    }
    return moveInDate;
  }

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

  bool _amenityIdsMatchBaseline() {
    final baseline =
        widget.listingDetail.amenities?.map((a) => a.id).toSet() ?? <int>{};
    if (baseline.length != _selectedAmenityIds.length) return false;
    for (final id in baseline) {
      if (!_selectedAmenityIds.contains(id)) return false;
    }
    return true;
  }

  /// Compares the form to the listing as originally opened (fields persisted via Update only).
  /// Photo deletes / primary changes that save immediately are intentionally ignored.
  bool _isFormDirty() {
    final d = widget.listingDetail;

    if (_normListingText(_titleController.text) != _normListingText(d.title)) {
      return true;
    }
    if (_normListingText(_descriptionController.text) !=
        _normListingText(_descriptionForEditing(d))) {
      return true;
    }

    final baselineTypeId = d.listingType.code == "roommate_needed" ? 2 : 1;
    if (_selectedListingTypeId != baselineTypeId) return true;

    final baselineGender = d.gender ?? 1;
    if (_selectedGender != baselineGender) return true;

    if (_price.round() != d.price) return true;

    if (_isPrivateRoom != (d.privateRoom ?? false)) return true;

    if (_moveInDateValue != _baselineMoveInDate(d)) return true;

    if (!_isLoadingLocations && d.locationId != _currentLocationId()) {
      return true;
    }

    if (!_isLoadingStations) {
      if (d.subwayStationId != _currentSubwayStationId()) return true;
      final curLine = _selectedSubwayLine > 0 ? _selectedSubwayLine : null;
      if (d.subwayLineId != curLine) return true;
    }

    if (!_amenityIdsMatchBaseline()) return true;

    if (_selectedPhotos.isNotEmpty) return true;

    if (_roomScanChanged) return true;

    return false;
  }

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    final baseline = widget.listingDetail;
    final changedFields = _computeChangedFieldLabels(
      baseline: baseline,
      currentLocationId:
          _isLoadingLocations ? baseline.locationId : _currentLocationId(),
      currentSubwayStationId: _isLoadingStations
          ? baseline.subwayStationId
          : _currentSubwayStationId(),
      currentSubwayLineId: _isLoadingStations
          ? baseline.subwayLineId
          : (_selectedSubwayLine > 0 ? _selectedSubwayLine : null),
    );
    final leave = await UnsavedChangesDialog.show(
      context,
      changedFieldLabels: changedFields,
    );
    if (!mounted || !leave) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final useLiquidGlassAppBar =
            themeState.isBlueTheme || themeState.isLightTheme;
        final appBarTheme = theme.appBarTheme;
        // When [extendBodyBehindAppBar] is true the body starts at y=0, so the
        // top padding must clear both the status bar (mainShellGlassExtraTopInset)
        // and the AppBar itself (kToolbarHeight) — otherwise the first row of
        // form fields gets clipped behind the translucent app bar.
        final bodyTopPad = useLiquidGlassAppBar
            ? 16.0 +
                themeState.mainShellGlassExtraTopInset(context) +
                kToolbarHeight
            : 20.0;

        return PopScope(
          canPop: _allowPopWithoutConfirm || !_isFormDirty(),
          onPopInvokedWithResult: _onPopInvoked,
          child: Scaffold(
            extendBodyBehindAppBar: useLiquidGlassAppBar,
            appBar: UydoshAppBar(
              title: L10n.text(
                "edit",
                style: appBarTheme.titleTextStyle,
              ),
              backgroundColor: useLiquidGlassAppBar
                  ? liquidGlassAppBarMaterialColor(context)
                  : appBarTheme.backgroundColor ?? theme.colorScheme.primary,
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
              foregroundColor:
                  appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
              leading: ThreeDAppBarIconButton.backLeading(
                context,
                onPressed: () {
                  // Use maybePop so PopScope (unsaved changes) is respected; imperative
                  // Navigator.pop bypasses Route.popDisposition and always removes the route.
                  Navigator.of(context).maybePop();
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildAppBarTrailingAction(theme),
                ),
              ],
            ),
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
                child: Form(
                  key: _formKey,
                  child: UydoshFormScrollBody(
                    topPadding: bodyTopPad,
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
                        isLoadingStations: _isLoadingStations,
                        metroLineScrollController: _metroLineScrollController,
                        metroStationScrollController:
                            _metroStationScrollController,
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
                        maxPrice: 1000.0,
                        initialMinPrice: _price,
                        initialMaxPrice: _price,
                        useSinglePrice: true,
                        onPriceRangeChanged: (minPrice, maxPrice) {
                          _dismissKeyboard();
                          setState(() {
                            _price =
                                minPrice; // Same value for both in single mode
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ), // Space between price range and description

                      // Description Field
                      WheelPickerPlateContainer(
                        showErrorBorder: _showDescriptionError,
                        theme: theme,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 320),
                          reverseDuration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.hardEdge,
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
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.7)
                                    : Colors.grey[400],
                              ),
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
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    ThreeDSurfaceStyle.wheelPickerPlateRadius,
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    ThreeDSurfaceStyle.wheelPickerPlateRadius,
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
                              color: ThemeState().isLightTheme
                                  ? Colors.black
                                  : theme.colorScheme.onSurfaceVariant,
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
                                  _isDescriptionExpanded =
                                      !_isDescriptionExpanded;
                                }),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Move-in Date and Private Room Row
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
                                  decoration: ThreeDSurfaceStyle
                                      .wheelPickerPlateDecoration(
                                    context,
                                    theme: theme,
                                  ),
                                  child:
                                      ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: _moveInDateController,
                                    builder: (context, value, child) {
                                      final isEmpty = value.text.isEmpty;
                                      final moveInDateLabel =
                                          L10n.get("move_in_date_label");
                                      final anyDateText = L10n.get("any_date")
                                          .replaceAll("\n", " ");
                                      final displayValue =
                                          isEmpty ? anyDateText : value.text;
                                      final displayText =
                                          "$moveInDateLabel\n$displayValue";
                                      final displayStyle = TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: ThemeState().isLightTheme
                                            ? Colors.black
                                            : theme
                                                .colorScheme.onSurfaceVariant,
                                      );
                                      final hintStyle = TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: ThemeState().isLightTheme
                                            ? Colors.black
                                            : theme
                                                .colorScheme.onSurfaceVariant,
                                      );
                                      return GestureDetector(
                                        onTap: () async {
                                          final firstDate = DateTime.now();
                                          final lastDate = DateTime.now().add(
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
                                          final picked =
                                              await LanguageAwareDatePicker
                                                  .showDatePicker(
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
                                              borderRadius: ThreeDSurfaceStyle
                                                  .wheelPickerPlateRadius,
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: ThreeDSurfaceStyle
                                                  .wheelPickerPlateRadius,
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: ThreeDSurfaceStyle
                                                  .wheelPickerPlateRadius,
                                              borderSide: BorderSide(
                                                color: _getBorderColor(),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 16,
                                            ),
                                            prefixIcon: ThemeIcon(
                                              CupertinoIcons.calendar,
                                              size: 22,
                                              color: Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? theme.colorScheme
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
                                              style: isEmpty
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
                                clipBehavior: Clip.antiAlias,
                                decoration: ThreeDSurfaceStyle
                                    .wheelPickerPlateDecoration(
                                  context,
                                  theme: theme,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 16.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ThemeIcon(
                                        Icons.lock_outline,
                                        color: _isPrivateRoom
                                            ? _getBorderColor()
                                            : (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? theme.colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7)
                                                : Colors.grey[600]),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              L10n.get("private_room")
                                                  .replaceFirst(" ", "\n"),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: ThemeState().isLightTheme
                                                    ? Colors.black
                                                    : theme.colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      NeumorphicToggle(
                                        value: _isPrivateRoom,
                                        activeAccentColor: _getBorderColor(),
                                        activeTrackColor: _getBorderColor()
                                            .withValues(alpha: 0.3),
                                        inactiveThumbColor: Theme.of(context)
                                                    .brightness ==
                                                Brightness.dark
                                            ? theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.7)
                                            : Colors.grey.shade600,
                                        inactiveTrackColor: Theme.of(context)
                                                    .brightness ==
                                                Brightness.dark
                                            ? theme.colorScheme.onSurfaceVariant
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
                      const SizedBox(height: 10),

                      // Photos Section
                      PhotoUploader(
                        selectedPhotos: _selectedPhotos,
                        onPhotosChanged: (photos) {
                          logger.d("=== PHOTO SELECTION CHANGED ===");
                          logger
                              .d("Previous selected photos: $_selectedPhotos");
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

                      ValueListenableBuilder<bool>(
                        valueListenable:
                            ClientLidarRoomScanConfig.lidarRoomScanDisabled,
                        builder: (context, lidarDisabled, _) {
                          // For testing: show this on Chrome/Web and iOS.
                          // On web, the scan screen still won't start scanning,
                          // but the UI flow can be exercised end-to-end.
                          final canShowOnThisDevice = isIOSDevice || kIsWeb;
                          if (!canShowOnThisDevice ||
                              (lidarDisabled && !kIsWeb) ||
                              _selectedListingTypeId == 1) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: _buildNeumorphicRoomScanButton(),
                              ),
                            ],
                          );
                        },
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

                      const SizedBox(height: 26),

                      Builder(
                        builder: (context) {
                          final label = Theme.of(context).textTheme.labelLarge;
                          final baseSize = label?.fontSize ?? 14;
                          final textStyle = label?.copyWith(
                                  fontSize: baseSize * 1.2, height: 1.0) ??
                              TextStyle(
                                fontSize: baseSize * 1.2,
                                height: 1.0,
                                fontWeight: FontWeight.w500,
                              );
                          return PrimaryButtonFactory.iconText(
                            onPressed: _isSubmitting ? null : _submitForm,
                            icon: Icons.save,
                            text: L10n.get(
                              _isSubmitting
                                  ? "updating_listing"
                                  : "update_listing_button",
                            ),
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(20),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: textStyle,
                            isLoading: _isSubmitting,
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
        subwayLineId: _selectedSubwayLine > 0
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
      final changedFields = _computeChangedFieldLabels(
        baseline: widget.listingDetail,
        currentLocationId: selectedLocation.id,
        currentSubwayStationId: selectedStation?.id,
        currentSubwayLineId:
            _selectedSubwayLine > 0 ? _selectedSubwayLine : null,
      );
      final baseSuccess = L10n.get("listing_updated_success");
      final changedPrefix = L10n.get("changed_fields", fallback: "Changed");
      ToastTheme.showSuccess(
        context,
        message: changedFields.isEmpty
            ? baseSuccess
            : "$baseSuccess\n$changedPrefix: ${changedFields.join(', ')}",
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

      // Navigate back after PopScope allows pop (form still "dirty" vs baseline).
      setState(() => _allowPopWithoutConfirm = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop(true); // true indicates listing was updated
      });
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

  /// Shows a pulsing save icon when the form has unsaved changes (or a
  /// spinner while a save is in progress). Falls back to the 3-dots menu
  /// when the form is clean — matching the behavior on the edit profile
  /// screen so the save affordance is consistently discoverable.
  Widget _buildAppBarTrailingAction(ThemeData theme) {
    final foregroundColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    if (_isSubmitting) {
      return IconButton(
        onPressed: null,
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
        tooltip: L10n.get("save_changes"),
      );
    }

    if (_isFormDirty()) {
      return _PulsingSaveButton(
        onPressed: () {
          HapticFeedbackUtils.impact();
          _submitForm();
        },
        tooltip: L10n.get("save_changes"),
      );
    }

    return ActionDropdownMenu(
      items: _buildActionMenuItems(),
      icon: Icons.more_vert,
      iconColor: foregroundColor,
      tooltip: L10n.get("actions"),
    );
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
          // First slot after removal: index 1 if we removed the lead photo, else index 0.
          final nextIdx = index == 0 ? 1 : 0;
          newPrimaryPhotoId = _existingPhotos[nextIdx].id;
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
          }
        });

        // Update backend for new primary photo if needed (do this after setState)
        if (shouldPromoteNewPrimary && newPrimaryPhotoId != null) {
          _updatePrimaryPhotoInBackend(newPrimaryPhotoId);
        }

        // Show success message (avoid double toast when removing the last image)
        if (remainingPhotosCount == 0) {
          ToastTheme.showSuccess(
            context,
            message: L10n.get("last_photo_deleted"),
          );
        } else {
          ToastTheme.showSuccess(
            context,
            message: L10n.get("photo_deleted_success"),
          );
        }
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

/// Save icon that pulses (fades) gently to draw attention. Owns its own
/// `AnimationController`, so the controller only ticks while this widget is
/// mounted — i.e. only while the form is actually dirty. Previously the
/// controller lived on the parent state and ticked forever, including for the
/// majority of the screen's lifetime when nothing was unsaved.
class _PulsingSaveButton extends StatefulWidget {
  const _PulsingSaveButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_PulsingSaveButton> createState() => _PulsingSaveButtonState();
}

class _PulsingSaveButtonState extends State<_PulsingSaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: const ThemeIcon(Icons.save),
        tooltip: widget.tooltip,
      ),
    );
  }
}

/// Rotates [child] for one short attention burst on first paint, then stops.
///
/// Replaces a previous behavior where the room-scan icon spun forever for the
/// entire lifetime of the edit-listing screen. The user only needs to see the
/// "this is interactive / animated" cue once; after that the icon rests.
class _RoomScanIconRotator extends StatefulWidget {
  const _RoomScanIconRotator({required this.child});

  final Widget child;

  @override
  State<_RoomScanIconRotator> createState() => _RoomScanIconRotatorState();
}

class _RoomScanIconRotatorState extends State<_RoomScanIconRotator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const Duration _burstDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _burstDuration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Two full rotations across `_burstDuration`, then static.
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi * 2,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
