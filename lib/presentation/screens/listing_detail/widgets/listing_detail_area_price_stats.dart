import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Mean/median rent among similar active listings at the same station and/or district.
class ListingDetailAreaPriceStats extends StatelessWidget {
  const ListingDetailAreaPriceStats({required this.listingDetail, super.key});

  final ListingDetail listingDetail;

  String? _stationPlaceName(BuildContext context) {
    final s = listingDetail.subwayStation;
    if (s == null) return null;
    switch (LanguageState().currentLanguage) {
      case "uz":
        return s.nameUz;
      case "ru":
        return s.nameRu;
      default:
        return s.nameEn;
    }
  }

  String? _districtPlaceName() {
    final l = listingDetail.location;
    if (l == null) return null;
    switch (LanguageState().currentLanguage) {
      case "uz":
        return l.shortNameUz.isNotEmpty ? l.shortNameUz : l.nameUz;
      case "ru":
        return l.shortNameRu.isNotEmpty ? l.shortNameRu : l.nameRu;
      default:
        return l.shortNameEn.isNotEmpty ? l.shortNameEn : l.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = listingDetail.areaPriceStats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final station = stats.subwayStation;
    final district = stats.location;
    final hasGeo =
        listingDetail.subwayStationId != null || listingDetail.locationId != null;

    if (station == null && district == null) {
      if (!hasGeo) return const SizedBox.shrink();
      return _section(
        context,
        body: Text(
          context.l10n.listing_area_price_insufficient_data,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.35,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final stationName =
        _stationPlaceName(context) ?? l10n.listing_area_price_unknown_station;
    return _section(
      context,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (station != null) ...[
            Text(
              l10n.listing_area_price_station_line(
                stationName,
                "${station.median}",
                "${station.mean}",
                "${station.sampleCount}",
              ),
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            if (district != null) const SizedBox(height: 6),
          ],
          if (district != null)
            Text(
              l10n.listing_area_price_location_line(
                _districtPlaceName() ?? l10n.listing_area_price_unknown_district,
                "${district.median}",
                "${district.mean}",
                "${district.sampleCount}",
              ),
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, {required Widget body}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.insights_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.listing_area_price_heading,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    body,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
