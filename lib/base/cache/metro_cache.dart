import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/domain/models/subway_station.dart";

/// Static cache for metro lines and stations to reduce API calls
/// This data is fetched from the API and stored locally for better performance
class MetroCache {
  /// Metro line names in different languages
  static const Map<int, Map<String, String>> metroLineNames = {
    1: {"en": "Chilanzar", "ru": "Чиланзар", "uz": "Chilanzar"},
    2: {"en": "Uzbekistan", "ru": "Узбекистан", "uz": "Oʻzbekiston"},
    3: {"en": "Yunusobod", "ru": "Юнусабад", "uz": "Yunusobod"},
    4: {"en": "Halqa", "ru": "Кольцевая", "uz": "Circle"},
  };

  /// All metro stations organized by line
  static const Map<int, List<SubwayStation>> metroStations = {
    1: [
      // Chilonzor Line
      SubwayStation(
        id: 1,
        line: 1,
        ordinal: 1,
        nameUz: "Chinor",
        nameRu: "Чинор",
        nameEn: "Chinor",
        latitude: 41.20669650,
        longitude: 69.21895750,
        locationId: 5,
      ),
      SubwayStation(
        id: 2,
        line: 1,
        ordinal: 2,
        nameUz: "Yangikhayot",
        nameRu: "Янгихаёт",
        nameEn: "Yangikhayot",
        latitude: 41.21350990,
        longitude: 69.21401500,
        locationId: 5,
      ),
      SubwayStation(
        id: 3,
        line: 1,
        ordinal: 3,
        nameUz: "Sergeli",
        nameRu: "Сергели",
        nameEn: "Sergeli",
        latitude: 41.22064000,
        longitude: 69.20884500,
        locationId: 5,
      ),
      SubwayStation(
        id: 4,
        line: 1,
        ordinal: 4,
        nameUz: "Uzgarish",
        nameRu: "Узгариш",
        nameEn: "Uzgarish",
        latitude: 41.22733640,
        longitude: 69.20397140,
        locationId: 5,
      ),
      SubwayStation(
        id: 5,
        line: 1,
        ordinal: 5,
        nameUz: "Chashtepa",
        nameRu: "Чаштепа",
        nameEn: "Chashtepa",
        latitude: 41.23824960,
        longitude: 69.19603450,
        locationId: 5,
      ),
      SubwayStation(
        id: 6,
        line: 1,
        ordinal: 6,
        nameUz: "Almazar",
        nameRu: "Алмазар",
        nameEn: "Almazar",
        latitude: 41.25667240,
        longitude: 69.19610450,
        locationId: 7,
      ),
      SubwayStation(
        id: 7,
        line: 1,
        ordinal: 7,
        nameUz: "Chilanzar",
        nameRu: "Чиланзар",
        nameEn: "Chilanzar",
        latitude: 41.27435900,
        longitude: 69.20497350,
        locationId: 7,
      ),
      SubwayStation(
        id: 8,
        line: 1,
        ordinal: 8,
        nameUz: "Mirzo Ulugbek",
        nameRu: "Мирзо Улугбек",
        nameEn: "Mirzo Ulugbek",
        latitude: 41.28203420,
        longitude: 69.21258340,
        locationId: 7,
      ),
      SubwayStation(
        id: 9,
        line: 1,
        ordinal: 9,
        nameUz: "Novza",
        nameRu: "Новза",
        nameEn: "Novza",
        latitude: 41.29187220,
        longitude: 69.22361650,
        locationId: 7,
      ),
      SubwayStation(
        id: 10,
        line: 1,
        ordinal: 10,
        nameUz: "Milliy bog",
        nameRu: "Нац. Парк",
        nameEn: "National Park",
        latitude: 41.30339440,
        longitude: 69.23566630,
        locationId: 8,
      ),
      SubwayStation(
        id: 11,
        line: 1,
        ordinal: 11,
        nameUz: "Xalqlar doʻstligi",
        nameRu: "Дружба народов",
        nameEn: "Friendship of Nations",
        latitude: 41.31189870,
        longitude: 69.24309590,
        locationId: 8,
      ),
      SubwayStation(
        id: 12,
        line: 1,
        ordinal: 12,
        nameUz: "Paxtakor",
        nameRu: "Пахтакор",
        nameEn: "Pakhtakor",
        latitude: 41.31779140,
        longitude: 69.25508820,
        locationId: 8,
      ),
      SubwayStation(
        id: 13,
        line: 1,
        ordinal: 13,
        nameUz: "Mustaqil. Maydoni",
        nameRu: "Пл. Независимости",
        nameEn: "Indep. Square",
        latitude: 41.31494530,
        longitude: 69.27106460,
        locationId: 9,
      ),
      SubwayStation(
        id: 14,
        line: 1,
        ordinal: 14,
        nameUz: "A. Temur Xiyoboni",
        nameRu: "Сквер Амира Темура",
        nameEn: "A. Temur Square",
        latitude: 41.31267380,
        longitude: 69.28326910,
        locationId: 9,
      ),
      SubwayStation(
        id: 15,
        line: 1,
        ordinal: 15,
        nameUz: "Hamid Olimjon",
        nameRu: "Хамид Алимджан",
        nameEn: "Hamid Olimjon",
        latitude: 41.31816440,
        longitude: 69.29574190,
        locationId: 3,
      ),
      SubwayStation(
        id: 16,
        line: 1,
        ordinal: 16,
        nameUz: "Pushkin",
        nameRu: "Пушкин",
        nameEn: "Pushkin",
        latitude: 41.32194810,
        longitude: 69.31110200,
        locationId: 3,
      ),
      SubwayStation(
        id: 17,
        line: 1,
        ordinal: 17,
        nameUz: "Buyuk Ipak Yoli",
        nameRu: "Вел. Шелковый Путь",
        nameEn: "Great Silk Road",
        latitude: 41.32610540,
        longitude: 69.32855980,
        locationId: 3,
      ),
    ],
    2: [
      // Oʻzbekiston Line
      SubwayStation(
        id: 18,
        line: 2,
        ordinal: 18,
        nameUz: "Beruniy",
        nameRu: "Беруни",
        nameEn: "Beruniy",
        latitude: 41.34461520,
        longitude: 69.20620460,
        locationId: 6,
      ),
      SubwayStation(
        id: 19,
        line: 2,
        ordinal: 19,
        nameUz: "Tinchlik",
        nameRu: "Тинчлик",
        nameEn: "Tinchlik",
        latitude: 41.33230140,
        longitude: 69.21911550,
        locationId: 6,
      ),
      SubwayStation(
        id: 20,
        line: 2,
        ordinal: 20,
        nameUz: "Chorsu",
        nameRu: "Чорсу",
        nameEn: "Chorsu",
        latitude: 41.32586490,
        longitude: 69.23681520,
        locationId: 8,
      ),
      SubwayStation(
        id: 21,
        line: 2,
        ordinal: 21,
        nameUz: "Gafur Gulom",
        nameRu: "Гафур Гулям",
        nameEn: "Gafur Gulom",
        latitude: 41.32788280,
        longitude: 69.24583420,
        locationId: 8,
      ),
      SubwayStation(
        id: 22,
        line: 2,
        ordinal: 22,
        nameUz: "Alisher Navoiy",
        nameRu: "Алишер Навои",
        nameEn: "Alisher Navoi",
        latitude: 41.31892180,
        longitude: 69.25429730,
        locationId: 8,
      ),
      SubwayStation(
        id: 23,
        line: 2,
        ordinal: 23,
        nameUz: "Oʻzbekiston",
        nameRu: "Узбекистан",
        nameEn: "Uzbekistan",
        latitude: 41.31194370,
        longitude: 69.25340570,
        locationId: 10,
      ),
      SubwayStation(
        id: 24,
        line: 2,
        ordinal: 24,
        nameUz: "Kosmonavtlar",
        nameRu: "Космонавты",
        nameEn: "Cosmonauts",
        latitude: 41.30516180,
        longitude: 69.26472070,
        locationId: 10,
      ),
      SubwayStation(
        id: 25,
        line: 2,
        ordinal: 25,
        nameUz: "Oybek",
        nameRu: "Ойбек",
        nameEn: "Oybek",
        latitude: 41.29801280,
        longitude: 69.27405010,
        locationId: 4,
      ),
      SubwayStation(
        id: 26,
        line: 2,
        ordinal: 26,
        nameUz: "Toshkent",
        nameRu: "Ташкент",
        nameEn: "Tashkent",
        latitude: 41.29328860,
        longitude: 69.28772120,
        locationId: 4,
      ),
      SubwayStation(
        id: 27,
        line: 2,
        ordinal: 27,
        nameUz: "Mashinasozlar",
        nameRu: "Машиностроители",
        nameEn: "Machine Builders",
        latitude: 41.29898470,
        longitude: 69.30512760,
        locationId: 11,
      ),
      SubwayStation(
        id: 28,
        line: 2,
        ordinal: 28,
        nameUz: "Doʻstlik",
        nameRu: "Дустлик",
        nameEn: "Dustlik",
        latitude: 41.29364010,
        longitude: 69.32224450,
        locationId: 11,
      ),
    ],
    3: [
      // Yunusobod Line
      SubwayStation(
        id: 29,
        line: 3,
        ordinal: 29,
        nameUz: "Mingurik",
        nameRu: "Мингурик",
        nameEn: "Mingurik",
        latitude: 41.29966100,
        longitude: 69.27441020,
        locationId: 4,
      ),
      SubwayStation(
        id: 30,
        line: 3,
        ordinal: 30,
        nameUz: "Yunus Rajabiy",
        nameRu: "Юнус Раджаби",
        nameEn: "Yunus Rajabiy",
        latitude: 41.31388710,
        longitude: 69.28350770,
        locationId: 9,
      ),
      SubwayStation(
        id: 31,
        line: 3,
        ordinal: 31,
        nameUz: "Abdulla Qodiriy",
        nameRu: "Абдулла Кадыри",
        nameEn: "Abdulla Qodiriy",
        latitude: 41.32019240,
        longitude: 69.28175900,
        locationId: 9,
      ),
      SubwayStation(
        id: 32,
        line: 3,
        ordinal: 32,
        nameUz: "Minor",
        nameRu: "Минор",
        nameEn: "Minor",
        latitude: 41.32689230,
        longitude: 69.28341630,
        locationId: 9,
      ),
      SubwayStation(
        id: 33,
        line: 3,
        ordinal: 33,
        nameUz: "Bodomzor",
        nameRu: "Бодомзор",
        nameEn: "Bodomzor",
        latitude: 41.33717010,
        longitude: 69.28456970,
        locationId: 9,
      ),
      SubwayStation(
        id: 34,
        line: 3,
        ordinal: 34,
        nameUz: "Shahriston",
        nameRu: "Шахристан",
        nameEn: "Shahriston",
        latitude: 41.35311850,
        longitude: 69.28810690,
        locationId: 9,
      ),
      SubwayStation(
        id: 35,
        line: 3,
        ordinal: 35,
        nameUz: "Yunusobod",
        nameRu: "Юнусабад",
        nameEn: "Yunusabad",
        latitude: 41.36684110,
        longitude: 69.29230030,
        locationId: 9,
      ),
      SubwayStation(
        id: 36,
        line: 3,
        ordinal: 36,
        nameUz: "Turkiston",
        nameRu: "Туркистан",
        nameEn: "Turkiston",
        latitude: 41.37752170,
        longitude: 69.29601510,
        locationId: 9,
      ),
    ],
    4: [
      // Halqa Line
      SubwayStation(
        id: 37,
        line: 4,
        ordinal: 37,
        nameUz: "Texnopark",
        nameRu: "Технопарк",
        nameEn: "Technopark",
        latitude: 41.29462800,
        longitude: 69.32318670,
        locationId: 11,
      ),
      SubwayStation(
        id: 38,
        line: 4,
        ordinal: 38,
        nameUz: "Yashnobod",
        nameRu: "Яшнабад",
        nameEn: "Yashnobod",
        latitude: 41.29758590,
        longitude: 69.34978310,
        locationId: 11,
      ),
      SubwayStation(
        id: 39,
        line: 4,
        ordinal: 39,
        nameUz: "Tuzel",
        nameRu: "Тузель",
        nameEn: "Tuzel",
        latitude: 41.29201250,
        longitude: 69.35618440,
        locationId: 11,
      ),
      SubwayStation(
        id: 40,
        line: 4,
        ordinal: 40,
        nameUz: "Olmos",
        nameRu: "Алмаз",
        nameEn: "Olmos",
        latitude: 41.28170500,
        longitude: 69.36033380,
        locationId: 11,
      ),
      SubwayStation(
        id: 41,
        line: 4,
        ordinal: 41,
        nameUz: "Rohat",
        nameRu: "Рохат",
        nameEn: "Rohat",
        latitude: 41.26529070,
        longitude: 69.36475170,
        locationId: 11,
      ),
      SubwayStation(
        id: 42,
        line: 4,
        ordinal: 42,
        nameUz: "Yangiobod",
        nameRu: "Янгиабад",
        nameEn: "Yangiobod",
        latitude: 41.25650750,
        longitude: 69.35872420,
        locationId: 11,
      ),
      SubwayStation(
        id: 43,
        line: 4,
        ordinal: 43,
        nameUz: "Quyliuq",
        nameRu: "Куйлюк",
        nameEn: "Quyliuq",
        latitude: 41.23745790,
        longitude: 69.32700010,
        locationId: 4,
      ),
      SubwayStation(
        id: 44,
        line: 4,
        ordinal: 44,
        nameUz: "Matonat",
        nameRu: "Матонат",
        nameEn: "Matonat",
        latitude: 41.24447130,
        longitude: 69.30832290,
        locationId: 5,
      ),
      SubwayStation(
        id: 45,
        line: 4,
        ordinal: 45,
        nameUz: "Qiyot",
        nameRu: "Киёт",
        nameEn: "Qiyot",
        latitude: 41.24447960,
        longitude: 69.29972800,
        locationId: 5,
      ),
      SubwayStation(
        id: 46,
        line: 4,
        ordinal: 46,
        nameUz: "Tolarik",
        nameRu: "Толарик",
        nameEn: "Tolarik",
        latitude: 41.24451390,
        longitude: 69.28495680,
        locationId: 5,
      ),
      SubwayStation(
        id: 47,
        line: 4,
        ordinal: 47,
        nameUz: "Xonabod",
        nameRu: "Ханабад",
        nameEn: "Xonabod",
        latitude: 41.23001030,
        longitude: 69.27043530,
        locationId: 5,
      ),
      SubwayStation(
        id: 48,
        line: 4,
        ordinal: 48,
        nameUz: "Quruvchilar",
        nameRu: "Курувчилар",
        nameEn: "Quruvchilar",
        latitude: 41.22163670,
        longitude: 69.26050330,
        locationId: 5,
      ),
      SubwayStation(
        id: 49,
        line: 4,
        ordinal: 49,
        nameUz: "Turon",
        nameRu: "Турон",
        nameEn: "Turon",
        latitude: 41.21068130,
        longitude: 69.23415400,
        locationId: 5,
      ),
      SubwayStation(
        id: 50,
        line: 4,
        ordinal: 50,
        nameUz: "Qipchoq",
        nameRu: "Кипчок",
        nameEn: "Qipchoq",
        latitude: 41.20542290,
        longitude: 69.22141120,
        locationId: 5,
      ),
    ],
  };

