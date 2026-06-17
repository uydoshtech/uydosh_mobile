import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/util/save_export.dart" as save_export;

Map<String, dynamic> _requireJsonMap(dynamic response, String errorMessage) {
  if (response is! Map) {
    throw Exception(errorMessage);
  }
  return Map<String, dynamic>.from(response);
}

class TelegramSyncStats {
  TelegramSyncStats({
    required this.scanned,
    required this.skippedNoPeer,
    required this.skippedBroadcast,
    required this.batches,
    required this.missingIds,
    required this.duplicatePolicy,
    this.chatKey,
    this.syncedTelegramMessageIdsCount,
  });

  factory TelegramSyncStats.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    final rawCount = json["syncedTelegramMessageIdsCount"];
    return TelegramSyncStats(
      scanned: n(json["scanned"]),
      skippedNoPeer: n(json["skippedNoPeer"]),
      skippedBroadcast: n(json["skippedBroadcast"]),
      batches: n(json["batches"]),
      missingIds: (json["missingIds"] as List<dynamic>?)
              ?.map((e) => e is int ? e : int.tryParse("$e") ?? 0)
              .toList() ??
          [],
      duplicatePolicy: json["duplicatePolicy"] as String? ?? "",
      chatKey: json["chatKey"] as String?,
      syncedTelegramMessageIdsCount: rawCount == null ? null : n(rawCount),
    );
  }

  final int scanned;
  final int skippedNoPeer;
  final int skippedBroadcast;
  final int batches;
  final List<int> missingIds;
  final String duplicatePolicy;
  final String? chatKey;

  /// How many Telegram message ids this sync wrote (listing import scopes to these when supported).
  final int? syncedTelegramMessageIdsCount;
}

class TelegramListingImportStats {
  TelegramListingImportStats({
    required this.groupsTotal,
    required this.imported,
    required this.skippedEmpty,
    required this.skippedBroadcast,
    required this.skippedNoListingType,
    required this.skippedFailed,
    required this.errors,
    this.scopedToTelegramMessageIds,
  });

  factory TelegramListingImportStats.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    final rawScoped = json["scopedToTelegramMessageIds"];
    return TelegramListingImportStats(
      groupsTotal: n(json["groupsTotal"]),
      imported: n(json["imported"]),
      skippedEmpty: n(json["skippedEmpty"]),
      skippedBroadcast: n(json["skippedBroadcast"]),
      skippedNoListingType: n(json["skippedNoListingType"]),
      skippedFailed: n(json["skippedFailed"]),
      errors: (json["errors"] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? "")
              .toList() ??
          [],
      scopedToTelegramMessageIds: rawScoped == null ? null : n(rawScoped),
    );
  }

  final int groupsTotal;
  final int imported;
  final int skippedEmpty;
  final int skippedBroadcast;
  final int skippedNoListingType;
  final int skippedFailed;
  final List<String> errors;

  /// Present when import was limited to specific `telegram_message_id`s from the sync run.
  final int? scopedToTelegramMessageIds;
}

class TelegramSyncRunResult {
  TelegramSyncRunResult({
    required this.sync,
    this.listingImport,
    this.listingImportNote,
  });

  factory TelegramSyncRunResult.fromJson(Map<String, dynamic> json) {
    final syncRaw = json["sync"];
    if (syncRaw is! Map) {
      throw Exception("Unexpected sync payload");
    }
    Map<String, dynamic>? listingRaw;
    final li = json["listingImport"];
    if (li is Map) {
      listingRaw = Map<String, dynamic>.from(li);
    }
    return TelegramSyncRunResult(
      sync: TelegramSyncStats.fromJson(Map<String, dynamic>.from(syncRaw)),
      listingImport: listingRaw != null
          ? TelegramListingImportStats.fromJson(listingRaw)
          : null,
      listingImportNote: json["listingImportNote"] as String?,
    );
  }

