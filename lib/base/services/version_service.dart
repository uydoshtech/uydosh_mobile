import 'package:flutter/services.dart';
import 'package:uy_dosh/base/constants/app_version.dart';

class VersionService {
  static const String _versionKey = 'version';
  static String? _cachedVersion;

  /// Get the current app version from pubspec.yaml
  static Future<String> getVersion() async {
    if (_cachedVersion != null) {
      return _cachedVersion!;
    }

    try {
      // Read pubspec.yaml file
      final String pubspecContent = await rootBundle.loadString('pubspec.yaml');

      // Extract version using regex
      final RegExp versionRegex = RegExp(
        r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)$',
        multiLine: true,
      );
      final Match? match = versionRegex.firstMatch(pubspecContent);

      if (match != null) {
        final String semanticVersion = match.group(1)!;
        final String buildNumber = match.group(2)!;
        _cachedVersion = '$semanticVersion+$buildNumber';
        return _cachedVersion!;
      }

      // Fallback to a generated version if parsing fails
      _cachedVersion = AppVersion.fullVersion;
      return _cachedVersion!;
    } catch (e) {
      // Fallback to a generated version if reading fails
      _cachedVersion = AppVersion.fullVersion;
      return _cachedVersion!;
    }
  }

  /// Get only the semantic version (without build number)
  static Future<String> getSemanticVersion() async {
    final String fullVersion = await getVersion();
    return fullVersion.split('+')[0];
  }

  /// Get only the build number
  static Future<String> getBuildNumber() async {
    final String fullVersion = await getVersion();
    return fullVersion.split('+')[1];
  }

  /// Get formatted version string for display
  static Future<String> getDisplayVersion() async {
    final String semanticVersion = await getSemanticVersion();
    return 'Version $semanticVersion';
  }

  /// Clear cached version (useful for testing or when version changes)
  static void clearCache() {
    _cachedVersion = null;
  }
}
