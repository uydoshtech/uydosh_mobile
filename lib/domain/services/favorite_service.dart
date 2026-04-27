import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/listing.dart";

// Simple request classes for API calls
class _AddToFavoritesRequest implements IJsonEncodable {

  _AddToFavoritesRequest(this.listingId);
  final int listingId;

  @override
  Map<String, dynamic> toJson() => {"listingId": listingId};
}

class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

abstract class IFavoriteService {
  Future<bool> addToFavorites(int listingId);
  Future<bool> removeFromFavorites(int listingId);
  Future<bool> toggleFavorite(int listingId);
  Future<List<Listing>> getUserFavorites({int page = 1, int limit = 10});
  Future<List<Listing>> getUserFavoriteListings(int userId);
  Future<bool> checkIfFavorited(int listingId);
  Future<int> getFavoriteCount(int listingId);
}

class FavoriteService implements IFavoriteService {

  FavoriteService(this._oauthApiClient);
  final IOAuthApiClient _oauthApiClient;

  // Track seen listing IDs across all calls to detect cross-call duplicates
  static final Set<int> _seenListingIds = <int>{};
  static int _totalCalls = 0;

  // Handle 401 unauthorized errors by clearing invalid session
  Future<void> _handleUnauthorized() async {
    logger.d("🚨 FavoriteService: Session expired, clearing local session...");
    await SessionManager.clearSession();
    logger.d(
      "✅ FavoriteService: Local session cleared. User needs to re-authenticate.",
    );
  }

