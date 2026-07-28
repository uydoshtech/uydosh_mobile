import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";

class _BlockToggleRequest implements IJsonEncodable {
  _BlockToggleRequest({this.reason});

  final String? reason;

  @override
  Map<String, dynamic> toJson() {
    final reason = this.reason?.trim();
    if (reason == null || reason.isEmpty) return {};
    return {"reason": reason};
  }
}

class UserBlockToggleResult {
  const UserBlockToggleResult({
    required this.userId,
    required this.isBlocked,
    required this.action,
  });

  factory UserBlockToggleResult.fromJson(Map<String, dynamic> json) {
    return UserBlockToggleResult(
      userId: (json["userId"] as num?)?.toInt() ?? 0,
      isBlocked: json["isBlocked"] as bool? ?? false,
      action: json["action"] as String? ?? "",
    );
  }

  final int userId;
  final bool isBlocked;
  final String action;
}

abstract class IUserBlockService {
  Future<bool> checkIfBlocked(int userId);
  Future<UserBlockToggleResult?> toggleBlock(int userId, {String? reason});
  Future<List<int>> getBlockedUserIds();
}

class UserBlockService implements IUserBlockService {
  UserBlockService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  Future<void> _handleUnauthorized() async {
    await SessionManager.clearSession();
  }

  @override
  Future<bool> checkIfBlocked(int userId) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/blocks/check/$userId",
        (data) => data as Map<String, dynamic>,
      );
      return response["isBlocked"] as bool? ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      return false;
    } catch (e) {
      logger.d("UserBlockService: checkIfBlocked error: $e");
      return false;
    }
  }

  @override
  Future<UserBlockToggleResult?> toggleBlock(
    int userId, {
    String? reason,
  }) async {
    try {
      final response = await _oauthApiClient.put<Map<String, dynamic>,
          _BlockToggleRequest>(
        "/blocks/toggle/$userId",
        (data) => data as Map<String, dynamic>,
        data: _BlockToggleRequest(reason: reason),
      );
      return UserBlockToggleResult.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("UserBlockService: toggleBlock error: ${e.message}");
      return null;
    } catch (e) {
      logger.d("UserBlockService: toggleBlock error: $e");
      return null;
    }
  }

  @override
  Future<List<int>> getBlockedUserIds() async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/blocks/ids",
        (data) => data as Map<String, dynamic>,
      );
      final raw = response["userIds"];
      if (raw is! List) return const [];
      return raw
          .map((e) => (e as num?)?.toInt())
          .whereType<int>()
          .toList(growable: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handleUnauthorized();
      }
      logger.d("UserBlockService: getBlockedUserIds error: ${e.message}");
      return const [];
    } catch (e) {
      logger.d("UserBlockService: getBlockedUserIds error: $e");
      return const [];
    }
  }
}
