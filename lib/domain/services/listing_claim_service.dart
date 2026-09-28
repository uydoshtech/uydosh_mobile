import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

class ListingClaimEligibility {
  const ListingClaimEligibility({
    required this.eligible,
    this.telegramUsername,
  });
  final bool eligible;
  final String? telegramUsername;

  factory ListingClaimEligibility.fromJson(Map<String, dynamic> json) =>
      ListingClaimEligibility(
        eligible: json["eligible"] == true,
        telegramUsername: json["telegramUsername"] as String?,
      );
}

class ListingClaimService {
  ListingClaimService(this._client);
  final IOAuthApiClient _client;

  Future<ListingClaimEligibility> eligibility(int listingId) => _client.get(
    "/listings/$listingId/claim-eligibility",
    (json) => ListingClaimEligibility.fromJson(json),
    basePath: EnvironmentUtil.basePath,
  );

  Future<void> claim(int listingId) async {
    await _client.post<dynamic, EmptyListingRequest>(
      "/listings/$listingId/claim",
      (json) => json,
      basePath: EnvironmentUtil.basePath,
      data: EmptyListingRequest(),
    );
  }
}
