class ConversationMemberSummary {
  const ConversationMemberSummary({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role,
  });

  factory ConversationMemberSummary.fromJson(Map<String, dynamic> json) {
    return ConversationMemberSummary(
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

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "avatar_url": avatarUrl,
        "role": role,
      };
}
