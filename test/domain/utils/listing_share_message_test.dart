import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";

void main() {
  test("encodes and parses structured listing share payload", () {
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

    final encoded = GroupShortlistDiscussMessage.buildContent(
      listing: listing,
      ownerName: "Bob Landlord",
      ownerAvatarUrl: "/uploads/avatars/bob.jpg",
    );
    final payload = ListingShareMessageCodec.parse(encoded);

    expect(payload, isNotNull);
    expect(payload!.listingId, 42);
    expect(payload.title, "Cozy flat near metro");
    expect(payload.location, "Yunusabad");
    expect(payload.metro, "Minor");
    expect(payload.metroLine, 1);
    expect(payload.ownerUserId, 1);
    expect(payload.ownerName, "Bob Landlord");
    expect(payload.ownerAvatarUrl, "/uploads/avatars/bob.jpg");
  });

  test("parses legacy plain-text listing share messages", () {
    const legacy = """
How do you like this option?

Cozy flat near metro
📍 Yunusabad
🚇 Minor
💰 100/mo per person
🔗 https://api.uydosh.com/listing/3663
""";

    final payload = ListingShareMessageCodec.parse(legacy);
    expect(payload?.listingId, 3663);
    expect(payload?.title, "Cozy flat near metro");
    expect(payload?.location, "Yunusabad");
    expect(payload?.metro, "Minor");
  });
}
