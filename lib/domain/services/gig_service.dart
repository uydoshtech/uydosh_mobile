import "dart:convert";
import "dart:io";

import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/gig/gig_bid.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_provider_profile.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";

/// Wraps a `Map&lt;String, dynamic&gt;` body as an `IJsonEncodable` so it can
/// be passed directly to `IApiClient.post/patch/...`.
class _RawJsonBody implements IJsonEncodable {
  _RawJsonBody(this._body);
  final Map<String, dynamic> _body;
  @override
  Map<String, dynamic> toJson() => _body;
}

abstract class IGigService {
  Future<List<GigCategory>> listCategories();

  // Provider profile
  Future<GigProviderProfile?> getMyProviderProfile();
  Future<GigProviderProfile> upsertMyProviderProfile({
    String? headline,
    String? bioUz,
    String? bioRu,
    String? bioEn,
    int? hourlyRate,
    String currencyCode = "UZS",
    int? baseLocationId,
    int? baseCityId,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    bool isActive = true,
  });

  // Offers
  Future<({List<GigOffer> offers, bool hasMore})> listOffers({
    int page = 1,
    int limit = 20,
    int? categoryId,
    int? cityId,
    int? minPrice,
    int? maxPrice,
    GigPricingType? pricingType,
    bool? isRemote,
    int? providerUserId,
  });
  Future<GigOffer> getOffer(int id);
  Future<GigOffer> createOffer({
    required int categoryId,
    required String title,
    required GigPricingType pricingType,
    required int price,
    String? descriptionUz,
    String? descriptionRu,
    String? descriptionEn,
    String currencyCode = "UZS",
    int? minDurationMinutes,
    int? cityId,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    bool isRemote = false,
  });
  Future<GigOffer> updateOffer({
    required int id,
    required Map<String, dynamic> patch,
  });
  Future<void> deleteOffer(int id);

  /// Link an already-hosted image to an offer by URL. Used by server-side /
  /// admin tooling that already has a public URL on hand.
  Future<void> addOfferPhoto({
    required int offerId,
    required String photoUrl,
    bool isPrimary = false,
  });

  /// Upload a local image file as a photo on an offer. Mirrors the listing
  /// photo upload path: reads the file, encodes it as a base64
  /// `data:image/jpeg;base64,...` payload, posts to
  /// `POST /gigs/offers/:id/photos`. The server handles content moderation,
  /// watermarking, and storage. Returns the new photo row id, or `-1` if the
  /// response omitted it.
  Future<int> uploadOfferPhoto({
    required int offerId,
    required String photoPath,
    bool isPrimary = false,
  });

  Future<void> deleteOfferPhoto({
    required int offerId,
    required int photoId,
  });

  Future<void> reorderOfferPhotos({
    required int offerId,
    required List<int> photoIds,
  });

  // Requests
  Future<({List<GigRequest> requests, bool hasMore})> listRequests({
    int page = 1,
    int limit = 20,
    int? categoryId,
    int? cityId,
    GigRequestStatus? status,
    int? clientUserId,
  });
  Future<GigRequest> getRequest(int id);
  Future<GigRequest> createRequest({
    required int categoryId,
    required String title,
    required GigRequestBudgetType budgetType,
    int? budgetAmount,
    String currencyCode = "UZS",
    String? descriptionUz,
    String? descriptionRu,
    String? descriptionEn,
    DateTime? scheduledAt,
    int? durationMinutesEstimate,
    int? cityId,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    double? latitude,
    double? longitude,
    String? addressText,
    bool isRemote = false,
    DateTime? expiresAt,
  });
  Future<GigRequest> updateRequest({
    required int id,
    required Map<String, dynamic> patch,
  });
  Future<GigRequest> cancelRequest(int id);

  // Bids
  Future<GigBid> placeBid({
    required int requestId,
    required int amount,
    String currencyCode = "UZS",
    String? message,
    int? etaMinutes,
  });
  Future<GigBid> withdrawBid(int bidId);
  Future<GigBooking> acceptBid(int bidId);

