part of "yandex_map_widget.dart";

/// Bump when listing-type map glyphs change so in-memory caches refresh.
const int _yandexMapSharedIconBytesVersion = 2;
int _loadedYandexMapSharedIconBytesVersion = 0;

Future<_YandexMapSharedIconBytes>? _sharedYandexMapIconBytesFuture;
_YandexMapSharedIconBytes? _sharedYandexMapIconBytes;
final Map<String, Uint8List> _sharedListingGroupIconBytes = {};
final Map<String, Future<Uint8List>> _pendingSharedListingGroupIconBytes = {};
final Map<String, Uint8List> _sharedListingTypePinIconBytes = {};
final Map<String, Future<Uint8List>> _pendingSharedListingTypePinIconBytes = {};
final Map<String, Uint8List> _sharedListingClusterIconBytes = {};
final Map<String, Future<Uint8List>> _pendingSharedListingClusterIconBytes = {};
final Map<String, Uint8List> _sharedUniversityClusterIconBytes = {};
final Map<String, Future<Uint8List>> _pendingSharedUniversityClusterIconBytes =
    {};

class _YandexMapSharedIconBytes {
  const _YandexMapSharedIconBytes({
    required this.defaultIconBytes,
    required this.darkDefaultIconBytes,
    required this.visitedIconBytes,
    required this.darkVisitedIconBytes,
    required this.selectedIconBytes,
    required this.universityIconBytes,
    required this.userUniversityIconBytes,
    required this.selectedUserUniversityIconBytes,
    required this.selectedUniversityIconBytes,
    required this.userLocationPinIconBytes,
    required this.userLocationArrowIconBytes,
    required this.darkUserLocationPinIconBytes,
    required this.darkUserLocationArrowIconBytes,
    required this.groceryStoreIconBytes,
    required this.busStopIconBytes,
    required this.listingTypeIconBytes,
    required this.darkListingTypeIconBytes,
    required this.visitedListingTypeIconBytes,
    required this.darkVisitedListingTypeIconBytes,
    required this.selectedListingTypeIconBytes,
    required this.metroStationIconBytes,
    required this.selectedMetroStationIconBytes,
  });

  final Uint8List defaultIconBytes;
  final Uint8List darkDefaultIconBytes;
  final Uint8List visitedIconBytes;
  final Uint8List darkVisitedIconBytes;
  final Uint8List selectedIconBytes;
  final Uint8List universityIconBytes;
  final Uint8List userUniversityIconBytes;
  final Uint8List selectedUserUniversityIconBytes;
  final Uint8List selectedUniversityIconBytes;
  final Uint8List userLocationPinIconBytes;
  final Uint8List userLocationArrowIconBytes;
  final Uint8List darkUserLocationPinIconBytes;
  final Uint8List darkUserLocationArrowIconBytes;
  final Uint8List groceryStoreIconBytes;
  final Uint8List busStopIconBytes;
  final Map<String, Uint8List> listingTypeIconBytes;
  final Map<String, Uint8List> darkListingTypeIconBytes;
  final Map<String, Uint8List> visitedListingTypeIconBytes;
  final Map<String, Uint8List> darkVisitedListingTypeIconBytes;
  final Map<String, Uint8List> selectedListingTypeIconBytes;
  final Map<int, Uint8List> metroStationIconBytes;
  final Map<int, Uint8List> selectedMetroStationIconBytes;
}

extension _YandexMapWidgetIconGeneration on _YandexMapWidgetState {
  static const Color _visitedPinBackground = Color(0xFF9E9E9E);
  static const Color _visitedPinBackgroundDark = Color(0xFF757575);

  Future<_YandexMapSharedIconBytes> _loadSharedIconBytes() async {
    if (_loadedYandexMapSharedIconBytesVersion !=
        _yandexMapSharedIconBytesVersion) {
      _sharedYandexMapIconBytes = null;
      _sharedYandexMapIconBytesFuture = null;
      _sharedListingTypePinIconBytes.clear();
      _pendingSharedListingTypePinIconBytes.clear();
      _loadedYandexMapSharedIconBytesVersion =
          _yandexMapSharedIconBytesVersion;
    }

    final cached = _sharedYandexMapIconBytes;
    if (cached != null) return cached;

    final existingFuture = _sharedYandexMapIconBytesFuture;
    if (existingFuture != null) return existingFuture;

    final future = _createSharedIconBytes();
    _sharedYandexMapIconBytesFuture = future;
    try {
      final bytes = await future;
      _sharedYandexMapIconBytes = bytes;
      return bytes;
    } catch (_) {
      if (identical(_sharedYandexMapIconBytesFuture, future)) {
        _sharedYandexMapIconBytesFuture = null;
      }
      rethrow;
    }
  }

