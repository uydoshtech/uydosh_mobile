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
    required this.showDistrictLayer,
    required this.showMetroStationsLayer,
    required this.placeViewToggleAtBottom,
    required this.searchButtonBottom,
    required this.viewToggleBottom,
    required this.onOpenFilters,
    required this.onOpenEmbeddedSearch,
    required this.onOpenFeedView,
    required this.onToggleDistrictLayer,
    required this.onToggleMetroStationsLayer,
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
  final bool showDistrictLayer;
  final bool showMetroStationsLayer;
  final bool placeViewToggleAtBottom;
  final double searchButtonBottom;
  final double viewToggleBottom;
  final VoidCallback onOpenFilters;
  final VoidCallback? onOpenEmbeddedSearch;
  final VoidCallback onOpenFeedView;
  final VoidCallback onToggleDistrictLayer;
  final VoidCallback onToggleMetroStationsLayer;
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
    final hasTopTile = pin != null ||
        pinGroup.isNotEmpty ||
        universityMarker != null ||
        hasSelectedMetroStation ||
        showNoResultsTile;
    const viewToggleTop = 4.0;
    const viewToggleWidth = 61.2;
    const feedViewButtonHeight = 34.2;
    const viewToggleHeight = 38.0;
    const viewToggleGap = 8.0;
    const zoomControlsWidth = 48.0;
    const metroTooltipReservedHeight = 64.0;
    const layerButtonIconSize = 18.0;
    const layerButtonBorder = BorderSide(color: Colors.black, width: 1);
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
    final districtLayerButton = SearchFloatingActionButton(
      onPressed: onToggleDistrictLayer,
      iconData: Icons.layers_rounded,
      tooltip: showDistrictLayer
          ? context.l10n.hide_district_layer
          : context.l10n.show_district_layer,
      width: viewToggleWidth,
      height: viewToggleHeight,
      iconSize: layerButtonIconSize,
      backgroundColor: showDistrictLayer ? Colors.black : Colors.white,
      foregroundColor: showDistrictLayer ? Colors.white : Colors.black,
      borderSide: layerButtonBorder,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
    final metroStationsLayerButton = SearchFloatingActionButton(
      onPressed: onToggleMetroStationsLayer,
      iconData: Icons.directions_subway_rounded,
      tooltip: showMetroStationsLayer
          ? context.l10n.hide_metro_stations_layer
          : context.l10n.show_metro_stations_layer,
      width: viewToggleWidth,
      height: viewToggleHeight,
      iconSize: layerButtonIconSize,
      backgroundColor: showMetroStationsLayer ? Colors.black : Colors.white,
      foregroundColor: showMetroStationsLayer ? Colors.white : Colors.black,
      borderSide: layerButtonBorder,
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
                  selectedListingId: selectedPin?.listingId,
                  selectedListingGroupIds: [
                    for (final pin in pinGroup) pin.listingId,
                  ],
                  title: context.l10n.search_results,
                  height: double.infinity,
                  moveCameraOnTargetChange: result.pins.isNotEmpty,
                  includeUniversityMarkersInCamera: false,
                  showDefaultPlacemark: false,
                  showUniversityMarkerTooltip: false,
                  showUserLocation: true,
                  showDistrictLayer: showDistrictLayer,
                  showMetroStationsLayer: showMetroStationsLayer,
                  showLoadingPlaceholderContent: false,
                  zoomControlsRight: placeViewToggleAtBottom
                      ? 16 + ((viewToggleWidth - zoomControlsWidth) / 2)
                      : null,
                  zoomControlsBottom: placeViewToggleAtBottom
                      ? viewToggleBottom + feedViewButtonHeight + viewToggleGap
                      : null,
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
                        ? const Center(
                            key: ValueKey("map-results-loading"),
                            child: HouseLoadingIndicator(
                              size: 44,
                              color: Colors.black,
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
                      child: pin != null
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
                                  : showNoResultsTile
                                      ? _NoMapResultsTile(
                                          key: const ValueKey("no-map-results"),
                                          label: L10n.get("no_results"),
                                        )
                                      : hasSelectedMetroStation
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        metroStationsLayerButton,
                        const SizedBox(width: viewToggleGap),
                        districtLayerButton,
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
                    foregroundColor: Colors.black,
                    elevation: ThemeState().isBlueTheme ? null : 8,
                  ),
                ),
            ],
          ),
        ),
      ],
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
