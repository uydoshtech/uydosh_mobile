import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/admin_user.dart";

abstract class IAdminUserService {
  Future<List<AdminUser>> getUsers({int pageNumber = 1, int pageSize = 20});
  Future<AdminUser> updateUserRole({required int userId, required String role});
}

class AdminUserService implements IAdminUserService {
  AdminUserService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<List<AdminUser>> getUsers({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/users",
        (json) => json,
        queryParameters: {
          "pageNumber": pageNumber,
          "pageSize": pageSize,
        },
      );

      final List<dynamic> usersData =
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
}

class _RoleUpdateRequest implements IJsonEncodable {
  _RoleUpdateRequest({required this.role});

  final String role;

  @override
  Map<String, dynamic> toJson() => {"role": role};
}
