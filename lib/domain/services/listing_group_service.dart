import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing_group.dart";

abstract class IListingGroupService {
  Future<void> createJoinRequest({
    required int listingId,
    String? message,
  });

  Future<void> withdrawJoinRequest({required int listingId});

  Future<List<ListingGroupJoinRequest>> listJoinRequests({
    required int listingId,
  });

  Future<List<ListingGroupMember>> listMembers({required int listingId});

  Future<int> approveJoinRequest({
    required int listingId,
    required int requestId,
  });

  Future<void> rejectJoinRequest({
    required int listingId,
    required int requestId,
  });
}

class ListingGroupService implements IListingGroupService {
  ListingGroupService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<void> createJoinRequest({
    required int listingId,
    String? message,
  }) async {
    await _oauthApiClient.post<Map<String, dynamic>, _JoinRequestBody>(
      "/listings/$listingId/group/join-requests",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: _JoinRequestBody(message: message),
    );
  }

  @override
  Future<void> withdrawJoinRequest({required int listingId}) async {
    await _oauthApiClient.delete<Map<String, dynamic>, _EmptyBody>(
      "/listings/$listingId/group/join-requests/mine",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
  }

  @override
  Future<List<ListingGroupMember>> listMembers({
    required int listingId,
  }) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/listings/$listingId/group/members",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
    );
    final data = response["data"];
    if (data is! List) return const [];
    return data
        .map(
          (e) => ListingGroupMember.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<ListingGroupJoinRequest>> listJoinRequests({
    required int listingId,
  }) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/listings/$listingId/group/join-requests",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
    );
    final data = response["data"];
    if (data is! List) return const [];
    return data
        .map(
          (e) => ListingGroupJoinRequest.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<int> approveJoinRequest({
    required int listingId,
    required int requestId,
  }) async {
    final response = await _oauthApiClient.post<Map<String, dynamic>, _EmptyBody>(
      "/listings/$listingId/group/join-requests/$requestId/approve",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
    return (response["conversation_id"] as num).toInt();
  }

  @override
  Future<void> rejectJoinRequest({
    required int listingId,
    required int requestId,
  }) async {
    await _oauthApiClient.post<Map<String, dynamic>, _EmptyBody>(
      "/listings/$listingId/group/join-requests/$requestId/reject",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
  }
}

class _JoinRequestBody implements IJsonEncodable {
  const _JoinRequestBody({this.message});

  final String? message;

  @override
  Map<String, dynamic> toJson() {
    if (message == null || message!.trim().isEmpty) {
      return {};
    }
    return {"message": message!.trim()};
  }
}

class _EmptyBody implements IJsonEncodable {
  const _EmptyBody();

  @override
  Map<String, dynamic> toJson() => {};
}
