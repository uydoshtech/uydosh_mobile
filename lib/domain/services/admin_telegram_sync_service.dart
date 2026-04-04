import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

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
  });

  factory TelegramSyncStats.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
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
    );
  }

  final int scanned;
  final int skippedNoPeer;
  final int skippedBroadcast;
  final int batches;
  final List<int> missingIds;
  final String duplicatePolicy;
  final String? chatKey;
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
  });

  factory TelegramListingImportStats.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
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
    );
  }

  final int groupsTotal;
  final int imported;
  final int skippedEmpty;
  final int skippedBroadcast;
  final int skippedNoListingType;
  final int skippedFailed;
  final List<String> errors;
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

abstract class IAdminTelegramSyncService {
  Future<TelegramSyncRunResult> runSync({
    required String chat,
    required int limit,
    required bool newestFirst,
    required bool skipListingImport,
    int? importUserId,
  });
}

class AdminTelegramSyncService implements IAdminTelegramSyncService {
  AdminTelegramSyncService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  static const Duration _runTimeout = Duration(minutes: 15);

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
      final map = _requireJsonMap(response, "Unexpected telegram sync response");
      return TelegramSyncRunResult.fromJson(map);
    } catch (e) {
      logger.d("Telegram sync error: $e");
      rethrow;
    }
  }
}
