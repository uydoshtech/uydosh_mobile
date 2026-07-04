import "package:uy_dosh/domain/models/location.dart";

/// Static cache for locations to reduce API calls
/// This data is fetched from the API and stored locally for better performance
class LocationCache {
  /// All locations with their details
  static const List<Location> locations = [
    Location(
      id: 1, //41.296048, 69.175168
      nameUz: "Uchtepa Tumani",
      nameRu: "Учтепинский район",
      nameEn: "Uchtepa District",
      shortNameUz: "Uchtepa",
      shortNameRu: "Учтепа",
      shortNameEn: "Uchtepa",
      shortName: "Uchtepa",
      latitude: 41.296048,
      longitude: 69.175168,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 2, //41°13′49″N 69°20′12″E
      nameUz: "Bektemir Tumani",
      nameRu: "Бектемирский район",
      nameEn: "Bektemir District",
      shortNameUz: "Bektemir",
      shortNameRu: "Бектемир",
      shortNameEn: "Bektemir",
      shortName: "Bektemir",
      latitude: 41.2333,
      longitude: 69.3344,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 3, //41.3294°N 69.3475°E
      nameUz: "Mirzo Ulugbek Tumani",
      nameRu: "Мирзо‑Улугбекский район",
      nameEn: "Mirzo Ulugbek District",
      shortNameUz: "Mirzo Ulugbek",
      shortNameRu: "Мирзо‑Улугбек",
      shortNameEn: "Mirzo Ulugbek",
      shortName: "Mirzo Ulugbek",
      latitude: 41.3257,
      longitude: 69.3257,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 4, //41.2760°N 69.2936°E
      nameUz: "Mirobod Tumani",
      nameRu: "Мирабадский район",
      nameEn: "Mirabad District",
      shortNameUz: "Mirobod",
      shortNameRu: "Мирабад",
      shortNameEn: "Mirabad",
      shortName: "Mirobod",
      latitude: 41.2774,
      longitude: 69.2972,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 5, //41.2102°N 69.2318°E
      nameUz: "Sergeli Tumani",
      nameRu: "Сергелийский район",
      nameEn: "Sergeli District",
      shortNameUz: "Sergeli",
      shortNameRu: "Сергели",
      shortNameEn: "Sergeli",
      shortName: "Sergeli",
      latitude: 41.2100,
      longitude: 69.2317,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 6, //41.3640°N 69.2280°E
      nameUz: "Olmazor Tumani",
      nameRu: "Алмазарский район",
      nameEn: "Almazar District",
      shortNameUz: "Olmazor",
      shortNameRu: "Алмазар",
      shortNameEn: "Almazar",
      shortName: "Olmazor",
      latitude: 41.3614,
      longitude: 69.2254,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 7, //41°16′20″N 69°12′06″E
      nameUz: "Chilanzar Tumani",
      nameRu: "Чиланзарский район",
      nameEn: "Chilanzar District",
      shortNameUz: "Chilanzar",
      shortNameRu: "Чиланзар",
      shortNameEn: "Chilanzar",
      shortName: "Chilanzar",
      latitude: 41.2743,
      longitude: 69.2049,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 8, //41.3270°N 69.2110°E
      nameUz: "Shayxontohur Tumani",
      nameRu: "Шайхантаурский район",
      nameEn: "Shaykhantahur District",
      shortNameUz: "Shayxontohur",
      shortNameRu: "Шайхантаур",
      shortNameEn: "Shaykhantahur",
      shortName: "Shayxontohur",
      latitude: 41.3223,
      longitude: 69.2101,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 9, //41.3580°N 69.2990°E
      nameUz: "Yunusobod Tumani",
      nameRu: "Юнусабадский район",
      nameEn: "Yunusabad District",
      shortNameUz: "Yunusobod",
      shortNameRu: "Юнусабад",
      shortNameEn: "Yunusabad",
      shortName: "Yunusobod",
      latitude: 41.3666,
      longitude: 69.2922,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 10, //41.2760°N 69.2470°E
      nameUz: "Yakkasaroy Tumani",
      nameRu: "Яккасарайский район",
      nameEn: "Yakkasaray District",
      shortNameUz: "Yakkasaroy",
      shortNameRu: "Яккасарай",
      shortNameEn: "Yakkasaray",
      shortName: "Yakkasaroy",
      latitude: 41.2807,
      longitude: 69.2557,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 11, //41.2862°N 69.3236°E
      nameUz: "Yashnobod Tumani",
      nameRu: "Яшнабадский район",
      nameEn: "Yashnabad District",
      shortNameUz: "Yashnobod",
      shortNameRu: "Яшнабад",
      shortNameEn: "Yashnabad",
      shortName: "Yashnobod",
      latitude: 41.2832,
      longitude: 69.3339,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
    Location(
      id: 12, //41.19°N 69.22°E
      nameUz: "Yangi Hayot Tumani",
      nameRu: "Янгихаётский район",
      nameEn: "Yangihayot District",
      shortNameUz: "Yangi Hayot",
      shortNameRu: "Янгихаёт",
      shortNameEn: "Yangihayot",
      shortName: "Yangi Hayot",
      latitude: 41.0655,
      longitude: 69.4457,
      createdAt: "2025-08-01T11:52:20.681703Z",
      updatedAt: "2025-08-01T11:52:20.681703Z",
    ),
  ];

  /// Get all locations
  static List<Location> getAllLocations() {
    return locations;
  }

  /// Get a specific location by ID
  static Location? getLocationById(int id) {
    try {
      return locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get locations by name (case-insensitive search)
  static List<Location> getLocationsByName(String name) {
    final lowercaseName = name.toLowerCase();
    return locations.where((location) {
      return (location.nameUz?.toLowerCase().contains(lowercaseName) ??
              false) ||
          (location.nameRu?.toLowerCase().contains(lowercaseName) ?? false) ||
          (location.nameEn?.toLowerCase().contains(lowercaseName) ?? false) ||
          (location.shortNameUz?.toLowerCase().contains(lowercaseName) ??
              false) ||
          (location.shortNameRu?.toLowerCase().contains(lowercaseName) ??
              false) ||
          (location.shortNameEn?.toLowerCase().contains(lowercaseName) ??
              false) ||
          (location.shortName?.toLowerCase().contains(lowercaseName) ?? false);
    }).toList();
  }

  /// Get location name in a specific language
  /// [locationId] - location ID
  /// [language] - language code ("en", "ru", "uz")
  static String getLocationName(int locationId, String language) {
    final location = getLocationById(locationId);
    if (location == null) return "Unknown Location";

    switch (language) {
      case "uz":
        return location.nameUz ?? location.shortNameUz ?? "Unknown Location";
      case "ru":
        return location.nameRu ?? location.shortNameRu ?? "Unknown Location";
      case "en":
        return location.nameEn ?? location.shortNameEn ?? "Unknown Location";
      default:
        return location.nameRu ?? location.shortNameRu ?? "Unknown Location";
    }
  }

  /// Get location short name in a specific language
  /// [locationId] - location ID
  /// [language] - language code ("en", "ru", "uz")
  static String getLocationShortName(int locationId, String language) {
    final location = getLocationById(locationId);
    if (location == null) return "Unknown";

    switch (language) {
      case "uz":
        return location.shortNameUz ?? location.shortName ?? "Unknown";
      case "ru":
        return location.shortNameRu ?? location.shortName ?? "Unknown";
      case "en":
        return location.shortNameEn ?? location.shortName ?? "Unknown";
      default:
        return location.shortNameRu ?? location.shortName ?? "Unknown";
    }
  }

  /// Get location name in English
  static String getLocationNameEn(int locationId) {
    return getLocationName(locationId, "en");
  }

  /// Get location name in Russian
  static String getLocationNameRu(int locationId) {
    return getLocationName(locationId, "ru");
  }

  /// Get location name in Uzbek
  static String getLocationNameUz(int locationId) {
    return getLocationName(locationId, "uz");
  }

  /// Get location short name in English
  static String getLocationShortNameEn(int locationId) {
    return getLocationShortName(locationId, "en");
  }

  /// Get location short name in Russian
  static String getLocationShortNameRu(int locationId) {
    return getLocationShortName(locationId, "ru");
  }

  /// Get location short name in Uzbek
  static String getLocationShortNameUz(int locationId) {
    return getLocationShortName(locationId, "uz");
  }

  /// Get all location names in a specific language
  static Map<int, String> getAllLocationNames(String language) {
    final result = <int, String>{};
    for (final location in locations) {
      result[location.id] = getLocationName(location.id, language);
    }
    return result;
  }

  /// Get all location short names in a specific language
  static Map<int, String> getAllLocationShortNames(String language) {
    final result = <int, String>{};
    for (final location in locations) {
      result[location.id] = getLocationShortName(location.id, language);
    }
    return result;
  }

  /// Get all location names in English
  static Map<int, String> getAllLocationNamesEn() {
    return getAllLocationNames("en");
  }

  /// Get all location names in Russian
  static Map<int, String> getAllLocationNamesRu() {
    return getAllLocationNames("ru");
  }

  /// Get all location names in Uzbek
  static Map<int, String> getAllLocationNamesUz() {
    return getAllLocationNames("uz");
  }

  /// Get all location short names in English
  static Map<int, String> getAllLocationShortNamesEn() {
    return getAllLocationShortNames("en");
  }

  /// Get all location short names in Russian
  static Map<int, String> getAllLocationShortNamesRu() {
    return getAllLocationShortNames("ru");
  }

  /// Get all location short names in Uzbek
  static Map<int, String> getAllLocationShortNamesUz() {
    return getAllLocationShortNames("uz");
  }

  /// Location id whose center coordinate is closest to [latitude]/[longitude].
  /// Fallback for [TashkentDistrictBoundaryCache.findLocationIdForCoordinate]
  /// when the point falls outside every district polygon (GPS noise, or a
  /// position just past a border).
  static int? findNearestLocationId(double latitude, double longitude) {
    int? bestId;
    double? bestDistanceSquared;
    for (final location in locations) {
      final lat = location.latitude;
      final lon = location.longitude;
      if (lat == null || lon == null) continue;
      final dLat = lat - latitude;
      final dLon = lon - longitude;
      final distanceSquared = dLat * dLat + dLon * dLon;
      if (bestDistanceSquared == null || distanceSquared < bestDistanceSquared) {
        bestDistanceSquared = distanceSquared;
        bestId = location.id;
      }
    }
    return bestId;
  }

  /// Get coordinates for a location by ID
  static Map<String, double>? getLocationCoordinatesById(int locationId) {
    final location = getLocationById(locationId);
    if (location == null ||
        location.latitude == null ||
        location.longitude == null) {
      return null;
    }

    return {"latitude": location.latitude!, "longitude": location.longitude!};
  }

  /// Get coordinates for a location by name
  static Map<String, double>? getLocationCoordinatesByName(
    String locationName,
  ) {
    final matchingLocations = getLocationsByName(locationName);
    if (matchingLocations.isEmpty) return null;

    // Return coordinates of the first match
    final location = matchingLocations.first;
    if (location.latitude == null || location.longitude == null) return null;

    return {"latitude": location.latitude!, "longitude": location.longitude!};
  }
}
