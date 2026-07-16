import "package:room_scan_kit/room_scan_kit.dart";
import "package:uy_dosh/base/utils/ios_device.dart";

/// Host wrapper around [NativeLanguage] from `room_scan_kit`.
abstract final class NativeLanguageService {
  /// Sets iOS `AppleLanguages` so newly-presented native controllers pick up
  /// the desired localization.
  ///
  /// Note: iOS frameworks may still fall back to English if Apple doesn't ship
  /// translations for that UI in the target language.
  static Future<void> setPreferredLanguage(String languageCode) async {
    if (!isIOSDevice) return;
    await NativeLanguage.setPreferredLanguage(languageCode);
  }
}
