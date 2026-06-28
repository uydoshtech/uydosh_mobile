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
import "package:uy_dosh/base/services/room_plan_capability.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/description_counter_toolbar.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/group_size_target_picker.dart";
import "package:uy_dosh/presentation/widgets/common/unsaved_changes_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/labeled_field_overlay.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_form_scroll_body.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_amenities_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/multi_location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/multi_station_picker.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/photo_item.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_plate_text_form_field.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

class EditListingScreen extends StatefulWidget {
  const EditListingScreen({required this.listingDetail, super.key});
  final ListingDetail listingDetail;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

enum _LocationSearchMode { metro, district }

class _EditListingScreenState extends State<EditListingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moveInDateController = TextEditingController();
  String _moveInDateValue = "";
  FixedExtentScrollController? _locationScrollController;
  FixedExtentScrollController? _listingTypeScrollController;
  FixedExtentScrollController? _groupSizeScrollController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _metroStationScrollController;
  int _selectedListingTypeId = 2; // 2 = roommate needed, 1 = room needed
  // Editable on the edit form (1 = male, 2 = female). Unlike the create flow,
  // where gender is inferred from the profile and the picker is hidden, here we
  // seed from the listing being edited and let the user change it.
  int _selectedGender = 1;
  int _groupSizeTarget = 3;

  bool get _isGroupFormingFlow =>
      _selectedListingTypeId == ListingTypeIds.groupForming;

  bool get _supportsMultiSearch =>
      _selectedListingTypeId == ListingTypeIds.roomNeeded ||
      _isGroupFormingFlow;

  /// Scalar rent for "roommate needed" (listing type 2).
  double _roommatePrice = 50.0;

  /// Budget range for "room needed" (listing type 1).
  double _roomBudgetMin = 50.0;
  double _roomBudgetMax = 50.0;
  static const double _priceSliderMin = 10.0;
  static const double _priceSliderMax = 1000.0;
  static const double _priceSliderInitialVisibleMax = 500.0;
  static const double _priceSliderExpansionStep = 100.0;
  bool get _pricePickerSingleHandle =>
      _selectedListingTypeId == ListingTypeIds.roommateNeeded;
  bool _isPrivateRoom = false; // Add private room toggle
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  _LocationSearchMode _locationSearchMode = _LocationSearchMode.metro;
  List<SubwayStation> _currentStations = [];
  List<Location> _currentLocations = [];

  static const List<int> _listingTypePickerOrder = [
    ListingTypeIds.roommateNeeded,
    ListingTypeIds.groupForming,
    ListingTypeIds.roomNeeded,
  ];

  final List<SubwayStation> _selectedSearchStations = [];
  final List<Location> _selectedSearchLocations = [];
  final Map<int, SubwayStation> _stationCache = {};

  bool _isLoadingStations = false;
  bool _isLoadingLocations = false;
  bool _isSubmitting = false;

  // Validation state variables
  bool _showDescriptionError = false;
  bool _showLocationError = false;

  static const int _descriptionBaseLines = 4;
  static const int _descriptionExpandedExtraLines = 3;
  bool _isDescriptionExpanded = false;

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

  // Amenities state
  final Set<int> _selectedAmenityIds = {};

  // Photos state
  List<String> _selectedPhotos = [];
  List<Photo> _existingPhotos = [];
  final Set<int> _deletingPhotoIds = {}; // Track which photos are being deleted
  final Set<int> _makingPhotoPrimaryIds =
      {}; // Track which photos are being made primary

  /// Display order for the combined existing + new photos grid. Owned by this
  /// screen so drag-reorder survives rebuilds and can be persisted on save.
  /// Kept in sync with [_existingPhotos] and [_selectedPhotos] via
  /// [_rebuildOrderedPhotos] whenever either source changes.
  List<PhotoItem> _orderedPhotos = const [];
  bool _photoOrderDirty = false;

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

  int _listingTypeIdFromDetail(ListingDetail d) {
    switch (d.listingType.code) {
      case ListingTypeCodes.roommateNeeded:
        return ListingTypeIds.roommateNeeded;
      case ListingTypeCodes.groupForming:
        return ListingTypeIds.groupForming;
      default:
        return ListingTypeIds.roomNeeded;
    }
  }

  SubwayStation _stationFromDetail(SubwayStationDetail station) {
    return SubwayStation(
      id: station.id,
      line: station.line,
      ordinal: 0,
      nameUz: station.nameUz,
      nameRu: station.nameRu,
      nameEn: station.nameEn,
    );
  }

