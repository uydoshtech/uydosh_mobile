import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/services.dart";

/// Keeps Yandex MapKit's native locale aligned with the in-app language.
///
/// MapKit defaults to the OS locale; [LanguageState] can differ (e.g. Russian UI
/// on an English system). Call [sync] after the resolved language is known.
///
/// **iOS:** Yandex MapKit allows `setLocale` only once per process (before any map
/// use). The Runner `AppDelegate` sets it at cold start from persisted language;
/// subsequent [sync] calls are acknowledged but do not change locale until restart.
abstract final class MapKitLocaleSyncService {
  static const MethodChannel _channel = MethodChannel("uydosh/mapkit_locale");

  static Future<void> sync(String languageCode) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>("setLocale", <String, dynamic>{
        "languageCode": languageCode,
      });
    } catch (_) {
      // Best-effort: do not block language changes if native layer rejects it.
    }
  }
}
