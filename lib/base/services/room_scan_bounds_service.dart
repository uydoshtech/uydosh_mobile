import "package:room_scan_kit/room_scan_kit.dart" as kit;
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

/// Host wrapper around [kit.RoomScanBounds]; maps into domain [RoomScanMetrics].
class RoomScanBoundsService {
  RoomScanBoundsService._();

  static Future<RoomScanMetrics?> computeFromUsdPath(String path) async {
    if (!isIOSDevice) return null;
    final metrics = await kit.RoomScanBounds.computeFromUsdPath(path);
    if (metrics == null) return null;
    return RoomScanMetrics(
      floorLongM: metrics.floorLongM,
      floorShortM: metrics.floorShortM,
      heightM: metrics.heightM,
      floorAreaM2: metrics.floorAreaM2,
      worldPlusXBearingDeg: metrics.worldPlusXBearingDeg,
    );
  }
}
