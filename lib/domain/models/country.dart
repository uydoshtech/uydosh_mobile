/// Lightweight immutable country descriptor used by the country picker.
///
/// This is intentionally not a Freezed/JSON model — it's a static reference
/// list shipped with the app (see `countries_catalog.dart`). If the backend
/// ever starts returning countries, convert this into a Freezed model with
/// `fromJson` like [Region].
class Country {
  const Country({
    required this.iso2,
    required this.flag,
    required this.nameEn,
    required this.nameRu,
    required this.nameUz,
  });

  /// ISO 3166-1 alpha-2 code (e.g. "UZ", "RU", "US"). Uppercase.
  final String iso2;

  /// Flag emoji — two Regional Indicator Symbols (e.g. "🇺🇿").
  final String flag;

  final String nameEn;
  final String nameRu;
  final String nameUz;

  /// Returns the localized country name for the given language code.
  /// Falls back to English when the code is unknown.
  String getLocalizedName(String language) {
    switch (language) {
      case "ru":
        return nameRu;
      case "uz":
        return nameUz;
      case "en":
      default:
        return nameEn;
    }
  }
}
