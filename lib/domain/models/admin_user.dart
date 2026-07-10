class AdminUser {
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
    this.isOnline = false,
    this.telegramUsername,
    this.isTelegramMiniAppOnly = false,
    this.signupSource,
  });

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
      // Active in the Telegram Mini App within the last ~30s. See
      // TelegramMiniAppSessionService.heartbeat (uydosh_backend) for the source signal.
      isOnline: json["isOnline"] as bool? ?? false,
      telegramUsername: json["telegramUsername"] as String?,
      // Has a Telegram id but none of the native-app-only signals (firebase/email/phone/FCM
      // token) — see IS_TELEGRAM_MINI_APP_ONLY_SQL in uydosh_backend's userService.ts.
      isTelegramMiniAppOnly: json["isTelegramMiniAppOnly"] as bool? ?? false,
      // Immutable "how this account was first created" tag, e.g. 'telegram_mini_app',
      // 'telegram_bot', 'telegram_oidc', 'firebase', 'email_password'. Null for accounts
      // created before this column existed. See UserModel.signup_source (uydosh_backend).
      signupSource: json["signup_source"] as String?,
    );
  }
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
  final bool isOnline;
  final String? telegramUsername;
  final bool isTelegramMiniAppOnly;
  final String? signupSource;

  bool get isCurrentlyBlocked {
    if (!isBlocked) return false;
    if (blockedUntil != null && blockedUntil!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
