import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/region.dart";

/// Cache for regions data fetched from the API
/// This cache stores regions with proper localization support
class RegionCache {
  static List<Region> _cachedRegions = [];
  static bool _isInitialized = false;

  /// Tashkent City's region id — pinned first in sorted region lists since
  /// it's the capital, ahead of the alphabetical Cyrillic/Latin ordering.
  static const int capitalRegionId = 1;

  /// Initialize the cache by fetching data from the API
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      logger.d("=== REGION CACHE INITIALIZATION ===");
      logger.d("Fetching regions from API...");

      // For now, we'll create the regions with proper localized data
      // In a real implementation, this would fetch from the API
      _cachedRegions = _getRegionsFromApi();

      _isInitialized = true;
      logger.d(
        "Region cache initialized with ${_cachedRegions.length} regions",
      );
      logger.d("=====================================");
    } catch (e) {
      logger.d("Error initializing region cache: $e");
      rethrow;
    }
  }

  /// Get regions from API (simulated - in real implementation this would make HTTP call)
  static List<Region> _getRegionsFromApi() {
    // This simulates the API response with proper localized data from the database
    return [
      const Region(
        id: 1,
        name: "Toshkent shahri",
        nameRu: "Город Ташкент",
        nameEn: "Tashkent City",
        nameUz: "Toshkent shahri",
        shortName: "Toshkent",
        shortNameRu: "Ташкент",
        shortNameEn: "Tashkent",
        shortNameUz: "Toshkent",
        latitude: "41.29950000",
        longitude: "69.24010000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 2,
        name: "Qoraqalpogiston Respublikasi",
        nameRu: "Республика Каракалпакстан",
        nameEn: "Republic of Karakalpakstan",
        nameUz: "Qoraqalpogiston Respublikasi",
        shortName: "Qoraqalpogiston",
        shortNameRu: "Каракалпакстан",
        shortNameEn: "Karakalpakstan",
        shortNameUz: "Qoraqalpogiston",
        latitude: "43.76830000",
        longitude: "59.02140000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 3,
        name: "Andijon viloyati",
        nameRu: "Андижанская область",
        nameEn: "Andijan Region",
        nameUz: "Andijon viloyati",
        shortName: "Andijon",
        shortNameRu: "Андижан",
        shortNameEn: "Andijan",
        shortNameUz: "Andijon",
        latitude: "40.78330000",
        longitude: "72.35000000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 4,
        name: "Buxoro viloyati",
        nameRu: "Бухарская область",
        nameEn: "Bukhara Region",
        nameUz: "Buxoro viloyati",
        shortName: "Buxoro",
        shortNameRu: "Бухара",
        shortNameEn: "Bukhara",
        shortNameUz: "Buxoro",
        latitude: "39.76840000",
        longitude: "64.45560000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 5,
        name: "Jizzax viloyati",
        nameRu: "Джизакская область",
        nameEn: "Jizzakh Region",
        nameUz: "Jizzax viloyati",
        shortName: "Jizzax",
        shortNameRu: "Джизак",
        shortNameEn: "Jizzakh",
        shortNameUz: "Jizzax",
        latitude: "40.11580000",
        longitude: "67.84220000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 6,
        name: "Qashqadaryo viloyati",
        nameRu: "Кашкадарьинская область",
        nameEn: "Kashkadarya Region",
        nameUz: "Qashqadaryo viloyati",
        shortName: "Qashqadaryo",
        shortNameRu: "Кашкадарья",
        shortNameEn: "Kashkadarya",
        shortNameUz: "Qashqadaryo",
        latitude: "38.86060000",
        longitude: "65.78490000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 7,
        name: "Navoiy viloyati",
        nameRu: "Навоийская область",
        nameEn: "Navoiy Region",
        nameUz: "Navoiy viloyati",
        shortName: "Navoiy",
        shortNameRu: "Навои",
        shortNameEn: "Navoiy",
        shortNameUz: "Navoiy",
        latitude: "40.10390000",
        longitude: "65.37180000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 8,
        name: "Namangan viloyati",
        nameRu: "Наманганская область",
        nameEn: "Namangan Region",
        nameUz: "Namangan viloyati",
        shortName: "Namangan",
        shortNameRu: "Наманган",
        shortNameEn: "Namangan",
        shortNameUz: "Namangan",
        latitude: "40.99830000",
        longitude: "71.67260000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 9,
        name: "Samarqand viloyati",
        nameRu: "Самаркандская область",
        nameEn: "Samarkand Region",
        nameUz: "Samarqand viloyati",
        shortName: "Samarqand",
        shortNameRu: "Самарканд",
        shortNameEn: "Samarkand",
        shortNameUz: "Samarqand",
        latitude: "39.62700000",
        longitude: "66.97470000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 10,
        name: "Surxondaryo viloyati",
        nameRu: "Сурхандарьинская область",
        nameEn: "Surkhandarya Region",
        nameUz: "Surxondaryo viloyati",
        shortName: "Surxondaryo",
        shortNameRu: "Сурхандарья",
        shortNameEn: "Surkhandarya",
        shortNameUz: "Surxondaryo",
        latitude: "37.94090000",
        longitude: "67.57070000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 11,
        name: "Sirdaryo viloyati",
        nameRu: "Сырдарьинская область",
        nameEn: "Syrdarya Region",
        nameUz: "Sirdaryo viloyati",
        shortName: "Sirdaryo",
        shortNameRu: "Сырдарья",
        shortNameEn: "Syrdarya",
        shortNameUz: "Sirdaryo",
        latitude: "40.75000000",
        longitude: "68.50000000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 12,
        name: "Toshkent viloyati",
        nameRu: "Ташкентская область",
        nameEn: "Tashkent Region",
        nameUz: "Toshkent viloyati",
        shortName: "Toshkent viloyati",
        shortNameRu: "Ташкентская область",
        shortNameEn: "Tashkent Region",
        shortNameUz: "Toshkent viloyati",
        latitude: "41.00000000",
        longitude: "69.00000000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 13,
        name: "Fargona viloyati",
        nameRu: "Ферганская область",
        nameEn: "Fergana Region",
        nameUz: "Fargona viloyati",
        shortName: "Fargona",
        shortNameRu: "Фергана",
        shortNameEn: "Fergana",
        shortNameUz: "Fargona",
        latitude: "40.38640000",
        longitude: "71.78640000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
      const Region(
        id: 14,
        name: "Xorazm viloyati",
        nameRu: "Хорезмская область",
        nameEn: "Khorezm Region",
        nameUz: "Xorazm viloyati",
        shortName: "Xorazm",
        shortNameRu: "Хорезм",
        shortNameEn: "Khorezm",
        shortNameUz: "Xorazm",
        latitude: "41.55000000",
        longitude: "60.63330000",
        createdAt: "2025-08-01T12:57:51.498Z",
        updatedAt: "2025-08-01T12:57:51.498Z",
      ),
    ];
  }

  /// Get all regions
  static List<Region> getAllRegions() {
    if (!_isInitialized) {
      logger.d("Region cache not initialized, returning empty list");
      return [];
    }
    return _cachedRegions;
  }

  /// Get regions sorted alphabetically by localized name
  static List<Region> getRegionsSortedByLanguage(String language) {
    if (!_isInitialized) {
      logger.d("Region cache not initialized, returning empty list");
      return [];
    }

    final sortedRegions = List<Region>.from(_cachedRegions);
    sortedRegions.sort((a, b) => compareRegionsCapitalFirst(a, b, language));
    return sortedRegions;
  }

  /// Comparator that pins Tashkent City ([capitalRegionId]) first, then
  /// falls back to alphabetical order by localized name.
  static int compareRegionsCapitalFirst(
    Region a,
    Region b,
    String language,
  ) {
    if (a.id == capitalRegionId && b.id == capitalRegionId) return 0;
    if (a.id == capitalRegionId) return -1;
    if (b.id == capitalRegionId) return 1;
    return a.getLocalizedName(language).compareTo(b.getLocalizedName(language));
  }

  /// Get a specific region by ID
  static Region? getRegionById(int id) {
    if (!_isInitialized) {
      logger.d("Region cache not initialized, returning null");
      return null;
    }

    try {
      return _cachedRegions.firstWhere((region) => region.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get regions by name (case-insensitive search)
  static List<Region> getRegionsByName(String name) {
    if (!_isInitialized) {
      logger.d("Region cache not initialized, returning empty list");
      return [];
    }

    final lowercaseName = name.toLowerCase();
    return _cachedRegions.where((region) {
      return (region.name?.toLowerCase().contains(lowercaseName) ?? false) ||
          (region.nameRu?.toLowerCase().contains(lowercaseName) ?? false) ||
          (region.nameEn?.toLowerCase().contains(lowercaseName) ?? false) ||
          (region.nameUz?.toLowerCase().contains(lowercaseName) ?? false) ||
          (region.shortName?.toLowerCase().contains(lowercaseName) ?? false) ||
          (region.shortNameRu?.toLowerCase().contains(lowercaseName) ??
              false) ||
          (region.shortNameEn?.toLowerCase().contains(lowercaseName) ??
              false) ||
          (region.shortNameUz?.toLowerCase().contains(lowercaseName) ?? false);
    }).toList();
  }

  /// Get region name in a specific language
  /// [regionId] - region ID
  /// [language] - language code ("en", "ru", "uz")
  static String getRegionName(int regionId, String language) {
    final region = getRegionById(regionId);
    if (region == null) return "Unknown Region";

    return region.getLocalizedName(language);
  }

  /// Get region short name in a specific language
  /// [regionId] - region ID
  /// [language] - language code ("en", "ru", "uz")
  static String getRegionShortName(int regionId, String language) {
    final region = getRegionById(regionId);
    if (region == null) return "Unknown";

    return region.getLocalizedShortName(language);
  }

  /// Check if cache is initialized
  static bool get isInitialized => _isInitialized;

  /// Clear the cache (useful for testing or refresh)
  static void clearCache() {
    _cachedRegions = [];
    _isInitialized = false;
    logger.d("Region cache cleared");
  }
}
