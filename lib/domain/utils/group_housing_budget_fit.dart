import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

enum GroupHousingBudgetFit {
  fits,
  above,
  unknown,
}

abstract final class GroupHousingBudgetFitHelper {
  static const double _slackRatio = 1.1;

  static GroupHousingBudgetFit evaluate({
    required ListingDetail groupListing,
    required int housingPrice,
    int? housingMinPrice,
    int? housingMaxPrice,
    String housingListingTypeCode = ListingTypeCodes.roommateNeeded,
  }) {
    final groupSize = groupListing.groupContext?.groupSizeTarget ??
        groupListing.groupSizeTarget;
    if (groupSize == null || groupSize < 2) {
      return GroupHousingBudgetFit.unknown;
    }

    final groupBounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: groupListing.price,
      listingTypeCode: ListingTypeCodes.groupForming,
      minPrice: groupListing.minPrice,
      maxPrice: groupListing.maxPrice,
    );
    if (groupBounds.max <= 0) return GroupHousingBudgetFit.unknown;

    final housingBounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: housingPrice,
      listingTypeCode: housingListingTypeCode,
      minPrice: housingMinPrice,
      maxPrice: housingMaxPrice,
    );
    final housingMid = housingBounds.max > housingBounds.min
        ? ((housingBounds.min + housingBounds.max) / 2).round()
        : housingBounds.max;
    if (housingMid <= 0) return GroupHousingBudgetFit.unknown;

    final perPerson = housingMid / groupSize;
    final maxAllowed = groupBounds.max * _slackRatio;
    if (perPerson <= maxAllowed) return GroupHousingBudgetFit.fits;
    return GroupHousingBudgetFit.above;
  }

  static GroupHousingBudgetFit evaluateListing({
    required ListingDetail groupListing,
    required Listing housingListing,
  }) {
    return evaluate(
      groupListing: groupListing,
      housingPrice: housingListing.price,
      housingMinPrice: housingListing.minPrice,
      housingMaxPrice: housingListing.maxPrice,
      housingListingTypeCode:
          housingListing.listingType?.code ?? ListingTypeCodes.roommateNeeded,
    );
  }
}
