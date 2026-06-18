import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart"
    show DescriptionTranslationRequest, EmptyListingRequest;
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

abstract class IListingDetailService {
  Future<ListingDetail> getListingDetail(int listingId, {String? language});

  /// Persists a translated description for [listingId] (requires auth).
  Future<void> saveDescriptionTranslation({
    required int listingId,
    required String targetLanguageCode,
    required String translatedText,
  });
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
  ListingDetailService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;
  static const Duration _viewCountCacheTtl = Duration(minutes: 1);
  static final Map<int, _CachedViewCount> _viewCountCache = {};
  static final Map<int, Future<int>> _viewCountInFlight = {};

  @override
  Future<ListingDetail> getListingDetail(
    int listingId, {
    String? language,
  }) async {
    final currentLanguage = language ?? LanguageState().currentLanguage;

    try {
      // Use the OAuth client so `optionalAuthenticateToken` on the server can
      // resolve the viewer (owners see their pending listings; admins see the
      // moderation queue). Anonymous sessions omit the header and behave like
      // the public client.
      final response = await _oauthApiClient.get<Map<String, dynamic>>(
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
      final detail = ListingDetail.fromJson(response);
      final rawGroupContext = response["group_context"];
      if (rawGroupContext is Map<String, dynamic>) {
        return detail.copyWith(
          groupContext: ListingGroupContext.fromJson(rawGroupContext),
        );
      }
      return detail;
    } catch (e) {
      logger.d("Error fetching listing detail: $e");
      rethrow;
    }
  }

  @override
  Future<void> saveDescriptionTranslation({
    required int listingId,
    required String targetLanguageCode,
    required String translatedText,
  }) async {
    await _oauthApiClient.post<dynamic, DescriptionTranslationRequest>(
      "/listings/$listingId/description-translations",
      (json) => json,
      basePath: EnvironmentUtil.basePath,
      data: DescriptionTranslationRequest(
        targetLanguageCode: targetLanguageCode,
        translatedText: translatedText,
      ),
    );
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
      _viewCountCache.remove(listingId);
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
    final cached = _viewCountCache[listingId];
    if (cached != null && !cached.isExpired) {
      return cached.count;
    }

    final inFlight = _viewCountInFlight[listingId];
    if (inFlight != null) {
      return inFlight;
    }

    final request = _fetchListingViewCount(listingId);
    _viewCountInFlight[listingId] = request;
    try {
      final count = await request;
      _viewCountCache[listingId] = _CachedViewCount(
        count: count,
        expiresAt: DateTime.now().add(_viewCountCacheTtl),
      );
      return count;
    } finally {
      _viewCountInFlight.remove(listingId);
    }
  }

  Future<int> _fetchListingViewCount(int listingId) async {
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

class _CachedViewCount {
  const _CachedViewCount({required this.count, required this.expiresAt});

  final int count;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
