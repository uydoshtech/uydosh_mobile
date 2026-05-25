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
    final station = _currentStations[_selectedStationIndex];
    if (station.line != _selectedSubwayLine) {
      return null;
    }
    return station;
  }

  void _loadStationsForLine(int line) {
    if (line == _selectedSubwayLine &&
        _currentStations.isNotEmpty &&
        !_isLoadingStations) {
      return;
    }
    setState(() {
      _selectedSubwayLine = line;
      _selectedStationIndex = 0;
      _currentStations = [];
      _isLoadingStations = true;
    });
    context.read<SubwayStationsBloc>().add(
          SubwayStationsEvent.fetchSubwayStationsByLine(line: line),
        );
  }

  void _onStationsLoaded(List<SubwayStation> stations) {
    if (_selectedSubwayLine <= 0) {
      return;
    }
    if (stations.isNotEmpty &&
        stations.any((station) => station.line != _selectedSubwayLine)) {
      return;
    }

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
    if (pendingLoc != null && _selectedSubwayLine > 0) {
      final idx = sorted.indexWhere((l) => l.id == pendingLoc);
      if (idx >= 0) locationIndex = idx;
      _pendingLocationId = null;
    } else if (pendingLoc != null) {
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

  /// Metro line/station only — used under the "Metro station" collapsible title.
  String? _buildCollapsedMetroSummary() {
    final station = _resolvedSubwayStation();
    if (station != null) {
      return MetroCache.formatStationLabel(
        _localizedName(
          nameUz: station.nameUz,
          nameRu: station.nameRu,
          nameEn: station.nameEn,
        ),
        L10n.currentLanguage,
      );
    }
    if (_selectedSubwayLine > 0) {
      return MetroCache.getLineLabel(
        _selectedSubwayLine,
        L10n.currentLanguage,
      );
    }
    return null;
  }

  void _resetLocationSpinner() {
    setState(() {
      _selectedLocationIndex = -1;
      _pendingLocationId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _locationScrollController;
      if (controller == null || !controller.hasClients) return;
      if (controller.selectedItem != 0) {
        controller.jumpToItem(0);
      }
    });
  }

  void _clearMetroSelection() {
    setState(() {
      _selectedSubwayLine = 0;
      _currentStations = [];
      _selectedStationIndex = 0;
      _isLoadingStations = false;
      _pendingSubwayStationId = null;
      _pendingSubwayLineId = null;
    });
    _resetLocationSpinner();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lineCtrl = _metroLineScrollController;
      if (lineCtrl != null && lineCtrl.hasClients && lineCtrl.selectedItem != 0) {
        lineCtrl.jumpToItem(0);
      }
      final stationCtrl = _metroStationScrollController;
      if (stationCtrl != null &&
          stationCtrl.hasClients &&
          stationCtrl.selectedItem != 0) {
        stationCtrl.jumpToItem(0);
      }
    });
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
    final summary = _buildCollapsedMetroSummary();
    final titleColor = ThemeState().isLightTheme
        ? Colors.black
        : scheme.onSurfaceVariant;
    final subtitleColor = scheme.onSurfaceVariant.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.75 : 0.85,
    );

    return InkWell(
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
    );
  }

  Widget _buildCollapsibleTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dividerColor = scheme.onSurfaceVariant.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.14,
    );

    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      dirtyOutlineColor: widget.locationDirtyOutlineColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCollapsibleHeader(context),
          if (_expanded) ...[
            Divider(height: 1, thickness: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: _buildGeoPickers(context, embeddedInPlate: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeoPickers(
    BuildContext context, {
    bool embeddedInPlate = false,
  }) {
    final sectionGap = embeddedInPlate ? 10.0 : 14.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListingFormMetroSection(
          embeddedInPlate: embeddedInPlate,
          selectedSubwayLine: _selectedSubwayLine,
          selectedStationIndex: _selectedStationIndex,
          currentStations: _currentStations,
          isLoadingStations: _isLoadingStations,
          metroLineScrollController: _metroLineScrollController,
          metroStationScrollController: _metroStationScrollController,
          onLineChanged: (index) {
            if (index == _selectedSubwayLine) {
              _notifyParent();
              return;
            }
            if (index > 0) {
              _loadStationsForLine(index);
            } else {
              _clearMetroSelection();
            }
            _notifyParent();
          },
          onStationChanged: (index) {
            if (index == _selectedStationIndex) {
              _notifyParent();
              return;
            }
            setState(() => _selectedStationIndex = index);
            _syncLocationWithStation();
            _notifyParent();
          },
          onDismissKeyboard: () => FocusScope.of(context).unfocus(),
        ),
        SizedBox(height: sectionGap),
        _buildLocationPicker(context, embeddedInPlate: embeddedInPlate),
      ],
    );
  }

  Widget _buildLocationPicker(
    BuildContext context, {
    bool embeddedInPlate = false,
  }) {
    final metroLineSelected = _selectedSubwayLine > 0;
    final picker = LocationPicker(
      embeddedInPlate: embeddedInPlate,
      readOnly: !metroLineSelected,
      locations: _currentLocations,
      selectedLocationIndex: _selectedLocationIndex,
      scrollController: _locationScrollController,
      placeholderText: metroLineSelected
          ? null
          : L10n.get("select_metro_line_title"),
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
    if (embeddedInPlate || widget.locationDirtyOutlineColor == null) {
      return picker;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ThreeDSurfaceStyle.wheelPickerCornerRadius,
        ),
        border: Border.all(
          color: widget.locationDirtyOutlineColor!,
          width: 1.5,
        ),
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
          ? _buildCollapsibleTile(context)
          : _buildGeoPickers(context),
    );
  }
}
