import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_views_stats_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";

/// Owner toolbar with view count and promote button for listing detail.
class ListingDetailOwnerToolbar extends StatelessWidget {
  const ListingDetailOwnerToolbar({
    required this.listingDetail,
    required this.viewCount,
    required this.isLoadingViewCount,
    required this.isToggling,
  required this.onToggleFeature,
  super.key,
});

  final ListingDetail listingDetail;
  final int? viewCount;
  final bool isLoadingViewCount;
  final bool isToggling;
  final VoidCallback? onToggleFeature;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Row(
        children: [
          if (isLoadingViewCount && viewCount == null)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "...",
                  style: TextStyle(
                    fontSize: 14,
                    color: ListingDetailThemeHelper.secondaryTextColorFromContext(
                      context,
                    ),
                  ),
                ),
              ],
            )
          else if (viewCount != null)
            GestureDetector(
              onTap: () {
                HapticFeedbackUtils.impact();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ListingViewsStatsScreen(
                      listingId: listingDetail.id,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.eye,
                    size: 18,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    L10n.get("listing_views_by_others")
                        .replaceAll("{count}", viewCount.toString()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ListingDetailThemeHelper.secondaryTextColorFromContext(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          TextButton.icon(
            onPressed: isToggling ? null : onToggleFeature,
            icon: isToggling
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ListingDetailThemeHelper.iconColor,
                    ),
                  )
                : Icon(
                    ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
                        ? CupertinoIcons.arrow_down
                        : CupertinoIcons.arrow_up,
                    size: 16,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
            label: Text(
              L10n.get(
                ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
                    ? "remove_from_top"
                    : "promote_listing",
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ListingDetailThemeHelper.iconColor,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
