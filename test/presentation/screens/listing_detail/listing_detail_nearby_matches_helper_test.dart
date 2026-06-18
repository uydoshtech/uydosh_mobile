import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_nearby_matches_helper.dart";

ListingDetail _listing({
  required int listingTypeId,
  required String listingTypeCode,
  int? subwayStationId,
  int? locationId,
}) {
  return ListingDetail(
    id: 1,
    userId: 10,
    title: "Test",
    listingTypeId: listingTypeId,
    price: 500000,
    isActive: true,
    createdAt: "2026-01-01T00:00:00Z",
    updatedAt: "2026-01-01T00:00:00Z",
    user: const UserDetail(
      id: 10,
      createdAt: "2026-01-01T00:00:00Z",
    ),
    listingType: ListingTypeDetail(
      id: listingTypeId,
      nameUz: "uz",
      nameRu: "ru",
      nameEn: "en",
      code: listingTypeCode,
    ),
    subwayStationId: subwayStationId,
    locationId: locationId,
    gender: 1,
  );
}

void main() {
  group("ListingDetailNearbyMatchesHelper", () {
    test("complementaryListingTypeId inverts seeker and offer types", () {
      expect(ListingDetailNearbyMatchesHelper.complementaryListingTypeId(1), 2);
      expect(ListingDetailNearbyMatchesHelper.complementaryListingTypeId(2), 1);
      expect(ListingDetailNearbyMatchesHelper.complementaryListingTypeId(99), isNull);
    });

    test("searchFilters prefer station over district", () {
      final listing = _listing(
        listingTypeId: 1,
        listingTypeCode: "room_needed",
        subwayStationId: 5,
        locationId: 9,
      );

      final filters = ListingDetailNearbyMatchesHelper.searchFilters(listing);
      expect(filters.complementaryListingTypeId, 2);
      expect(filters.subwayStationId, 5);
      expect(filters.locationId, isNull);
      expect(filters.gender, 1);
    });

    test("searchFilters fall back to district when station missing", () {
      final listing = _listing(
        listingTypeId: 2,
        listingTypeCode: "roommate_needed",
        locationId: 9,
      );

      final filters = ListingDetailNearbyMatchesHelper.searchFilters(listing);
      expect(filters.complementaryListingTypeId, 1);
      expect(filters.subwayStationId, isNull);
      expect(filters.locationId, 9);
    });

    test("canShowForListing requires geo anchor and known type", () {
      expect(
        ListingDetailNearbyMatchesHelper.canShowForListing(
          _listing(
            listingTypeId: 1,
            listingTypeCode: "room_needed",
            subwayStationId: 3,
          ),
        ),
        isTrue,
      );
      expect(
        ListingDetailNearbyMatchesHelper.canShowForListing(
          _listing(
            listingTypeId: 1,
            listingTypeCode: "room_needed",
          ),
        ),
        isFalse,
      );
    });

    test("labelKeyForListing is type-aware", () {
      expect(
        ListingDetailNearbyMatchesHelper.labelKeyForListing(
          _listing(listingTypeId: 1, listingTypeCode: "room_needed"),
        ),
        "listing_detail_nearby_room_offers",
      );
      expect(
        ListingDetailNearbyMatchesHelper.labelKeyForListing(
          _listing(listingTypeId: 2, listingTypeCode: "roommate_needed"),
        ),
        "listing_detail_nearby_room_seekers",
      );
    });
  });
}
