part of "../search_results_map_screen.dart";

class _SearchResultsMapContent extends StatelessWidget {
  const _SearchResultsMapContent({
    required this.result,
    required this.isLoading,
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
    required this.showUniversitiesLayer,
    required this.showGroceryStoresLayer,
    required this.showBusStopsLayer,
    required this.mapNightModeOverride,
    required this.showLocationPrompt,
    required this.showFilterRibbon,
    required this.userLocationRequestToken,
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
    required this.onSelectMetroLayerMode,
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
  final bool showUniversitiesLayer;
  final bool showGroceryStoresLayer;
  final bool showBusStopsLayer;
  final bool? mapNightModeOverride;
  final bool showLocationPrompt;
  final bool showFilterRibbon;
  final int userLocationRequestToken;
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
  final ValueChanged<_MetroLayerMode> onSelectMetroLayerMode;
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
    final showNoResultsTile = !isLoading && result.total == 0;
    final showChooseFiltersTile = !showFilterRibbon;
    final hasMapTooltipSpace = hasSelectedMetroStation && !showNoResultsTile;
    final hasTopTile = pin != null ||
        pinGroup.isNotEmpty ||
        universityMarker != null ||
        showChooseFiltersTile ||
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
    const brandMarkSize = 42.0;
    const brandMarkInset = 10.0;
    const locationPromptGapAboveBrandMark = 20.0;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final brandMarkBottomInset =
        mapBottomInset > safeAreaBottom ? mapBottomInset : safeAreaBottom;
    final locationPromptBottom = brandMarkBottomInset +
        brandMarkInset +
        brandMarkSize +
        locationPromptGapAboveBrandMark;
    final zoomControlsBottom = viewToggleBottom +
        feedViewButtonHeight +
        viewToggleGap -
        safeAreaBottom;
    final feedViewButton = SearchFloatingActionButton(
      onPressed: onOpenFeedView,
      iconData: Icons.view_list_rounded,
      tooltip: L10n.get("open_feed_view"),
      width: viewToggleWidth,
      height: feedViewButtonHeight,
      iconSize: 22.5,
      foregroundColor: mapNightModeEnabled
          ? Colors.white
          : ThemeState().isBlueTheme
              ? Colors.black
              : null,
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
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
    return Column(
      children: [
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
          ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
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
                    moveOnTargetChange: result.pins.isNotEmpty,
                    includeUniversityMarkersInCamera: false,
                  ),
                  showDefaultPlacemark: false,
                  nightModeEnabled: mapNightModeEnabled,
                  tooltipOptions: YandexMapTooltipOptions(
                    showUniversityMarker: false,
                    showMetroStation: !showNoResultsTile,
                  ),
                  layerOptions: YandexMapLayerOptions(
                    showUserLocation: true,
                    showDistrictLayer: showDistrictLayer,
                    showMetroStationsLayer: metroLayerMode.showsStations,
                    metroStationLineId: metroLayerMode.lineId,
                    showGroceryStoresLayer: showGroceryStoresLayer,
                    showBusStopsLayer: showBusStopsLayer,
                  ),
                  userLocationRequestToken: userLocationRequestToken,
                  showLoadingPlaceholderContent: false,
                  brandMarkBottomInset: brandMarkBottomInset,
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
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MapTooltipFadeTransition(
                      child: showChooseFiltersTile
                          ? _NoMapResultsTile(
                              key: const ValueKey("choose-map-filters"),
                              label: context.l10n.choose_filters,
                              onPressed: onOpenFilters,
                            )
                          : showNoResultsTile
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
                                              ? const SizedBox(
                                                  key: ValueKey(
                                                    "metro-station-tooltip-space",
                                                  ),
                                                  width: double.infinity,
                                                  height:
                                                      metroTooltipReservedHeight,
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
                              metroLayerMode: metroLayerMode,
                              showDistrictLayer: showDistrictLayer,
                              showUniversitiesLayer: showUniversitiesLayer,
                              onSelectMetroLayerMode: onSelectMetroLayerMode,
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
              if (placeViewToggleAtBottom)
                Positioned(
                  right: 16,
                  bottom: viewToggleBottom,
                  child: feedViewButton,
                ),
              if (placeViewToggleAtBottom && onOpenEmbeddedSearch != null)
                Positioned(
                  right: 16,
                  bottom: searchButtonBottom,
                  child: SearchFloatingActionButton(
                    onPressed: onOpenEmbeddedSearch,
                    iconData: Icons.search,
                    width: viewToggleWidth,
                    height: feedViewButtonHeight,
                    iconSize: 22.5,
                    foregroundColor:
                        mapNightModeEnabled ? Colors.white : Colors.black,
                    elevation: ThemeState().isBlueTheme ? null : 8,
                  ),
                ),
              if (showLocationPrompt)
                Positioned(
                  left: 12,
                  right: 88,
                  bottom: locationPromptBottom,
                  child: _MapLocationPromptCard(
                    onPressed: onRequestUserLocation,
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
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeState = ThemeState();
    final solidColors = UiPerformancePolicy.solidColorsPreferredForDevice;
    final lightThemeForeground =
        themeState.isLightTheme ? Colors.white : Colors.black;
    final child = Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: themeState.isBlueTheme
                ? BlueThemeColors.primary
                : scheme.primary,
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
            padding: EdgeInsets.all(8),
            child: ThemeIcon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 18,
              useThemeColor: false,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L10n.get("map_location_prompt_title"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: lightThemeForeground,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                L10n.get("map_location_prompt_body"),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: lightThemeForeground,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SearchFloatingActionButton(
          onPressed: onPressed,
          iconData: Icons.near_me_rounded,
          tooltip: L10n.get("map_location_prompt_action"),
          width: 42,
          height: 38,
          iconSize: 19,
          foregroundColor: lightThemeForeground,
          elevation: themeState.isBlueTheme ? null : 6,
        ),
      ],
    );

    if (isAndroidDevice) {
      return Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: child,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: LiquidGlassPlate(
        borderRadius: BorderRadius.circular(18),
        sigma: 18,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: child,
      ),
    );
  }
}

class _NoMapResultsTile extends StatelessWidget {
  const _NoMapResultsTile({
    required this.label,
    this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

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

    return Material(
      color: solidColors ? scheme.surface : Colors.transparent,
      borderRadius: borderRadius,
      child: DecoratedBox(
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
        child: onPressed == null
            ? child
            : InkWell(
                borderRadius: borderRadius,
                onTap: onPressed,
                child: child,
              ),
      ),
    );
  }
}

class _MapLayerToggleButtons extends StatelessWidget {
  const _MapLayerToggleButtons({
    required this.metroLayerMode,
    required this.showDistrictLayer,
    required this.showUniversitiesLayer,
    required this.onSelectMetroLayerMode,
    required this.onToggleDistrictLayer,
    required this.onToggleUniversitiesLayer,
    required this.width,
    required this.height,
    required this.gap,
  });

  final _MetroLayerMode metroLayerMode;
  final bool showDistrictLayer;
  final bool showUniversitiesLayer;
  final ValueChanged<_MetroLayerMode> onSelectMetroLayerMode;
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
        _MetroLayerModeButton(
          mode: metroLayerMode,
          width: width,
          height: height,
          iconSize: _iconSize,
          borderSide: _border,
          onSelected: onSelectMetroLayerMode,
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
    required this.onSelected,
  });

  final _MetroLayerMode mode;
  final double width;
  final double height;
  final double iconSize;
  final BorderSide borderSide;
  final ValueChanged<_MetroLayerMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _modeBackgroundColor(mode);
    final foregroundColor = _modeForegroundColor(mode);
    return SearchFloatingActionButton(
      onPressed: () => onSelected(mode.next),
      iconData: Icons.directions_subway_rounded,
      tooltip: _modeTooltip(context, mode),
      width: width,
      height: height,
      iconSize: iconSize,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderSide: borderSide,
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
