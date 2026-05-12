import "package:freezed_annotation/freezed_annotation.dart";

part "listings_event.freezed.dart";

@freezed
class ListingsEvent with _$ListingsEvent {
  const factory ListingsEvent.fetchListings({
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
  }) = _$FetchListingsImpl;

  const factory ListingsEvent.loadMore({
    @Default(10) int limit,
    @Default(true) bool isActive,
  }) = _$LoadMoreImpl;

  const factory ListingsEvent.fetchListingsBySubwayStation({
    required int subwayStationId,
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
    /// When true with [isRefresh], keeps [ListingsState.loaded] visible (no
    /// [ListingsState.loading]) until the request completes — for UI that
    /// animates in parallel (e.g. home filter ribbon).
    @Default(false) bool keepStaleWhileRefreshing,
  }) = _$FetchListingsBySubwayStationImpl;

  const factory ListingsEvent.fetchListingsByLocation({
    required int locationId,
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
  }) = _$FetchListingsByLocationImpl;

  const factory ListingsEvent.searchListings({
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isActive,
    @Default(true) bool isRefresh,
    /// When true with [isRefresh], keeps current listings on screen until the
    /// new page returns (skips loading/skeleton state).
    @Default(false) bool keepStaleWhileRefreshing,
  }) = _$SearchListingsImpl;

  const factory ListingsEvent.fetchUserListings({
    @Default(1) int page,
    @Default(10) int limit,
    @Default(true) bool isRefresh,
  }) = _$FetchUserListingsImpl;
}
