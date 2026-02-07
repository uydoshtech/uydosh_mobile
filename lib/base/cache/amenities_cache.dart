import "package:uy_dosh/domain/models/amenity.dart";

/// Static cache for amenities to reduce API calls
/// This data is fetched from the API and stored locally for better performance
class AmenitiesCache {
  static const List<String> defaultOrderedCodes = [
    "wifi",
    "tv",
    "oven",
    "bed",
    "air_conditioning",
    "refrigerator",
    "washing_machine",
    "microwave",
    "pets",
  ];
  /// All amenities with their details
  static const List<Amenity> amenities = [
    Amenity(
      id: 2,
      code: "wifi",
      nameEn: "Wi-Fi",
      nameRu: "Wi-Fi",
      nameUz: "Wi-Fi",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
    Amenity(
      id: 4,
      code: "air_conditioning",
      nameEn: "AC",
      nameRu: "AC",
      nameUz: "AC",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
    Amenity(
      id: 3,
      code: "bed",
      nameEn: "Bed",
      nameRu: "Кровать",
      nameUz: "Krovat",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
    Amenity(
      id: 8,
      code: "refrigerator",
      nameEn: "Refrigerator",
      nameRu: "Холодильник",
      nameUz: "Muzlatkich",
      createdAt: "2025-08-11T13:00:08.821031Z",
      updatedAt: "2025-08-11T13:00:08.821031Z",
    ),
    Amenity(
      id: 6,
      code: "microwave",
      nameEn: "Microwave",
      nameRu: "Микроволновка",
      nameUz: "Mikrovolnovka",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
    Amenity(
      id: 7,
      code: "washing_machine",
      nameEn: "Washing Machine",
      nameRu: "Стиралка",
      nameUz: "Kir yuvish mashinasi",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
    Amenity(
      id: 9,
      code: "oven",
      nameEn: "Cookings Oven",
      nameRu: "Плита",
      nameUz: "Gaz Plitasi",
      createdAt: "2025-08-11T13:02:17.028979Z",
      updatedAt: "2025-08-11T13:02:17.028979Z",
    ),
    Amenity(
      id: 5,
      code: "tv",
      nameEn: "TV",
      nameRu: "ТВ",
      nameUz: "TV",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
    Amenity(
      id: 10,
      code: "pets",
      nameEn: "Pets",
      nameRu: "Животные",
      nameUz: "Uy hayvonlar",
      createdAt: "2025-08-08T18:49:52.335522Z",
      updatedAt: "2025-08-08T18:49:52.335522Z",
    ),
  ];

  /// Get all amenities
  static List<Amenity> getAllAmenities() {
    return amenities;
  }

  /// Get amenities ordered by code preference.
  /// Codes not in the list keep their original cache order.
  static List<Amenity> getOrderedAmenities(List<String> orderedCodes) {
    final indexedAmenities = amenities.asMap().entries.toList();

    indexedAmenities.sort((a, b) {
      final aCode = a.value.code ?? "";
      final bCode = b.value.code ?? "";
      final aPriority = orderedCodes.indexOf(aCode);
      final bPriority = orderedCodes.indexOf(bCode);
      final aRank = aPriority == -1 ? orderedCodes.length : aPriority;
      final bRank = bPriority == -1 ? orderedCodes.length : bPriority;

      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.key.compareTo(b.key);
    });

    return indexedAmenities.map((entry) => entry.value).toList();
  }

  /// Get amenities ordered by the default code preference.
  static List<Amenity> getDefaultOrderedAmenities() {
    return getOrderedAmenities(defaultOrderedCodes);
  }

  /// Get a specific amenity by ID
  static Amenity? getAmenityById(int id) {
    try {
      return amenities.firstWhere((amenity) => amenity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific amenity by code
  static Amenity? getAmenityByCode(String code) {
    try {
      return amenities.firstWhere((amenity) => amenity.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get amenities by name (case-insensitive search)
  static List<Amenity> getAmenitiesByName(String name) {
    final lowercaseName = name.toLowerCase();
    return amenities.where((amenity) {
      return amenity.nameEn.toLowerCase().contains(lowercaseName) ||
          amenity.nameRu.toLowerCase().contains(lowercaseName) ||
          amenity.nameUz.toLowerCase().contains(lowercaseName);
    }).toList();
  }

  /// Get amenity name in a specific language
  /// [amenityId] - amenity ID
  /// [language] - language code ("en", "ru", "uz")
  static String getAmenityName(int amenityId, String language) {
    final amenity = getAmenityById(amenityId);
    if (amenity == null) return "Unknown Amenity";

    switch (language) {
      case "uz":
        return amenity.nameUz;
      case "ru":
        return amenity.nameRu;
      case "en":
        return amenity.nameEn;
      default:
        return amenity.nameEn;
    }
  }

  /// Get amenity name by code in a specific language
  /// [code] - amenity code
  /// [language] - language code ("en", "ru", "uz")
  static String getAmenityNameByCode(String code, String language) {
    final amenity = getAmenityByCode(code);
    if (amenity == null) return "Unknown Amenity";

    switch (language) {
      case "uz":
        return amenity.nameUz;
      case "ru":
        return amenity.nameRu;
      case "en":
        return amenity.nameEn;
      default:
        return amenity.nameEn;
    }
  }

  /// Get amenity name in English
  static String getAmenityNameEn(int amenityId) {
    return getAmenityName(amenityId, "en");
  }

  /// Get amenity name in Russian
  static String getAmenityNameRu(int amenityId) {
    return getAmenityName(amenityId, "ru");
  }

  /// Get amenity name in Uzbek
  static String getAmenityNameUz(int amenityId) {
    return getAmenityName(amenityId, "uz");
  }

  /// Get amenity name by code in English
  static String getAmenityNameByCodeEn(String code) {
    return getAmenityNameByCode(code, "en");
  }

  /// Get amenity name by code in Russian
  static String getAmenityNameByCodeRu(String code) {
    return getAmenityNameByCode(code, "ru");
  }

  /// Get amenity name by code in Uzbek
  static String getAmenityNameByCodeUz(String code) {
    return getAmenityNameByCode(code, "uz");
  }

  /// Get all amenity names in a specific language
  static Map<int, String> getAllAmenityNames(String language) {
    final result = <int, String>{};
    for (final amenity in amenities) {
      result[amenity.id] = getAmenityName(amenity.id, language);
    }
    return result;
  }

  /// Get all amenity names by code in a specific language
  static Map<String, String> getAllAmenityNamesByCode(String language) {
    final result = <String, String>{};
    for (final amenity in amenities) {
      if (amenity.code != null && amenity.code!.isNotEmpty) {
        result[amenity.code!] = getAmenityNameByCode(amenity.code!, language);
      }
    }
    return result;
  }

  /// Get all amenity names in English
  static Map<int, String> getAllAmenityNamesEn() {
    return getAllAmenityNames("en");
  }

  /// Get all amenity names in Russian
  static Map<int, String> getAllAmenityNamesRu() {
    return getAllAmenityNames("ru");
  }

  /// Get all amenity names in Uzbek
  static Map<int, String> getAllAmenityNamesUz() {
    return getAllAmenityNames("uz");
  }

  /// Get all amenity names by code in English
  static Map<String, String> getAllAmenityNamesByCodeEn() {
    return getAllAmenityNamesByCode("en");
  }

  /// Get all amenity names by code in Russian
  static Map<String, String> getAllAmenityNamesByCodeRu() {
    return getAllAmenityNamesByCode("ru");
  }

  /// Get all amenity names by code in Uzbek
  static Map<String, String> getAllAmenityNamesByCodeUz() {
    return getAllAmenityNamesByCode("uz");
  }

  /// Get amenities by category (if needed for future grouping)
  static List<Amenity> getAmenitiesByCategory(String category) {
    // For now, return all amenities. This can be extended later
    // when categories are added to the amenity model
    return amenities;
  }

  /// Check if an amenity exists by ID
  static bool hasAmenity(int id) {
    return getAmenityById(id) != null;
  }

  /// Check if an amenity exists by code
  static bool hasAmenityCode(String code) {
    return getAmenityByCode(code) != null;
  }

  /// Get amenities count
  static int getAmenitiesCount() {
    return amenities.length;
  }
}
