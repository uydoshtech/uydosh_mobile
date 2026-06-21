import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart" hide ListingTypeDetail;
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";

ListingDetail _groupListing({
  int price = 300,
  int? locationId = 10,
  int? subwayLineId,
  int groupSize = 3,
}) {
  return ListingDetail(
    id: 1,
    userId: 1,
    title: "Group",
    listingTypeId: ListingTypeIds.groupForming,
    price: price,
    isActive: true,
    createdAt: "2020-01-01T00:00:00Z",
    updatedAt: "2020-01-01T00:00:00Z",
    user: const UserDetail(id: 1, createdAt: "2020-01-01T00:00:00Z"),
    listingType: const ListingTypeDetail(
      id: ListingTypeIds.groupForming,
      code: ListingTypeCodes.groupForming,
      nameUz: "Group",
      nameRu: "Group",
      nameEn: "Group",
    ),
    locationId: locationId,
    subwayLineId: subwayLineId,
    groupSizeTarget: groupSize,
    groupContext: ListingGroupContext(
      isGroupForming: true,
      groupSizeTarget: groupSize,
      groupMemberCount: groupSize,
      groupSpotsOpen: 0,
      isOwner: true,
      isMember: true,
    ),
  );
}

Listing _housingListing({
  int price = 900,
  int? locationId = 10,
  int? subwayLineId,
}) {
  return Listing(
    id: 2,
    userId: 2,
    title: "Flat",
    listingTypeId: ListingTypeIds.roommateNeeded,
    price: price,
    isActive: true,
    createdAt: "2020-01-01T00:00:00Z",
    updatedAt: "2020-01-01T00:00:00Z",
    locationId: locationId,
    subwayLineId: subwayLineId,
  );
}

void main() {
  group("GroupHousingListingFit", () {
    test("marks budget, location, and group size when listing matches", () {
      final fit = GroupHousingListingFit.evaluate(
        groupListing: _groupListing(),
        housingListing: _housingListing(),
      );

      expect(fit.budget, GroupHousingBudgetFit.fits);
      expect(fit.location, GroupHousingLocationFit.matches);
      expect(fit.groupSize, 3);
      expect(fit.perPersonPriceMid, isNotNull);
      expect(fit.formatPerPersonPriceLabel(), isNotEmpty);
    });

    test("marks location mismatch when districts differ", () {
      final fit = GroupHousingListingFit.evaluate(
        groupListing: _groupListing(locationId: 10),
        housingListing: _housingListing(locationId: 20),
      );

      expect(fit.location, GroupHousingLocationFit.different);
    });

    test("falls back to subway line when location ids are missing", () {
      final fit = GroupHousingListingFit.evaluate(
        groupListing: _groupListing(locationId: null, subwayLineId: 4),
        housingListing: _housingListing(locationId: null, subwayLineId: 4),
      );

      expect(fit.location, GroupHousingLocationFit.matches);
    });
  });
}
