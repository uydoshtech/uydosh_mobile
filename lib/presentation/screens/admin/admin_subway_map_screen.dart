import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class _MapData {
  const _MapData({
    required this.stationLabels,
    required this.rawSvg,
  });

  final List<_StationLabel> stationLabels;
  final String rawSvg;
}

class _StationLabel {
  const _StationLabel({
    required this.stationId,
    required this.label,
    required this.x,
    required this.y,
    required this.textAnchor,
  });

  final int stationId;
  final String label;
  final double x;
  final double y;
  /// "start" | "middle" | "end" - how (x,y) aligns to the text
  final String textAnchor;
}

/// Configuration for a single map overlay (POI icon).
class _OverlayConfig {
  const _OverlayConfig(
    this.assetName,
    this.mapX,
    this.mapY,
    this.width,
    this.height, {
    this.useColorFilter = false,
    this.sizeScale = 1.0,
  });

  final String assetName;
  final double mapX;
  final double mapY;
  final double width;
  final double height;
  final bool useColorFilter;
  /// Multiplier for displayed width/height (e.g. 2.0 for bazaar_chorsu, monument2)
  final double sizeScale;
}

/// Per-station overrides for tappable area position and size.
/// dx, dy are in SVG coordinates (scaled with map).
/// widthDelta is added to the computed width.
class _TapTargetOverride {
  const _TapTargetOverride({
    required this.dx,
    required this.dy,
    required this.widthDelta,
  });

  const _TapTargetOverride.only({double dx = 0, double dy = 0, double widthDelta = 0})
      : dx = dx,
        dy = dy,
        widthDelta = widthDelta;

  final double dx;
  final double dy;
  final double widthDelta;
}

class AdminSubwayMapScreen extends StatefulWidget {
  const AdminSubwayMapScreen({super.key});

  @override
  State<AdminSubwayMapScreen> createState() => _AdminSubwayMapScreenState();
}

