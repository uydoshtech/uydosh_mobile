import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Optional district + metro pickers for gig publish (task and service).
class GigPublishGeoSection extends StatefulWidget {
  const GigPublishGeoSection({
    required this.onGeoChanged,
    this.initialLocationId,
    this.initialSubwayStationId,
    this.initialSubwayLineId,
    this.locationDirtyOutlineColor,
    super.key,
  });

  final void Function({
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
  }) onGeoChanged;

  final int? initialLocationId;
  final int? initialSubwayStationId;
  final int? initialSubwayLineId;
  final Color? locationDirtyOutlineColor;

  @override
  State<GigPublishGeoSection> createState() => _GigPublishGeoSectionState();
}

class _GigPublishGeoSectionState extends State<GigPublishGeoSection> {
  FixedExtentScrollController? _locationScrollController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _metroStationScrollController;

  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedLocationIndex = -1;
  List<SubwayStation> _currentStations = [];
  List<Location> _currentLocations = [];
  bool _isLoadingStations = false;
  bool _isLoadingLocations = false;

  int? _pendingSubwayStationId;
  int? _pendingSubwayLineId;
  int? _pendingLocationId;

  @override
  void initState() {
    super.initState();
    _pendingLocationId = widget.initialLocationId;
    _pendingSubwayStationId = widget.initialSubwayStationId;
    _pendingSubwayLineId = widget.initialSubwayLineId;
    _selectedSubwayLine = _resolveInitialSubwayLine();

    _locationScrollController = FixedExtentScrollController(initialItem: 0);
    _metroLineScrollController = FixedExtentScrollController(
      initialItem: _selectedSubwayLine,
    );
    _metroStationScrollController = FixedExtentScrollController(
      initialItem: _selectedStationIndex,
    );

    _bootstrapLocationsFromCache();
    _bootstrapMetroFromPending();
  }

  int _resolveInitialSubwayLine() {
    final stationId = _pendingSubwayStationId;
    if (stationId != null) {
      final station = MetroCache.getStationById(stationId);
      if (station != null) return station.line;
    }
    final lineId = _pendingSubwayLineId;
    if (lineId != null && lineId > 0) return lineId;
    return 0;
  }

  void _bootstrapLocationsFromCache() {
    _applyLocations(LocationCache.getAllLocations(), notifyParent: false);
  }

  void _bootstrapMetroFromPending() {
    if (_selectedSubwayLine > 0) {
      _loadStationsForLine(_selectedSubwayLine);
    }
  }

  @override
  void dispose() {
    _locationScrollController?.dispose();
    _metroLineScrollController?.dispose();
    _metroStationScrollController?.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final locationId = _resolvedLocationId();
    final station = _resolvedSubwayStation();
    widget.onGeoChanged(
      locationId: locationId,
      subwayStationId: station?.id,
      subwayLineId: station != null
          ? station.line
          : (_selectedSubwayLine > 0 ? _selectedSubwayLine : null),
    );
  }

  int? _resolvedLocationId() {
    if (_selectedLocationIndex < 0 ||
        _selectedLocationIndex >= _currentLocations.length) {
      return null;
    }
    return _currentLocations[_selectedLocationIndex].id;
  }

  SubwayStation? _resolvedSubwayStation() {
    if (_selectedSubwayLine <= 0 ||
        _currentStations.isEmpty ||
        _selectedStationIndex < 0 ||
        _selectedStationIndex >= _currentStations.length) {
      return null;
    }
    return _currentStations[_selectedStationIndex];
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

  void _onStationsLoaded(List<SubwayStation> stations) {
    var stationIndex = 0;
    final pendingId = _pendingSubwayStationId;
    if (pendingId != null) {
      final idx = stations.indexWhere((s) => s.id == pendingId);
      if (idx >= 0) stationIndex = idx;
      _pendingSubwayStationId = null;
    }
    setState(() {
      _currentStations = stations;
      _selectedStationIndex = stationIndex;
      _isLoadingStations = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _metroStationScrollController?.animateToItem(
        stationIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
    _syncLocationWithStation();
    _notifyParent();
  }

  List<Location> _sortedLocations(List<Location> locations) {
    final sorted = List<Location>.from(locations)
      ..sort((a, b) {
        String name(Location l) {
          final lang = L10n.currentLanguage;
          switch (lang) {
            case "uz":
              return l.shortNameUz ?? l.shortNameRu ?? l.shortNameEn ?? "";
            case "en":
              return l.shortNameEn ?? l.shortNameRu ?? l.shortNameUz ?? "";
            default:
              return l.shortNameRu ?? l.shortNameUz ?? l.shortNameEn ?? "";
          }
        }

        return name(a).compareTo(name(b));
      });
    return sorted;
  }

  void _applyLocations(List<Location> locations, {required bool notifyParent}) {
    final sorted = _sortedLocations(locations);

    var locationIndex = -1;
    final pendingLoc = _pendingLocationId;
    if (pendingLoc != null) {
      final idx = sorted.indexWhere((l) => l.id == pendingLoc);
      if (idx >= 0) locationIndex = idx;
      _pendingLocationId = null;
    }

    setState(() {
      _currentLocations = sorted;
      _selectedLocationIndex = locationIndex;
      _isLoadingLocations = false;
    });

    if (locationIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _locationScrollController?.animateToItem(
          locationIndex + 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    }
    if (notifyParent) {
      _notifyParent();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifyParent();
      });
    }
  }

  void _syncLocationWithStation() {
    final station = _resolvedSubwayStation();
    if (station?.locationId == null || _currentLocations.isEmpty) return;
    final locationIndex = _currentLocations.indexWhere(
      (location) => location.id == station!.locationId,
    );
    if (locationIndex < 0) return;
    setState(() => _selectedLocationIndex = locationIndex);
    _locationScrollController?.animateToItem(
      locationIndex + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _notifyParent();
  }

  Widget _buildLocationPicker(BuildContext context) {
    final picker = LocationPicker(
      locations: _currentLocations,
      selectedLocationIndex: _selectedLocationIndex,
      scrollController: _locationScrollController,
      onLocationChanged: (locationIndex) {
        setState(() => _selectedLocationIndex = locationIndex);
        _notifyParent();
      },
      isLoading: _isLoadingLocations,
      isRequired: false,
      useThemeColors: true,
      useColoredIcons: true,
      showArrows: false,
    );
    final outline = widget.locationDirtyOutlineColor;
    if (outline == null) return picker;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ThreeDSurfaceStyle.wheelPickerCornerRadius,
        ),
        border: Border.all(color: outline, width: 1.5),
      ),
      child: picker,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubwayStationsBloc, SubwayStationsState>(
      listener: (context, state) {
        state.mapOrNull(
          loaded: (s) => _onStationsLoaded(s.stations),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              _notifyParent();
            },
            onStationChanged: (index) {
              setState(() => _selectedStationIndex = index);
              _syncLocationWithStation();
              _notifyParent();
            },
            onDismissKeyboard: () => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 14),
          _buildLocationPicker(context),
        ],
      ),
    );
  }
}
