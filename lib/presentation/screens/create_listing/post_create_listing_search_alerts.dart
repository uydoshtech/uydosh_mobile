import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/search_alert_service.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

enum PostCreateListingSearchAlertSaveKind {
  created,
  alreadyExists,
  failed,
}

class PostCreateListingSearchAlertSaveResult {
  const PostCreateListingSearchAlertSaveResult._(this.kind, [this.error]);

  const PostCreateListingSearchAlertSaveResult.created()
      : this._(PostCreateListingSearchAlertSaveKind.created);

  const PostCreateListingSearchAlertSaveResult.alreadyExists()
      : this._(PostCreateListingSearchAlertSaveKind.alreadyExists);

  const PostCreateListingSearchAlertSaveResult.failed([String? error])
      : this._(PostCreateListingSearchAlertSaveKind.failed, error);

  final PostCreateListingSearchAlertSaveKind kind;
  final String? error;
}

class PostCreateListingSearchAlertSuggestion {
  const PostCreateListingSearchAlertSuggestion({
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoomOnly,
    required this.withPhotoOnly,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds,
    this.subwayLineId,
    this.gender,
  });

  final int listingTypeId;
  final double minPrice;
  final double maxPrice;
  final bool privateRoomOnly;
  final bool withPhotoOnly;
  final int? locationId;
  final int? subwayStationId;
  final List<int>? subwayStationIds;
  final int? subwayLineId;
  final int? gender;

  static PostCreateListingSearchAlertSuggestion? fromListing(
    ListingDetail detail,
  ) {
    final targetListingTypeId = switch (detail.listingTypeId) {
      ListingTypeIds.roomNeeded => ListingTypeIds.roommateNeeded,
      ListingTypeIds.roommateNeeded => ListingTypeIds.roomNeeded,
      _ => null,
    };
    if (targetListingTypeId == null) return null;

    final searchStationIds = detail.searchSubwayStations
        ?.map((station) => station.id)
        .where((id) => id > 0)
        .toSet()
        .toList();
    final multiStationIds =
        searchStationIds != null && searchStationIds.length > 1
            ? searchStationIds
            : null;
    final singleStationId = multiStationIds == null
        ? (searchStationIds != null && searchStationIds.isNotEmpty
            ? searchStationIds.first
            : _positiveOrNull(detail.subwayStationId))
        : null;
    final locationId = _positiveOrNull(detail.locationId) ??
        (detail.searchLocations != null && detail.searchLocations!.isNotEmpty
            ? _positiveOrNull(detail.searchLocations!.first.id)
            : null);
    final subwayLineId = _positiveOrNull(detail.subwayLineId) ??
        (detail.searchSubwayStations != null &&
                detail.searchSubwayStations!.isNotEmpty
            ? _positiveOrNull(detail.searchSubwayStations!.first.line)
            : null);

    final hasGeo = locationId != null ||
        singleStationId != null ||
        multiStationIds != null ||
        subwayLineId != null;
    if (!hasGeo) return null;

    final bounds = PriceRangeHelper.resolveListingDisplayBounds(
      storedPrice: detail.price,
      listingTypeCode: detail.listingType.code,
      minPrice: detail.minPrice,
      maxPrice: detail.maxPrice,
    );
    final minPrice = bounds.min > 0 ? bounds.min.toDouble() : 0.0;
    final maxPrice = bounds.max > 0 ? bounds.max.toDouble() : 1000.0;

    return PostCreateListingSearchAlertSuggestion(
      listingTypeId: targetListingTypeId,
      minPrice: minPrice,
      maxPrice: maxPrice >= minPrice ? maxPrice : minPrice,
      privateRoomOnly: detail.privateRoom == true,
      withPhotoOnly: false,
      locationId: locationId,
      subwayStationId: singleStationId,
      subwayStationIds: multiStationIds,
      subwayLineId: subwayLineId,
      gender: _positiveOrNull(detail.gender),
    );
  }

  static int? _positiveOrNull(int? value) =>
      value != null && value > 0 ? value : null;
}

abstract final class PostCreateListingSearchAlerts {
  static Future<PostCreateListingSearchAlertSaveResult> create(
    PostCreateListingSearchAlertSuggestion suggestion,
  ) async {
    final error =
        await getIt<ISearchAlertService>().createAlertForCurrentSearch(
      listingTypeId: suggestion.listingTypeId,
      minPrice: suggestion.minPrice,
      maxPrice: suggestion.maxPrice,
      privateRoomOnly: suggestion.privateRoomOnly,
      withPhotoOnly: suggestion.withPhotoOnly,
      locationId: suggestion.locationId,
      subwayStationId: suggestion.subwayStationId,
      subwayStationIds: suggestion.subwayStationIds,
      subwayLineId: suggestion.subwayLineId,
      gender: suggestion.gender,
    );

    if (error == null) {
      return const PostCreateListingSearchAlertSaveResult.created();
    }
    if (error == SearchAlertService.alreadyExistsErrorToken) {
      return const PostCreateListingSearchAlertSaveResult.alreadyExists();
    }
    return PostCreateListingSearchAlertSaveResult.failed(error);
  }
}
