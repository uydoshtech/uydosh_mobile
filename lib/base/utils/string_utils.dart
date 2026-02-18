/// String utilities (non-localization).
class StringUtils {
  StringUtils._();

  /// Extract initials from a person's name.
  /// Returns 2 letters for names with spaces (first and last name)
  /// Returns first 2 letters for single names
  /// Returns empty string if name is null or empty
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
