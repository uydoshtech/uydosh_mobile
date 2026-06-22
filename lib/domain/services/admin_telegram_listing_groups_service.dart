import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";

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
  });

  /// GET `/admin/telegram/listing-groups/listings` — listings within one group.
  Future<PageableResponse<Listing>> getGroupListings({
    required TelegramListingGroupType groupType,
    required String groupValue,
    int page = 1,
    int limit = 20,
  });
}

class AdminTelegramListingGroupsService
    implements IAdminTelegramListingGroupsService {
  AdminTelegramListingGroupsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<TelegramListingGroupsResponse> getGroups({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/telegram/listing-groups",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
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
  Future<PageableResponse<Listing>> getGroupListings({
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
      final listings = rawList
          .whereType<Map<String, dynamic>>()
          .map(Listing.fromJson)
          .toList();
      return PageableResponse<Listing>(
        data: listings,
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
}
