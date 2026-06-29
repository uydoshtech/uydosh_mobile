import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_search_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_group_shortlist_sheet.dart";

abstract final class GroupHousingFlow {
  static Future<void> openSearch({
    required BuildContext context,
    required ListingDetail groupListingDetail,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GroupHousingSearchScreen(
          groupListingDetail: groupListingDetail,
        ),
      ),
    );
  }

  static Future<void> openShortlistSheet({
    required BuildContext context,
    required int groupListingId,
    required bool isOwner,
    ListingDetail? groupListingDetail,
    VoidCallback? onChanged,
  }) async {
    if (!context.mounted) return;
    await showListingGroupShortlistSheet(
      context: context,
      groupListingId: groupListingId,
      isOwner: isOwner,
      groupListingDetail: groupListingDetail,
      onChanged: onChanged,
    );
    await GroupShortlistState().refreshCount(groupListingId);
  }

  static String savedListingsLabel(int count) {
    if (count <= 0) return L10n.get("group_shortlist_title");
    return L10n.getWithParams(
      "group_shortlist_title_count",
      params: {"count": count.toString()},
    );
  }
}
