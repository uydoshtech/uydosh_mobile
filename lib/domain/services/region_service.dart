import "package:injectable/injectable.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/cache/region_cache.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/region.dart";

abstract class IRegionService {
  Future<List<Region>> getRegions();
}

@injectable
class RegionService implements IRegionService {

  RegionService(this._publicApiClient);
  final IPublicApiClient _publicApiClient;

  @override
  Future<List<Region>> getRegions() async {
    try {
      logger.d("=== REGION SERVICE DEBUG ===");
      logger.d("Using region cache for data");

      // Initialize cache if not already done
      if (!RegionCache.isInitialized) {
        await RegionCache.initialize();
      }

      // Get regions from cache
      final regions = RegionCache.getAllRegions();

      logger.d(
        "Successfully loaded ${regions.length} Region objects from cache",
      );
      logger.d(
        'First region: ${regions.isNotEmpty ? regions.first.name : "None"}',
      );
      logger.d("=====================================");

      return regions;
    } catch (error) {
      logger.d("=== REGION SERVICE ERROR DEBUG ===");
      logger.d("Error loading regions from cache: $error");
      logger.d("Error type: ${error.runtimeType}");
      logger.d("Error stack trace: ${StackTrace.current}");
      logger.d("=====================================");
      rethrow;
    }
  }
}