  Location _locationFromDetail(LocationDetail location) {
    return Location(
      id: location.id,
      createdAt: "",
      updatedAt: "",
      nameUz: location.nameUz,
      nameRu: location.nameRu,
      nameEn: location.nameEn,
      shortNameUz: location.shortNameUz,
      shortNameRu: location.shortNameRu,
      shortNameEn: location.shortNameEn,
    );
  }

  void _seedMultiSearchFromDetail() {
    final d = widget.listingDetail;
    final stations = d.searchSubwayStations ?? const <SubwayStationDetail>[];
    final locations = d.searchLocations ?? const <LocationDetail>[];

    _selectedSearchStations.clear();
    _selectedSearchLocations.clear();
    _stationCache.clear();

    if (stations.isNotEmpty) {
      final mapped = stations.map(_stationFromDetail).toList();
      _locationSearchMode = _LocationSearchMode.metro;
      _selectedSearchStations.addAll(mapped);
      _stationCache.addEntries(mapped.map((s) => MapEntry(s.id, s)));
      _selectedSubwayLine = mapped.first.line;
      return;
    }

    if (locations.isNotEmpty) {
      _locationSearchMode = _LocationSearchMode.district;
      _selectedSearchLocations.addAll(locations.map(_locationFromDetail));
      return;
    }

    final station = d.subwayStation;
    if (station != null) {
      final mapped = _stationFromDetail(station);
      _locationSearchMode = _LocationSearchMode.metro;
      _selectedSearchStations.add(mapped);
      _stationCache[mapped.id] = mapped;
      _selectedSubwayLine = mapped.line;
      return;
    }

    final location = d.location;
    if (location != null) {
      _locationSearchMode = _LocationSearchMode.district;
      _selectedSearchLocations.add(_locationFromDetail(location));
    }
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
    unawaited(_initGender());
    _listingTypeScrollController = FixedExtentScrollController(
      initialItem: _listingTypePickerOrder
          .indexOf(_selectedListingTypeId)
          .clamp(0, _listingTypePickerOrder.length - 1),
    );
    _metroLineScrollController = FixedExtentScrollController(
      initialItem: _selectedSubwayLine,
    );
    _metroStationScrollController = FixedExtentScrollController(
      initialItem: _selectedStationIndex,
    );
    if (_isGroupFormingFlow) {
      _groupSizeScrollController = FixedExtentScrollController(
        initialItem: _groupSizeTarget - GroupSizeTargetPicker.minSize,
      );
    }
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
        builder: (context) =>
            RoomPlanScanScreen(listingId: widget.listingDetail.id),
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

    // Set listing type from the stored listing code.
    _selectedListingTypeId = _listingTypeIdFromDetail(widget.listingDetail);
    if (_isGroupFormingFlow) {
      _isPrivateRoom = false;
    }
    _groupSizeTarget = (widget.listingDetail.groupSizeTarget ?? 3).clamp(
      GroupSizeTargetPicker.minSize,
      GroupSizeTargetPicker.maxSize,
    );
    // Seed gender from the listing being edited so the picker shows its current
    // value. Falls back to male; the profile fallback is resolved in _initGender.
    final listingGender = widget.listingDetail.gender;
    _selectedGender =
        (listingGender == 1 || listingGender == 2) ? listingGender! : 1;

    // Seed price fields from the stored listing price (midpoint for room-needed).
    _roommatePrice = widget.listingDetail.price
        .toDouble()
        .clamp(_priceSliderMin, _priceSliderMax);
    final storedMin = widget.listingDetail.minPrice;
    final storedMax = widget.listingDetail.maxPrice;
    if (storedMin != null &&
        storedMax != null &&
        storedMin > 0 &&
        storedMax >= storedMin) {
      _roomBudgetMin =
          storedMin.toDouble().clamp(_priceSliderMin, _priceSliderMax);
      _roomBudgetMax =
          storedMax.toDouble().clamp(_priceSliderMin, _priceSliderMax);
    } else if (_selectedListingTypeId == 1 ||
        widget.listingDetail.listingType.code ==
            ListingTypeCodes.groupForming) {
      _deriveBudgetRangeFromRoommatePrice();
    } else {
      _roomBudgetMin = _roommatePrice;
      _roomBudgetMax = _roommatePrice;
    }

    _seedMultiSearchFromDetail();

    // Set subway line and station
    if (_selectedSearchStations.isNotEmpty) {
      _selectedSubwayLine = _selectedSearchStations.first.line;
      _loadStationsForLine(_selectedSubwayLine);
    } else if (widget.listingDetail.subwayStation != null) {
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
    _rebuildOrderedPhotos();
  }

  /// Resolve the gender picker's initial value. The listing's stored gender wins
  /// (it's what the user is editing); when the listing has none, fall back to
  /// the user profile so the picker still starts on a sensible option.
  Future<void> _initGender() async {
    final listingGender = widget.listingDetail.gender;
    if (listingGender == 1 || listingGender == 2) {
      return; // Already seeded synchronously in _initializeForm.
    }
    final gender = await _getProfileGender();
    if (!mounted) return;
    final resolved = (gender == 1 || gender == 2) ? gender! : 1;
    if (resolved == _selectedGender) return;
    setState(() => _selectedGender = resolved);
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

  /// Rebuild [_orderedPhotos] from the current sources, preserving any
  /// user-chosen order from the previous `_orderedPhotos` list.
  ///
  /// On first build (no prior order), existing photos are laid out with the
  /// primary one first (matching the original PhotoUploader behavior), then
  /// any newly-picked photos in selection order.
  void _rebuildOrderedPhotos() {
    final prev = _orderedPhotos;
    final prevKeys = prev.map((e) => e.stableKey).toList();

    // "Fresh" list in the default order (primary-first for existing, then
    // new photos in selection order). Used both for first build and as the
    // source of truth for which items should exist.
    final fresh = <PhotoItem>[];
    final primaryIndex = _existingPhotos.indexWhere((p) => p.isPrimary);
    if (primaryIndex > 0) {
      fresh.add(ExistingPhotoItem(_existingPhotos[primaryIndex]));
      for (var i = 0; i < _existingPhotos.length; i++) {
        if (i == primaryIndex) continue;
        fresh.add(ExistingPhotoItem(_existingPhotos[i]));
      }
    } else {
      for (final p in _existingPhotos) {
        fresh.add(ExistingPhotoItem(p));
      }
    }
    for (final path in _selectedPhotos) {
      fresh.add(NewPhotoItem(path));
    }

    if (prevKeys.isEmpty) {
      _orderedPhotos = fresh;
      return;
    }

    // Keep previous ordering for items that still exist, then append any
    // items that are new since the last rebuild (e.g. a newly-picked photo).
    final freshByKey = {for (final item in fresh) item.stableKey: item};
    final merged = <PhotoItem>[];
    final used = <String>{};
    for (final key in prevKeys) {
      final item = freshByKey[key];
      if (item != null) {
        merged.add(item);
        used.add(key);
      }
    }
    for (final item in fresh) {
      if (!used.contains(item.stableKey)) {
        merged.add(item);
      }
    }
    _orderedPhotos = merged;
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
      for (final station in stations) {
        _stationCache[station.id] = station;
      }

      // Find and set the current station index
      final selectedStationId = _selectedSearchStations
          .where((station) => station.line == _selectedSubwayLine)
          .map((station) => station.id)
          .cast<int?>()
          .firstWhere((id) => id != null, orElse: () => null);
      if (selectedStationId != null) {
        final stationIndex = stations.indexWhere(
          (station) => station.id == selectedStationId,
        );
        _selectedStationIndex = stationIndex >= 0 ? stationIndex : 0;
      } else if (widget.listingDetail.subwayStation != null) {
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
    if (!_supportsMultiSearch && widget.listingDetail.location == null) {
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
                (location) => location.id == _selectedSearchLocations.first.id,
              );
      }
    });
  }

