enum GigBidStatus { pending, accepted, rejected, withdrawn }

GigBidStatus gigBidStatusFromString(String? raw) {
  switch (raw) {
    case "accepted":
      return GigBidStatus.accepted;
    case "rejected":
      return GigBidStatus.rejected;
    case "withdrawn":
      return GigBidStatus.withdrawn;
    case "pending":
    default:
      return GigBidStatus.pending;
  }
}

class GigBid {
  const GigBid({
    required this.id,
    required this.requestId,
    required this.providerUserId,
    required this.amount,
    required this.currencyCode,
    required this.status,
    this.message,
    this.etaMinutes,
    this.providerDisplayName,
    this.providerAvatarUrl,
    this.providerRatingAvg,
    this.providerRatingCount,
  });

  factory GigBid.fromJson(Map<String, dynamic> json) {
    String? providerName;
    String? providerAvatar;
    double? providerRatingAvg;
    int? providerRatingCount;
    if (json["provider"] is Map<String, dynamic>) {
      final p = json["provider"] as Map<String, dynamic>;
      if (p["profile"] is Map<String, dynamic>) {
        final pf = p["profile"] as Map<String, dynamic>;
        providerName = pf["name"] as String?;
        providerAvatar = pf["avatar_url"] as String?;
      }
      if (p["gig_provider_profile"] is Map<String, dynamic>) {
        final gp = p["gig_provider_profile"] as Map<String, dynamic>;
        final ra = gp["rating_avg"];
        providerRatingAvg = ra is num
            ? ra.toDouble()
            : (ra is String ? double.tryParse(ra) : null);
        providerRatingCount = (gp["rating_count"] as num?)?.toInt();
      }
    }
    return GigBid(
      id: (json["id"] as num).toInt(),
      requestId: (json["request_id"] as num).toInt(),
      providerUserId: (json["provider_user_id"] as num).toInt(),
      amount: (json["amount"] as num).toInt(),
      currencyCode: json["currency_code"] as String? ?? "UZS",
      message: json["message"] as String?,
      etaMinutes: (json["eta_minutes"] as num?)?.toInt(),
      status: gigBidStatusFromString(json["status"] as String?),
      providerDisplayName: providerName,
      providerAvatarUrl: providerAvatar,
      providerRatingAvg: providerRatingAvg,
      providerRatingCount: providerRatingCount,
    );
  }

  final int id;
  final int requestId;
  final int providerUserId;
  final int amount;
  final String currencyCode;
  final String? message;
  final int? etaMinutes;
  final GigBidStatus status;
  final String? providerDisplayName;
  final String? providerAvatarUrl;
  final double? providerRatingAvg;
  final int? providerRatingCount;
}