  final TelegramSyncStats sync;
  final TelegramListingImportStats? listingImport;
  final String? listingImportNote;
}

class _TelegramSyncPostBody implements IJsonEncodable {
  _TelegramSyncPostBody({
    required this.chat,
    required this.limit,
    required this.newestFirst,
    required this.skipListingImport,
    this.importUserId,
  });

  final String chat;
  final int limit;
  final bool newestFirst;
  final bool skipListingImport;
  final int? importUserId;

  @override
  dynamic toJson() => {
        "chat": chat,
        "limit": limit,
        "newestFirst": newestFirst,
        if (importUserId != null) "importUserId": importUserId,
        "skipListingImport": skipListingImport,
      };
}

class ClearListingsResult {
  ClearListingsResult({
    required this.listingsDeleted,
    required this.listingsRemaining,
    required this.ingestedMessagesDeleted,
    required this.ingestedMessagesRemaining,
  });

  factory ClearListingsResult.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return ClearListingsResult(
      listingsDeleted: n(json["listingsDeleted"]),
      listingsRemaining: n(json["listingsRemaining"]),
      ingestedMessagesDeleted: n(json["ingestedMessagesDeleted"]),
      ingestedMessagesRemaining: n(json["ingestedMessagesRemaining"]),
    );
  }

  final int listingsDeleted;
  final int listingsRemaining;

  /// TRUNCATE ... CASCADE on `listings` also wipes `telegram_ingested_messages`
  /// (it has a FK reference), so we surface that impact in the response.
  final int ingestedMessagesDeleted;
  final int ingestedMessagesRemaining;
}

class ClearIngestedMessagesResult {
  ClearIngestedMessagesResult({
    required this.ingestedMessagesDeleted,
    required this.ingestedMessagesRemaining,
  });

  factory ClearIngestedMessagesResult.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return ClearIngestedMessagesResult(
      ingestedMessagesDeleted: n(json["ingestedMessagesDeleted"]),
      ingestedMessagesRemaining: n(json["ingestedMessagesRemaining"]),
    );
  }

  final int ingestedMessagesDeleted;
  final int ingestedMessagesRemaining;
}

class _EmptyRequest implements IJsonEncodable {
  const _EmptyRequest();

  @override
  dynamic toJson() => <String, dynamic>{};
}

class TelegramChannelsResponse {
  TelegramChannelsResponse({
    required this.channels,
    this.channel,
  });

  factory TelegramChannelsResponse.fromJson(Map<String, dynamic> json) {
    return TelegramChannelsResponse(
      channels: (json["channels"] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? "")
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          [],
      channel: json["channel"] as String?,
    );
  }

  final List<String> channels;
  final String? channel;
}

class _AddTelegramChannelBody implements IJsonEncodable {
  const _AddTelegramChannelBody({required this.channel});

  final String channel;

  @override
  dynamic toJson() => {"channel": channel};
}

abstract class IAdminTelegramSyncService {
  Future<TelegramChannelsResponse> getChannels();

  Future<TelegramChannelsResponse> addChannel(String channel);

  Future<TelegramSyncRunResult> runSync({
    required String chat,
    required int limit,
    required bool newestFirst,
    required bool skipListingImport,
    int? importUserId,
  });

  /// GET `/admin/telegram/ingested-messages/export` — saves JSONL via share sheet (mobile/desktop) or browser download (web).
  Future<void> downloadIngestedExport({
    String? chatKeyFilter,
    int maxRows = 100000,
  });

  /// DELETE `/admin/listings/all` — wipes every row from the `listings` table and all
  /// referencing rows (photos, amenities, favorites, complaints, conversations, ingested
  /// messages, etc.). Destructive; resets sequence ids.
  Future<ClearListingsResult> clearAllListings();

  /// DELETE `/admin/telegram/ingested-messages/all` — wipes every row from the
  /// `telegram_ingested_messages` table. Does not touch `listings`.
  Future<ClearIngestedMessagesResult> clearAllIngestedMessages();
}

