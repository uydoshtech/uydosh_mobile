import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings] (`propertyNavEnabled`).
abstract final class ClientPropertyFeatureConfig {
  static final ValueNotifier<bool> propertyFeatureEnabled =
      ValueNotifier(true);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final enabled = await service.getPropertyNavEnabled();
      propertyFeatureEnabled.value = enabled;
    } catch (e, st) {
      logger.d(
        "Property nav enabled: fetch failed, defaulting to enabled: $e\n$st",
      );
      propertyFeatureEnabled.value = true;
    }
  }

  static void applyEnabled({required bool enabled}) {
    propertyFeatureEnabled.value = enabled;
  }
}
