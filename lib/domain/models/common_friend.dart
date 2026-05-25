class CommonFriend {
  const CommonFriend({
    required this.userId,
    this.name,
    this.avatarUrl,
  });

  factory CommonFriend.fromJson(Map<String, dynamic> json) {
    return CommonFriend(
      userId: json["userId"] as int? ?? json["user_id"] as int,
      name: json["name"] as String?,
      avatarUrl: json["avatarUrl"] as String? ?? json["avatar_url"] as String?,
    );
  }

  final int userId;
  final String? name;
  final String? avatarUrl;
}

class CommonFriendsResult {
  const CommonFriendsResult({
    required this.commonFriends,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory CommonFriendsResult.fromJson(Map<String, dynamic> json) {
    final friendsJson = json["commonFriends"] as List<dynamic>? ?? [];
    return CommonFriendsResult(
      commonFriends: friendsJson
          .map((item) => CommonFriend.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json["total"] as int? ?? 0,
      page: json["page"] as int? ?? 1,
      totalPages: json["totalPages"] as int? ?? 0,
    );
  }

  final List<CommonFriend> commonFriends;
  final int total;
  final int page;
  final int totalPages;
}

class FollowToggleResult {
  const FollowToggleResult({
    required this.isFollowing,
    required this.action,
  });

  factory FollowToggleResult.fromJson(Map<String, dynamic> json) {
    return FollowToggleResult(
      isFollowing: json["isFollowing"] as bool? ?? false,
      action: json["action"] as String? ?? "",
    );
  }

  final bool isFollowing;
  final String action;
}

class FollowCounts {
  const FollowCounts({
    required this.followerCount,
    required this.followingCount,
  });

  factory FollowCounts.fromJson(Map<String, dynamic> json) {
    return FollowCounts(
      followerCount: json["followerCount"] as int? ??
          json["follower_count"] as int? ??
          0,
      followingCount: json["followingCount"] as int? ??
          json["following_count"] as int? ??
          0,
    );
  }

  final int followerCount;
  final int followingCount;
}

class FollowUserSummary {
  const FollowUserSummary({
    required this.userId,
    this.name,
    this.avatarUrl,
    this.isFollowing = false,
  });

  factory FollowUserSummary.fromJson(Map<String, dynamic> json) {
    return FollowUserSummary(
      userId: json["userId"] as int? ?? json["user_id"] as int,
      name: json["name"] as String?,
      avatarUrl: json["avatarUrl"] as String? ?? json["avatar_url"] as String?,
      isFollowing: json["isFollowing"] as bool? ?? false,
    );
  }

  final int userId;
  final String? name;
  final String? avatarUrl;
  final bool isFollowing;
}

class FollowUsersResult {
  const FollowUsersResult({
    required this.users,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory FollowUsersResult.fromJson(Map<String, dynamic> json) {
    final usersJson = json["users"] as List<dynamic>? ?? [];
    return FollowUsersResult(
      users: usersJson
          .map((item) => FollowUserSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json["total"] as int? ?? 0,
      page: json["page"] as int? ?? 1,
      totalPages: json["totalPages"] as int? ?? 0,
    );
  }

  final List<FollowUserSummary> users;
  final int total;
  final int page;
  final int totalPages;
}
