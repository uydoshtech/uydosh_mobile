part of "../search_results_map_screen.dart";

class _SearchResultsMapContent extends StatelessWidget {
  const _SearchResultsMapContent({
    required this.result,
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    required this.selectedPin,
    required this.selectedUniversityMarker,
    required this.universityMarkers,
    required this.showDistrictLayer,
    required this.onOpenFilters,
    required this.onOpenFeedView,
    required this.onToggleDistrictLayer,
    required this.onClearSelectedPin,
    required this.onClearSelectedUniversityMarker,
    required this.onSelectPin,
    required this.onSelectUniversityMarker,
    required this.onOpenPin,
    this.gender,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
  });

  final _SearchMapResult result;
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
  final UniversityMapMarker? selectedUniversityMarker;
  final List<UniversityMapMarker> universityMarkers;
  final bool showDistrictLayer;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenFeedView;
  final VoidCallback onToggleDistrictLayer;
  final VoidCallback onClearSelectedPin;
  final VoidCallback onClearSelectedUniversityMarker;
  final ValueChanged<ListingMapPin> onSelectPin;
  final ValueChanged<UniversityMapMarker> onSelectUniversityMarker;
  final ValueChanged<ListingMapPin> onOpenPin;

  @override
  Widget build(BuildContext context) {
    final pin = selectedPin;
    final universityMarker = selectedUniversityMarker;
    final hasTooltip = pin != null || universityMarker != null;
    const viewToggleTop = 4.0;
    const viewToggleHeight = 38.0;
    const viewToggleGap = 8.0;
    final feedViewButton = SearchFloatingActionButton(
      onPressed: onOpenFeedView,
      iconData: Icons.view_list_rounded,
      tooltip: L10n.get("open_feed_view"),
      width: 68,
      height: viewToggleHeight,
      foregroundColor: ThemeState().isBlueTheme ? Colors.black : null,
      elevation: ThemeState().isBlueTheme ? null : 8,
    );
    final districtLayerButton = SearchFloatingActionButton(
      onPressed: onToggleDistrictLayer,
      iconData:
          showDistrictLayer ? Icons.layers_clear_rounded : Icons.layers_rounded,
      tooltip: L10n.get(
        showDistrictLayer ? "hide_district_layer" : "show_district_layer",
      ),
      width: 68,
      height: viewToggleHeight,
      backgroundColor: showDistrictLayer ? AppColors.primary : null,
      foregroundColor: showDistrictLayer
          ? Colors.white
          : ThemeState().isBlueTheme
              ? Colors.black
              : null,
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
                  title: context.l10n.search_results,
                  height: double.infinity,
                  moveCameraOnTargetChange: result.pins.isNotEmpty,
                  showDefaultPlacemark: false,
                  showUniversityMarkerTooltip: false,
                  showUserLocation: true,
                  showDistrictLayer: showDistrictLayer,
                  onMapTap: (_) {
                    onClearSelectedPin();
                    onClearSelectedUniversityMarker();
                  },
                  onPinTap: onSelectPin,
                  onUniversityMarkerTap: onSelectUniversityMarker,
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
                          : universityMarker != null
                              ? UniversityMapTooltip(
                                  key: ValueKey(
                                    "university-${universityMarker.id}",
                                  ),
                                  marker: universityMarker,
                                  onClose: onClearSelectedUniversityMarker,
                                )
                              : null,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: hasTooltip ? viewToggleGap : 0,
                    ),
                    feedViewButton,
                    const SizedBox(height: viewToggleGap),
                    districtLayerButton,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
