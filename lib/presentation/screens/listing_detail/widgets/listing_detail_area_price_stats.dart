import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Mean/median rent among similar active listings at the same station and/or district.
class ListingDetailAreaPriceStats extends StatelessWidget {
  const ListingDetailAreaPriceStats({
    required this.listingDetail,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final ListingDetail listingDetail;
  final bool expanded;
  final VoidCallback onToggle;

  /// 1 = cheap vs median, 2 = medium, 3 = expensive; 0 = unknown (no median).
  int _priceIndicatorLevel(AreaPriceBenchmark benchmark) {
    if (benchmark.median <= 0) return 0;
    final ratio = listingDetail.price / benchmark.median;
    if (ratio <= 1.1) return 1;
    if (ratio <= 1.35) return 2;
    return 3;
  }

  Color _priceTierColor(BuildContext context, int level) {
    return switch (level) {
      1 => Colors.green.shade400,
      2 => Colors.amber.shade700,
      _ => Theme.of(context).colorScheme.error,
    };
  }

  /// Width reserved for the dollar-sign indicator so body rows align
  /// regardless of tier, and line up with the header's leading icon column.
  // Must accommodate "$$$" without overflowing into the text column.
  static const double _indicatorColumnWidth = 38;

  /// Plain dollar characters only (no circled icon); count matches [_priceIndicatorLevel].
  Widget _priceTierDollarSigns(
    BuildContext context,
    AreaPriceBenchmark benchmark,
  ) {
    final level = _priceIndicatorLevel(benchmark);
    if (level <= 0) return const SizedBox.shrink();

    final color = _priceTierColor(context, level);
    const fontSize = 15.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < level; i++) ...[
          if (i > 0) const SizedBox(width: 1),
          Text(
            r"$",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _benchmarkRow(
    BuildContext context, {
    required AreaPriceBenchmark benchmark,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _indicatorColumnWidth,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _priceTierDollarSigns(context, benchmark),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.35,
              color: ListingDetailThemeHelper.descriptionTextColor,
            ),
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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        String medianLabel(int medianUzs) =>
            PriceRangeHelper.formatListingPriceRangeWithCurrency(
              medianUzs,
              medianUzs,
            );

        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (station != null) ...[
              _benchmarkRow(
                context,
                benchmark: station,
                text: l10n.listing_area_price_station_line(
                  stationName,
                  medianLabel(station.median),
                ),
              ),
              if (district != null) const SizedBox(height: 4),
            ],
            if (district != null)
              _benchmarkRow(
                context,
                benchmark: district,
                text: l10n.listing_area_price_location_line(
                  _districtPlaceName() ??
                      l10n.listing_area_price_unknown_district,
                  medianLabel(district.median),
                ),
              ),
          ],
        );

        return _section(
          context,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onToggle,
            child: body,
          ),
        );
      },
    );
  }

  Widget _section(BuildContext context, {required Widget body}) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;
    const headerPadding = EdgeInsets.only(top: 4, bottom: 4);
    const childrenTopPadding = EdgeInsets.only(top: 8, bottom: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: headerPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _indicatorColumnWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ThemeIcon(
                        Icons.insights_outlined,
                        size: 18,
                        color: iconColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.listing_area_price_heading,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ListingDetailThemeHelper.descriptionTextColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.expand_more,
                      size: 24,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: expanded
              ? Padding(
                  padding: childrenTopPadding,
                  child: body,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
