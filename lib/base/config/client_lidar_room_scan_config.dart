import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/lidar-room-scan-disabled]. When
/// true, RoomPlan (LiDAR) capture UI is hidden and uploads are rejected.
abstract final class ClientLidarRoomScanConfig {
  static final ValueNotifier<bool> lidarRoomScanDisabled = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final disabled = await service.getLidarRoomScanDisabled();
      lidarRoomScanDisabled.value = disabled;
    } catch (e, st) {
      logger.d(
        "LiDAR room scan disabled: fetch failed, defaulting to enabled: $e\n$st",
      );
      lidarRoomScanDisabled.value = false;
    }
  }

  static void applyDisabled({required bool disabled}) {
    lidarRoomScanDisabled.value = disabled;
  }
}
