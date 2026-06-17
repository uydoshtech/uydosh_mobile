import "package:uy_dosh/base/services/room_scan_bounds_service.dart";
import "package:uy_dosh/base/services/room_usdz_viewer_service.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

extension ListingDetailRoomScanMetrics on ListingDetail {
  bool get roomScanMetricsMissing =>
      roomScanFloorLongM == null ||
      roomScanFloorShortM == null ||
      roomScanHeightM == null ||
      roomScanFloorAreaM2 == null;

  ListingDetail withRoomScanMetrics(RoomScanMetrics metrics) {
    return copyWith(
      roomScanFloorLongM: metrics.floorLongM,
      roomScanFloorShortM: metrics.floorShortM,
      roomScanHeightM: metrics.heightM,
      roomScanFloorAreaM2: metrics.floorAreaM2,
      roomScanWorldPlusXBearingDeg:
          metrics.worldPlusXBearingDeg ?? roomScanWorldPlusXBearingDeg,
    );
  }
}

/// Computes room footprint from a remote USDZ when DB columns are still null.
class RoomScanMetricsHydrationService {
  RoomScanMetricsHydrationService._();

  static Future<RoomScanMetrics?> computeFromRemoteUrl({
    required String absoluteUrl,
    required int listingId,
  }) async {
    if (!isIOSDevice) return null;
    final file = await RoomUsdzViewerService.downloadUsdToCache(
      absoluteUrl,
      listingId: listingId,
    );
    if (file == null) return null;
    return RoomScanBoundsService.computeFromUsdPath(file.path);
  }
}
