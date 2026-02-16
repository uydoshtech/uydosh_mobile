part of "listing_owner_profile_bloc.dart";

@freezed
class ListingOwnerProfileState with _$ListingOwnerProfileState {
  const factory ListingOwnerProfileState.initial() = _Initial;
  const factory ListingOwnerProfileState.loading() = _Loading;
  const factory ListingOwnerProfileState.loaded({
    required UserProfile profile,
  }) = _Loaded;
  const factory ListingOwnerProfileState.error({required String message}) =
      _Error;
}
