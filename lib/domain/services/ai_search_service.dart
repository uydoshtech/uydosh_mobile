import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing.dart";

class AiSearchResponse {
  const AiSearchResponse({
    required this.text,
    required this.listings,
    required this.total,
    this.filters,
  });
  final String text;
  final List<Listing> listings;
  final int total;
  final AiSearchFilters? filters;
}

class AiSearchFilters {
  const AiSearchFilters({
    this.listingTypeId,
    this.locationId,
    this.minPrice,
    this.maxPrice,
    this.gender,
    this.privateRoom,
  });

  factory AiSearchFilters.fromJson(Map<String, dynamic> json) =>
      AiSearchFilters(
        listingTypeId: json["listingTypeId"] as int?,
        locationId: json["locationId"] as int?,
        minPrice: (json["minPrice"] as num?)?.toDouble(),
        maxPrice: (json["maxPrice"] as num?)?.toDouble(),
        gender: json["gender"] as int?,
        privateRoom: json["privateRoom"] as bool?,
      );

  final int? listingTypeId;
  final int? locationId;
  final double? minPrice;
  final double? maxPrice;
  final int? gender;
  final bool? privateRoom;
}

abstract class IAiSearchService {
  Future<AiSearchResponse> search(String message, {String? language});
}

class AiSearchService implements IAiSearchService {
  AiSearchService(this._apiClient);
  final IOAuthApiClient _apiClient;

  @override
  Future<AiSearchResponse> search(String message, {String? language}) async {
    final response = await _apiClient.dio.post<dynamic>(
      "${EnvironmentUtil.basePath}/api/ai/chat",
      data: {"message": message, "language": ?language},
    );
    final body = response.data as Map<String, dynamic>;
    final listings = (body["listings"] as List<dynamic>? ?? const [])
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
    return AiSearchResponse(
      text: body["text"] as String? ?? "",
      listings: listings,
      total: body["total"] as int? ?? listings.length,
      filters: body["filters"] is Map<String, dynamic>
          ? AiSearchFilters.fromJson(body["filters"] as Map<String, dynamic>)
          : null,
    );
  }
}