  static final Map<int, SubwayStation> _stationById = {
    for (final stations in metroStations.values)
      for (final station in stations) station.id: station,
  };

  static final List<SubwayStation> _allStations =
      List<SubwayStation>.unmodifiable([
    for (final stations in metroStations.values) ...stations,
  ]);

  /// Get all stations for a specific line
  static List<SubwayStation> getStationsForLine(int line) {
    return metroStations[line] ?? [];
  }

  /// Get all available metro lines
  static List<int> getAvailableLines() {
    return metroStations.keys.toList()..sort();
  }

  /// Get all stations from all lines
  static List<SubwayStation> getAllStations() => _allStations;

  /// Raw station name for a specific language (no type prefix).
  static String getStationName(SubwayStation station, String language) {
    switch (language) {
      case "uz":
        return station.nameUz ?? station.nameEn ?? station.nameRu ?? "";
      case "ru":
        return station.nameRu ?? station.nameUz ?? station.nameEn ?? "";
      case "en":
        return station.nameEn ?? station.nameUz ?? station.nameRu ?? "";
      default:
        return station.nameUz ?? station.nameEn ?? station.nameRu ?? "";
    }
  }

  /// Station name with localized "st." / "ст." suffix for UI labels.
  static String formatStationLabel(String stationName, String language) {
    final trimmed = stationName.trim();
    if (trimmed.isEmpty) return trimmed;
    final suffix = AppStrings.get("metro_station_abbr", language);
    return "$trimmed $suffix";
  }

