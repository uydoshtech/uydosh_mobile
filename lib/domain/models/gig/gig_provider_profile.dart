enum GigKycStatus { none, pending, approved, rejected }

GigKycStatus gigKycStatusFromString(String? raw) {
  switch (raw) {
    case "pending":
      return GigKycStatus.pending;
    case "approved":
      return GigKycStatus.approved;
    case "rejected":
      return GigKycStatus.rejected;
    case "none":
    default:
      return GigKycStatus.none;
  }
}

class GigProviderProfile {
  const GigProviderProfile({
    required this.userId,
    required this.currencyCode,
    required this.isActive,
    required this.isVerified,
    required this.kycStatus,
    required this.completedJobsCount,
    required this.cancellationCount,
    required this.ratingCount,
    this.headline,
    this.bioUz,
    this.bioRu,
    this.bioEn,
    this.hourlyRate,
    this.baseLocationId,
    this.baseCityId,
    this.latitude,
    this.longitude,
    this.serviceRadiusKm,
    this.ratingAvg,
  });

  factory GigProviderProfile.fromJson(Map<String, dynamic> json) {
    final ra = json["rating_avg"];
    final ratingAvg = ra is num
        ? ra.toDouble()
        : (ra is String ? double.tryParse(ra) : null);
    return GigProviderProfile(
      userId: (json["user_id"] as num).toInt(),
      currencyCode: json["currency_code"] as String? ?? "UZS",
      isActive: json["is_active"] as bool? ?? true,
      isVerified: json["is_verified"] as bool? ?? false,
      kycStatus: gigKycStatusFromString(json["kyc_status"] as String?),
      completedJobsCount: (json["completed_jobs_count"] as num?)?.toInt() ?? 0,
      cancellationCount: (json["cancellation_count"] as num?)?.toInt() ?? 0,
      ratingCount: (json["rating_count"] as num?)?.toInt() ?? 0,
      headline: json["headline"] as String?,
      bioUz: json["bio_uz"] as String?,
      bioRu: json["bio_ru"] as String?,
      bioEn: json["bio_en"] as String?,
      hourlyRate: (json["hourly_rate"] as num?)?.toInt(),
      baseLocationId: (json["base_location_id"] as num?)?.toInt(),
      baseCityId: (json["base_city_id"] as num?)?.toInt(),
      latitude: (json["latitude"] is num)
          ? (json["latitude"] as num).toDouble()
          : null,
      longitude: (json["longitude"] is num)
          ? (json["longitude"] as num).toDouble()
          : null,
      serviceRadiusKm: (json["service_radius_km"] as num?)?.toInt(),
      ratingAvg: ratingAvg,
    );
  }

  final int userId;
  final String? headline;
  final String? bioUz;
  final String? bioRu;
  final String? bioEn;
  final int? hourlyRate;
  final String currencyCode;
  final int? baseLocationId;
  final int? baseCityId;
  final double? latitude;
  final double? longitude;
  final int? serviceRadiusKm;
  final bool isActive;
  final bool isVerified;
  final GigKycStatus kycStatus;
  final int completedJobsCount;
  final int cancellationCount;
  final double? ratingAvg;
  final int ratingCount;
}
