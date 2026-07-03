import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

Map<String, dynamic> _requireJsonMap(dynamic response, String errorMessage) {
  if (response is! Map) {
    throw Exception(errorMessage);
  }
  return Map<String, dynamic>.from(response);
}

double _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse("$v") ?? 0;
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse("$v") ?? 0;
}

DateTime _asDateTime(dynamic v) {
  return DateTime.tryParse("$v")?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

/// One distinct Telegram Mini App visitor who has reported at least one device
/// location, as summarized for the admin "select a Telegram user" picker.
class TelegramMiniAppLocationUserSummary {
  TelegramMiniAppLocationUserSummary({
    required this.telegramUserId,
    required this.telegramUsername,
    required this.phoneNumber,
    required this.lastLatitude,
    required this.lastLongitude,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.pingCount,
  });

  factory TelegramMiniAppLocationUserSummary.fromJson(
      Map<String, dynamic> json) {
    return TelegramMiniAppLocationUserSummary(
      telegramUserId: "${json["telegramUserId"]}",
      telegramUsername: json["telegramUsername"] as String?,
      phoneNumber: json["phoneNumber"] as String?,
      lastLatitude: _asDouble(json["lastLatitude"]),
      lastLongitude: _asDouble(json["lastLongitude"]),
      firstSeenAt: _asDateTime(json["firstSeenAt"]),
      lastSeenAt: _asDateTime(json["lastSeenAt"]),
      pingCount: _asInt(json["pingCount"]),
    );
  }

  final String telegramUserId;
  final String? telegramUsername;
  final String? phoneNumber;
  final double lastLatitude;
  final double lastLongitude;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final int pingCount;
}

class TelegramMiniAppLocationUsersPage {
  TelegramMiniAppLocationUsersPage({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory TelegramMiniAppLocationUsersPage.fromJson(Map<String, dynamic> json) {
    return TelegramMiniAppLocationUsersPage(
      users: (json["users"] as List<dynamic>? ?? [])
          .map((e) => TelegramMiniAppLocationUserSummary.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: _asInt(json["total"]),
      page: _asInt(json["page"]),
      limit: _asInt(json["limit"]),
    );
  }

  final List<TelegramMiniAppLocationUserSummary> users;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => users.isNotEmpty && page * limit < total;
}

/// One recorded device position for a Telegram user, optionally paired with a
/// verified phone number (only present on the row where requestContact() was shared).
class TelegramMiniAppLocationHistoryPoint {
  TelegramMiniAppLocationHistoryPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory TelegramMiniAppLocationHistoryPoint.fromJson(
      Map<String, dynamic> json) {
    return TelegramMiniAppLocationHistoryPoint(
      id: _asInt(json["id"]),
      latitude: _asDouble(json["latitude"]),
      longitude: _asDouble(json["longitude"]),
      phoneNumber: json["phoneNumber"] as String?,
      createdAt: _asDateTime(json["createdAt"]),
    );
  }

  final int id;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final DateTime createdAt;
}

class TelegramMiniAppLocationHistoryPage {
  TelegramMiniAppLocationHistoryPage({
    required this.telegramUserId,
    required this.telegramUsername,
    required this.history,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory TelegramMiniAppLocationHistoryPage.fromJson(
      Map<String, dynamic> json) {
    return TelegramMiniAppLocationHistoryPage(
      telegramUserId: "${json["telegramUserId"]}",
      telegramUsername: json["telegramUsername"] as String?,
      history: (json["history"] as List<dynamic>? ?? [])
          .map((e) => TelegramMiniAppLocationHistoryPoint.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: _asInt(json["total"]),
      page: _asInt(json["page"]),
      limit: _asInt(json["limit"]),
    );
  }

  final String telegramUserId;
  final String? telegramUsername;
  final List<TelegramMiniAppLocationHistoryPoint> history;
  final int total;
  final int page;
  final int limit;
}

abstract class IAdminTelegramMiniAppLocationService {
  /// GET `/admin/telegram-mini-app-locations/users` — search/list distinct Telegram
  /// visitors who have reported a device location, most recently active first.
  Future<TelegramMiniAppLocationUsersPage> listUsers({
    String? search,
    int page = 1,
    int limit = 30,
  });

  /// GET `/admin/telegram-mini-app-locations/users/:telegramUserId/history` —
  /// chronological (oldest-first) location history for one Telegram user.
  Future<TelegramMiniAppLocationHistoryPage> getHistory({
    required String telegramUserId,
    int page = 1,
    int limit = 1000,
  });
}

class AdminTelegramMiniAppLocationService
    implements IAdminTelegramMiniAppLocationService {
  AdminTelegramMiniAppLocationService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<TelegramMiniAppLocationUsersPage> listUsers({
    String? search,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final trimmed = search?.trim();
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/telegram-mini-app-locations/users",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {
          "page": page,
          "limit": limit,
          if (trimmed != null && trimmed.isNotEmpty) "q": trimmed,
        },
      );
      final map = _requireJsonMap(
          response, "Unexpected telegram mini app location users response");
      return TelegramMiniAppLocationUsersPage.fromJson(map);
    } catch (e) {
      logger.d("Load telegram mini app location users error: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramMiniAppLocationHistoryPage> getHistory({
    required String telegramUserId,
    int page = 1,
    int limit = 1000,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/telegram-mini-app-locations/users/$telegramUserId/history",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
      );
      final map = _requireJsonMap(
          response, "Unexpected telegram mini app location history response");
      return TelegramMiniAppLocationHistoryPage.fromJson(map);
    } catch (e) {
      logger.d("Load telegram mini app location history error: $e");
      rethrow;
    }
  }
}
