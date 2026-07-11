import "package:freezed_annotation/freezed_annotation.dart";

part "listings_event.freezed.dart";

@freezed
sealed class ListingsEvent with _$ListingsEvent {
  const factory ListingsEvent.fetchListings({
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
  }) = _FetchListings;

  const factory ListingsEvent.loadMore({
    @Default(10) int limit,
    @Default(true) bool isActive,
  }) = _LoadMore;

  const factory ListingsEvent.fetchListingsByLocation({
    required int locationId,
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
  }) = _FetchListingsByLocation;

  const factory ListingsEvent.searchListings({
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    bool? has3dTour,
    String? priceSortOrder,
    List<int>? excludeUserIds,
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
    /// When true with [isRefresh], keeps current listings on screen until the
    /// new page returns (skips loading/skeleton state).
    @Default(false) bool keepStaleWhileRefreshing,
  }) = _SearchListings;

  const factory ListingsEvent.fetchUserListings({
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isRefresh,
  }) = _FetchUserListings;
}
