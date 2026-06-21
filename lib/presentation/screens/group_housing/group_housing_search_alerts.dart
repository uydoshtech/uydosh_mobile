import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

abstract final class GroupHousingSearchAlerts {
  static Future<void> ensureForGroupListing(ListingDetail detail) async {
    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: detail.price,
      listingTypeCode: ListingTypeCodes.groupForming,
      minPrice: detail.minPrice,
      maxPrice: detail.maxPrice,
    );
    final groupSize =
        detail.groupContext?.groupSizeTarget ?? detail.groupSizeTarget;
    final totalMaxPrice =
        groupSize != null ? bounds.max * groupSize : bounds.max;
    if (totalMaxPrice <= 0) return;

    try {
      final error =
          await getIt<ISearchAlertService>().createAlertForCurrentSearch(
        listingTypeId: ListingTypeIds.roommateNeeded,
        minPrice: (bounds.min > 0 ? bounds.min : 0).toDouble(),
        maxPrice: totalMaxPrice.toDouble(),
        privateRoomOnly: false,
        withPhotoOnly: false,
        locationId: detail.locationId,
        subwayStationId: detail.subwayStationId,
        subwayLineId: detail.subwayLineId,
        gender: detail.gender,
      );
      if (error != null &&
          error != SearchAlertService.alreadyExistsErrorToken) {
        logger.d("GroupHousingSearchAlerts: create failed: $error");
      }
    } catch (e) {
      logger.d("GroupHousingSearchAlerts: create failed: $e");
    }
  }
}
