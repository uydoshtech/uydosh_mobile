import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

abstract class ILocationService {
  Future<List<Location>> getLocations({String? language});
}

class LocationService implements ILocationService {
  LocationService(this._apiClient);

  final IPublicApiClient _apiClient;

  @override
  Future<List<Location>> getLocations({String? language}) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

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
