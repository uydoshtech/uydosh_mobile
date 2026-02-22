import "dart:convert";
import "dart:io";

import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/create_listing_request.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

// Empty request class for endpoints that don't require request body
class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

// Photo upload request class
class _PhotoUploadRequest implements IJsonEncodable {

  _PhotoUploadRequest({required this.imageData, required this.isPrimary});
  final String imageData;
  final bool isPrimary;

  @override
  Map<String, dynamic> toJson() => {
    "imageData": imageData,
    "isPrimary": isPrimary,
  };
}

abstract class IListingService {
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = 30,
  });

  Future<List<Listing>> getListingsBySubwayStation(
    int subwayStationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  });
  Future<List<Listing>> getListingsByLocation(
    int locationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  });
  Future<ListingDetail> getListingDetail(int listingId, {String? language});
  Future<ListingDetail> createListing({
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId, // Made optional, moved to end
    int? subwayLineId, // Add subway line ID parameter
    String? moveInDate, // Add move-in date parameter
    bool? privateRoom, // Add private room parameter
    List<String>? photoPaths, // Optional photo paths to upload
  });

  Future<ListingDetail> updateListing({
    required int listingId,
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId, // Made optional, moved to end
    int? subwayLineId, // Add subway line ID parameter
    String? moveInDate, // Add move-in date parameter
    bool? privateRoom, // Add private room parameter
    List<String>? photoPaths, // Optional photo paths to upload
  });

  // New comprehensive search method
  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    int createdWithinDays = 30,
  });

  // Get listings for a specific user
  Future<PageableResponse<Listing>> getUserListings({
    int page = 1,
    int limit = 10,
    String? language,
  });

  // Get listings for a specific user by ID (admin)
  Future<PageableResponse<Listing>> getListingsByUserId({
    required int userId,
    int page = 1,
    int limit = 10,
    String? language,
  });

  // Toggle listing active status
  Future<bool> toggleListingActive(int listingId);

  // Delete a listing
  Future<bool> deleteListing(int listingId);

  // Upload photos for a listing
  Future<bool> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  });

  // Upload a single photo
  Future<bool> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  });

  // Delete a photo
  Future<bool> deletePhoto({required int listingId, required int photoId});

  // Set a photo as primary
  Future<bool> setPrimaryPhoto({required int listingId, required int photoId});

  // Feature a listing (move to top)
  Future<bool> featureListing(int listingId);

  // Toggle feature status of a listing
  Future<bool> toggleFeatureListing(int listingId, bool isCurrentlyFeatured);

  // Record a view when non-owner views a listing (auth required)
  Future<void> recordListingView(int listingId);

  // Get listings the user has viewed (auth required)
  Future<PageableResponse<Listing>> getViewedListings({
    int page = 1,
    int limit = 50,
  });

  // Get view count for owner (auth required)
  Future<int> getListingViewCount(int listingId);

  // Get views per day for owner (auth required)
  Future<List<Map<String, dynamic>>> getListingViewStatsByDay(
    int listingId, {
    int daysBack = 30,
  });
}

class ListingService implements IListingService {
  ListingService(this._apiClient, this._oauthApiClient);

  final IPublicApiClient _apiClient;
  final IOAuthApiClient _oauthApiClient;

