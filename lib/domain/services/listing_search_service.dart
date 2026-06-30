import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_map_pin_data.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:flutter/foundation.dart";
import "package:uy_dosh/domain/search/listing_browse_constants.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

void _applyListingTypeQueryParams(
  Map<String, dynamic> queryParams, {
  int? listingTypeId,
  List<int>? listingTypeIds,
}) {
  if (listingTypeIds != null && listingTypeIds.isNotEmpty) {
    queryParams["listingTypeIds"] = listingTypeIds.join(",");
  } else if (listingTypeId != null) {
    queryParams["listingTypeId"] = listingTypeId;
  }
}

abstract class IListingSearchService {
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = listingBrowseCreatedWithinDays,
  });

  Future<List<Listing>> getListingsBySubwayStation(
    int subwayStationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = listingBrowseCreatedWithinDays,
  });

  Future<List<Listing>> getListingsByLocation(
    int locationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = listingBrowseCreatedWithinDays,
  });

  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = listingBrowseCreatedWithinDays,
    List<int>? excludeUserIds,
  });

  Future<PageableResponse<ListingMapPinData>> searchMapListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = listingBrowseCreatedWithinDays,
    List<int>? excludeUserIds,
  });

  Future<PageableResponse<Listing>> getUserListings({
    int page = 1,
    int limit = 10,
    String? language,
  });

  Future<PageableResponse<Listing>> getListingsByUserId({
    required int userId,
    int page = 1,
    int limit = 10,
    String? language,
  });

  /// Subway station IDs that have at least one active listing (single API round-trip).
  Future<List<int>> getSubwayStationIdsWithListings({
    int createdWithinDays = listingBrowseCreatedWithinDays,
    int? listingTypeId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
  });
}

