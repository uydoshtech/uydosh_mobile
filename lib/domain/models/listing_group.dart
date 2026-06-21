import "dart:convert";

class ListingGroupMember {
  const ListingGroupMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role,
  });

  factory ListingGroupMember.fromJson(Map<String, dynamic> json) {
    return ListingGroupMember(
      userId: (json["user_id"] as num).toInt(),
      name: json["name"] as String? ?? "User",
      avatarUrl: json["avatar_url"] as String?,
      role: json["role"] as String?,
    );
  }

  final int userId;
  final String name;
  final String? avatarUrl;
  final String? role;
}

class ListingGroupContext {
  const ListingGroupContext({
    required this.isGroupForming,
    this.groupSizeTarget,
    required this.groupMemberCount,
    required this.groupSpotsOpen,
    this.groupFormingStatus,
    this.groupConversationId,
    required this.isOwner,
    required this.isMember,
    this.myJoinRequestStatus,
    this.pendingJoinRequestCount,
    this.groupShortlistCount,
  });

  factory ListingGroupContext.fromJson(Map<String, dynamic> json) {
    return ListingGroupContext(
      isGroupForming: json["is_group_forming"] == true,
      groupSizeTarget: (json["group_size_target"] as num?)?.toInt(),
      groupMemberCount: (json["group_member_count"] as num?)?.toInt() ?? 0,
      groupSpotsOpen: (json["group_spots_open"] as num?)?.toInt() ?? 0,
      groupFormingStatus: json["group_forming_status"] as String?,
      groupConversationId: (json["group_conversation_id"] as num?)?.toInt(),
      isOwner: json["is_owner"] == true,
      isMember: json["is_member"] == true,
      myJoinRequestStatus: json["my_join_request_status"] as String?,
      pendingJoinRequestCount:
          (json["pending_join_request_count"] as num?)?.toInt(),
      groupShortlistCount: (json["group_shortlist_count"] as num?)?.toInt(),
    );
  }

  final bool isGroupForming;
  final int? groupSizeTarget;
  final int groupMemberCount;
  final int groupSpotsOpen;
  final String? groupFormingStatus;
  final int? groupConversationId;
  final bool isOwner;
  final bool isMember;
  final String? myJoinRequestStatus;
  final int? pendingJoinRequestCount;
  final int? groupShortlistCount;

  bool get isRecruiting =>
      groupFormingStatus == null || groupFormingStatus == "recruiting";

  bool get isFull =>
      groupFormingStatus == "full" ||
      (groupSizeTarget != null && groupMemberCount >= groupSizeTarget!);

  bool get canUseHousingShortlist =>
      (isOwner || isMember) && isFull;

  bool get hasPendingJoinRequest => myJoinRequestStatus == "pending";

  bool get canRequestToJoin =>
      !isOwner &&
      !isMember &&
      !hasPendingJoinRequest &&
      isRecruiting &&
      groupSpotsOpen > 0;

  bool get hasGroupChat => groupConversationId != null;
}

class ListingGroupJoinRequest {
  const ListingGroupJoinRequest({
    required this.id,
    required this.listingId,
    required this.applicantUserId,
    this.message,
    required this.status,
    required this.createdAt,
    required this.applicantName,
    this.applicantAvatar,
    this.applicantGender,
  });

  factory ListingGroupJoinRequest.fromJson(Map<String, dynamic> json) {
    return ListingGroupJoinRequest(
      id: (json["id"] as num).toInt(),
      listingId: (json["listing_id"] as num).toInt(),
      applicantUserId: (json["applicant_user_id"] as num).toInt(),
      message: json["message"] as String?,
      status: json["status"] as String,
      createdAt: json["created_at"] as String,
      applicantName: json["applicant_name"] as String? ?? "User",
      applicantAvatar: json["applicant_avatar"] as String?,
      applicantGender: (json["applicant_gender"] as num?)?.toInt(),
    );
  }

  final int id;
  final int listingId;
  final int applicantUserId;
  final String? message;
  final String status;
  final String createdAt;
  final String applicantName;
  final String? applicantAvatar;
  final int? applicantGender;
}

Map<String, dynamic>? _optionalJsonMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

class ListingGroupShortlistItem {
  const ListingGroupShortlistItem({
    required this.id,
    required this.groupListingId,
    required this.listingId,
    required this.savedByUserId,
    required this.createdAt,
    this.savedByName,
    this.listingJson,
  });

  factory ListingGroupShortlistItem.fromJson(Map<String, dynamic> json) {
    final savedBy = _optionalJsonMap(json["saved_by"]);
    return ListingGroupShortlistItem(
      id: (json["id"] as num).toInt(),
      groupListingId: (json["group_listing_id"] as num).toInt(),
      listingId: (json["listing_id"] as num).toInt(),
      savedByUserId: (json["saved_by_user_id"] as num).toInt(),
      createdAt: json["created_at"]?.toString() ?? "",
      savedByName: savedBy?["name"] as String?,
      listingJson: _optionalJsonMap(json["listing"]),
    );
  }

  final int id;
  final int groupListingId;
  final int listingId;
  final int savedByUserId;
  final String createdAt;
  final String? savedByName;
  final Map<String, dynamic>? listingJson;
}

class ListingGroupShortlistSaver {
  const ListingGroupShortlistSaver({
    required this.userId,
    required this.name,
  });

  factory ListingGroupShortlistSaver.fromJson(Map<String, dynamic> json) {
    return ListingGroupShortlistSaver(
      userId: (json["user_id"] as num).toInt(),
      name: json["name"] as String? ?? "User",
    );
  }

  final int userId;
  final String name;
}
