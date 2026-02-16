import "package:injectable/injectable.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

abstract class ISubwayStationService {
  Future<List<SubwayStation>> getSubwayStations({String? language});
  Future<List<SubwayStation>> getSubwayStationsByLine(
    int line, {
    String? language,
  });
}

@injectable
class SubwayStationService implements ISubwayStationService {
  SubwayStationService(this._apiClient);

  final IPublicApiClient _apiClient;

  @override
  Future<List<SubwayStation>> getSubwayStations({String? language}) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final response = await _apiClient.get<List<dynamic>>(
        "/subway-stations",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"language": currentLanguage},
      );

      // Debug: Print response structure
      // logger.d('Subway Stations API Response: $response'); // Commented out to reduce console verbosity

      // Handle different possible response structures
      List<dynamic> stationsData;
      stationsData = response;
    
      final stations =
          stationsData
              .map(
                (item) => SubwayStation.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      // Remove duplicates and sort only by line, preserve server ordering within each line
      final uniqueStations = <int, SubwayStation>{};
      for (final station in stations) {
        uniqueStations[station.id] = station;
      }

      final sortedStations =
          uniqueStations.values.toList()..sort((a, b) {
            // Only sort by line, let server handle ordering within each line
            return a.line.compareTo(b.line);
          });

      return sortedStations;
    } catch (e) {
      logger.d("Error fetching subway stations: $e");
      rethrow;
    }
  }

  @override
  Future<List<SubwayStation>> getSubwayStationsByLine(
    int line, {
    String? language,
  }) async {
    // Use provided language or fall back to current app language
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final response = await _apiClient.get<List<dynamic>>(
        "/subway-stations/line/$line",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"language": currentLanguage},
      );

      // Debug: Print response structure
      // logger.d('Subway Stations By Line API Response: $response'); // Commented out to reduce console verbosity

      // Handle different possible response structures
      List<dynamic> stationsData;
      stationsData = response;
    
      final stations =
          stationsData
              .map(
                (item) => SubwayStation.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      // Server now returns stations sorted by ordinal, so we don't need to sort here
      // The server handles the ordering: ORDER BY ordinal ASC, name_ru ASC, name_en ASC, name_uz ASC
      return stations;
    } catch (e) {
      logger.d("Error fetching subway stations for line $line: $e");
      rethrow;
    }
  }
}
