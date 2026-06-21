import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/group_shortlist_discuss_message.dart";

void main() {
  test("builds share text with title, location, metro, price, and link", () {
    final listing = Listing(
      id: 42,
      userId: 1,
      title: "Cozy flat near metro",
      listingTypeId: ListingTypeIds.roommateNeeded,
      price: 900,
      isActive: true,
      createdAt: "2020-01-01T00:00:00Z",
      updatedAt: "2020-01-01T00:00:00Z",
      location: const LocationDetail(
        id: 1,
        nameEn: "Yunusabad",
        nameRu: "Yunusabad",
        nameUz: "Yunusabad",
      ),
      subwayStation: const SubwayStationDetail(
        id: 2,
        line: 1,
        nameEn: "Minor",
        nameRu: "Minor",
        nameUz: "Minor",
      ),
    );

    final text = GroupShortlistDiscussMessage.build(listing: listing);

    expect(text, contains("Cozy flat near metro"));
    expect(text, contains("📍 Yunusabad"));
    expect(text, contains("🚇 Minor"));
    expect(text, contains("💰"));
    expect(text, contains("🔗"));
    expect(text, contains("/listing/42"));
  });
}
