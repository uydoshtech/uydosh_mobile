part of "../search_results_map_screen.dart";

class _SearchResultsMapContent extends StatelessWidget {
  const _SearchResultsMapContent({
    required this.result,
    required this.isLoading,
    required this.hasSearchFilters,
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    required this.selectedPin,
    required this.selectedPinGroup,
    required this.selectedUniversityMarker,
    required this.hasSelectedMetroStation,
    required this.universityMarkers,
    required this.selectedUniversityMarkerId,
    required this.userUniversityMarkerId,
    required this.showDistrictLayer,
    required this.metroLayerMode,
    required this.walkRadiusMinutes,
    required this.showUniversitiesLayer,
    required this.showGroceryStoresLayer,
    required this.showBusStopsLayer,
    required this.mapNightModeOverride,
    required this.showLocationPrompt,
    required this.filterRibbonEnabled,
    required this.showFilterRibbon,
    required this.userLocationRequestToken,
    required this.userLocationLatitude,
    required this.userLocationLongitude,
    required this.placeViewToggleAtBottom,
    required this.mapBottomInset,
    required this.searchButtonBottom,
    required this.viewToggleBottom,
    required this.onOpenFilters,
    required this.onCloseFilterRibbon,
    required this.onOpenEmbeddedSearch,
    required this.onOpenFeedView,
    required this.onRequestUserLocation,
    required this.onToggleDistrictLayer,
    required this.onToggleWalkRadiusMinutes,
    required this.onToggleMetroLayerMode,
    required this.onToggleUniversitiesLayer,
    required this.onToggleMapNightMode,
    required this.onClearSelectedPin,
    required this.onClearSelectedUniversityMarker,
    required this.onSelectPin,
    required this.onSelectPinGroup,
    required this.onSelectUniversityMarker,
    required this.onMetroStationTooltipChanged,
    required this.onOpenPin,
    this.gender,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
  });

  final _SearchMapResult result;
  final bool isLoading;
  final bool hasSearchFilters;
  final int listingTypeId;
  final int? gender;
  final int? locationId;
  final int? subwayStationId;
  final List<int> subwayStationIds;
  final int? subwayLineId;
  final double minPrice;
  final double maxPrice;
  final bool privateRoom;
  final bool withPhoto;
  final ListingMapPin? selectedPin;
  final List<ListingMapPin> selectedPinGroup;
  final UniversityMapMarker? selectedUniversityMarker;
  final bool hasSelectedMetroStation;
  final List<UniversityMapMarker> universityMarkers;
  final String? selectedUniversityMarkerId;
  final String? userUniversityMarkerId;
  final bool showDistrictLayer;
  final _MetroLayerMode metroLayerMode;
  final _WalkRadiusMinutes walkRadiusMinutes;
  final bool showUniversitiesLayer;
  final bool showGroceryStoresLayer;
  final bool showBusStopsLayer;
  final bool? mapNightModeOverride;
  final bool showLocationPrompt;
  final bool filterRibbonEnabled;
  final bool showFilterRibbon;
  final int userLocationRequestToken;
  final double? userLocationLatitude;
  final double? userLocationLongitude;
  final bool placeViewToggleAtBottom;
  final double mapBottomInset;
  final double searchButtonBottom;
  final double viewToggleBottom;
  final VoidCallback onOpenFilters;
  final VoidCallback onCloseFilterRibbon;
  final VoidCallback? onOpenEmbeddedSearch;
  final VoidCallback onOpenFeedView;
  final VoidCallback onRequestUserLocation;
  final VoidCallback onToggleDistrictLayer;
  final VoidCallback onToggleWalkRadiusMinutes;
  final VoidCallback onToggleMetroLayerMode;
  final VoidCallback onToggleUniversitiesLayer;
  final ValueChanged<bool> onToggleMapNightMode;
  final VoidCallback onClearSelectedPin;
  final VoidCallback onClearSelectedUniversityMarker;
  final ValueChanged<ListingMapPin> onSelectPin;
  final ValueChanged<List<ListingMapPin>> onSelectPinGroup;
  final ValueChanged<UniversityMapMarker> onSelectUniversityMarker;
  final ValueChanged<bool> onMetroStationTooltipChanged;
  final ValueChanged<ListingMapPin> onOpenPin;

