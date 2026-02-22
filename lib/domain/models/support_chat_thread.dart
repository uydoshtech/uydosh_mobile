class SupportChatThread {
  SupportChatThread({
    required this.id,
    required this.userId,
    this.subject,
    required this.status,
    this.assignedSupportUserId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.lastMessage,
    this.messageCount,
  });

  factory SupportChatThread.fromJson(Map<String, dynamic> json) {
    final userJson = json["user"] as Map<String, dynamic>?;
    final profileJson = userJson?["profile"] as Map<String, dynamic>?;
    final lastMsgJson = json["last_message"] as Map<String, dynamic>?;

    return SupportChatThread(
      id: (json["id"] as num).toInt(),
      userId: (json["user_id"] as num).toInt(),
      subject: json["subject"] as String?,
      status: json["status"] as String? ?? "open",
      assignedSupportUserId: json["assigned_support_user_id"] != null
          ? (json["assigned_support_user_id"] as num).toInt()
          : null,
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"] as String)
          : DateTime.now(),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"] as String)
          : DateTime.now(),
      user: userJson != null
          ? SupportChatThreadUser(
              id: (userJson["id"] as num).toInt(),
              email: userJson["email"] as String?,
              name: profileJson?["name"] as String?,
            )
          : null,
      lastMessage: lastMsgJson != null
          ? SupportChatLastMessage(
              body: lastMsgJson["body"] as String? ?? "",
              createdAt: lastMsgJson["created_at"] != null
                  ? DateTime.parse(lastMsgJson["created_at"] as String)
                  : DateTime.now(),
            )
          : null,
      messageCount: (json["message_count"] as num?)?.toInt(),
    );
  }

  final int id;
  final int userId;
  final String? subject;
  final String status;
  final int? assignedSupportUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SupportChatThreadUser? user;
  final SupportChatLastMessage? lastMessage;
  final int? messageCount;

  String get displayTitle {
    if (subject != null && subject!.isNotEmpty) return subject!;
    if (user != null) return user!.name ?? user!.email ?? "User #${user!.id}";
    return "Support";
  }
}

class SupportChatThreadUser {
  SupportChatThreadUser({
    required this.id,
    this.email,
    this.name,
  });

  final int id;
  final String? email;
  final String? name;
}

class SupportChatLastMessage {
  SupportChatLastMessage({
    required this.body,
    required this.createdAt,
  });

  final String body;
  final DateTime createdAt;
}
