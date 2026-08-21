import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing.dart";

class AiSearchResponse {
  const AiSearchResponse({
    required this.text,
    required this.listings,
    required this.total,
  });
  final String text;
  final List<Listing> listings;
  final int total;
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
    );
  }
}
