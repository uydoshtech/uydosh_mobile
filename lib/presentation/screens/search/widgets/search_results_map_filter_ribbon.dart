part of "../search_results_map_screen.dart";

class _MapFilterRibbon extends StatelessWidget {
  const _MapFilterRibbon({
    required this.onPressed,
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    this.has3dTour = false,
    this.total,
    this.onClose,
    this.emptyLabel,
    this.gender,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds = const [],
    this.subwayLineId,
  });

  static const double _ribbonHeight = 56.0;

  final VoidCallback onPressed;
  final VoidCallback? onClose;
  final String? emptyLabel;
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
  final bool has3dTour;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBlue = ThemeState().isBlueTheme;
    final label = emptyLabel;
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
            gradient: ThreeDSurfaceStyle.surfaceGradient(
              context,
              scheme.surface,
            ),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          );
    final orbIconColor = isBlue ? Colors.white : scheme.onSurface;
    final hasEmptyLabel = label != null;
    final filterContent = label == null
        ? AppliedSearchFiltersBar(
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
            has3dTour: has3dTour,
            total: total,
            showLabel: false,
            alignRight: false,
            height: _ribbonHeight,
            endPadding: onClose == null ? 0 : 56,
            alwaysShowPriceRange: true,
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: SizedBox(
              height: _ribbonHeight,
              child: Row(
                children: [
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: orbDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.search,
                          size: 16,
                          color: orbIconColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LiquidGlassPlate(
        height: _ribbonHeight,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.only(left: 12, right: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                if (!hasEmptyLabel) ...[
                  // Reserve space for the tune icon which is drawn above the chips.
                  const SizedBox(width: 18, height: 18),
                  // Small breathing room between the tune icon and the first chip.
                  const SizedBox(width: 16),
                ],
                Expanded(child: filterContent),
                if (onClose != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
            if (!hasEmptyLabel)
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
    );
  }
}
