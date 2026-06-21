import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

enum GroupHousingLocationFit {
  matches,
  different,
  unknown,
}

class GroupHousingListingFit {
  const GroupHousingListingFit({
    required this.budget,
    required this.location,
    this.groupSize,
    this.perPersonPriceMid,
  });

  final GroupHousingBudgetFit budget;
  final GroupHousingLocationFit location;
  final int? groupSize;
  final int? perPersonPriceMid;

  factory GroupHousingListingFit.evaluate({
    required ListingDetail groupListing,
    required Listing housingListing,
  }) {
    final groupSize = groupListing.groupContext?.groupSizeTarget ??
        groupListing.groupSizeTarget;
    final budget = GroupHousingBudgetFitHelper.evaluateListing(
      groupListing: groupListing,
      housingListing: housingListing,
    );
    final location = _evaluateLocation(
      groupListing: groupListing,
      housingListing: housingListing,
    );
    final perPersonPriceMid = _resolvePerPersonPriceMid(
      groupSize: groupSize,
      housingListing: housingListing,
    );

    return GroupHousingListingFit(
      budget: budget,
      location: location,
      groupSize: groupSize,
      perPersonPriceMid: perPersonPriceMid,
    );
  }

  static int? _resolvePerPersonPriceMid({
    required int? groupSize,
    required Listing housingListing,
  }) {
    if (groupSize == null || groupSize < 1) return null;

    final housingBounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: housingListing.price,
      listingTypeCode:
          housingListing.listingType?.code ?? ListingTypeCodes.roommateNeeded,
      minPrice: housingListing.minPrice,
      maxPrice: housingListing.maxPrice,
    );
    final housingMid = housingBounds.max > housingBounds.min
        ? ((housingBounds.min + housingBounds.max) / 2).round()
        : housingBounds.max;
    if (housingMid <= 0) return null;

    return (housingMid / groupSize).round();
  }

  static GroupHousingLocationFit _evaluateLocation({
    required ListingDetail groupListing,
    required Listing housingListing,
  }) {
    final groupLoc = groupListing.locationId;
    final groupStation = groupListing.subwayStationId;
    final groupLine = groupListing.subwayLineId;

    if (groupLoc != null && housingListing.locationId != null) {
      return groupLoc == housingListing.locationId
          ? GroupHousingLocationFit.matches
          : GroupHousingLocationFit.different;
    }
    if (groupStation != null && housingListing.subwayStationId != null) {
      return groupStation == housingListing.subwayStationId
          ? GroupHousingLocationFit.matches
          : GroupHousingLocationFit.different;
    }
    if (groupLine != null && housingListing.subwayLineId != null) {
      return groupLine == housingListing.subwayLineId
          ? GroupHousingLocationFit.matches
          : GroupHousingLocationFit.different;
    }
    return GroupHousingLocationFit.unknown;
  }

  String? formatPerPersonPriceLabel() {
    final mid = perPersonPriceMid;
    if (mid == null || mid <= 0) return null;
    return PriceRangeHelper.formatListingPriceRangeWithCurrency(mid, mid);
  }
}
