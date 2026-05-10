import "dart:convert";
import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/create_listing_request.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

abstract class IListingCrudService {
  Future<ListingDetail> createListing({
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
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
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  });

  Future<bool> toggleListingActive(int listingId);
  Future<bool> deleteListing(int listingId);

  /// Upload all photos in [photoPaths] sequentially.
  /// Returns the server-assigned photo IDs in upload order so callers can
  /// match them back to local paths for a subsequent reorder call.
  Future<List<int>> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  });

  /// Upload a single photo. Returns the server-assigned photo ID (or -1 if
  /// the response was missing an id).
  Future<int> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  });
  Future<bool> deletePhoto({required int listingId, required int photoId});
  Future<bool> setPrimaryPhoto({required int listingId, required int photoId});
  Future<bool> reorderPhotos({
    required int listingId,
    required List<int> photoIds,
  });
  Future<void> uploadRoomScan({
    required int listingId,
    required String usdzFilePath,
    RoomScanMetrics? roomScanMetrics,
  });

  /// Backfills DB metrics for an existing USDZ when all four columns are still null.
  Future<void> patchRoomScanMetricsIfMissing({
    required int listingId,
    required RoomScanMetrics metrics,
  });
  Future<bool> featureListing(int listingId);
  Future<bool> toggleFeatureListing(int listingId, bool isCurrentlyFeatured);
}

class ListingCrudService implements IListingCrudService {
  ListingCrudService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<ListingDetail> createListing({
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  }) async {
    try {
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
        subwayLineId: subwayLineId,
        locationId: locationId,
        amenityIds: amenityIds,
        moveInDate: moveInDate,
        privateRoom: privateRoom,
        userId: null,
      );

      if (kDebugMode) {
        logger.d("=== CREATE LISTING REQUEST DEBUG ===");
        logger.d("Endpoint: /listings");
        logger.d("User ID from session: $userId");
        logger.d("Request JSON: ${request.toJson()}");
        logger.d("====================================");
      }

      final response = await _oauthApiClient
          .post<Map<String, dynamic>, CreateListingRequest>(
            "/listings",
            (json) => json as Map<String, dynamic>,
            basePath: EnvironmentUtil.basePath,
            data: request,
          );

      if (kDebugMode) {
        logger.d("=== CREATE LISTING RESPONSE DEBUG ===");
        logger.d("Response keys: ${response.keys.toList()}");
        logger.d("====================================");
      }

      if (response.containsKey("message") &&
          response["message"] == "Listing created successfully") {
        if (response.containsKey("listing")) {
          final listingData = response["listing"] as Map<String, dynamic>;
          final createdListing = ListingDetail.fromJson(listingData);
          final listingId = createdListing.id;

          if (photoPaths != null && photoPaths.isNotEmpty) {
            try {
              if (kDebugMode) {
                logger.d("=== UPLOADING PHOTOS FOR LISTING $listingId ===");
              }
              final isPrimaryFlags = List<bool>.generate(
                photoPaths.length,
                (index) => index == 0,
              );
              await uploadListingPhotos(
                listingId: listingId,
                photoPaths: photoPaths,
                isPrimaryFlags: isPrimaryFlags,
              );
              if (kDebugMode) {
                logger.d(
                  "✅ All photos uploaded successfully for listing $listingId",
                );
              }
            } catch (photoError) {
              if (kDebugMode) {
                logger.d("⚠️ Warning: Photos failed to upload: $photoError");
              }
            }
          }

          return createdListing;
        } else {
          throw Exception("Response missing listing data");
        }
      } else {
        throw Exception(
          'Failed to create listing: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.d("=== CREATE LISTING ERROR DEBUG ===");
        logger.d("Error: $e");
        logger.d("====================================");
      }
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
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  }) async {
    try {
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
        subwayLineId: subwayLineId,
        locationId: locationId,
        amenityIds: amenityIds,
        moveInDate: moveInDate,
        privateRoom: privateRoom,
        userId: null,
      );

      if (kDebugMode) {
        logger.d("=== UPDATE LISTING REQUEST ===");
        logger.d("URL: /listings/$listingId");
        logger.d("Request JSON: ${request.toJson()}");
        logger.d("=============================");
      }

      Map<String, dynamic> response;
      try {
        response = await _oauthApiClient
            .put<Map<String, dynamic>, CreateListingRequest>(
              "/listings/$listingId",
              (json) => json as Map<String, dynamic>,
              basePath: EnvironmentUtil.basePath,
              data: request,
            );
      } catch (e) {
        if (kDebugMode) {
          logger.d("PUT method failed: $e, trying PATCH...");
        }
        response = await _oauthApiClient
            .patch<Map<String, dynamic>, CreateListingRequest>(
              "/listings/$listingId",
              (json) => json as Map<String, dynamic>,
              basePath: EnvironmentUtil.basePath,
              data: request,
            );
      }

      if (kDebugMode) {
        logger.d("=== UPDATE LISTING RESPONSE ===");
        logger.d("Response keys: ${response.keys.toList()}");
        logger.d("==============================");
      }

      if (response.containsKey("message") &&
          response["message"] == "Listing updated successfully") {
        if (response.containsKey("listing")) {
          final listingData = response["listing"] as Map<String, dynamic>;
          final updatedListing = ListingDetail.fromJson(listingData);

          if (photoPaths != null && photoPaths.isNotEmpty) {
            try {
              if (kDebugMode) {
                logger.d(
                  "=== UPLOADING PHOTOS FOR UPDATED LISTING $listingId ===",
                );
              }
              final isPrimaryFlags = List<bool>.generate(
                photoPaths.length,
                (index) => index == 0,
              );
              await uploadListingPhotos(
                listingId: listingId,
                photoPaths: photoPaths,
                isPrimaryFlags: isPrimaryFlags,
              );
              if (kDebugMode) {
                logger.d(
                  "✅ All photos uploaded successfully for updated listing $listingId",
                );
              }
            } catch (photoError) {
              if (kDebugMode) {
                logger.d("⚠️ Warning: Photos failed to upload: $photoError");
              }
            }
          }

          return updatedListing;
        } else {
          throw Exception("Response missing listing data");
        }
      } else {
        throw Exception(
          'Failed to update listing: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.d("Error updating listing: $e");
      }
      rethrow;
    }
  }

