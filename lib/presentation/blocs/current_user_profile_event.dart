part of "current_user_profile_bloc.dart";

@freezed
class CurrentUserProfileEvent with _$CurrentUserProfileEvent {
  const factory CurrentUserProfileEvent.fetchProfile() = _FetchProfile;
  const factory CurrentUserProfileEvent.reset() = _Reset;
}
