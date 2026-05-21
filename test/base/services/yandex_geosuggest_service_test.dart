import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/base/services/yandex_geosuggest_service.dart";

void main() {
  group("YandexGeosuggestService.parseSuggestions", () {
    test("returns empty list for null or missing results", () {
      expect(YandexGeosuggestService.parseSuggestions(null), isEmpty);
      expect(YandexGeosuggestService.parseSuggestions({}), isEmpty);
      expect(
        YandexGeosuggestService.parseSuggestions({"results": "bad"}),
        isEmpty,
      );
    });

    test("prefers formatted_address over title", () {
      final suggestions = YandexGeosuggestService.parseSuggestions({
        "results": [
          {
            "title": {"text": "Short title"},
            "subtitle": {"text": "Tashkent"},
            "address": {
              "formatted_address": "ул. Навои, 12, Tashkent",
            },
          },
        ],
      });

      expect(suggestions, hasLength(1));
      expect(suggestions.first.displayText, "ул. Навои, 12, Tashkent");
      expect(suggestions.first.subtitle, "Tashkent");
    });

    test("falls back to title when formatted_address is absent", () {
      final suggestions = YandexGeosuggestService.parseSuggestions({
        "results": [
          {
            "title": {"text": "Chorsu Bazaar"},
          },
        ],
      });

      expect(suggestions, hasLength(1));
      expect(suggestions.first.displayText, "Chorsu Bazaar");
    });
  });
}
