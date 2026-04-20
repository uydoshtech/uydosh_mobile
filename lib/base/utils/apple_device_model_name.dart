/// Utilities to present Apple hardware identifiers (e.g. `iPhone16,2`)
/// as user-friendly marketing names where possible.
///
/// iOS reports "machine" identifiers via `utsname.machine`. These numbers
/// are not the same as marketing names, which can look like "one generation
/// higher" to admins. We keep sending the raw identifier to backend (useful
/// for debugging), but format it for display in the admin UI.
class AppleDeviceModelName {
  AppleDeviceModelName._();

  static final RegExp _iPhoneMachine = RegExp(r"^iPhone(\d+),(\d+)$");

  /// Converts `utsname.machine` like `iPhone16,2` to a friendly name.
  /// Falls back to the original value when unknown.
  static String format(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return raw;

    // Mapping from Apple hardware identifiers (`utsname.machine`) to
    // marketing names. Source provided by project team.
    const known = <String, String>{
      "iPhone1,1": "iPhone (Original)",
      "iPhone1,2": "iPhone 3G",
      "iPhone2,1": "iPhone 3GS",

      "iPhone3,1": "iPhone 4",
      "iPhone3,2": "iPhone 4",
      "iPhone3,3": "iPhone 4 (CDMA)",

      "iPhone4,1": "iPhone 4s",

      "iPhone5,1": "iPhone 5",
      "iPhone5,2": "iPhone 5",
      "iPhone5,3": "iPhone 5c",
      "iPhone5,4": "iPhone 5c",

      "iPhone6,1": "iPhone 5s",
      "iPhone6,2": "iPhone 5s",

      "iPhone7,1": "iPhone 6 Plus",
      "iPhone7,2": "iPhone 6",

      "iPhone8,1": "iPhone 6s",
      "iPhone8,2": "iPhone 6s Plus",
      "iPhone8,4": "iPhone SE (1st gen)",

      "iPhone9,1": "iPhone 7",
      "iPhone9,2": "iPhone 7 Plus",
      "iPhone9,3": "iPhone 7",
      "iPhone9,4": "iPhone 7 Plus",

      "iPhone10,1": "iPhone 8",
      "iPhone10,2": "iPhone 8 Plus",
      "iPhone10,3": "iPhone X",
      "iPhone10,4": "iPhone 8",
      "iPhone10,5": "iPhone 8 Plus",
      "iPhone10,6": "iPhone X",

      "iPhone11,2": "iPhone XS",
      "iPhone11,4": "iPhone XS Max",
      "iPhone11,6": "iPhone XS Max",
      "iPhone11,8": "iPhone XR",

      "iPhone12,1": "iPhone 11",
      "iPhone12,3": "iPhone 11 Pro",
      "iPhone12,5": "iPhone 11 Pro Max",
      "iPhone12,8": "iPhone SE (2nd gen)",

      "iPhone13,1": "iPhone 12 mini",
      "iPhone13,2": "iPhone 12",
      "iPhone13,3": "iPhone 12 Pro",
      "iPhone13,4": "iPhone 12 Pro Max",

      "iPhone14,2": "iPhone 13 Pro",
      "iPhone14,3": "iPhone 13 Pro Max",
      "iPhone14,4": "iPhone 13 mini",
      "iPhone14,5": "iPhone 13",
      "iPhone14,6": "iPhone SE (3rd gen)",
      "iPhone14,7": "iPhone 14",
      "iPhone14,8": "iPhone 14 Plus",

      "iPhone15,2": "iPhone 14 Pro",
      "iPhone15,3": "iPhone 14 Pro Max",
      "iPhone15,4": "iPhone 15",
      "iPhone15,5": "iPhone 15 Plus",

      "iPhone16,1": "iPhone 15 Pro",
      "iPhone16,2": "iPhone 15 Pro Max",

      "iPhone17,1": "iPhone 16 Pro",
      "iPhone17,2": "iPhone 16 Pro Max",
      "iPhone17,3": "iPhone 16",
      "iPhone17,4": "iPhone 16 Plus",
    };
    final mapped = known[s];
    if (mapped != null) return mapped;

    // Heuristic fallback: for modern iPhones the first number is typically
    // marketing generation + 1 (e.g. iPhone16,* ≈ iPhone 15).
    final match = _iPhoneMachine.firstMatch(s);
    if (match != null) {
      final major = int.tryParse(match.group(1) ?? "");
      if (major != null && major >= 14) {
        return "iPhone ${major - 1}";
      }
    }

    return raw;
  }
}

