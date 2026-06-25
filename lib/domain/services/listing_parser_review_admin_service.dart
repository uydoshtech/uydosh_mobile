import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// One field-level difference between the frozen parser output and the
/// human-approved listing (mirrors `listing_correction_diffs`).
class ParserCorrectionDiff {
  ParserCorrectionDiff({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.correctionType,
  });

  factory ParserCorrectionDiff.fromJson(Map<String, dynamic> json) {
    return ParserCorrectionDiff(
      fieldName: (json["field_name"] ?? json["fieldName"]) as String? ?? "",
      oldValue: json["old_value"] ?? json["oldValue"],
      newValue: json["new_value"] ?? json["newValue"],
      correctionType:
          (json["correction_type"] ?? json["correctionType"]) as String? ??
              "confirmed",
    );
  }

  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;

  /// One of: confirmed | changed | added | removed.
  final String correctionType;
}

/// Snapshot of the parser's structured output frozen at import time.
class ParserSnapshot {
  ParserSnapshot({
    required this.outputJson,
    this.parserVersion,
    this.parserType,
    this.confidenceJson,
    this.metadataJson,
  });

  factory ParserSnapshot.fromJson(Map<String, dynamic> json) {
    return ParserSnapshot(
      outputJson: (json["output_json"] ?? json["outputJson"])
              as Map<String, dynamic>? ??
          const {},
      parserVersion:
          (json["parser_version"] ?? json["parserVersion"]) as String?,
      parserType: (json["parser_type"] ?? json["parserType"]) as String?,
      confidenceJson: (json["confidence_json"] ?? json["confidenceJson"])
          as Map<String, dynamic>?,
      metadataJson: (json["metadata_json"] ?? json["metadataJson"])
          as Map<String, dynamic>?,
    );
  }

  final Map<String, dynamic> outputJson;
  final String? parserVersion;
  final String? parserType;
  final Map<String, dynamic>? confidenceJson;
  final Map<String, dynamic>? metadataJson;
}

/// The immutable raw Telegram source a listing was parsed from.
class ParserRawSource {
  ParserRawSource({
    this.text,
    this.chatKey,
    this.messageDate,
    this.authorUsername,
    this.authorDisplayName,
    this.telegramMessageId,
  });

  factory ParserRawSource.fromJson(Map<String, dynamic> json) {
    return ParserRawSource(
      text: json["text"] as String?,
      chatKey: (json["chatKey"] ?? json["chat_key"]) as String?,
      messageDate: (json["messageDate"] ?? json["message_date"]) as String?,
      authorUsername:
          (json["authorUsername"] ?? json["author_username"]) as String?,
      authorDisplayName:
          (json["authorDisplayName"] ?? json["author_display_name"]) as String?,
      telegramMessageId:
          (json["telegramMessageId"] ?? json["telegram_message_id"])
              ?.toString(),
    );
  }

  final String? text;
  final String? chatKey;
  final String? messageDate;
  final String? authorUsername;
  final String? authorDisplayName;
  final String? telegramMessageId;
}

/// Everything the admin review screen needs in one call.
class ParserReviewBundle {
  ParserReviewBundle({
    required this.listing,
    required this.correctionDiffs,
    this.rawSource,
    this.parserSnapshot,
    this.latestHumanCorrected,
    this.latestApproved,
  });

