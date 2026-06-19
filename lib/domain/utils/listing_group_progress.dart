import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";

/// Shared `current/target` group size for tiles and detail screens.
class ListingGroupProgress {
  const ListingGroupProgress({
    required this.current,
    required this.target,
  });

  final int current;
  final int target;

  String get ratioLabel => "$current/$target";

  /// Group compatibility needs at least owner + one approved member.
  static const int minMembersForGroupCompatibility = 2;

  static bool canShowGroupCompatibility(ListingDetail detail) {
    if (!isGroupFormingDetail(detail)) return false;
    final progress = fromListingDetail(detail);
    if (progress == null) return false;
    return progress.current >= minMembersForGroupCompatibility;
  }

  static bool isGroupFormingListing(Listing listing) {
    return listing.listingTypeId == ListingTypeIds.groupForming ||
        listing.listingType?.code == ListingTypeCodes.groupForming;
  }

  static bool isGroupFormingDetail(ListingDetail detail) {
    return detail.groupContext?.isGroupForming == true ||
        detail.listingTypeId == ListingTypeIds.groupForming ||
        detail.listingType.code == ListingTypeCodes.groupForming;
  }

  /// Feed/listing tile — requires a member count from the listings API.
  static ListingGroupProgress? fromListing(Listing listing) {
    if (!isGroupFormingListing(listing)) return null;
    final target = listing.groupSizeTarget;
    if (target == null || target <= 0) return null;
    final raw = listing.groupMemberCount;
    if (raw == null) return null;
    return ListingGroupProgress(
      current: raw < 1 ? 1 : raw,
      target: target,
    );
  }

  /// Detail screen — prefers viewer [ListingGroupContext] (same source as join UI).
  static ListingGroupProgress? fromListingDetail(ListingDetail detail) {
    if (!isGroupFormingDetail(detail)) return null;
    final ctx = detail.groupContext;
    final target = ctx?.groupSizeTarget ?? detail.groupSizeTarget;
    if (target == null || target <= 0) return null;
    final raw = ctx?.groupMemberCount;
    final current = (raw == null || raw < 1) ? 1 : raw;
    return ListingGroupProgress(current: current, target: target);
  }

  static ListingGroupProgress? fromGroupContext(ListingGroupContext ctx) {
    final target = ctx.groupSizeTarget;
    if (target == null || target <= 0) return null;
    final raw = ctx.groupMemberCount;
    final current = raw < 1 ? 1 : raw;
    return ListingGroupProgress(current: current, target: target);
  }
}
