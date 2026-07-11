part of "listing_owner_profile_bloc.dart";

@freezed
sealed class ListingOwnerProfileState with _$ListingOwnerProfileState {
  const factory ListingOwnerProfileState.initial() = _Initial;
  const factory ListingOwnerProfileState.loading() = _Loading;
  const factory ListingOwnerProfileState.loaded({
    required UserProfile profile,
    @Default(false) bool isFollowing,
    @Default(false) bool isFollowLoading,
    @Default(<CommonFriend>[]) List<CommonFriend> commonFriends,
    @Default(0) int commonFriendsTotal,
    @Default(false) bool canFollow,
  }) = _Loaded;
  const factory ListingOwnerProfileState.error({required String message}) =
      _Error;
}
