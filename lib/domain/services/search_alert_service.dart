import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";

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
}
