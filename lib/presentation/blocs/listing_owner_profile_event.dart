part of "listing_owner_profile_bloc.dart";

@freezed
class ListingOwnerProfileEvent with _$ListingOwnerProfileEvent {
  const factory ListingOwnerProfileEvent.fetchProfile({required int userId}) =
      _FetchProfile;
}