class ListingSearchService implements IListingSearchService {
  ListingSearchService(IPublicApiClient apiClient, this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  List<dynamic> _extractListingsData(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response["content"] != null) {
        return response["content"] as List<dynamic>;
      }
      if (response["listings"] != null) {
        return response["listings"] as List<dynamic>;
      }
      if (response["data"] != null) {
        return response["data"] as List<dynamic>;
      }
    }
    return <dynamic>[];
  }

  PageableResponse<Listing> _toPageableResponse(
    Map<String, dynamic> response,
    List<Listing> listings,
    int page,
    int limit,
  ) =>
      PageableResponse<Listing>(
        data: listings,
        total: response["total"] as int? ?? listings.length,
        page: response["page"] as int? ?? page,
        limit: response["limit"] as int? ?? limit,
        totalPages: response["totalPages"] as int? ?? 1,
      );

  List<dynamic> _extractMapPinsData(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response["pins"] != null) {
        return response["pins"] as List<dynamic>;
      }
    }
    return <dynamic>[];
  }

  PageableResponse<ListingMapPinData> _toMapPinPageableResponse(
    Map<String, dynamic> response,
    List<ListingMapPinData> pins,
    int page,
    int limit,
  ) =>
      PageableResponse<ListingMapPinData>(
        data: pins,
        total: response["total"] as int? ?? pins.length,
        page: response["page"] as int? ?? page,
        limit: response["limit"] as int? ?? limit,
        totalPages: response["totalPages"] as int? ?? 1,
      );

  Map<String, dynamic> _buildListingSearchQueryParams({
    required int page,
    required int limit,
    required bool isActive,
    required String language,
    int createdWithinDays = listingBrowseCreatedWithinDays,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    List<int>? excludeUserIds,
  }) {
    final queryParams = <String, dynamic>{
      "page": page,
      "limit": limit,
      "isActive": isActive,
      "language": language,
    };
    if (createdWithinDays > 0) {
      queryParams["createdWithinDays"] = createdWithinDays;
    }
    _applyListingTypeQueryParams(
      queryParams,
      listingTypeId: listingTypeId,
      listingTypeIds: listingTypeIds,
    );
    if (locationId != null && locationId > 0) {
      queryParams["locationId"] = locationId;
    }

    final finalStationIds = <int>[];
    if (subwayStationId != null && subwayStationId > 0) {
      finalStationIds.add(subwayStationId);
    }
    if (subwayStationIds != null && subwayStationIds.isNotEmpty) {
      finalStationIds.addAll(subwayStationIds);
    }
    if (finalStationIds.isNotEmpty) {
      final expandedStationIds =
          MetroCache.expandWithTransferStations(finalStationIds);
      if (expandedStationIds.length == 1) {
        queryParams["subwayStationId"] = expandedStationIds.first;
      } else {
        queryParams["subwayStationIds"] = expandedStationIds.join(",");
      }
    }
    if (subwayLineId != null && subwayLineId > 0) {
      queryParams["subwayLineId"] = subwayLineId;
    }
    if (gender != null) queryParams["gender"] = gender;
    if (minPrice != null) queryParams["minPrice"] = minPrice;
    if (maxPrice != null) queryParams["maxPrice"] = maxPrice;
    if (privateRoom != null) queryParams["privateRoom"] = privateRoom;
    if (withPhoto != null) queryParams["withPhoto"] = withPhoto;
    if (excludeUserIds != null && excludeUserIds.isNotEmpty) {
      queryParams["excludeUserIds"] = excludeUserIds.join(",");
    }
    return queryParams;
  }

  @override
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = listingBrowseCreatedWithinDays,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final queryParams = <String, dynamic>{
        "page": page,
        "limit": limit,
        "isActive": isActive,
        "language": currentLanguage,
      };
      if (createdWithinDays > 0) {
        queryParams["createdWithinDays"] = createdWithinDays;
      }
      _applyListingTypeQueryParams(
        queryParams,
        listingTypeId: listingTypeId,
        listingTypeIds: listingTypeIds,
      );
      if (locationId != null && locationId > 0) {
        queryParams["locationId"] = locationId;
      }

      final finalStationIds = <int>[];
      if (subwayStationId != null && subwayStationId > 0) {
        finalStationIds.add(subwayStationId);
      }
      if (subwayStationIds != null && subwayStationIds.isNotEmpty) {
        finalStationIds.addAll(subwayStationIds);
      }
      if (finalStationIds.isNotEmpty) {
        final expandedStationIds =
            MetroCache.expandWithTransferStations(finalStationIds);
        if (expandedStationIds.length == 1) {
          queryParams["subwayStationId"] = expandedStationIds.first;
        } else {
          queryParams["subwayStationIds"] = expandedStationIds.join(",");
        }
        logger.d("\x1B[36m=== TRANSFER STATION EXPANSION DEBUG ===");
        logger.d("Original station IDs: $finalStationIds");
        logger.d("Expanded with transfer stations: $expandedStationIds");
        logger.d("===============================================\x1B[0m");
      }
      if (subwayLineId != null && subwayLineId > 0) {
        queryParams["subwayLineId"] = subwayLineId;
      }
      if (gender != null) queryParams["gender"] = gender;
      if (minPrice != null) queryParams["minPrice"] = minPrice;
      if (maxPrice != null) queryParams["maxPrice"] = maxPrice;

      logger.d("\x1B[32m=== LISTINGS API REQUEST DEBUG ===");
      logger.d("URL: /listings");
      logger.d("Query Parameters: $queryParams");
      logger.d("=====================================\x1B[0m");

      // Use OAuth client so auth token is sent when logged in (enables saving user searches)
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      final listingsData = _extractListingsData(response);
      final listings = listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();

      return _toPageableResponse(response, listings, page, limit);
    } catch (e) {
      logger.d("Error fetching listings: $e");
      rethrow;
    }
  }

  @override
  Future<List<Listing>> getListingsBySubwayStation(
    int subwayStationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = listingBrowseCreatedWithinDays,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      // Use OAuth client so auth token is sent when logged in (enables saving user searches)
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/search?subwayStationId=$subwayStationId&page=$page&limit=$limit&language=$currentLanguage&createdWithinDays=$createdWithinDays",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
      );

      final listingsData = _extractListingsData(response);
      return listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.d("Error fetching listings by subway station: $e");
      rethrow;
    }
  }

  @override
  Future<List<Listing>> getListingsByLocation(
    int locationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = listingBrowseCreatedWithinDays,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      // Use OAuth client so auth token is sent when logged in (enables saving user searches)
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings?locationId=$locationId&page=$page&limit=$limit&language=$currentLanguage&createdWithinDays=$createdWithinDays",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
      );

      final listingsData = _extractListingsData(response);
      return listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.d("Error fetching listings by location: $e");
      rethrow;
    }
  }

  @override
  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = listingBrowseCreatedWithinDays,
    List<int>? excludeUserIds,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final queryParams = <String, dynamic>{
        "page": page,
        "limit": limit,
        "isActive": isActive,
        "language": currentLanguage,
      };
      if (createdWithinDays > 0) {
        queryParams["createdWithinDays"] = createdWithinDays;
      }
      _applyListingTypeQueryParams(
        queryParams,
        listingTypeId: listingTypeId,
        listingTypeIds: listingTypeIds,
      );
      if (locationId != null && locationId > 0) {
        queryParams["locationId"] = locationId;
      }

      final finalStationIds = <int>[];
      if (subwayStationId != null && subwayStationId > 0) {
        finalStationIds.add(subwayStationId);
      }
      if (subwayStationIds != null && subwayStationIds.isNotEmpty) {
        finalStationIds.addAll(subwayStationIds);
      }
      if (finalStationIds.isNotEmpty) {
        final expandedStationIds =
            MetroCache.expandWithTransferStations(finalStationIds);
        if (expandedStationIds.length == 1) {
          queryParams["subwayStationId"] = expandedStationIds.first;
        } else {
          queryParams["subwayStationIds"] = expandedStationIds.join(",");
        }
        logger.d("\x1B[36m=== TRANSFER STATION EXPANSION DEBUG ===");
        logger.d("Original station IDs: $finalStationIds");
        logger.d("Expanded with transfer stations: $expandedStationIds");
        logger.d("===============================================\x1B[0m");
      }
      if (subwayLineId != null && subwayLineId > 0) {
        queryParams["subwayLineId"] = subwayLineId;
      }
      if (gender != null) queryParams["gender"] = gender;
      if (minPrice != null) queryParams["minPrice"] = minPrice;
      if (maxPrice != null) queryParams["maxPrice"] = maxPrice;
      if (privateRoom != null) queryParams["privateRoom"] = privateRoom;
      if (withPhoto != null) queryParams["withPhoto"] = withPhoto;
      if (excludeUserIds != null && excludeUserIds.isNotEmpty) {
        queryParams["excludeUserIds"] = excludeUserIds.join(",");
      }

      logger.d("\x1B[33m=== SEARCH LISTINGS API REQUEST DEBUG ===");
      logger.d("URL: /listings/search");
      logger.d("Query Parameters: $queryParams");
      logger.d("===============================================\x1B[0m");

      // Use OAuth client so auth token is sent when logged in (enables saving user searches)
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/search",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      final listingsData = _extractListingsData(response);
      final listings = listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();

      return _toPageableResponse(response, listings, page, limit);
    } catch (e) {
      logger.d("Error searching listings: $e");
      rethrow;
    }
  }

  @override
  Future<PageableResponse<ListingMapPinData>> searchMapListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = listingBrowseCreatedWithinDays,
    List<int>? excludeUserIds,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final queryParams = _buildListingSearchQueryParams(
        page: page,
        limit: limit,
        isActive: isActive,
        language: currentLanguage,
        createdWithinDays: createdWithinDays,
        listingTypeId: listingTypeId,
        listingTypeIds: listingTypeIds,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoom,
        withPhoto: withPhoto,
        excludeUserIds: excludeUserIds,
      );

      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/map",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      final pinsData = _extractMapPinsData(response);
      final pins = pinsData
          .map((item) => ListingMapPinData.fromJson(item as Map<String, dynamic>))
          .toList();

      return _toMapPinPageableResponse(response, pins, page, limit);
    } catch (e) {
      logger.d("Error searching map listings: $e");
      rethrow;
    }
  }

  @override
  Future<PageableResponse<Listing>> getUserListings({
    int page = 1,
    int limit = 10,
    String? language,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception("User not authenticated. Please log in first.");
      }

      final queryParams = <String, dynamic>{
        "page": page,
        "limit": limit,
        "language": currentLanguage,
      };

      logger.d("\x1B[32m=== USER LISTINGS API REQUEST DEBUG ===");
      logger.d("URL: /listings/user/$userId");
      logger.d("Query Parameters: $queryParams");
      logger.d("==========================================\x1B[0m");

      final response = await _oauthApiClient.get<dynamic>(
        "/listings/user/$userId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      List<dynamic> listingsData;
      if (response is List) {
        listingsData = response;
      } else if (response is Map<String, dynamic>) {
        listingsData = _extractListingsData(response);
      } else {
        listingsData = <dynamic>[];
      }

      final listings = listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();

      return PageableResponse<Listing>(
        data: listings,
        total: listings.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    } catch (e) {
      logger.d("Error fetching user listings: $e");
      rethrow;
    }
  }

  @override
  Future<PageableResponse<Listing>> getListingsByUserId({
    required int userId,
    int page = 1,
    int limit = 10,
    String? language,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final queryParams = <String, dynamic>{
        "page": page,
        "limit": limit,
        "language": currentLanguage,
      };

      final response = await _oauthApiClient.get<dynamic>(
        "/listings/user/$userId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      List<dynamic> listingsData;
      if (response is List) {
        listingsData = response;
      } else if (response is Map<String, dynamic>) {
        listingsData = _extractListingsData(response);
      } else {
        listingsData = <dynamic>[];
      }

      final listings = listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();

      return PageableResponse<Listing>(
        data: listings,
        total: listings.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    } catch (e) {
      logger.d("Error fetching listings for user $userId: $e");
      rethrow;
    }
  }

  @override
  Future<List<int>> getSubwayStationIdsWithListings({
    int createdWithinDays = listingBrowseCreatedWithinDays,
    int? listingTypeId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (createdWithinDays > 0) ...{
          "createdWithinDays": createdWithinDays,
          "created_within_days": createdWithinDays,
        },
        if (listingTypeId != null) ...{
          "listingTypeId": listingTypeId,
          "listing_type_id": listingTypeId,
        },
        if (gender != null) "gender": gender,
        if (minPrice != null) ...{
          "minPrice": minPrice,
          "min_price": minPrice,
        },
        if (maxPrice != null) ...{
          "maxPrice": maxPrice,
          "max_price": maxPrice,
        },
        if (privateRoom != null) ...{
          "privateRoom": privateRoom,
          "private_room": privateRoom,
        },
        if (withPhoto != null) ...{
          "withPhoto": withPhoto,
          "with_photo": withPhoto,
        },
      };
      debugPrint(
        "[ListingSearchService] subway-stations-with-listings params=$queryParams",
      );
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/subway-stations-with-listings",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );
      final raw = response["subwayStationIds"];
      if (raw is! List<dynamic>) return [];
      return raw.map((e) => (e as num).toInt()).toList();
    } catch (e) {
      logger.d("Error fetching subway stations with listings: $e");
      rethrow;
    }
  }
}