  @override
  Widget build(BuildContext context) {
    final pin = selectedPin;
    final pinGroup = selectedPinGroup;
    final universityMarker = selectedUniversityMarker;
    final showSelectFiltersTile = !hasSearchFilters && !isLoading;
    final showNoResultsTile =
        hasSearchFilters && !isLoading && result.total == 0;
    final hasMapTooltipSpace = hasSelectedMetroStation &&
        !showSelectFiltersTile &&
        !showNoResultsTile;
    final hasTopTile = pin != null ||
        pinGroup.isNotEmpty ||
        universityMarker != null ||
        showNoResultsTile ||
        hasMapTooltipSpace;
    final appNightModeEnabled = Theme.of(context).brightness == Brightness.dark;
    final mapNightModeEnabled = mapNightModeOverride ?? appNightModeEnabled;
    final mapLoaderColor = mapNightModeEnabled ? Colors.white : Colors.black;
    const viewToggleTop = 4.0;
    const viewToggleWidth = 61.2;
    const feedViewButtonHeight = 34.2;
    const viewToggleHeight = 38.0;
    const viewToggleGap = 8.0;
    const zoomControlsWidth = 48.0;
    const metroTooltipReservedHeight = 64.0;
    const locationPromptBottomMargin = 8.0;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final bottomOverlayInset =
        mapBottomInset > safeAreaBottom ? mapBottomInset : safeAreaBottom;
    final locationPromptBottom = placeViewToggleAtBottom
        ? searchButtonBottom
        : bottomOverlayInset + locationPromptBottomMargin;
    final locationPromptHeight = placeViewToggleAtBottom
        ? (viewToggleBottom - searchButtonBottom) + feedViewButtonHeight
        : feedViewButtonHeight;
    final zoomControlsBottom = viewToggleBottom +
        feedViewButtonHeight +
        viewToggleGap -
        safeAreaBottom;
    const mapOverlayPanelColor = Colors.white;
    final feedViewButton = SearchFloatingActionButton(
      onPressed: onOpenFeedView,
      iconData: Icons.view_list_rounded,
      tooltip: L10n.get("open_feed_view"),
      width: viewToggleWidth,
      height: feedViewButtonHeight,
      iconSize: 22.5,
      backgroundColor: mapOverlayPanelColor,
      foregroundColor: Colors.black,
      mapOverlay: true,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
    final mapThemeButton = SearchFloatingActionButton(
      onPressed: () => onToggleMapNightMode(!mapNightModeEnabled),
      iconData: mapNightModeEnabled
          ? Icons.light_mode_rounded
          : Icons.dark_mode_rounded,
      tooltip: mapNightModeEnabled
          ? context.l10n.switch_to_light_map
          : context.l10n.switch_to_dark_map,
      width: viewToggleWidth,
      height: viewToggleHeight,
      iconSize: 18,
      backgroundColor: mapNightModeEnabled ? Colors.black : Colors.white,
      foregroundColor: mapNightModeEnabled ? Colors.white : Colors.black,
      borderSide: const BorderSide(color: Colors.black, width: 1),
      mapOverlay: true,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
    return Column(
      children: [
        if (filterRibbonEnabled)
          if (showFilterRibbon)
            _MapFilterRibbon(
              onPressed: onOpenFilters,
              onClose: onCloseFilterRibbon,
              listingTypeId: listingTypeId,
              gender: gender,
              locationId: locationId,
              subwayStationId: subwayStationId,
              subwayStationIds: subwayStationIds,
              subwayLineId: subwayLineId,
              minPrice: minPrice,
              maxPrice: maxPrice,
              privateRoom: privateRoom,
              withPhoto: withPhoto,
              total: result.total,
            )
          else
            _MapFilterRibbon(
              onPressed: onOpenFilters,
              emptyLabel: hasSearchFilters
                  ? "${L10n.get("filters_bar_label")} • ${result.total}"
                  : context.l10n.choose_filters,
              listingTypeId: listingTypeId,
              gender: gender,
              locationId: locationId,
              subwayStationId: subwayStationId,
              subwayStationIds: subwayStationIds,
              subwayLineId: subwayLineId,
              minPrice: minPrice,
              maxPrice: maxPrice,
              privateRoom: privateRoom,
              withPhoto: withPhoto,
              total: result.total,
            ),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: mapBottomInset,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: mapBottomInset > 0,
                  child: RepaintBoundary(
                    child: YandexMapWidget(
                    apiKey: AppConfig.yandexMapsApiKey,
                    pins: result.pins,
                    universityMarkers: universityMarkers,
                    selectedUniversityMarkerId: selectedUniversityMarkerId,
                    userUniversityMarkerId: userUniversityMarkerId,
                    selectedUniversityZoomFocusId: universityMarker?.id,
                    selectedListingId: selectedPin?.listingId,
                    selectedListingGroupIds: [
                      for (final pin in pinGroup) pin.listingId,
                    ],
                    title: context.l10n.search_results,
                    height: double.infinity,
                    cameraOptions: YandexMapCameraOptions(
                      moveOnTargetChange:
                          hasSearchFilters && result.pins.isNotEmpty,
                      includeUniversityMarkersInCamera: false,
                      fitCityWhenNoPins: !hasSearchFilters,
                    ),
                    showDefaultPlacemark: false,
                    nightModeEnabled: mapNightModeEnabled,
                    walkRadiusMinutes: walkRadiusMinutes.minutes,
                    tooltipOptions: YandexMapTooltipOptions(
                      showUniversityMarker: false,
                      showMetroStation:
                          !showSelectFiltersTile && !showNoResultsTile,
                    ),
                    layerOptions: YandexMapLayerOptions(
                      showUserLocation: false,
                      showDistrictLayer: showDistrictLayer,
                      showMetroStationsLayer: metroLayerMode.showsStations,
                      metroStationLineId: metroLayerMode.lineId,
                      showGroceryStoresLayer: showGroceryStoresLayer,
                      showBusStopsLayer: showBusStopsLayer,
                    ),
                    userLocationRequestToken: userLocationRequestToken,
                    userLocationLatitude: userLocationLatitude,
                    userLocationLongitude: userLocationLongitude,
                    showLoadingPlaceholderContent: false,
                    zoomControlsOptions: YandexMapZoomControlsOptions(
                      right: placeViewToggleAtBottom
                          ? 16 + ((viewToggleWidth - zoomControlsWidth) / 2)
                          : null,
                      bottom: placeViewToggleAtBottom
                          ? zoomControlsBottom.clamp(0.0, double.infinity)
                          : null,
                    ),
                    onMetroStationTooltipChanged: onMetroStationTooltipChanged,
                    onMapTap: (_) {
                      onClearSelectedPin();
                      onClearSelectedUniversityMarker();
                    },
                    onPinTap: onSelectPin,
                    onPinGroupTap: onSelectPinGroup,
                    onUniversityMarkerTap: onSelectUniversityMarker,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: UiPerformancePolicy.solidColorsPreferredForDevice
                      ? (isLoading
                          ? Center(
                              child: Transform.translate(
                                offset: const Offset(0, -50),
                                child: HouseLoadingIndicator(
                                  size: 44,
                                  color: mapLoaderColor,
                                ),
                              ),
                            )
                          : const SizedBox.shrink())
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: isLoading
                              ? Center(
                                  key: const ValueKey("map-results-loading"),
                                  child: Transform.translate(
                                    offset: const Offset(0, -50),
                                    child: HouseLoadingIndicator(
                                      size: 44,
                                      color: mapLoaderColor,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey("map-results-idle"),
                                ),
                        ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: viewToggleTop,
                child: PointerInterceptor(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MapTooltipFadeTransition(
                      child: showNoResultsTile
                          ? _NoMapResultsTile(
                              key: const ValueKey("no-map-results"),
                              label: L10n.get("no_results"),
                            )
                          : pin != null
                              ? _PinSummaryTooltip(
                                  key: ValueKey("pin-${pin.listingId}"),
                                  pin: pin,
                                  onClose: onClearSelectedPin,
                                  onOpen: () => onOpenPin(pin),
                                )
                              : pinGroup.isNotEmpty
                                  ? _PinGroupSummaryTooltip(
                                      key: ValueKey(
                                        "pin-group-${pinGroup.map((pin) => pin.listingId).join("-")}",
                                      ),
                                      pins: pinGroup,
                                      onClose: onClearSelectedPin,
                                      onOpenPin: onOpenPin,
                                    )
                                  : universityMarker != null
                                      ? UniversityMapTooltip(
                                          key: ValueKey(
                                            "university-${universityMarker.id}",
                                          ),
                                          marker: universityMarker,
                                          onClose:
                                              onClearSelectedUniversityMarker,
                                        )
                                      : hasMapTooltipSpace
                                          ? IgnorePointer(
                                              child: SizedBox(
                                                key: const ValueKey(
                                                  "metro-station-tooltip-space",
                                                ),
                                                width: double.infinity,
                                                height:
                                                    metroTooltipReservedHeight,
                                              ),
                                            )
                                          : null,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: hasTopTile ? viewToggleGap : 0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: mapThemeButton,
                        ),
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!placeViewToggleAtBottom) ...[
                              feedViewButton,
                              const SizedBox(height: viewToggleGap),
                            ],
                            _MapLayerToggleButtons(
                              walkRadiusMinutes: walkRadiusMinutes,
                              walkRadiusActive: hasSelectedMetroStation ||
                                  universityMarker != null,
                              metroLayerMode: metroLayerMode,
                              showDistrictLayer: showDistrictLayer,
                              showUniversitiesLayer: showUniversitiesLayer,
                              onToggleWalkRadiusMinutes: onToggleWalkRadiusMinutes,
                              onToggleMetroLayerMode: onToggleMetroLayerMode,
                              onToggleDistrictLayer: onToggleDistrictLayer,
                              onToggleUniversitiesLayer:
                                  onToggleUniversitiesLayer,
                              width: viewToggleWidth,
                              height: viewToggleHeight,
                              gap: viewToggleGap,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              if (placeViewToggleAtBottom)
                Positioned(
                  right: 16,
                  bottom: viewToggleBottom,
                  child: PointerInterceptor(child: feedViewButton),
                ),
              if (placeViewToggleAtBottom && onOpenEmbeddedSearch != null)
                Positioned(
                  right: 16,
                  bottom: searchButtonBottom,
                  child: PointerInterceptor(
                    child: SearchFloatingActionButton(
                      onPressed: onOpenEmbeddedSearch,
                      iconData: Icons.search,
                      width: viewToggleWidth,
                      height: feedViewButtonHeight,
                      iconSize: 22.5,
                      backgroundColor: mapOverlayPanelColor,
                      foregroundColor: Colors.black,
                      mapOverlay: true,
                      elevation: ThemeState().isBlueTheme ? null : 8,
                    ),
                  ),
                ),
              if (showLocationPrompt)
                Positioned(
                  left: 12,
                  width: MediaQuery.sizeOf(context).width * 0.75,
                  bottom: locationPromptBottom,
                  child: PointerInterceptor(
                    child: _MapLocationPromptCard(
                      height: locationPromptHeight,
                      actionButtonHeight: feedViewButtonHeight,
                      onPressed: onRequestUserLocation,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapLocationPromptCard extends StatelessWidget {
  const _MapLocationPromptCard({
    required this.height,
    required this.actionButtonHeight,
    required this.onPressed,
  });

  final double height;
  final double actionButtonHeight;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeState = ThemeState();
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    const foregroundColor = Colors.black;
    const iconBackgroundColor = Colors.black;
    const iconForegroundColor = Colors.white;
    const borderRadius = BorderRadius.all(Radius.circular(18));
    const base = Colors.white;
    final shadows = solidColors
        ? const <BoxShadow>[]
        : ThreeDSurfaceStyle.elevatedShadows(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: solidColors
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: ThemeIcon(
                Icons.my_location_rounded,
                color: iconForegroundColor,
                size: 18,
                useThemeColor: false,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              L10n.get("map_location_prompt_title"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SearchFloatingActionButton(
            onPressed: onPressed,
            iconData: Icons.near_me_rounded,
            tooltip: L10n.get("map_location_prompt_action"),
            width: actionButtonHeight,
            height: actionButtonHeight,
            iconSize: 19,
            backgroundColor: iconBackgroundColor,
            foregroundColor: iconForegroundColor,
            mapOverlay: true,
            elevation: themeState.isBlueTheme ? null : 6,
          ),
        ],
      ),
    );

    return Material(
      color: solidColors ? base : Colors.transparent,
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadows,
          border: solidColors
              ? Border.all(color: scheme.outlineVariant)
              : null,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
          ),
          child: SizedBox(
            height: height,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _NoMapResultsTile extends StatelessWidget {
  const _NoMapResultsTile({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(18);
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ),
    );

    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: borderRadius,
        border: solidColors ? Border.all(color: scheme.outlineVariant) : null,
        boxShadow: solidColors
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );

    return Material(
      color: solidColors ? scheme.surface : Colors.transparent,
      borderRadius: borderRadius,
      child: tile,
    );
  }
}

class _MapLayerToggleButtons extends StatelessWidget {
  const _MapLayerToggleButtons({
    required this.walkRadiusMinutes,
    required this.walkRadiusActive,
    required this.metroLayerMode,
    required this.showDistrictLayer,
    required this.showUniversitiesLayer,
    required this.onToggleWalkRadiusMinutes,
    required this.onToggleMetroLayerMode,
    required this.onToggleDistrictLayer,
    required this.onToggleUniversitiesLayer,
    required this.width,
    required this.height,
    required this.gap,
  });

  final _WalkRadiusMinutes walkRadiusMinutes;
  final bool walkRadiusActive;
  final _MetroLayerMode metroLayerMode;
  final bool showDistrictLayer;
  final bool showUniversitiesLayer;
  final VoidCallback onToggleWalkRadiusMinutes;
  final VoidCallback onToggleMetroLayerMode;
  final VoidCallback onToggleDistrictLayer;
  final VoidCallback onToggleUniversitiesLayer;
  final double width;
  final double height;
  final double gap;

  static const _iconSize = 18.0;
  static const _border = BorderSide(color: Colors.black, width: 1);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (walkRadiusActive) ...[
          _WalkRadiusMinutesButton(
            minutes: walkRadiusMinutes.minutes,
            active: true,
            width: width,
            height: height,
            borderSide: _border,
            onPressed: onToggleWalkRadiusMinutes,
          ),
          SizedBox(width: gap),
        ],
        _MetroLayerModeButton(
          mode: metroLayerMode,
          width: width,
          height: height,
          iconSize: _iconSize,
          borderSide: _border,
          onPressed: onToggleMetroLayerMode,
        ),
        SizedBox(width: gap),
        _buildLayerButton(
          context,
          active: showDistrictLayer,
          iconData: Icons.layers_rounded,
          activeTooltip: context.l10n.hide_district_layer,
          inactiveTooltip: context.l10n.show_district_layer,
          onPressed: onToggleDistrictLayer,
        ),
        SizedBox(width: gap),
        _buildLayerButton(
          context,
          active: showUniversitiesLayer,
          iconData: Icons.school_rounded,
          activeTooltip: context.l10n.hide_universities_layer,
          inactiveTooltip: context.l10n.show_universities_layer,
          onPressed: onToggleUniversitiesLayer,
        ),
        /*
        SizedBox(width: gap),
        _buildLayerButton(
          context,
          active: showGroceryStoresLayer,
          iconData: Icons.local_grocery_store_rounded,
          activeTooltip: context.l10n.hide_grocery_stores_layer,
          inactiveTooltip: context.l10n.show_grocery_stores_layer,
          onPressed: onToggleGroceryStoresLayer,
        ),
        SizedBox(width: gap),
        _buildLayerButton(
          context,
          active: showBusStopsLayer,
          iconData: Icons.directions_bus_rounded,
          activeTooltip: context.l10n.hide_bus_stops_layer,
          inactiveTooltip: context.l10n.show_bus_stops_layer,
          onPressed: onToggleBusStopsLayer,
        ),
        */
      ],
    );
  }

  Widget _buildLayerButton(
    BuildContext context, {
    required bool active,
    required IconData iconData,
    required String activeTooltip,
    required String inactiveTooltip,
    required VoidCallback onPressed,
  }) {
    return SearchFloatingActionButton(
      onPressed: onPressed,
      iconData: iconData,
      tooltip: active ? activeTooltip : inactiveTooltip,
      width: width,
      height: height,
      iconSize: _iconSize,
      backgroundColor: active ? Colors.black : Colors.white,
      foregroundColor: active ? Colors.white : Colors.black,
      borderSide: _border,
      mapOverlay: true,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
  }
}

class _MetroLayerModeButton extends StatelessWidget {
  const _MetroLayerModeButton({
    required this.mode,
    required this.width,
    required this.height,
    required this.iconSize,
    required this.borderSide,
    required this.onPressed,
  });

  final _MetroLayerMode mode;
  final double width;
  final double height;
  final double iconSize;
  final BorderSide borderSide;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _modeBackgroundColor(mode);
    final foregroundColor = _modeForegroundColor(mode);
    return SearchFloatingActionButton(
      onPressed: onPressed,
      iconData: Icons.directions_subway_rounded,
      tooltip: _modeTooltip(context, mode),
      width: width,
      height: height,
      iconSize: iconSize,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderSide: borderSide,
      mapOverlay: true,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
  }

  String _modeTooltip(BuildContext context, _MetroLayerMode mode) {
    return switch (mode) {
      _MetroLayerMode.off => context.l10n.show_metro_stations_layer,
      _MetroLayerMode.all => context.l10n.metro_layer_all_stations,
      _ => context.l10n.metro_layer_select_line,
    };
  }
}

Color _modeAccentColor(_MetroLayerMode mode) {
  return switch (mode) {
    _MetroLayerMode.line1 => const Color(0xFFE53935),
    _MetroLayerMode.line2 => const Color(0xFF1E88E5),
    _MetroLayerMode.line3 => const Color(0xFF43A047),
    _MetroLayerMode.line4 => const Color(0xFFFFB300),
    _MetroLayerMode.all => Colors.black,
    _MetroLayerMode.off => Colors.black54,
  };
}

Color _modeBackgroundColor(_MetroLayerMode mode) {
  return switch (mode) {
    _MetroLayerMode.off => Colors.white,
    _MetroLayerMode.all => Colors.black,
    _ => _modeAccentColor(mode),
  };
}

Color _modeForegroundColor(_MetroLayerMode mode) {
  return mode == _MetroLayerMode.off || mode == _MetroLayerMode.line4
      ? Colors.black
      : Colors.white;
}

class _WalkRadiusMinutesButton extends StatelessWidget {
  const _WalkRadiusMinutesButton({
    required this.minutes,
    required this.active,
    required this.width,
    required this.height,
    required this.borderSide,
    required this.onPressed,
  });

  final int minutes;
  final bool active;
  final double width;
  final double height;
  final BorderSide borderSide;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tooltip = context.l10n.map_walk_radius_button_tooltip(minutes);
    final radius = BorderRadius.circular(height / 2);
    final backgroundColor = active ? Colors.black : Colors.white;
    final foregroundColor = active ? Colors.white : Colors.black;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: backgroundColor,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            onTap: onPressed,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.fromBorderSide(borderSide),
                boxShadow: ThemeState().isBlueTheme
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "$minutes",
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
