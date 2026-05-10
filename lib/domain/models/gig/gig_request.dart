import "package:uy_dosh/domain/models/gig/gig_bid.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";

enum GigRequestBudgetType { hourly, fixed, open }

GigRequestBudgetType gigBudgetTypeFromString(String? raw) {
  switch (raw) {
    case "hourly":
      return GigRequestBudgetType.hourly;
    case "open":
      return GigRequestBudgetType.open;
    case "fixed":
    default:
      return GigRequestBudgetType.fixed;
  }
}

String gigBudgetTypeToString(GigRequestBudgetType t) {
  switch (t) {
    case GigRequestBudgetType.hourly:
      return "hourly";
    case GigRequestBudgetType.open:
      return "open";
    case GigRequestBudgetType.fixed:
      return "fixed";
  }
}

enum GigRequestStatus { open, assigned, closed, cancelled }

GigRequestStatus gigRequestStatusFromString(String? raw) {
  switch (raw) {
    case "assigned":
      return GigRequestStatus.assigned;
    case "closed":
      return GigRequestStatus.closed;
    case "cancelled":
      return GigRequestStatus.cancelled;
    case "open":
    default:
      return GigRequestStatus.open;
  }
}

class GigRequest {
  const GigRequest({
    required this.id,
    required this.clientUserId,
    required this.categoryId,
    required this.title,
    required this.budgetType,
    required this.currencyCode,
    required this.isRemote,
    required this.status,
    this.descriptionUz,
    this.descriptionRu,
    this.descriptionEn,
    this.budgetAmount,
    this.scheduledAt,
    this.durationMinutesEstimate,
    this.cityId,
    this.locationId,
    this.latitude,
    this.longitude,
    this.addressText,
    this.expiresAt,
    this.category,
    this.clientDisplayName,
    this.clientAvatarUrl,
    this.bids = const <GigBid>[],
    this.isFavorited,
    this.createdAt,
  });

  factory GigRequest.fromJson(Map<String, dynamic> json) {
    GigCategory? category;
    if (json["category"] is Map<String, dynamic>) {
      category = GigCategory.fromJson(json["category"] as Map<String, dynamic>);
    }
    String? clientName;
    String? clientAvatar;
    if (json["client"] is Map<String, dynamic>) {
      final c = json["client"] as Map<String, dynamic>;
      if (c["profile"] is Map<String, dynamic>) {
        final p = c["profile"] as Map<String, dynamic>;
        clientName = p["name"] as String?;
        clientAvatar = p["avatar_url"] as String?;
      }
    }
    final bids = <GigBid>[];
    if (json["bids"] is List) {
      for (final b in (json["bids"] as List)) {
        if (b is Map<String, dynamic>) bids.add(GigBid.fromJson(b));
      }
    }
    return GigRequest(
      id: (json["id"] as num).toInt(),
      clientUserId: (json["client_user_id"] as num).toInt(),
      categoryId: (json["category_id"] as num).toInt(),
      title: json["title"] as String,
      descriptionUz: json["description_uz"] as String?,
      descriptionRu: json["description_ru"] as String?,
      descriptionEn: json["description_en"] as String?,
      budgetType: gigBudgetTypeFromString(json["budget_type"] as String?),
      budgetAmount: (json["budget_amount"] as num?)?.toInt(),
      currencyCode: json["currency_code"] as String? ?? "UZS",
      scheduledAt: json["scheduled_at"] as String?,
      durationMinutesEstimate:
          (json["duration_minutes_estimate"] as num?)?.toInt(),
      cityId: (json["city_id"] as num?)?.toInt(),
      locationId: (json["location_id"] as num?)?.toInt(),
      latitude: (json["latitude"] is num)
          ? (json["latitude"] as num).toDouble()
          : null,
      longitude: (json["longitude"] is num)
          ? (json["longitude"] as num).toDouble()
          : null,
      addressText: json["address_text"] as String?,
      isRemote: json["is_remote"] as bool? ?? false,
      status: gigRequestStatusFromString(json["status"] as String?),
      expiresAt: json["expires_at"] as String?,
      category: category,
      clientDisplayName: clientName,
      clientAvatarUrl: clientAvatar,
      bids: bids,
      isFavorited: json["is_favorited"] as bool?,
      createdAt: json["created_at"] as String?,
    );
  }

  final int id;
  final int clientUserId;
  final int categoryId;
  final String title;
  final String? descriptionUz;
  final String? descriptionRu;
  final String? descriptionEn;
  final GigRequestBudgetType budgetType;
  final int? budgetAmount;
  final String currencyCode;
  final String? scheduledAt;
  final int? durationMinutesEstimate;
  final int? cityId;
  final int? locationId;
  final double? latitude;
  final double? longitude;
  final String? addressText;
  final bool isRemote;
  final GigRequestStatus status;
  final String? expiresAt;
  final GigCategory? category;
  final String? clientDisplayName;
  final String? clientAvatarUrl;
  final List<GigBid> bids;
  final bool? isFavorited;
  final String? createdAt;
}
