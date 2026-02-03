import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/admin_user.dart";

abstract class IAdminUserService {
  Future<List<AdminUser>> getUsers({int pageNumber = 1, int pageSize = 20});
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
}
