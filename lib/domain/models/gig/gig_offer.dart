import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_provider_profile.dart";

double? _offerJsonToDouble(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  if (raw is String) {
    final s = raw.trim().replaceAll(",", ".");
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

class GigOfferPhoto {
  const GigOfferPhoto({
    required this.id,
    required this.offerId,
    required this.photoUrl,
    required this.photoOrder,
    required this.isPrimary,
  });

  factory GigOfferPhoto.fromJson(Map<String, dynamic> json) => GigOfferPhoto(
        id: (json["id"] as num).toInt(),
        offerId: (json["offer_id"] as num).toInt(),
        photoUrl: json["photo_url"] as String,
        photoOrder: (json["photo_order"] as num?)?.toInt() ?? 0,
        isPrimary: json["is_primary"] as bool? ?? false,
      );

  final int id;
  final int offerId;
  final String photoUrl;
  final int photoOrder;
  final bool isPrimary;
}

enum GigPricingType { hourly, fixed, perUnit }

GigPricingType gigPricingTypeFromString(String? raw) {
  switch (raw) {
    case "hourly":
      return GigPricingType.hourly;
    case "per_unit":
      return GigPricingType.perUnit;
    case "fixed":
    default:
      return GigPricingType.fixed;
  }
}

String gigPricingTypeToString(GigPricingType type) {
  switch (type) {
    case GigPricingType.hourly:
      return "hourly";
    case GigPricingType.perUnit:
      return "per_unit";
    case GigPricingType.fixed:
      return "fixed";
  }
}

class GigOffer {
  const GigOffer({
    required this.id,
    required this.providerUserId,
    required this.categoryId,
    required this.title,
    required this.pricingType,
    required this.price,
    required this.currencyCode,
    required this.isRemote,
    required this.isActive,
    required this.isFeatured,
    this.descriptionUz,
    this.descriptionRu,
    this.descriptionEn,
    this.minDurationMinutes,
    this.cityId,
    this.locationId,
    this.latitude,
    this.longitude,
    this.serviceRadiusKm,
    this.featuredUntil,
    this.category,
    this.photos = const <GigOfferPhoto>[],
    this.providerProfile,
    this.providerDisplayName,
    this.providerAvatarUrl,
    this.providerRatingAvg,
    this.providerRatingCount,
    this.providerCompletedJobsCount,
    this.providerIsVerified,
    this.isFavorited,
  });

  factory GigOffer.fromJson(Map<String, dynamic> json) {
    GigCategory? category;
    if (json["category"] is Map<String, dynamic>) {
      category = GigCategory.fromJson(json["category"] as Map<String, dynamic>);
    }
    final photos = <GigOfferPhoto>[];
    if (json["photos"] is List) {
      for (final p in (json["photos"] as List)) {
        if (p is Map<String, dynamic>) {
          photos.add(GigOfferPhoto.fromJson(p));
        }
      }
    }
    String? providerDisplayName;
    String? providerAvatarUrl;
    double? providerRatingAvg;
    int? providerRatingCount;
    int? providerCompletedJobsCount;
    bool? providerIsVerified;
    GigProviderProfile? providerProfile;
    if (json["provider"] is Map<String, dynamic>) {
      final p = json["provider"] as Map<String, dynamic>;
      if (p["profile"] is Map<String, dynamic>) {
        final profile = p["profile"] as Map<String, dynamic>;
        providerDisplayName = profile["name"] as String?;
        providerAvatarUrl = profile["avatar_url"] as String?;
      }
      if (p["gig_provider_profile"] is Map<String, dynamic>) {
        final gp = Map<String, dynamic>.from(
          p["gig_provider_profile"] as Map<String, dynamic>,
        );
        final uid = gp["user_id"] ?? p["id"];
        if (uid is num) {
          gp["user_id"] = uid;
          providerProfile = GigProviderProfile.fromJson(gp);
        }
        final ra = gp["rating_avg"];
        providerRatingAvg = _offerJsonToDouble(ra);
        providerRatingCount = (gp["rating_count"] as num?)?.toInt();
        providerCompletedJobsCount =
            (gp["completed_jobs_count"] as num?)?.toInt();
        providerIsVerified = gp["is_verified"] as bool?;
      }
    }
    return GigOffer(
      id: (json["id"] as num).toInt(),
      providerUserId: (json["provider_user_id"] as num).toInt(),
      categoryId: (json["category_id"] as num).toInt(),
      title: json["title"] as String,
      descriptionUz: json["description_uz"] as String?,
      descriptionRu: json["description_ru"] as String?,
      descriptionEn: json["description_en"] as String?,
      pricingType: gigPricingTypeFromString(json["pricing_type"] as String?),
      price: (json["price"] as num).toInt(),
      currencyCode: json["currency_code"] as String? ?? "UZS",
      minDurationMinutes: (json["min_duration_minutes"] as num?)?.toInt(),
      cityId: (json["city_id"] as num?)?.toInt(),
      locationId: (json["location_id"] as num?)?.toInt(),
      latitude: (json["latitude"] is num)
          ? (json["latitude"] as num).toDouble()
          : (json["latitude"] is String
              ? double.tryParse(json["latitude"] as String)
              : null),
      longitude: (json["longitude"] is num)
          ? (json["longitude"] as num).toDouble()
          : (json["longitude"] is String
              ? double.tryParse(json["longitude"] as String)
              : null),
      serviceRadiusKm: (json["service_radius_km"] as num?)?.toInt(),
      isRemote: json["is_remote"] as bool? ?? false,
      isActive: json["is_active"] as bool? ?? true,
      isFeatured: json["is_featured"] as bool? ?? false,
      featuredUntil: json["featured_until"] as String?,
      category: category,
      photos: photos,
      providerProfile: providerProfile,
      providerDisplayName: providerDisplayName,
      providerAvatarUrl: providerAvatarUrl,
      providerRatingAvg: providerRatingAvg,
      providerRatingCount: providerRatingCount,
      providerCompletedJobsCount: providerCompletedJobsCount,
      providerIsVerified: providerIsVerified,
      isFavorited: json["is_favorited"] as bool?,
    );
  }

  final int id;
  final int providerUserId;
  final int categoryId;
  final String title;
  final String? descriptionUz;
  final String? descriptionRu;
  final String? descriptionEn;
  final GigPricingType pricingType;
  final int price;
  final String currencyCode;
  final int? minDurationMinutes;
  final int? cityId;
  final int? locationId;
  final double? latitude;
  final double? longitude;
  final int? serviceRadiusKm;
  final bool isRemote;
  final bool isActive;
  final bool isFeatured;
  final String? featuredUntil;
  final GigCategory? category;
  final List<GigOfferPhoto> photos;
  final GigProviderProfile? providerProfile;
  final String? providerDisplayName;
  final String? providerAvatarUrl;
  final double? providerRatingAvg;
  final int? providerRatingCount;
  final int? providerCompletedJobsCount;
  final bool? providerIsVerified;
  final bool? isFavorited;

  String? primaryPhotoUrl() {
    if (photos.isEmpty) return null;
    final primary = photos.firstWhere(
      (p) => p.isPrimary,
      orElse: () => photos.first,
    );
    return primary.photoUrl;
  }

  String? localizedDescription(String language) {
    switch (language) {
      case "uz":
        return (descriptionUz != null && descriptionUz!.isNotEmpty)
            ? descriptionUz
            : (descriptionRu ?? descriptionEn);
      case "en":
        return (descriptionEn != null && descriptionEn!.isNotEmpty)
            ? descriptionEn
            : (descriptionRu ?? descriptionUz);
      case "ru":
      default:
        return (descriptionRu != null && descriptionRu!.isNotEmpty)
            ? descriptionRu
            : (descriptionEn ?? descriptionUz);
    }
  }
}