  factory ParserReviewBundle.fromJson(Map<String, dynamic> json) {
    final rawSourceJson = json["rawSource"] as Map<String, dynamic>?;
    final snapshotJson = json["parserSnapshot"] as Map<String, dynamic>?;
    final humanJson =
        json["latestHumanCorrectedVersion"] as Map<String, dynamic>?;
    final approvedJson = json["latestApprovedVersion"] as Map<String, dynamic>?;
    final diffs = (json["correctionDiffs"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ParserCorrectionDiff.fromJson)
        .toList();
    return ParserReviewBundle(
      listing: json["listing"] as Map<String, dynamic>? ?? const {},
      rawSource: rawSourceJson != null
          ? ParserRawSource.fromJson(rawSourceJson)
          : null,
      parserSnapshot:
          snapshotJson != null ? ParserSnapshot.fromJson(snapshotJson) : null,
      latestHumanCorrected: humanJson,
      latestApproved: approvedJson,
      correctionDiffs: diffs,
    );
  }

  final Map<String, dynamic> listing;
  final ParserRawSource? rawSource;
  final ParserSnapshot? parserSnapshot;
  final Map<String, dynamic>? latestHumanCorrected;
  final Map<String, dynamic>? latestApproved;
  final List<ParserCorrectionDiff> correctionDiffs;

  bool get hasParserData => parserSnapshot != null;

  /// The original Telegram poster's handle (no `@`) stored on the listing, if
  /// any. Admin-editable on the review screen. Falls back to the raw source's
  /// author username so the field is pre-filled even before it's been saved.
  String? get telegramAuthorUsername {
    final candidates = <Object?>[
      listing["telegram_author_username"],
      rawSource?.authorUsername,
      parserSnapshot?.outputJson["telegram_author_username"],
      parserSnapshot?.outputJson["contact_telegram"],
      listing["contact_telegram"],
    ];
    for (final candidate in candidates) {
      final normalized = _normalizeTelegramUsername(candidate);
      if (normalized != null) return normalized;
    }
    return null;
  }

  static String? _normalizeTelegramUsername(Object? value) {
    if (value is! String) return null;
    var normalized = value.trim();
    if (normalized.isEmpty) return null;

    normalized = normalized
        .replaceFirst(RegExp(r"^https?://", caseSensitive: false), "")
        .replaceFirst(RegExp(r"^(www\.)?t\.me/", caseSensitive: false), "")
        .replaceFirst(RegExp(r"^telegram\.me/", caseSensitive: false), "")
        .replaceFirst(RegExp(r"^@+"), "")
        .split(RegExp(r"[\s/?#]"))
        .first
        .trim();

    return normalized.isEmpty ? null : normalized;
  }
}

class _SetTelegramAuthorUsernameBody implements IJsonEncodable {
  _SetTelegramAuthorUsernameBody({required this.telegramAuthorUsername});
  final String? telegramAuthorUsername;

  @override
  Map<String, dynamic> toJson() =>
      {"telegram_author_username": telegramAuthorUsername};
}

abstract class IListingParserReviewAdminService {
  Future<ParserReviewBundle> getParserReview(int listingId);

  /// Sets (or clears, with null/empty) the original Telegram poster's handle.
  /// Returns the normalized value stored server-side (no `@`, or null).
  Future<String?> updateTelegramAuthorUsername(int listingId, String? username);
}

class ListingParserReviewAdminService
    implements IListingParserReviewAdminService {
  ListingParserReviewAdminService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<ParserReviewBundle> getParserReview(int listingId) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/listings/$listingId/parser-review",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected parser-review response");
      }
      return ParserReviewBundle.fromJson(response);
    } catch (e) {
      logger.d("Error fetching parser review for listing $listingId: $e");
      rethrow;
    }
  }

  @override
  Future<String?> updateTelegramAuthorUsername(
    int listingId,
    String? username,
  ) async {
    try {
      final trimmed = username?.trim();
      final normalized = (trimmed == null || trimmed.isEmpty)
          ? null
          : trimmed.replaceAll(RegExp(r"^@+"), "").trim();
      final response =
          await _oauthApiClient.patch<dynamic, _SetTelegramAuthorUsernameBody>(
        "/admin/listings/$listingId/telegram-author-username",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _SetTelegramAuthorUsernameBody(
          telegramAuthorUsername:
              (normalized != null && normalized.isEmpty) ? null : normalized,
        ),
      );
      if (response is Map<String, dynamic>) {
        final stored = response["telegram_author_username"];
        if (stored is String) return stored;
      }
      return normalized;
    } catch (e) {
      logger.d(
        "Error updating telegram author username for listing $listingId: $e",
      );
      rethrow;
    }
  }
}
