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
    required this.showDistrictLayer,
    required this.showMetroStationsLayer,
    required this.showUniversitiesLayer,
    required this.showGroceryStoresLayer,
    required this.showBusStopsLayer,
    required this.showLocationPrompt,
    required this.userLocationRequestToken,
    required this.placeViewToggleAtBottom,
    required this.searchButtonBottom,
    required this.viewToggleBottom,
    required this.onOpenFilters,
    required this.onOpenEmbeddedSearch,
    required this.onOpenFeedView,
    required this.onRequestUserLocation,
    required this.onToggleDistrictLayer,
    required this.onToggleMetroStationsLayer,
    required this.onToggleUniversitiesLayer,
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
  final bool showDistrictLayer;
  final bool showMetroStationsLayer;
  final bool showUniversitiesLayer;
  final bool showGroceryStoresLayer;
  final bool showBusStopsLayer;
  final bool showLocationPrompt;
  final int userLocationRequestToken;
  final bool placeViewToggleAtBottom;
  final double searchButtonBottom;
  final double viewToggleBottom;
  final VoidCallback onOpenFilters;
  final VoidCallback? onOpenEmbeddedSearch;
  final VoidCallback onOpenFeedView;
  final VoidCallback onRequestUserLocation;
  final VoidCallback onToggleDistrictLayer;
  final VoidCallback onToggleMetroStationsLayer;
  final VoidCallback onToggleUniversitiesLayer;
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
    final hasMapTooltipSpace = hasSelectedMetroStation && !showNoResultsTile;
    final hasTopTile = pin != null ||
        pinGroup.isNotEmpty ||
        universityMarker != null ||
        showNoResultsTile ||
        hasMapTooltipSpace;
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
    final locationPromptBottom = safeAreaBottom +
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
      foregroundColor: ThemeState().isBlueTheme ? Colors.black : null,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
    return Column(
      children: [
        _MapFilterRibbon(
          onPressed: onOpenFilters,
          onClose: onOpenFeedView,
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
                  tooltipOptions: YandexMapTooltipOptions(
                    showUniversityMarker: false,
                    showMetroStation: !showNoResultsTile,
                  ),
                  layerOptions: YandexMapLayerOptions(
                    showUserLocation: true,
                    showDistrictLayer: showDistrictLayer,
                    showMetroStationsLayer: showMetroStationsLayer,
                    showGroceryStoresLayer: showGroceryStoresLayer,
                    showBusStopsLayer: showBusStopsLayer,
                  ),
                  userLocationRequestToken: userLocationRequestToken,
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
                              child: const HouseLoadingIndicator(
                                size: 44,
                                color: Colors.black,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    if (!placeViewToggleAtBottom) ...[
                      feedViewButton,
                      const SizedBox(height: viewToggleGap),
                    ],
                    _MapLayerToggleButtons(
                      showMetroStationsLayer: showMetroStationsLayer,
                      showDistrictLayer: showDistrictLayer,
                      showUniversitiesLayer: showUniversitiesLayer,
                      onToggleMetroStationsLayer: onToggleMetroStationsLayer,
                      onToggleDistrictLayer: onToggleDistrictLayer,
                      onToggleUniversitiesLayer: onToggleUniversitiesLayer,
                      width: viewToggleWidth,
                      height: viewToggleHeight,
                      gap: viewToggleGap,
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
                    foregroundColor: Colors.black,
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
    return Material(
      color: Colors.transparent,
      child: LiquidGlassPlate(
        borderRadius: BorderRadius.circular(18),
        sigma: 18,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: ThemeState().isBlueTheme
                    ? BlueThemeColors.primary
                    : scheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
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
                      color: Colors.black,
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
                      color: Colors.black,
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
              foregroundColor: ThemeState().isBlueTheme ? Colors.black : null,
              elevation: ThemeState().isBlueTheme ? null : 6,
            ),
          ],
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
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
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
        ),
      ),
    );
  }
}

class _MapLayerToggleButtons extends StatelessWidget {
  const _MapLayerToggleButtons({
    required this.showMetroStationsLayer,
    required this.showDistrictLayer,
    required this.showUniversitiesLayer,
    required this.onToggleMetroStationsLayer,
    required this.onToggleDistrictLayer,
    required this.onToggleUniversitiesLayer,
    required this.width,
    required this.height,
    required this.gap,
  });

  final bool showMetroStationsLayer;
  final bool showDistrictLayer;
  final bool showUniversitiesLayer;
  final VoidCallback onToggleMetroStationsLayer;
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
        _buildLayerButton(
          context,
          active: showMetroStationsLayer,
          iconData: Icons.directions_subway_rounded,
          activeTooltip: context.l10n.hide_metro_stations_layer,
          inactiveTooltip: context.l10n.show_metro_stations_layer,
          onPressed: onToggleMetroStationsLayer,
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
