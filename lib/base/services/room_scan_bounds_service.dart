import "package:flutter/services.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

/// Reads LiDAR USDZ axis-aligned bounds on iOS (SceneKit); matches the 3D viewer convention.
class RoomScanBoundsService {
  RoomScanBoundsService._();

  static const MethodChannel _channel = MethodChannel("uydosh/room_scan_bounds");

  static Future<RoomScanMetrics?> computeFromUsdPath(String path) async {
    if (!isIOSDevice) return null;
    if (path.isEmpty) return null;
    const delays = <Duration>[
      Duration.zero,
      const Duration(milliseconds: 350),
      const Duration(milliseconds: 800),
    ];
    for (final delay in delays) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      final metrics = await _computeOnce(path);
      if (metrics != null) {
        return metrics;
      }
    }
    return null;
  }

  static Future<RoomScanMetrics?> _computeOnce(String path) async {
    try {
      final raw = await _channel.invokeMethod<Object?>(
        "computeFromUsdPath",
        <String, dynamic>{"path": path},
      );
      if (raw is! Map) return null;
      final floorLong = (raw["floor_long_m"] as num?)?.toDouble();
      final floorShort = (raw["floor_short_m"] as num?)?.toDouble();
      final height = (raw["height_m"] as num?)?.toDouble();
      final area = (raw["floor_area_m2"] as num?)?.toDouble();
      if (floorLong == null ||
          floorShort == null ||
          height == null ||
          area == null) {
        return null;
      }
      final bearing = (raw["world_plus_x_bearing_deg"] as num?)?.toDouble();
      return RoomScanMetrics(
        floorLongM: floorLong,
        floorShortM: floorShort,
        heightM: height,
        floorAreaM2: area,
        worldPlusXBearingDeg: bearing,
      );
    } on Object {
      return null;
    }
  }
}
