import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";

class ListingUtils {
  /// Returns true if the listing is featured (featured_at is not null)
  static bool isCurrentlyFeatured(Listing listing) {
    return listing.featuredAt != null;
  }

  /// Returns true if the listing detail is featured (featured_at is not null)
  static bool isCurrentlyFeaturedDetail(ListingDetail listingDetail) {
    return listingDetail.featuredAt != null;
  }

  /// Types 1 (room needed) and 2 (roommate needed) use preset hashtag titles
  /// on create-listing; same rule for read-only display.
  static bool usesPresetListingTitle(int listingTypeId) {
    return listingTypeId == ListingTypeIds.roomNeeded ||
        listingTypeId == ListingTypeIds.roommateNeeded ||
        listingTypeId == ListingTypeIds.groupForming;
  }

  /// L10n key for the preset title ([CreateListingScreen] rules).
  /// [gender]: 1 = male, 2 = female; other values default like create flow (1).
  static String presetListingTitleL10nKey({
    required int listingTypeId,
    int? gender,
  }) {
    final g = (gender == 1 || gender == 2) ? gender! : 1;
    if (listingTypeId == ListingTypeIds.groupForming) {
      return "title_group_forming";
    }
    if (listingTypeId == 2) {
      return g == 1 ? "title_male_roommate" : "title_female_roommate";
    }
    return g == 1 ? "title_male_room" : "title_female_room";
  }
}
