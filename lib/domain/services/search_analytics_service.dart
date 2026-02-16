import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

class SearchAnalyticsSummary {
  SearchAnalyticsSummary({
    required this.totalSearches,
    required this.searchesToday,
    required this.searchesThisWeek,
  });

  factory SearchAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return SearchAnalyticsSummary(
      totalSearches: (json["totalSearches"] as num?)?.toInt() ?? 0,
      searchesToday: (json["searchesToday"] as num?)?.toInt() ?? 0,
      searchesThisWeek: (json["searchesThisWeek"] as num?)?.toInt() ?? 0,
    );
  }

  final int totalSearches;
  final int searchesToday;
  final int searchesThisWeek;
}

class StationSearchCount {
  StationSearchCount({required this.stationId, required this.count});

  factory StationSearchCount.fromJson(Map<String, dynamic> json) {
    return StationSearchCount(
      stationId: (json["stationId"] as num?)?.toInt() ?? 0,
      count: (json["count"] as num?)?.toInt() ?? 0,
    );
  }

  final int stationId;
  final int count;
}

class LocationSearchCount {
  LocationSearchCount({required this.locationId, required this.count});

  factory LocationSearchCount.fromJson(Map<String, dynamic> json) {
    return LocationSearchCount(
      locationId: (json["locationId"] as num?)?.toInt() ?? 0,
      count: (json["count"] as num?)?.toInt() ?? 0,
    );
  }

  final int locationId;
  final int count;
}

class LineSearchCount {
  LineSearchCount({required this.lineId, required this.count});

  factory LineSearchCount.fromJson(Map<String, dynamic> json) {
    return LineSearchCount(
      lineId: (json["lineId"] as num?)?.toInt() ?? 0,
      count: (json["count"] as num?)?.toInt() ?? 0,
    );
  }

  final int lineId;
  final int count;
}

class SearchAnalyticsResponse {
  SearchAnalyticsResponse({
    required this.summary,
    required this.topStations,
    required this.topLocations,
    required this.topLines,
  });

  factory SearchAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final summaryJson = json["summary"] as Map<String, dynamic>?;
    final topStationsJson = json["topStations"] as List<dynamic>? ?? [];
    final topLocationsJson = json["topLocations"] as List<dynamic>? ?? [];
    final topLinesJson = json["topLines"] as List<dynamic>? ?? [];

    return SearchAnalyticsResponse(
      summary: summaryJson != null
          ? SearchAnalyticsSummary.fromJson(summaryJson)
          : SearchAnalyticsSummary(
              totalSearches: 0,
              searchesToday: 0,
              searchesThisWeek: 0,
            ),
      topStations: topStationsJson
          .map((e) => StationSearchCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLocations: topLocationsJson
          .map((e) => LocationSearchCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLines: topLinesJson
          .map((e) => LineSearchCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final SearchAnalyticsSummary summary;
  final List<StationSearchCount> topStations;
  final List<LocationSearchCount> topLocations;
  final List<LineSearchCount> topLines;
}

abstract class ISearchAnalyticsService {
  Future<SearchAnalyticsResponse> getSearchAnalytics({int? days});
}

class SearchAnalyticsService implements ISearchAnalyticsService {
  SearchAnalyticsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<SearchAnalyticsResponse> getSearchAnalytics({int? days}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (days != null) {
        queryParams["days"] = days; // 0 = all time, >0 = last N days
      }

      final response = await _oauthApiClient.get<dynamic>(
        "/admin/search-analytics",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          "Search analytics API returned unexpected format. "
          "Ensure the backend is deployed with the latest admin routes.",
        );
      }

      return SearchAnalyticsResponse.fromJson(response);
    } catch (e) {
      logger.d("Error fetching search analytics: $e");
      rethrow;
    }
  }
}
