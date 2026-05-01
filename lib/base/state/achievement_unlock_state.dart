import "package:flutter/foundation.dart";
import "package:uy_dosh/domain/models/achievement.dart";

/// Global state for pending achievement unlock notification.
/// When an achievement is unlocked, set [pendingAchievement] and a listener
/// will show the bottom sheet.
///
/// Some achievements (e.g. the "ice breaker" one unlocked when sending the
/// first message) shouldn't pop while the user is still inside the screen
/// that triggered them. For those, use [setDeferredAchievement] and call
/// [flushDeferredAchievement] when leaving that screen.
class AchievementUnlockState extends ChangeNotifier {
  factory AchievementUnlockState() => _instance;
  AchievementUnlockState._internal();
  static final AchievementUnlockState _instance =
      AchievementUnlockState._internal();

  Achievement? _pendingAchievement;
  Achievement? _deferredAchievement;

  Achievement? get pendingAchievement => _pendingAchievement;

  void setPendingAchievement(Achievement? achievement) {
    _pendingAchievement = achievement;
    notifyListeners();
  }

  void clearPendingAchievement() {
    _pendingAchievement = null;
    notifyListeners();
  }

  /// Stash an achievement to surface later. The listener in `main.dart` won't
  /// react until [flushDeferredAchievement] promotes it to a regular pending
  /// achievement. Last-write-wins if called multiple times before flush.
  void setDeferredAchievement(Achievement achievement) {
    _deferredAchievement = achievement;
  }

  /// Promote any deferred achievement into the visible pending slot so the
  /// bottom sheet can show. No-op when there's nothing deferred.
  void flushDeferredAchievement() {
    final deferred = _deferredAchievement;
    if (deferred == null) return;
    _deferredAchievement = null;
    setPendingAchievement(deferred);
  }
}
