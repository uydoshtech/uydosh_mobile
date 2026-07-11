part of "listing_owner_profile_bloc.dart";

@freezed
sealed class ListingOwnerProfileEvent with _$ListingOwnerProfileEvent {
  const factory ListingOwnerProfileEvent.fetchProfile({required int userId}) =
      _FetchProfile;
  const factory ListingOwnerProfileEvent.toggleFollow({required int userId}) =
      _ToggleFollow;
}
