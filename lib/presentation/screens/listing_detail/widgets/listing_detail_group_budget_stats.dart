import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Per-person (and optional total) budget breakdown for `group_forming` listings.
class ListingDetailGroupBudgetStats extends StatelessWidget {
  const ListingDetailGroupBudgetStats({
    required this.listingDetail,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final ListingDetail listingDetail;
  final bool expanded;
  final VoidCallback onToggle;

  static const double _leadingColumnWidth = 38;

  int? get _groupSizeTarget {
    final target =
        listingDetail.groupContext?.groupSizeTarget ?? listingDetail.groupSizeTarget;
    if (target == null || target < 2) return null;
    return target;
  }

  ({int min, int max}) get _perPersonBounds =>
      PriceRangeHelper.resolveListingDisplayBounds(
        storedPrice: listingDetail.price,
        listingTypeCode: ListingTypeCodes.groupForming,
        minPrice: listingDetail.minPrice,
        maxPrice: listingDetail.maxPrice,
      );

  String _formatRange(int min, int max) =>
      PriceRangeHelper.formatListingPriceRangeWithCurrency(min, max);

  Widget _detailRow(BuildContext context, {required String text}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: _leadingColumnWidth),
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

  @override
  Widget build(BuildContext context) {
    final bounds = _perPersonBounds;
    final perPersonRange = _formatRange(bounds.min, bounds.max);
    final groupSize = _groupSizeTarget;

    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final lines = <String>[
          L10n.getWithParams(
            "group_budget_per_person_amount_line",
            params: {"range": perPersonRange},
          ),
        ];
        if (groupSize != null) {
          lines.add(
            L10n.getWithParams(
              "group_budget_total_apartment_line",
              params: {
                "count": "$groupSize",
                "range": _formatRange(
                  bounds.min * groupSize,
                  bounds.max * groupSize,
                ),
              },
            ),
          );
        }

        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              _detailRow(context, text: lines[i]),
            ],
          ],
        );

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
                        width: _leadingColumnWidth,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ThemeIcon(
                            Icons.payments_outlined,
                            size: 18,
                            color: iconColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          L10n.get("group_budget_per_person_heading"),
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
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: onToggle,
                        child: body,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
