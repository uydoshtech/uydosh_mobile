class AdminUser {
  final int id;
  final String? email;
  final String? role;
  final String? firebaseUid;
  final String? telegramId;
  final DateTime? createdAt;

  AdminUser({
    required this.id,
    this.email,
    this.role,
    this.firebaseUid,
    this.telegramId,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json["id"] as int? ?? 0,
      email: json["email"] as String?,
      role: json["role"] as String?,
      firebaseUid: json["firebase_uid"] as String?,
      telegramId: json["telegram_id"] as String?,
      createdAt: _parseDate(json["created_at"]),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
