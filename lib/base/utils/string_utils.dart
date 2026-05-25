/// String utilities (non-localization).
class StringUtils {
  StringUtils._();

  /// Normalizes CRLF and collapses runs of **three or more** newlines to a
  /// single paragraph break (two newlines). Pairs of newlines are kept so
  /// intentional blank lines between paragraphs stay readable.
  static String collapseExcessiveNewlines(String s) {
    return s.replaceAll("\r\n", "\n").replaceAll(RegExp(r"\n{3,}"), "\n\n");
  }

  /// Extract initials from a person's name.
  /// Returns 2 letters for names with spaces (first and last name)
  /// Returns first 2 letters for single names
  /// Returns empty string if name is null or empty
  /// Splits a full name into a first line and optional second line.
  /// Uses the first whitespace as the boundary (e.g. "Artur Musin" → "Artur", "Musin").
  static (String firstName, String? lastName) splitFullName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ("", null);
    }

    final trimmed = name.trim();
    final spaceIndex = trimmed.indexOf(" ");
    if (spaceIndex < 0) {
      return (trimmed, null);
    }

    final lastName = trimmed.substring(spaceIndex + 1).trim();
    return (trimmed.substring(0, spaceIndex), lastName.isEmpty ? null : lastName);
  }

  static String extractInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return "";
    }

    final nameParts = name.trim().split(" ");

    if (nameParts.length >= 2) {
      return "${nameParts[0][0].toUpperCase()}${nameParts[1][0].toUpperCase()}";
    } else {
      final singleName = nameParts[0];
      if (singleName.length >= 2) {
        return singleName.substring(0, 2).toUpperCase();
      } else {
        return singleName[0].toUpperCase();
      }
    }
  }
}
