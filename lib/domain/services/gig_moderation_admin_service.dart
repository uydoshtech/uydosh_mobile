import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/services/listing_moderation_admin_service.dart";

class PendingModerationGigOffer {
  PendingModerationGigOffer({
    required this.id,
    required this.providerUserId,
    required this.title,
    required this.createdAt,
    this.price,
    this.pricingType,
    this.currencyCode,
    this.providerName,
    this.categoryLabel,
  });

  factory PendingModerationGigOffer.fromJson(Map<String, dynamic> json) {
    final provider = json["provider"];
    String? providerName;
    if (provider is Map<String, dynamic>) {
      final profile = provider["profile"];
      if (profile is Map<String, dynamic>) {
        providerName = profile["name"] as String?;
      }
    }
    final cat = json["category"];
    String? categoryLabel;
    if (cat is Map<String, dynamic>) {
      categoryLabel = (cat["name_en"] as String?) ??
          (cat["name_ru"] as String?) ??
          (cat["name_uz"] as String?);
    }
    final priceRaw = json["price"];
    final created =
        json["created_at"] as String? ?? json["createdAt"] as String? ?? "";
    return PendingModerationGigOffer(
      id: (json["id"] as num?)?.toInt() ?? 0,
      providerUserId:
          ((json["provider_user_id"] ?? json["providerUserId"]) as num?)
                  ?.toInt() ??
              0,
      title: json["title"] as String? ?? "",
      createdAt: created,
      price: priceRaw is num ? priceRaw.toDouble() : double.tryParse("$priceRaw"),
      pricingType: json["pricing_type"] as String? ?? json["pricingType"] as String?,
      currencyCode:
          json["currency_code"] as String? ?? json["currencyCode"] as String?,
      providerName: providerName,
      categoryLabel: categoryLabel,
    );
  }

  final int id;
  final int providerUserId;
  final String title;
  final String createdAt;
  final double? price;
  final String? pricingType;
  final String? currencyCode;
  final String? providerName;
  final String? categoryLabel;
}

class PendingModerationGigRequestRow {
  PendingModerationGigRequestRow({
    required this.id,
    required this.clientUserId,
    required this.title,
    required this.createdAt,
    this.budgetAmount,
    this.budgetType,
    this.currencyCode,
    this.clientName,
    this.categoryLabel,
  });

  factory PendingModerationGigRequestRow.fromJson(Map<String, dynamic> json) {
    final client = json["client"];
    String? clientName;
    if (client is Map<String, dynamic>) {
      final profile = client["profile"];
      if (profile is Map<String, dynamic>) {
        clientName = profile["name"] as String?;
      }
    }
    final cat = json["category"];
    String? categoryLabel;
    if (cat is Map<String, dynamic>) {
      categoryLabel = (cat["name_en"] as String?) ??
          (cat["name_ru"] as String?) ??
          (cat["name_uz"] as String?);
    }
    final budgetRaw = json["budget_amount"] ?? json["budgetAmount"];
    final created =
        json["created_at"] as String? ?? json["createdAt"] as String? ?? "";
    return PendingModerationGigRequestRow(
      id: (json["id"] as num?)?.toInt() ?? 0,
      clientUserId:
          ((json["client_user_id"] ?? json["clientUserId"]) as num?)?.toInt() ??
              0,
      title: json["title"] as String? ?? "",
      createdAt: created,
      budgetAmount:
          budgetRaw is num ? budgetRaw.toInt() : int.tryParse("$budgetRaw"),
      budgetType: json["budget_type"] as String? ?? json["budgetType"] as String?,
      currencyCode:
          json["currency_code"] as String? ?? json["currencyCode"] as String?,
      clientName: clientName,
      categoryLabel: categoryLabel,
    );
  }

  final int id;
  final int clientUserId;
  final String title;
  final String createdAt;
  final int? budgetAmount;
  final String? budgetType;
  final String? currencyCode;
  final String? clientName;
  final String? categoryLabel;
}