  /// Line name with localized "ln." / "лн." suffix for UI labels.
  static String formatLineLabel(String lineName, String language) {
    final trimmed = lineName.trim();
    if (trimmed.isEmpty || trimmed == "Unknown Line") return trimmed;
    final suffix = AppStrings.get("metro_line_abbr", language);
    return "$trimmed $suffix";
  }

  /// Get station display name for a specific language.
  /// [stationId] - station ID
  /// [language] - language code ("en", "ru", "uz")
  static String getStationDisplayName(int stationId, String language) {
    final station = getStationById(stationId);
    if (station == null) return "";
    return getStationName(station, language);
  }

  /// Station display name with type suffix (e.g. "Чиланзар ст.").
  static String getStationLabel(int stationId, String language) {
    return formatStationLabel(
        getStationDisplayName(stationId, language), language);
  }

  /// Station label from a [SubwayStation] instance.
  static String getStationLabelFromStation(
    SubwayStation station,
    String language,
  ) {
    return formatStationLabel(getStationName(station, language), language);
  }

  /// Get a specific station by ID
  static SubwayStation? getStationById(int id) => _stationById[id];

  /// Get stations by name (case-insensitive search)
  static List<SubwayStation> getStationsByName(String name) {
    final lowercaseName = name.toLowerCase();
    final results = <SubwayStation>[];

    for (final station in _allStations) {
      if ((station.nameUz?.toLowerCase().contains(lowercaseName) ?? false) ||
          (station.nameRu?.toLowerCase().contains(lowercaseName) ?? false) ||
          (station.nameEn?.toLowerCase().contains(lowercaseName) ?? false)) {
        results.add(station);
      }
    }

    return results;
  }

