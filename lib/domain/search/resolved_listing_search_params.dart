import "package:flutter/foundation.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/search/listing_browse_constants.dart";
import "package:uy_dosh/domain/services/listing_service.dart";

/// Normalized listing search filters shared by the home feed, map, and header.
@immutable
class ResolvedListingSearchParams {
  const ResolvedListingSearchParams({
    this.listingTypeId,
    this.listingTypeIds,
    this.locationId,
    this.subwayStationId,
    this.subwayStationIds,
    this.subwayLineId,
    this.gender,
    this.minPrice,
    this.maxPrice,
    this.privateRoom,
    this.withPhoto,
    this.createdWithinDays = listingBrowseCreatedWithinDays,
  });

  final int? listingTypeId;
  final List<int>? listingTypeIds;
  final int? locationId;
  final int? subwayStationId;
  final List<int>? subwayStationIds;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;
  final int createdWithinDays;

  /// Build the same filter set the home feed uses from [SearchFiltersState].
  static ResolvedListingSearchParams fromSearchFiltersState(
    SearchFiltersState state, {
    int? explicitListingTypeId,
    List<int>? explicitListingTypeIds,
    int? explicitLocationId,
    int? explicitSubwayStationId,
    List<int>? explicitSubwayStationIds,
    int? explicitSubwayLineId,
    int? explicitGender,
    double? explicitMinPrice,
    double? explicitMaxPrice,
    bool? explicitPrivateRoom,
    bool? explicitWithPhoto,
    bool useExplicitFiltersOnly = false,
    bool includeSafeFallbacks = false,
    bool explicitNullFallsBackToState = false,
  }) {
    final fromExplicit = useExplicitFiltersOnly;

    final listingTypeId = fromExplicit
        ? (explicitNullFallsBackToState
            ? (explicitListingTypeId ?? state.searchListingTypeId)
            : explicitListingTypeId)
        : state.searchListingTypeId;

    final listingTypeIds =
        fromExplicit ? explicitListingTypeIds : state.searchListingTypeIds;

    final locationId = fromExplicit
        ? explicitLocationId
        : state.selectedLocationIndex;

    final subwayStationId = fromExplicit
        ? explicitSubwayStationId
        : state.selectedStationId;

    final subwayStationIds = fromExplicit
        ? explicitSubwayStationIds
        : state.searchSubwayStationIds;

    final stationIds = subwayStationIds ?? const <int>[];
    final hasStationFilter = stationIds.isNotEmpty ||
        (subwayStationId != null && subwayStationId > 0);

    final rawSubwayLineId =
        fromExplicit ? explicitSubwayLineId : state.selectedSubwayLine;
    final subwayLineId = hasStationFilter ? rawSubwayLineId : null;

    final gender =
        fromExplicit ? explicitGender : state.selectedGender;

    final minPrice = fromExplicit
        ? (includeSafeFallbacks
            ? (explicitMinPrice ?? 0.0)
            : explicitMinPrice)
        : state.minPrice;
    final maxPrice = fromExplicit
        ? (includeSafeFallbacks
            ? (explicitMaxPrice ?? 1000.0)
            : explicitMaxPrice)
        : state.maxPrice;

    final privateRoom = fromExplicit
        ? (includeSafeFallbacks
            ? (explicitPrivateRoom ?? false)
            : explicitPrivateRoom)
        : state.privateRoom;
    final withPhoto = fromExplicit
        ? (includeSafeFallbacks
            ? (explicitWithPhoto ?? false)
            : explicitWithPhoto)
        : state.withPhoto;

    return ResolvedListingSearchParams(
      listingTypeId: listingTypeIds != null ? null : listingTypeId,
      listingTypeIds: listingTypeIds,
      locationId: locationId,
      subwayStationId: subwayStationId,
      subwayStationIds: subwayStationIds,
      subwayLineId: subwayLineId,
      gender: gender,
      minPrice: minPrice,
      maxPrice: maxPrice,
      privateRoom: privateRoom,
      withPhoto: withPhoto,
    );
  }

  /// Build from map / search-sheet toggle values (single UI listing type + optional multi-type ids).
  static ResolvedListingSearchParams fromMapToggle({
    required int listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int> subwayStationIds = const [],
    int? subwayLineId,
    int? gender,
    required double minPrice,
    required double maxPrice,
    required bool privateRoom,
    required bool withPhoto,
  }) {
    final normalizedStationIds =
        subwayStationIds.isNotEmpty ? List<int>.from(subwayStationIds) : null;
    final hasStationFilter = (normalizedStationIds?.isNotEmpty ?? false) ||
        (subwayStationId != null && subwayStationId > 0);

    return ResolvedListingSearchParams(
      listingTypeId:
          listingTypeIds != null ? null : listingTypeId,
      listingTypeIds: listingTypeIds,
      locationId: locationId,
      subwayStationId: subwayStationId,
      subwayStationIds: normalizedStationIds,
      subwayLineId: hasStationFilter ? subwayLineId : null,
      gender: gender,
      minPrice: minPrice,
      maxPrice: maxPrice,
      privateRoom: privateRoom,
      withPhoto: withPhoto,
    );
  }

  Future<PageableResponse<Listing>> searchListingsPage(
    IListingService service, {
    required int page,
    required int limit,
    bool isActive = true,
  }) {
    return service.searchListings(
      page: page,
      limit: limit,
      isActive: isActive,
      listingTypeId: listingTypeId,
      listingTypeIds: listingTypeIds,
      locationId: locationId,
      subwayStationId: subwayStationId,
      subwayStationIds: subwayStationIds,
      subwayLineId: subwayLineId,
      gender: gender,
      minPrice: minPrice,
      maxPrice: maxPrice,
      privateRoom: privateRoom,
      withPhoto: withPhoto,
      createdWithinDays: createdWithinDays,
    );
  }
}
