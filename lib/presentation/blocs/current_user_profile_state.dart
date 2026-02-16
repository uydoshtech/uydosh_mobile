part of "current_user_profile_bloc.dart";

@freezed
class CurrentUserProfileState with _$CurrentUserProfileState {
  const factory CurrentUserProfileState.initial() = _Initial;
  const factory CurrentUserProfileState.loading() = _Loading;
  const factory CurrentUserProfileState.loaded({required UserProfile profile}) =
      _Loaded;
  const factory CurrentUserProfileState.error({required String message}) =
      _Error;
}
