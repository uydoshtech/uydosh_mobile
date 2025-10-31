import 'package:uy_dosh/domain/models/university.dart';
import 'package:uy_dosh/base/api/client/public_api_client.dart';
import 'package:uy_dosh/base/logger/logger.dart';
import 'package:uy_dosh/base/cache/university_cache.dart';
import 'package:uy_dosh/presentation/widgets/language_switcher.dart';

abstract class IUniversityService {
  Future<List<University>> getUniversities();
  Future<void> refreshUniversities();
  Map<String, dynamic> getCacheStats();
}

class UniversityService implements IUniversityService {
  final IPublicApiClient _publicApiClient;

  UniversityService(this._publicApiClient);

  @override
  Future<List<University>> getUniversities() async {
    try {
      logger.d('=== UNIVERSITY SERVICE DEBUG ===');
      logger.d('Using university cache for data');

      // Check if cache needs refresh
      if (UniversityCache.shouldRefresh()) {
        logger.d('Cache needs refresh, initializing...');
        await UniversityCache.initialize();
      } else {
        logger.d('Cache is fresh, using existing data');
      }

      // Get universities from cache and sort by current language
      final currentLanguage = LanguageState().currentLanguage;
      final universities = UniversityCache.getUniversitiesSortedByLanguage(
        currentLanguage,
      );

      // Log cache statistics
      final stats = UniversityCache.getCacheStats();
      logger.d('Cache stats: $stats');

      logger.d(
        'Successfully loaded ${universities.length} University objects from cache',
      );
      logger.d('Universities sorted alphabetically by $currentLanguage names');
      logger.d(
        'First university: ${universities.isNotEmpty ? universities.first.name : "None"}',
      );
      logger.d(
        'Last university: ${universities.isNotEmpty ? universities.last.name : "None"}',
      );
      logger.d('=====================================');

      // Debug print for verification
      print(
        '🎓 UNIVERSITY SERVICE DEBUG: Returning ${universities.length} universities',
      );
      print('🎓 Language: $currentLanguage');
      if (universities.isNotEmpty) {
        print(
          '🎓 First university: ${universities.first.getLocalizedName(currentLanguage)}',
        );
        print(
          '🎓 Last university: ${universities.last.getLocalizedName(currentLanguage)}',
        );
      }

      return universities;
    } catch (error) {
      logger.d('=== UNIVERSITY SERVICE ERROR DEBUG ===');
      logger.d('Error loading universities from cache: $error');
      logger.d('Error type: ${error.runtimeType}');
      logger.d('Error stack trace: ${StackTrace.current}');
      logger.d('=====================================');
      rethrow;
    }
  }

  @override
  Future<void> refreshUniversities() async {
    try {
      logger.d('=== REFRESHING UNIVERSITIES ===');
      await UniversityCache.refreshCache();
      logger.d('Universities refreshed successfully');
    } catch (error) {
      logger.d('Error refreshing universities: $error');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> getCacheStats() {
    return UniversityCache.getCacheStats();
  }
}
