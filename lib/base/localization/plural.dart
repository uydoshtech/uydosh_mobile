/// CLDR-style plural categories for the languages this app supports.
///
/// Returns one of: `one`, `few`, `many`, `other`. Russian uses all three
/// numeric categories (1 / 2–4 / 5+ with the usual teen exceptions);
/// English distinguishes `one` vs `other`; Uzbek has no numeric agreement.
///
/// Keep this dependency-free so it can be used from non-widget code (blocs,
/// services, etc.).
class Plural {
  Plural._();

  /// CLDR plural category for [count] in [language] ("ru", "en", "uz").
  static String category(int count, String language) {
    final n = count.abs();
    switch (language) {
      case "ru":
        final mod10 = n % 10;
        final mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return "one";
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
          return "few";
        }
        return "many";
      case "en":
        return n == 1 ? "one" : "other";
      case "uz":
      default:
        return "other";
    }
  }
}
