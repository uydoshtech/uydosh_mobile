class AdminUserDevice {
  const AdminUserDevice({
    required this.id,
    required this.deviceId,
    this.platform,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
    this.lastSeenAt,
    this.createdAt,
  });

  factory AdminUserDevice.fromJson(Map<String, dynamic> json) {
    return AdminUserDevice(
      id: json["id"] as int? ?? 0,
      deviceId: (json["device_id"] as String?) ?? "",
      platform: json["platform"] as String?,
      deviceModel: json["device_model"] as String?,
      osVersion: json["os_version"] as String?,
      appVersion: json["app_version"] as String?,
      lastSeenAt: _parseDate(json["last_seen_at"]),
      createdAt: _parseDate(json["created_at"]),
    );
  }

  final int id;
  final String deviceId;
  final String? platform;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