  Future<_YandexMapSharedIconBytes> _createSharedIconBytes() async {
    final reduceStartupIconWork = isAndroidDevice;
    final iconBytes = await _createIconBytes(
      Icons.home,
      reduceStartupIconWork ? 67 : 80,
      outlineColor: Colors.white,
      outlineWidth: reduceStartupIconWork ? 4 : 5,
    );
    final darkIconBytes = await _createIconBytes(
      Icons.home,
      reduceStartupIconWork ? 67 : 80,
      backgroundColor: BlueThemeColors.primaryDark,
      outlineColor: Colors.white,
      outlineWidth: reduceStartupIconWork ? 4 : 5,
    );
    final visitedIconBytes = await _createIconBytes(
      Icons.home,
      reduceStartupIconWork ? 67 : 80,
      backgroundColor: _visitedPinBackground,
      outlineColor: Colors.white,
      outlineWidth: reduceStartupIconWork ? 4 : 5,
    );
    final darkVisitedIconBytes = await _createIconBytes(
      Icons.home,
      reduceStartupIconWork ? 67 : 80,
      backgroundColor: _visitedPinBackgroundDark,
      outlineColor: Colors.white,
      outlineWidth: reduceStartupIconWork ? 4 : 5,
    );
    final selectedIconBytes = await _createIconBytes(
      Icons.home,
      reduceStartupIconWork ? 80 : 99,
      backgroundColor: AppColors.primary,
      outlineColor: Colors.white,
      outlineWidth: reduceStartupIconWork ? 4 : 5,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shadowBlurRadius: reduceStartupIconWork ? 6 : 10,
      shadowOffset:
          reduceStartupIconWork ? const Offset(0, 3) : const Offset(0, 5),
    );
    final listingTypeIconBytes = <String, Uint8List>{};
    final darkListingTypeIconBytes = <String, Uint8List>{};
    final visitedListingTypeIconBytes = <String, Uint8List>{};
    final darkVisitedListingTypeIconBytes = <String, Uint8List>{};
    final selectedListingTypeIconBytes = <String, Uint8List>{};
    if (!reduceStartupIconWork) {
      for (final code in ListingTypeHelper.getAllCodes()) {
        final icon = ListingTypeHelper.getIcon(code);
        listingTypeIconBytes[code] = await _createIconBytes(
          icon,
          80,
          outlineColor: Colors.white,
          outlineWidth: 5,
        );
        darkListingTypeIconBytes[code] = await _createIconBytes(
          icon,
          80,
          backgroundColor: BlueThemeColors.primaryDark,
          outlineColor: Colors.white,
          outlineWidth: 5,
        );
        visitedListingTypeIconBytes[code] = await _createIconBytes(
          icon,
          80,
          backgroundColor: _visitedPinBackground,
          outlineColor: Colors.white,
          outlineWidth: 5,
        );
        darkVisitedListingTypeIconBytes[code] = await _createIconBytes(
          icon,
          80,
          backgroundColor: _visitedPinBackgroundDark,
          outlineColor: Colors.white,
          outlineWidth: 5,
        );
        selectedListingTypeIconBytes[code] = await _createIconBytes(
          icon,
          99,
          backgroundColor: AppColors.primary,
          outlineColor: Colors.white,
          outlineWidth: 5,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          shadowBlurRadius: 10,
          shadowOffset: const Offset(0, 5),
        );
      }
      final absentHostIcon = ListingTypeHelper.roommateAbsentHostIcon;
      const absentHostKey = ListingTypeHelper.roommateAbsentHostMapIconKey;
      listingTypeIconBytes[absentHostKey] = await _createIconBytes(
        absentHostIcon,
        80,
        outlineColor: Colors.white,
        outlineWidth: 5,
      );
      darkListingTypeIconBytes[absentHostKey] = await _createIconBytes(
        absentHostIcon,
        80,
        backgroundColor: BlueThemeColors.primaryDark,
        outlineColor: Colors.white,
        outlineWidth: 5,
      );
      visitedListingTypeIconBytes[absentHostKey] = await _createIconBytes(
        absentHostIcon,
        80,
        backgroundColor: _visitedPinBackground,
        outlineColor: Colors.white,
        outlineWidth: 5,
      );
      darkVisitedListingTypeIconBytes[absentHostKey] = await _createIconBytes(
        absentHostIcon,
        80,
        backgroundColor: _visitedPinBackgroundDark,
        outlineColor: Colors.white,
        outlineWidth: 5,
      );
      selectedListingTypeIconBytes[absentHostKey] = await _createIconBytes(
        absentHostIcon,
        99,
        backgroundColor: AppColors.primary,
        outlineColor: Colors.white,
        outlineWidth: 5,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shadowBlurRadius: 10,
        shadowOffset: const Offset(0, 5),
      );
    }
    final universityIconBytes = reduceStartupIconWork
        ? selectedIconBytes
        : await _createIconBytes(
            Icons.school_rounded,
            112,
            backgroundColor: AppColors.primary,
            iconColor: Colors.white,
            outlineColor: Colors.white,
            outlineWidth: 7,
            shadowColor: Colors.black.withValues(alpha: 0.32),
            shadowBlurRadius: 10,
            shadowOffset: const Offset(0, 5),
          );
    final selectedUniversityIconBytes = reduceStartupIconWork
        ? iconBytes
        : await _createIconBytes(
            Icons.school_rounded,
            124,
            backgroundColor: Colors.black,
            iconColor: Colors.white,
            outlineColor: Colors.white,
            outlineWidth: 8,
            shadowColor: Colors.black.withValues(alpha: 0.38),
            shadowBlurRadius: 12,
            shadowOffset: const Offset(0, 6),
          );
    final userUniversityIconBytes = reduceStartupIconWork
        ? selectedIconBytes
        : await _createIconBytes(
            Icons.school_rounded,
            112,
            backgroundColor: AppColors.error,
            iconColor: Colors.white,
            outlineColor: Colors.white,
            outlineWidth: 7,
            shadowColor: Colors.black.withValues(alpha: 0.32),
            shadowBlurRadius: 10,
            shadowOffset: const Offset(0, 5),
          );
    final selectedUserUniversityIconBytes = reduceStartupIconWork
        ? iconBytes
        : await _createIconBytes(
            Icons.school_rounded,
            124,
            backgroundColor: Colors.black,
            iconColor: Colors.white,
            outlineColor: Colors.white,
            outlineWidth: 8,
            shadowColor: Colors.black.withValues(alpha: 0.38),
            shadowBlurRadius: 12,
            shadowOffset: const Offset(0, 6),
          );
    final userLocationPinIconBytes = await _createUserLocationPinIconBytes(
      foregroundColor: AppColors.error,
      outlineColor: Colors.black,
    );
    final userLocationArrowIconBytes = await _createUserLocationArrowIconBytes(
      foregroundColor: AppColors.error,
      outlineColor: Colors.black,
    );
    final darkUserLocationPinIconBytes = await _createUserLocationPinIconBytes(
      foregroundColor: AppColors.error,
      outlineColor: Colors.white,
    );
    final darkUserLocationArrowIconBytes =
        await _createUserLocationArrowIconBytes(
      foregroundColor: AppColors.error,
      outlineColor: Colors.white,
    );
    final groceryStoreIconBytes = reduceStartupIconWork
        ? iconBytes
        : await _createIconBytes(
            Icons.local_grocery_store_rounded,
            88,
            backgroundColor: const Color(0xFF2E7D32),
            outlineColor: Colors.white,
            outlineWidth: 6,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            shadowBlurRadius: 8,
            shadowOffset: const Offset(0, 4),
          );
    final busStopIconBytes = reduceStartupIconWork
        ? iconBytes
        : await _createIconBytes(
            Icons.directions_bus_rounded,
            88,
            backgroundColor: const Color(0xFF6A1B9A),
            outlineColor: Colors.white,
            outlineWidth: 6,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            shadowBlurRadius: 8,
            shadowOffset: const Offset(0, 4),
          );
    // Metro icons are always generated (including on Android) so stations use
    // the same placemark bitmaps as iOS instead of tiny meter-based circles.
    final metroStationIconBytes = <int, Uint8List>{};
    final selectedMetroStationIconBytes = <int, Uint8List>{};
    for (final line in MetroCache.getAvailableLines()) {
      final outlineColor = line == 4 ? Colors.black : Colors.white;
      final iconStyle = (
        backgroundColor: _metroLineColor(line),
        outlineColor: outlineColor,
        shadowColor: Colors.black.withValues(alpha: 0.28),
        shadowBlurRadius: 9.0,
        shadowOffset: const Offset(0, 4),
      );
      metroStationIconBytes[line] = await _createIconBytes(
        Icons.directions_subway_rounded,
        96,
        backgroundColor: iconStyle.backgroundColor,
        outlineColor: iconStyle.outlineColor,
        outlineWidth: _YandexMapWidgetState._metroStationIconOutlineWidth(
          selected: false,
        ),
        shadowColor: iconStyle.shadowColor,
        shadowBlurRadius: iconStyle.shadowBlurRadius,
        shadowOffset: iconStyle.shadowOffset,
      );
      selectedMetroStationIconBytes[line] = await _createIconBytes(
        Icons.directions_subway_rounded,
        96,
        backgroundColor: iconStyle.backgroundColor,
        outlineColor: iconStyle.outlineColor,
        outlineWidth: _YandexMapWidgetState._metroStationIconOutlineWidth(
          selected: true,
        ),
        shadowColor: iconStyle.shadowColor,
        shadowBlurRadius: iconStyle.shadowBlurRadius,
        shadowOffset: iconStyle.shadowOffset,
      );
    }

    return _YandexMapSharedIconBytes(
      defaultIconBytes: iconBytes,
      darkDefaultIconBytes: darkIconBytes,
      visitedIconBytes: visitedIconBytes,
      darkVisitedIconBytes: darkVisitedIconBytes,
      selectedIconBytes: selectedIconBytes,
      universityIconBytes: universityIconBytes,
      userUniversityIconBytes: userUniversityIconBytes,
      selectedUserUniversityIconBytes: selectedUserUniversityIconBytes,
      selectedUniversityIconBytes: selectedUniversityIconBytes,
      userLocationPinIconBytes: userLocationPinIconBytes,
      userLocationArrowIconBytes: userLocationArrowIconBytes,
      darkUserLocationPinIconBytes: darkUserLocationPinIconBytes,
      darkUserLocationArrowIconBytes: darkUserLocationArrowIconBytes,
      groceryStoreIconBytes: groceryStoreIconBytes,
      busStopIconBytes: busStopIconBytes,
      listingTypeIconBytes: Map.unmodifiable(listingTypeIconBytes),
      darkListingTypeIconBytes: Map.unmodifiable(darkListingTypeIconBytes),
      visitedListingTypeIconBytes: Map.unmodifiable(visitedListingTypeIconBytes),
      darkVisitedListingTypeIconBytes:
          Map.unmodifiable(darkVisitedListingTypeIconBytes),
      selectedListingTypeIconBytes: Map.unmodifiable(
        selectedListingTypeIconBytes,
      ),
      metroStationIconBytes: Map.unmodifiable(metroStationIconBytes),
      selectedMetroStationIconBytes:
          Map.unmodifiable(selectedMetroStationIconBytes),
    );
  }

