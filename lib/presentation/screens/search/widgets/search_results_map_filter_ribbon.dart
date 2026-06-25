part of "../search_results_map_screen.dart";

class _MapFilterRibbon extends StatelessWidget {
  const _MapFilterRibbon({
    required this.onPressed,
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    required this.total,
    this.gender,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
  });

  final VoidCallback onPressed;
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
  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: AppliedSearchFiltersBar(
            onPressed: onPressed,
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
            total: total,
            showLabel: false,
            height: 44,
            chipSize: 32,
            alwaysShowPriceRange: true,
          ),
        ),
      ),
    );
  }
}