  /// Task owner skips bids: invites [providerUserId]; booking stays [pending]
  /// until the provider accepts.
  Future<GigBooking> inviteProviderFromRequest({
    required int requestId,
    required int providerUserId,
    int? agreedAmount,
    String currencyCode = "UZS",
    DateTime? scheduledStartAt,
    DateTime? scheduledEndAt,
    String? addressText,
    double? latitude,
    double? longitude,
  });

  // Bookings
  Future<GigBooking> bookOffer({
    required int offerId,
    DateTime? scheduledStartAt,
    DateTime? scheduledEndAt,
    String? addressText,
    double? latitude,
    double? longitude,
  });
  Future<GigBooking> getBooking(int id);
  Future<List<GigBooking>> listMyBookings({
    String role = "all",
    GigBookingStatus? status,
  });
  Future<GigBooking> transitionBooking({
    required int id,
    required GigBookingStatus to,
    String? cancellationReason,
  });

  // Reviews
  Future<void> reviewBooking({
    required int bookingId,
    required int rating,
    String? comment,
  });

  // Payments
  Future<Map<String, dynamic>> createBookingPayment({
    required int bookingId,
    required String providerCode, // "payme" | "click"
  });

  /// Bookmark a service offer (gig) for later.
  /// Returns whether the offer is favorited *after* the toggle (not "request ok").
  Future<bool> toggleFavoriteOffer(int offerId);

  /// Bookmark an open task (gig request) for later.
  /// Returns whether the task is favorited *after* the toggle (not "request ok").
  Future<bool> toggleFavoriteRequest(int requestId);

  Future<({List<GigOffer> offers, bool hasMore})> listFavoriteOffers({
    int page = 1,
    int limit = 50,
  });

  Future<({List<GigRequest> requests, bool hasMore})> listFavoriteRequests({
    int page = 1,
    int limit = 50,
  });
}

class GigService implements IGigService {
  GigService(this._publicClient, this._oauthClient);

  final IPublicApiClient _publicClient;
  final IOAuthApiClient _oauthClient;

  String get _base => EnvironmentUtil.basePath;

