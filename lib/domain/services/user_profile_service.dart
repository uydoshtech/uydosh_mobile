import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/auth/create_profile_request.dart";
import "package:uy_dosh/domain/models/auth/update_profile_request.dart";
import "package:uy_dosh/domain/models/user_profile.dart";

abstract class IUserProfileService {
  Future<UserProfile> getUserProfile(int userId);
  Future<UserProfile> getCurrentUserProfile();
  Future<UserProfile> createProfile(CreateProfileRequest request);
  Future<UserProfile> updateProfile(UpdateProfileRequest request);
}

class UserProfileService implements IUserProfileService {

  UserProfileService(this._publicApiClient, this._oauthApiClient);
  final IPublicApiClient _publicApiClient;
  final IOAuthApiClient _oauthApiClient;

  @override
  Future<UserProfile> getUserProfile(int userId) async {
    try {
      final profile = await _publicApiClient.get<UserProfile>(
        "/profiles/$userId",
        (dynamic json) {
          return UserProfile.fromJson(json as Map<String, dynamic>);
        },
      );
      return profile;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    try {
      // Get the actual authenticated user ID from the session
      final currentUserId = await SessionManager.getUserId();

      if (currentUserId == null) {
        throw Exception("User not authenticated. Please log in first.");
      }

      logger.d("=== GETTING CURRENT USER PROFILE ===");
      logger.d("Authenticated user ID: $currentUserId");
      logger.d("=====================================");

      final profile = await _oauthApiClient.get<UserProfile>(
        "/profiles/$currentUserId",
        (dynamic json) {
          return UserProfile.fromJson(json as Map<String, dynamic>);
        },
      );
      return profile;
    } catch (error) {
      logger.d("=== ERROR GETTING CURRENT USER PROFILE ===");
      logger.d("Error: $error");
      logger.d("==========================================");
      rethrow;
    }
  }

  @override
  Future<UserProfile> createProfile(CreateProfileRequest request) async {
    try {
      // Debug: Log the API call details
      logger.d("=== API CALL DEBUG ===");
      logger.d("Endpoint: /profiles");
      logger.d("Request data: ${request.toJson()}");
      logger.d("Request type: ${request.runtimeType}");
      logger.d("Request JSON keys: ${request.toJson().keys.toList()}");
      logger.d("Request JSON values: ${request.toJson().values.toList()}");
      logger.d(
        'universityId specifically: ${request.toJson()['universityId']}',
      );
      logger.d("=====================");

      // First, try to get the raw response to see what the backend actually returns
      final rawResponse = await _oauthApiClient
          .post<Map<String, dynamic>, CreateProfileRequest>(
            "/profiles",
            (json) => json as Map<String, dynamic>,
            data: request,
          );

      logger.d("=== API RAW RESPONSE DEBUG ===");
      logger.d("Raw response received: ${rawResponse.toString()}");
      logger.d("Response type: ${rawResponse.runtimeType}");
      logger.d("Response keys: ${rawResponse.keys.toList()}");
      logger.d("==============================");

      // Log each field in the response for detailed debugging
      logger.d("=== DETAILED RESPONSE ANALYSIS ===");
      rawResponse.forEach((key, value) {
        logger.d('Field: "$key" = $value (type: ${value.runtimeType})');
        if (value is Map) {
          logger.d("  Sub-fields: ${value.keys.toList()}");
          value.forEach((subKey, subValue) {
            logger.d(
              '    Sub-field: "$subKey" = $subValue (type: ${subValue.runtimeType})',
            );
          });
        } else if (value is List) {
          logger.d("  List length: ${value.length}");
          if (value.isNotEmpty) {
            logger.d(
              "  First item: ${value.first} (type: ${value.first.runtimeType})",
            );
          }
        }
      });
      logger.d("=====================================");

      // Check if the response contains profile data directly
      if (rawResponse.containsKey("id") && rawResponse.containsKey("user_id")) {
        // Direct profile response
        logger.d("Direct profile response detected, parsing...");
        logger.d("Attempting to parse: ${rawResponse.toString()}");
        try {
          final profile = UserProfile.fromJson(rawResponse);
          logger.d(
            "✅ Profile parsed successfully: ID=${profile.id}, UserID=${profile.userId}",
          );
          return profile;
        } catch (e) {
          logger.d("❌ Failed to parse direct profile response: $e");
          logger.d("Raw data that failed: ${rawResponse.toString()}");
        }
      }

      // Check if the response contains profile data in a nested field
      if (rawResponse.containsKey("profile") &&
          rawResponse["profile"] is Map<String, dynamic>) {
        logger.d("Nested profile response detected, parsing...");
        final profileData = rawResponse["profile"] as Map<String, dynamic>;
        logger.d("Profile data to parse: ${profileData.toString()}");
        try {
          final profile = UserProfile.fromJson(profileData);
          logger.d(
            "✅ Profile parsed successfully from nested field: ID=${profile.id}, UserID=${profile.userId}",
          );
          return profile;
        } catch (e) {
          logger.d("❌ Failed to parse nested profile response: $e");
          logger.d("Nested data that failed: ${profileData.toString()}");
        }
      }

      // Check if the response contains profile data in a different field
      if (rawResponse.containsKey("data") &&
          rawResponse["data"] is Map<String, dynamic>) {
        logger.d("Data field profile response detected, parsing...");
        final profileData = rawResponse["data"] as Map<String, dynamic>;
        logger.d("Profile data to parse: ${profileData.toString()}");
        try {
          final profile = UserProfile.fromJson(profileData);
          logger.d(
            "✅ Profile parsed successfully from data field: ID=${profile.id}, UserID=${profile.userId}",
          );
          return profile;
        } catch (e) {
          logger.d("❌ Failed to parse data field profile response: $e");
          logger.d("Data field that failed: ${profileData.toString()}");
        }
      }

      // If we can't find profile data, try to fetch the profile using the user ID from the request
      logger.d(
        "No profile data found in response, fetching profile by user ID...",
      );
      final userId = request.userId;

      // Try to fetch the profile using the OAuth API client first (since we just created it)
      try {
        logger.d("Attempting to fetch profile using OAuth API client...");
        logger.d("Fetching from endpoint: /profiles/$userId");
        final profile = await _oauthApiClient.get<UserProfile>(
          "/profiles/$userId",
          (dynamic json) {
            logger.d(
              "OAuth API response for profile fetch: ${json.toString()}",
            );
            logger.d("Response type: ${json.runtimeType}");
            if (json is Map<String, dynamic>) {
              logger.d("Response keys: ${json.keys.toList()}");
            }
            return UserProfile.fromJson(json as Map<String, dynamic>);
          },
        );
        logger.d("✅ Profile fetched successfully using OAuth API client");
        logger.d(
          "Fetched profile: ID=${profile.id}, UserID=${profile.userId}, Name=${profile.name}",
        );
        return profile;
      } catch (e) {
        logger.d("❌ Failed to fetch profile using OAuth API client: $e");
        logger.d("Error type: ${e.runtimeType}");
        logger.d("Falling back to public API client...");
        // Fallback to public API client
        try {
          final profile = await getUserProfile(userId);
          logger.d("✅ Profile fetched successfully using public API client");
          logger.d(
            "Fetched profile: ID=${profile.id}, UserID=${profile.userId}, Name=${profile.name}",
          );
          return profile;
        } catch (fallbackError) {
          logger.d(
            "❌ Failed to fetch profile using public API client as well: $fallbackError",
          );
          logger.d(
            "Both OAuth and public API clients failed to fetch the profile",
          );
          rethrow;
        }
      }
    } catch (e) {
      logger.d("=== API ERROR DEBUG ===");
      logger.d("Error in createProfile: $e");
      logger.d("Error type: ${e.runtimeType}");
      logger.d("Error toString: ${e.toString()}");

      // Check if it's a DioException for more details
      if (e.toString().contains("DioException")) {
        logger.d("DioException detected - checking response details");
      }

      logger.d("=====================");
      throw Exception("Failed to create profile: $e");
    }
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    try {
      // Get the actual authenticated user ID from the session
      final currentUserId = await SessionManager.getUserId();

      if (currentUserId == null) {
        throw Exception("User not authenticated. Please log in first.");
      }

      logger.d("=== UPDATE PROFILE API CALL DEBUG ===");
      logger.d("Authenticated user ID: $currentUserId");
      logger.d("Request data: ${request.toJson()}");
      logger.d("Endpoint: /profiles/$currentUserId");
      logger.d("Request data: ${request.toJson()}");
      logger.d("Request type: ${request.runtimeType}");
      logger.d("=====================================");

      // For update operations, we might not get a UserProfile response
      // Let's try to handle the response more flexibly
      final response = await _oauthApiClient
          .put<Map<String, dynamic>, UpdateProfileRequest>(
            "/profiles/$currentUserId", // Update specific user's profile
            (json) => json as Map<String, dynamic>,
            data: request,
          );

      logger.d("=== UPDATE PROFILE API RESPONSE DEBUG ===");
      logger.d("Response received: ${response.toString()}");
      logger.d("Response type: ${response.runtimeType}");
      logger.d("Response keys: ${response.keys.toList()}");

      // Log each field in the response for detailed debugging
      logger.d("=== DETAILED RESPONSE ANALYSIS ===");
      response.forEach((key, value) {
        logger.d('Field: "$key" = $value (type: ${value.runtimeType})');
        if (value is Map) {
          logger.d("  Sub-fields: ${value.keys.toList()}");
          value.forEach((subKey, subValue) {
            logger.d(
              '    Sub-field: "$subKey" = $subValue (type: ${subValue.runtimeType})',
            );
          });
        } else if (value is List) {
          logger.d("  List length: ${value.length}");
          if (value.isNotEmpty) {
            logger.d(
              "  First item: ${value.first} (type: ${value.first.runtimeType})",
            );
          }
        }
      });
      logger.d("========================================");

      // If the response contains profile data, try to parse it
      if (response.containsKey("profile") &&
          response["profile"] is Map<String, dynamic>) {
        logger.d(
          "✅ Response contains profile data in nested field, parsing...",
        );
        try {
          final profileData = response["profile"] as Map<String, dynamic>;
          final profile = UserProfile.fromJson(profileData);
          logger.d(
            "✅ Profile parsed successfully from nested field: ID=${profile.id}, UserID=${profile.userId}",
          );
          return profile;
        } catch (e) {
          logger.d("❌ Failed to parse profile from nested field: $e");
          logger.d(
            'Profile data that failed: ${response['profile'].toString()}',
          );
        }
      } else if (response.containsKey("id")) {
        logger.d("✅ Response contains profile data directly, parsing...");
        try {
          final profile = UserProfile.fromJson(response);
          logger.d(
            "✅ Profile parsed successfully from direct response: ID=${profile.id}, UserID=${profile.userId}",
          );
          return profile;
        } catch (e) {
          logger.d("❌ Failed to parse profile from direct response: $e");
          logger.d("Response data that failed: ${response.toString()}");
        }
      }

      // If no profile data in response, fetch the updated profile
      logger.d("No profile data in response, fetching updated profile...");
      try {
        final updatedProfile = await getCurrentUserProfile();
        logger.d(
          "✅ Successfully fetched updated profile: ID=${updatedProfile.id}, UserID=${updatedProfile.userId}, Name=${updatedProfile.name}",
        );
        return updatedProfile;
      } catch (fetchError) {
        logger.d("❌ Failed to fetch updated profile: $fetchError");
        logger.d(
          "This suggests the update may have failed or the profile is not accessible",
        );
        throw Exception(
          "Profile update may have failed. Unable to fetch updated profile: $fetchError",
        );
      }
    } catch (e) {
      logger.d("=== UPDATE PROFILE API ERROR DEBUG ===");
      logger.d("Error in updateProfile: $e");
      logger.d("Error type: ${e.runtimeType}");
      logger.d("Error toString: ${e.toString()}");

      // Check if it's a DioException for more details
      if (e.toString().contains("DioException")) {
        logger.d("DioException detected - checking response details");
        if (e.toString().contains("statusCode")) {
          logger.d("Status code information found in error");
        }
      }

      logger.d("=====================================");
      throw Exception("Failed to update profile: $e");
    }
  }
}
