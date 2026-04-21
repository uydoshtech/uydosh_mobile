class ScamTrigger {
  const ScamTrigger._();

  static bool matches(String text) {
    final t = text.toLowerCase();

    // Links, off-platform, OTP, deposits, payment keywords.
    // MVP: simple and cheap (fast regex checks).
    const patterns = <String>[
      r'https?://',
      r'\b(t\.me|telegram|whatsapp|wa\.me|instagram|иг|инст)\b',
      r'\b(otp|code|verification|verify|парол|код|смс|sms)\b',
      r'\b(deposit|prepay|advance|pay now|bank|card|iban|swift|crypto|wallet|usdt|ton)\b',

      // RU: nouns (payment/banking) + verbs (explicit "send/transfer money" asks)
      r'\b(предоплат|задаток|депозит|оплат|перевод|перевести|переведи|переведите|перечисли|отправь|скинь|кинь|карта|банк)\b',
      // RU: currency / amount patterns (e.g. "$200", "200$", "200 долларов", "200 usd")
      r'(\$+\s*\d+|\d+\s*\$)',
      r'\b\d+\s*(usd|usdt|eur|rub|sum|сум|сома|сўм|доллар(ов|а)?|евро|руб(лей|ля)?)\b',
      // RU: verb + amount even without currency (e.g. "скинь 100000", "переведи 5000")
      r'\b(переведи|переведите|перевести|скинь|кинь|отправь|перечисли)\b[\s\S]{0,40}\b\d{3,}\b',
      // RU: "to phone number/card" transfer prompts (e.g. "на номер", "по номеру", "на телефон")
      r'\b(на номер|по номеру|на телефон|по телефону|на карту|на счет|на сч[её]т)\b',
      // Generic phone-like number sequences (7-15 digits) often used in transfer scams.
      r'\b\d{7,15}\b',

      // UZ: common payment/transfer phrases (latin + cyrillic)
      r'\b(o\'tkaz|otkaz|o‘tkaz|o‘tkazing|otkazing|yubor|yuboring|to\'lov|to‘lov|oldindan|depozit|karta|bank|hisob)\b',
    ];

    for (final raw in patterns) {
      final re = RegExp(raw, caseSensitive: false);
      if (re.hasMatch(t)) return true;
    }
    return false;
  }
}