  // ---- Categories ----------------------------------------------------------
  @override
  Future<List<GigCategory>> listCategories() async {
    return _publicClient.get<List<GigCategory>>(
      "/gigs/categories",
      (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(GigCategory.fromJson)
              .toList();
        }
        return const <GigCategory>[];
      },
      basePath: _base,
    );
  }

  // ---- Provider profile ----------------------------------------------------
  @override
  Future<GigProviderProfile?> getMyProviderProfile() async {
    return _oauthClient.get<GigProviderProfile?>(
      "/gigs/me/provider-profile",
      (json) {
        if (json is Map<String, dynamic>) {
          return GigProviderProfile.fromJson(json);
        }
        return null;
      },
      basePath: _base,
    );
  }

  @override
  Future<GigProviderProfile> upsertMyProviderProfile({
    String? headline,
    String? bioUz,
    String? bioRu,
    String? bioEn,
    int? hourlyRate,
    String currencyCode = "UZS",
    int? baseLocationId,
    int? baseCityId,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    bool isActive = true,
  }) async {
    final body = <String, dynamic>{
      if (headline != null) "headline": headline,
      if (bioUz != null) "bio_uz": bioUz,
      if (bioRu != null) "bio_ru": bioRu,
      if (bioEn != null) "bio_en": bioEn,
      if (hourlyRate != null) "hourly_rate": hourlyRate,
      "currency_code": currencyCode,
      if (baseLocationId != null) "base_location_id": baseLocationId,
      if (baseCityId != null) "base_city_id": baseCityId,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
      if (serviceRadiusKm != null) "service_radius_km": serviceRadiusKm,
      "is_active": isActive,
    };
    return _oauthClient.put<GigProviderProfile, _RawJsonBody>(
      "/gigs/me/provider-profile",
      (json) => GigProviderProfile.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody(body),
    );
  }

  // ---- Offers --------------------------------------------------------------
  @override
  Future<({List<GigOffer> offers, bool hasMore})> listOffers({
    int page = 1,
    int limit = 20,
    int? categoryId,
    int? cityId,
    int? minPrice,
    int? maxPrice,
    GigPricingType? pricingType,
    bool? isRemote,
    int? providerUserId,
  }) async {
    final qp = <String, dynamic>{
      "page": page,
      "limit": limit,
      if (categoryId != null) "category_id": categoryId,
      if (cityId != null) "city_id": cityId,
      if (minPrice != null) "min_price": minPrice,
      if (maxPrice != null) "max_price": maxPrice,
      if (pricingType != null) "pricing_type": gigPricingTypeToString(pricingType),
      if (isRemote != null) "is_remote": isRemote,
      if (providerUserId != null) "provider_user_id": providerUserId,
    };
    return _oauthClient.get<({List<GigOffer> offers, bool hasMore})>(
      "/gigs/offers",
      (json) {
        if (json is Map<String, dynamic>) {
          final list = (json["offers"] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(GigOffer.fromJson)
              .toList();
          final hasMore = json["hasMore"] as bool? ?? false;
          return (offers: list, hasMore: hasMore);
        }
        return (offers: const <GigOffer>[], hasMore: false);
      },
      basePath: _base,
      queryParameters: qp,
    );
  }

  @override
  Future<GigOffer> getOffer(int id) async {
    return _oauthClient.get<GigOffer>(
      "/gigs/offers/$id",
      (json) => GigOffer.fromJson(json as Map<String, dynamic>),
      basePath: _base,
    );
  }

  @override
  Future<GigOffer> createOffer({
    required int categoryId,
    required String title,
    required GigPricingType pricingType,
    required int price,
    String? descriptionUz,
    String? descriptionRu,
    String? descriptionEn,
    String currencyCode = "UZS",
    int? minDurationMinutes,
    int? cityId,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    bool isRemote = false,
  }) async {
    final body = <String, dynamic>{
      "category_id": categoryId,
      "title": title,
      "pricing_type": gigPricingTypeToString(pricingType),
      "price": price,
      "currency_code": currencyCode,
      if (descriptionUz != null) "description_uz": descriptionUz,
      if (descriptionRu != null) "description_ru": descriptionRu,
      if (descriptionEn != null) "description_en": descriptionEn,
      if (minDurationMinutes != null) "min_duration_minutes": minDurationMinutes,
      if (cityId != null) "city_id": cityId,
      if (locationId != null) "location_id": locationId,
      if (subwayStationId != null) "subway_station_id": subwayStationId,
      if (subwayLineId != null) "subway_line_id": subwayLineId,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
      if (serviceRadiusKm != null) "service_radius_km": serviceRadiusKm,
      "is_remote": isRemote,
    };
    return _oauthClient.post<GigOffer, _RawJsonBody>(
      "/gigs/offers",
      (json) => GigOffer.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody(body),
    );
  }

  @override
  Future<GigOffer> updateOffer({required int id, required Map<String, dynamic> patch}) async {
    return _oauthClient.patch<GigOffer, _RawJsonBody>(
      "/gigs/offers/$id",
      (json) => GigOffer.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody(patch),
    );
  }

  @override
  Future<void> deleteOffer(int id) async {
    await _oauthClient.delete<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/offers/$id",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
    );
  }

  @override
  Future<void> addOfferPhoto({
    required int offerId,
    required String photoUrl,
    bool isPrimary = false,
  }) async {
    await _oauthClient.post<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/offers/$offerId/photos",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({"photo_url": photoUrl, "is_primary": isPrimary}),
    );
  }

  @override
  Future<int> uploadOfferPhoto({
    required int offerId,
    required String photoPath,
    bool isPrimary = false,
  }) async {
    final file = File(photoPath);
    if (!file.existsSync()) {
      throw Exception("Photo file does not exist: $photoPath");
    }
    final bytes = await file.readAsBytes();
    final imageData = "data:image/jpeg;base64,${base64Encode(bytes)}";
    final response = await _oauthClient.post<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/offers/$offerId/photos",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({
        "image_data": imageData,
        "is_primary": isPrimary,
      }),
    );
    final photo = response["photo"];
    if (photo is Map<String, dynamic>) {
      final rawId = photo["id"];
      if (rawId is int) return rawId;
      if (rawId is num) return rawId.toInt();
    }
    return -1;
  }

  @override
  Future<void> deleteOfferPhoto({
    required int offerId,
    required int photoId,
  }) async {
    await _oauthClient.delete<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/offers/$offerId/photos/$photoId",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({}),
    );
  }

  @override
  Future<void> reorderOfferPhotos({
    required int offerId,
    required List<int> photoIds,
  }) async {
    await _oauthClient.post<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/offers/$offerId/photos/reorder",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({"photo_ids": photoIds}),
    );
  }

  // ---- Gig bookmarks (favorites) -------------------------------------------
  @override
  Future<bool> toggleFavoriteOffer(int offerId) async {
    final map = await _oauthClient.put<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/favorites/offers/$offerId/toggle",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({}),
    );
    return map["isFavorited"] == true;
  }

  @override
  Future<bool> toggleFavoriteRequest(int requestId) async {
    final map = await _oauthClient.put<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/favorites/requests/$requestId/toggle",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({}),
    );
    return map["isFavorited"] == true;
  }

  @override
  Future<({List<GigOffer> offers, bool hasMore})> listFavoriteOffers({
    int page = 1,
    int limit = 50,
  }) async {
    final qp = <String, dynamic>{"page": page, "limit": limit};
    return _oauthClient.get<({List<GigOffer> offers, bool hasMore})>(
      "/gigs/favorites/offers",
      (json) {
        if (json is Map<String, dynamic>) {
          final list = (json["offers"] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(GigOffer.fromJson)
              .toList();
          final hasMore = json["hasMore"] as bool? ?? false;
          return (offers: list, hasMore: hasMore);
        }
        return (offers: const <GigOffer>[], hasMore: false);
      },
      basePath: _base,
      queryParameters: qp,
    );
  }

  @override
  Future<({List<GigRequest> requests, bool hasMore})> listFavoriteRequests({
    int page = 1,
    int limit = 50,
  }) async {
    final qp = <String, dynamic>{"page": page, "limit": limit};
    return _oauthClient.get<({List<GigRequest> requests, bool hasMore})>(
      "/gigs/favorites/requests",
      (json) {
        if (json is Map<String, dynamic>) {
          final list = (json["requests"] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(GigRequest.fromJson)
              .toList();
          final hasMore = json["hasMore"] as bool? ?? false;
          return (requests: list, hasMore: hasMore);
        }
        return (requests: const <GigRequest>[], hasMore: false);
      },
      basePath: _base,
      queryParameters: qp,
    );
  }

  // ---- Requests ------------------------------------------------------------
  @override
  Future<({List<GigRequest> requests, bool hasMore})> listRequests({
    int page = 1,
    int limit = 20,
    int? categoryId,
    int? cityId,
    GigRequestStatus? status,
    int? clientUserId,
  }) async {
    final statusMap = {
      GigRequestStatus.open: "open",
      GigRequestStatus.assigned: "assigned",
      GigRequestStatus.closed: "closed",
      GigRequestStatus.cancelled: "cancelled",
    };
    final qp = <String, dynamic>{
      "page": page,
      "limit": limit,
      if (categoryId != null) "category_id": categoryId,
      if (cityId != null) "city_id": cityId,
      if (status != null) "status": statusMap[status],
      if (clientUserId != null) "client_user_id": clientUserId,
    };
    return _oauthClient.get<({List<GigRequest> requests, bool hasMore})>(
      "/gigs/requests",
      (json) {
        if (json is Map<String, dynamic>) {
          final list = (json["requests"] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(GigRequest.fromJson)
              .toList();
          final hasMore = json["hasMore"] as bool? ?? false;
          return (requests: list, hasMore: hasMore);
        }
        return (requests: const <GigRequest>[], hasMore: false);
      },
      basePath: _base,
      queryParameters: qp,
    );
  }

  @override
  Future<GigRequest> getRequest(int id) async {
    return _oauthClient.get<GigRequest>(
      "/gigs/requests/$id",
      (json) => GigRequest.fromJson(json as Map<String, dynamic>),
      basePath: _base,
    );
  }

  @override
  Future<GigRequest> createRequest({
    required int categoryId,
    required String title,
    required GigRequestBudgetType budgetType,
    int? budgetAmount,
    String currencyCode = "UZS",
    String? descriptionUz,
    String? descriptionRu,
    String? descriptionEn,
    DateTime? scheduledAt,
    int? durationMinutesEstimate,
    int? cityId,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    double? latitude,
    double? longitude,
    String? addressText,
    bool isRemote = false,
    DateTime? expiresAt,
  }) async {
    final body = <String, dynamic>{
      "category_id": categoryId,
      "title": title,
      "budget_type": gigBudgetTypeToString(budgetType),
      if (budgetAmount != null) "budget_amount": budgetAmount,
      "currency_code": currencyCode,
      if (descriptionUz != null) "description_uz": descriptionUz,
      if (descriptionRu != null) "description_ru": descriptionRu,
      if (descriptionEn != null) "description_en": descriptionEn,
      if (scheduledAt != null) "scheduled_at": scheduledAt.toIso8601String(),
      if (durationMinutesEstimate != null)
        "duration_minutes_estimate": durationMinutesEstimate,
      if (cityId != null) "city_id": cityId,
      if (locationId != null) "location_id": locationId,
      if (subwayStationId != null) "subway_station_id": subwayStationId,
      if (subwayLineId != null) "subway_line_id": subwayLineId,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
      if (addressText != null) "address_text": addressText,
      "is_remote": isRemote,
      if (expiresAt != null) "expires_at": expiresAt.toIso8601String(),
    };
    return _oauthClient.post<GigRequest, _RawJsonBody>(
      "/gigs/requests",
      (json) => GigRequest.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody(body),
    );
  }

  @override
  Future<GigRequest> updateRequest({
    required int id,
    required Map<String, dynamic> patch,
  }) async {
    return _oauthClient.patch<GigRequest, _RawJsonBody>(
      "/gigs/requests/$id",
      (json) => GigRequest.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody(patch),
    );
  }

  @override
  Future<GigRequest> cancelRequest(int id) async {
    return _oauthClient.post<GigRequest, _RawJsonBody>(
      "/gigs/requests/$id/cancel",
      (json) => GigRequest.fromJson(json as Map<String, dynamic>),
      basePath: _base,
    );
  }

  // ---- Bids ----------------------------------------------------------------
  @override
  Future<GigBid> placeBid({
    required int requestId,
    required int amount,
    String currencyCode = "UZS",
    String? message,
    int? etaMinutes,
  }) async {
    return _oauthClient.post<GigBid, _RawJsonBody>(
      "/gigs/requests/$requestId/bids",
      (json) => GigBid.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody({
        "amount": amount,
        "currency_code": currencyCode,
        if (message != null) "message": message,
        if (etaMinutes != null) "eta_minutes": etaMinutes,
      }),
    );
  }

  @override
  Future<GigBid> withdrawBid(int bidId) async {
    return _oauthClient.post<GigBid, _RawJsonBody>(
      "/gigs/bids/$bidId/withdraw",
      (json) => GigBid.fromJson(json as Map<String, dynamic>),
      basePath: _base,
    );
  }

  @override
  Future<GigBooking> acceptBid(int bidId) async {
    return _oauthClient.post<GigBooking, _RawJsonBody>(
      "/gigs/bids/$bidId/accept",
      (json) => GigBooking.fromJson(json as Map<String, dynamic>),
      basePath: _base,
    );
  }

  @override
  Future<GigBooking> inviteProviderFromRequest({
    required int requestId,
    required int providerUserId,
    int? agreedAmount,
    String currencyCode = "UZS",
    DateTime? scheduledStartAt,
    DateTime? scheduledEndAt,
    String? addressText,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      "provider_user_id": providerUserId,
      "currency_code": currencyCode,
      if (agreedAmount != null) "agreed_amount": agreedAmount,
      if (scheduledStartAt != null)
        "scheduled_start_at": scheduledStartAt.toIso8601String(),
      if (scheduledEndAt != null)
        "scheduled_end_at": scheduledEndAt.toIso8601String(),
      if (addressText != null) "address_text": addressText,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
    };
    return _oauthClient.post<GigBooking, _RawJsonBody>(
      "/gigs/requests/$requestId/invite-provider",
      (json) => GigBooking.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody(body),
    );
  }

  // ---- Bookings ------------------------------------------------------------
  @override
  Future<GigBooking> bookOffer({
    required int offerId,
    DateTime? scheduledStartAt,
    DateTime? scheduledEndAt,
    String? addressText,
    double? latitude,
    double? longitude,
  }) async {
    return _oauthClient.post<GigBooking, _RawJsonBody>(
      "/gigs/offers/$offerId/book",
      (json) => GigBooking.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody({
        if (scheduledStartAt != null)
          "scheduled_start_at": scheduledStartAt.toIso8601String(),
        if (scheduledEndAt != null)
          "scheduled_end_at": scheduledEndAt.toIso8601String(),
        if (addressText != null) "address_text": addressText,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      }),
    );
  }

  @override
  Future<GigBooking> getBooking(int id) async {
    return _oauthClient.get<GigBooking>(
      "/gigs/bookings/$id",
      (json) => GigBooking.fromJson(json as Map<String, dynamic>),
      basePath: _base,
    );
  }

  @override
  Future<List<GigBooking>> listMyBookings({
    String role = "all",
    GigBookingStatus? status,
  }) async {
    final qp = <String, dynamic>{
      "role": role,
      if (status != null) "status": gigBookingStatusToString(status),
    };
    return _oauthClient.get<List<GigBooking>>(
      "/gigs/bookings",
      (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(GigBooking.fromJson)
              .toList();
        }
        return const <GigBooking>[];
      },
      basePath: _base,
      queryParameters: qp,
    );
  }

  @override
  Future<GigBooking> transitionBooking({
    required int id,
    required GigBookingStatus to,
    String? cancellationReason,
  }) async {
    return _oauthClient.post<GigBooking, _RawJsonBody>(
      "/gigs/bookings/$id/transition",
      (json) => GigBooking.fromJson(json as Map<String, dynamic>),
      basePath: _base,
      data: _RawJsonBody({
        "status": gigBookingStatusToString(to),
        if (cancellationReason != null) "cancellation_reason": cancellationReason,
      }),
    );
  }

  // ---- Reviews -------------------------------------------------------------
  @override
  Future<void> reviewBooking({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    await _oauthClient.post<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/bookings/$bookingId/reviews",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({
        "rating": rating,
        if (comment != null) "comment": comment,
      }),
    );
  }

  // ---- Payments ------------------------------------------------------------
  @override
  Future<Map<String, dynamic>> createBookingPayment({
    required int bookingId,
    required String providerCode,
  }) async {
    return _oauthClient.post<Map<String, dynamic>, _RawJsonBody>(
      "/gigs/bookings/$bookingId/pay",
      (json) => json as Map<String, dynamic>,
      basePath: _base,
      data: _RawJsonBody({"provider_code": providerCode}),
    );
  }
}
