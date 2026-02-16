import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class _MapData {
  const _MapData({
    required this.stationLabels,
    required this.mapSvg,
  });

  final List<_StationLabel> stationLabels;
  final String mapSvg;
}

class _StationLabel {
  const _StationLabel({
    required this.stationId,
    required this.label,
    required this.x,
    required this.y,
  });

  final int stationId;
  final String label;
  final double x;
  final double y;
}

class AdminSubwayMapScreen extends StatefulWidget {
  const AdminSubwayMapScreen({super.key});

  @override
  State<AdminSubwayMapScreen> createState() => _AdminSubwayMapScreenState();
}

class _AdminSubwayMapScreenState extends State<AdminSubwayMapScreen> {
  Key _mapKey = UniqueKey();
  late final TransformationController _transformationController;
  double _zoomLevel = 1.3;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController(
      Matrix4.identity()
        ..translate(_initialMapShiftX, _initialMapShiftY)
        ..scale(1.3),
    );
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (_zoomLevel != scale) {
      setState(() {
        _zoomLevel = scale;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  static const double _svgWidth = 640;
  static const double _svgHeight = 1200;
  static const double _viewBoxMinX = -80;
  static const Offset _mapOffset = Offset(40, 80);
  static const double _tapTargetWidth = 140;
  static const double _tapTargetHeight = 26;
  static const double _initialMapShiftX = -20;
  static const double _initialMapShiftY = -50;

  static const String _svgAssetPath =
      "assets/map_elements/tashkent_metro_map.svg";

  static Future<_MapData>? _mapDataFuture;

  static Future<_MapData> _loadMapData() {
    _mapDataFuture ??=
        rootBundle
            .loadString(_svgAssetPath)
            .then(
              (rawSvg) => _MapData(
                stationLabels: _extractStationLabels(rawSvg),
                mapSvg: _processSvg(rawSvg),
              ),
            );
    return _mapDataFuture!;
  }

  static List<_StationLabel> _extractStationLabels(String svg) {
    final labels = <_StationLabel>[];
    final usedStationIds = <int>{};
    final switchRegExp = RegExp(
      r'<switch[^>]*transform="translate\(([-\d.]+),([-\d.]+)\)"[^>]*>([\s\S]*?)</switch>',
    );
    final tspanRegExp = RegExp("<tspan[^>]*>([^<]+)</tspan>");

    for (final match in switchRegExp.allMatches(svg)) {
      final x = double.tryParse(match.group(1) ?? "");
      final y = double.tryParse(match.group(2) ?? "");
      final content = match.group(3) ?? "";
      if (x == null || y == null) continue;

      final tspanMatch = tspanRegExp.firstMatch(content);
      final label = tspanMatch?.group(1)?.trim();
      if (label == null || label.isEmpty) continue;

      final station = _findStationByLabel(label);
      if (station == null) continue;
      if (!usedStationIds.add(station.id)) continue;

      labels.add(
        _StationLabel(
          stationId: station.id,
          label: label,
          x: x,
          y: y,
        ),
      );
    }

    return labels;
  }

  static SubwayStation? _findStationByLabel(String label) {
    final matches = MetroCache.getStationsByName(label);
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;

    final normalizedLabel = _normalizeStationLabel(label);
    for (final station in matches) {
      for (final name in _stationNames(station)) {
        if (_normalizeStationLabel(name) == normalizedLabel) {
          return station;
        }
      }
    }

    return matches.first;
  }

  static Iterable<String> _stationNames(SubwayStation station) sync* {
    if (station.nameUz != null) yield station.nameUz!;
    if (station.nameRu != null) yield station.nameRu!;
    if (station.nameEn != null) yield station.nameEn!;
  }

  static String _normalizeStationLabel(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp("[’ʻ'`.]"), "")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  void _openStationListings(BuildContext context, int stationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (context) => ListingsBloc(getIt<IListingService>()),
              child: HomeScreen(
                subwayStationId: stationId,
                isSearchMode: true,
              ),
            ),
      ),
    );
  }

  static const double _bazaarChorsuMapX = 110;
  static const double _bazaarChorsuMapY = 205;
  static const double _bazaarChorsuWidth = 50;
  static const double _bazaarChorsuHeight = 18;

  static const double _tvTowerMapX = 240;
  static const double _tvTowerMapY = 120;
  static const double _tvTowerWidth = 56;
  static const double _tvTowerHeight = 60;

  static const double _monumentMapX = 170;
  static const double _monumentMapY = 330;
  static const double _monumentWidth = 20;
  static const double _monumentHeight = 20;

  static const double _airportMapX = 200;
  static const double _airportMapY = 625;
  static const double _airportWidth = 50;
  static const double _airportHeight = 27;

  static const double _cityParkMapX = 10;
  static const double _cityParkMapY = 335;
  static const double _cityParkWidth = 25;
  static const double _cityParkHeight = 40;

  static const double _busHubMapX = 15;
  static const double _busHubMapY = 580;
  static const double _busHubWidth = 22;
  static const double _busHubHeight = 22;

