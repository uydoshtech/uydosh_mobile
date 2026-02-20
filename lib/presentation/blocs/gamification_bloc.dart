import "package:flutter_bloc/flutter_bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/achievement.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";

part "gamification_bloc.freezed.dart";
part "gamification_event.dart";
part "gamification_state.dart";

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  GamificationBloc(this._gamificationService)
      : super(const GamificationState.initial()) {
    on<GamificationEvent>((event, emit) async {
      await event.map(
        loadAchievements: (e) async => _onLoadAchievements(e, emit),
        checkAndUnlock: (e) async => _onCheckAndUnlock(e, emit),
      );
    });
  }

  final IGamificationService _gamificationService;

  Future<void> _onLoadAchievements(
    _LoadAchievements event,
    Emitter<GamificationState> emit,
  ) async {
    emit(const GamificationState.loading());

    try {
      final achievements = await _gamificationService.getAllAchievements();
      final unlockedIds =
          await _gamificationService.getUnlockedAchievementIds();

      emit(GamificationState.loaded(
        achievements: achievements,
        unlockedIds: unlockedIds,
      ));
    } catch (e) {
      emit(GamificationState.error(message: e.toString()));
    }
  }

  Future<void> _onCheckAndUnlock(
    _CheckAndUnlock event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      await _gamificationService.recordAppOpen();

      await _gamificationService.checkAndUnlockAchievements(
        hasAccount: event.hasAccount,
        profileCompletionPercent: event.profileCompletionPercent,
        viewedListingsCount: event.viewedListingsCount,
        favoritesCount: event.favoritesCount,
        messagesSentCount: event.messagesSentCount,
        listingsCreatedCount: event.listingsCreatedCount,
        conversationsStartedCount: event.conversationsStartedCount,
      );
    } catch (_) {}
  }
}
