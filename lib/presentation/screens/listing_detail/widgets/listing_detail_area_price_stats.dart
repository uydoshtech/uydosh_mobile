import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Mean/median rent among similar active listings at the same station and/or district.
class ListingDetailAreaPriceStats extends StatelessWidget {
  const ListingDetailAreaPriceStats({required this.listingDetail, super.key});

  final ListingDetail listingDetail;

  Color? _priceIndicatorColor(ThemeData theme, AreaPriceBenchmark benchmark) {
    if (benchmark.median <= 0) return null;

    final ratio = listingDetail.price / benchmark.median;
    if (ratio <= 1.1) return Colors.green.shade400;
    if (ratio <= 1.35) return Colors.amber.shade700;
    return theme.colorScheme.error;
  }

  Widget _priceIndicatorDot(
    BuildContext context, {
    required AreaPriceBenchmark benchmark,
  }) {
    final theme = Theme.of(context);
    final color = _priceIndicatorColor(theme, benchmark);
    if (color == null) return const SizedBox.shrink();

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 1.0,
        ),
      ),
    );
  }

  Widget _benchmarkRow(
    BuildContext context, {
    required AreaPriceBenchmark benchmark,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: _priceIndicatorDot(context, benchmark: benchmark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ),
      ],
    );
  }

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

    if (station == null && district == null) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final stationName =
        _stationPlaceName(context) ?? l10n.listing_area_price_unknown_station;
    return _section(
      context,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (station != null) ...[
            _benchmarkRow(
              context,
              benchmark: station,
              text: l10n.listing_area_price_station_line(
                stationName,
                "${station.median}",
                "${station.sampleCount}",
              ),
            ),
            if (district != null) const SizedBox(height: 6),
          ],
          if (district != null)
            _benchmarkRow(
              context,
              benchmark: district,
              text: l10n.listing_area_price_location_line(
                _districtPlaceName() ?? l10n.listing_area_price_unknown_district,
                "${district.median}",
                "${district.sampleCount}",
              ),
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
              ThemeIcon(
                Icons.insights_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
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
