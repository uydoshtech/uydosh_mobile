import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/conversation.dart";

abstract class IAdminListingConversationsService {
  Future<AdminListingConversationsResult> listForListing(int listingId);
}

class AdminListingConversationsResult {

  AdminListingConversationsResult({
    required this.listingUserId,
    required this.conversations,
  });

  final int listingUserId;
  final List<ConversationSummary> conversations;
}

/// Admin moderation: `/admin/listings/:id/conversations`.
class AdminListingConversationsService implements IAdminListingConversationsService {
  AdminListingConversationsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<AdminListingConversationsResult> listForListing(int listingId) async {
    if (!await SessionManager.isAuthenticated()) {
      throw Exception("User not authenticated. Please log in first.");
    }

    try {
      final raw = await _oauthApiClient.get<Map<String, dynamic>>(
        "/admin/listings/$listingId/conversations",
        (json) => json as Map<String, dynamic>,
        basePath: EnvironmentUtil.basePath,
      );

      final inner = raw["data"];
      if (inner is! Map<String, dynamic>) {
        throw Exception("Unexpected listing conversations payload");
      }

      final uid = (inner["listing_user_id"] as num?)?.toInt();
      if (uid == null) {
        throw Exception("Missing listing owner id");
      }

      final listRaw = inner["conversations"];
      final list = listRaw is List ? listRaw : const <dynamic>[];

      final conversations =
          list
              .map(
                (e) =>
                    ConversationSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList();

      return AdminListingConversationsResult(
        listingUserId: uid,
        conversations: conversations,
      );
    } catch (e) {
      logger.d("❌ Admin listing conversations: $e");
      rethrow;
    }
  }
}