class AdminTelegramSyncService implements IAdminTelegramSyncService {
  AdminTelegramSyncService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  static const Duration _runTimeout = Duration(minutes: 15);
  static const Duration _exportReceiveTimeout = Duration(minutes: 30);

  @override
  Future<TelegramChannelsResponse> getChannels() async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "/admin/telegram/channels",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );
      final map =
          _requireJsonMap(response, "Unexpected telegram channels response");
      return TelegramChannelsResponse.fromJson(map);
    } catch (e) {
      logger.d("Load telegram channels error: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramChannelsResponse> addChannel(String channel) async {
    try {
      final response = await _oauthApiClient.post<dynamic, IJsonEncodable>(
        "/admin/telegram/channels",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _AddTelegramChannelBody(channel: channel),
      );
      final map =
          _requireJsonMap(response, "Unexpected telegram channels response");
      return TelegramChannelsResponse.fromJson(map);
    } catch (e) {
      logger.d("Add telegram channel error: $e");
      rethrow;
    }
  }

  @override
  Future<TelegramSyncRunResult> runSync({
    required String chat,
    required int limit,
    required bool newestFirst,
    required bool skipListingImport,
    int? importUserId,
  }) async {
    try {
      final response = await _oauthApiClient.post<dynamic, IJsonEncodable>(
        "/admin/telegram/sync",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _TelegramSyncPostBody(
          chat: chat,
          limit: limit,
          newestFirst: newestFirst,
          skipListingImport: skipListingImport,
          importUserId: importUserId,
        ),
        options: Options(
          receiveTimeout: _runTimeout,
          sendTimeout: const Duration(minutes: 2),
        ),
      );
      final map =
          _requireJsonMap(response, "Unexpected telegram sync response");
      return TelegramSyncRunResult.fromJson(map);
    } catch (e) {
      logger.d("Telegram sync error: $e");
      rethrow;
    }
  }

  @override
  Future<void> downloadIngestedExport({
    String? chatKeyFilter,
    int maxRows = 100000,
  }) async {
    try {
      final trimmed = chatKeyFilter?.trim();
      final bytes = await _oauthApiClient.getBytes(
        "/admin/telegram/ingested-messages/export",
        queryParameters: {
          "maxRows": maxRows,
          if (trimmed != null && trimmed.isNotEmpty) "chatKey": trimmed,
        },
        options: Options(receiveTimeout: _exportReceiveTimeout),
      );
      final day = DateTime.now().toIso8601String().split("T").first;
      final rawSlug = trimmed ?? "all";
      final safe = rawSlug.replaceAll(RegExp(r"[^\w:-]+"), "_");
      final name = "telegram_ingested_${safe}_$day.jsonl";
      await save_export.saveExportBytes(bytes, name);
    } catch (e) {
      logger.d("Telegram ingested export error: $e");
      rethrow;
    }
  }

  @override
  Future<ClearListingsResult> clearAllListings() async {
    try {
      final response = await _oauthApiClient.delete<dynamic, IJsonEncodable>(
        "/admin/listings/all",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: const _EmptyRequest(),
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
      );
      final map =
          _requireJsonMap(response, "Unexpected clear listings response");
      return ClearListingsResult.fromJson(map);
    } catch (e) {
      logger.d("Clear all listings error: $e");
      rethrow;
    }
  }

  @override
  Future<ClearIngestedMessagesResult> clearAllIngestedMessages() async {
    try {
      final response = await _oauthApiClient.delete<dynamic, IJsonEncodable>(
        "/admin/telegram/ingested-messages/all",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: const _EmptyRequest(),
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
      );
      final map = _requireJsonMap(
          response, "Unexpected clear ingested messages response");
      return ClearIngestedMessagesResult.fromJson(map);
    } catch (e) {
      logger.d("Clear ingested messages error: $e");
      rethrow;
    }
  }
}
