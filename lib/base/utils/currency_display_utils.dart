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

  /// ISO code only (no flag). Use for [ListingPaymentsOutlineBadge] and tight chips.
  static String isoCode(String currencyCode) {
    final c = currencyCode.trim();
    if (c.isEmpty) return "UZS";
    return c.toUpperCase();
  }

  /// ISO code with regional flag for read-only lines (`{currency}` in L10n).
  static String codeWithFlag(String currencyCode) {
    final code =
        currencyCode.trim().isEmpty ? "UZS" : currencyCode.trim();
    return "${flagEmoji(code)} $code";
  }
}