  void _onSearchStationsSelected(List<int> ids) {
    setState(() {
      _selectedSearchLocations.clear();
      _selectedLocationIndex = -1;
      _showLocationError = false;
      final next = <SubwayStation>[];
      for (final id in ids) {
        final station = _stationCache[id] ??
            _selectedSearchStations
                .where((station) => station.id == id)
                .cast<SubwayStation?>()
                .firstWhere((station) => station != null, orElse: () => null);
        if (station != null) next.add(station);
      }
      _selectedSearchStations
        ..clear()
        ..addAll(next);
    });
  }

  void _removeSearchStation(int stationId) {
    HapticFeedbackUtils.impact();
    setState(() {
      _selectedSearchStations.removeWhere((station) => station.id == stationId);
    });
  }

  void _onSearchLocationsSelected(List<int> ids) {
    setState(() {
      _selectedSearchStations.clear();
      _selectedSubwayLine = 0;
      _selectedStationIndex = 0;
      _currentStations = [];
      _showLocationError = false;
      final next = <Location>[];
      for (final id in ids) {
        final location = _currentLocations
            .where((location) => location.id == id)
            .cast<Location?>()
            .firstWhere((location) => location != null, orElse: () => null);
        if (location != null) next.add(location);
      }
      _selectedSearchLocations
        ..clear()
        ..addAll(next);
      _selectedLocationIndex = next.isEmpty
          ? -1
          : _currentLocations.indexWhere(
              (location) => location.id == next.first.id,
            );
    });
  }

