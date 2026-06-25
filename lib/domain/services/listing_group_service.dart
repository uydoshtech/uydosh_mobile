import "dart:convert";

import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/listing_group.dart";

Map<String, dynamic> _requireResponseMap(dynamic json) {
  if (json is Map<String, dynamic>) return json;
  if (json is Map) return Map<String, dynamic>.from(json);
  if (json is String) {
    final trimmed = json.trim();
    if (trimmed.isEmpty) {
      throw const FormatException("Empty API response");
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw FormatException("Unexpected API response: $trimmed");
    }
  }
  throw FormatException("Expected JSON object, got ${json.runtimeType}");
}

class LandlordInviteResult {
  const LandlordInviteResult({
    this.inviteId,
    this.conversationId,
  });

  factory LandlordInviteResult.fromJson(Map<String, dynamic> json) {
    return LandlordInviteResult(
      inviteId: (json["invite_id"] as num?)?.toInt(),
      conversationId: (json["conversation_id"] as num?)?.toInt(),
    );
  }

  final int? inviteId;
  final int? conversationId;
}

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

  Future<void> removeMember({
    required int listingId,
    required int memberUserId,
    String? reason,
  });

  Future<void> leaveGroup({required int listingId});

  Future<List<ListingGroupShortlistItem>> listShortlist({
    required int groupListingId,
    int page = 1,
    int limit = 50,
  });

  Future<int> getShortlistCount({required int groupListingId});

  Future<bool> isOnShortlist({
    required int groupListingId,
    required int housingListingId,
  });

  Future<bool> toggleShortlist({
    required int groupListingId,
    required int housingListingId,
  });

  Future<void> removeFromShortlist({
    required int groupListingId,
    required int housingListingId,
  });

  Future<LandlordInviteResult> inviteLandlordToGroupChat({
    required int groupListingId,
    required int housingListingId,
  });

  Future<PendingLandlordInvite?> getPendingLandlordInviteForConversation({
    required int conversationId,
  });

  Future<List<PendingLandlordInvite>> listPendingLandlordInvites();

  Future<int> acceptLandlordInvite({
    required int groupListingId,
    required int inviteId,
  });

  Future<void> declineLandlordInvite({
    required int groupListingId,
    required int inviteId,
  });

  Future<ListingGroupShortlistRating> rateShortlistItem({
    required int groupListingId,
    required int housingListingId,
    required int stars,
    List<String> reasons = const [],
    Map<String, int> categoryRatings = const {},
    String? verdict,
  });

  /// Shared housing-search preferences for the group (member only).
  Future<GroupSearchPrefs> getSearchPrefs({required int groupListingId});

  /// Upserts the shared housing-search preferences (member only) and re-applies
  /// every active member's housing alert on the backend.
  Future<GroupSearchPrefs> updateSearchPrefs({
    required int groupListingId,
    int? locationId,
    List<int> subwayStationIds = const [],
    List<int> subwayLineIds = const [],
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
    final response =
        await _oauthApiClient.post<Map<String, dynamic>, _EmptyBody>(
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

  @override
  Future<void> removeMember({
    required int listingId,
    required int memberUserId,
    String? reason,
  }) async {
    await _oauthApiClient.delete<Map<String, dynamic>, _MemberRemovalBody>(
      "/listings/$listingId/group/members/$memberUserId",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: _MemberRemovalBody(reason: reason),
    );
  }

  @override
  Future<void> leaveGroup({required int listingId}) async {
    await _oauthApiClient.delete<Map<String, dynamic>, _EmptyBody>(
      "/listings/$listingId/group/members/me",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
  }

  @override
  Future<List<ListingGroupShortlistItem>> listShortlist({
    required int groupListingId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/listings/$groupListingId/group/shortlist",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      queryParameters: {
        "page": page,
        "limit": limit,
        "language": L10n.currentLanguage,
      },
    );
    final data = response["data"];
    if (data is! List) return const [];
    final items = <ListingGroupShortlistItem>[];
    for (final entry in data) {
      if (entry is! Map) continue;
      try {
        items.add(
          ListingGroupShortlistItem.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      } catch (_) {}
    }
    return items;
  }

  @override
  Future<int> getShortlistCount({required int groupListingId}) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/listings/$groupListingId/group/shortlist/count",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
    );
    return (response["count"] as num?)?.toInt() ?? 0;
  }

  @override
  Future<bool> isOnShortlist({
    required int groupListingId,
    required int housingListingId,
  }) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/listings/$groupListingId/group/shortlist/check/$housingListingId",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
    );
    return response["isShortlisted"] == true;
  }

  @override
  Future<bool> toggleShortlist({
    required int groupListingId,
    required int housingListingId,
  }) async {
    final response =
        await _oauthApiClient.put<Map<String, dynamic>, _EmptyBody>(
      "/listings/$groupListingId/group/shortlist/toggle/$housingListingId",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
    return response["isShortlisted"] == true;
  }

  @override
  Future<void> removeFromShortlist({
    required int groupListingId,
    required int housingListingId,
  }) async {
    await _oauthApiClient.delete<Map<String, dynamic>, _EmptyBody>(
      "/listings/$groupListingId/group/shortlist/$housingListingId",
      (json) => json as Map<String, dynamic>,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
  }

  @override
  Future<LandlordInviteResult> inviteLandlordToGroupChat({
    required int groupListingId,
    required int housingListingId,
  }) async {
    final response =
        await _oauthApiClient.post<Map<String, dynamic>, _EmptyBody>(
      "/listings/$groupListingId/group/shortlist/$housingListingId/landlord-invites",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
    return LandlordInviteResult.fromJson(response);
  }

  @override
  Future<PendingLandlordInvite?> getPendingLandlordInviteForConversation({
    required int conversationId,
  }) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/conversations/$conversationId/pending-landlord-invite",
      _requireResponseMap,
    );
    final data = response["data"];
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return PendingLandlordInvite.fromJson(data);
    }
    if (data is Map) {
      return PendingLandlordInvite.fromJson(Map<String, dynamic>.from(data));
    }
    throw FormatException("Unexpected invite response: ${data.runtimeType}");
  }

  @override
  Future<List<PendingLandlordInvite>> listPendingLandlordInvites() async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/conversations/pending-landlord-invites",
      _requireResponseMap,
    );
    final data = response["data"];
    if (data is! List) return const [];
    return data
        .map((item) => PendingLandlordInvite.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList(growable: false);
  }

  @override
  Future<int> acceptLandlordInvite({
    required int groupListingId,
    required int inviteId,
  }) async {
    final response =
        await _oauthApiClient.post<Map<String, dynamic>, _EmptyBody>(
      "/listings/$groupListingId/group/landlord-invites/$inviteId/accept",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
    return (response["conversation_id"] as num).toInt();
  }

  @override
  Future<void> declineLandlordInvite({
    required int groupListingId,
    required int inviteId,
  }) async {
    await _oauthApiClient.post<Map<String, dynamic>, _EmptyBody>(
      "/listings/$groupListingId/group/landlord-invites/$inviteId/decline",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      data: const _EmptyBody(),
    );
  }

  @override
  Future<ListingGroupShortlistRating> rateShortlistItem({
    required int groupListingId,
    required int housingListingId,
    required int stars,
    List<String> reasons = const [],
    Map<String, int> categoryRatings = const {},
    String? verdict,
  }) async {
    final response =
        await _oauthApiClient.put<Map<String, dynamic>, _ShortlistRatingBody>(
      "/listings/$groupListingId/group/shortlist/$housingListingId/rating",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      data: _ShortlistRatingBody(
        stars: stars,
        reasons: reasons,
        categoryRatings: categoryRatings,
        verdict: verdict,
        language: L10n.currentLanguage,
      ),
    );
    final rating = ListingGroupShortlistRating.fromJsonOrNull(
      response["rating"],
    );
    if (rating == null) {
      throw const FormatException("Missing shortlist rating response");
    }
    return rating;
  }

  @override
  Future<GroupSearchPrefs> getSearchPrefs({
    required int groupListingId,
  }) async {
    final response = await _oauthApiClient.get<Map<String, dynamic>>(
      "/listings/$groupListingId/group/search-prefs",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
    );
    final data = response["data"];
    if (data is! Map) return const GroupSearchPrefs();
    return GroupSearchPrefs.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<GroupSearchPrefs> updateSearchPrefs({
    required int groupListingId,
    int? locationId,
    List<int> subwayStationIds = const [],
    List<int> subwayLineIds = const [],
  }) async {
    final response =
        await _oauthApiClient.put<Map<String, dynamic>, _SearchPrefsBody>(
      "/listings/$groupListingId/group/search-prefs",
      _requireResponseMap,
      basePath: EnvironmentUtil.basePath,
      data: _SearchPrefsBody(
        locationId: locationId,
        subwayStationIds: subwayStationIds,
        subwayLineIds: subwayLineIds,
      ),
    );
    final data = response["data"];
    if (data is! Map) return const GroupSearchPrefs();
    return GroupSearchPrefs.fromJson(Map<String, dynamic>.from(data));
  }
}

class _SearchPrefsBody implements IJsonEncodable {
  const _SearchPrefsBody({
    this.locationId,
    this.subwayStationIds = const [],
    this.subwayLineIds = const [],
  });

  final int? locationId;
  final List<int> subwayStationIds;
  final List<int> subwayLineIds;

  @override
  Map<String, dynamic> toJson() => {
        "locationId": locationId,
        "subwayStationIds": subwayStationIds,
        "subwayLineIds": subwayLineIds,
      };
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

class _MemberRemovalBody implements IJsonEncodable {
  const _MemberRemovalBody({this.reason});

  final String? reason;

  @override
  Map<String, dynamic> toJson() {
    final trimmed = reason?.trim();
    if (trimmed == null || trimmed.isEmpty) return {};
    return {"reason": trimmed};
  }
}

class _EmptyBody implements IJsonEncodable {
  const _EmptyBody();

  @override
  Map<String, dynamic> toJson() => {};
}

class _ShortlistRatingBody implements IJsonEncodable {
  const _ShortlistRatingBody({
    required this.stars,
    this.reasons = const [],
    this.categoryRatings = const {},
    this.verdict,
    this.language,
  });

  final int stars;
  final List<String> reasons;
  final Map<String, int> categoryRatings;
  final String? verdict;
  final String? language;

  @override
  Map<String, dynamic> toJson() => {
        "stars": stars,
        "reasons": reasons,
        "category_ratings": categoryRatings,
        if (verdict != null) "verdict": verdict,
        if (language != null) "language": language,
      };
}
