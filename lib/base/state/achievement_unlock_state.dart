import "package:flutter/foundation.dart";
import "package:uy_dosh/domain/models/achievement.dart";

/// Global state for pending achievement unlock notification.
/// When an achievement is unlocked, set [pendingAchievement] and a listener
/// will show the bottom sheet.
class AchievementUnlockState extends ChangeNotifier {
  factory AchievementUnlockState() => _instance;
  AchievementUnlockState._internal();
  static final AchievementUnlockState _instance =
      AchievementUnlockState._internal();

  Achievement? _pendingAchievement;

  Achievement? get pendingAchievement => _pendingAchievement;

  void setPendingAchievement(Achievement? achievement) {
    _pendingAchievement = achievement;
    notifyListeners();
  }

  void clearPendingAchievement() {
    _pendingAchievement = null;
    notifyListeners();
  }
}
