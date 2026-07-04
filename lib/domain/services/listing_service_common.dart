import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/domain/models/listing.dart";

/// Empty request for endpoints that don't require a request body.
class EmptyListingRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

class DescriptionTranslationRequest implements IJsonEncodable {
  DescriptionTranslationRequest({
    required this.targetLanguageCode,
    required this.translatedText,
  });

  final String targetLanguageCode;
  final String translatedText;

  @override
  Map<String, dynamic> toJson() => {
        "targetLanguageCode": targetLanguageCode,
        "translatedText": translatedText,
      };
}

/// Request for photo upload endpoints.
class PhotoUploadRequest implements IJsonEncodable {
  PhotoUploadRequest({required this.imageData, required this.isPrimary});

  final String imageData;
  final bool isPrimary;

  @override
  Map<String, dynamic> toJson() => {
        "imageData": imageData,
        "isPrimary": isPrimary,
      };
}

/// PATCH `/listings/:id/room-scan-metrics` body wrapper.
class RoomScanMetricsPatchRequest implements IJsonEncodable {
  RoomScanMetricsPatchRequest({required this.metrics});

  final RoomScanMetrics metrics;

  @override
  Map<String, dynamic> toJson() => {
        "room_scan_metrics": metrics.toJson(),
      };
}

/// Manual compass correction for an existing room scan (-180..180, or null to reset).
class RoomScanNorthCorrectionPatchRequest implements IJsonEncodable {
  RoomScanNorthCorrectionPatchRequest({required this.northCorrectionDeg});

  final double? northCorrectionDeg;

  @override
  Map<String, dynamic> toJson() => {
        "north_correction_deg": northCorrectionDeg,
      };
}

/// Footprint derived from LiDAR USDZ (meters); sent with [RoomScanUploadRequest].
class RoomScanMetrics implements IJsonEncodable {
  RoomScanMetrics({
    required this.floorLongM,
    required this.floorShortM,
    required this.heightM,
    required this.floorAreaM2,
    this.worldPlusXBearingDeg,
  });

  final double floorLongM;
  final double floorShortM;
  final double heightM;
  final double floorAreaM2;
  final double? worldPlusXBearingDeg;

  @override
  Map<String, dynamic> toJson() => {
        "floor_long_m": floorLongM,
        "floor_short_m": floorShortM,
        "height_m": heightM,
        "floor_area_m2": floorAreaM2,
        if (worldPlusXBearingDeg != null)
          "world_plus_x_bearing_deg": worldPlusXBearingDeg,
      };
}

/// RoomPlan USDZ upload (stored server-side; URL saved as listing.point_cloud_url).
class RoomScanUploadRequest implements IJsonEncodable {
  RoomScanUploadRequest({required this.usdzData, this.roomScanMetrics});

  final String usdzData;
  final RoomScanMetrics? roomScanMetrics;

  @override
  Map<String, dynamic> toJson() => {
        "usdzData": usdzData,
        if (roomScanMetrics != null) "room_scan_metrics": roomScanMetrics!.toJson(),
      };
}

/// Reorder existing listing photos. `photoIds` are in the desired display
/// order (index 0 = new primary, index 0-based = new photo_order - 1).
class PhotoReorderRequest implements IJsonEncodable {
  PhotoReorderRequest({required this.photoIds});

  final List<int> photoIds;

  @override
  Map<String, dynamic> toJson() => {"photoIds": photoIds};
}

/// Outcome of `PATCH /listings/:id/renew`. Distinguishes a successful bump
/// (carries the refreshed [listing]) from a still-on-cooldown response
/// (carries [nextRenewalAt] so callers can sync their local countdown) and
/// any other failure.
class RenewListingResult {
  const RenewListingResult._({
    required this.status,
    this.listing,
    this.nextRenewalAt,
  });

  factory RenewListingResult.renewed(Listing listing) =>
      RenewListingResult._(status: RenewListingStatus.renewed, listing: listing);

  factory RenewListingResult.cooldown(String? nextRenewalAt) =>
      RenewListingResult._(
        status: RenewListingStatus.cooldown,
        nextRenewalAt: nextRenewalAt,
      );

  factory RenewListingResult.failure() =>
      const RenewListingResult._(status: RenewListingStatus.failure);

  final RenewListingStatus status;

  /// Populated only when [status] is [RenewListingStatus.renewed].
  final Listing? listing;

  /// Populated only when [status] is [RenewListingStatus.cooldown] (may still
  /// be null if the server didn't return one).
  final String? nextRenewalAt;

  bool get isSuccess => status == RenewListingStatus.renewed;
  bool get isCooldown => status == RenewListingStatus.cooldown;
}

enum RenewListingStatus { renewed, cooldown, failure }
