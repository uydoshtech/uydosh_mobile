part of 'listing_detail_bloc.dart';

@freezed
class ListingDetailEvent with _$ListingDetailEvent {
  const factory ListingDetailEvent.fetchListingDetail({required int id}) =
      _FetchListingDetail;
  const factory ListingDetailEvent.updateListingDetail({
    required ListingDetail listingDetail,
  }) = _UpdateListingDetail;
}
