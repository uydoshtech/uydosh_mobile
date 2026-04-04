import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/gemini-listing-ui-hidden]. When
/// true, hides listing description translation controls and the AI improve
/// action on create/edit for all users.
abstract final class ClientGeminiListingUiConfig {
  static final ValueNotifier<bool> hideGeminiListingUi = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final hidden = await service.getGeminiListingUiHidden();
      hideGeminiListingUi.value = hidden;
    } catch (e, st) {
      logger.d("Gemini listing UI hidden: fetch failed, defaulting to visible: $e\n$st");
      hideGeminiListingUi.value = false;
    }
  }

  /// Updates UI after admin PATCH or a successful refetch.
  static void applyHidden({required bool hidden}) {
    hideGeminiListingUi.value = hidden;
  }
}
