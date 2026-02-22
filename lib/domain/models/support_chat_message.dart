class SupportChatMessage {
  SupportChatMessage({
    required this.id,
    required this.threadId,
    required this.senderUserId,
    required this.body,
    required this.createdAt,
    this.sender,
    this.forceFromSupport = false,
  });

  factory SupportChatMessage.fromJson(Map<String, dynamic> json) {
    final senderJson = json["sender"] as Map<String, dynamic>?;
    final profileJson = senderJson?["profile"] as Map<String, dynamic>?;

    return SupportChatMessage(
      id: (json["id"] as num).toInt(),
      threadId: (json["thread_id"] as num).toInt(),
      senderUserId: (json["sender_user_id"] as num).toInt(),
      body: json["body"] as String? ?? "",
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"] as String)
          : DateTime.now(),
      sender: senderJson != null
          ? SupportChatMessageSender(
              id: (senderJson["id"] as num).toInt(),
              email: senderJson["email"] as String?,
              name: profileJson?["name"] as String?,
              role: senderJson["role"] as String?,
            )
          : null,
    );
  }

  final int id;
  final int threadId;
  final int senderUserId;
  final String body;
  final DateTime createdAt;
  final SupportChatMessageSender? sender;
  final bool forceFromSupport;

  bool get isFromSupport =>
      forceFromSupport ||
      sender?.role == "admin" ||
      sender?.role == "manager";
}

class SupportChatMessageSender {
  SupportChatMessageSender({
    required this.id,
    this.email,
    this.name,
    this.role,
  });

  final int id;
  final String? email;
  final String? name;
  final String? role;

  String get displayName => name ?? email ?? "User #$id";
}