class GigOffersModerationQueueResponse {
  GigOffersModerationQueueResponse({
    required this.offers,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.summary,
  });

  factory GigOffersModerationQueueResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json["offers"] as List<dynamic>? ?? [];
    final summaryJson = json["summary"] as Map<String, dynamic>?;
    return GigOffersModerationQueueResponse(
      offers: rawList
          .map(
            (e) =>
                PendingModerationGigOffer.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      total: (json["total"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages:
          ((json["totalPages"] ?? json["total_pages"]) as num?)?.toInt() ?? 1,
      summary: summaryJson != null
          ? PendingModerationSummary.fromJson(summaryJson)
          : PendingModerationSummary(
              pendingTotal: 0,
              pendingSubmittedToday: 0,
              oldestWaitingDays: null,
            ),
    );
  }

  final List<PendingModerationGigOffer> offers;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final PendingModerationSummary summary;
}

class GigRequestsModerationQueueResponse {
  GigRequestsModerationQueueResponse({
    required this.requests,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.summary,
  });

  factory GigRequestsModerationQueueResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawList = json["requests"] as List<dynamic>? ?? [];
    final summaryJson = json["summary"] as Map<String, dynamic>?;
    return GigRequestsModerationQueueResponse(
      requests: rawList
          .map(
            (e) => PendingModerationGigRequestRow.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      total: (json["total"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages:
          ((json["totalPages"] ?? json["total_pages"]) as num?)?.toInt() ?? 1,
      summary: summaryJson != null
          ? PendingModerationSummary.fromJson(summaryJson)
          : PendingModerationSummary(
              pendingTotal: 0,
              pendingSubmittedToday: 0,
              oldestWaitingDays: null,
            ),
    );
  }

  final List<PendingModerationGigRequestRow> requests;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final PendingModerationSummary summary;
}

class _SetModerationBody implements IJsonEncodable {
  _SetModerationBody({required this.moderationStatus});
  final String moderationStatus;

  @override
  Map<String, dynamic> toJson() => {"moderation_status": moderationStatus};
}

abstract class IGigModerationAdminService {
  Future<GigOffersModerationQueueResponse> getPendingOffersQueue({
    int page = 1,
    int limit = 20,
  });

  Future<GigRequestsModerationQueueResponse> getPendingRequestsQueue({
    int page = 1,
    int limit = 20,
  });

  Future<void> approveOffer(int offerId);

  Future<void> approveRequest(int requestId);
}

class GigModerationAdminService implements IGigModerationAdminService {
  GigModerationAdminService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<GigOffersModerationQueueResponse> getPendingOffersQueue({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/gig-offers/pending-moderation",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected gig-offers pending-moderation response");
      }

      return GigOffersModerationQueueResponse.fromJson(response);
    } catch (e) {
      logger.d("Error fetching gig offers moderation queue: $e");
      rethrow;
    }
  }

  @override
  Future<GigRequestsModerationQueueResponse> getPendingRequestsQueue({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/gig-requests/pending-moderation",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected gig-requests pending-moderation response");
      }

      return GigRequestsModerationQueueResponse.fromJson(response);
    } catch (e) {
      logger.d("Error fetching gig requests moderation queue: $e");
      rethrow;
    }
  }

  @override
  Future<void> approveOffer(int offerId) async {
    await _oauthApiClient.patch<dynamic, _SetModerationBody>(
      "/admin/gig-offers/$offerId/moderation",
      (data) => data,
      basePath: EnvironmentUtil.basePath,
      data: _SetModerationBody(moderationStatus: "approved"),
    );
  }

  @override
  Future<void> approveRequest(int requestId) async {
    await _oauthApiClient.patch<dynamic, _SetModerationBody>(
      "/admin/gig-requests/$requestId/moderation",
      (data) => data,
      basePath: EnvironmentUtil.basePath,
      data: _SetModerationBody(moderationStatus: "approved"),
    );
  }
}