class _AdminSubwayMapScreenState extends State<AdminSubwayMapScreen> {
  Key _mapKey = UniqueKey();
  late final TransformationController _transformationController;
  /// Stations with at least one listing (from API). Empty set before load completes.
  Set<int> _stationIdsWithListings = {};

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController(
      Matrix4.identity()
        ..translate(_initialMapShiftX, _initialMapShiftY)
        ..scale(1.3),
    );
    _loadListingStationIds();
  }

  Future<void> _loadListingStationIds() async {
    try {
      final ids = await getIt<IListingService>().getSubwayStationIdsWithListings(
        createdWithinDays: 30,
      );
      if (!mounted) return;
      setState(() => _stationIdsWithListings = ids.toSet());
    } catch (_) {
      if (!mounted) return;
      setState(() => _stationIdsWithListings = {});
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  static const double _svgWidth = 640;
  static const double _svgHeight = 1200;
  static const double _viewBoxMinX = -80;
  static const Offset _mapOffset = Offset(40, 80);
  /// stname_group in SVG has transform="translate(0,4)"
  static const double _stnameGroupOffsetY = 4.0;
  /// Approximate character width for 13px font (matches SVG station labels)
  static const double _charWidth = 7.0;
  static const double _tapTargetHeight = 16.0;
  /// Shift tap targets left to better align with SVG text
  static const double _tapTargetOffsetX = 15.0;
  /// Extra width for end-anchor text (Cyrillic often wider than estimate)
  static const double _endAnchorWidthExtra = 12.0;
  /// Extra width for start-anchor text
  static const double _startAnchorWidthExtra = 12.0;
  static const double _initialMapShiftX = -20;
  static const double _initialMapShiftY = -50;

  /// Per-station tappable area overrides (stationId -> offset/width adjustments)
  /// Ordered by station ID (1–50). Tune dx, dy, widthDelta per station as needed.
  static const Map<int, _TapTargetOverride> _tapTargetOverrides = {
    // Line 1 – Chilanzar
    1: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Chinor
    2: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Yangikhayot
    3: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Sergeli
    4: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Uzgarish
    5: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Chashtepa
    6: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Almazar
    7: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Chilanzar
    8: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Mirzo Ulugbek
    9: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),   // Novza
    10: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),  // Milliy bog
    11: _TapTargetOverride(dx: 20, dy: -8, widthDelta: 0),  // Xalqlar doʻstligi
    12: _TapTargetOverride(dx: 70, dy: 0, widthDelta: -40),  // Paxtakor
    13: _TapTargetOverride(dx: 20, dy: 0, widthDelta: -70),  // Mustaqil. Maydoni
    14: _TapTargetOverride(dx: 20, dy: -8, widthDelta: -60),  // A. Temur Xiyoboni
    15: _TapTargetOverride(dx: 10, dy: -6, widthDelta: -50),  // Hamid Olimjon
    16: _TapTargetOverride(dx: 20, dy: -6, widthDelta: -20),  // Pushkin
    17: _TapTargetOverride(dx: 20, dy: -8, widthDelta: -60),  // Buyuk Ipak Yoli
    // Line 2 – Oʻzbekiston
    18: _TapTargetOverride(dx: 100, dy: -5, widthDelta: -30),  // Beruniy
    19: _TapTargetOverride(dx: 20, dy: -6, widthDelta: -20),  // Tinchlik
    20: _TapTargetOverride(dx: 20, dy: -6, widthDelta: -20),  // Chorsu
    21: _TapTargetOverride(dx: 20, dy: -7, widthDelta: -50),  // Gafur Gulom
    22: _TapTargetOverride(dx: 120, dy: -10, widthDelta: -70),  // Alisher Navoiy
    23: _TapTargetOverride(dx: 80, dy: -5, widthDelta: -50),  // Oʻzbekiston
    24: _TapTargetOverride(dx: -70, dy: -4, widthDelta: -20),  // Kosmonavtlar
    25: _TapTargetOverride(dx: 20, dy: -6, widthDelta: -20),  // Oybek
    26: _TapTargetOverride(dx: 10, dy: 0, widthDelta: -10),  // Toshkent
    27: _TapTargetOverride(dx: 70, dy: -6, widthDelta: -20),  // Mashinasozlar
    28: _TapTargetOverride(dx: 0, dy: -6, widthDelta: 0),  // Doʻstlik
    // Line 3 – Yunusobod
    29: _TapTargetOverride(dx: 20, dy: -8, widthDelta: -20),  // Mingurik
    30: _TapTargetOverride(dx: 160, dy: 0, widthDelta: -50),  // Yunus Rajabiy
    31: _TapTargetOverride(dx: 130, dy: -8, widthDelta: -70),  // Abdulla Qodiriy
    32: _TapTargetOverride(dx: 15, dy: -6, widthDelta: -20),  // Minor
    33: _TapTargetOverride(dx: 15, dy: -6, widthDelta: -20),  // Bodomzor
    34: _TapTargetOverride(dx: 15, dy: -6, widthDelta: -20),  // Shahriston
    35: _TapTargetOverride(dx: 15, dy: -6, widthDelta: -20),  // Yunusobod
    36: _TapTargetOverride(dx: 15, dy: -6, widthDelta: -20),  // Turkiston
    // Line 4 – Halqa
    37: _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Texnopark
    38:  _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Yashnobod
    39:  _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Tuzel
    40:  _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Olmos
    41:  _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Rohat
    42:  _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Yangiobod
    43:  _TapTargetOverride(dx: 10, dy: -5, widthDelta: 0),  // Quyliuq
    44: _TapTargetOverride(dx: 10, dy: 0, widthDelta: -10),  // Matonat
    45: _TapTargetOverride(dx: 10, dy: 0, widthDelta: -10),  // Qiyot
    46: _TapTargetOverride(dx: -5, dy: 0, widthDelta: -20),  // Tolarik
    47: _TapTargetOverride(dx: -10, dy: 0, widthDelta: -20),  // Xonabod
    48: _TapTargetOverride(dx: -20, dy: 0, widthDelta: -30),  // Quruvchilar
    49: _TapTargetOverride(dx: 20, dy: 0, widthDelta: -20),  // Turon
    50: _TapTargetOverride(dx:20, dy: 0, widthDelta: -20),  // Qipchoq
  };

  static const String _svgAssetPath =
      "assets/map_elements/tashkent_metro_map.svg";

  static const List<_OverlayConfig> _overlayConfigs = [
    _OverlayConfig("bazaar_chorsu.svg", 0, 220, 30, 30, sizeScale: 1.1),
    _OverlayConfig("tv_tower.svg", 240, 120, 56, 60, useColorFilter: true),
    _OverlayConfig("monument2.svg", 200, 340, 20, 20, sizeScale: 2.0),
    _OverlayConfig("airport.svg", 200, 625, 50, 27, useColorFilter: true),
    _OverlayConfig("city_park.svg", 30, 335, 25, 40, useColorFilter: true),
    _OverlayConfig("bus_hub.svg", 25, 580, 22, 22),
    _OverlayConfig("circus.svg", 185, 200, 45, 15, sizeScale: 1.8),
  ];

  static Future<_MapData>? _mapDataFuture;

  static Future<_MapData> _loadMapData() {
    _mapDataFuture ??= () async {
      final rawSvg = await rootBundle.loadString(_svgAssetPath);
      return _MapData(
        stationLabels: _extractStationLabels(rawSvg),
        rawSvg: rawSvg,
      );
    }();
    return _mapDataFuture!;
  }

  /// SVG label variants that don't match MetroCache names directly
  static const Map<String, String> _labelFixups = {
    "Чоштепа": "Чаштепа",
    "Choshtepa": "Chashtepa",
    "Чилонзор": "Чиланзар",
    "Chilonzor": "Chilanzar",
    "Олмазор": "Алмазар",
    "Olmazor": "Almazar",
    "Миллий Бог": "Milliy bog",
    "Миллий Боғ": "Milliy bog",
    "Milliy bogh": "Milliy bog",
    "Milliy bogʻ": "Milliy bog",
    "Буюк Ипак йули": "Buyuk Ipak Yoli",
    "Buyuk ipak yuli": "Buyuk Ipak Yoli",
    "Buyuk ipak yoʻli": "Buyuk Ipak Yoli",
    "Мустакиллик": "Mustaqil. Maydoni",
    "Mustaqilliq Square": "Indep. Square",
    "Mustaqillik maydoni": "Mustaqil. Maydoni",
    "Хонобод": "Xonabod",
    "Honobod": "Xonabod",
    "Xonobod": "Xonabod",
    "Киёт": "Qiyot",
    "Kiyot": "Qiyot",
    "Толарык": "Tolarik",
    "Tolariq": "Tolarik",
  };

  static List<_StationLabel> _extractStationLabels(String svg) {
    final labels = <_StationLabel>[];
    final switchRegExp = RegExp(
      r'<switch[^>]*transform="translate\(([-\d.]+),([-\d.]+)\)"[^>]*>([\s\S]*?)</switch>',
    );
    final tspanRegExp = RegExp("<tspan[^>]*>([^<]+)</tspan>");
    final anchorRegExp = RegExp(r'<g[^>]*class="[^"]*\b(end|mid)\b');

    for (final match in switchRegExp.allMatches(svg)) {
      final x = double.tryParse(match.group(1) ?? "");
      final y = double.tryParse(match.group(2) ?? "");
      final content = match.group(3) ?? "";
      if (x == null || y == null) continue;

      final preceding = match.start > 600
          ? svg.substring(match.start - 600, match.start)
          : svg.substring(0, match.start);
      final anchorMatches = anchorRegExp.allMatches(preceding).toList();
      final anchorMatch = anchorMatches.isEmpty ? null : anchorMatches.last;
      final textAnchor = anchorMatch?.group(1) == "end"
          ? "end"
          : anchorMatch?.group(1) == "mid"
              ? "middle"
              : "start";

      final labelCandidates = tspanRegExp
          .allMatches(content)
          .map((m) => m.group(1)?.trim())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      if (labelCandidates.isEmpty) continue;

      SubwayStation? station;
      String? matchedLabel;
      for (final label in labelCandidates) {
        station = _findStationByLabel(label);
        if (station != null) {
          matchedLabel = label;
          break;
        }
        final fixup = _labelFixups[label];
        if (fixup != null) {
          station = _findStationByLabel(fixup);
          if (station != null) {
            matchedLabel = label;
            break;
          }
        }
        final abbrevMatch = RegExp(r"^[^\s]+\.\s*(.+)$").firstMatch(label);
        if (abbrevMatch != null) {
          station = _findStationByLabel(abbrevMatch.group(1)!.trim());
          if (station != null) {
            matchedLabel = label;
            break;
          }
        }
      }
      if (station == null || matchedLabel == null) continue;

      labels.add(
        _StationLabel(
          stationId: station.id,
          label: matchedLabel,
          x: x,
          y: y,
          textAnchor: textAnchor,
        ),
      );
    }

    return labels;
  }

  /// Resolves [SubwayStation.id] from a `<switch>` inner fragment (same matching as labels).
  static int? _stationIdFromSwitchContent(String content) {
    final tspanRegExp = RegExp("<tspan[^>]*>([^<]+)</tspan>");
    final labelCandidates = tspanRegExp
        .allMatches(content)
        .map((m) => m.group(1)?.trim())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    if (labelCandidates.isEmpty) return null;

    SubwayStation? station;
    for (final label in labelCandidates) {
      station = _findStationByLabel(label);
      if (station != null) return station.id;
      final fixup = _labelFixups[label];
      if (fixup != null) {
        station = _findStationByLabel(fixup);
        if (station != null) return station.id;
      }
      final abbrevMatch = RegExp(r"^[^\s]+\.\s*(.+)$").firstMatch(label);
      if (abbrevMatch != null) {
        station = _findStationByLabel(abbrevMatch.group(1)!.trim());
        if (station != null) return station.id;
      }
    }
    return null;
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
                useExplicitFiltersOnly: true,
              ),
            ),
      ),
    );
  }

  List<Widget> _buildMapOverlays(
    double scale,
    double offsetX,
    double offsetY, {
    required bool isBlueTheme,
  }) {
    return _overlayConfigs.map((c) {
      final screenX =
          offsetX + (_mapOffset.dx + c.mapX - _viewBoxMinX) * scale;
      final screenY = offsetY + (_mapOffset.dy + c.mapY) * scale;
      final w = c.width * c.sizeScale;
      final h = c.height * c.sizeScale;
      return Positioned(
        left: screenX - w / 2,
        top: screenY - h / 2,
        child: SvgPicture.asset(
          "assets/map_elements/${c.assetName}",
          width: w,
          height: h,
          fit: BoxFit.contain,
          colorFilter: c.useColorFilter && isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      );
    }).toList();
  }

  List<Widget> _buildStationTapTargets(
    BuildContext context,
    List<_StationLabel> stationLabels,
    double scale,
    double offsetX,
    double offsetY,
    String language,
  ) {
    return stationLabels.map((label) {
      final override = _tapTargetOverrides[label.stationId];
      var posX = offsetX + (_mapOffset.dx + label.x - _viewBoxMinX) * scale;
      var posY = offsetY +
          (_mapOffset.dy + label.y + _stnameGroupOffsetY) * scale;
      if (override != null) {
        posX += override.dx * scale;
        posY += override.dy * scale;
      }
      final displayName =
          MetroCache.getStationDisplayName(label.stationId, language);
      final tapWidth =
          ((displayName.isNotEmpty ? displayName : label.label).length *
                  _charWidth)
              .clamp(40.0, 120.0);
      final left = label.textAnchor == "end"
          ? posX - tapWidth - _tapTargetOffsetX - _endAnchorWidthExtra
          : label.textAnchor == "middle"
              ? posX - tapWidth / 2
              : posX - _tapTargetOffsetX;
      var width = label.textAnchor == "end"
          ? tapWidth + _tapTargetOffsetX + _endAnchorWidthExtra
          : label.textAnchor == "start"
              ? tapWidth + _startAnchorWidthExtra
              : tapWidth;
      if (override != null && override.widthDelta != 0) {
        width += override.widthDelta;
      }
      return Positioned(
        left: left,
        top: posY - _tapTargetHeight / 2,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openStationListings(context, label.stationId),
            child: SizedBox(
              width: width,
              height: _tapTargetHeight,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Select the text element matching [language] from switch content.
  /// SVG uses systemLanguage="ru", "en", "uz". Falls back to element without systemLanguage.
  static String? _selectTextForLanguage(String switchContent, String language) {
    final textRegExp = RegExp(r"<text([^>]*)>([\s\S]*?)</text>");
    String? langMatch;
    String? fallback;
    for (final m in textRegExp.allMatches(switchContent)) {
      final attrs = m.group(1) ?? "";
      final full = m.group(0) ?? "";
      final sysLang = RegExp('systemLanguage="([^"]+)"').firstMatch(attrs);
      if (sysLang != null && sysLang.group(1) == language) {
        langMatch = full;
        break;
      }
      if (sysLang == null) fallback = full;
    }
    return langMatch ?? fallback ?? textRegExp.firstMatch(switchContent)?.group(0);
  }

  static final Map<String, String> _processedSvgCache = {};

  static String _processSvgCacheKey(String language, Set<int> boldStationIds) {
    final sorted = boldStationIds.toList()..sort();
    return "$language|${sorted.join(",")}";
  }

  static String _processSvg(
    String svg,
    String language,
    Set<int> boldStationIds,
  ) {
    final key = _processSvgCacheKey(language, boldStationIds);
    return _processedSvgCache.putIfAbsent(
      key,
      () => _processSvgImpl(svg, language, boldStationIds),
    );
  }

  static String _processSvgImpl(
    String svg,
    String language,
    Set<int> boldStationIds,
  ) {
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
        final textValue = _selectTextForLanguage(content, language);
        if (textValue == null) return "";

        final transformMatch =
            RegExp('transform="[^"]+"').firstMatch(attributes);
        if (transformMatch == null) return textValue;

        final stationId = _stationIdFromSwitchContent(content);
        final useBold = stationId != null &&
            boldStationIds.isNotEmpty &&
            boldStationIds.contains(stationId);
        final inner = useBold
            ? '<g style="font-weight:bold;text-decoration:underline;text-underline-offset:3px">$textValue</g>'
            : textValue;

        return "<g ${transformMatch.group(0)}>$inner</g>";
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
    return Theme(
      data: AppTheme.getTheme(AppTheme.lightTheme),
      child: Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_subway_map_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          ListenableBuilder(
            listenable: _transformationController,
            builder: (context, _) {
              final scale = _transformationController.value.getMaxScaleOnAxis();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "${(scale * 100).round()}%",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const ThemeIcon(Icons.refresh),
            onPressed: () {
              setState(() {
                _mapKey = UniqueKey();
                _transformationController.value = Matrix4.identity()
                  ..translate(_initialMapShiftX, _initialMapShiftY)
                  ..scale(1.3);
              });
              _loadListingStationIds();
            },
            tooltip: "Refresh map",
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
            listenable: LanguageState(),
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
                            child: RepaintBoundary(
                              child: Stack(
                                children: [
                                  SvgPicture.string(
                                    _processSvg(
                                      mapData.rawSvg,
                                      LanguageState().currentLanguage,
                                      _stationIdsWithListings,
                                    ),
                                    width: mapWidth,
                                    height: mapHeight,
                                    fit: BoxFit.contain,
                                    semanticsLabel: "Tashkent subway map",
                                  ),
                                ..._buildMapOverlays(
                                  scale,
                                  offsetX,
                                  offsetY,
                                  isBlueTheme: false,
                                ),
                                ..._buildStationTapTargets(
                                  context,
                                  mapData.stationLabels,
                                  scale,
                                  offsetX,
                                  offsetY,
                                  LanguageState().currentLanguage,
                                ),
                              ],
                            ),
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
    ),
    );
  }
}
