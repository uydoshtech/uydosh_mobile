/// Integer display formatting (non-localized grouping only).
class IntFormatUtils {
  IntFormatUtils._();

  /// Groups digits with `.` as the thousands separator (e.g. 1_000_000 → 1.000.000).
  static String withDotThousands(int value) {
    final negative = value < 0;
    final digits = negative ? (-value).toString() : value.toString();
    final buffer = StringBuffer();
    if (negative) {
      buffer.write("-");
    }
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(".");
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
