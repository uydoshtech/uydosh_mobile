import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/listing_form_metro_section.dart";
import "package:uy_dosh/presentation/widgets/common/location_picker.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

/// Optional district + metro pickers for gig publish (task and service).
class GigPublishGeoSection extends StatefulWidget {
  const GigPublishGeoSection({
    required this.onGeoChanged,
    this.initialLocationId,
    this.initialSubwayStationId,
    this.initialSubwayLineId,
    this.locationDirtyOutlineColor,
    this.collapsible = false,
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
  final bool collapsible;

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
  bool _expanded = false;

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

  String _localizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final lang = L10n.currentLanguage;
    switch (lang) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "";
    }
  }

  String? _locationDisplayName(Location location) {
    final lang = L10n.currentLanguage;
    switch (lang) {
      case "uz":
        return location.shortNameUz ??
            location.shortNameRu ??
            location.shortNameEn;
      case "en":
        return location.shortNameEn ??
            location.shortNameRu ??
            location.shortNameUz;
      default:
        return location.shortNameRu ??
            location.shortNameUz ??
            location.shortNameEn;
    }
  }

  String? _buildCollapsedSummary() {
    final parts = <String>[];

    final station = _resolvedSubwayStation();
    if (station != null) {
      parts.add(
        _localizedName(
          nameUz: station.nameUz,
          nameRu: station.nameRu,
          nameEn: station.nameEn,
        ),
      );
    } else if (_selectedSubwayLine > 0) {
      parts.add(
        MetroCache.getLineName(_selectedSubwayLine, L10n.currentLanguage),
      );
    }

    final locationId = _resolvedLocationId();
    if (locationId != null && _currentLocations.isNotEmpty) {
      final idx = _currentLocations.indexWhere((l) => l.id == locationId);
      if (idx >= 0) {
        final name = _locationDisplayName(_currentLocations[idx]);
        if (name != null && name.isNotEmpty) {
          parts.add(name);
        }
      }
    }

    if (parts.isEmpty) return null;
    return parts.join(" · ");
  }

  Color _metroHeaderIconColor() {
    final station = _resolvedSubwayStation();
    if (station != null) {
      return AppColors.getMetroLineColor(station.line);
    }
    if (_selectedSubwayLine > 0) {
      return AppColors.getMetroLineColor(_selectedSubwayLine);
    }
    return Colors.black;
  }

  Widget _buildCollapsibleHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = _buildCollapsedSummary();
    final titleColor = ThemeState().isLightTheme
        ? Colors.black
        : scheme.onSurfaceVariant;
    final subtitleColor = scheme.onSurfaceVariant.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.75 : 0.85,
    );

    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      dirtyOutlineColor: widget.locationDirtyOutlineColor,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              MLetterIcon(color: _metroHeaderIconColor(), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.get("metro_station_label"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    if (summary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        summary,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: ThemeIcon(
                  Icons.keyboard_arrow_down,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeoPickers(BuildContext context) {
    return Column(
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
    );
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
      child: widget.collapsible
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCollapsibleHeader(context),
                if (_expanded) ...[
                  const SizedBox(height: 14),
                  _buildGeoPickers(context),
                ],
              ],
            )
          : _buildGeoPickers(context),
    );
  }
}