  Future<Uint8List> _createListingTypePinIconBytes(
    String cacheKey, {
    required bool selected,
    required bool visited,
    required bool darkMap,
  }) async {
    final icon = ListingTypeHelper.iconForMapCacheKey(cacheKey);
    final reduceStartupIconWork = isAndroidDevice;
    if (selected) {
      return _createIconBytes(
        icon,
        reduceStartupIconWork ? 80 : 99,
        backgroundColor: AppColors.primary,
        outlineColor: Colors.white,
        outlineWidth: 5,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shadowBlurRadius: reduceStartupIconWork ? 6 : 10,
        shadowOffset:
            reduceStartupIconWork ? const Offset(0, 3) : const Offset(0, 5),
      );
    }
    if (visited) {
      return _createIconBytes(
        icon,
        reduceStartupIconWork ? 67 : 80,
        backgroundColor:
            darkMap ? _visitedPinBackgroundDark : _visitedPinBackground,
        outlineColor: Colors.white,
        outlineWidth: reduceStartupIconWork ? 4 : 5,
      );
    }
    if (darkMap) {
      return _createIconBytes(
        icon,
        reduceStartupIconWork ? 67 : 80,
        backgroundColor: BlueThemeColors.primaryDark,
        outlineColor: Colors.white,
        outlineWidth: reduceStartupIconWork ? 4 : 5,
      );
    }
    return _createIconBytes(
      icon,
      reduceStartupIconWork ? 67 : 80,
      outlineColor: Colors.white,
      outlineWidth: reduceStartupIconWork ? 4 : 5,
    );
  }

