import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/group_shortlist_discuss_message.dart";

void main() {
  test("build appends hidden listing marker instead of a visible URL", () {
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
    expect(text, contains("[[uydosh:listing:42]]"));
    expect(text, isNot(contains("https://")));
  });

  test("parse strips marker and legacy link line", () {
    const legacy =
        "Как вам этот вариант?\n\nFlat title\n📍 District\n🔗 https://api.uydosh.com/listing/3663";
    final parsed = GroupShortlistDiscussMessage.parse(legacy);

    expect(parsed.listingId, 3663);
    expect(parsed.displayText, contains("Flat title"));
    expect(parsed.displayText, isNot(contains("https://")));
    expect(parsed.displayText, isNot(contains("🔗")));
  });

  test("parse reads hidden marker from new messages", () {
    const message =
        "Flat title\n📍 District\n[[uydosh:listing:99]]";
    final parsed = GroupShortlistDiscussMessage.parse(message);

    expect(parsed.listingId, 99);
    expect(parsed.displayText, "Flat title\n📍 District");
    expect(parsed.hasListingFooter, isTrue);
  });
}
