import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/achievement.dart";

abstract class IGamificationService {
  Future<List<Achievement>> getAllAchievements();
  Future<Set<String>> getUnlockedAchievementIds();
  Future<bool> hasNewAchievements();
  Future<void> markAchievementsAsSeen();
  Future<bool> isAchievementUnlocked(String achievementId);
  Future<Achievement?> unlockAchievement(String achievementId);
  Future<void> recordAppOpen();
  Future<Achievement?> recordShare();
  Future<Achievement?> recordFirstMessage();
  Future<bool> hasSentFirstMessage();
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

class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

class _CheckAchievementsRequest implements IJsonEncodable {
  _CheckAchievementsRequest({
    required this.profileCompletionPercent,
    required this.viewedListingsCount,
    required this.favoritesCount,
    required this.listingsCreatedCount,
    required this.conversationsStartedCount,
  });

  final int profileCompletionPercent;
  final int viewedListingsCount;
  final int favoritesCount;
  final int listingsCreatedCount;
  final int conversationsStartedCount;

  @override
  Map<String, dynamic> toJson() => {
        "profileCompletionPercent": profileCompletionPercent,
        "viewedListingsCount": viewedListingsCount,
        "favoritesCount": favoritesCount,
        "listingsCreatedCount": listingsCreatedCount,
        "conversationsStartedCount": conversationsStartedCount,
      };
}

/// Achievement definitions - same as backend. Used for display.
const List<Achievement> _allAchievements = [
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
  Achievement(
    id: "sharer",
    key: "achievement_sharer",
    icon: Icons.ios_share,
    category: AchievementCategory.engagement,
  ),
];

/// Gamification service backed by backend API (database).
class GamificationService implements IGamificationService {
  GamificationService(this._oauthApiClient);
  final IOAuthApiClient _oauthApiClient;

  Future<void> _handleUnauthorized() async {
    logger.d("🚨 GamificationService: Session expired, clearing local session...");
    await SessionManager.clearSession();
  }

  Achievement? _achievementById(String id) {
    try {
      return _allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return List.from(_allAchievements);
  }

  @override
  Future<Set<String>> getUnlockedAchievementIds() async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/achievements",
        (data) => data as Map<String, dynamic>,
      );
      final list = response["unlockedIds"];
      if (list is List) {
        return list.map((e) => e.toString()).toSet();
      }
      return {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("❌ GamificationService: getUnlockedAchievementIds: ${e.message}");
      return {};
    } catch (e) {
      logger.d("❌ GamificationService: getUnlockedAchievementIds: $e");
      return {};
    }
  }

  @override
  Future<bool> hasNewAchievements() async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/achievements",
        (data) => data as Map<String, dynamic>,
      );
      return response["hasNew"] as bool? ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> markAchievementsAsSeen() async {
    try {
      await _oauthApiClient.post<Map<String, dynamic>, _EmptyRequest>(
        "/achievements/mark-seen",
        (data) => data as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("❌ GamificationService: markAchievementsAsSeen: ${e.message}");
    } catch (e) {
      logger.d("❌ GamificationService: markAchievementsAsSeen: $e");
    }
  }

  @override
  Future<bool> isAchievementUnlocked(String achievementId) async {
    final unlocked = await getUnlockedAchievementIds();
    return unlocked.contains(achievementId);
  }

  @override
  Future<Achievement?> unlockAchievement(String achievementId) async {
    final a = _achievementById(achievementId);
    return a;
  }

  @override
  Future<void> recordAppOpen() async {
    try {
      await _oauthApiClient.post<Map<String, dynamic>, _EmptyRequest>(
        "/achievements/record-app-open",
        (data) => data as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("❌ GamificationService: recordAppOpen: ${e.message}");
    } catch (e) {
      logger.d("❌ GamificationService: recordAppOpen: $e");
    }
  }

  @override
  Future<Achievement?> recordShare() async {
    try {
      final response = await _oauthApiClient.post<Map<String, dynamic>, _EmptyRequest>(
        "/achievements/record-share",
        (data) => data as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
      final newlyUnlocked = response["newlyUnlocked"] as List<dynamic>?;
      if (newlyUnlocked != null &&
          newlyUnlocked.isNotEmpty &&
          newlyUnlocked.first is String) {
        return _achievementById(newlyUnlocked.first as String);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("❌ GamificationService: recordShare: ${e.message}");
      return null;
    } catch (e) {
      logger.d("❌ GamificationService: recordShare: $e");
      return null;
    }
  }

  @override
  Future<Achievement?> recordFirstMessage() async {
    try {
      final response = await _oauthApiClient.post<Map<String, dynamic>, _EmptyRequest>(
        "/achievements/record-first-message",
        (data) => data as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
      final newlyUnlocked = response["newlyUnlocked"] as List<dynamic>?;
      if (newlyUnlocked != null &&
          newlyUnlocked.isNotEmpty &&
          newlyUnlocked.first is String) {
        return _achievementById(newlyUnlocked.first as String);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("❌ GamificationService: recordFirstMessage: ${e.message}");
      return null;
    } catch (e) {
      logger.d("❌ GamificationService: recordFirstMessage: $e");
      return null;
    }
  }

  @override
  Future<bool> hasSentFirstMessage() async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/achievements/has-sent-first-message",
        (data) => data as Map<String, dynamic>,
      );
      return response["hasSentFirstMessage"] as bool? ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      return false;
    } catch (_) {
      return false;
    }
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
    try {
      final response = await _oauthApiClient.post<Map<String, dynamic>, _CheckAchievementsRequest>(
        "/achievements/check",
        (data) => data as Map<String, dynamic>,
        data: _CheckAchievementsRequest(
          profileCompletionPercent: profileCompletionPercent,
          viewedListingsCount: viewedListingsCount,
          favoritesCount: favoritesCount,
          listingsCreatedCount: listingsCreatedCount,
          conversationsStartedCount: conversationsStartedCount,
        ),
      );
      final newlyUnlocked = response["newlyUnlocked"] as List<dynamic>?;
      if (newlyUnlocked == null) return [];

      final result = <Achievement>[];
      for (final id in newlyUnlocked) {
        final a = _achievementById(id.toString());
        if (a != null) result.add(a);
      }
      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("❌ GamificationService: checkAndUnlockAchievements: ${e.message}");
      return [];
    } catch (e) {
      logger.d("❌ GamificationService: checkAndUnlockAchievements: $e");
      return [];
    }
  }
}
