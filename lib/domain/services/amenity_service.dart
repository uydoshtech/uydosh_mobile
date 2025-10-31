import 'package:uy_dosh/domain/models/amenity.dart';
import 'package:uy_dosh/base/api/client/public_api_client.dart';
import 'package:uy_dosh/base/logger/logger.dart';

abstract class IAmenityService {
  Future<List<Amenity>> getAmenities();
}

class AmenityService implements IAmenityService {
  final IPublicApiClient _apiClient;

  AmenityService(this._apiClient);

  @override
  Future<List<Amenity>> getAmenities() async {
    try {
      final amenities = await _apiClient.get<
        List<Amenity>
      >('/amenities/ordered', (dynamic json) {
        if (json is Map<String, dynamic> && json.containsKey('amenities')) {
          // Handle the actual API response structure
          final amenitiesList = json['amenities'] as List;
          final result =
              amenitiesList
                  .map((item) => Amenity.fromJson(item as Map<String, dynamic>))
                  .toList();

          return result;
        } else if (json is List) {
          // Fallback for direct array response
          final result =
              json
                  .map((item) => Amenity.fromJson(item as Map<String, dynamic>))
                  .toList();

          return result;
        } else if (json is Map<String, dynamic> && json.containsKey('data')) {
          // Fallback for data field structure
          final data = json['data'] as List;
          final result =
              data
                  .map((item) => Amenity.fromJson(item as Map<String, dynamic>))
                  .toList();

          return result;
        } else {
          logger.d('Unexpected JSON structure: $json'); // Debug print
          return <Amenity>[];
        }
      });

      return amenities;
    } catch (e) {
      rethrow;
    }
  }
}
