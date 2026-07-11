part of "listing_detail_bloc.dart";

@freezed
sealed class ListingDetailEvent with _$ListingDetailEvent {
  const factory ListingDetailEvent.fetchListingDetail({
    required int id,
    @Default(false) bool isRefresh,
  }) = _FetchListingDetail;
  const factory ListingDetailEvent.updateListingDetail({
    required ListingDetail listingDetail,
  }) = _UpdateListingDetail;
}
