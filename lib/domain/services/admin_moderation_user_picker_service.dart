import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// One row from GET `/admin/users/picker`.
class ModerationUserPickerUser {
  const ModerationUserPickerUser({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
  });

  factory ModerationUserPickerUser.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return ModerationUserPickerUser(
      id: n(json["id"]),
      email: json["email"] as String?,
      name: json["name"] as String?,
      avatarUrl: json["avatar_url"] as String?,
    );
  }

  final int id;
  final String? email;
  final String? name;
  final String? avatarUrl;

  String get displayLabel {
    final n = (name ?? "").trim();
    if (n.isNotEmpty) return n;
    final e = (email ?? "").trim();
    if (e.isNotEmpty) return e;
    return "User $id";
  }
}

abstract class IAdminModerationUserPickerService {
  Future<List<ModerationUserPickerUser>> search({String? q, int limit = 30});
}

class AdminModerationUserPickerService
    implements IAdminModerationUserPickerService {
  AdminModerationUserPickerService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<List<ModerationUserPickerUser>> search({
    String? q,
    int limit = 30,
  }) async {
    try {
      final trimmed = q?.trim();
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/users/picker",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: <String, dynamic>{
          "limit": limit,
          if (trimmed != null && trimmed.isNotEmpty) "q": trimmed,
        },
      );
      if (response is! Map) {
        return const [];
      }
      final raw = response["users"];
      if (raw is! List) {
        return const [];
      }
      return raw
          .whereType<Map>()
          .map(
            (e) => ModerationUserPickerUser.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e) {
      logger.d("Admin user picker search error: $e");
      rethrow;
    }
  }
}
