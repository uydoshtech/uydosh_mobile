class AdminUser {
  final int id;
  final String? email;
  final String? role;
  final String? firebaseUid;
  final String? telegramId;
  final DateTime? createdAt;
  final bool isBlocked;
  final DateTime? blockedAt;
  final DateTime? blockedUntil;
  final String? blockedReason;

  AdminUser({
    required this.id,
    this.email,
    this.role,
    this.firebaseUid,
    this.telegramId,
    this.createdAt,
    this.isBlocked = false,
    this.blockedAt,
    this.blockedUntil,
    this.blockedReason,
  });

  bool get isCurrentlyBlocked {
    if (!isBlocked) return false;
    if (blockedUntil != null && blockedUntil!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json["id"] as int? ?? 0,
      email: json["email"] as String?,
      role: json["role"] as String?,
      firebaseUid: json["firebase_uid"] as String?,
      telegramId: json["telegram_id"] as String?,
      createdAt: _parseDate(json["created_at"]),
      isBlocked: json["is_blocked"] as bool? ?? false,
      blockedAt: _parseDate(json["blocked_at"]),
      blockedUntil: _parseDate(json["blocked_until"]),
      blockedReason: json["blocked_reason"] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