  @override
  Future<bool> toggleListingActive(int listingId) async {
    try {
      if (kDebugMode) {
        logger.d("=== DEACTIVATION REQUEST ===");
        logger.d("Listing ID: $listingId");
        logger.d("Endpoint: /listings/$listingId/toggle-active");
        logger.d("=====================================");
      }

      await _oauthApiClient.patch<dynamic, EmptyListingRequest>(
        "/listings/$listingId/toggle-active",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
      );

      if (kDebugMode) {
        logger.d("=== DEACTIVATION RESPONSE ===");
        logger.d("Success");
        logger.d("=====================================");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error toggling listing active status: $e");
      }
      rethrow;
    }
  }

  @override
  Future<bool> deleteListing(int listingId) async {
    try {
      if (kDebugMode) {
        logger.d("=== DELETE LISTING REQUEST ===");
        logger.d("Listing ID: $listingId");
        logger.d("=====================================");
      }

      await _oauthApiClient.delete<dynamic, EmptyListingRequest>(
        "/listings/$listingId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
      );

      if (kDebugMode) {
        logger.d("=== DELETE LISTING RESPONSE ===");
        logger.d("Success");
        logger.d("=====================================");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error deleting listing: $e");
      }
      rethrow;
    }
  }

  @override
  Future<int> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  }) async {
    try {
      final photoFile = File(photoPath);
      if (!photoFile.existsSync()) {
        throw Exception("Photo file does not exist: $photoPath");
      }

      final photoBytes = await photoFile.readAsBytes();
      final base64Image = base64Encode(photoBytes);
      final imageData = "data:image/jpeg;base64,$base64Image";

      final requestData = PhotoUploadRequest(
        imageData: imageData,
        isPrimary: isPrimary,
      );

      final response = await _oauthApiClient
          .post<Map<String, dynamic>, PhotoUploadRequest>(
            "/listings/$listingId/photos",
            (json) => json as Map<String, dynamic>,
            basePath: EnvironmentUtil.basePath,
            data: requestData,
          );

      // Backend returns { message, photo: { id, ... } }.
      final photo = response["photo"];
      if (photo is Map<String, dynamic>) {
        final rawId = photo["id"];
        if (rawId is int) return rawId;
        if (rawId is num) return rawId.toInt();
      }
      return -1;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error uploading photo: $e");
      }
      rethrow;
    }
  }

  @override
  Future<List<int>> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  }) async {
    try {
      final ids = <int>[];
      for (var i = 0; i < photoPaths.length; i++) {
        final id = await uploadPhoto(
          listingId: listingId,
          photoPath: photoPaths[i],
          isPrimary: isPrimaryFlags[i],
        );
        ids.add(id);
      }
      return ids;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error uploading multiple photos: $e");
      }
      rethrow;
    }
  }

  @override
  Future<bool> deletePhoto({
    required int listingId,
    required int photoId,
  }) async {
    try {
      await _oauthApiClient.delete<dynamic, EmptyListingRequest>(
        "/listings/$listingId/photos/$photoId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error deleting photo: $e");
      }
      rethrow;
    }
  }

  @override
  Future<bool> setPrimaryPhoto({
    required int listingId,
    required int photoId,
  }) async {
    try {
      await _oauthApiClient.patch<dynamic, EmptyListingRequest>(
        "/listings/$listingId/photos/$photoId/primary",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error setting primary photo: $e");
      }
      rethrow;
    }
  }

  @override
  Future<bool> reorderPhotos({
    required int listingId,
    required List<int> photoIds,
  }) async {
    try {
      if (photoIds.isEmpty) return true;
      await _oauthApiClient.post<Map<String, dynamic>, PhotoReorderRequest>(
        "/listings/$listingId/photos/reorder",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
        data: PhotoReorderRequest(photoIds: photoIds),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error reordering photos: $e");
      }
      rethrow;
    }
  }

  @override
  Future<void> uploadRoomScan({
    required int listingId,
    required String usdzFilePath,
    RoomScanMetrics? roomScanMetrics,
  }) async {
    final file = File(usdzFilePath);
    if (!file.existsSync()) {
      throw Exception("USDZ file not found: $usdzFilePath");
    }
    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);
    final request = RoomScanUploadRequest(
      usdzData: b64,
      roomScanMetrics: roomScanMetrics,
    );
    await _oauthApiClient.post<Map<String, dynamic>, RoomScanUploadRequest>(
      "/listings/$listingId/room-scan",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: request,
      options: Options(
        sendTimeout: const Duration(minutes: 6),
        receiveTimeout: const Duration(minutes: 6),
      ),
    );
  }

  @override
  Future<void> patchRoomScanMetricsIfMissing({
    required int listingId,
    required RoomScanMetrics metrics,
  }) async {
    await _oauthApiClient.patch<dynamic, RoomScanMetricsPatchRequest>(
      "/listings/$listingId/room-scan-metrics",
      (json) => json,
      basePath: EnvironmentUtil.basePath,
      data: RoomScanMetricsPatchRequest(metrics: metrics),
    );
  }

  @override
  Future<bool> featureListing(int listingId) async {
    try {
      await _oauthApiClient.post<dynamic, EmptyListingRequest>(
        "/listings/$listingId/feature",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error featuring listing: $e");
      }
      rethrow;
    }
  }

  @override
  Future<bool> toggleFeatureListing(
    int listingId,
    bool isCurrentlyFeatured,
  ) async {
    try {
      if (isCurrentlyFeatured) {
        await _oauthApiClient.delete<dynamic, EmptyListingRequest>(
          "/listings/$listingId/feature",
          (json) => json,
          basePath: EnvironmentUtil.basePath,
        );
      } else {
        await _oauthApiClient.post<dynamic, EmptyListingRequest>(
          "/listings/$listingId/feature",
          (json) => json,
          basePath: EnvironmentUtil.basePath,
          data: EmptyListingRequest(),
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ Error toggling feature listing: $e");
      }
      rethrow;
    }
  }
}
