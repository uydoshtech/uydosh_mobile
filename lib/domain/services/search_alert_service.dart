import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/search_alert.dart";

class _CreateSearchAlertRequest implements IJsonEncodable {
  _CreateSearchAlertRequest({
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    this.locationId,
    this.subwayStationId,
    this.subwayLineId,
    this.gender,
  });

  final int listingTypeId;
  final double minPrice;
  final double maxPrice;
  final bool privateRoom;
  final bool withPhoto;
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final int? gender;

  @override
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      "listingTypeId": listingTypeId,
      "minPrice": minPrice,
      "maxPrice": maxPrice,
    };
    if (locationId != null) m["locationId"] = locationId;
    if (subwayStationId != null) m["subwayStationId"] = subwayStationId;
    if (subwayLineId != null) m["subwayLineId"] = subwayLineId;
    if (gender != null) m["gender"] = gender;
    if (privateRoom) m["privateRoom"] = true;
    if (withPhoto) m["withPhoto"] = true;
    return m;
  }
}

abstract class ISearchAlertService {
  /// Creates a search alert matching the current filters. Returns an error message or null on success.
  Future<String?> createAlertForCurrentSearch({
    required int listingTypeId,
    required double minPrice,
    required double maxPrice,
    required bool privateRoomOnly,
    required bool withPhotoOnly,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    int? gender,
  });

  Future<List<SearchAlert>> listAlerts();
  Future<bool> setAlertEnabled({required int alertId, required bool enabled});
  Future<bool> deleteAlert({required int alertId});
}

class SearchAlertService implements ISearchAlertService {
  SearchAlertService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<String?> createAlertForCurrentSearch({
    required int listingTypeId,
    required double minPrice,
    required double maxPrice,
    required bool privateRoomOnly,
    required bool withPhotoOnly,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    int? gender,
  }) async {
    try {
      final data = _CreateSearchAlertRequest(
        listingTypeId: listingTypeId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoomOnly,
        withPhoto: withPhotoOnly,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId,
        gender: gender,
      );

      await _oauthApiClient.post<Map<String, dynamic>, _CreateSearchAlertRequest>(
        "/users/me/search-alerts",
        (json) => json as Map<String, dynamic>,
        data: data,
      );
      return null;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body["error"] is String) {
        return body["error"] as String;
      }
      logger.d("SearchAlertService: create failed: $e");
      return "error";
    } catch (e) {
      logger.d("SearchAlertService: create failed: $e");
      return "error";
    }
  }

  @override
  Future<List<SearchAlert>> listAlerts() async {
    final r = await _oauthApiClient.get<Map<String, dynamic>>(
      "/users/me/search-alerts",
      (json) => json as Map<String, dynamic>,
    );
    final raw = r["alerts"];
    if (raw is! List) return <SearchAlert>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(SearchAlert.fromJson)
        .toList();
  }

  @override
  Future<bool> setAlertEnabled({required int alertId, required bool enabled}) async {
    try {
      await _oauthApiClient.patch<Map<String, dynamic>, _SetEnabledRequest>(
        "/users/me/search-alerts/$alertId",
        (json) => json as Map<String, dynamic>,
        data: _SetEnabledRequest(enabled: enabled),
      );
      return true;
    } catch (e) {
      logger.d("SearchAlertService: set enabled failed: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteAlert({required int alertId}) async {
    try {
      await _oauthApiClient.delete<Map<String, dynamic>, _EmptyRequest>(
        "/users/me/search-alerts/$alertId",
        (json) => json as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
      return true;
    } on DioException catch (e) {
      // Backend returns 204; Dio may treat empty body as null; treat 204 as ok.
      if (e.response?.statusCode == 204) return true;
      logger.d("SearchAlertService: delete failed: $e");
      return false;
    } catch (e) {
      logger.d("SearchAlertService: delete failed: $e");
      return false;
    }
  }
}

class _SetEnabledRequest implements IJsonEncodable {
  _SetEnabledRequest({required this.enabled});
  final bool enabled;

  @override
  Map<String, dynamic> toJson() => {"enabled": enabled};
}

class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}
