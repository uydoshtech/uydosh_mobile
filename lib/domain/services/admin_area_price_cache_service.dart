import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart"
    show EmptyListingRequest;

Map<String, dynamic> _requireJsonMap(dynamic response, String errorMessage) {
  if (response is! Map) {
    throw Exception(errorMessage);
  }
  return Map<String, dynamic>.from(response);
}

class AreaPriceCacheRefreshResult {
  AreaPriceCacheRefreshResult({
    required this.rowCount,
    required this.listingCount,
    required this.durationMs,
  });

  factory AreaPriceCacheRefreshResult.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return AreaPriceCacheRefreshResult(
      rowCount: n(json["rowCount"]),
      listingCount: n(json["listingCount"]),
      durationMs: n(json["durationMs"]),
    );
  }

  final int rowCount;
  final int listingCount;
  final int durationMs;
}

abstract class IAdminAreaPriceCacheService {
  Future<AreaPriceCacheRefreshResult> refreshCache();
}

class AdminAreaPriceCacheService implements IAdminAreaPriceCacheService {
  AdminAreaPriceCacheService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  static const Duration _timeout = Duration(minutes: 5);

  @override
  Future<AreaPriceCacheRefreshResult> refreshCache() async {
    try {
      final response = await _oauthApiClient.post<dynamic, IJsonEncodable>(
        "/admin/listings/area-price-cache/refresh",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
        options: Options(
          receiveTimeout: _timeout,
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final map = _requireJsonMap(
        response,
        "Unexpected area price cache refresh response",
      );
      return AreaPriceCacheRefreshResult.fromJson(map);
    } catch (e) {
      logger.d("Area price cache refresh error: $e");
      rethrow;
    }
  }
}
