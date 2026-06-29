import "package:flutter/material.dart";
import "package:uy_dosh/base/state/admin_feature_flags_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_area_price_stats.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_group_budget_stats.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_meta_badges.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";

/// Meta chips and optional area price stats in one [ListingDetailTileShell].
///
/// Expansion is driven from here so taps on the badges row and on the price
/// header/body can all toggle the section.
class ListingDetailMetaAndPriceTile extends StatefulWidget {
  const ListingDetailMetaAndPriceTile({required this.listingDetail, super.key});

  final ListingDetail listingDetail;

  @override
  State<ListingDetailMetaAndPriceTile> createState() =>
      _ListingDetailMetaAndPriceTileState();
}

class _ListingDetailMetaAndPriceTileState extends State<ListingDetailMetaAndPriceTile> {
  bool _priceExpanded = false;

  void _togglePriceSection() {
    HapticFeedbackUtils.selection();
    setState(() => _priceExpanded = !_priceExpanded);
  }

  bool _shouldShowAreaPriceInsights(ListingDetail listingDetail) {
    if (listingDetail.listingType.code == ListingTypeCodes.roomNeeded ||
        listingDetail.listingType.code == ListingTypeCodes.groupForming ||
        listingDetail.price <= 0) {
      return false;
    }
    if (!AdminFeatureFlagsState().showPriceInsights) return false;
    final stats = listingDetail.areaPriceStats;
    if (stats == null) return false;
    return stats.subwayStation != null || stats.location != null;
  }

  bool _shouldShowGroupBudgetPerPerson(ListingDetail listingDetail) {
    return listingDetail.listingType.code == ListingTypeCodes.groupForming &&
        listingDetail.price > 0;
  }

  @override
  Widget build(BuildContext context) {
    AdminFeatureFlagsState().ensureLoaded();
    return ListenableBuilder(
      listenable: AdminFeatureFlagsState(),
      builder: (context, _) {
        final listingDetail = widget.listingDetail;
        final showAreaPrice = _shouldShowAreaPriceInsights(listingDetail);
        final showGroupBudget = _shouldShowGroupBudgetPerPerson(listingDetail);
        final showExpandableSection = showAreaPrice || showGroupBudget;
        return SizedBox(
          width: double.infinity,
          child: ListingDetailTileShell(
            useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListingDetailMetaBadges(
                    listingDetail: listingDetail,
                    onBackgroundTap:
                        showExpandableSection ? _togglePriceSection : null,
                  ),
                  if (showGroupBudget)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: ListingDetailGroupBudgetStats(
                        listingDetail: listingDetail,
                        expanded: _priceExpanded,
                        onToggle: _togglePriceSection,
                      ),
                    )
                  else if (showAreaPrice)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: ListingDetailAreaPriceStats(
                        listingDetail: listingDetail,
                        expanded: _priceExpanded,
                        onToggle: _togglePriceSection,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
