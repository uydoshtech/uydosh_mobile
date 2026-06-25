part of "../search_results_map_screen.dart";

class _MapFilterRibbon extends StatelessWidget {
  const _MapFilterRibbon({
    required this.onPressed,
    required this.onClose,
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
  final VoidCallback onClose;
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
    final scheme = Theme.of(context).colorScheme;
    final isBlue = ThemeState().isBlueTheme;
    final orbDecoration = isBlue
        ? BoxDecoration(
            color: BlueThemeColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                ThreeDSurfaceStyle.surfaceGradient(context, scheme.surface),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          );
    final orbIconColor = isBlue ? Colors.white : scheme.onSurface;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LiquidGlassPlate(
          height: 56,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.only(left: 12, right: 6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  const SizedBox(width: 18, height: 18),
                  const SizedBox(width: 16),
                  Expanded(
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
                      alignRight: false,
                      height: 56,
                      endPadding: 56,
                      alwaysShowPriceRange: true,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: DecoratedBox(
                      decoration: orbDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 16, color: orbIconColor),
                      ),
                    ),
                    onPressed: onClose,
                    tooltip: L10n.get("close"),
                  ),
                ],
              ),
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      decoration: orbDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.tune, size: 16, color: orbIconColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
