import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/common_friend.dart";

class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

abstract class IFollowService {
  Future<bool> checkIfFollowing(int userId);
  Future<FollowToggleResult?> toggleFollow(int userId);
  Future<CommonFriendsResult> getCommonFriends(
    int userId, {
    int page = 1,
    int limit = 10,
  });
  Future<FollowCounts> getFollowCounts(int userId);
  Future<FollowUsersResult> getFollowers(
    int userId, {
    int page = 1,
    int limit = 20,
  });
  Future<FollowUsersResult> getFollowing(
    int userId, {
    int page = 1,
    int limit = 20,
  });
}

class FollowService implements IFollowService {
  FollowService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  Future<void> _handleUnauthorized() async {
    await SessionManager.clearSession();
  }

  @override
  Future<bool> checkIfFollowing(int userId) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/follows/check/$userId",
        (data) => data as Map<String, dynamic>,
      );
      return response["isFollowing"] as bool? ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      return false;
    } catch (e) {
      logger.d("FollowService: checkIfFollowing error: $e");
      return false;
    }
  }

  @override
  Future<FollowToggleResult?> toggleFollow(int userId) async {
    try {
      final response = await _oauthApiClient
          .put<Map<String, dynamic>, _EmptyRequest>(
            "/follows/toggle/$userId",
            (data) => data as Map<String, dynamic>,
          );
      return FollowToggleResult.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("FollowService: toggleFollow error: ${e.message}");
      return null;
    } catch (e) {
      logger.d("FollowService: toggleFollow error: $e");
      return null;
    }
  }

  @override
  Future<CommonFriendsResult> getCommonFriends(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/follows/common/$userId?page=$page&limit=$limit",
        (data) => data as Map<String, dynamic>,
      );
      return CommonFriendsResult.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("FollowService: getCommonFriends error: ${e.message}");
      return const CommonFriendsResult(
        commonFriends: [],
        total: 0,
        page: 1,
        totalPages: 0,
      );
    } catch (e) {
      logger.d("FollowService: getCommonFriends error: $e");
      return const CommonFriendsResult(
        commonFriends: [],
        total: 0,
        page: 1,
        totalPages: 0,
      );
    }
  }

  @override
  Future<FollowCounts> getFollowCounts(int userId) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/follows/counts/$userId",
        (data) => data as Map<String, dynamic>,
      );
      return FollowCounts.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("FollowService: getFollowCounts error: ${e.message}");
      return const FollowCounts(followerCount: 0, followingCount: 0);
    } catch (e) {
      logger.d("FollowService: getFollowCounts error: $e");
      return const FollowCounts(followerCount: 0, followingCount: 0);
    }
  }

  @override
  Future<FollowUsersResult> getFollowers(
    int userId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _fetchFollowUsers("/follows/followers/$userId", page, limit);
  }

  @override
  Future<FollowUsersResult> getFollowing(
    int userId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _fetchFollowUsers("/follows/following/$userId", page, limit);
  }

  Future<FollowUsersResult> _fetchFollowUsers(
    String path,
    int page,
    int limit,
  ) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "$path?page=$page&limit=$limit",
        (data) => data as Map<String, dynamic>,
      );
      return FollowUsersResult.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("FollowService: fetchFollowUsers error: ${e.message}");
      return const FollowUsersResult(
        users: [],
        total: 0,
        page: 1,
        totalPages: 0,
      );
    } catch (e) {
      logger.d("FollowService: fetchFollowUsers error: $e");
      return const FollowUsersResult(
        users: [],
        total: 0,
        page: 1,
        totalPages: 0,
      );
    }
  }
}
