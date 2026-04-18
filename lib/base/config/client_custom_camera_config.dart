import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/custom-camera-disabled]. When
/// true, clients skip the in-app [CustomCameraScreen] (watermark overlay) and
/// fall back to the native camera picker via `image_picker`.
abstract final class ClientCustomCameraConfig {
  static final ValueNotifier<bool> customCameraDisabled = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final disabled = await service.getCustomCameraDisabled();
      customCameraDisabled.value = disabled;
    } catch (e, st) {
      logger.d(
        "Custom camera disabled: fetch failed, defaulting to enabled: $e\n$st",
      );
      customCameraDisabled.value = false;
    }
  }

  static void applyDisabled({required bool disabled}) {
    customCameraDisabled.value = disabled;
  }
}
