import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/location.dart";

abstract class ILocationService {
  Future<List<Location>> getLocations({String? language});
}

class LocationService implements ILocationService {
  LocationService();

  @override
  Future<List<Location>> getLocations({String? language}) async {
    try {
      // Use the cache instead of making API calls
      final locations = LocationCache.getAllLocations();

      return locations;
    } catch (e) {
      logger.d("Error fetching locations from cache: $e");
      rethrow;
    }
  }
}
