import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/domain/models/search_alert.dart";

abstract class IAdminUserSearchAlertService {
  Future<List<SearchAlert>> listUserAlerts({required int userId});
}

class AdminUserSearchAlertService implements IAdminUserSearchAlertService {
  AdminUserSearchAlertService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<List<SearchAlert>> listUserAlerts({required int userId}) async {
    final r = await _oauthApiClient.get<Map<String, dynamic>>(
      "/users/$userId/search-alerts",
      (json) => json as Map<String, dynamic>,
    );

    final raw = r["alerts"];
    if (raw is! List) return <SearchAlert>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(SearchAlert.fromJson)
        .toList();
  }
}
