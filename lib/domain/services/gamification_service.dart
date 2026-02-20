import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/domain/models/achievement.dart";

abstract class IGamificationService {
  Future<List<Achievement>> getAllAchievements();
  Future<Set<String>> getUnlockedAchievementIds();
  Future<bool> isAchievementUnlocked(String achievementId);
  Future<Achievement?> unlockAchievement(String achievementId);
  Future<void> recordAppOpen();
  Future<List<Achievement>> checkAndUnlockAchievements({
    required bool hasAccount,
    required int profileCompletionPercent,
    required int viewedListingsCount,
    required int favoritesCount,
    required int messagesSentCount,
    required int listingsCreatedCount,
    required int conversationsStartedCount,
  });
}

/// Storage key for unlocked achievement IDs (JSON array of strings).
const String _unlockedAchievementsKey = "gamification_unlocked_achievements";

/// MVP achievements - client-side only. Backend can be added later.
class GamificationService implements IGamificationService {
  GamificationService(this._prefs);
  final SharedPreferences _prefs;

  static const List<Achievement> _allAchievements = [
    Achievement(
      id: "first_steps",
      key: "achievement_first_steps",
      icon: Icons.login,
      category: AchievementCategory.onboarding,
    ),
    Achievement(
      id: "profile_complete",
      key: "achievement_profile_complete",
      icon: Icons.check_circle,
      category: AchievementCategory.profile,
      isMajor: true,
    ),
    Achievement(
      id: "first_look",
      key: "achievement_first_look",
      icon: Icons.visibility,
      category: AchievementCategory.browsing,
    ),
    Achievement(
      id: "bookmarker",
      key: "achievement_bookmarker",
      icon: Icons.favorite,
      category: AchievementCategory.browsing,
    ),
    Achievement(
      id: "ice_breaker",
      key: "achievement_ice_breaker",
      icon: Icons.chat_bubble,
      category: AchievementCategory.messaging,
    ),
    Achievement(
      id: "first_listing",
      key: "achievement_first_listing",
      icon: Icons.add_home,
      category: AchievementCategory.listings,
      isMajor: true,
    ),
    Achievement(
      id: "returning_user",
      key: "achievement_returning_user",
      icon: Icons.celebration,
      category: AchievementCategory.engagement,
      isMajor: true,
    ),
  ];

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return List.from(_allAchievements);
  }

  @override
  Future<Set<String>> getUnlockedAchievementIds() async {
    final json = _prefs.getString(_unlockedAchievementsKey);
    if (json == null || json.isEmpty) return {};
    try {
      final list = _parseJsonList(json);
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  List<String> _parseJsonList(String json) {
    final trimmed = json.trim();
    if (trimmed.isEmpty || trimmed == "[]") return [];
    final inner = trimmed
        .replaceFirst("[", "")
        .replaceFirst("]", "")
        .split(",")
        .map((s) => s.trim().replaceAll('"', ""))
        .where((s) => s.isNotEmpty)
        .toList();
    return inner;
  }

  Future<void> _saveUnlockedIds(Set<String> ids) async {
    final json = "[${ids.map((s) => '"$s"').join(",")}]";
    await _prefs.setString(_unlockedAchievementsKey, json);
  }

  @override
  Future<bool> isAchievementUnlocked(String achievementId) async {
    final unlocked = await getUnlockedAchievementIds();
    return unlocked.contains(achievementId);
  }

  @override
  Future<Achievement?> unlockAchievement(String achievementId) async {
    final alreadyUnlocked = await isAchievementUnlocked(achievementId);
    if (alreadyUnlocked) return null;

    final achievement =
        _allAchievements.cast<Achievement?>().firstWhere(
              (a) => a?.id == achievementId,
              orElse: () => null,
            );
    if (achievement == null) return null;

    final unlocked = await getUnlockedAchievementIds();
    unlocked.add(achievementId);
    await _saveUnlockedIds(unlocked);
    return achievement;
  }

  @override
  Future<List<Achievement>> checkAndUnlockAchievements({
    required bool hasAccount,
    required int profileCompletionPercent,
    required int viewedListingsCount,
    required int favoritesCount,
    required int messagesSentCount,
    required int listingsCreatedCount,
    required int conversationsStartedCount,
  }) async {
    final toUnlock = <String>[];

    if (hasAccount) toUnlock.add("first_steps");
    if (profileCompletionPercent >= 100) toUnlock.add("profile_complete");
    if (viewedListingsCount >= 1) toUnlock.add("first_look");
    if (favoritesCount >= 1) toUnlock.add("bookmarker");
    if (messagesSentCount >= 1) toUnlock.add("ice_breaker");
    if (listingsCreatedCount >= 1) toUnlock.add("first_listing");
    if (await _getStreakDays() >= 7) toUnlock.add("returning_user");

    final newlyUnlocked = <Achievement>[];
    for (final id in toUnlock) {
      final a = await unlockAchievement(id);
      if (a != null) newlyUnlocked.add(a);
    }
    return newlyUnlocked;
  }

  static const String _streakCountKey = "gamification_streak_count";
  static const String _lastOpenDateKey = "gamification_last_open_date";

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

  Future<int> _getStreakDays() async {
    return _prefs.getInt(_streakCountKey) ?? 0;
  }

  /// Call this when the app is opened to update streak.
  @override
  Future<void> recordAppOpen() async {
    final today = DateTime.now();
    final todayStr = _dateKey(today);
    final lastOpenStr = _prefs.getString(_lastOpenDateKey);
    var streak = _prefs.getInt(_streakCountKey) ?? 0;

    if (lastOpenStr == null) {
      streak = 1;
    } else {
      final lastOpen = DateTime.tryParse(lastOpenStr);
      if (lastOpen != null) {
        final diff = today.difference(DateTime(lastOpen.year, lastOpen.month, lastOpen.day)).inDays;
        if (diff == 0) {
          return;
        }
        if (diff == 1) {
          streak += 1;
        } else {
          streak = 1;
        }
      } else {
        streak = 1;
      }
    }

    await _prefs.setString(_lastOpenDateKey, todayStr);
    await _prefs.setInt(_streakCountKey, streak);
  }
}
