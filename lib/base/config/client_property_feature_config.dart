import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings] (`propertyNavEnabled`).
///
/// Defaults to off so the Property tab stays hidden unless an admin explicitly
/// enables it (and clients successfully load that setting).
abstract final class ClientPropertyFeatureConfig {
  static final ValueNotifier<bool> propertyFeatureEnabled =
      ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final enabled = await service.getPropertyNavEnabled();
      propertyFeatureEnabled.value = enabled;
    } catch (e, st) {
      logger.d(
        "Property nav enabled: fetch failed, defaulting to disabled: $e\n$st",
      );
      propertyFeatureEnabled.value = false;
    }
  }

  static void applyEnabled({required bool enabled}) {
    propertyFeatureEnabled.value = enabled;
  }
}
