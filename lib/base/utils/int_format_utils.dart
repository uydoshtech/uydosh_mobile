import "package:flutter/services.dart";

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

  /// Parses an amount the user may have typed with `.` thousands grouping.
  static int? parseAmountInput(String raw) {
    final d = raw.replaceAll(".", "").trim();
    if (d.isEmpty) return null;
    return int.tryParse(d);
  }
}

/// Digits-only editing with live `.` thousand grouping (common for UZS / large amounts).
class DotThousandsDigitsInputFormatter extends TextInputFormatter {
  DotThousandsDigitsInputFormatter({this.maxDigits = 14});

  /// Upper bound on digit count so parsing stays within [int] range for the client.
  final int maxDigits;

  static final RegExp _nonDigit = RegExp(r"\D");

  static int _digitCountBefore(String text, int offset) {
    final end = offset.clamp(0, text.length);
    var n = 0;
    for (var i = 0; i < end; i++) {
      final u = text.codeUnitAt(i);
      if (u >= 0x30 && u <= 0x39) {
        n++;
      }
    }
    return n;
  }

  static int _offsetForDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) {
      return 0;
    }
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      final u = formatted.codeUnitAt(i);
      if (u >= 0x30 && u <= 0x39) {
        seen++;
        if (seen >= digitIndex) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(composing: TextRange.empty);
    }

    var newDigits = newValue.text.replaceAll(_nonDigit, "");
    if (newDigits.length > maxDigits) {
      newDigits = newDigits.substring(0, maxDigits);
    }

    if (newDigits.isEmpty) {
      return const TextEditingValue(
        text: "",
        selection: TextSelection.collapsed(offset: 0),
        composing: TextRange.empty,
      );
    }

    final n = int.tryParse(newDigits);
    if (n == null) {
      return oldValue;
    }

    final newText = IntFormatUtils.withDotThousands(n);

    final targetDigitCount = _digitCountBefore(newValue.text, newValue.selection.end);
    var newOffset = _offsetForDigitIndex(newText, targetDigitCount);
    final totalDigits =
        newText.replaceAll(_nonDigit, "").length;
    if (targetDigitCount >= totalDigits && totalDigits > 0) {
      newOffset = newText.length;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, newText.length)),
      composing: TextRange.empty,
    );
  }
}
