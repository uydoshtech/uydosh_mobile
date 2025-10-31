import "package:flutter_bloc/flutter_bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";

part 'listing_owner_profile_event.dart';
part 'listing_owner_profile_state.dart';
part 'listing_owner_profile_bloc.freezed.dart';

class ListingOwnerProfileBloc
    extends Bloc<ListingOwnerProfileEvent, ListingOwnerProfileState> {
  final IUserProfileService _userProfileService;

  ListingOwnerProfileBloc(this._userProfileService)
    : super(const ListingOwnerProfileState.initial()) {
    on<ListingOwnerProfileEvent>((event, emit) async {
      await event.map(
        fetchProfile: (e) async => await _onFetchProfile(e, emit),
      );
    });
  }

  Future<void> _onFetchProfile(
    _FetchProfile event,
    Emitter<ListingOwnerProfileState> emit,
  ) async {
    logger.d("🔍 Profile BLoC: Fetching profile for userId: ${event.userId}");
    emit(const ListingOwnerProfileState.loading());

    try {
      logger.d("🔍 Profile BLoC: Calling getUserProfile service...");
      final profile = await _userProfileService.getUserProfile(event.userId);
      logger.d("🔍 Profile BLoC: Profile received: $profile");
      emit(ListingOwnerProfileState.loaded(profile: profile));
    } catch (error) {
      logger.e("🔍 Profile BLoC: Error occurred: $error");
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingOwnerProfileState.error(message: sanitizedMessage));
    }
  }
}