  String _listingTypePinIconVariantKey(
    String cacheKey, {
    required bool selected,
    required bool visited,
    required bool darkMap,
  }) {
    final state = selected
        ? "selected"
        : visited
            ? darkMap
                ? "dark_visited"
                : "visited"
            : darkMap
                ? "dark"
                : "default";
    return "${state}_$cacheKey";
  }

  Map<String, Uint8List> _listingTypePinIconBytesMap({
    required bool selected,
    required bool visited,
    required bool darkMap,
  }) {
    if (selected) return _cachedSelectedListingTypeIconBytes;
    if (visited) {
      return darkMap
          ? _cachedDarkVisitedListingTypeIconBytes
          : _cachedVisitedListingTypeIconBytes;
    }
    return darkMap
        ? _cachedDarkListingTypeIconBytes
        : _cachedListingTypeIconBytes;
  }

  void _ensureListingTypePinIconBytes(
    String cacheKey, {
    required bool selected,
    required bool visited,
  }) {
    if (_cachedIconBytes == null) return;
    final darkMap = widget.nightModeEnabled && !selected && !visited;
    final targetMap = _listingTypePinIconBytesMap(
      selected: selected,
      visited: visited,
      darkMap: darkMap,
    );
    if (targetMap.containsKey(cacheKey)) return;

    final variantKey = _listingTypePinIconVariantKey(
      cacheKey,
      selected: selected,
      visited: visited,
      darkMap: darkMap,
    );
    final sharedBytes = _sharedListingTypePinIconBytes[variantKey];
    if (sharedBytes != null) {
      targetMap[cacheKey] = sharedBytes;
      return;
    }
    if (_pendingListingTypePinIconKeys.contains(variantKey)) return;

    _pendingListingTypePinIconKeys.add(variantKey);
    final future = _pendingSharedListingTypePinIconBytes.putIfAbsent(
      variantKey,
      () => _createListingTypePinIconBytes(
        cacheKey,
        selected: selected,
        visited: visited,
        darkMap: darkMap,
      ).then((bytes) {
        _sharedListingTypePinIconBytes[variantKey] = bytes;
        _pendingSharedListingTypePinIconBytes.remove(variantKey);
        return bytes;
      }).catchError((Object error, StackTrace stackTrace) {
        _pendingSharedListingTypePinIconBytes.remove(variantKey);
        Error.throwWithStackTrace(error, stackTrace);
      }),
    );
    future.then((bytes) {
      _pendingListingTypePinIconKeys.remove(variantKey);
      if (!mounted) return;
      targetMap[cacheKey] = bytes;
      _requestMapRebuild();
    }).catchError((error) {
      _pendingListingTypePinIconKeys.remove(variantKey);
      logger.w("Could not create listing type pin icon: $error");
    });
  }

