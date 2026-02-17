import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

class ListingCreationByDay {
  ListingCreationByDay({
    required this.date,
    required this.count,
    required this.listingIds,
  });

  factory ListingCreationByDay.fromJson(Map<String, dynamic> json) {
    final idsRaw = json["listingIds"] ?? json["listing_ids"];
    final listingIds = idsRaw is List
        ? idsRaw
            .map((e) => (e is num) ? e.toInt() : int.tryParse(e.toString()))
            .whereType<int>()
            .toList()
        : <int>[];
    return ListingCreationByDay(
      date: json["date"] as String? ?? "",
      count: (json["count"] as num?)?.toInt() ?? 0,
      listingIds: listingIds,
    );
  }

  final String date;
  final int count;
  final List<int> listingIds;
}

class ListingCreationSummary {
  ListingCreationSummary({
    required this.total,
    required this.today,
    required this.thisWeek,
  });

  factory ListingCreationSummary.fromJson(Map<String, dynamic> json) {
    return ListingCreationSummary(
      total: (json["total"] as num?)?.toInt() ?? 0,
      today: (json["today"] as num?)?.toInt() ?? 0,
      thisWeek: (json["thisWeek"] as num?)?.toInt() ?? 0,
    );
  }

  final int total;
  final int today;
  final int thisWeek;
}

class ListingCreationAnalyticsResponse {
  ListingCreationAnalyticsResponse({
    required this.byDay,
    required this.summary,
  });

  factory ListingCreationAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final byDayJson = json["byDay"] as List<dynamic>? ?? [];
    final summaryJson = json["summary"] as Map<String, dynamic>?;

    return ListingCreationAnalyticsResponse(
      byDay: byDayJson
          .map((e) => ListingCreationByDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: summaryJson != null
          ? ListingCreationSummary.fromJson(summaryJson)
          : ListingCreationSummary(total: 0, today: 0, thisWeek: 0),
    );
  }

  final List<ListingCreationByDay> byDay;
  final ListingCreationSummary summary;
}

abstract class IListingCreationAnalyticsService {
  Future<ListingCreationAnalyticsResponse> getListingCreationAnalytics({int? days});
}

class ListingCreationAnalyticsService implements IListingCreationAnalyticsService {
  ListingCreationAnalyticsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<ListingCreationAnalyticsResponse> getListingCreationAnalytics({int? days}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (days != null) {
        queryParams["days"] = days; // 0 = all time, >0 = last N days
      }

      final response = await _oauthApiClient.get<dynamic>(
        "/admin/listing-creation-analytics",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          "Listing creation analytics API returned unexpected format. "
          "Ensure the backend is deployed with the latest admin routes.",
        );
      }

      return ListingCreationAnalyticsResponse.fromJson(response);
    } catch (e) {
      logger.d("Error fetching listing creation analytics: $e");
      rethrow;
    }
  }
}
