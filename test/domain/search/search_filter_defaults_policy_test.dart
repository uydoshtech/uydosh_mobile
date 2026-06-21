import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/search/search_filter_defaults.dart";

void main() {
  group("SearchFilterDefaultsPolicy", () {
    test("tenant-like roles default to roommate_needed single-type search", () {
      for (final role in ["tenant", "service_requester"]) {
        final defaults = SearchFilterDefaultsPolicy.forRole(role, profileGender: 1);
        expect(defaults.uiListingTypeId, ListingTypeIds.roommateNeeded);
        expect(defaults.searchListingTypeIds, [ListingTypeIds.roommateNeeded]);
        expect(defaults.hasMultiListingTypeSearch, isFalse);
        expect(defaults.gender, 1);
      }
    });

    test("landlord-like roles default to room_needed + group_forming bundle", () {
      for (final role in ["landlord", "service_provider"]) {
        final defaults = SearchFilterDefaultsPolicy.forRole(role);
        expect(defaults.uiListingTypeId, ListingTypeIds.roomNeeded);
        expect(
          defaults.searchListingTypeIds,
          ListingTypeIds.landlordDemandListingTypeIds,
        );
        expect(defaults.hasMultiListingTypeSearch, isTrue);
      }
    });

    test("unknown role falls back to tenant-like defaults", () {
      final defaults = SearchFilterDefaultsPolicy.forRole(null);
      expect(defaults.uiListingTypeId, ListingTypeIds.roommateNeeded);
      expect(defaults.searchListingTypeIds, [ListingTypeIds.roommateNeeded]);
    });

    test("legacy landlord upgrade detects room-only saved filters", () {
      expect(
        SearchFilterDefaultsPolicy.shouldUpgradeLegacyLandlordSearch(
          role: "landlord",
          uiListingTypeId: ListingTypeIds.roomNeeded,
          searchListingTypeIds: const [ListingTypeIds.roomNeeded],
          hadExplicitListingTypeIds: false,
        ),
        isTrue,
      );
      expect(
        SearchFilterDefaultsPolicy.shouldUpgradeLegacyLandlordSearch(
          role: "landlord",
          uiListingTypeId: ListingTypeIds.roomNeeded,
          searchListingTypeIds: const [ListingTypeIds.roomNeeded],
          hadExplicitListingTypeIds: true,
        ),
        isFalse,
      );
      expect(
        SearchFilterDefaultsPolicy.shouldUpgradeLegacyLandlordSearch(
          role: "tenant",
          uiListingTypeId: ListingTypeIds.roomNeeded,
          searchListingTypeIds: const [ListingTypeIds.roomNeeded],
          hadExplicitListingTypeIds: false,
        ),
        isFalse,
      );
    });
  });

  group("SearchFilterListingTypeIdsCodec", () {
    test("round-trips prefs string", () {
      const ids = [1, 3];
      final encoded = SearchFilterListingTypeIdsCodec.toPrefsString(ids);
      expect(
        SearchFilterListingTypeIdsCodec.fromPrefsString(
          encoded,
          fallbackUiTypeId: 2,
        ),
        ids,
      );
    });

    test("reads legacy landlord bundle from server json", () {
      expect(
        SearchFilterListingTypeIdsCodec.fromServerJson(
          {"listing_type_id": 1, "landlord_demand_bundle": true},
          fallbackUiTypeId: 1,
        ),
        ListingTypeIds.landlordDemandListingTypeIds,
      );
    });

    test("prefers listing_type_ids array on server json", () {
      expect(
        SearchFilterListingTypeIdsCodec.fromServerJson(
          {
            "listing_type_id": 1,
            "listing_type_ids": [1, 3],
          },
          fallbackUiTypeId: 1,
        ),
        [1, 3],
      );
    });
  });
}
