import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/listing.dart" hide ListingTypeDetail;
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";

Listing _listing({String? featuredAt}) {
  return Listing(
    id: 1,
    userId: 1,
    title: "t",
    listingTypeId: 3,
    price: 0,
    isActive: true,
    createdAt: "2020-01-01T00:00:00Z",
    updatedAt: "2020-01-01T00:00:00Z",
    featuredAt: featuredAt,
  );
}

ListingDetail _listingDetail({String? featuredAt}) {
  return ListingDetail(
    id: 1,
    userId: 1,
    title: "t",
    listingTypeId: 3,
    price: 0,
    isActive: true,
    createdAt: "2020-01-01T00:00:00Z",
    updatedAt: "2020-01-01T00:00:00Z",
    user: const UserDetail(id: 1, createdAt: "2020-01-01T00:00:00Z"),
    listingType: const ListingTypeDetail(
      id: 1,
      code: "other",
      nameUz: "u",
      nameRu: "r",
      nameEn: "e",
    ),
    featuredAt: featuredAt,
  );
}

void main() {
  group("ListingUtils.isCurrentlyFeatured", () {
    test("false when featuredAt is null", () {
      expect(ListingUtils.isCurrentlyFeatured(_listing()), isFalse);
    });

    test("true when featuredAt is set", () {
      expect(
        ListingUtils.isCurrentlyFeatured(_listing(featuredAt: "2025-01-01")),
        isTrue,
      );
    });
  });

  group("ListingUtils.isCurrentlyFeaturedDetail", () {
    test("false when featuredAt is null", () {
      expect(ListingUtils.isCurrentlyFeaturedDetail(_listingDetail()), isFalse);
    });

    test("true when featuredAt is set", () {
      expect(
        ListingUtils.isCurrentlyFeaturedDetail(
          _listingDetail(featuredAt: "2025-01-01"),
        ),
        isTrue,
      );
    });
  });

  group("ListingUtils.usesPresetListingTitle", () {
    test("true for types 1 and 2 only", () {
      expect(ListingUtils.usesPresetListingTitle(1), isTrue);
      expect(ListingUtils.usesPresetListingTitle(2), isTrue);
      expect(ListingUtils.usesPresetListingTitle(3), isFalse);
    });
  });

  group("ListingUtils.presetListingTitleL10nKey", () {
    test("roommate needed (2) by gender", () {
      expect(
        ListingUtils.presetListingTitleL10nKey(listingTypeId: 2, gender: 1),
        "title_male_roommate",
      );
      expect(
        ListingUtils.presetListingTitleL10nKey(listingTypeId: 2, gender: 2),
        "title_female_roommate",
      );
    });

    test("room needed (1) by gender", () {
      expect(
        ListingUtils.presetListingTitleL10nKey(listingTypeId: 1, gender: 1),
        "title_male_room",
      );
      expect(
        ListingUtils.presetListingTitleL10nKey(listingTypeId: 1, gender: 2),
        "title_female_room",
      );
    });

    test("defaults gender to male when missing or invalid", () {
      expect(
        ListingUtils.presetListingTitleL10nKey(listingTypeId: 1),
        "title_male_room",
      );
      expect(
        ListingUtils.presetListingTitleL10nKey(listingTypeId: 1, gender: 99),
        "title_male_room",
      );
    });
  });
}
