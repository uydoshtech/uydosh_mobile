import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";

/// Shared “ensure auth → create/find conversation → push chat → toast errors”
/// entry path for listing + gig surfaces.
///
/// [ChatScreen.routeName] delegates to [chatRouteName] so deep-link ids stay
/// in sync.
abstract final class ConversationEntryFlow {
  /// Deep-link route segment; [ChatScreen.routeName] forwards here.
  static String chatRouteName(int conversationId) => "/chat/$conversationId";

  static Future<void> pushChatShell(
    BuildContext context, {
    required int conversationId,
    required Widget chatScreenChild,
  }) async {
    try {
      if (!context.mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: chatRouteName(conversationId)),
          builder: (_) => chatScreenChild,
        ),
      );
    } catch (e, st) {
      logger.d("ConversationEntryFlow.pushChatShell failed: $e\n$st");
      ToastReporting.errorMessage(context, "Failed to open chat: $e");
    }
  }

  /// Listing thread: refresh session identity, block self-chat, create or resolve
  /// an existing inbox row, then run caller-supplied navigation + analytics.
  static Future<void> openListingThread({
    required BuildContext context,
    required ListingDetail listingDetail,
    required int analyticsListingRouteId,
    required Future<void> Function(Conversation conversation) pushNewThread,
    required Future<void> Function(
      ConversationSummary summary,
      int currentUserId,
    ) pushExistingThread,
  }) async {
    try {
      if (!AuthFlow.requireAuth(context)) return;

      await UserListingState().refreshUserId();
      final currentUserId = await SessionManager.getUserId();

      if (currentUserId == null) {
        ToastReporting.errorKey(context, "error_not_authenticated");
        return;
      }

      if (currentUserId == listingDetail.user.id) {
        ToastReporting.errorKey(context, "error_cannot_message_self");
        return;
      }

      if (PeerInteractionEligibility
          .isInternalListingChatDisabledForPublisherEmail(
        listingDetail.user.email,
      )) {
        ToastReporting.errorKey(context, "error_listing_chat_disabled");
        return;
      }

      var loadingVisible = false;
      void dismissLoading() {
        if (!loadingVisible || !context.mounted) return;
        Navigator.of(context).pop();
        loadingVisible = false;
      }

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: HouseLoadingIndicator()),
      );
      loadingVisible = true;

      final messagingService = getIt<IMessagingService>();

      try {
        final conversation = await messagingService.createConversation(
          listingId: listingDetail.id,
          participantId: listingDetail.user.id,
        );
        final isFirstOpen = !_conversationHadMessages(conversation);

        dismissLoading();

        if (!context.mounted) return;

        if (isFirstOpen) {
          await getIt<AppAnalyticsService>().logConversationStarted(
            listingId: analyticsListingRouteId,
            ownerId: listingDetail.user.id,
          );
        }

        await pushNewThread(conversation);
      } catch (e) {
        logger.d("ConversationEntryFlow listing create failed: $e");
        final message = e.toString();
        final isAlreadyExists = _looksLikeListingConversationExists(message);

        if (isAlreadyExists) {
          final authed = await SessionManager.isAuthenticated();
          if (!authed) {
            dismissLoading();
            return;
          }

          try {
            final conversations = await messagingService.getConversations(
              page: 1,
              limit: 100,
            );

            ConversationSummary? existing;
            for (final conv in conversations.data) {
              if (conv.listingId == listingDetail.id &&
                  (conv.initiatorId == currentUserId ||
                      conv.participantId == currentUserId)) {
                existing = conv;
                break;
              }
            }

            if (existing == null) {
              throw Exception("Conversation not found in list");
            }

            dismissLoading();

            if (!context.mounted) return;

            await pushExistingThread(existing, currentUserId);

            ToastReporting.infoKey(context, "opening_existing_conversation");
            return;
          } catch (findError, st) {
            logger.d(
              "ConversationEntryFlow could not recover existing listing chat: $findError\n$st",
            );
          }
        }

        dismissLoading();
        rethrow;
      }
    } catch (e) {
      logger.d("ConversationEntryFlow listing thread error: $e");
      var errorMessage = L10n.get("conversation_failed");
      if (e.toString().contains("DioException")) {
        errorMessage = "Network error: ${e.toString()}";
      } else {
        errorMessage = "Error: ${e.toString()}";
      }
      ToastReporting.errorMessage(context, errorMessage);
    }
  }

  /// Opens (or creates) the gig-request thread from task detail (provider → client).
  static Future<void> openGigRequestChat({
    required BuildContext context,
    required GigRequest request,
    required Widget Function(Conversation conversation) buildChat,
  }) async {
    if (!AuthFlow.requireAuth(context)) return;
    try {
      await UserListingState().refreshUserId();
      final currentUserId = await SessionManager.getUserId();
      if (currentUserId == null) {
        ToastReporting.errorKey(context, "error_not_authenticated");
        return;
      }
      if (currentUserId == request.clientUserId) {
        ToastReporting.errorKey(context, "error_cannot_message_self");
        return;
      }

      final svc = getIt<IMessagingService>();
      final conv = await svc.createConversation(gigRequestId: request.id);
      if (!context.mounted) return;

      await pushChatShell(
        context,
        conversationId: conv.id,
        chatScreenChild: buildChat(conv),
      );
    } catch (e, st) {
      logger.d("ConversationEntryFlow gig request chat failed: $e\n$st");
      ToastReporting.errorKey(context, "gigs_request_contact_failed");
    }
  }

  /// Opens (or creates) the gig-booking thread (used from offer detail + bookings list).
  static Future<void> openGigBookingChat({
    required BuildContext context,
    required int gigBookingId,
    required Widget Function(Conversation conversation) buildChat,
    String errorMessageKey = "conversation_failed",
  }) async {
    if (!AuthFlow.requireAuth(context)) return;
    try {
      final svc = getIt<IMessagingService>();
      final conv = await svc.createConversation(gigBookingId: gigBookingId);
      if (!context.mounted) return;

      await pushChatShell(
        context,
        conversationId: conv.id,
        chatScreenChild: buildChat(conv),
      );
    } catch (e, st) {
      logger.d("ConversationEntryFlow gig booking chat failed: $e\n$st");
      ToastReporting.errorKey(context, errorMessageKey);
    }
  }

  /// POST /conversations is idempotent — it returns an existing row when one
  /// already exists. Use message metadata to tell a genuinely new thread apart.
  static bool _conversationHadMessages(Conversation conversation) {
    final lastAt = conversation.lastMessageAt;
    return lastAt != null && lastAt.trim().isNotEmpty;
  }

  static bool _looksLikeListingConversationExists(String message) {
    final containsExact = message.contains(
      "Conversation already exists for this listing and participants",
    );
    final containsPartial = message.contains("Conversation already exists");
    final containsGeneric = message.contains("already exists");
    final isDio400 =
        message.contains("DioException") && message.contains("400");
    return containsExact || containsPartial || containsGeneric || isDio400;
  }
}