  /// Get metro line name in a specific language
  /// [line] - line number (1-4)
  /// [language] - language code ("en", "ru", "uz")
  static String getLineName(int line, String language) {
    final lineNames = metroLineNames[line];
    if (lineNames == null) return "Unknown Line";

    return lineNames[language] ?? lineNames["en"] ?? "Unknown Line";
  }

  /// Line display name with type prefix (e.g. "лн. Чиланзар").
  static String getLineLabel(int line, String language) {
    return formatLineLabel(getLineName(line, language), language);
  }

  /// Get metro line name in English
  static String getLineNameEn(int line) {
    return getLineName(line, "en");
  }

  /// Get metro line name in Russian
  static String getLineNameRu(int line) {
    return getLineName(line, "ru");
  }

  /// Get metro line name in Uzbek
  static String getLineNameUz(int line) {
    return getLineName(line, "uz");
  }

  /// Get all available line names in a specific language
  static Map<int, String> getAllLineNames(String language) {
    final result = <int, String>{};
    for (final line in metroLineNames.keys) {
      result[line] = getLineName(line, language);
    }
    return result;
  }

  /// Get all available line names in English
  static Map<int, String> getAllLineNamesEn() {
    return getAllLineNames("en");
  }

  /// Get all available line names in Russian
  static Map<int, String> getAllLineNamesRu() {
    return getAllLineNames("ru");
  }

