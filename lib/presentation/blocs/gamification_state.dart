part of "gamification_bloc.dart";

@freezed
sealed class GamificationState with _$GamificationState {
  const factory GamificationState.initial() = _Initial;
  const factory GamificationState.loading() = _Loading;
  const factory GamificationState.loaded({
    required List<Achievement> achievements,
    required Set<String> unlockedIds,
  }) = _Loaded;
  const factory GamificationState.error({required String message}) = _Error;
}
