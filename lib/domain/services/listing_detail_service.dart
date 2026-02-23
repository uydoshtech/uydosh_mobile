import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

abstract class IListingDetailService {
  Future<ListingDetail> getListingDetail(int listingId, {String? language});
  Future<void> recordListingView(int listingId);
  Future<PageableResponse<Listing>> getViewedListings({
    int page = 1,
    int limit = 50,
  });
  Future<int> getListingViewCount(int listingId);
  Future<List<Map<String, dynamic>>> getListingViewStatsByDay(
    int listingId, {
    int daysBack = 30,
  });
}

class ListingDetailService implements IListingDetailService {
  ListingDetailService(this._apiClient, this._oauthApiClient);

  final IPublicApiClient _apiClient;
  final IOAuthApiClient _oauthApiClient;

  @override
  Future<ListingDetail> getListingDetail(
    int listingId, {
    String? language,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        "/listings/$listingId",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {
          "language": currentLanguage,
          "_t": DateTime.now().millisecondsSinceEpoch.toString(),
        },
        headers: {
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0",
        },
      );
      return ListingDetail.fromJson(response);
    } catch (e) {
      logger.d("Error fetching listing detail: $e");
      rethrow;
    }
  }

  @override
  Future<void> recordListingView(int listingId) async {
    try {
      await _oauthApiClient.post<dynamic, EmptyListingRequest>(
        "/listings/$listingId/record-view",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
        data: EmptyListingRequest(),
      );
    } catch (e) {
      logger.d("Error recording listing view: $e");
      // Fire-and-forget - don't rethrow
    }
  }

  @override
  Future<PageableResponse<Listing>> getViewedListings({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/viewed-by-me?page=$page&limit=$limit",
        (json) => json,
        basePath: EnvironmentUtil.basePath,
      );

      final listingsData = response["listings"];
      final list = listingsData is List
          ? listingsData
              .map<Listing>((e) => Listing.fromJson(e as Map<String, dynamic>))
              .toList()
          : <Listing>[];

      final total = (response["total"] is num)
          ? (response["total"] as num).toInt()
          : list.length;
      final pageNum =
          (response["page"] is num) ? (response["page"] as num).toInt() : page;
      final totalPages = (response["totalPages"] is num)
          ? (response["totalPages"] as num).toInt()
          : 1;

      return PageableResponse<Listing>(
        data: list,
        total: total,
        page: pageNum,
        limit: limit,
        totalPages: totalPages,
      );
    } catch (e) {
      logger.d("Error fetching viewed listings: $e");
      rethrow;
    }
  }

  @override
  Future<int> getListingViewCount(int listingId) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/$listingId/view-count",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
      );
      final count = response["viewCount"];
      return (count is num) ? count.toInt() : 0;
    } catch (e) {
      logger.d("Error fetching listing view count: $e");
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getListingViewStatsByDay(
    int listingId, {
    int daysBack = 30,
  }) async {
    try {
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
        "/listings/$listingId/view-stats?days=$daysBack",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
      );
      final stats = response["stats"];
      if (stats is! List) return [];
      return stats
          .map((e) => e is Map<String, dynamic>
              ? e
              : Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      logger.d("Error fetching listing view stats: $e");
      rethrow;
    }
  }
}
