import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing_duplicate_hint.dart";
import "package:uy_dosh/domain/models/listing.dart";

/// How a scraped (Telegram-ingested) listing was attributed to a poster.
enum TelegramListingGroupType {
  /// Grouped by a Telegram `@handle` (from the post text or the resolved author).
  telegram,

  /// No handle available — grouped by the contact phone number (digits only).
  phone,

  /// Neither a handle nor a phone could be identified — the shared bucket.
  unknown;

  static TelegramListingGroupType fromApi(String? value) {
    switch (value) {
      case "telegram":
        return TelegramListingGroupType.telegram;
      case "phone":
        return TelegramListingGroupType.phone;
      default:
        return TelegramListingGroupType.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case TelegramListingGroupType.telegram:
        return "telegram";
      case TelegramListingGroupType.phone:
        return "phone";
      case TelegramListingGroupType.unknown:
        return "unknown";
    }
  }
}

/// How the groups list is ordered. The `unknown` bucket is always pinned to the
/// bottom server-side regardless of the chosen sort.
enum TelegramListingGroupSort {
  /// Most listings first (default) — surfaces prolific posters / duplicates.
  count,

  /// Most recent activity first (latest scraped listing).
  recent,

  /// Handle / phone alphabetically (A→Z).
  name;

  String get apiValue {
    switch (this) {
      case TelegramListingGroupSort.count:
        return "count";
      case TelegramListingGroupSort.recent:
        return "recent";
      case TelegramListingGroupSort.name:
        return "name";
    }
  }
}

class TelegramListingGroup {
  TelegramListingGroup({
    required this.groupType,
    required this.groupValue,
    required this.listingCount,
    this.latestCreatedAt,
    this.earliestCreatedAt,
  });

  factory TelegramListingGroup.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw);
      }
      return null;
    }

    return TelegramListingGroup(
      groupType: TelegramListingGroupType.fromApi(json["groupType"] as String?),
      groupValue: json["groupValue"] as String? ?? "",
      listingCount: (json["listingCount"] as num?)?.toInt() ?? 0,
      latestCreatedAt: parseDate(json["latestCreatedAt"]),
      earliestCreatedAt: parseDate(json["earliestCreatedAt"]),
    );
  }

  final TelegramListingGroupType groupType;
  final String groupValue;
  final int listingCount;
  final DateTime? latestCreatedAt;
  final DateTime? earliestCreatedAt;

  bool get hasDuplicates => listingCount > 1;
}

class TelegramListingGroupsSummary {
  TelegramListingGroupsSummary({
    required this.scrapedTotal,
    required this.groupsTotal,
    required this.duplicateGroups,
    required this.ungroupedCount,
  });

  factory TelegramListingGroupsSummary.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return TelegramListingGroupsSummary(
      scrapedTotal: n(json["scrapedTotal"]),
      groupsTotal: n(json["groupsTotal"]),
      duplicateGroups: n(json["duplicateGroups"]),
      ungroupedCount: n(json["ungroupedCount"]),
    );
  }

  final int scrapedTotal;
  final int groupsTotal;
  final int duplicateGroups;
  final int ungroupedCount;
}

class TelegramListingGroupsResponse {
  TelegramListingGroupsResponse({
    required this.groups,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.summary,
  });