  /// Get all available line names in Uzbek
  static Map<int, String> getAllLineNamesUz() {
    return getAllLineNames("uz");
  }

  /// Get coordinates for a metro station by ID
  static Map<String, double>? getMetroStationCoordinatesById(int stationId) {
    final station = getStationById(stationId);
    if (station == null ||
        station.latitude == null ||
        station.longitude == null) {
      return null;
    }

    return {"latitude": station.latitude!, "longitude": station.longitude!};
  }

  /// Get coordinates for a metro station by name
  static Map<String, double>? getMetroStationCoordinatesByName(
    String stationName,
  ) {
    final matchingStations = getStationsByName(stationName);
    if (matchingStations.isEmpty) return null;

    // Return coordinates of the first match
    final station = matchingStations.first;
    if (station.latitude == null || station.longitude == null) return null;

    return {"latitude": station.latitude!, "longitude": station.longitude!};
  }

  /// Transfer station pairs - when one station is selected, automatically include its transfer partner
  static const Map<int, int> transferStationPairs = {
    // Pair 1: Paxtakor (Line 1) ↔ Alisher Navoiy (Line 2)
    12: 22, // Paxtakor → Alisher Navoiy
    22: 12, // Alisher Navoiy → Paxtakor
    // Pair 2: A. Temur Xiyoboni (Line 1) ↔ Yunus Rajabiy (Line 3)
    14: 30, // A. Temur Xiyoboni → Yunus Rajabiy
    30: 14, // Yunus Rajabiy → A. Temur Xiyoboni
    // Pair 3: Oybek (Line 2) ↔ Mingurik (Line 3)
    25: 29, // Oybek → Mingurik
    29: 25, // Mingurik → Oybek
    // Pair 4: Chinor (Line 1) ↔ Qipchoq (Line 4)
    1: 50, // Chinor → Qipchoq
    50: 1, // Qipchoq → Chinor
    // Pair 5: Doʻstlik (Line 2) ↔ Texnopark (Line 4)
    28: 37, // Doʻstlik → Texnopark
    37: 28, // Texnopark → Doʻstlik
  };

