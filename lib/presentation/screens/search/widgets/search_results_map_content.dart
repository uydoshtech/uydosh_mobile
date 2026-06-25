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
    required this.showRefreshAreaButton,
    required this.loading,
    required this.onOpenFilters,
    required this.onOpenFeedView,
    required this.onRefreshVisibleArea,
    required this.onMapCreated,
    required this.onCameraPositionChanged,
    required this.onClearSelectedPin,
    required this.onSelectPin,
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
  final bool showRefreshAreaButton;
  final bool loading;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenFeedView;
  final VoidCallback onRefreshVisibleArea;
  final MapCreatedCallback onMapCreated;
  final CameraPositionCallback onCameraPositionChanged;
  final VoidCallback onClearSelectedPin;
  final ValueChanged<ListingMapPin> onSelectPin;
  final ValueChanged<ListingMapPin> onOpenPin;

  @override
  Widget build(BuildContext context) {
    final pin = selectedPin;
    return Column(
      children: [
        _MapFilterRibbon(
          onPressed: onOpenFilters,
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
                  title: context.l10n.search_results,
                  height: double.infinity,
                  moveCameraOnTargetChange: result.pins.isNotEmpty,
                  showDefaultPlacemark: false,
                  onMapCreated: onMapCreated,
                  onCameraPositionChanged: onCameraPositionChanged,
                  onMapTap: (_) => onClearSelectedPin(),
                  onPinTap: onSelectPin,
                ),
              ),
              if (pin != null)
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  child: _PinSummaryTooltip(
                    pin: pin,
                    onClose: onClearSelectedPin,
                    onOpen: () => onOpenPin(pin),
                  ),
                ),
              Positioned(
                right: 16,
                top: 12,
                child: Transform.scale(
                  scale: 0.92,
                  child: SearchFloatingActionButton(
                    onPressed: onOpenFeedView,
                    iconData: Icons.view_list_rounded,
                    tooltip: L10n.get("open_feed_view"),
                    elevation: ThemeState().isBlueTheme ? null : 8,
                  ),
                ),
              ),
              if (showRefreshAreaButton || loading)
                Positioned(
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _RefreshAreaButton(
                      loading: loading,
                      onPressed: onRefreshVisibleArea,
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
