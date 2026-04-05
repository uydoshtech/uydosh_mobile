import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/admin_user.dart";

abstract class IAdminUserService {
  Future<List<AdminUser>> getUsers({
    int pageNumber = 1,
    int pageSize = 20,
    String? role,
  });
  Future<AdminUser> updateUserRole({required int userId, required String role});
  Future<AdminUser> blockUser({
    required int userId,
    String? reason,
    DateTime? blockedUntil,
  });
  Future<AdminUser> unblockUser({required int userId});
}

class AdminUserService implements IAdminUserService {
  AdminUserService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<List<AdminUser>> getUsers({
    int pageNumber = 1,
    int pageSize = 20,
    String? role,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        "pageNumber": pageNumber,
        "pageSize": pageSize,
      };
      if (role != null && role.trim().isNotEmpty) {
        queryParameters["role"] = role.trim();
      }
      final response = await _oauthApiClient.get<dynamic>(
        "/users",
        (json) => json,
        queryParameters: queryParameters,
      );

      final usersData =
          response is List ? response : <dynamic>[];

      return usersData
          .map((item) => AdminUser.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
    } catch (e) {
      logger.d("Error fetching admin users: $e");
      rethrow;
    }
  }

  @override
  Future<AdminUser> updateUserRole({
    required int userId,
    required String role,
  }) async {
    try {
      final response = await _oauthApiClient.put<Map<String, dynamic>, _RoleUpdateRequest>(
        "/users/$userId",
        (json) => json as Map<String, dynamic>,
        data: _RoleUpdateRequest(role: role),
      );

      return AdminUser.fromJson(response);
    } catch (e) {
      logger.d("Error updating user role: $e");
      rethrow;
    }
  }

  @override
  Future<AdminUser> blockUser({
    required int userId,
    String? reason,
    DateTime? blockedUntil,
  }) async {
    try {
      final response = await _oauthApiClient.patch<Map<String, dynamic>, _BlockRequest>(
        "/users/$userId/block",
        (json) => json as Map<String, dynamic>,
        data: _BlockRequest(reason: reason, blockedUntil: blockedUntil),
      );

      return AdminUser.fromJson(response);
    } catch (e) {
      logger.d("Error blocking user: $e");
      rethrow;
    }
  }

  @override
  Future<AdminUser> unblockUser({required int userId}) async {
    try {
      final response = await _oauthApiClient.patch<Map<String, dynamic>, _EmptyRequest>(
        "/users/$userId/unblock",
        (json) => json as Map<String, dynamic>,
        data: _EmptyRequest(),
      );

      return AdminUser.fromJson(response);
    } catch (e) {
      logger.d("Error unblocking user: $e");
      rethrow;
    }
  }
}

class _RoleUpdateRequest implements IJsonEncodable {
  _RoleUpdateRequest({required this.role});

  final String role;

  @override
  Map<String, dynamic> toJson() => {"role": role};
}

class _BlockRequest implements IJsonEncodable {
  _BlockRequest({this.reason, this.blockedUntil});

  final String? reason;
  final DateTime? blockedUntil;

  @override
  Map<String, dynamic> toJson() => {
        if (reason != null && reason!.isNotEmpty) "reason": reason,
        if (blockedUntil != null) "blocked_until": blockedUntil!.toIso8601String(),
      };
}

class _EmptyRequest implements IJsonEncodable {
  _EmptyRequest();

  @override
  Map<String, dynamic> toJson() => {};
}
