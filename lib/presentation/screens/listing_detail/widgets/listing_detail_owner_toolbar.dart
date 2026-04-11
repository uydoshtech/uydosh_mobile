import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_views_stats_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

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
          if ((isLoadingViewCount && viewCount == null) || viewCount != null)
            ThreeDPillButton(
              onPressed: () {
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    CupertinoIcons.eye,
                    size: 18,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
                  const SizedBox(width: 6),
                  if (viewCount != null)
                    Text(
                      L10n.get("listing_views_by_others")
                          .replaceAll("{count}", viewCount.toString()),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ListingDetailThemeHelper
                            .secondaryTextColorFromContext(context),
                      ),
                    )
                  else
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ListingDetailThemeHelper.iconColor,
                      ),
                    ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          ThreeDPillButton(
            onPressed: isToggling ? null : onToggleFeature,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isToggling)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ListingDetailThemeHelper.iconColor,
                    ),
                  )
                else
                  ThemeIcon(
                    ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
                        ? CupertinoIcons.arrow_down
                        : CupertinoIcons.arrow_up,
                    size: 16,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
                const SizedBox(width: 8),
                Text(
                  L10n.get(
                    ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
                        ? "remove_from_top"
                        : "promote_listing",
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
