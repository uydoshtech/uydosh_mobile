import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/message.dart";

void main() {
  test("Message.fromJson parses listing_rating payload", () {
    final message = Message.fromJson({
      "id": 1,
      "conversation_id": 10,
      "sender_id": 2,
      "content": "hello",
      "message_type": "text",
      "created_at": "2020-01-01T00:00:00Z",
      "updated_at": "2020-01-01T00:00:00Z",
      "listing_rating": {
        "average": 4.5,
        "count": 2,
        "my_stars": 5,
        "distribution": {"5": 1, "4": 1},
      },
    });

    expect(message.listingRating, isNotNull);
    expect(message.listingRating!.average, 4.5);
    expect(message.listingRating!.count, 2);
    expect(message.listingRating!.myStars, 5);
    expect(message.listingRating!.distribution[5], 1);
    expect(message.listingRating!.distribution[4], 1);
  });
}
