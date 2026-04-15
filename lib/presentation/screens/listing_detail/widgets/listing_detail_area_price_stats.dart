import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Mean/median rent among similar active listings at the same station and/or district.
class ListingDetailAreaPriceStats extends StatelessWidget {
  const ListingDetailAreaPriceStats({required this.listingDetail, super.key});

  final ListingDetail listingDetail;

  int _priceIndicatorLevel(AreaPriceBenchmark benchmark) {
    if (benchmark.median <= 0) return 0;

    final ratio = listingDetail.price / benchmark.median;
    // More filled disks = more expensive vs median:
    // 1 = green (cheap/ok), 2 = yellow (somewhat expensive), 3 = red (expensive)
    if (ratio <= 1.1) return 1;
    if (ratio <= 1.35) return 2;
    return 3;
  }

  Widget _priceIndicatorDisks(
    BuildContext context, {
    required AreaPriceBenchmark benchmark,
  }) {
    final theme = Theme.of(context);
    final level = _priceIndicatorLevel(benchmark);
    if (level <= 0) return const SizedBox.shrink();

    const size = 10.0;
    const gap = 1.0; // pixels between disks
    const step = size + gap;

    final emptyBase = theme.colorScheme.onSurfaceVariant;
    final filledBase = switch (level) {
      1 => Colors.green.shade400,
      2 => Colors.amber.shade700,
      _ => theme.colorScheme.error,
    };

    Widget disk(int idx) {
      final filled = idx < level;
      final borderColor =
          filled ? filledBase : emptyBase.withOpacity(0.7);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? filledBase : emptyBase.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 1.4,
          ),
        ),
      );
    }

    return SizedBox(
      width: size + step * 2,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0 * step, child: disk(0)),
          Positioned(left: 1 * step, child: disk(1)),
          Positioned(left: 2 * step, child: disk(2)),
        ],
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
          child: _priceIndicatorDisks(context, benchmark: benchmark),
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
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 6),
              iconColor: theme.colorScheme.onSurfaceVariant,
              collapsedIconColor: theme.colorScheme.onSurfaceVariant,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ThemeIcon(
                    Icons.insights_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.listing_area_price_heading,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              children: [body],
            ),
          ),
        ],
      ),
    );
  }
}
