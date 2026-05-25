import "package:flutter_bloc/flutter_bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/common_friend.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/follow_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";

part "listing_owner_profile_event.dart";
part "listing_owner_profile_state.dart";
part "listing_owner_profile_bloc.freezed.dart";

class ListingOwnerProfileBloc
    extends Bloc<ListingOwnerProfileEvent, ListingOwnerProfileState> {
  ListingOwnerProfileBloc(
    this._userProfileService,
    this._followService,
  ) : super(const ListingOwnerProfileState.initial()) {
    on<ListingOwnerProfileEvent>((event, emit) async {
      await event.map(
        fetchProfile: (e) async => _onFetchProfile(e, emit),
        toggleFollow: (e) async => _onToggleFollow(e, emit),
      );
    });
  }

  final IUserProfileService _userProfileService;
  final IFollowService _followService;

  Future<void> _onFetchProfile(
    _FetchProfile event,
    Emitter<ListingOwnerProfileState> emit,
  ) async {
    logger.d("🔍 Profile BLoC: Fetching profile for userId: ${event.userId}");
    emit(const ListingOwnerProfileState.loading());

    try {
      final profile = await _userProfileService.getUserProfile(event.userId);
      final currentUserId = await SessionManager.getUserId();
      final canFollow =
          currentUserId != null && currentUserId != event.userId;

      var isFollowing = false;
      if (canFollow) {
        isFollowing = await _followService.checkIfFollowing(event.userId);
      }

      emit(
        ListingOwnerProfileState.loaded(
          profile: profile,
          isFollowing: isFollowing,
          canFollow: canFollow,
        ),
      );

      if (canFollow) {
        try {
          final commonResult = await _followService.getCommonFriends(
            event.userId,
            limit: 6,
          );
          final current = state;
          if (current is _Loaded && current.profile.userId == event.userId) {
            emit(
              current.copyWith(
                commonFriends: commonResult.commonFriends,
                commonFriendsTotal: commonResult.total,
              ),
            );
          }
        } catch (_) {}
      }
    } catch (error) {
      logger.e("🔍 Profile BLoC: Error occurred: $error");
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingOwnerProfileState.error(message: sanitizedMessage));
    }
  }

  Future<void> _onToggleFollow(
    _ToggleFollow event,
    Emitter<ListingOwnerProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! _Loaded || !currentState.canFollow) {
      return;
    }

    emit(currentState.copyWith(isFollowLoading: true));

    final result = await _followService.toggleFollow(event.userId);
    if (result == null) {
      emit(currentState.copyWith(isFollowLoading: false));
      return;
    }

    emit(
      currentState.copyWith(
        isFollowing: result.isFollowing,
        isFollowLoading: false,
      ),
    );
  }
}