  void _removeSearchLocation(int locationId) {
    HapticFeedbackUtils.impact();
    setState(() {
      _selectedSearchLocations.removeWhere(
        (location) => location.id == locationId,
      );
      _selectedLocationIndex = _selectedSearchLocations.isEmpty
          ? -1
          : _currentLocations.indexWhere(
              (location) => location.id == _selectedSearchLocations.first.id,
            );
    });
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
      if (_selectedSearchLocations.isNotEmpty) {
        final currentLocationId = _selectedSearchLocations.first.id;
        final locationIndex = _currentLocations.indexWhere(
          (location) => location.id == currentLocationId,
        );
        _selectedLocationIndex = locationIndex >= 0 ? locationIndex : -1;
      } else if (widget.listingDetail.location != null) {
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
    if (!_supportsMultiSearch && widget.listingDetail.location == null) {
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
    _moveInDateController.dispose();
    _locationScrollController?.dispose();
    _listingTypeScrollController?.dispose();
    _groupSizeScrollController?.dispose();
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

  int _priceForUpdateRequest() {
    if (_selectedListingTypeId == ListingTypeIds.roommateNeeded) {
      return _roommatePrice.round();
    }
    return ((_roomBudgetMin + _roomBudgetMax) / 2).round();
  }

  ({int min, int max}) _priceBoundsForUpdateRequest() {
    if (_pricePickerSingleHandle) {
      final p = _roommatePrice.round();
      return (min: p, max: p);
    }
    return (min: _roomBudgetMin.round(), max: _roomBudgetMax.round());
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

  Widget _buildLocationModeToggle() {
    final theme = Theme.of(context);
    final accent = _getBorderColor();
    final selectedColor =
        ThemeState().isBlueTheme ? Colors.white : theme.colorScheme.onSurface;
    final unselectedColor = selectedColor.withValues(alpha: 0.62);
    const height = 60.0;

    Widget tab({
      required _LocationSearchMode mode,
      required IconData icon,
      required String label,
    }) {
      final selected = _locationSearchMode == mode;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _setLocationSearchMode(mode),
          child: SizedBox.expand(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.28) : null,
                borderRadius: BorderRadius.circular(999),
                border: selected
                    ? Border.all(color: accent.withValues(alpha: 0.45))
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeIcon(
                    icon,
                    size: 22,
                    color: selected ? selectedColor : unselectedColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected ? selectedColor : unselectedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return LiquidGlassPlate(
      height: height,
      borderRadius: BorderRadius.circular(999),
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          tab(
            mode: _LocationSearchMode.metro,
            icon: Icons.train,
            label: L10n.get("wizard_location_mode_metro"),
          ),
          tab(
            mode: _LocationSearchMode.district,
            icon: Icons.location_on,
            label: L10n.get("wizard_location_mode_district"),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandSideGeoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLocationModeToggle(),
        const SizedBox(height: 12),
        if (_locationSearchMode == _LocationSearchMode.metro) ...[
          MultiStationPicker(
            selectedSubwayLine: _selectedSubwayLine,
            currentStations: _currentStations,
            selectedStationIds:
                _selectedSearchStations.map((station) => station.id).toSet(),
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
        ] else ...[
          MultiLocationPicker(
            locations: _currentLocations,
            selectedLocationIds:
                _selectedSearchLocations.map((location) => location.id).toSet(),
            onLocationsSelected: _onSearchLocationsSelected,
            getLocationName: (location) => _getLocalizedName(
              nameUz: location.shortNameUz,
              nameRu: location.shortNameRu,
              nameEn: location.shortNameEn,
              shortName: location.shortName,
            ),
            isLoading: _isLoadingLocations,
            accentColor: _getBorderColor(),
          ),
          if (_selectedSearchLocations.isNotEmpty)
            _buildSelectedLocationChips(),
        ],
      ],
    );
  }

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

    final baselineTypeId = _listingTypeIdFromDetail(baseline);
    if (!_isGroupFormingFlow && _selectedListingTypeId != baselineTypeId) {
      addLabel("listing_type_label", fallback: "Listing type");
    }

    if (_isGroupFormingFlow &&
        _groupSizeTarget != (baseline.groupSizeTarget ?? 3)) {
      addLabel("group_size_target_label", fallback: "Group size");
    }

    if (_priceForUpdateRequest() != baseline.price) {
      addLabel("listing_price_label", fallback: "Price");
    }

    if (!_isGroupFormingFlow &&
        _isPrivateRoom != (baseline.privateRoom ?? false)) {
      addLabel("private_room", fallback: "Private room");
    }

    if (_moveInDateValue != _baselineMoveInDate(baseline)) {
      addLabel("move_in_date_label", fallback: "Move-in date");
    }

    if (_supportsMultiSearch) {
      final multiLocationChanged =
          _locationSearchMode == _LocationSearchMode.metro
              ? !_searchStationsMatchBaseline()
              : !_searchLocationsMatchBaseline();
      if (multiLocationChanged) {
        addLabel("location", fallback: "Location");
      }
    } else {
      if (baseline.locationId != currentLocationId) {
        addLabel("location", fallback: "Location");
      }

      if (baseline.subwayStationId != currentSubwayStationId ||
          baseline.subwayLineId != currentSubwayLineId) {
        addLabel("select_metro_line_optional", fallback: "Metro");
      }
    }

    if (!_amenityIdsMatchBaseline()) {
      addLabel("amenities", fallback: "Amenities");
    }

    if (_selectedPhotos.isNotEmpty || _photoOrderDirty) {
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

  List<int> _baselineSearchStationIds() {
    final stations = widget.listingDetail.searchSubwayStations;
    if (stations != null && stations.isNotEmpty) {
      return stations.map((station) => station.id).toList();
    }
    final id = widget.listingDetail.subwayStationId;
    return id != null ? [id] : const <int>[];
  }

  List<int> _baselineSearchLocationIds() {
    final locations = widget.listingDetail.searchLocations;
    if (locations != null && locations.isNotEmpty) {
      return locations.map((location) => location.id).toList();
    }
    final id = widget.listingDetail.locationId;
    return id != null ? [id] : const <int>[];
  }

  bool _searchStationsMatchBaseline() {
    return listEquals(
      _selectedSearchStations.map((station) => station.id).toList(),
      _baselineSearchStationIds(),
    );
  }

  bool _searchLocationsMatchBaseline() {
    return listEquals(
      _selectedSearchLocations.map((location) => location.id).toList(),
      _baselineSearchLocationIds(),
    );
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

    final baselineTypeId = _listingTypeIdFromDetail(d);
    if (!_isGroupFormingFlow && _selectedListingTypeId != baselineTypeId) {
      return true;
    }

    if (_isGroupFormingFlow && _groupSizeTarget != (d.groupSizeTarget ?? 3)) {
      return true;
    }

    if (_priceForUpdateRequest() != d.price) return true;

    if (!_isGroupFormingFlow && _isPrivateRoom != (d.privateRoom ?? false)) {
      return true;
    }

    if (_moveInDateValue != _baselineMoveInDate(d)) return true;

    if (_supportsMultiSearch) {
      if (_locationSearchMode == _LocationSearchMode.metro) {
        if (_selectedSearchLocations.isNotEmpty) return true;
        if (!_searchStationsMatchBaseline()) return true;
      } else {
        if (_selectedSearchStations.isNotEmpty) return true;
        if (!_searchLocationsMatchBaseline()) return true;
      }
    } else {
      if (!_isLoadingLocations && d.locationId != _currentLocationId()) {
        return true;
      }

      if (!_isLoadingStations) {
        if (d.subwayStationId != _currentSubwayStationId()) return true;
        final curLine = _selectedSubwayLine > 0 ? _selectedSubwayLine : null;
        if (d.subwayLineId != curLine) return true;
      }
    }

    if (!_amenityIdsMatchBaseline()) return true;

    if (_selectedPhotos.isNotEmpty) return true;
    if (_photoOrderDirty) return true;

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
    Navigator.of(context).pop(_roomScanChanged ? true : result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final useLiquidGlassAppBar =
            themeState.usesLiquidGlassChrome;
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
                if (_isSubmitting || _isFormDirty())
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
                  child: KeyboardDismissScope(
                    child: UydoshFormScrollBody(
                      topPadding: bodyTopPad,
                      children: [
                        if (_isGroupFormingFlow) ...[
                          LabeledFieldOverlay(
                            label: L10n.get("group_size_target_label"),
                            child: GroupSizeTargetPicker(
                              groupSizeTarget: _groupSizeTarget,
                              scrollController: _groupSizeScrollController,
                              onChanged: (value) {
                                setState(() => _groupSizeTarget = value);
                                _markDirty();
                              },
                            ),
                          ),
                        ] else ...[
                          // Listing type + gender. Unlike the create flow (where
                          // gender is inferred from the profile and hidden), the
                          // edit form exposes the gender picker so it can be changed.
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: LabeledFieldOverlay(
                                  label: L10n.get("listing_type_label"),
                                  child: ListingTypePicker(
                                    selectedListingTypeId:
                                        _selectedListingTypeId,
                                    scrollController:
                                        _listingTypeScrollController,
                                    userGender: _selectedGender,
                                    onListingTypeChanged: (listingTypeId) {
                                      setState(() {
                                        final prevType = _selectedListingTypeId;
                                        _selectedListingTypeId = listingTypeId;
                                        if (prevType ==
                                                ListingTypeIds.roommateNeeded &&
                                            listingTypeId ==
                                                ListingTypeIds.roomNeeded) {
                                          _deriveBudgetRangeFromRoommatePrice();
                                        } else if (prevType ==
                                                ListingTypeIds.roomNeeded &&
                                            listingTypeId ==
                                                ListingTypeIds.roommateNeeded) {
                                          _deriveRoommatePriceFromBudget();
                                        }
                                      });
                                      _markDirty();
                                    },
                                    useThemeColors: true,
                                    showArrows: false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LabeledFieldOverlay(
                                  label: L10n.get("gender"),
                                  child: GenderPicker(
                                    selectedGender: _selectedGender,
                                    onGenderChanged: (gender) {
                                      setState(() => _selectedGender = gender);
                                      _markDirty();
                                    },
                                    useThemeColors: true,
                                    showArrows: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),

                        if (_supportsMultiSearch) ...[
                          _buildDemandSideGeoSection(),
                        ] else ...[
                          // Metro Line and Station Selection (Third Row)
                          ListingFormMetroSection(
                            selectedSubwayLine: _selectedSubwayLine,
                            selectedStationIndex: _selectedStationIndex,
                            currentStations: _currentStations,
                            isLoadingStations: _isLoadingStations,
                            metroLineScrollController:
                                _metroLineScrollController,
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
                        ],
                        const SizedBox(
                          height: 10,
                        ), // Space between location and price range
                        // Price — single handle for roommate needed, range for room needed.
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
                          initialMinPrice: _pricePickerSingleHandle
                              ? _roommatePrice
                              : _roomBudgetMin,
                          initialMaxPrice: _pricePickerSingleHandle
                              ? _roommatePrice
                              : _roomBudgetMax,
                          useSinglePrice: _pricePickerSingleHandle,
                          onPriceRangeChanged: (minPrice, maxPrice) {
                            _dismissKeyboard();
                            setState(() {
                              if (_pricePickerSingleHandle) {
                                _roommatePrice = minPrice;
                              } else {
                                _roomBudgetMin = minPrice;
                                _roomBudgetMax = maxPrice;
                              }
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Space between price range and title

                        // Title Field — editable. Pre-populated with the
                        // listing's existing title in [_initializeForm].
                        LabeledFieldOverlay(
                          label: L10n.get("listing_title_label"),
                          child: UydoshPlateTextFormField(
                            hintText: L10n.get("listing_title_hint"),
                            controller: _titleController,
                            maxLength: _titleMaxLength,
                            maxLines: 1,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            buildCounter: _buildTitleCounter,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Space between title and description

                        // Description Field
                        LabeledFieldOverlay(
                          label: L10n.get("listing_description_label"),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 320),
                            reverseDuration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            child: UydoshPlateTextFormField(
                              hintText: L10n.get("listing_description_hint"),
                              showErrorBorder: _showDescriptionError,
                              controller: _descriptionController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: UydoshPlateFieldDecoration.forHint(
                                context,
                                hintText: L10n.get(
                                  "listing_description_hint",
                                ),
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.7)
                                      : Colors.grey[400],
                                ),
                              ).copyWith(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              clipBehavior: Clip.none,
                              onChanged: (value) {
                                if (_showDescriptionError &&
                                    value.trim().isNotEmpty) {
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
                                    _isDescriptionExpanded =
                                        !_isDescriptionExpanded;
                                  }),
                                  onTranscriptInserted: () => setState(() {}),
                                  counterVisibleAtFraction: 0.7,
                                  debugShowTapBounds: false,
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
                                    child: ValueListenableBuilder<
                                        TextEditingValue>(
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
                              if (!_isGroupFormingFlow) ...[
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
                                                : (Theme.of(context)
                                                            .brightness ==
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
                                                    color: ThemeState()
                                                            .isLightTheme
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
                                            activeAccentColor:
                                                _getBorderColor(),
                                            activeTrackColor: _getBorderColor()
                                                .withValues(alpha: 0.3),
                                            inactiveThumbColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? theme.colorScheme
                                                        .onSurfaceVariant
                                                        .withOpacity(0.7)
                                                    : Colors.grey.shade600,
                                            inactiveTrackColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? theme.colorScheme
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
                        const SizedBox(height: 10),

                        // Photos Section - Only show for roommate needed listings (not for room needed)
                        if (_selectedListingTypeId !=
                            1) // Hide for "room needed" (listingTypeId == 1)
                          PhotoUploader(
                            selectedPhotos: _selectedPhotos,
                            onPhotosChanged: (photos) {
                              logger.d("=== PHOTO SELECTION CHANGED ===");
                              logger.d(
                                  "Previous selected photos: $_selectedPhotos");
                              logger.d("New selected photos: $photos");
                              setState(() {
                                _selectedPhotos = photos;
                                _rebuildOrderedPhotos();
                              });
                              logger.d(
                                  "Updated _selectedPhotos: $_selectedPhotos");
                            },
                            existingPhotos: _existingPhotos,
                            onDeleteExistingPhoto: _deleteExistingPhoto,
                            onMakePhotoPrimary: _makePhotoPrimary,
                            onMakeNewPhotoPrimary: _makeNewPhotoPrimary,
                            deletingPhotoIds: _deletingPhotoIds,
                            makingPhotoPrimaryIds: _makingPhotoPrimaryIds,
                            orderedItems: _orderedPhotos,
                            onReorderItems: (newOrder) {
                              setState(() {
                                _orderedPhotos = newOrder;
                                _photoOrderDirty = true;
                              });
                            },
                            isRequired: false,
                          ),

                        ValueListenableBuilder<bool>(
                          valueListenable:
                              ClientLidarRoomScanConfig.lidarRoomScanDisabled,
                          builder: (context, lidarDisabled, _) {
                            return FutureBuilder<bool>(
                              future: RoomPlanCapability.isSupportedOnDevice(),
                              builder: (context, snap) {
                                // For testing: show this on Chrome/Web and on iOS
                                // only when RoomPlan / LiDAR is available.
                                final canShowOnThisDevice =
                                    (isIOSDevice && snap.data == true) ||
                                        kIsWeb;
                                if (!canShowOnThisDevice ||
                                    (lidarDisabled && !kIsWeb) ||
                                    _selectedListingTypeId == 1) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildNeumorphicRoomScanButton(),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 26),

                        Builder(
                          builder: (context) {
                            final label =
                                Theme.of(context).textTheme.labelLarge;
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

    final usesMetroSearch = _supportsMultiSearch &&
        _locationSearchMode == _LocationSearchMode.metro;
    final usesDistrictSearch = _supportsMultiSearch &&
        _locationSearchMode == _LocationSearchMode.district;

    // Validate location/search area (mandatory)
    final missingLocation = usesMetroSearch
        ? _selectedSearchStations.isEmpty
        : usesDistrictSearch
            ? _selectedSearchLocations.isEmpty
            : _selectedLocationIndex < 0;
    if (missingLocation) {
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

    if (_priceForUpdateRequest() < 1) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_price_minimum"),
      );
      return;
    }

    // Metro line and station are now optional - no validation required

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the selected location and station (if available)
      final selectedLocation = usesDistrictSearch
          ? _selectedSearchLocations.first
          : !_supportsMultiSearch
              ? _currentLocations[_selectedLocationIndex]
              : null;
      final selectedStation = usesMetroSearch
          ? _selectedSearchStations.first
          : _selectedSubwayLine > 0 &&
                  _currentStations.isNotEmpty &&
                  _selectedStationIndex >= 0 &&
                  _selectedStationIndex < _currentStations.length
              ? _currentStations[_selectedStationIndex]
              : null;
      final multiStationIds = _supportsMultiSearch
          ? (usesMetroSearch
              ? _selectedSearchStations.map((station) => station.id).toList()
              : <int>[])
          : null;
      final multiLocationIds = _supportsMultiSearch
          ? (usesDistrictSearch
              ? _selectedSearchLocations.map((location) => location.id).toList()
              : <int>[])
          : null;
      final effectiveSubwayLineId = usesMetroSearch
          ? selectedStation!.line
          : usesDistrictSearch
              ? null
              : (_selectedSubwayLine > 0 ? _selectedSubwayLine : null);

      // Determine listing type ID based on selection
      final listingTypeId = _selectedListingTypeId;

      // Update listing using the service
      final listingService = getIt<IListingService>();

      // First, update the listing details (without photos)
      final priceBounds = _priceBoundsForUpdateRequest();
      await listingService.updateListing(
        listingId: widget.listingDetail.id,
        title: _titleController.text.trim(),
        listingTypeId: listingTypeId,
        price: _priceForUpdateRequest(),
        minPrice: priceBounds.min,
        maxPrice: priceBounds.max,
        description: _descriptionController.text.trim(),
        gender: _selectedGender,
        locationId: selectedLocation?.id,
        locationIds: multiLocationIds,
        amenityIds: _selectedAmenityIds.toList(),
        subwayStationId: selectedStation?.id, // Made optional, moved to end
        subwayStationIds: multiStationIds,
        subwayLineId: effectiveSubwayLineId, // Add subway line ID
        moveInDate: _moveInDateValue.isNotEmpty
            ? _moveInDateValue
            : null, // Add move-in date
        privateRoom: _isGroupFormingFlow ? false : _isPrivateRoom,
        photoPaths: null, // Don"t upload photos during listing update
        groupSizeTarget: _isGroupFormingFlow ? _groupSizeTarget : null,
      );

      // Then, upload new photos separately if any were selected.
      // After uploading we collect the server IDs so we can persist the
      // user's chosen display order (existing + newly uploaded).
      final List<int> newPhotoIds = [];
      if (_selectedPhotos.isNotEmpty) {
        try {
          logger.d("=== UPLOADING NEW PHOTOS FOR UPDATED LISTING ===");
          logger.d("New photo count: ${_selectedPhotos.length}");
          logger.d("New photo paths: $_selectedPhotos");
          logger.d("Existing photos count: ${_existingPhotos.length}");

          // isPrimary on upload doesn't matter when we follow up with a
          // reorder call — the reorder makes `is_primary` match index 0 of
          // the final order. Pass `false` to avoid unnecessary toggling.
          final isPrimaryFlags =
              List<bool>.filled(_selectedPhotos.length, false);

          final ids = await listingService.uploadListingPhotos(
            listingId: widget.listingDetail.id,
            photoPaths: _selectedPhotos,
            isPrimaryFlags: isPrimaryFlags,
          );
          newPhotoIds.addAll(ids);

          logger.d("✅ All new photos uploaded successfully (ids: $ids)");
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

      // Persist the display order (existing + new) if the user reordered, or
      // if there are new photos (so any reorder intent between existing and
      // new is captured). We skip when only existing photos remain and the
      // order is untouched — the server is already in that state.
      final shouldPersistOrder = _photoOrderDirty ||
          (newPhotoIds.isNotEmpty && _orderedPhotos.isNotEmpty);
      if (shouldPersistOrder) {
        try {
          final pathToNewId = <String, int>{};
          for (var i = 0;
              i < _selectedPhotos.length && i < newPhotoIds.length;
              i++) {
            if (newPhotoIds[i] > 0) {
              pathToNewId[_selectedPhotos[i]] = newPhotoIds[i];
            }
          }
          final orderedIds = <int>[];
          for (final item in _orderedPhotos) {
            if (item is ExistingPhotoItem) {
              orderedIds.add(item.photo.id);
            } else if (item is NewPhotoItem) {
              final id = pathToNewId[item.path];
              if (id != null) orderedIds.add(id);
            }
          }
          if (orderedIds.isNotEmpty) {
            await listingService.reorderPhotos(
              listingId: widget.listingDetail.id,
              photoIds: orderedIds,
            );
            logger.d("✅ Photo order persisted: $orderedIds");
          }
        } catch (reorderError) {
          logger.d("⚠️ Warning: Failed to persist photo order: $reorderError");
          // The photos themselves are saved; only the order/primary failed.
          // Surface it so a silent failure here (e.g. an auth/permission
          // error on the reorder endpoint) is visible instead of looking like
          // "the main photo just didn't change".
          if (mounted) {
            ToastTheme.showWarning(
              context,
              message: L10n.get(
                "error_reordering_photos",
                fallback: "Couldn't update the main photo. Please try again.",
              ),
            );
          }
        }
      }

      // Show success message
      final changedFields = _computeChangedFieldLabels(
        baseline: widget.listingDetail,
        currentLocationId: selectedLocation?.id,
        currentSubwayStationId: selectedStation?.id,
        currentSubwayLineId: effectiveSubwayLineId,
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
      _photoOrderDirty = false;
      // _rebuildOrderedPhotos() will happen on next setState; we're about to
      // pop, so no visible rebuild is necessary.

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
  /// spinner while a save is in progress). When the form is clean, no
  /// trailing action is shown (the parent gates this widget on dirty/submitting).
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

    return _PulsingSaveButton(
      onPressed: () {
        HapticFeedbackUtils.impact();
        _submitForm();
      },
      tooltip: L10n.get("save_changes"),
    );
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
          _rebuildOrderedPhotos();
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
    );
    _opacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  void _syncPulse() {
    final enabled = UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    if (enabled) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
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

/// Continuously rotates [child] to match the room-scan icon behavior used on
/// the listing detail screen (`_Room3dTile`).
///
/// The ticker only runs while this widget is mounted, so it stops as soon as
/// the user leaves the edit-listing screen.
class _RoomScanIconRotator extends StatefulWidget {
  const _RoomScanIconRotator({required this.child});

  final Widget child;

  @override
  State<_RoomScanIconRotator> createState() => _RoomScanIconRotatorState();
}

class _RoomScanIconRotatorState extends State<_RoomScanIconRotator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRotation();
  }

  void _syncRotation() {
    final enabled = UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    if (enabled) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: widget.child,
    );
  }
}