  /// Get transfer partner station ID for a given station
  /// Returns null if the station doesn't have a transfer partner
  static int? getTransferPartnerStationId(int stationId) {
    return transferStationPairs[stationId];
  }

  /// Expand station IDs to include transfer partners
  /// Takes a list of station IDs and returns a new list that includes transfer partners
  static List<int> expandWithTransferStations(List<int> stationIds) {
    final expandedIds = <int>{};

    for (final stationId in stationIds) {
      // Add the original station
      expandedIds.add(stationId);

      // Add transfer partner if it exists
      final transferPartner = getTransferPartnerStationId(stationId);
      if (transferPartner != null) {
        expandedIds.add(transferPartner);
      }
    }

    return expandedIds.toList();
  }

  /// Collapse mirrored transfer partners to a single display item while keeping
  /// the first station encountered, so search/order semantics stay unchanged.
  static List<T> dedupeTransferStationPairs<T>(
    Iterable<T> stations,
    int Function(T station) stationIdOf,
  ) {
    final result = <T>[];
    final seenKeys = <String>{};

    for (final station in stations) {
      final stationId = stationIdOf(station);
      final transferPartnerId = getTransferPartnerStationId(stationId);
      final key = transferPartnerId == null
          ? "$stationId"
          : stationId < transferPartnerId
              ? "$stationId:$transferPartnerId"
              : "$transferPartnerId:$stationId";

      if (seenKeys.add(key)) result.add(station);
    }

    return result;
  }

  /// Get all transfer station pairs as a list of pairs
  static List<Map<String, int>> getAllTransferStationPairs() {
    final pairs = <Map<String, int>>[];
    final processed = <int>{};

    for (final entry in transferStationPairs.entries) {
      if (!processed.contains(entry.key)) {
        pairs.add({"station1": entry.key, "station2": entry.value});
        processed.add(entry.key);
        processed.add(entry.value);
      }
    }

    return pairs;
  }

  /// Check if a station is a transfer station
  static bool isTransferStation(int stationId) {
    return transferStationPairs.containsKey(stationId);
  }

  /// Get the connected transfer station for a given station
  /// Returns null if the station is not a transfer station
  static SubwayStation? getConnectedTransferStation(int stationId) {
    final transferPartnerId = getTransferPartnerStationId(stationId);
    if (transferPartnerId == null) return null;

    return getStationById(transferPartnerId);
  }

  /// Get transfer station info for UI display
  /// Returns a map with transfer information if the station is a transfer station
  static Map<String, dynamic>? getTransferStationInfo(int stationId) {
    if (!isTransferStation(stationId)) return null;

    final connectedStation = getConnectedTransferStation(stationId);
    if (connectedStation == null) return null;

    return {
      "isTransfer": true,
      "connectedStationId": connectedStation.id,
      "connectedStationName": connectedStation.nameUz,
      "connectedStationNameRu": connectedStation.nameRu,
      "connectedStationNameEn": connectedStation.nameEn,
      "connectedStationLine": connectedStation.line,
    };
  }
}
