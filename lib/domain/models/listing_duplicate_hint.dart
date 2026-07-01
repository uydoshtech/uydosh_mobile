import "package:uy_dosh/base/localization/l10n.dart";

/// Server-side duplicate hint for Telegram-attributed listings.
class ListingDuplicateHint {
  ListingDuplicateHint({
    required this.level,
    required this.score,
    required this.matchedListingId,
    required this.matchedFields,
    this.matchedModerationStatus,
    this.matchedCreatedAt,
  });

  factory ListingDuplicateHint.fromJson(Map<String, dynamic> json) {
    final rawFields = json["matchedFields"] ?? json["matched_fields"];
    final fields = rawFields is List
        ? rawFields.map((e) => e.toString()).toList()
        : const <String>[];
    return ListingDuplicateHint(
      level: (json["level"] as String?) ?? "medium",
      score: ((json["score"] as num?) ?? 0).toInt(),
      matchedListingId:
          ((json["matchedListingId"] ?? json["matched_listing_id"]) as num?)
              ?.toInt() ??
          0,
      matchedModerationStatus: json["matchedModerationStatus"] as String? ??
          json["matched_moderation_status"] as String?,
      matchedFields: fields,
      matchedCreatedAt: json["matchedCreatedAt"] as String? ??
          json["matched_created_at"] as String?,
    );
  }

  static ListingDuplicateHint? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    try {
      return ListingDuplicateHint.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  final String level;
  final int score;
  final int matchedListingId;
  final String? matchedModerationStatus;
  final List<String> matchedFields;
  final String? matchedCreatedAt;

  bool get isHigh => level == "high";
  bool get isMedium => level == "medium";

  String badgeLabel() {
    final key = isHigh
        ? "admin_listing_duplicate_badge_high"
        : "admin_listing_duplicate_badge";
    return L10n.getWithParams(
      key,
      params: {"id": "$matchedListingId"},
    );
  }

  String matchedFieldsLabel() {
    if (matchedFields.isEmpty) return "";
    return matchedFields.map(_fieldLabel).join(", ");
  }

  String approveMessage() {
    return L10n.getWithParams(
      "admin_listing_duplicate_approve_message",
      params: {
        "id": "$matchedListingId",
        "fields": matchedFieldsLabel(),
      },
    );
  }

  static String _fieldLabel(String field) {
    return L10n.get("admin_listing_duplicate_field_$field");
  }
}
