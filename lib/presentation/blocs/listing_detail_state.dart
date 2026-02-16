part of "listing_detail_bloc.dart";

@freezed
class ListingDetailState with _$ListingDetailState {
  const factory ListingDetailState.initial() = _Initial;
  const factory ListingDetailState.loading() = _Loading;
  const factory ListingDetailState.loaded({
    required ListingDetail listingDetail,
  }) = _Loaded;
  const factory ListingDetailState.error({required String message}) = _Error;
}
