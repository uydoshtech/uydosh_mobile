part of "../search_results_map_screen.dart";

class _SearchResultsMapBody extends StatelessWidget {
  const _SearchResultsMapBody({
    required this.canvasListenable,
    required this.overlayListenable,
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
    required this.onMapBackgroundTap,
    required this.onSelectPin,
    required this.onSelectPinGroup,
    required this.onSelectUniversityMarker,
    required this.onClearSelectedMetroStation,
    required this.onSelectedMetroStationChanged,
    required this.onOpenPin,
  });

  final ValueListenable<_SearchMapCanvasProps> canvasListenable;
  final ValueListenable<_SearchMapOverlayProps> overlayListenable;
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
  final ArgumentCallback<Point> onMapBackgroundTap;
  final ValueChanged<ListingMapPin> onSelectPin;
  final ValueChanged<List<ListingMapPin>> onSelectPinGroup;
  final ValueChanged<UniversityMapMarker> onSelectUniversityMarker;
  final VoidCallback onClearSelectedMetroStation;
  final ValueChanged<SubwayStation?> onSelectedMetroStationChanged;
  final ValueChanged<ListingMapPin> onOpenPin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<_SearchMapOverlayProps>(
          valueListenable: overlayListenable,
          builder: (context, overlay, _) {
            if (!overlay.filterRibbonEnabled) return const SizedBox.shrink();
            if (overlay.showFilterRibbon) {
              return _MapFilterRibbon(
                onPressed: onOpenFilters,
                onClose: onCloseFilterRibbon,
                listingTypeId: overlay.listingTypeId,
                gender: overlay.gender,
                locationId: overlay.locationId,
                subwayStationId: overlay.subwayStationId,
                subwayStationIds: overlay.subwayStationIds,
                subwayLineId: overlay.subwayLineId,
                minPrice: overlay.minPrice,
                maxPrice: overlay.maxPrice,
                privateRoom: overlay.privateRoom,
                withPhoto: overlay.withPhoto,
                total: overlay.resultTotal,
              );
            }
            return _MapFilterRibbon(
              onPressed: onOpenFilters,
              emptyLabel: overlay.hasSearchFilters
                  ? "${L10n.get("filters_bar_label")} • ${overlay.resultTotal}"
                  : context.l10n.choose_filters,
              listingTypeId: overlay.listingTypeId,
              gender: overlay.gender,
              locationId: overlay.locationId,
              subwayStationId: overlay.subwayStationId,
              subwayStationIds: overlay.subwayStationIds,
              subwayLineId: overlay.subwayLineId,
              minPrice: overlay.minPrice,
              maxPrice: overlay.maxPrice,
              privateRoom: overlay.privateRoom,
              withPhoto: overlay.withPhoto,
              total: overlay.resultTotal,
            );
          },
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ValueListenableBuilder<_SearchMapCanvasProps>(
                  valueListenable: canvasListenable,
                  builder: (context, canvas, _) {
                    return _SearchMapCanvas(
                      props: canvas,
                      onMapBackgroundTap: onMapBackgroundTap,
                      onSelectPin: onSelectPin,
                      onSelectPinGroup: onSelectPinGroup,
                      onSelectUniversityMarker: onSelectUniversityMarker,
                      onSelectedMetroStationChanged:
                          onSelectedMetroStationChanged,
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<_SearchMapOverlayProps>(
                  valueListenable: overlayListenable,
                  builder: (context, overlay, _) {
                    return _SearchMapOverlays(
                      props: overlay,
                      onOpenFeedView: onOpenFeedView,
                      onOpenEmbeddedSearch: onOpenEmbeddedSearch,
                      onRequestUserLocation: onRequestUserLocation,
                      onToggleDistrictLayer: onToggleDistrictLayer,
                      onToggleWalkRadiusMinutes: onToggleWalkRadiusMinutes,
                      onToggleMetroLayerMode: onToggleMetroLayerMode,
                      onToggleUniversitiesLayer: onToggleUniversitiesLayer,
                      onToggleMapNightMode: onToggleMapNightMode,
                      onClearSelectedPin: onClearSelectedPin,
                      onClearSelectedUniversityMarker:
                          onClearSelectedUniversityMarker,
                      onClearSelectedMetroStation: onClearSelectedMetroStation,
                      onOpenPin: onOpenPin,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchMapCanvas extends StatelessWidget {
  const _SearchMapCanvas({
    required this.props,
    required this.onMapBackgroundTap,
    required this.onSelectPin,
    required this.onSelectPinGroup,
    required this.onSelectUniversityMarker,
    required this.onSelectedMetroStationChanged,
  });

  final _SearchMapCanvasProps props;
  final ArgumentCallback<Point> onMapBackgroundTap;
  final ValueChanged<ListingMapPin> onSelectPin;
  final ValueChanged<List<ListingMapPin>> onSelectPinGroup;
  final ValueChanged<UniversityMapMarker> onSelectUniversityMarker;
  final ValueChanged<SubwayStation?> onSelectedMetroStationChanged;

  @override
  Widget build(BuildContext context) {
    final canvas = props;
    final appNightModeEnabled = Theme.of(context).brightness == Brightness.dark;
    final mapNightModeEnabled =
        canvas.mapNightModeOverride ?? appNightModeEnabled;
    const viewToggleWidth = 61.0;
    const zoomControlsWidth = 48.0;
    const viewToggleGap = 8.0;
    const feedViewButtonHeight = 34.2;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final zoomControlsBottom = canvas.viewToggleBottom +
        feedViewButtonHeight +
        viewToggleGap -
        safeAreaBottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return MediaQuery.removePadding(
          context: context,
          removeBottom: canvas.mapBottomInset > 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: canvas.mapBottomInset),
            child: RepaintBoundary(
              child: YandexMapWidget(
                key: const ValueKey("search-results-yandex-map"),
                apiKey: AppConfig.yandexMapsApiKey,
                pins: canvas.result.pins,
                universityMarkers: canvas.universityMarkers,
                selectedUniversityMarkerId: canvas.selectedUniversityMarkerId,
                selectedMetroStationId: canvas.selectedMetroStationId,
                userUniversityMarkerId: canvas.userUniversityMarkerId,
                selectedUniversityZoomFocusId:
                    canvas.selectedUniversityZoomFocusId,
                selectedListingId: canvas.selectedListingId,
                selectedListingGroupIds: canvas.selectedListingGroupIds,
                title: context.l10n.search_results,
                height: mapHeight,
                cameraOptions: YandexMapCameraOptions(
                  moveOnTargetChange: canvas.activeMapSearch &&
                      (canvas.result.pins.isNotEmpty ||
                          (canvas.locationId != null && canvas.locationId! > 0)),
                  includeUniversityMarkersInCamera: false,
                  fitCityWhenNoPins: !canvas.activeMapSearch,
                ),
                showDefaultPlacemark: false,
                nightModeEnabled: mapNightModeEnabled,
                walkRadiusMinutes: canvas.walkRadiusMinutes.minutes,
                tooltipOptions: const YandexMapTooltipOptions(
                  showUniversityMarker: false,
                  showMetroStation: false,
                ),
                layerOptions: YandexMapLayerOptions(
                  showUserLocation: false,
                  showDistrictLayer: canvas.showDistrictLayer,
                  highlightedLocationId: canvas.activeMapSearch &&
                          canvas.locationId != null &&
                          canvas.locationId! > 0
                      ? canvas.locationId
                      : null,
                  showMetroStationsLayer: canvas.metroLayerMode.showsStations,
                  metroStationLineId: canvas.metroLayerMode.lineId,
                  showGroceryStoresLayer: canvas.showGroceryStoresLayer,
                  showBusStopsLayer: canvas.showBusStopsLayer,
                ),
                userLocationRequestToken: canvas.userLocationRequestToken,
                userLocationLatitude: canvas.userLocationLatitude,
                userLocationLongitude: canvas.userLocationLongitude,
                showLoadingPlaceholderContent: false,
                zoomControlsOptions: YandexMapZoomControlsOptions(
                  right: canvas.placeViewToggleAtBottom
                      ? 16 + ((viewToggleWidth - zoomControlsWidth) / 2)
                      : null,
                  bottom: canvas.placeViewToggleAtBottom
                      ? zoomControlsBottom.clamp(0.0, double.infinity)
                      : null,
                ),
                onSelectedMetroStationChanged: onSelectedMetroStationChanged,
                onMapTap: onMapBackgroundTap,
                onPinTap: onSelectPin,
                onPinGroupTap: onSelectPinGroup,
                onUniversityMarkerTap: onSelectUniversityMarker,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchMapOverlays extends StatelessWidget {
  const _SearchMapOverlays({
    required this.props,
    required this.onOpenFeedView,
    required this.onOpenEmbeddedSearch,
    required this.onRequestUserLocation,
    required this.onToggleDistrictLayer,
    required this.onToggleWalkRadiusMinutes,
    required this.onToggleMetroLayerMode,
    required this.onToggleUniversitiesLayer,
    required this.onToggleMapNightMode,
    required this.onClearSelectedPin,
    required this.onClearSelectedUniversityMarker,
    required this.onClearSelectedMetroStation,
    required this.onOpenPin,
  });

  final _SearchMapOverlayProps props;
  final VoidCallback onOpenFeedView;
  final VoidCallback? onOpenEmbeddedSearch;
  final VoidCallback onRequestUserLocation;
  final VoidCallback onToggleDistrictLayer;
  final VoidCallback onToggleWalkRadiusMinutes;
  final VoidCallback onToggleMetroLayerMode;
  final VoidCallback onToggleUniversitiesLayer;
  final ValueChanged<bool> onToggleMapNightMode;
  final VoidCallback onClearSelectedPin;
  final VoidCallback onClearSelectedUniversityMarker;
  final VoidCallback onClearSelectedMetroStation;
  final ValueChanged<ListingMapPin> onOpenPin;

  @override
  Widget build(BuildContext context) {
    final overlay = props;
    final pin = overlay.selectedPin;
    final pinGroup = overlay.selectedPinGroup;
    final universityMarker = overlay.selectedUniversityMarker;
    final metroStation = overlay.selectedMetroStation;
    final showSelectFiltersTile = !overlay.hasSearchFilters && !overlay.isLoading;
    final showNoResultsTile =
        overlay.hasSearchFilters && !overlay.isLoading && overlay.resultTotal == 0;
    final hasTopTile = pin != null ||
        pinGroup.isNotEmpty ||
        universityMarker != null ||
        showNoResultsTile ||
        (metroStation != null && !showSelectFiltersTile && !showNoResultsTile);
    final appNightModeEnabled = Theme.of(context).brightness == Brightness.dark;
    final mapNightModeEnabled =
        overlay.mapNightModeOverride ?? appNightModeEnabled;
    final mapLoaderColor = mapNightModeEnabled ? Colors.white : Colors.black;
    const viewToggleTop = 4.0;
    const viewToggleWidth = 61.0;
    const feedViewButtonHeight = 34.2;
    const viewToggleHeight = 38.0;
    const viewToggleGap = 8.0;
    const locationPromptBottomMargin = 8.0;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final bottomOverlayInset = overlay.mapBottomInset > safeAreaBottom
        ? overlay.mapBottomInset
        : safeAreaBottom;
    final locationPromptBottom = overlay.placeViewToggleAtBottom
        ? overlay.searchButtonBottom
        : bottomOverlayInset + locationPromptBottomMargin;
    final locationPromptHeight = overlay.placeViewToggleAtBottom
        ? (overlay.viewToggleBottom - overlay.searchButtonBottom) +
            feedViewButtonHeight
        : feedViewButtonHeight;
    const mapOverlayPanelColor = Colors.white;
    const mapOverlayButtonBorder = BorderSide(color: Colors.black, width: 1);
    final feedViewButton = SearchFloatingActionButton(
      onPressed: onOpenFeedView,
      iconData: Icons.view_list_rounded,
      tooltip: L10n.get("open_feed_view"),
      width: viewToggleWidth,
      height: feedViewButtonHeight,
      iconSize: 22.5,
      backgroundColor: mapOverlayPanelColor,
      foregroundColor: Colors.black,
      borderSide: mapOverlayButtonBorder,
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
      borderSide: mapOverlayButtonBorder,
      mapOverlay: true,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: UiPerformancePolicy.solidColorsPreferredForDevice
                ? (overlay.isLoading
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
                    child: overlay.isLoading
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
                                      onClose: onClearSelectedUniversityMarker,
                                    )
                                  : metroStation != null &&
                                          !showSelectFiltersTile &&
                                          !showNoResultsTile
                                      ? MetroStationMapTooltip(
                                          key: ValueKey(
                                            "metro-station-${metroStation.id}",
                                          ),
                                          station: metroStation,
                                          lineColor: AppColors.getMetroLineColor(
                                            metroStation.line,
                                          ),
                                          onClose: onClearSelectedMetroStation,
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
                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!overlay.placeViewToggleAtBottom) ...[
                              feedViewButton,
                              const SizedBox(height: viewToggleGap),
                            ],
                            _MapLayerToggleButtons(
                              walkRadiusMinutes: overlay.walkRadiusMinutes,
                              walkRadiusActive: metroStation != null ||
                                  universityMarker != null,
                              metroLayerMode: overlay.metroLayerMode,
                              showDistrictLayer: overlay.showDistrictLayer,
                              showUniversitiesLayer:
                                  overlay.showUniversitiesLayer,
                              onToggleWalkRadiusMinutes:
                                  onToggleWalkRadiusMinutes,
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (overlay.placeViewToggleAtBottom)
          Positioned(
            right: 16,
            bottom: overlay.viewToggleBottom,
            child: PointerInterceptor(child: feedViewButton),
          ),
        if (overlay.placeViewToggleAtBottom && overlay.hasEmbeddedSearch)
          Positioned(
            right: 16,
            bottom: overlay.searchButtonBottom,
            child: PointerInterceptor(
              child: SearchFloatingActionButton(
                onPressed: onOpenEmbeddedSearch,
                iconData: Icons.search,
                width: viewToggleWidth,
                height: feedViewButtonHeight,
                iconSize: 22.5,
                backgroundColor: mapOverlayPanelColor,
                foregroundColor: Colors.black,
                borderSide: mapOverlayButtonBorder,
                mapOverlay: true,
                elevation: ThemeState().isBlueTheme ? null : 8,
              ),
            ),
          ),
        if (overlay.showLocationPrompt)
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
