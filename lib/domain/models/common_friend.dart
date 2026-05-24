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
