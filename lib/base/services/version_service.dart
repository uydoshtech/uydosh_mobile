import "package:package_info_plus/package_info_plus.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_version.dart";

class VersionService {
  static String? _cachedVersion;

  /// Get the current app version.
  ///
  /// Prefer platform version (always correct for the built app).
  /// Fall back to parsing pubspec (debug/dev) and finally to generated constants.
  static Future<String> getVersion() async {
    if (_cachedVersion != null) {
      return _cachedVersion!;
    }

    try {
      final info = await PackageInfo.fromPlatform();
      // `version` == build name (x.y.z), `buildNumber` == build number (n)
      if (info.version.isNotEmpty && info.buildNumber.isNotEmpty) {
        _cachedVersion = "${info.version}+${info.buildNumber}";
        return _cachedVersion!;
      }
    } catch (_) {
      // Ignore and try pubspec parsing / fallback constants below.
    }

    try {
      // Read pubspec.yaml file
      final pubspecContent = await rootBundle.loadString("pubspec.yaml");

      // Extract version using regex
      final versionRegex = RegExp(
        r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)$",
        multiLine: true,
      );
      final Match? match = versionRegex.firstMatch(pubspecContent);

      if (match != null) {
        final semanticVersion = match.group(1)!;
        final buildNumber = match.group(2)!;
        _cachedVersion = "$semanticVersion+$buildNumber";
        return _cachedVersion!;
      }

      // Fallback to a generated version if parsing fails
      _cachedVersion = AppVersion.fullVersion;
      return _cachedVersion!;
    } catch (_) {
      // Fallback to a generated version if reading fails
      _cachedVersion = AppVersion.fullVersion;
      return _cachedVersion!;
    }
  }

  /// Get only the semantic version (without build number)
  static Future<String> getSemanticVersion() async {
    final fullVersion = await getVersion();
    return fullVersion.split("+")[0];
  }

  /// Get only the build number
  static Future<String> getBuildNumber() async {
    final fullVersion = await getVersion();
    return fullVersion.split("+")[1];
  }

  /// Get formatted version string for display
  static Future<String> getDisplayVersion() async {
    final semanticVersion = await getSemanticVersion();
    return "Version $semanticVersion";
  }

  /// Clear cached version (useful for testing or when version changes)
  static void clearCache() {
    _cachedVersion = null;
  }
}