  factory TelegramListingGroupsResponse.fromJson(Map<String, dynamic> json) {
    final rawGroups = json["groups"] as List<dynamic>? ?? [];
    final summaryJson = json["summary"] as Map<String, dynamic>?;
    return TelegramListingGroupsResponse(
      groups: rawGroups
          .whereType<Map<String, dynamic>>()
          .map(TelegramListingGroup.fromJson)
          .toList(),
      total: (json["total"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages: (json["totalPages"] as num?)?.toInt() ?? 1,
      summary: summaryJson != null
          ? TelegramListingGroupsSummary.fromJson(summaryJson)
          : TelegramListingGroupsSummary(
              scrapedTotal: 0,
              groupsTotal: 0,
              duplicateGroups: 0,
              ungroupedCount: 0,
            ),
    );
  }

  final List<TelegramListingGroup> groups;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final TelegramListingGroupsSummary summary;
}

abstract class IAdminTelegramListingGroupsService {
  /// GET `/admin/telegram/listing-groups` — scraped listings grouped by poster.
  Future<TelegramListingGroupsResponse> getGroups({
    int page = 1,
    int limit = 20,
    TelegramListingGroupSort sort = TelegramListingGroupSort.count,
  });

  /// GET `/admin/telegram/listing-groups/listings` — listings within one group.
  Future<TelegramGroupListingsPage> getGroupListings({
    required TelegramListingGroupType groupType,
    required String groupValue,
    int page = 1,
    int limit = 20,
  });

  /// POST `/admin/telegram/listing-groups/merge` — collapse a set of duplicate
  /// listings into one, permanently deleting the rest.
  Future<TelegramGroupMergeResult> mergeListings({
    required List<int> listingIds,
    required int keepListingId,
  });
}

class TelegramGroupMergeResult {
  TelegramGroupMergeResult({required this.keptListingId, required this.deletedIds});

  factory TelegramGroupMergeResult.fromJson(Map<String, dynamic> json) {
    final rawDeleted = json["deletedIds"] as List<dynamic>? ?? [];
    return TelegramGroupMergeResult(
      keptListingId: ((json["keptListingId"] as num?) ?? 0).toInt(),
      deletedIds: rawDeleted.map((e) => (e as num).toInt()).toList(),
    );
  }

  final int keptListingId;
  final List<int> deletedIds;
}

class _MergeListingsRequest implements IJsonEncodable {
  _MergeListingsRequest({required this.listingIds, required this.keepListingId});

  final List<int> listingIds;
  final int keepListingId;

  @override
  Map<String, dynamic> toJson() => {
    "listingIds": listingIds,
    "keepListingId": keepListingId,
  };
}

class TelegramGroupListingsPage {
  TelegramGroupListingsPage({
    required this.listings,
    required this.duplicateHints,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<Listing> listings;
  final Map<int, ListingDuplicateHint?> duplicateHints;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

class AdminTelegramListingGroupsService
    implements IAdminTelegramListingGroupsService {
  AdminTelegramListingGroupsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<TelegramListingGroupsResponse> getGroups({
    int page = 1,
    int limit = 20,
    TelegramListingGroupSort sort = TelegramListingGroupSort.count,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/telegram/listing-groups",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit, "sort": sort.apiValue},
      );
      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected listing-groups response");
      }
      return TelegramListingGroupsResponse.fromJson(response);
    } catch (e) {
      logger.d("Error fetching telegram listing groups: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramGroupListingsPage> getGroupListings({
    required TelegramListingGroupType groupType,
    required String groupValue,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/telegram/listing-groups/listings",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {
          "groupType": groupType.apiValue,
          "groupValue": groupValue,
          "page": page,
          "limit": limit,
        },
      );
      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected listing-group listings response");
      }
      final rawList = response["listings"] as List<dynamic>? ?? [];
      final listings = <Listing>[];
      final duplicateHints = <int, ListingDuplicateHint?>{};
      for (final raw in rawList.whereType<Map<String, dynamic>>()) {
        final listing = Listing.fromJson(raw);
        listings.add(listing);
        duplicateHints[listing.id] = ListingDuplicateHint.tryParse(
          raw["duplicateHint"] ?? raw["duplicate_hint"],
        );
      }
      return TelegramGroupListingsPage(
        listings: listings,
        duplicateHints: duplicateHints,
        total: (response["total"] as num?)?.toInt() ?? listings.length,
        page: (response["page"] as num?)?.toInt() ?? page,
        limit: (response["limit"] as num?)?.toInt() ?? limit,
        totalPages: (response["totalPages"] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      logger.d("Error fetching telegram listing group listings: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramGroupMergeResult> mergeListings({
    required List<int> listingIds,
    required int keepListingId,
  }) async {
    try {
      final response = await _oauthApiClient
          .post<dynamic, _MergeListingsRequest>(
        "/admin/telegram/listing-groups/merge",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _MergeListingsRequest(
          listingIds: listingIds,
          keepListingId: keepListingId,
        ),
      );
      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected listing-group merge response");
      }
      return TelegramGroupMergeResult.fromJson(response);
    } catch (e) {
      logger.d("Error merging telegram listing group listings: $e");
      rethrow;
    }
  }
}
