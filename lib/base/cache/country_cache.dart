import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/country.dart";

/// Static cache for the ISO 3166-1 country list.
///
/// Mirrors the shape of [RegionCache] / [MetroCache]: a const data blob
/// shipped with the app, hidden behind an `initialize()` gate so callers can
/// treat it like a lazily-loaded API cache. This keeps the country picker
/// fast and makes it trivial to swap the data source for a real backend
/// call later without touching UI code.
class CountryCache {
  CountryCache._();

  static List<Country> _cachedCountries = <Country>[];
  static bool _isInitialized = false;

  /// ISO 3166-1 alpha-2 code used as the default selection in onboarding.
  static const String defaultIso2 = "UZ";

  /// Countries that should always appear at the top of the picker, in
  /// order. Covers Uzbekistan and its closest neighbors / Russian-speaking
  /// CIS. The remainder of the list is sorted alphabetically by localized
  /// name.
  static const List<String> pinnedIsoCodes = <String>[
    "UZ",
    "RU",
    "KZ",
    "KG",
    "TJ",
    "TM",
    "AZ",
    "BY",
    "UA",
    "TR",
  ];

  /// Populate the cache. Cheap and synchronous under the hood, but kept
  /// `Future` to match [RegionCache.initialize] so callers can be swapped
  /// to an HTTP-backed implementation without touching their call sites.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      logger.d("=== COUNTRY CACHE INITIALIZATION ===");
      logger.d("Loading countries from static catalog...");
      _cachedCountries = _getCountriesFromApi();
      _isInitialized = true;
      logger.d(
        "Country cache initialized with ${_cachedCountries.length} countries",
      );
      logger.d("======================================");
    } catch (e) {
      logger.d("Error initializing country cache: $e");
      rethrow;
    }
  }

  static bool get isInitialized => _isInitialized;

  /// Clears the cache. Useful for tests.
  static void clearCache() {
    _cachedCountries = <Country>[];
    _isInitialized = false;
    logger.d("Country cache cleared");
  }

  /// All countries in the cache. Order is not meaningful — use
  /// [getCountriesSortedByLanguage] for the picker.
  static List<Country> getAllCountries() {
    if (!_isInitialized) {
      logger.d("Country cache not initialized, returning empty list");
      return <Country>[];
    }
    return _cachedCountries;
  }

  /// Returns countries ready for display: [pinnedIsoCodes] first in the
  /// order given, then the rest alphabetically by the localized name in
  /// [language].
  static List<Country> getCountriesSortedByLanguage(String language) {
    if (!_isInitialized) {
      logger.d("Country cache not initialized, returning empty list");
      return <Country>[];
    }

    final pinnedSet = pinnedIsoCodes.toSet();
    final pinned = <Country>[];
    for (final code in pinnedIsoCodes) {
      final c = getCountryByIso2(code);
      if (c != null) pinned.add(c);
    }

    final rest = _cachedCountries
        .where((c) => !pinnedSet.contains(c.iso2))
        .toList()
      ..sort(
        (a, b) => a
            .getLocalizedName(language)
            .toLowerCase()
            .compareTo(b.getLocalizedName(language).toLowerCase()),
      );

    return <Country>[...pinned, ...rest];
  }

  /// Look up a country by its ISO 3166-1 alpha-2 code (case-insensitive).
  /// Returns `null` if the code is not in the catalog.
  static Country? getCountryByIso2(String? iso2) {
    if (!_isInitialized) {
      logger.d("Country cache not initialized, returning null");
      return null;
    }
    if (iso2 == null || iso2.isEmpty) return null;
    final upper = iso2.toUpperCase();
    for (final c in _cachedCountries) {
      if (c.iso2 == upper) return c;
    }
    return null;
  }

  /// Case-insensitive search across localized names.
  static List<Country> getCountriesByName(String name) {
    if (!_isInitialized) return <Country>[];

    final needle = name.toLowerCase().trim();
    if (needle.isEmpty) return List<Country>.from(_cachedCountries);

    return _cachedCountries.where((c) {
      return c.nameEn.toLowerCase().contains(needle) ||
          c.nameRu.toLowerCase().contains(needle) ||
          c.nameUz.toLowerCase().contains(needle) ||
          c.iso2.toLowerCase().contains(needle);
    }).toList();
  }

  /// Localized name for the given ISO 3166-1 alpha-2 code.
  static String getCountryName(String iso2, String language) {
    final country = getCountryByIso2(iso2);
    if (country == null) return "Unknown Country";
    return country.getLocalizedName(language);
  }

  // ---------------------------------------------------------------------
  // Static data source
  // ---------------------------------------------------------------------

  /// Returns the full ISO 3166-1 country list (with emoji flags and
  /// localized names). Kept as a private method so the signature mirrors
  /// [RegionCache._getRegionsFromApi]; swapping this for a real API call
  /// is a local change inside the cache.
  static List<Country> _getCountriesFromApi() {
    return const <Country>[
      Country(iso2: "UZ", flag: "🇺🇿", nameEn: "Uzbekistan", nameRu: "Узбекистан", nameUz: "O'zbekiston"),
      Country(iso2: "RU", flag: "🇷🇺", nameEn: "Russia", nameRu: "Россия", nameUz: "Rossiya"),
      Country(iso2: "KZ", flag: "🇰🇿", nameEn: "Kazakhstan", nameRu: "Казахстан", nameUz: "Qozog'iston"),
      Country(iso2: "KG", flag: "🇰🇬", nameEn: "Kyrgyzstan", nameRu: "Киргизия", nameUz: "Qirg'iziston"),
      Country(iso2: "TJ", flag: "🇹🇯", nameEn: "Tajikistan", nameRu: "Таджикистан", nameUz: "Tojikiston"),
      Country(iso2: "TM", flag: "🇹🇲", nameEn: "Turkmenistan", nameRu: "Туркменистан", nameUz: "Turkmaniston"),
      Country(iso2: "AZ", flag: "🇦🇿", nameEn: "Azerbaijan", nameRu: "Азербайджан", nameUz: "Ozarbayjon"),
      Country(iso2: "BY", flag: "🇧🇾", nameEn: "Belarus", nameRu: "Беларусь", nameUz: "Belarus"),
      Country(iso2: "UA", flag: "🇺🇦", nameEn: "Ukraine", nameRu: "Украина", nameUz: "Ukraina"),
      Country(iso2: "TR", flag: "🇹🇷", nameEn: "Turkey", nameRu: "Турция", nameUz: "Turkiya"),
      Country(iso2: "AF", flag: "🇦🇫", nameEn: "Afghanistan", nameRu: "Афганистан", nameUz: "Afg'oniston"),
      Country(iso2: "AL", flag: "🇦🇱", nameEn: "Albania", nameRu: "Албания", nameUz: "Albaniya"),
      Country(iso2: "DZ", flag: "🇩🇿", nameEn: "Algeria", nameRu: "Алжир", nameUz: "Jazoir"),
      Country(iso2: "AS", flag: "🇦🇸", nameEn: "American Samoa", nameRu: "Американское Самоа", nameUz: "Amerika Samoasi"),
      Country(iso2: "AD", flag: "🇦🇩", nameEn: "Andorra", nameRu: "Андорра", nameUz: "Andorra"),
      Country(iso2: "AO", flag: "🇦🇴", nameEn: "Angola", nameRu: "Ангола", nameUz: "Angola"),
      Country(iso2: "AI", flag: "🇦🇮", nameEn: "Anguilla", nameRu: "Ангилья", nameUz: "Angilya"),
      Country(iso2: "AQ", flag: "🇦🇶", nameEn: "Antarctica", nameRu: "Антарктида", nameUz: "Antarktida"),
      Country(iso2: "AG", flag: "🇦🇬", nameEn: "Antigua and Barbuda", nameRu: "Антигуа и Барбуда", nameUz: "Antigua va Barbuda"),
      Country(iso2: "AR", flag: "🇦🇷", nameEn: "Argentina", nameRu: "Аргентина", nameUz: "Argentina"),
      Country(iso2: "AM", flag: "🇦🇲", nameEn: "Armenia", nameRu: "Армения", nameUz: "Armaniston"),
      Country(iso2: "AW", flag: "🇦🇼", nameEn: "Aruba", nameRu: "Аруба", nameUz: "Aruba"),
      Country(iso2: "AU", flag: "🇦🇺", nameEn: "Australia", nameRu: "Австралия", nameUz: "Avstraliya"),
      Country(iso2: "AT", flag: "🇦🇹", nameEn: "Austria", nameRu: "Австрия", nameUz: "Avstriya"),
      Country(iso2: "BS", flag: "🇧🇸", nameEn: "Bahamas", nameRu: "Багамы", nameUz: "Bagama orollari"),
      Country(iso2: "BH", flag: "🇧🇭", nameEn: "Bahrain", nameRu: "Бахрейн", nameUz: "Bahrayn"),
      Country(iso2: "BD", flag: "🇧🇩", nameEn: "Bangladesh", nameRu: "Бангладеш", nameUz: "Bangladesh"),
      Country(iso2: "BB", flag: "🇧🇧", nameEn: "Barbados", nameRu: "Барбадос", nameUz: "Barbados"),
      Country(iso2: "BE", flag: "🇧🇪", nameEn: "Belgium", nameRu: "Бельгия", nameUz: "Belgiya"),
      Country(iso2: "BZ", flag: "🇧🇿", nameEn: "Belize", nameRu: "Белиз", nameUz: "Beliz"),
      Country(iso2: "BJ", flag: "🇧🇯", nameEn: "Benin", nameRu: "Бенин", nameUz: "Benin"),
      Country(iso2: "BM", flag: "🇧🇲", nameEn: "Bermuda", nameRu: "Бермуды", nameUz: "Bermuda orollari"),
      Country(iso2: "BT", flag: "🇧🇹", nameEn: "Bhutan", nameRu: "Бутан", nameUz: "Butan"),
      Country(iso2: "BO", flag: "🇧🇴", nameEn: "Bolivia", nameRu: "Боливия", nameUz: "Boliviya"),
      Country(iso2: "BQ", flag: "🇧🇶", nameEn: "Bonaire, Sint Eustatius and Saba", nameRu: "Бонэйр, Синт-Эстатиус и Саба", nameUz: "Boneyr, Sint-Estatius va Saba"),
      Country(iso2: "BA", flag: "🇧🇦", nameEn: "Bosnia and Herzegovina", nameRu: "Босния и Герцеговина", nameUz: "Bosniya va Gertsegovina"),
      Country(iso2: "BW", flag: "🇧🇼", nameEn: "Botswana", nameRu: "Ботсвана", nameUz: "Botsvana"),
      Country(iso2: "BV", flag: "🇧🇻", nameEn: "Bouvet Island", nameRu: "Остров Буве", nameUz: "Buve oroli"),
      Country(iso2: "BR", flag: "🇧🇷", nameEn: "Brazil", nameRu: "Бразилия", nameUz: "Braziliya"),
      Country(iso2: "IO", flag: "🇮🇴", nameEn: "British Indian Ocean Territory", nameRu: "Британская территория в Индийском океане", nameUz: "Britaniyaning Hind okeanidagi hududi"),
      Country(iso2: "BN", flag: "🇧🇳", nameEn: "Brunei", nameRu: "Бруней", nameUz: "Bruney"),
      Country(iso2: "BG", flag: "🇧🇬", nameEn: "Bulgaria", nameRu: "Болгария", nameUz: "Bolgariya"),
      Country(iso2: "BF", flag: "🇧🇫", nameEn: "Burkina Faso", nameRu: "Буркина-Фасо", nameUz: "Burkina-Faso"),
      Country(iso2: "BI", flag: "🇧🇮", nameEn: "Burundi", nameRu: "Бурунди", nameUz: "Burundi"),
      Country(iso2: "CV", flag: "🇨🇻", nameEn: "Cabo Verde", nameRu: "Кабо-Верде", nameUz: "Kabo-Verde"),
      Country(iso2: "KH", flag: "🇰🇭", nameEn: "Cambodia", nameRu: "Камбоджа", nameUz: "Kambodja"),
      Country(iso2: "CM", flag: "🇨🇲", nameEn: "Cameroon", nameRu: "Камерун", nameUz: "Kamerun"),
      Country(iso2: "CA", flag: "🇨🇦", nameEn: "Canada", nameRu: "Канада", nameUz: "Kanada"),
      Country(iso2: "KY", flag: "🇰🇾", nameEn: "Cayman Islands", nameRu: "Каймановы острова", nameUz: "Kayman orollari"),
      Country(iso2: "CF", flag: "🇨🇫", nameEn: "Central African Republic", nameRu: "Центральноафриканская Республика", nameUz: "Markaziy Afrika Respublikasi"),
      Country(iso2: "TD", flag: "🇹🇩", nameEn: "Chad", nameRu: "Чад", nameUz: "Chad"),
      Country(iso2: "CL", flag: "🇨🇱", nameEn: "Chile", nameRu: "Чили", nameUz: "Chili"),
      Country(iso2: "CN", flag: "🇨🇳", nameEn: "China", nameRu: "Китай", nameUz: "Xitoy"),
      Country(iso2: "CX", flag: "🇨🇽", nameEn: "Christmas Island", nameRu: "Остров Рождества", nameUz: "Rojdestvo oroli"),
      Country(iso2: "CC", flag: "🇨🇨", nameEn: "Cocos (Keeling) Islands", nameRu: "Кокосовые острова", nameUz: "Kokos orollari"),
      Country(iso2: "CO", flag: "🇨🇴", nameEn: "Colombia", nameRu: "Колумбия", nameUz: "Kolumbiya"),
      Country(iso2: "KM", flag: "🇰🇲", nameEn: "Comoros", nameRu: "Коморы", nameUz: "Komor orollari"),
      Country(iso2: "CG", flag: "🇨🇬", nameEn: "Congo", nameRu: "Конго", nameUz: "Kongo"),
      Country(iso2: "CD", flag: "🇨🇩", nameEn: "Congo (DRC)", nameRu: "Демократическая Республика Конго", nameUz: "Kongo Demokratik Respublikasi"),
      Country(iso2: "CK", flag: "🇨🇰", nameEn: "Cook Islands", nameRu: "Острова Кука", nameUz: "Kuk orollari"),
      Country(iso2: "CR", flag: "🇨🇷", nameEn: "Costa Rica", nameRu: "Коста-Рика", nameUz: "Kosta-Rika"),
      Country(iso2: "CI", flag: "🇨🇮", nameEn: "Côte d'Ivoire", nameRu: "Кот-д'Ивуар", nameUz: "Kot-d'Ivuar"),
      Country(iso2: "HR", flag: "🇭🇷", nameEn: "Croatia", nameRu: "Хорватия", nameUz: "Xorvatiya"),
      Country(iso2: "CU", flag: "🇨🇺", nameEn: "Cuba", nameRu: "Куба", nameUz: "Kuba"),
      Country(iso2: "CW", flag: "🇨🇼", nameEn: "Curaçao", nameRu: "Кюрасао", nameUz: "Kyurasao"),
      Country(iso2: "CY", flag: "🇨🇾", nameEn: "Cyprus", nameRu: "Кипр", nameUz: "Kipr"),
      Country(iso2: "CZ", flag: "🇨🇿", nameEn: "Czechia", nameRu: "Чехия", nameUz: "Chexiya"),
      Country(iso2: "DK", flag: "🇩🇰", nameEn: "Denmark", nameRu: "Дания", nameUz: "Daniya"),
      Country(iso2: "DJ", flag: "🇩🇯", nameEn: "Djibouti", nameRu: "Джибути", nameUz: "Djibuti"),
      Country(iso2: "DM", flag: "🇩🇲", nameEn: "Dominica", nameRu: "Доминика", nameUz: "Dominika"),
      Country(iso2: "DO", flag: "🇩🇴", nameEn: "Dominican Republic", nameRu: "Доминиканская Республика", nameUz: "Dominikan Respublikasi"),
      Country(iso2: "EC", flag: "🇪🇨", nameEn: "Ecuador", nameRu: "Эквадор", nameUz: "Ekvador"),
      Country(iso2: "EG", flag: "🇪🇬", nameEn: "Egypt", nameRu: "Египет", nameUz: "Misr"),
      Country(iso2: "SV", flag: "🇸🇻", nameEn: "El Salvador", nameRu: "Сальвадор", nameUz: "Salvador"),
      Country(iso2: "GQ", flag: "🇬🇶", nameEn: "Equatorial Guinea", nameRu: "Экваториальная Гвинея", nameUz: "Ekvatorial Gvineya"),
      Country(iso2: "ER", flag: "🇪🇷", nameEn: "Eritrea", nameRu: "Эритрея", nameUz: "Eritreya"),
      Country(iso2: "EE", flag: "🇪🇪", nameEn: "Estonia", nameRu: "Эстония", nameUz: "Estoniya"),
      Country(iso2: "SZ", flag: "🇸🇿", nameEn: "Eswatini", nameRu: "Эсватини", nameUz: "Esvatini"),
      Country(iso2: "ET", flag: "🇪🇹", nameEn: "Ethiopia", nameRu: "Эфиопия", nameUz: "Efiopiya"),
      Country(iso2: "FK", flag: "🇫🇰", nameEn: "Falkland Islands", nameRu: "Фолклендские острова", nameUz: "Folklend orollari"),
      Country(iso2: "FO", flag: "🇫🇴", nameEn: "Faroe Islands", nameRu: "Фарерские острова", nameUz: "Farer orollari"),
      Country(iso2: "FJ", flag: "🇫🇯", nameEn: "Fiji", nameRu: "Фиджи", nameUz: "Fiji"),
      Country(iso2: "FI", flag: "🇫🇮", nameEn: "Finland", nameRu: "Финляндия", nameUz: "Finlyandiya"),
      Country(iso2: "FR", flag: "🇫🇷", nameEn: "France", nameRu: "Франция", nameUz: "Fransiya"),
      Country(iso2: "GF", flag: "🇬🇫", nameEn: "French Guiana", nameRu: "Французская Гвиана", nameUz: "Fransuz Gvianasi"),
      Country(iso2: "PF", flag: "🇵🇫", nameEn: "French Polynesia", nameRu: "Французская Полинезия", nameUz: "Fransuz Polineziyasi"),
      Country(iso2: "TF", flag: "🇹🇫", nameEn: "French Southern Territories", nameRu: "Французские Южные территории", nameUz: "Fransuz Janubiy hududlari"),
      Country(iso2: "GA", flag: "🇬🇦", nameEn: "Gabon", nameRu: "Габон", nameUz: "Gabon"),
      Country(iso2: "GM", flag: "🇬🇲", nameEn: "Gambia", nameRu: "Гамбия", nameUz: "Gambiya"),
      Country(iso2: "GE", flag: "🇬🇪", nameEn: "Georgia", nameRu: "Грузия", nameUz: "Gruziya"),
      Country(iso2: "DE", flag: "🇩🇪", nameEn: "Germany", nameRu: "Германия", nameUz: "Germaniya"),
      Country(iso2: "GH", flag: "🇬🇭", nameEn: "Ghana", nameRu: "Гана", nameUz: "Gana"),
      Country(iso2: "GI", flag: "🇬🇮", nameEn: "Gibraltar", nameRu: "Гибралтар", nameUz: "Gibraltar"),
      Country(iso2: "GR", flag: "🇬🇷", nameEn: "Greece", nameRu: "Греция", nameUz: "Gretsiya"),
      Country(iso2: "GL", flag: "🇬🇱", nameEn: "Greenland", nameRu: "Гренландия", nameUz: "Grenlandiya"),
      Country(iso2: "GD", flag: "🇬🇩", nameEn: "Grenada", nameRu: "Гренада", nameUz: "Grenada"),
      Country(iso2: "GP", flag: "🇬🇵", nameEn: "Guadeloupe", nameRu: "Гваделупа", nameUz: "Gvadelupa"),
      Country(iso2: "GU", flag: "🇬🇺", nameEn: "Guam", nameRu: "Гуам", nameUz: "Guam"),
      Country(iso2: "GT", flag: "🇬🇹", nameEn: "Guatemala", nameRu: "Гватемала", nameUz: "Gvatemala"),
      Country(iso2: "GG", flag: "🇬🇬", nameEn: "Guernsey", nameRu: "Гернси", nameUz: "Gernsi"),
      Country(iso2: "GN", flag: "🇬🇳", nameEn: "Guinea", nameRu: "Гвинея", nameUz: "Gvineya"),
      Country(iso2: "GW", flag: "🇬🇼", nameEn: "Guinea-Bissau", nameRu: "Гвинея-Бисау", nameUz: "Gvineya-Bisau"),
      Country(iso2: "GY", flag: "🇬🇾", nameEn: "Guyana", nameRu: "Гайана", nameUz: "Gayana"),
      Country(iso2: "HT", flag: "🇭🇹", nameEn: "Haiti", nameRu: "Гаити", nameUz: "Gaiti"),
      Country(iso2: "HM", flag: "🇭🇲", nameEn: "Heard Island and McDonald Islands", nameRu: "Остров Херд и острова Макдональд", nameUz: "Xerd oroli va Makdonald orollari"),
      Country(iso2: "VA", flag: "🇻🇦", nameEn: "Holy See (Vatican)", nameRu: "Ватикан", nameUz: "Vatikan"),
      Country(iso2: "HN", flag: "🇭🇳", nameEn: "Honduras", nameRu: "Гондурас", nameUz: "Gonduras"),
      Country(iso2: "HK", flag: "🇭🇰", nameEn: "Hong Kong", nameRu: "Гонконг", nameUz: "Gonkong"),
      Country(iso2: "HU", flag: "🇭🇺", nameEn: "Hungary", nameRu: "Венгрия", nameUz: "Vengriya"),
      Country(iso2: "IS", flag: "🇮🇸", nameEn: "Iceland", nameRu: "Исландия", nameUz: "Islandiya"),
      Country(iso2: "IN", flag: "🇮🇳", nameEn: "India", nameRu: "Индия", nameUz: "Hindiston"),
      Country(iso2: "ID", flag: "🇮🇩", nameEn: "Indonesia", nameRu: "Индонезия", nameUz: "Indoneziya"),
      Country(iso2: "IR", flag: "🇮🇷", nameEn: "Iran", nameRu: "Иран", nameUz: "Eron"),
      Country(iso2: "IQ", flag: "🇮🇶", nameEn: "Iraq", nameRu: "Ирак", nameUz: "Iroq"),
      Country(iso2: "IE", flag: "🇮🇪", nameEn: "Ireland", nameRu: "Ирландия", nameUz: "Irlandiya"),
      Country(iso2: "IM", flag: "🇮🇲", nameEn: "Isle of Man", nameRu: "Остров Мэн", nameUz: "Men oroli"),
      Country(iso2: "IL", flag: "🇮🇱", nameEn: "Israel", nameRu: "Израиль", nameUz: "Isroil"),
      Country(iso2: "IT", flag: "🇮🇹", nameEn: "Italy", nameRu: "Италия", nameUz: "Italiya"),
      Country(iso2: "JM", flag: "🇯🇲", nameEn: "Jamaica", nameRu: "Ямайка", nameUz: "Yamayka"),
      Country(iso2: "JP", flag: "🇯🇵", nameEn: "Japan", nameRu: "Япония", nameUz: "Yaponiya"),
      Country(iso2: "JE", flag: "🇯🇪", nameEn: "Jersey", nameRu: "Джерси", nameUz: "Jersi"),
      Country(iso2: "JO", flag: "🇯🇴", nameEn: "Jordan", nameRu: "Иордания", nameUz: "Iordaniya"),
      Country(iso2: "KE", flag: "🇰🇪", nameEn: "Kenya", nameRu: "Кения", nameUz: "Keniya"),
      Country(iso2: "KI", flag: "🇰🇮", nameEn: "Kiribati", nameRu: "Кирибати", nameUz: "Kiribati"),
      Country(iso2: "KP", flag: "🇰🇵", nameEn: "North Korea", nameRu: "КНДР", nameUz: "Shimoliy Koreya"),
      Country(iso2: "KR", flag: "🇰🇷", nameEn: "South Korea", nameRu: "Южная Корея", nameUz: "Janubiy Koreya"),
      Country(iso2: "KW", flag: "🇰🇼", nameEn: "Kuwait", nameRu: "Кувейт", nameUz: "Quvayt"),
      Country(iso2: "LA", flag: "🇱🇦", nameEn: "Laos", nameRu: "Лаос", nameUz: "Laos"),
      Country(iso2: "LV", flag: "🇱🇻", nameEn: "Latvia", nameRu: "Латвия", nameUz: "Latviya"),
      Country(iso2: "LB", flag: "🇱🇧", nameEn: "Lebanon", nameRu: "Ливан", nameUz: "Livan"),
      Country(iso2: "LS", flag: "🇱🇸", nameEn: "Lesotho", nameRu: "Лесото", nameUz: "Lesoto"),
      Country(iso2: "LR", flag: "🇱🇷", nameEn: "Liberia", nameRu: "Либерия", nameUz: "Liberiya"),
      Country(iso2: "LY", flag: "🇱🇾", nameEn: "Libya", nameRu: "Ливия", nameUz: "Liviya"),
      Country(iso2: "LI", flag: "🇱🇮", nameEn: "Liechtenstein", nameRu: "Лихтенштейн", nameUz: "Lixtenshteyn"),
      Country(iso2: "LT", flag: "🇱🇹", nameEn: "Lithuania", nameRu: "Литва", nameUz: "Litva"),
      Country(iso2: "LU", flag: "🇱🇺", nameEn: "Luxembourg", nameRu: "Люксембург", nameUz: "Lyuksemburg"),
      Country(iso2: "MO", flag: "🇲🇴", nameEn: "Macao", nameRu: "Макао", nameUz: "Makao"),
      Country(iso2: "MG", flag: "🇲🇬", nameEn: "Madagascar", nameRu: "Мадагаскар", nameUz: "Madagaskar"),
      Country(iso2: "MW", flag: "🇲🇼", nameEn: "Malawi", nameRu: "Малави", nameUz: "Malavi"),
      Country(iso2: "MY", flag: "🇲🇾", nameEn: "Malaysia", nameRu: "Малайзия", nameUz: "Malayziya"),
      Country(iso2: "MV", flag: "🇲🇻", nameEn: "Maldives", nameRu: "Мальдивы", nameUz: "Maldiv orollari"),
      Country(iso2: "ML", flag: "🇲🇱", nameEn: "Mali", nameRu: "Мали", nameUz: "Mali"),
      Country(iso2: "MT", flag: "🇲🇹", nameEn: "Malta", nameRu: "Мальта", nameUz: "Malta"),
      Country(iso2: "MH", flag: "🇲🇭", nameEn: "Marshall Islands", nameRu: "Маршалловы Острова", nameUz: "Marshal orollari"),
      Country(iso2: "MQ", flag: "🇲🇶", nameEn: "Martinique", nameRu: "Мартиника", nameUz: "Martinika"),
      Country(iso2: "MR", flag: "🇲🇷", nameEn: "Mauritania", nameRu: "Мавритания", nameUz: "Mavritaniya"),
      Country(iso2: "MU", flag: "🇲🇺", nameEn: "Mauritius", nameRu: "Маврикий", nameUz: "Mavrikiy"),
      Country(iso2: "YT", flag: "🇾🇹", nameEn: "Mayotte", nameRu: "Майотта", nameUz: "Mayotta"),
      Country(iso2: "MX", flag: "🇲🇽", nameEn: "Mexico", nameRu: "Мексика", nameUz: "Meksika"),
      Country(iso2: "FM", flag: "🇫🇲", nameEn: "Micronesia", nameRu: "Микронезия", nameUz: "Mikroneziya"),
      Country(iso2: "MD", flag: "🇲🇩", nameEn: "Moldova", nameRu: "Молдова", nameUz: "Moldova"),
      Country(iso2: "MC", flag: "🇲🇨", nameEn: "Monaco", nameRu: "Монако", nameUz: "Monako"),
      Country(iso2: "MN", flag: "🇲🇳", nameEn: "Mongolia", nameRu: "Монголия", nameUz: "Mo'g'uliston"),
      Country(iso2: "ME", flag: "🇲🇪", nameEn: "Montenegro", nameRu: "Черногория", nameUz: "Chernogoriya"),
      Country(iso2: "MS", flag: "🇲🇸", nameEn: "Montserrat", nameRu: "Монтсеррат", nameUz: "Montserrat"),
      Country(iso2: "MA", flag: "🇲🇦", nameEn: "Morocco", nameRu: "Марокко", nameUz: "Marokash"),
      Country(iso2: "MZ", flag: "🇲🇿", nameEn: "Mozambique", nameRu: "Мозамбик", nameUz: "Mozambik"),
      Country(iso2: "MM", flag: "🇲🇲", nameEn: "Myanmar", nameRu: "Мьянма", nameUz: "Myanma"),
      Country(iso2: "NA", flag: "🇳🇦", nameEn: "Namibia", nameRu: "Намибия", nameUz: "Namibiya"),
      Country(iso2: "NR", flag: "🇳🇷", nameEn: "Nauru", nameRu: "Науру", nameUz: "Nauru"),
      Country(iso2: "NP", flag: "🇳🇵", nameEn: "Nepal", nameRu: "Непал", nameUz: "Nepal"),
      Country(iso2: "NL", flag: "🇳🇱", nameEn: "Netherlands", nameRu: "Нидерланды", nameUz: "Niderlandiya"),
      Country(iso2: "NC", flag: "🇳🇨", nameEn: "New Caledonia", nameRu: "Новая Каледония", nameUz: "Yangi Kaledoniya"),
      Country(iso2: "NZ", flag: "🇳🇿", nameEn: "New Zealand", nameRu: "Новая Зеландия", nameUz: "Yangi Zelandiya"),
      Country(iso2: "NI", flag: "🇳🇮", nameEn: "Nicaragua", nameRu: "Никарагуа", nameUz: "Nikaragua"),
      Country(iso2: "NE", flag: "🇳🇪", nameEn: "Niger", nameRu: "Нигер", nameUz: "Niger"),
      Country(iso2: "NG", flag: "🇳🇬", nameEn: "Nigeria", nameRu: "Нигерия", nameUz: "Nigeriya"),
      Country(iso2: "NU", flag: "🇳🇺", nameEn: "Niue", nameRu: "Ниуэ", nameUz: "Niue"),
      Country(iso2: "NF", flag: "🇳🇫", nameEn: "Norfolk Island", nameRu: "Остров Норфолк", nameUz: "Norfolk oroli"),
      Country(iso2: "MK", flag: "🇲🇰", nameEn: "North Macedonia", nameRu: "Северная Македония", nameUz: "Shimoliy Makedoniya"),
      Country(iso2: "MP", flag: "🇲🇵", nameEn: "Northern Mariana Islands", nameRu: "Северные Марианские острова", nameUz: "Shimoliy Mariana orollari"),
      Country(iso2: "NO", flag: "🇳🇴", nameEn: "Norway", nameRu: "Норвегия", nameUz: "Norvegiya"),
      Country(iso2: "OM", flag: "🇴🇲", nameEn: "Oman", nameRu: "Оман", nameUz: "Ummon"),
      Country(iso2: "PK", flag: "🇵🇰", nameEn: "Pakistan", nameRu: "Пакистан", nameUz: "Pokiston"),
      Country(iso2: "PW", flag: "🇵🇼", nameEn: "Palau", nameRu: "Палау", nameUz: "Palau"),
      Country(iso2: "PS", flag: "🇵🇸", nameEn: "Palestine", nameRu: "Палестина", nameUz: "Falastin"),
      Country(iso2: "PA", flag: "🇵🇦", nameEn: "Panama", nameRu: "Панама", nameUz: "Panama"),
      Country(iso2: "PG", flag: "🇵🇬", nameEn: "Papua New Guinea", nameRu: "Папуа — Новая Гвинея", nameUz: "Papua — Yangi Gvineya"),
      Country(iso2: "PY", flag: "🇵🇾", nameEn: "Paraguay", nameRu: "Парагвай", nameUz: "Paragvay"),
      Country(iso2: "PE", flag: "🇵🇪", nameEn: "Peru", nameRu: "Перу", nameUz: "Peru"),
      Country(iso2: "PH", flag: "🇵🇭", nameEn: "Philippines", nameRu: "Филиппины", nameUz: "Filippin"),
      Country(iso2: "PN", flag: "🇵🇳", nameEn: "Pitcairn", nameRu: "Острова Питкэрн", nameUz: "Pitkern orollari"),
      Country(iso2: "PL", flag: "🇵🇱", nameEn: "Poland", nameRu: "Польша", nameUz: "Polsha"),
      Country(iso2: "PT", flag: "🇵🇹", nameEn: "Portugal", nameRu: "Португалия", nameUz: "Portugaliya"),
      Country(iso2: "PR", flag: "🇵🇷", nameEn: "Puerto Rico", nameRu: "Пуэрто-Рико", nameUz: "Puerto-Riko"),
      Country(iso2: "QA", flag: "🇶🇦", nameEn: "Qatar", nameRu: "Катар", nameUz: "Qatar"),
      Country(iso2: "RE", flag: "🇷🇪", nameEn: "Réunion", nameRu: "Реюньон", nameUz: "Reyunion"),
      Country(iso2: "RO", flag: "🇷🇴", nameEn: "Romania", nameRu: "Румыния", nameUz: "Ruminiya"),
      Country(iso2: "RW", flag: "🇷🇼", nameEn: "Rwanda", nameRu: "Руанда", nameUz: "Ruanda"),
      Country(iso2: "BL", flag: "🇧🇱", nameEn: "Saint Barthélemy", nameRu: "Сен-Бартелеми", nameUz: "Sen-Bartelemi"),
      Country(iso2: "SH", flag: "🇸🇭", nameEn: "Saint Helena", nameRu: "Остров Святой Елены", nameUz: "Avliyo Yelena oroli"),
      Country(iso2: "KN", flag: "🇰🇳", nameEn: "Saint Kitts and Nevis", nameRu: "Сент-Китс и Невис", nameUz: "Sent-Kits va Nevis"),
      Country(iso2: "LC", flag: "🇱🇨", nameEn: "Saint Lucia", nameRu: "Сент-Люсия", nameUz: "Sent-Lyusiya"),
      Country(iso2: "MF", flag: "🇲🇫", nameEn: "Saint Martin", nameRu: "Сен-Мартен", nameUz: "Sen-Marten"),
      Country(iso2: "PM", flag: "🇵🇲", nameEn: "Saint Pierre and Miquelon", nameRu: "Сен-Пьер и Микелон", nameUz: "Sen-Pyer va Mikelon"),
      Country(iso2: "VC", flag: "🇻🇨", nameEn: "Saint Vincent and the Grenadines", nameRu: "Сент-Винсент и Гренадины", nameUz: "Sent-Vinsent va Grenadinlar"),
      Country(iso2: "WS", flag: "🇼🇸", nameEn: "Samoa", nameRu: "Самоа", nameUz: "Samoa"),
      Country(iso2: "SM", flag: "🇸🇲", nameEn: "San Marino", nameRu: "Сан-Марино", nameUz: "San-Marino"),
      Country(iso2: "ST", flag: "🇸🇹", nameEn: "São Tomé and Príncipe", nameRu: "Сан-Томе и Принсипи", nameUz: "San-Tome va Prinsipi"),
      Country(iso2: "SA", flag: "🇸🇦", nameEn: "Saudi Arabia", nameRu: "Саудовская Аравия", nameUz: "Saudiya Arabistoni"),
      Country(iso2: "SN", flag: "🇸🇳", nameEn: "Senegal", nameRu: "Сенегал", nameUz: "Senegal"),
      Country(iso2: "RS", flag: "🇷🇸", nameEn: "Serbia", nameRu: "Сербия", nameUz: "Serbiya"),
      Country(iso2: "SC", flag: "🇸🇨", nameEn: "Seychelles", nameRu: "Сейшелы", nameUz: "Seyshel orollari"),
      Country(iso2: "SL", flag: "🇸🇱", nameEn: "Sierra Leone", nameRu: "Сьерра-Леоне", nameUz: "Syerra-Leone"),
      Country(iso2: "SG", flag: "🇸🇬", nameEn: "Singapore", nameRu: "Сингапур", nameUz: "Singapur"),
      Country(iso2: "SX", flag: "🇸🇽", nameEn: "Sint Maarten", nameRu: "Синт-Мартен", nameUz: "Sint-Marten"),
      Country(iso2: "SK", flag: "🇸🇰", nameEn: "Slovakia", nameRu: "Словакия", nameUz: "Slovakiya"),
      Country(iso2: "SI", flag: "🇸🇮", nameEn: "Slovenia", nameRu: "Словения", nameUz: "Sloveniya"),
      Country(iso2: "SB", flag: "🇸🇧", nameEn: "Solomon Islands", nameRu: "Соломоновы Острова", nameUz: "Solomon orollari"),
      Country(iso2: "SO", flag: "🇸🇴", nameEn: "Somalia", nameRu: "Сомали", nameUz: "Somali"),
      Country(iso2: "ZA", flag: "🇿🇦", nameEn: "South Africa", nameRu: "ЮАР", nameUz: "Janubiy Afrika"),
      Country(iso2: "GS", flag: "🇬🇸", nameEn: "South Georgia and the South Sandwich Islands", nameRu: "Южная Георгия и Южные Сандвичевы острова", nameUz: "Janubiy Georgiya va Janubiy Sendvich orollari"),
      Country(iso2: "SS", flag: "🇸🇸", nameEn: "South Sudan", nameRu: "Южный Судан", nameUz: "Janubiy Sudan"),
      Country(iso2: "ES", flag: "🇪🇸", nameEn: "Spain", nameRu: "Испания", nameUz: "Ispaniya"),
      Country(iso2: "LK", flag: "🇱🇰", nameEn: "Sri Lanka", nameRu: "Шри-Ланка", nameUz: "Shri-Lanka"),
      Country(iso2: "SD", flag: "🇸🇩", nameEn: "Sudan", nameRu: "Судан", nameUz: "Sudan"),
      Country(iso2: "SR", flag: "🇸🇷", nameEn: "Suriname", nameRu: "Суринам", nameUz: "Surinam"),
      Country(iso2: "SJ", flag: "🇸🇯", nameEn: "Svalbard and Jan Mayen", nameRu: "Шпицберген и Ян-Майен", nameUz: "Shpitsbergen va Yan-Mayen"),
      Country(iso2: "SE", flag: "🇸🇪", nameEn: "Sweden", nameRu: "Швеция", nameUz: "Shvetsiya"),
      Country(iso2: "CH", flag: "🇨🇭", nameEn: "Switzerland", nameRu: "Швейцария", nameUz: "Shveytsariya"),
      Country(iso2: "SY", flag: "🇸🇾", nameEn: "Syria", nameRu: "Сирия", nameUz: "Suriya"),
      Country(iso2: "TW", flag: "🇹🇼", nameEn: "Taiwan", nameRu: "Тайвань", nameUz: "Tayvan"),
      Country(iso2: "TZ", flag: "🇹🇿", nameEn: "Tanzania", nameRu: "Танзания", nameUz: "Tanzaniya"),
      Country(iso2: "TH", flag: "🇹🇭", nameEn: "Thailand", nameRu: "Таиланд", nameUz: "Tailand"),
      Country(iso2: "TL", flag: "🇹🇱", nameEn: "Timor-Leste", nameRu: "Восточный Тимор", nameUz: "Sharqiy Timor"),
      Country(iso2: "TG", flag: "🇹🇬", nameEn: "Togo", nameRu: "Того", nameUz: "Togo"),
      Country(iso2: "TK", flag: "🇹🇰", nameEn: "Tokelau", nameRu: "Токелау", nameUz: "Tokelau"),
      Country(iso2: "TO", flag: "🇹🇴", nameEn: "Tonga", nameRu: "Тонга", nameUz: "Tonga"),
      Country(iso2: "TT", flag: "🇹🇹", nameEn: "Trinidad and Tobago", nameRu: "Тринидад и Тобаго", nameUz: "Trinidad va Tobago"),
      Country(iso2: "TN", flag: "🇹🇳", nameEn: "Tunisia", nameRu: "Тунис", nameUz: "Tunis"),
      Country(iso2: "TC", flag: "🇹🇨", nameEn: "Turks and Caicos Islands", nameRu: "Острова Теркс и Кайкос", nameUz: "Terks va Kaykos orollari"),
      Country(iso2: "TV", flag: "🇹🇻", nameEn: "Tuvalu", nameRu: "Тувалу", nameUz: "Tuvalu"),
      Country(iso2: "UG", flag: "🇺🇬", nameEn: "Uganda", nameRu: "Уганда", nameUz: "Uganda"),
      Country(iso2: "AE", flag: "🇦🇪", nameEn: "United Arab Emirates", nameRu: "ОАЭ", nameUz: "Birlashgan Arab Amirliklari"),
      Country(iso2: "GB", flag: "🇬🇧", nameEn: "United Kingdom", nameRu: "Великобритания", nameUz: "Birlashgan Qirollik"),
      Country(iso2: "US", flag: "🇺🇸", nameEn: "United States", nameRu: "США", nameUz: "AQSh"),
      Country(iso2: "UM", flag: "🇺🇲", nameEn: "U.S. Minor Outlying Islands", nameRu: "Внешние малые острова США", nameUz: "AQSH tashqi kichik orollari"),
      Country(iso2: "UY", flag: "🇺🇾", nameEn: "Uruguay", nameRu: "Уругвай", nameUz: "Urugvay"),
      Country(iso2: "VU", flag: "🇻🇺", nameEn: "Vanuatu", nameRu: "Вануату", nameUz: "Vanuatu"),
      Country(iso2: "VE", flag: "🇻🇪", nameEn: "Venezuela", nameRu: "Венесуэла", nameUz: "Venesuela"),
      Country(iso2: "VN", flag: "🇻🇳", nameEn: "Vietnam", nameRu: "Вьетнам", nameUz: "Vetnam"),
      Country(iso2: "VG", flag: "🇻🇬", nameEn: "British Virgin Islands", nameRu: "Британские Виргинские острова", nameUz: "Britaniya Virgin orollari"),
      Country(iso2: "VI", flag: "🇻🇮", nameEn: "U.S. Virgin Islands", nameRu: "Виргинские острова США", nameUz: "AQSH Virgin orollari"),
      Country(iso2: "WF", flag: "🇼🇫", nameEn: "Wallis and Futuna", nameRu: "Уоллис и Футуна", nameUz: "Uollis va Futuna"),
      Country(iso2: "EH", flag: "🇪🇭", nameEn: "Western Sahara", nameRu: "Западная Сахара", nameUz: "G'arbiy Sahara"),
      Country(iso2: "YE", flag: "🇾🇪", nameEn: "Yemen", nameRu: "Йемен", nameUz: "Yaman"),
      Country(iso2: "ZM", flag: "🇿🇲", nameEn: "Zambia", nameRu: "Замбия", nameUz: "Zambiya"),
      Country(iso2: "ZW", flag: "🇿🇼", nameEn: "Zimbabwe", nameRu: "Зимбабве", nameUz: "Zimbabve"),
    ];
  }
}
