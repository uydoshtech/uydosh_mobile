import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart" show GigPricingType, gigPricingTypeFromString;

enum GigBookingSourceType { offer, request }

GigBookingSourceType gigBookingSourceTypeFromString(String? raw) {
  switch (raw) {
    case "request":
      return GigBookingSourceType.request;
    case "offer":
    default:
      return GigBookingSourceType.offer;
  }
}

enum GigBookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  disputed,
}

GigBookingStatus gigBookingStatusFromString(String? raw) {
  switch (raw) {
    case "accepted":
      return GigBookingStatus.accepted;
    case "in_progress":
      return GigBookingStatus.inProgress;
    case "completed":
      return GigBookingStatus.completed;
    case "cancelled":
      return GigBookingStatus.cancelled;
    case "disputed":
      return GigBookingStatus.disputed;
    case "pending":
    default:
      return GigBookingStatus.pending;
  }
}

String gigBookingStatusToString(GigBookingStatus s) {
  switch (s) {
    case GigBookingStatus.accepted:
      return "accepted";
    case GigBookingStatus.inProgress:
      return "in_progress";
    case GigBookingStatus.completed:
      return "completed";
    case GigBookingStatus.cancelled:
      return "cancelled";
    case GigBookingStatus.disputed:
      return "disputed";
    case GigBookingStatus.pending:
      return "pending";
  }
}

class GigBooking {
  const GigBooking({
    required this.id,
    required this.clientUserId,
    required this.providerUserId,
    required this.sourceType,
    required this.categoryId,
    required this.titleSnapshot,
    required this.pricingType,
    required this.agreedAmount,
    required this.currencyCode,
    required this.status,
    this.offerId,
    this.requestId,
    this.bidId,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.actualStartAt,
    this.actualEndAt,
    this.addressText,
    this.cancellationReason,
    this.category,
    this.clientDisplayName,
    this.providerDisplayName,
    this.clientAvatarUrl,
    this.providerAvatarUrl,
  });

  factory GigBooking.fromJson(Map<String, dynamic> json) {
    GigCategory? category;
    if (json["category"] is Map<String, dynamic>) {
      category = GigCategory.fromJson(json["category"] as Map<String, dynamic>);
    }
    String? clientName;
    String? providerName;
    String? clientAvatar;
    String? providerAvatar;
    if (json["client"] is Map<String, dynamic>) {
      final c = json["client"] as Map<String, dynamic>;
      if (c["profile"] is Map<String, dynamic>) {
        final p = c["profile"] as Map<String, dynamic>;
        clientName = p["name"] as String?;
        clientAvatar = p["avatar_url"] as String?;
      }
    }
    if (json["provider"] is Map<String, dynamic>) {
      final c = json["provider"] as Map<String, dynamic>;
      if (c["profile"] is Map<String, dynamic>) {
        final p = c["profile"] as Map<String, dynamic>;
        providerName = p["name"] as String?;
        providerAvatar = p["avatar_url"] as String?;
      }
    }
    return GigBooking(
      id: (json["id"] as num).toInt(),
      clientUserId: (json["client_user_id"] as num).toInt(),
      providerUserId: (json["provider_user_id"] as num).toInt(),
      sourceType: gigBookingSourceTypeFromString(json["source_type"] as String?),
      offerId: (json["offer_id"] as num?)?.toInt(),
      requestId: (json["request_id"] as num?)?.toInt(),
      bidId: (json["bid_id"] as num?)?.toInt(),
      categoryId: (json["category_id"] as num).toInt(),
      titleSnapshot: json["title_snapshot"] as String,
      pricingType: gigPricingTypeFromString(json["pricing_type"] as String?),
      agreedAmount: (json["agreed_amount"] as num).toInt(),
      currencyCode: json["currency_code"] as String? ?? "UZS",
      scheduledStartAt: json["scheduled_start_at"] as String?,
      scheduledEndAt: json["scheduled_end_at"] as String?,
      actualStartAt: json["actual_start_at"] as String?,
      actualEndAt: json["actual_end_at"] as String?,
      addressText: json["address_text"] as String?,
      status: gigBookingStatusFromString(json["status"] as String?),
      cancellationReason: json["cancellation_reason"] as String?,
      category: category,
      clientDisplayName: clientName,
      providerDisplayName: providerName,
      clientAvatarUrl: clientAvatar,
      providerAvatarUrl: providerAvatar,
    );
  }

  final int id;
  final int clientUserId;
  final int providerUserId;
  final GigBookingSourceType sourceType;
  final int? offerId;
  final int? requestId;
  final int? bidId;
  final int categoryId;
  final String titleSnapshot;
  final GigPricingType pricingType;
  final int agreedAmount;
  final String currencyCode;
  final String? scheduledStartAt;
  final String? scheduledEndAt;
  final String? actualStartAt;
  final String? actualEndAt;
  final String? addressText;
  final GigBookingStatus status;
  final String? cancellationReason;
  final GigCategory? category;
  final String? clientDisplayName;
  final String? providerDisplayName;
  final String? clientAvatarUrl;
  final String? providerAvatarUrl;

  bool isClient(int userId) => clientUserId == userId;
  bool isProvider(int userId) => providerUserId == userId;
}