  void _syncListingTypePinIconBytes() {
    if (_cachedIconBytes == null) return;
    for (final cacheKey in ListingTypeHelper.getAllMapIconCacheKeys()) {
      _ensureListingTypePinIconBytes(cacheKey, selected: false, visited: false);
      _ensureListingTypePinIconBytes(cacheKey, selected: false, visited: true);
      _ensureListingTypePinIconBytes(cacheKey, selected: true, visited: false);
    }
  }

  Future<Uint8List> _createIconBytes(
    IconData iconData,
    int size, {
    Color backgroundColor = const Color(0xFF000000),
    Color iconColor = Colors.white,
    Color? outlineColor,
    double outlineWidth = 0,
    Color? shadowColor,
    double shadowBlurRadius = 0,
    Offset shadowOffset = Offset.zero,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final center = Offset(size / 2, size / 2);
    final radius = size * 0.39;

    if (shadowColor != null && shadowBlurRadius > 0) {
      final shadowPaint = Paint()
        ..color = shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + shadowOffset, radius, shadowPaint);
    }

    if (outlineColor != null && outlineWidth > 0) {
      final outlinePaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + outlineWidth, outlinePaint);
    }

    final circlePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size.toDouble() * 0.6,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    final picture = pictureRecorder.endRecording();
    try {
      final image = await picture.toImage(size, size);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  Future<Uint8List> _createUserLocationPinIconBytes({
    required Color foregroundColor,
    required Color outlineColor,
  }) async {
    const size = 104;
    const center = Offset(size / 2, size / 2);
    const outerRadius = 28.0;
    const innerRadius = outerRadius - 3;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, 4), outerRadius, shadowPaint);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outlinePaint);

    final dotPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, dotPaint);

    return _createPngBytesFromPicture(pictureRecorder, size, size);
  }

  Future<Uint8List> _createUserLocationArrowIconBytes({
    required Color foregroundColor,
    required Color outlineColor,
  }) async {
    const size = 152;
    const center = Offset(size / 2, size / 2);
    const outerRadius = 30.0;
    const innerRadius = outerRadius - 3;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final arrowPath = Path()
      ..moveTo(center.dx, 12)
      ..lineTo(center.dx - 24, center.dy - 8)
      ..lineTo(center.dx, center.dy - 18)
      ..lineTo(center.dx + 24, center.dy - 8)
      ..close();

    final arrowOutlinePaint = Paint()
      ..color = outlineColor
      ..strokeWidth = 14
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(arrowPath, arrowOutlinePaint);

    final arrowPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, 4), outerRadius, shadowPaint);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outlinePaint);

    final dotPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, dotPaint);

    return _createPngBytesFromPicture(pictureRecorder, size, size);
  }

  Future<Uint8List> _createPngBytesFromPicture(
    ui.PictureRecorder pictureRecorder,
    int width,
    int height,
  ) async {
    final picture = pictureRecorder.endRecording();
    try {
      final image = await picture.toImage(width, height);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  String _metroWalkAreaLabelIconCacheKey(String label) {
    return "${widget.nightModeEnabled ? "dark" : "light"}|$label";
  }

  String _districtLabelIconCacheKey({
    required int locationId,
    required String language,
    required bool highlighted,
  }) {
    return "district_${locationId}_${language}_"
        "${widget.nightModeEnabled ? "dark" : "light"}_"
        "${highlighted ? "hi" : "normal"}";
  }

  void _ensureDistrictLabelIconBytes({
    required int locationId,
    required String label,
    required bool highlighted,
  }) {
    final cacheKey = _districtLabelIconCacheKey(
      locationId: locationId,
      language: Localizations.localeOf(context).languageCode,
      highlighted: highlighted,
    );
    if (_cachedDistrictLabelIconBytes.containsKey(cacheKey) ||
        _pendingDistrictLabelIconKeys.contains(cacheKey)) {
      return;
    }

    _pendingDistrictLabelIconKeys.add(cacheKey);
    _createDistrictLabelIconBytes(label: label, highlighted: highlighted)
        .then((bytes) {
      _pendingDistrictLabelIconKeys.remove(cacheKey);
      if (!mounted) return;
      _cachedDistrictLabelIconBytes[cacheKey] = bytes;
      _requestMapRebuild();
    }).catchError((Object error) {
      _pendingDistrictLabelIconKeys.remove(cacheKey);
      logger.w("Could not create district label icon: $error");
    });
  }

  Future<Uint8List> _createDistrictLabelIconBytes({
    required String label,
    required bool highlighted,
  }) async {
    final textColor =
        widget.nightModeEnabled ? Colors.white : const Color(0xFF111111);
    final fontSize = highlighted ? 42.0 : 38.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const horizontalPadding = 4.0;
    const verticalPadding = 2.0;
    final width = (textPainter.width + horizontalPadding * 2).ceil();
    final height = (textPainter.height + verticalPadding * 2).ceil();
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final offset = Offset(horizontalPadding, verticalPadding);
    textPainter.paint(canvas, offset);

    return _createPngBytesFromPicture(pictureRecorder, width, height);
  }

  Color _metroWalkAreaLabelColor() {
    return widget.nightModeEnabled ? Colors.white : Colors.black;
  }

  void _ensureMetroWalkAreaLabelIconBytes(String label) {
    final cacheKey = _metroWalkAreaLabelIconCacheKey(label);
    if (_cachedMetroWalkAreaLabelIconBytes.containsKey(cacheKey) ||
        _pendingMetroWalkAreaLabelIconKeys.contains(cacheKey)) {
      return;
    }

    _pendingMetroWalkAreaLabelIconKeys.add(cacheKey);
    _createMetroWalkAreaLabelIconBytes(label).then((bytes) {
      _pendingMetroWalkAreaLabelIconKeys.remove(cacheKey);
      if (!mounted) return;
      _cachedMetroWalkAreaLabelIconBytes[cacheKey] = bytes;
      _requestMapRebuild();
    }).catchError((Object error) {
      _pendingMetroWalkAreaLabelIconKeys.remove(cacheKey);
      logger.w("Could not create metro walk area label icon: $error");
    });
  }

  Future<Uint8List> _createMetroWalkAreaLabelIconBytes(String label) async {
    final textColor = _metroWalkAreaLabelColor();
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 42,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const horizontalPadding = 13.0;
    const verticalPadding = 9.0;
    final width = (textPainter.width + horizontalPadding * 2).ceil();
    final height = (textPainter.height + verticalPadding * 2).ceil();
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final offset = Offset(horizontalPadding, verticalPadding);
    textPainter.paint(canvas, offset);

    return _createPngBytesFromPicture(pictureRecorder, width, height);
  }

  Future<Uint8List> _listingClusterIconBytes(int count) {
    final cappedCount = count > 99 ? 99 : count;
    final key =
        cappedCount == 99 && count > 99 ? "99+" : cappedCount.toString();
    final cached = _sharedListingClusterIconBytes[key];
    if (cached != null) return Future.value(cached);

    return _pendingSharedListingClusterIconBytes.putIfAbsent(
      key,
      () => _createListingClusterIconBytes(key).then((bytes) {
        _sharedListingClusterIconBytes[key] = bytes;
        _pendingSharedListingClusterIconBytes.remove(key);
        return bytes;
      }).catchError((Object error, StackTrace stackTrace) {
        _pendingSharedListingClusterIconBytes.remove(key);
        Error.throwWithStackTrace(error, stackTrace);
      }),
    );
  }

  Future<Uint8List> _createListingClusterIconBytes(String label) async {
    return _createClusterIconBytes(label, backgroundColor: Colors.black);
  }

  Future<Uint8List> _universityClusterIconBytes(
    int count, {
    bool isUserUniversity = false,
  }) {
    final cappedCount = count > 99 ? 99 : count;
    final countLabel =
        cappedCount == 99 && count > 99 ? "99+" : cappedCount.toString();
    final key = isUserUniversity ? "${countLabel}_user" : countLabel;
    final cached = _sharedUniversityClusterIconBytes[key];
    if (cached != null) return Future.value(cached);

    return _pendingSharedUniversityClusterIconBytes.putIfAbsent(
      key,
      () => _createUniversityClusterIconBytes(
        countLabel,
        isUserUniversity: isUserUniversity,
      ).then((bytes) {
        _sharedUniversityClusterIconBytes[key] = bytes;
        _pendingSharedUniversityClusterIconBytes.remove(key);
        return bytes;
      }).catchError((Object error, StackTrace stackTrace) {
        _pendingSharedUniversityClusterIconBytes.remove(key);
        Error.throwWithStackTrace(error, stackTrace);
      }),
    );
  }

  Future<Uint8List> _createUniversityClusterIconBytes(
    String label, {
    bool isUserUniversity = false,
  }) async {
    return _createClusterIconBytes(
      label,
      backgroundColor:
          isUserUniversity ? AppColors.error : AppColors.success,
    );
  }

  Future<Uint8List> _createClusterIconBytes(
    String label, {
    required Color backgroundColor,
  }) async {
    const size = 112;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const center = Offset(size / 2, size / 2);
    const radius = 38.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, 5), radius, shadowPaint);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 7, outlinePaint);

    final circlePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 30 : 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    try {
      final image = await picture.toImage(size, size);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  void _syncListingGroupIconBytes() {
    for (final group in _groupListingPins(widget.pins)) {
      if (group.pins.length < 2) continue;
      final listingTypeCode = _listingGroupTypeCode(group.pins);
      _ensureListingGroupIconBytes(
        group.pins.length,
        listingTypeCode: listingTypeCode,
      );
      _ensureListingGroupIconBytes(
        group.pins.length,
        listingTypeCode: listingTypeCode,
        visited: true,
      );
      _ensureListingGroupIconBytes(
        group.pins.length,
        listingTypeCode: listingTypeCode,
        selected: true,
      );
    }
  }

  void _ensureListingGroupIconBytes(
    int count, {
    String? listingTypeCode,
    bool selected = false,
    bool visited = false,
  }) {
    if (_cachedIconBytes == null || _cachedSelectedIconBytes == null) return;
    final darkMap = widget.nightModeEnabled && !selected && !visited;
    final key = _listingGroupIconKey(
      count,
      listingTypeCode: listingTypeCode,
      selected: selected,
      visited: visited,
      darkMap: darkMap,
    );
    final sharedBytes = _sharedListingGroupIconBytes[key];
    if (sharedBytes != null) {
      _cachedListingGroupIconBytes[key] = sharedBytes;
      return;
    }
    if (_cachedListingGroupIconBytes.containsKey(key) ||
        _pendingListingGroupIconKeys.contains(key)) {
      return;
    }

    _pendingListingGroupIconKeys.add(key);
    final future = _pendingSharedListingGroupIconBytes.putIfAbsent(
      key,
      () => _createListingGroupIconBytes(
        count,
        listingTypeCode: listingTypeCode,
        selected: selected,
        visited: visited,
        darkMap: darkMap,
      ).then((bytes) {
        _sharedListingGroupIconBytes[key] = bytes;
        _pendingSharedListingGroupIconBytes.remove(key);
        return bytes;
      }).catchError((Object error, StackTrace stackTrace) {
        _pendingSharedListingGroupIconBytes.remove(key);
        Error.throwWithStackTrace(error, stackTrace);
      }),
    );
    future.then((bytes) {
      _pendingListingGroupIconKeys.remove(key);
      if (!mounted) return;
      _cachedListingGroupIconBytes[key] = bytes;
      _requestMapRebuild();
    }).catchError((error) {
      _pendingListingGroupIconKeys.remove(key);
      logger.w("Could not create grouped listing pin icon: $error");
    });
  }

  String _listingGroupIconKey(
    int count, {
    required String? listingTypeCode,
    required bool selected,
    required bool visited,
    required bool darkMap,
  }) {
    final state = selected
        ? "selected"
        : visited
            ? "visited"
            : darkMap
                ? "dark"
                : "default";
    return "${state}_${listingTypeCode ?? "mixed"}_$count";
  }

  Future<Uint8List> _createListingGroupIconBytes(
    int count, {
    required bool selected,
    required bool visited,
    required bool darkMap,
    String? listingTypeCode,
  }) async {
    const width = 118;
    const height = 77;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const center = Offset(width / 2, height / 2);
    final pillHeight = selected ? 54.0 : 50.0;
    final pillWidth = selected ? 104.0 : 98.0;
    final pillRect = Rect.fromCenter(
      center: center,
      width: pillWidth,
      height: pillHeight,
    );
    final pillRadius = Radius.circular(pillHeight / 2);
    final pillRRect = RRect.fromRectAndRadius(pillRect, pillRadius);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: selected ? 0.35 : 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRRect.shift(const Offset(0, 4)), shadowPaint);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final outlineWidth = selected ? 6.0 : 4.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        pillRect.inflate(outlineWidth),
        Radius.circular((pillHeight / 2) + outlineWidth),
      ),
      outlinePaint,
    );

    final pillPaint = Paint()
      ..color = selected
          ? AppColors.primary
          : visited
              ? _visitedPinBackground
              : darkMap
                  ? BlueThemeColors.primaryDark
                  : Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRRect, pillPaint);

    final label = count > 99 ? "99+" : count.toString();
    final iconData = listingTypeCode == null
        ? Icons.home_work_outlined
        : ListingTypeHelper.getIcon(listingTypeCode);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 26 : 30,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 24 : 29,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const gap = 6.0;
    final contentWidth = textPainter.width + gap + iconPainter.width;
    final contentHeight = iconPainter.height > textPainter.height
        ? iconPainter.height
        : textPainter.height;
    final contentLeft = (width - contentWidth) / 2;
    final contentTop = (height - contentHeight) / 2;
    textPainter.paint(
      canvas,
      Offset(
        contentLeft,
        contentTop + (contentHeight - textPainter.height) / 2,
      ),
    );
    iconPainter.paint(
      canvas,
      Offset(
        contentLeft + textPainter.width + gap,
        contentTop + (contentHeight - iconPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    try {
      final image = await picture.toImage(width, height);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}
