import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from
/// [GET /app/settings/listing-description-dictation-meter-disabled]. When true,
/// the listing description dictation waveform + timer row is hidden (recording
/// still works via the mic button).
abstract final class ClientListingDictationMeterConfig {
  static final ValueNotifier<bool> dictationMeterDisabled = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final disabled = await service.getListingDescriptionDictationMeterDisabled();
      dictationMeterDisabled.value = disabled;
    } catch (e, st) {
      logger.d(
        "Dictation meter disabled: fetch failed, defaulting to enabled UI: $e\n$st",
      );
      dictationMeterDisabled.value = false;
    }
  }

  static void applyDisabled({required bool disabled}) {
    dictationMeterDisabled.value = disabled;
  }
}
