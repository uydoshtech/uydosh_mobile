import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uy_dosh/domain/services/user_profile_service.dart';
import 'package:uy_dosh/domain/models/user_profile.dart';
import 'package:uy_dosh/base/util/error_message_helper.dart';

part 'current_user_profile_event.dart';
part 'current_user_profile_state.dart';
part 'current_user_profile_bloc.freezed.dart';

const String profileNotFoundErrorCode = 'profile_not_found';

class CurrentUserProfileBloc
    extends Bloc<CurrentUserProfileEvent, CurrentUserProfileState> {
  final IUserProfileService _userProfileService;

  CurrentUserProfileBloc(this._userProfileService)
    : super(const CurrentUserProfileState.initial()) {
    on<CurrentUserProfileEvent>((event, emit) async {
      await event.map(
        fetchProfile: (e) async => await _onFetchProfile(e, emit),
      );
    });
  }

  Future<void> _onFetchProfile(
    _FetchProfile event,
    Emitter<CurrentUserProfileState> emit,
  ) async {
    emit(const CurrentUserProfileState.loading());

    try {
      final profile = await _userProfileService.getCurrentUserProfile();
      emit(CurrentUserProfileState.loaded(profile: profile));
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 404) {
        emit(
          const CurrentUserProfileState.error(
            message: profileNotFoundErrorCode,
          ),
        );
        return;
      }
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(CurrentUserProfileState.error(message: sanitizedMessage));
    }
  }
}
