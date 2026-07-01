import "package:uy_dosh/domain/models/listing_duplicate_hint.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

class PendingModerationSummary {
  PendingModerationSummary({
    required this.pendingTotal,
    required this.pendingSubmittedToday,
    required this.oldestWaitingDays,
  });

  factory PendingModerationSummary.fromJson(Map<String, dynamic> json) {
    final oldest = json["oldestWaitingDays"] ?? json["oldest_waiting_days"];
    return PendingModerationSummary(
      pendingTotal:
          ((json["pendingTotal"] ?? json["pending_total"]) as num?)?.toInt() ??
              0,
      pendingSubmittedToday:
          ((json["pendingSubmittedToday"] ?? json["pending_submitted_today"])
                  as num?)
              ?.toInt() ??
          0,
      oldestWaitingDays: oldest is num ? oldest.toInt() : int.tryParse("$oldest"),
    );
  }

  final int pendingTotal;
  final int pendingSubmittedToday;
  final int? oldestWaitingDays;
}

class PendingModerationListing {
  PendingModerationListing({
    required this.id,
    required this.userId,
    required this.title,
    required this.price,
    required this.createdAt,
    this.userEmail,
    this.userName,
    this.userAvatarUrl,
    this.listingTypeLabel,
    this.duplicateHint,
  });

  factory PendingModerationListing.fromJson(Map<String, dynamic> json) {
    final user = json["user"];
    String? email;
    String? name;
    String? avatarUrl;
    if (user is Map<String, dynamic>) {
      email = user["email"] as String?;
      final profile = user["profile"];
      if (profile is Map<String, dynamic>) {
        name = profile["name"] as String?;
        avatarUrl = profile["avatar_url"] as String? ??
            profile["avatarUrl"] as String?;
      }
    }
    final lt = json["listing_type"];
    String? typeLabel;
    if (lt is Map<String, dynamic>) {
      typeLabel = (lt["name_en"] as String?) ??
          (lt["name_ru"] as String?) ??
          (lt["name_uz"] as String?);
    }
    final created =
        json["created_at"] as String? ?? json["createdAt"] as String? ?? "";
    return PendingModerationListing(
      id: (json["id"] as num?)?.toInt() ?? 0,
      userId: (json["user_id"] ?? json["userId"] as num?)?.toInt() ?? 0,
      title: json["title"] as String? ?? "",
      price: (json["price"] as num?)?.toInt() ?? 0,
      createdAt: created,
      userEmail: email,
      userName: name,
      userAvatarUrl: avatarUrl,
      listingTypeLabel: typeLabel,
      duplicateHint: ListingDuplicateHint.tryParse(
        json["duplicateHint"] ?? json["duplicate_hint"],
      ),
    );
  }

  final int id;
  final int userId;
  final String title;
  final int price;
  final String createdAt;
  final String? userEmail;
  final String? userName;
  final String? userAvatarUrl;
  final String? listingTypeLabel;
  final ListingDuplicateHint? duplicateHint;
}

class PendingModerationQueueResponse {
  PendingModerationQueueResponse({
    required this.listings,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.summary,
  });

  factory PendingModerationQueueResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json["listings"] as List<dynamic>? ?? [];
    final summaryJson = json["summary"] as Map<String, dynamic>?;
    return PendingModerationQueueResponse(
      listings: rawList
          .map(
            (e) => PendingModerationListing.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      total: (json["total"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages:
          (json["totalPages"] ?? json["total_pages"] as num?)?.toInt() ?? 1,
      summary: summaryJson != null
          ? PendingModerationSummary.fromJson(summaryJson)
          : PendingModerationSummary(
              pendingTotal: 0,
              pendingSubmittedToday: 0,
              oldestWaitingDays: null,
            ),
    );
  }

  final List<PendingModerationListing> listings;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final PendingModerationSummary summary;
}

class _SetListingModerationBody implements IJsonEncodable {
  _SetListingModerationBody({required this.moderationStatus});
  final String moderationStatus;

  @override
  Map<String, dynamic> toJson() => {"moderation_status": moderationStatus};
}

abstract class IListingModerationAdminService {
  Future<PendingModerationQueueResponse> getPendingQueue({
    int page = 1,
    int limit = 20,
  });

  Future<void> approveListing(int listingId);
}

class ListingModerationAdminService implements IListingModerationAdminService {
  ListingModerationAdminService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<PendingModerationQueueResponse> getPendingQueue({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/listings/pending-moderation",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected pending-moderation response");
      }

      return PendingModerationQueueResponse.fromJson(response);
    } catch (e) {
      logger.d("Error fetching pending moderation queue: $e");
      rethrow;
    }
  }

  @override
  Future<void> approveListing(int listingId) async {
    await _oauthApiClient.patch<dynamic, _SetListingModerationBody>(
      "/admin/listings/$listingId/moderation",
      (data) => data,
      basePath: EnvironmentUtil.basePath,
      data: _SetListingModerationBody(moderationStatus: "approved"),
    );
  }
}
