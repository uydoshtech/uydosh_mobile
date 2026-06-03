import "package:uy_dosh/base/logger/logger.dart";
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
      fieldName:
          (json["field_name"] ?? json["fieldName"]) as String? ?? "",
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
      outputJson:
          (json["output_json"] ?? json["outputJson"]) as Map<String, dynamic>? ??
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
      messageDate:
          (json["messageDate"] ?? json["message_date"]) as String?,
      authorUsername:
          (json["authorUsername"] ?? json["author_username"]) as String?,
      authorDisplayName:
          (json["authorDisplayName"] ?? json["author_display_name"])
              as String?,
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
    final approvedJson =
        json["latestApprovedVersion"] as Map<String, dynamic>?;
    final diffs = (json["correctionDiffs"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ParserCorrectionDiff.fromJson)
        .toList();
    return ParserReviewBundle(
      listing: json["listing"] as Map<String, dynamic>? ?? const {},
      rawSource:
          rawSourceJson != null ? ParserRawSource.fromJson(rawSourceJson) : null,
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
}

abstract class IListingParserReviewAdminService {
  Future<ParserReviewBundle> getParserReview(int listingId);
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
}
