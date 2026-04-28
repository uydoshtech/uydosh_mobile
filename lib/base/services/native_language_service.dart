import "package:flutter/services.dart";
import "package:uy_dosh/base/utils/ios_device.dart";

/// Syncs the in-app selected language to iOS so native UI (e.g. RoomPlan)
/// follows the same locale.
abstract final class NativeLanguageService {
  static const MethodChannel _channel = MethodChannel("uydosh/native_language");

  /// Sets iOS `AppleLanguages` so newly-presented native controllers pick up
  /// the desired localization.
  ///
  /// Note: iOS frameworks may still fall back to English if Apple doesn't ship
  /// translations for that UI in the target language.
  static Future<void> setPreferredLanguage(String languageCode) async {
    if (!isIOSDevice) return;
    try {
      await _channel.invokeMethod<void>("setPreferredLanguage", <String, dynamic>{
        "languageCode": languageCode,
      });
    } catch (_) {
      // Best-effort: do not fail app flow if iOS rejects the request.
    }
  }
}

