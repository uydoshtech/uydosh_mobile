import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";

void main() {
  group("ListingDetail address coordinate parsing", () {
    test("parses address_latitude/longitude when sent as JSON strings", () {
      // Regression test: Postgres NUMERIC columns are serialized as JSON
      // strings by the API, not numbers. A plain `as num?` cast used to
      // crash the entire listing detail parse for any listing with a
      // precise address pin set.
      final json = _baseListingJson()
        ..addAll({
          "address_latitude": "41.29559504",
          "address_longitude": "69.27456024",
        });

      final detail = ListingDetail.fromJson(json);

      expect(detail.addressLatitude, closeTo(41.29559504, 1e-9));
      expect(detail.addressLongitude, closeTo(69.27456024, 1e-9));
    });

    test("still parses address_latitude/longitude when sent as numbers", () {
      final json = _baseListingJson()
        ..addAll({
          "address_latitude": 41.29559504,
          "address_longitude": 69.27456024,
        });

      final detail = ListingDetail.fromJson(json);

      expect(detail.addressLatitude, closeTo(41.29559504, 1e-9));
      expect(detail.addressLongitude, closeTo(69.27456024, 1e-9));
    });

    test("tolerates missing address coordinates", () {
      final detail = ListingDetail.fromJson(_baseListingJson());

      expect(detail.addressLatitude, isNull);
      expect(detail.addressLongitude, isNull);
    });
  });
}

Map<String, dynamic> _baseListingJson() => {
      "id": 883,
      "user_id": 2,
      "title": "#ИщемСоседа",
      "listing_type_id": 2,
      "price": 250,
      "is_active": true,
      "created_at": "2026-07-07T06:55:44.352Z",
      "updated_at": "2026-07-07T11:06:16.328Z",
      "user": {
        "id": 2,
        "created_at": "2025-09-04T14:31:16.145Z",
      },
      "listing_type": {
        "id": 2,
        "name_uz": "Hamkor Kerak",
        "name_ru": "Нужен Сосед",
        "name_en": "Roommate Needed",
        "code": "roommate_needed",
      },
    };