  @override
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = 30,
  }) async {
    // Use provided language or fall back to current app language
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

      // Add listing type ID filter if provided
      if (listingTypeId != null) {
        queryParams["listingTypeId"] = listingTypeId;
      }

      // Add location ID filter if provided
      if (locationId != null && locationId > 0) {
        queryParams["locationId"] = locationId;
      }

      // Handle subway station filtering with transfer station logic
      final finalStationIds = <int>[];

      // Add single subway station ID if provided
      if (subwayStationId != null && subwayStationId > 0) {
        finalStationIds.add(subwayStationId);
      }

      // Add multiple subway station IDs if provided
      if (subwayStationIds != null && subwayStationIds.isNotEmpty) {
        finalStationIds.addAll(subwayStationIds);
      }

      // Expand with transfer stations if any station IDs are provided
      if (finalStationIds.isNotEmpty) {
        final expandedStationIds = MetroCache.expandWithTransferStations(
          finalStationIds,
        );
        // Use single subwayStationId for analytics when one station; otherwise subwayStationIds
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

      // Add subway line filter if provided
      if (subwayLineId != null && subwayLineId > 0) {
        queryParams["subwayLineId"] = subwayLineId;
      }

      // Add gender filter if provided (1 = male, 2 = female)
      if (gender != null) {
        queryParams["gender"] = gender;
      }

      // Add price filters if provided
      if (minPrice != null) {
        queryParams["minPrice"] = minPrice;
      }
      if (maxPrice != null) {
        queryParams["maxPrice"] = maxPrice;
      }

      logger.d("\x1B[32m=== LISTINGS API REQUEST DEBUG ===");
      logger.d("URL: /listings");
      logger.d("Query Parameters: $queryParams");
      logger.d("Page: $page");
      logger.d("Limit: $limit");
      logger.d("Is Active: $isActive");
      logger.d("Language: $currentLanguage");
      logger.d("Listing Type ID: $listingTypeId");
      logger.d("Location ID: $locationId");
      logger.d("Subway Line ID: $subwayLineId");
      logger.d("Subway Station ID: $subwayStationId");
      logger.d("Gender: $gender");
      logger.d("Min Price: $minPrice");
      logger.d("Max Price: $maxPrice");
      logger.d("=====================================\x1B[0m");

      final response = await _apiClient.get<Map<String, dynamic>>(
        "/listings",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      // Debug: Print response structure
      // logger.d('API Response: $response'); // Commented out to reduce console verbosity

      // Handle different possible response structures
      List<dynamic> listingsData;
      if (response["content"] != null) {
        listingsData = response["content"] as List<dynamic>;
      } else if (response["listings"] != null) {
        listingsData = response["listings"] as List<dynamic>;
      } else if (response["data"] != null) {
        listingsData = response["data"] as List<dynamic>;
      } else {
        // Fallback to empty list
        listingsData = <dynamic>[];
      }

      final listings =
          listingsData
              .map((item) => Listing.fromJson(item as Map<String, dynamic>))
              .toList();

      return PageableResponse<Listing>(
        data: listings,
        total: response["total"] as int? ?? listings.length,
        page: response["page"] as int? ?? page,
        limit: response["limit"] as int? ?? limit,
        totalPages: response["totalPages"] as int? ?? 1,
      );
    } catch (e) {
      logger.d("Error fetching listings: $e");
      rethrow;
    }
  }

  @override
  Future<ListingDetail> getListingDetail(
    int listingId, {
    String? language,
  }) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        "/listings/$listingId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {
          "language": currentLanguage,
          "_t":
              DateTime.now().millisecondsSinceEpoch
                  .toString(), // Force fresh data
        },
        headers: {
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0",
        },
      );
      return ListingDetail.fromJson(response);
    } catch (e) {
      logger.d("Error fetching listing detail: $e");
      rethrow;
    }
  }

  @override
  Future<List<Listing>> getListingsBySubwayStation(
    int subwayStationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  }) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        "/listings/search?subwayStationId=$subwayStationId&page=$page&limit=$limit&language=$currentLanguage&createdWithinDays=$createdWithinDays",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
      );

      // Handle different possible response structures
      List<dynamic> listingsData;
      if (response["content"] != null) {
        listingsData = response["content"] as List<dynamic>;
      } else if (response["listings"] != null) {
        listingsData = response["listings"] as List<dynamic>;
      } else if (response["data"] != null) {
        listingsData = response["data"] as List<dynamic>;
      } else {
        // Fallback to empty list
        listingsData = <dynamic>[];
      }

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
    int createdWithinDays = 30,
  }) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        "/listings?locationId=$locationId&page=$page&limit=$limit&language=$currentLanguage&createdWithinDays=$createdWithinDays",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
      );

      // Handle different possible response structures
      List<dynamic> listingsData;
      if (response["content"] != null) {
        listingsData = response["content"] as List<dynamic>;
      } else if (response["listings"] != null) {
        listingsData = response["listings"] as List<dynamic>;
      } else if (response["data"] != null) {
        listingsData = response["data"] as List<dynamic>;
      } else {
        // Fallback to empty list
        listingsData = <dynamic>[];
      }

      return listingsData
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.d("Error fetching listings by location: $e");
      rethrow;
    }
  }

  @override
  Future<ListingDetail> createListing({
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId, // Made optional, moved to end
    int? subwayLineId, // Add subway line ID parameter
    String? moveInDate, // Add move-in date parameter
    bool? privateRoom, // Add private room parameter
    List<String>? photoPaths, // Optional photo paths to upload
  }) async {
    try {
      // Get the authenticated user ID from the session
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception("User not authenticated. Please log in first.");
      }

      final request = CreateListingRequest(
        title: title,
        listingTypeId: listingTypeId,
        price: price,
        description: description,
        gender: gender,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId, // Add subway line ID
        locationId: locationId,
        amenityIds: amenityIds,
        moveInDate: moveInDate, // Add move-in date
        privateRoom: privateRoom, // Add private room
        userId:
            null, // Don't send userId in body - let server extract from JWT token
      );

      logger.d("=== CREATE LISTING REQUEST DEBUG ===");
      logger.d("Endpoint: /listings");
      logger.d("User ID from session: $userId");
      logger.d("Session Manager User ID: ${await SessionManager.getUserId()}");
      logger.d("Session Manager Email: ${await SessionManager.getUserEmail()}");
      logger.d(
        "Session Manager isAuthenticated: ${await SessionManager.isAuthenticated()}",
      );
      logger.d("Session Manager Token: ${await SessionManager.getToken()}");
      logger.d("Request object: $request");
      logger.d("Request type: ${request.runtimeType}");
      logger.d("Request JSON: ${request.toJson()}");
      logger.d("JSON type: ${request.toJson().runtimeType}");
      logger.d(
        "JSON keys: ${(request.toJson() as Map<String, dynamic>).keys.toList()}",
      );
      logger.d('Title: "$title" (length: ${title.length})');
      logger.d("Listing Type ID: $listingTypeId");
      logger.d("Price: $price");
      logger.d('Description: "$description" (length: ${description.length})');
      logger.d("Gender: $gender");
      logger.d("Location ID: $locationId");
      logger.d("Subway Station ID: $subwayStationId");
      logger.d("Subway Line ID: $subwayLineId");
      logger.d("Amenity IDs: $amenityIds (count: ${amenityIds.length})");
      logger.d("====================================");

      final response = await _oauthApiClient
          .post<Map<String, dynamic>, CreateListingRequest>(
            "/listings",
            (json) => json as Map<String, dynamic>,
            basePath: EnvironmentUtil.basePath,
            data: request,
          );

      logger.d("=== CREATE LISTING RESPONSE DEBUG ===");
      logger.d("Response type: ${response.runtimeType}");
      logger.d("Response keys: ${response.keys.toList()}");
      logger.d("Full response: $response");
      logger.d("====================================");

      // Check if the response indicates success
      if (response.containsKey("message") &&
          response["message"] == "Listing created successfully") {
        // Extract the created listing from the response
        if (response.containsKey("listing")) {
          logger.d("Parsing created listing from response...");
          final listingData = response["listing"] as Map<String, dynamic>;
          logger.d("Listing data keys: ${listingData.keys.toList()}");
          logger.d(
            'price_per_month from response: ${listingData['price_per_month']} (type: ${listingData['price_per_month'].runtimeType})',
          );
          logger.d(
            'gender from response: ${listingData['gender']} (type: ${listingData['gender'].runtimeType})',
          );

          final createdListing = ListingDetail.fromJson(
            listingData,
          );
          final listingId = createdListing.id;

          // Upload photos if provided
          if (photoPaths != null && photoPaths.isNotEmpty) {
            try {
              logger.d("=== UPLOADING PHOTOS FOR LISTING $listingId ===");
              logger.d("Photo count: ${photoPaths.length}");

              // Create isPrimary flags (first photo is primary)
              final isPrimaryFlags = List<bool>.generate(
                photoPaths.length,
                (index) => index == 0, // First photo is primary
              );

              // Upload all photos
              await uploadListingPhotos(
                listingId: listingId,
                photoPaths: photoPaths,
                isPrimaryFlags: isPrimaryFlags,
              );

              logger.d(
                "✅ All photos uploaded successfully for listing $listingId",
              );
            } catch (photoError) {
              logger.d("⚠️ Warning: Photos failed to upload: $photoError");
              logger.d(
                "⚠️ Listing was created successfully, but photos could not be uploaded",
              );
              // Don't fail the entire listing creation if photos fail
            }
          }

          return createdListing;
        } else {
          logger.d("No listing data in response, throwing error...");
          throw Exception("Response missing listing data");
        }
      } else {
        // Not a success response
        throw Exception(
          'Failed to create listing: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      logger.d("=== CREATE LISTING ERROR DEBUG ===");
      logger.d("Error type: ${e.runtimeType}");
      logger.d("Error message: $e");
      logger.d("Error toString: ${e.toString()}");

      // Check if it's a DioException for more details
      if (e.toString().contains("DioException")) {
        logger.d("DioException detected - checking response details");
        if (e.toString().contains("500")) {
          logger.d(
            "Server error (500) detected - this usually indicates a server-side issue",
          );
          logger.d("Possible causes:");
          logger.d("- Invalid data format sent to server");
          logger.d("- Server validation failed");
          logger.d("- Database constraint violation");
          logger.d("- Server configuration issue");
          logger.d("- Missing required fields on server side");
          logger.d("- Database connection problem");
        }

        // Try to extract more specific error information
        if (e.toString().contains("bad response")) {
          logger.d("Bad response detected - checking for response data");
        }
      }

      logger.d("====================================");
      rethrow;
    }
  }

  @override
  Future<ListingDetail> updateListing({
    required int listingId,
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId, // Made optional, moved to end
    int? subwayLineId, // Add subway line ID parameter
    String? moveInDate, // Add move-in date parameter
    bool? privateRoom, // Add private room parameter
    List<String>? photoPaths, // Optional photo paths to upload
  }) async {
    try {
      // Get the authenticated user ID from the session
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception("User not authenticated. Please log in first.");
      }

      final request = CreateListingRequest(
        title: title,
        listingTypeId: listingTypeId,
        price: price,
        description: description,
        gender: gender,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId, // Add subway line ID
        locationId: locationId,
        amenityIds: amenityIds,
        moveInDate: moveInDate, // Add move-in date
        privateRoom: privateRoom, // Add private room
        userId:
            null, // Don't send userId in body - let server extract from JWT token
      );

      logger.d("=== UPDATE LISTING REQUEST ===");
      logger.d("Method: PUT");
      logger.d("URL: {{baseUrl}}/listings/$listingId");
      logger.d("Listing ID: $listingId");
      logger.d("Request Parameters:");
      logger.d('  title: "$title" (type: ${title.runtimeType})');
      logger.d(
        "  listingTypeId: $listingTypeId (type: ${listingTypeId.runtimeType})",
      );
      logger.d("  price: $price (type: ${price.runtimeType})");
      logger.d(
        '  description: "$description" (type: ${description.runtimeType})',
      );
      logger.d(
        "  subwayStationId: $subwayStationId (type: ${subwayStationId.runtimeType})",
      );
      logger.d(
        "  subwayLineId: $subwayLineId (type: ${subwayLineId.runtimeType})",
      );
      logger.d("  locationId: $locationId (type: ${locationId.runtimeType})");
      logger.d(
        "  amenityIds: $amenityIds (type: ${amenityIds.runtimeType}, count: ${amenityIds.length})",
      );
      logger.d("Request JSON: ${request.toJson()}");
      logger.d("=============================");

      Map<String, dynamic> response;

      try {
        // Try PUT method first
        response = await _oauthApiClient
            .put<Map<String, dynamic>, CreateListingRequest>(
              "/listings/$listingId",
              (json) => json as Map<String, dynamic>,
              basePath: EnvironmentUtil.basePath,
              data: request,
            );
        logger.d("PUT request successful");
        logger.d("Response: $response");
        logger.d("Response type: ${response.runtimeType}");
      } catch (e) {
        logger.d("PUT method failed: $e");
        logger.d("Trying PATCH method...");
        // Fallback to PATCH method
        response = await _oauthApiClient
            .patch<Map<String, dynamic>, CreateListingRequest>(
              "/listings/$listingId",
              (json) => json as Map<String, dynamic>,
              basePath: EnvironmentUtil.basePath,
              data: request,
            );
        logger.d("PATCH request successful");
        logger.d("Response: $response");
        logger.d("Response type: ${response.runtimeType}");
      }

      logger.d("=== UPDATE LISTING RESPONSE ===");
      logger.d("Response type: ${response.runtimeType}");
      logger.d("Response keys: ${response.keys.toList()}");
      logger.d("Full response: $response");
      logger.d("==============================");

      // Check if the response indicates success
      if (response.containsKey("message") &&
          response["message"] == "Listing updated successfully") {
        // Extract the updated listing from the response
        if (response.containsKey("listing")) {
          logger.d("Parsing updated listing from response...");
          final listingData = response["listing"] as Map<String, dynamic>;
          logger.d("Listing data keys: ${listingData.keys.toList()}");
          logger.d(
            'price_per_month from response: ${listingData['price_per_month']} (type: ${listingData['price_per_month'].runtimeType})',
          );

          final updatedListing = ListingDetail.fromJson(
            listingData,
          );

          // Upload photos if provided
          if (photoPaths != null && photoPaths.isNotEmpty) {
            try {
              logger.d(
                "=== UPLOADING PHOTOS FOR UPDATED LISTING $listingId ===",
              );
              logger.d("Photo count: ${photoPaths.length}");

              // Create isPrimary flags (first photo is primary)
              final isPrimaryFlags = List<bool>.generate(
                photoPaths.length,
                (index) => index == 0, // First photo is primary
              );

              // Upload all photos
              await uploadListingPhotos(
                listingId: listingId,
                photoPaths: photoPaths,
                isPrimaryFlags: isPrimaryFlags,
              );

              logger.d(
                "✅ All photos uploaded successfully for updated listing $listingId",
              );
            } catch (photoError) {
              logger.d("⚠️ Warning: Photos failed to upload: $photoError");
              logger.d(
                "⚠️ Listing was updated successfully, but photos could not be uploaded",
              );
              // Don't fail the entire listing update if photos fail
            }
          }

          return updatedListing;
        } else {
          logger.d("No listing data in response, throwing error...");
          throw Exception("Response missing listing data");
        }
      } else {
        // Not a success response
        throw Exception(
          'Failed to update listing: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      logger.d("Error updating listing: $e");
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
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    int createdWithinDays = 30,
  }) async {
    // Use provided language or fall back to current app language
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

      // Add listing type ID filter if provided
      if (listingTypeId != null) {
        queryParams["listingTypeId"] = listingTypeId;
      }

      // Add location ID filter if provided
      if (locationId != null && locationId > 0) {
        queryParams["locationId"] = locationId;
      }

      // Handle subway station filtering with transfer station logic
      final finalStationIds = <int>[];

      // Add single subway station ID if provided
      if (subwayStationId != null && subwayStationId > 0) {
        finalStationIds.add(subwayStationId);
      }

      // Add multiple subway station IDs if provided
      if (subwayStationIds != null && subwayStationIds.isNotEmpty) {
        finalStationIds.addAll(subwayStationIds);
      }

      // Expand with transfer stations if any station IDs are provided
      if (finalStationIds.isNotEmpty) {
        final expandedStationIds = MetroCache.expandWithTransferStations(
          finalStationIds,
        );
        // Use single subwayStationId for analytics when one station; otherwise subwayStationIds
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

      // Add subway line filter if provided
      if (subwayLineId != null && subwayLineId > 0) {
        queryParams["subwayLineId"] = subwayLineId;
      }

      // Add gender filter if provided (1 = male, 2 = female)
      if (gender != null) {
        queryParams["gender"] = gender;
      }

      // Add price filters if provided
      if (minPrice != null) {
        queryParams["minPrice"] = minPrice;
      }
      if (maxPrice != null) {
        queryParams["maxPrice"] = maxPrice;
      }

      // Add private room filter if provided
      if (privateRoom != null) {
        queryParams["privateRoom"] = privateRoom;
      }

      logger.d("\x1B[33m=== SEARCH LISTINGS API REQUEST DEBUG ===");
      logger.d("URL: /listings/search");
      logger.d("Query Parameters: $queryParams");
      logger.d("Page: $page");
      logger.d("Limit: $limit");
      logger.d("Is Active: $isActive");
      logger.d("Language: $currentLanguage");
      logger.d("Listing Type ID: $listingTypeId");
      logger.d("Location ID: $locationId");
      logger.d("Subway Line ID: $subwayLineId");
      logger.d("Subway Station ID: $subwayStationId");
      logger.d("Gender: $gender");
      logger.d("Min Price: $minPrice");
      logger.d("Max Price: $maxPrice");
      logger.d("Private Room: $privateRoom");
      logger.d("Created Within Days: $createdWithinDays");
      logger.d("===============================================\x1B[0m");

      final response = await _apiClient.get<Map<String, dynamic>>(
        "/listings/search",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      // Handle different possible response structures
      List<dynamic> listingsData;
      if (response["content"] != null) {
        listingsData = response["content"] as List<dynamic>;
      } else if (response["listings"] != null) {
        listingsData = response["listings"] as List<dynamic>;
      } else if (response["data"] != null) {
        listingsData = response["data"] as List<dynamic>;
      } else {
        // Fallback to empty list
        listingsData = <dynamic>[];
      }

      final listings =
          listingsData
              .map((item) => Listing.fromJson(item as Map<String, dynamic>))
              .toList();

      return PageableResponse<Listing>(
        data: listings,
        total: response["total"] as int? ?? listings.length,
        page: response["page"] as int? ?? page,
        limit: response["limit"] as int? ?? limit,
        totalPages: response["totalPages"] as int? ?? 1,
      );
    } catch (e) {
      logger.d("Error searching listings: $e");
      rethrow;
    }
  }

  @override
  Future<PageableResponse<Listing>> getUserListings({
    int page = 1,
    int limit = 10,
    String? language,
  }) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      // Get the authenticated user ID from the session
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
      logger.d("User ID: $userId");
      logger.d("==========================================\x1B[0m");

      final response = await _oauthApiClient.get<dynamic>(
        "/listings/user/$userId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      // Handle different possible response structures
      List<dynamic> listingsData;

      // Check if the response is directly an array (as it seems to be)
      if (response is List) {
        listingsData = response;
      } else if (response is Map<String, dynamic>) {
        // Handle wrapped response structures
        if (response["content"] != null) {
          listingsData = response["content"] as List<dynamic>;
        } else if (response["listings"] != null) {
          listingsData = response["listings"] as List<dynamic>;
        } else if (response["data"] != null) {
          listingsData = response["data"] as List<dynamic>;
        } else {
          // Fallback to empty list
          listingsData = <dynamic>[];
        }
      } else {
        // Fallback to empty list for unexpected response types
        listingsData = <dynamic>[];
      }

      final listings =
          listingsData
              .map((item) => Listing.fromJson(item as Map<String, dynamic>))
              .toList();

      // Since the API returns an array directly, we need to create pagination metadata
      // For now, we'll assume it's a single page response
      return PageableResponse<Listing>(
        data: listings,
        total: listings.length,
        page: page,
        limit: limit,
        totalPages:
            1, // Since we don't have pagination metadata, assume single page
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
        if (response["content"] != null) {
          listingsData = response["content"] as List<dynamic>;
        } else if (response["listings"] != null) {
          listingsData = response["listings"] as List<dynamic>;
        } else if (response["data"] != null) {
          listingsData = response["data"] as List<dynamic>;
        } else {
          listingsData = <dynamic>[];
        }
      } else {
        listingsData = <dynamic>[];
      }

      final listings =
          listingsData
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
  Future<bool> toggleListingActive(int listingId) async {
    try {
      logger.d("=== DEACTIVATION REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Endpoint: /listings/$listingId/toggle-active");
      logger.d("  • Base Path: ${EnvironmentUtil.basePath}");
      logger.d(
        "  • Full URL: ${EnvironmentUtil.basePath}/listings/$listingId/toggle-active",
      );
      logger.d("  • Method: PUT (with POST fallback)");
      logger.d("  • Auth: Bearer token (automatic)");
      logger.d("=====================================");

      // Backend expects PATCH for toggle-active
      final response = await _oauthApiClient.patch<dynamic, _EmptyRequest>(
        "/listings/$listingId/toggle-active",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: _EmptyRequest(),
      );

      logger.d("=== DEACTIVATION RESPONSE ===");
      logger.d("📥 Response Details:");
      logger.d("  • Status: Success");
      logger.d("  • Response Type: ${response.runtimeType}");
      logger.d("  • Raw Response: $response");

      // Check if the response indicates success
      if (response is String) {
        // If it's a string response, check if it contains success indicators
        if (response.contains("✅") ||
            response.contains("success") ||
            response.contains("running")) {
          logger.d("  • Success: String response indicates success");
          return true;
        }
      } else if (response is Map<String, dynamic>) {
        // If it's a JSON response, check for success indicators
        if (response["message"] != null &&
            response["message"].toString().toLowerCase().contains(
              "successfully",
            )) {
          logger.d('  • Success: ${response['message']}');

          // Also check if the listing object exists and has updated is_active status
          if (response["listing"] != null &&
              response["listing"] is Map<String, dynamic>) {
            final listing = response["listing"] as Map<String, dynamic>;
            final isActive = listing["is_active"] as bool?;
            logger.d('  • Listing ID: ${listing['id']}');
            logger.d("  • Active Status: $isActive");
            logger.d('  • Updated At: ${listing['updated_at']}');
          }

          return true;
        } else if (response["success"] == true ||
            response["status"] == "success") {
          logger.d("  • Success: JSON response indicates success");
          return true;
        }
      }

      // If we get here, assume success (since the API responded)
      logger.d("  • Success: Assuming success based on API response");
      logger.d("=====================================");
      return true;
    } catch (e) {
      logger.d("❌ Error toggling listing active status: $e");
      rethrow;
    }
  }

  @override
  Future<bool> deleteListing(int listingId) async {
    try {
      logger.d("=== DELETE LISTING REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Endpoint: /listings/$listingId");
      logger.d("  • Base Path: ${EnvironmentUtil.basePath}");
      logger.d("  • Method: DELETE");
      logger.d("  • Auth: Bearer token (automatic)");
      logger.d("=====================================");

      // Delete the listing using DELETE method
      final response = await _oauthApiClient.delete<dynamic, _EmptyRequest>(
        "/listings/$listingId",
        (json) => json, // Accept any response type
        basePath: EnvironmentUtil.basePath,
        data: _EmptyRequest(),
      );

      logger.d("=== DELETE LISTING RESPONSE ===");
      logger.d("📥 Response Details:");
      logger.d("  • Status: Success");
      logger.d("  • Response Type: ${response.runtimeType}");
      logger.d("  • Response: $response");
      logger.d("=====================================");

      // Consider any response as success (including string responses)
      return true;
    } catch (e) {
      logger.d("❌ Error deleting listing: $e");
      rethrow;
    }
  }

  @override
  Future<bool> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  }) async {
    try {
      logger.d("=== UPLOAD PHOTO REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Photo Path: $photoPath");
      logger.d("  • Is Primary: $isPrimary");
      logger.d("  • Endpoint: /listings/$listingId/photos");
      logger.d("  • Base Path: ${EnvironmentUtil.basePath}");
      logger.d("=====================================");

      // Read the photo file and convert to base64
      final photoFile = File(photoPath);
      if (!photoFile.existsSync()) {
        throw Exception("Photo file does not exist: $photoPath");
      }

      final photoBytes = await photoFile.readAsBytes();
      final base64Image = base64Encode(photoBytes);
      final imageData = "data:image/jpeg;base64,$base64Image";

      logger.d("📁 Photo Details:");
      logger.d("  • File Size: ${photoBytes.length} bytes");
      logger.d("  • Base64 Length: ${base64Image.length} characters");
      logger.d("  • MIME Type: image/jpeg");

      // Create the request payload
      final requestData = _PhotoUploadRequest(
        imageData: imageData,
        isPrimary: isPrimary,
      );

      logger.d("📤 Request Payload:");
      logger.d("  • imageData: ${imageData.substring(0, 100)}...");
      logger.d("  • isPrimary: $isPrimary");

      // Upload the photo
      final response = await _oauthApiClient
          .post<Map<String, dynamic>, _PhotoUploadRequest>(
            "/listings/$listingId/photos",
            (json) => json as Map<String, dynamic>,
            basePath: EnvironmentUtil.basePath,
            data: requestData,
          );

      logger.d("=== UPLOAD PHOTO RESPONSE ===");
      logger.d("📥 Response Details:");
      logger.d("  • Status: Success");
      logger.d("  • Response: $response");
      logger.d("=====================================");

      return true;
    } catch (e) {
      logger.d("❌ Error uploading photo: $e");
      rethrow;
    }
  }

  @override
  Future<bool> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  }) async {
    try {
      logger.d("=== UPLOAD MULTIPLE PHOTOS REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Photo Count: ${photoPaths.length}");
      logger.d("  • Endpoint: /listings/$listingId/photos");
      logger.d("=====================================");

      // Upload photos one by one
      for (var i = 0; i < photoPaths.length; i++) {
        final photoPath = photoPaths[i];
        final isPrimary = isPrimaryFlags[i];

        logger.d("📸 Uploading photo ${i + 1}/${photoPaths.length}:");
        logger.d("  • Path: $photoPath");
        logger.d("  • Is Primary: $isPrimary");

        await uploadPhoto(
          listingId: listingId,
          photoPath: photoPath,
          isPrimary: isPrimary,
        );

        logger.d("✅ Photo ${i + 1} uploaded successfully");
      }

      logger.d("=== ALL PHOTOS UPLOADED SUCCESSFULLY ===");
      return true;
    } catch (e) {
      logger.d("❌ Error uploading multiple photos: $e");
      rethrow;
    }
  }

  @override
  Future<bool> deletePhoto({
    required int listingId,
    required int photoId,
  }) async {
    try {
      logger.d("=== DELETE PHOTO REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Photo ID: $photoId");
      logger.d("  • Endpoint: /listings/$listingId/photos/$photoId");
      logger.d("  • Method: DELETE");
      logger.d(
        "  • Full URL: ${EnvironmentUtil.basePath}/listings/$listingId/photos/$photoId",
      );
      logger.d("=====================================");

      // Delete the photo using DELETE method
      // Handle both string and JSON responses since the API might return different types
      logger.d(
        "🌐 Making DELETE request to: ${EnvironmentUtil.basePath}/listings/$listingId/photos/$photoId",
      );
      final response = await _oauthApiClient.delete<dynamic, _EmptyRequest>(
        "/listings/$listingId/photos/$photoId",
        (json) => json, // Accept any response type
        basePath: EnvironmentUtil.basePath,
        data: _EmptyRequest(),
      );

      logger.d("=== DELETE PHOTO RESPONSE ===");
      logger.d("📥 Response Details:");
      logger.d("  • Status: Success");
      logger.d("  • Response Type: ${response.runtimeType}");
      logger.d("  • Response: $response");
      logger.d("=====================================");

      // Consider any response as success (including string responses)
      return true;
    } catch (e) {
      logger.d("❌ Error deleting photo: $e");
      rethrow;
    }
  }

  @override
  Future<bool> setPrimaryPhoto({
    required int listingId,
    required int photoId,
  }) async {
    try {
      logger.d("=== SET PRIMARY PHOTO REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Photo ID: $photoId");
      logger.d("  • Endpoint: /listings/$listingId/photos/$photoId/primary");
      logger.d("  • Method: PATCH");
      logger.d(
        "  • Full URL: ${EnvironmentUtil.basePath}/listings/$listingId/photos/$photoId/primary",
      );
      logger.d("=====================================");

      // Set the photo as primary using PATCH method
      final response = await _oauthApiClient.patch<dynamic, _EmptyRequest>(
        "/listings/$listingId/photos/$photoId/primary",
        (json) => json, // Accept any response type
        basePath: EnvironmentUtil.basePath,
        data: _EmptyRequest(),
      );

      logger.d("=== SET PRIMARY PHOTO RESPONSE ===");
      logger.d("📥 Response Details:");
      logger.d("  • Status: Success");
      logger.d("  • Response Type: ${response.runtimeType}");
      logger.d("  • Response: $response");
      logger.d("=====================================");

      // Consider any response as success (including string responses)
      return true;
    } catch (e) {
      logger.d("❌ Error setting primary photo: $e");
      rethrow;
    }
  }

  @override
  Future<bool> featureListing(int listingId) async {
    try {
      logger.d("=== FEATURE LISTING REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Endpoint: /listings/$listingId/feature");
      logger.d("  • Base Path: ${EnvironmentUtil.basePath}");
      logger.d("  • Method: POST");
      logger.d("  • Auth: Bearer token (automatic)");
      logger.d("=====================================");

      // Feature the listing using POST method
      final response = await _oauthApiClient.post<dynamic, _EmptyRequest>(
        "/listings/$listingId/feature",
        (json) => json, // Accept any response type
        basePath: EnvironmentUtil.basePath,
        data: _EmptyRequest(),
      );

      logger.d("=== FEATURE LISTING RESPONSE ===");
      logger.d("📥 Response Details:");
      logger.d("  • Status: Success");
      logger.d("  • Response Type: ${response.runtimeType}");
      logger.d("  • Response: $response");
      logger.d("=====================================");

      // Consider any response as success (including string responses)
      return true;
    } catch (e) {
      logger.d("❌ Error featuring listing: $e");
      rethrow;
    }
  }

  @override
  Future<bool> toggleFeatureListing(
    int listingId,
    bool isCurrentlyFeatured,
  ) async {
    try {
      logger.d("=== TOGGLE FEATURE LISTING REQUEST ===");
      logger.d("📡 Request Details:");
      logger.d("  • Listing ID: $listingId");
      logger.d("  • Currently Featured: $isCurrentlyFeatured");
      logger.d('  • Action: ${isCurrentlyFeatured ? "UNFEATURE" : "FEATURE"}');
      logger.d("  • Endpoint: /listings/$listingId/feature");
      logger.d("  • Base Path: ${EnvironmentUtil.basePath}");
      logger.d('  • Method: ${isCurrentlyFeatured ? "DELETE" : "POST"}');
      logger.d("  • Auth: Bearer token (automatic)");
      logger.d("=====================================");

      if (isCurrentlyFeatured) {
        // Unfeature the listing using DELETE method
        final response = await _oauthApiClient.delete<dynamic, _EmptyRequest>(
          "/listings/$listingId/feature",
          (json) => json,
          basePath: EnvironmentUtil.basePath,
        );

        logger.d("=== UNFEATURE LISTING RESPONSE ===");
        logger.d("📥 Response Details:");
        logger.d("  • Status: Success");
        logger.d("  • Response Type: ${response.runtimeType}");
        logger.d("  • Response: $response");
        logger.d("=====================================");
      } else {
        // Feature the listing using POST method
        final response = await _oauthApiClient.post<dynamic, _EmptyRequest>(
          "/listings/$listingId/feature",
          (json) => json,
          basePath: EnvironmentUtil.basePath,
          data: _EmptyRequest(),
        );

        logger.d("=== FEATURE LISTING RESPONSE ===");
        logger.d("📥 Response Details:");
        logger.d("  • Status: Success");
        logger.d("  • Response Type: ${response.runtimeType}");
        logger.d("  • Response: $response");
        logger.d("=====================================");
      }

      // Consider any response as success
      return true;
    } catch (e) {
      logger.d("❌ Error toggling feature listing: $e");
      rethrow;
    }
  }

  @override
  Future<void> recordListingView(int listingId) async {
    try {
      await _oauthApiClient.post<dynamic, _EmptyRequest>(
        "/listings/$listingId/record-view",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: _EmptyRequest(),
      );
    } catch (e) {
      logger.d("Error recording listing view: $e");
      // Fire-and-forget - don't rethrow
    }
  }

  @override
  Future<PageableResponse<Listing>> getViewedListings({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/viewed-by-me?page=$page&limit=$limit",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
      );

      final listingsData = response["listings"];
      final list = listingsData is List
          ? (listingsData as List)
              .map((e) => Listing.fromJson(e as Map<String, dynamic>))
              .toList()
          : <Listing>[];

      final total = (response["total"] is num)
          ? (response["total"] as num).toInt()
          : list.length;
      final pageNum =
          (response["page"] is num) ? (response["page"] as num).toInt() : page;
      final totalPages = (response["totalPages"] is num)
          ? (response["totalPages"] as num).toInt()
          : 1;

      return PageableResponse<Listing>(
        data: list,
        total: total,
        page: pageNum,
        limit: limit,
        totalPages: totalPages,
      );
    } catch (e) {
      logger.d("Error fetching viewed listings: $e");
      rethrow;
    }
  }

  @override
  Future<int> getListingViewCount(int listingId) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/$listingId/view-count",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
      );
      final count = response["viewCount"];
      return (count is num) ? count.toInt() : 0;
    } catch (e) {
      logger.d("Error fetching listing view count: $e");
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getListingViewStatsByDay(
    int listingId, {
    int daysBack = 30,
  }) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/$listingId/view-stats?days=$daysBack",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
      );
      final stats = response["stats"];
      if (stats is! List) return [];
      return stats
          .map((e) => e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      logger.d("Error fetching listing view stats: $e");
      rethrow;
    }
  }
}