  static const double _circusMapX = 10;
  static const double _circusMapY = 240;
  static const double _circusWidth = 30;
  static const double _circusHeight = 30;

  List<Widget> _buildMapOverlays(
    double scale,
    double offsetX,
    double offsetY, {
    required bool isBlueTheme,
  }) {
    final bazaarX =
        offsetX + (_mapOffset.dx + _bazaarChorsuMapX - _viewBoxMinX) * scale;
    final bazaarY =
        offsetY + (_mapOffset.dy + _bazaarChorsuMapY) * scale;
    final tvTowerX =
        offsetX + (_mapOffset.dx + _tvTowerMapX - _viewBoxMinX) * scale;
    final tvTowerY =
        offsetY + (_mapOffset.dy + _tvTowerMapY) * scale;
    final monumentX =
        offsetX + (_mapOffset.dx + _monumentMapX - _viewBoxMinX) * scale;
    final monumentY =
        offsetY + (_mapOffset.dy + _monumentMapY) * scale;
    final airportX =
        offsetX + (_mapOffset.dx + _airportMapX - _viewBoxMinX) * scale;
    final airportY =
        offsetY + (_mapOffset.dy + _airportMapY) * scale;
    final cityParkX =
        offsetX + (_mapOffset.dx + _cityParkMapX - _viewBoxMinX) * scale;
    final cityParkY =
        offsetY + (_mapOffset.dy + _cityParkMapY) * scale;
    final busHubX =
        offsetX + (_mapOffset.dx + _busHubMapX - _viewBoxMinX) * scale;
    final busHubY =
        offsetY + (_mapOffset.dy + _busHubMapY) * scale;
    final circusX =
        offsetX + (_mapOffset.dx + _circusMapX - _viewBoxMinX) * scale;
    final circusY =
        offsetY + (_mapOffset.dy + _circusMapY) * scale;
    return [
      Positioned(
        left: bazaarX - _bazaarChorsuWidth / 2,
        top: bazaarY - _bazaarChorsuHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/bazaar_chorsu.svg",
          width: _bazaarChorsuWidth * 2,
          height: _bazaarChorsuHeight * 2,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: tvTowerX - _tvTowerWidth / 2,
        top: tvTowerY - _tvTowerHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/tv_tower.svg",
          width: _tvTowerWidth,
          height: _tvTowerHeight,
          fit: BoxFit.contain,
          colorFilter: isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
      Positioned(
        left: monumentX - _monumentWidth / 2,
        top: monumentY - _monumentHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/monument2.svg",
          width: _monumentWidth * 2,
          height: _monumentHeight * 2,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: airportX - _airportWidth / 2,
        top: airportY - _airportHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/airport.svg",
          width: _airportWidth,
          height: _airportHeight,
          fit: BoxFit.contain,
          colorFilter: isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
      Positioned(
        left: cityParkX - _cityParkWidth / 2,
        top: cityParkY - _cityParkHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/city_park.svg",
          width: _cityParkWidth,
          height: _cityParkHeight,
          fit: BoxFit.contain,
          colorFilter: isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
      Positioned(
        left: busHubX - _busHubWidth / 2,
        top: busHubY - _busHubHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/bus_hub.svg",
          width: _busHubWidth,
          height: _busHubHeight,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: circusX - _circusWidth / 2,
        top: circusY - _circusHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/circus.svg",
          width: _circusWidth,
          height: _circusHeight,
          fit: BoxFit.contain,
          colorFilter: isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildStationTapTargets(
    BuildContext context,
    List<_StationLabel> stationLabels,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    return stationLabels.map((label) {
      final posX = offsetX + (_mapOffset.dx + label.x - _viewBoxMinX) * scale;
      final posY = offsetY + (_mapOffset.dy + label.y) * scale;
      return Positioned(
        left: posX - _tapTargetWidth / 2,
        top: posY - _tapTargetHeight / 2,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openStationListings(context, label.stationId),
          child: const SizedBox(
            width: _tapTargetWidth,
            height: _tapTargetHeight,
          ),
        ),
      );
    }).toList();
  }

  static String _processSvg(String svg) {
    final withoutStyle = svg.replaceAll(
      RegExp(r"<style[\s\S]*?</style>"),
      "",
    );
    final withoutTitleGroup = withoutStyle
        .replaceAll(
          '<g id="title_group"',
          '<g id="title_group" style="display:none"',
        )
        .replaceAll(
          '<g id="linebox_group"',
          '<g id="linebox_group" style="display:none"',
        )
        .replaceAll(
          '<g id="route_terminus_num_group"',
          '<g id="route_terminus_num_group" style="display:none"',
        )
        .replaceAll(
          '<g id="ic_num_group"',
          '<g id="ic_num_group" style="display:none"',
        )
        .replaceAll(
          '<rect id="background_color_rectangle"',
          '<rect id="background_color_rectangle" style="display:none"',
        );
    final flattenedSwitches = withoutTitleGroup.replaceAllMapped(
      RegExp(r"<switch([^>]*)>([\s\S]*?)</switch>"),
      (match) {
        final attributes = match.group(1) ?? "";
        final content = match.group(2) ?? "";
        final firstText = RegExp(r"<text[\s\S]*?</text>").firstMatch(content);
        final textValue = firstText?.group(0);
        if (textValue == null) return "";

        final transformMatch =
            RegExp('transform="[^"]+"').firstMatch(attributes);
        if (transformMatch == null) return textValue;

        return "<g ${transformMatch.group(0)}>$textValue</g>";
      },
    );
    return flattenedSwitches
        .replaceAll(
          'class="st"',
          'style="font-family:Arial,sans-serif;font-size:13px"',
        )
        .replaceAll('class="mid"', 'style="text-anchor:middle"')
        .replaceAll('class="end"', 'style="text-anchor:end"')
        .replaceAll('class="ic"', 'style="font-weight:bold"')
        .replaceAll(
          '<g id="route1_stname">',
          '<g id="route1_stname" style="fill:#D60000">',
        )
        .replaceAll(
          '<g id="route2_stname">',
          '<g id="route2_stname" style="fill:#0300EE">',
        )
        .replaceAll(
          '<g id="route3_stname">',
          '<g id="route3_stname" style="fill:#009900">',
        )
        .replaceAll(
          '<g id="route4_stname">',
          '<g id="route4_stname" style="fill:#F59E0B">',
        )
        .replaceAll('class="mebg"', 'style="fill:none;stroke:#fff;stroke-width:7"')
        .replaceAll(
          'class="me p1"',
          'style="fill:none;stroke:#D60000;stroke-width:5"',
        )
        .replaceAll(
          'class="me p2"',
          'style="fill:none;stroke:#0300EE;stroke-width:5"',
        )
        .replaceAll(
          'class="me p3"',
          'style="fill:none;stroke:#009900;stroke-width:5"',
        )
        .replaceAll(
          'class="me p4"',
          'style="fill:none;stroke:#F59E0B;stroke-width:5"',
        )
        .replaceAll('class="p1"', 'style="stroke:#D60000"')
        .replaceAll('class="p2"', 'style="stroke:#0300EE"')
        .replaceAll('class="p3"', 'style="stroke:#009900"')
        .replaceAll('class="p4"', 'style="stroke:#F59E0B"')
        .replaceAll('class="f1"', 'style="fill:#D60000"')
        .replaceAll('class="f2"', 'style="fill:#0300EE"')
        .replaceAll('class="f3"', 'style="fill:#009900"')
        .replaceAll('class="f4"', 'style="fill:#F59E0B"')
        .replaceAll('class="r1"', 'style="fill:#D60000"')
        .replaceAll('class="r2"', 'style="fill:#0300EE"')
        .replaceAll('class="r3"', 'style="fill:#009900"')
        .replaceAll('class="r4"', 'style="fill:#F59E0B"')
        .replaceAll(
          'class="intb"',
          'style="fill:none;stroke:#000;stroke-width:9;stroke-linecap:round;stroke-linejoin:round"',
        )
        .replaceAll(
          'class="intf"',
          'style="fill:none;stroke:#fff;stroke-width:7;stroke-linecap:round;stroke-linejoin:round"',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "admin_subway_map_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "${(_zoomLevel * 100).round()}%",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _mapKey = UniqueKey();
                _transformationController.value = Matrix4.identity()
                  ..translate(_initialMapShiftX, _initialMapShiftY)
                  ..scale(1.3);
              });
            },
            tooltip: "Refresh map icons",
          ),
        ],
      ),
      body: FutureBuilder<_MapData>(
        future: _loadMapData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final mapData = snapshot.data!;
          return ListenableBuilder(
            listenable: Listenable.merge([LanguageState(), ThemeState()]),
            builder: (context, child) {
              return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final mapWidth = constraints.maxWidth;
                        final mapHeight = constraints.maxHeight;
                        final scale = math.min(
                          mapWidth / _svgWidth,
                          mapHeight / _svgHeight,
                        );
                        final contentWidth = _svgWidth * scale;
                        final contentHeight = _svgHeight * scale;
                        final offsetX = (mapWidth - contentWidth) / 2;
                        final offsetY = (mapHeight - contentHeight) / 2;
                        return InteractiveViewer(
                          constrained: false,
                          minScale: 0.6,
                          maxScale: 8.0,
                          boundaryMargin: const EdgeInsets.all(40),
                          transformationController: _transformationController,
                          child: SizedBox(
                            key: _mapKey,
                            width: mapWidth,
                            height: mapHeight,
                            child: Stack(
                              children: [
                                SvgPicture.string(
                                  mapData.mapSvg,
                                  width: mapWidth,
                                  height: mapHeight,
                                  fit: BoxFit.contain,
                                  semanticsLabel: "Tashkent subway map",
                                ),
                                ..._buildMapOverlays(
                                  scale,
                                  offsetX,
                                  offsetY,
                                  isBlueTheme: ThemeState().isBlueTheme,
                                ),
                                ..._buildStationTapTargets(
                                  context,
                                  mapData.stationLabels,
                                  scale,
                                  offsetX,
                                  offsetY,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
        },
      ),
    );
  }
}
