/// Shared currency affordances for amount fields (gig flows).
class CurrencyDisplayUtils {
  CurrencyDisplayUtils._();

  /// Regional flag emoji for common posting currencies (matches gig publish UX).
  static String flagEmoji(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case "USD":
        return "🇺🇸";
      case "RUB":
        return "🇷🇺";
      case "EUR":
        return "🇪🇺";
      case "UZS":
      default:
        return "🇺🇿";
    }
  }

  /// Spinner / stepper delta for whole-currency amount fields.
  static int amountNudgeStep(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case "UZS":
        return 1000;
      case "USD":
        return 1;
      default:
        return 1;
    }
  }

  /// ISO 4217 code only (no flag). Use for [ListingPaymentsOutlineBadge] and tight chips.
  ///
  /// Strips a leading flag emoji (e.g. when the API or stored value mirrors
  /// [codeWithFlag]: `"🇺🇿 UZS"`).
  static String isoCode(String currencyCode) {
    final trimmed = currencyCode.trim();
    if (trimmed.isEmpty) return "UZS";

    for (final raw in trimmed.split(RegExp(r"\s+"))) {
      final part = raw.trim();
      if (part.length == 3 && RegExp(r"^[A-Za-z]{3}$").hasMatch(part)) {
        return part.toUpperCase();
      }
    }

    final lettersOnly = trimmed.replaceAll(RegExp(r"[^A-Za-z]"), "");
    if (lettersOnly.length == 3) {
      return lettersOnly.toUpperCase();
    }
    if (lettersOnly.length > 3) {
      return lettersOnly.substring(lettersOnly.length - 3).toUpperCase();
    }

    return trimmed.toUpperCase();
  }

  /// ISO code with regional flag for read-only lines (`{currency}` in L10n).
  static String codeWithFlag(String currencyCode) {
    final code =
        currencyCode.trim().isEmpty ? "UZS" : currencyCode.trim();
    return "${flagEmoji(code)} $code";
  }
}