  @override
  Future<bool> addToFavorites(int listingId) async {
    try {
      logger.d("🌐 FavoriteService: Adding listing $listingId to favorites...");

      await _oauthApiClient.post<Map<String, dynamic>, _AddToFavoritesRequest>(
        "/favorites",
        (data) => data as Map<String, dynamic>,
        data: _AddToFavoritesRequest(listingId),
      );

      logger.d("✅ FavoriteService: Successfully added to favorites");
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        logger.d("❌ FavoriteService: Unauthorized - session expired");
        await _handleUnauthorized();
        return false;
      }
      logger.d("❌ FavoriteService: Error adding to favorites: ${e.message}");
      return false;
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return false;
    }
  }

  @override
  Future<bool> removeFromFavorites(int listingId) async {
    try {
      logger.d(
        "🌐 FavoriteService: Removing listing $listingId from favorites...",
      );

      await _oauthApiClient.delete<Map<String, dynamic>, _EmptyRequest>(
        "/favorites/$listingId",
        (data) => data as Map<String, dynamic>,
      );

      logger.d("✅ FavoriteService: Successfully removed from favorites");
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        logger.d("❌ FavoriteService: Unauthorized - session expired");
        await _handleUnauthorized();
        return false;
      }
      logger.d(
        "❌ FavoriteService: Error removing from favorites: ${e.message}",
      );
      return false;
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return false;
    }
  }

  @override
  Future<bool> toggleFavorite(int listingId) async {
    try {
      logger.d(
        "🌐 FavoriteService: Toggling favorite status for listing $listingId...",
      );

      final response = await _oauthApiClient
          .put<Map<String, dynamic>, _EmptyRequest>(
            "/favorites/toggle/$listingId",
            (data) => data as Map<String, dynamic>,
          );

      logger.d("✅ FavoriteService: Successfully toggled favorite status");
      logger.d("📊 FavoriteService: Response: $response");
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        logger.d("❌ FavoriteService: Unauthorized - session expired");
        await _handleUnauthorized();
        return false;
      }
      logger.d("❌ FavoriteService: Error toggling favorite: ${e.message}");
      return false;
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return false;
    }
  }

  @override
  Future<List<Listing>> getUserFavorites({int page = 1, int limit = 10}) async {
    try {
      _totalCalls++;
      logger.d(
        "🌐 FavoriteService: Getting user favorites (page: $page, limit: $limit)...",
      );
      logger.d(
        "🔍 FavoriteService: Request details - Page: $page, Limit: $limit",
      );
      logger.d("🔍 FavoriteService: Total API calls made: $_totalCalls");
      logger.d(
        "🔍 FavoriteService: Previously seen listing IDs: ${_seenListingIds.length}",
      );

      // Check authentication token
      final token = await SessionManager.getToken();
      logger.d("🔑 FavoriteService: Auth token exists: ${token != null}");
      if (token != null) {
        logger.d("🔑 FavoriteService: Token length: ${token.length}");
      }

      // Use the main /favorites endpoint with pagination
      final endpoint = "/favorites?page=$page&limit=$limit";
      logger.d("🔍 FavoriteService: Using endpoint: $endpoint");

      dynamic response;
      try {
        response = await _oauthApiClient.get<dynamic>(endpoint, (data) {
          return data; // Don't force cast to Map<String, dynamic>
        });
      } catch (e) {
        logger.d("❌ FavoriteService: Endpoint $endpoint failed: $e");
        logger.d("❌ FavoriteService: Error type: ${e.runtimeType}");
        if (e is DioException) {
          logger.d("❌ FavoriteService: DioException details:");
          logger.d("  - Status code: ${e.response?.statusCode}");
          logger.d("  - Response data: ${e.response?.data}");
          logger.d("  - Response headers: ${e.response?.headers}");
          logger.d("  - Response status message: ${e.response?.statusMessage}");
          logger.d("  - Message: ${e.message}");
          logger.d("  - Error type: ${e.type}");
          logger.d("  - Request URL: ${e.requestOptions.uri}");
          logger.d("  - Request method: ${e.requestOptions.method}");
          logger.d("  - Request headers: ${e.requestOptions.headers}");
          logger.d("  - Request data: ${e.requestOptions.data}");
          logger.d(
            "  - Request query parameters: ${e.requestOptions.queryParameters}",
          );
          logger.d("  - Full request: ${e.requestOptions.toString()}");

          // Show the exact error response
          if (e.response?.data != null) {
            logger.d("🔍 FavoriteService: Error response details:");
            logger.d(
              "  - Error response type: ${e.response!.data.runtimeType}",
            );
            logger.d("  - Error response content: ${e.response!.data}");
            if (e.response!.data is Map) {
              logger.d(
                "  - Error response keys: ${(e.response!.data as Map).keys.toList()}",
              );
            }
          }
        }
        return [];
      }

      if (response == null) {
        logger.d("❌ FavoriteService: Response is null");
        return [];
      }

      // Handle different possible response structures
      var favoritesData = <dynamic>[]; // Initialize with empty list

      // First, check if response is directly a list (which seems to be the case based on backend)
      if (response is List) {
        favoritesData = response;
        logger.d("✅ FavoriteService: Found direct array response");
      } else if (response is Map<String, dynamic>) {
        // Handle map response with different possible field names
        final mapResponse = response;

        if (mapResponse["content"] != null) {
          favoritesData = mapResponse["content"] as List<dynamic>;
          logger.d('✅ FavoriteService: Found favorites in "content" field');
        } else if (mapResponse["favorites"] != null) {
          favoritesData = mapResponse["favorites"] as List<dynamic>;

          // Debug: Show first few items to check for duplicates
          if (favoritesData.isNotEmpty) {
            if (favoritesData.length > 1) {
              // Debug log removed
            }
            if (favoritesData.length > 2) {
              logger.d(
                "🔍 FavoriteService: Third favorite item: ${favoritesData[2]}",
              );
            }
          }
        } else if (mapResponse["listings"] != null) {
          favoritesData = mapResponse["listings"] as List<dynamic>;
          logger.d('✅ FavoriteService: Found favorites in "listings" field');
        } else if (mapResponse["result"] != null) {
          // Check if backend returns data in 'result' field
          final result = mapResponse["result"];
          if (result is List) {
            favoritesData = result;
            logger.d('✅ FavoriteService: Found favorites in "result" field');
          } else {
            logger.d(
              '⚠️ FavoriteService: "result" field is not a list: $result',
            );
          }
        } else if (mapResponse["items"] != null) {
          // Check if backend returns data in 'items' field (common pagination field)
          final items = mapResponse["items"];
          if (items is List) {
            favoritesData = items;
            logger.d('✅ FavoriteService: Found favorites in "items" field');
          } else {
            logger.d('⚠️ FavoriteService: "items" field is not a list: $items');
          }
        } else if (mapResponse["data"] != null) {
          // Check if backend returns data in 'data' field
          final data = mapResponse["data"];
          if (data is List) {
            favoritesData = data;
            logger.d('✅ FavoriteService: Found favorites in "data" field');
          } else {
            logger.d('⚠️ FavoriteService: "data" field is not a list: $data');
          }
        } else if (mapResponse["page"] != null ||
            mapResponse["total"] != null ||
            mapResponse["totalPages"] != null) {
          // This looks like a paginated response, let's check for common pagination field names
          logger.d("🔍 FavoriteService: Response appears to be paginated");

          // Try to find the actual data in common pagination field names
          final possibleDataFields = [
            "content",
            "items",
            "listings",
            "favorites",
            "data",
            "results",
          ];
          var foundData = false;

          for (final fieldName in possibleDataFields) {
            if (mapResponse[fieldName] != null) {
              final fieldValue = mapResponse[fieldName];
              if (fieldValue is List) {
                favoritesData = fieldValue;
                logger.d(
                  '✅ FavoriteService: Found favorites in paginated "$fieldName" field',
                );
                foundData = true;
                break;
              }
            }
          }

          if (!foundData) {
            logger.d(
              "⚠️ FavoriteService: Paginated response but no data field found",
            );
          }
        } else {
          // Check if this might be a paginated response without standard pagination fields
          logger.d(
            "🔍 FavoriteService: Checking for non-standard pagination fields...",
          );
          final allKeys = mapResponse.keys.toList();
          logger.d("🔍 FavoriteService: All available keys: $allKeys");

          // Look for any field that might contain the data
          for (final key in allKeys) {
            final value = mapResponse[key];
            if (value is List) {
              logger.d(
                '🔍 FavoriteService: Found list in field "$key" with ${value.length} items',
              );
              if (value.isNotEmpty && value.first is Map) {
                final firstItem = value.first as Map;
                logger.d(
                  '🔍 FavoriteService: First item in "$key" has keys: ${firstItem.keys.toList()}',
                );
              }
            }
          }
        }
      } else {
        // Fallback to empty list
        logger.d(
          "⚠️ FavoriteService: Unexpected response structure, no favorites found",
        );
        logger.d("⚠️ FavoriteService: Response type: ${response.runtimeType}");
      }

      if (favoritesData.isNotEmpty) {
        try {
          final favorites =
              favoritesData
                  .map((data) {
                    if (data == null) {
                      logger.d("⚠️ FavoriteService: Skipping null data item");
                      return null;
                    }

                    // Check if this is a favorite object with nested listing data
                    if (data is Map<String, dynamic> &&
                        data["listing"] != null) {
                      final listingData =
                          data["listing"] as Map<String, dynamic>;
                      try {
                        final listing = Listing.fromJson(listingData);
                        return listing;
                      } catch (parseError) {
                        logger.d(
                          "❌ FavoriteService: Failed to parse listing data: $parseError",
                        );
                        return null;
                      }
                    } else {
                      // Direct listing data
                      try {
                        final listing = Listing.fromJson(
                          data as Map<String, dynamic>,
                        );
                        return listing;
                      } catch (parseError) {
                        logger.d(
                          "❌ FavoriteService: Failed to parse direct listing data: $parseError",
                        );
                        return null;
                      }
                    }
                  })
                  .whereType<Listing>()
                  .toList();

          // Remove duplicates based on listing ID
          final uniqueFavorites = <Listing>[];
          final seenIds = <int>{};

          for (final favorite in favorites) {
            if (!seenIds.contains(favorite.id)) {
              seenIds.add(favorite.id);
              uniqueFavorites.add(favorite);

              // Track globally across all API calls
              if (!_seenListingIds.contains(favorite.id)) {
                _seenListingIds.add(favorite.id);
              }
            } else {
              logger.d(
                "⚠️ FavoriteService: Duplicate listing ID ${favorite.id} found within this response, skipping",
              );
            }
          }

          return uniqueFavorites;
        } catch (parseError) {
          logger.d(
            "❌ FavoriteService: Error parsing favorites data: $parseError",
          );
          logger.d(
            '❌ FavoriteService: First data item: ${favoritesData.isNotEmpty ? favoritesData.first : 'empty'}',
          );
          return [];
        }
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        logger.d("❌ FavoriteService: Unauthorized - session expired");
        await _handleUnauthorized();
        return [];
      }
      logger.d("❌ FavoriteService: Error getting favorites: ${e.message}");
      logger.d("❌ FavoriteService: Response status: ${e.response?.statusCode}");
      logger.d("❌ FavoriteService: Response data: ${e.response?.data}");
      return [];
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return [];
    }
  }

  @override
  Future<List<Listing>> getUserFavoriteListings(int userId) async {
    try {
      logger.d(
        "🌐 FavoriteService: Getting favorite listings for user $userId...",
      );

      final response = await _oauthApiClient.get<List<dynamic>>(
        "/listings/user/$userId",
        (data) => data as List<dynamic>,
      );

      final favorites = response.map((data) => Listing.fromJson(data)).toList();
      logger.d(
        "✅ FavoriteService: Successfully loaded ${favorites.length} favorite listings",
      );
      return favorites;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        logger.d("❌ FavoriteService: Unauthorized - session expired");
        await _handleUnauthorized();
        return [];
      }
      logger.d(
        "❌ FavoriteService: Error getting favorite listings: ${e.message}",
      );
      return [];
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return [];
    }
  }

  @override
  Future<bool> checkIfFavorited(int listingId) async {
    try {
      logger.d(
        "🌐 FavoriteService: Checking if listing $listingId is favorited...",
      );

      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/favorites/check/$listingId",
        (data) => data as Map<String, dynamic>,
      );

      if (response["isFavorited"] != null) {
        final isFavorited = response["isFavorited"] as bool;
        return isFavorited;
      }

      logger.d("✅ FavoriteService: Could not determine favorite status");
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        logger.d("❌ FavoriteService: Unauthorized - session expired");
        await _handleUnauthorized();
        return false;
      }
      logger.d(
        "❌ FavoriteService: Error checking favorite status: ${e.message}",
      );
      return false;
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return false;
    }
  }

  @override
  Future<int> getFavoriteCount(int listingId) async {
    try {
      logger.d(
        "🌐 FavoriteService: Getting favorite count for listing $listingId...",
      );

      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/favorites/count/$listingId",
        (data) => data as Map<String, dynamic>,
      );

      if (response["favoriteCount"] != null) {
        final count = response["favoriteCount"] as int;
        logger.d("✅ FavoriteService: Listing $listingId has $count favorites");
        return count;
      }

      logger.d("✅ FavoriteService: Could not get favorite count");
      return 0;
    } on DioException catch (e) {
      logger.d("❌ FavoriteService: Error getting favorite count: ${e.message}");
      return 0;
    } catch (e) {
      logger.d("❌ FavoriteService: Unexpected error: $e");
      return 0;
    }
  }
}
