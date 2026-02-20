part of "gamification_bloc.dart";

@freezed
class GamificationEvent with _$GamificationEvent {
  const factory GamificationEvent.loadAchievements() = _LoadAchievements;

  const factory GamificationEvent.checkAndUnlock({
    required bool hasAccount,
    required int profileCompletionPercent,
    required int viewedListingsCount,
    required int favoritesCount,
    required int messagesSentCount,
    required int listingsCreatedCount,
    required int conversationsStartedCount,
  }) = _CheckAndUnlock;
}
