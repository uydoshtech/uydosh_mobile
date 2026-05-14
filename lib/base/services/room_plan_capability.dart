import "package:flutter_roomplan/flutter_roomplan.dart";

import "package:uy_dosh/base/utils/ios_device.dart";

/// RoomPlan / LiDAR is only available on some iOS devices ([FlutterRoomplan.isSupported]).
/// Cached for the lifetime of the isolate so list screens can hide the affordance on e.g. a
/// non‑LiDAR iPad without each caller awaiting a fresh native query.
abstract final class RoomPlanCapability {
  static final FlutterRoomplan _roomPlan = FlutterRoomplan();
  static Future<bool>? _future;

  static Future<bool> isSupportedOnDevice() {
    if (!isIOSDevice) return Future<bool>.value(false);
    return _future ??= _query();
  }

  static Future<bool> _query() async {
    try {
      return await _roomPlan.isSupported();
    } catch (_) {
      return false;
    }
  }
}
