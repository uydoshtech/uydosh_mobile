import "package:uy_dosh/domain/models/conversation.dart";

/// Resolves the other participant in a two-party conversation.
///
/// When [viewerUserId] is null (session not hydrated yet), returns null so
/// callers don't mistakenly treat `initiator_id == null` as false and pick the
/// wrong peer — which surfaces as "chatting with yourself" for outbound rows.
int? conversationCounterpartyUserId(
  ConversationSummary conversation,
  int? viewerUserId,
) {
  if (viewerUserId == null) return null;
  return conversation.initiatorId == viewerUserId
      ? conversation.participantId
      : conversation.initiatorId;
}

/// Whether this thread should appear in the messages inbox.
///
/// Conversations opened from a listing but with no messages yet keep
/// [ConversationSummary.lastMessageAt] null; [ConversationSummary.updatedAt]
/// still changes, so we must not use updated time alone.
bool conversationHasMessagesForInbox(ConversationSummary conversation) {
  final lastAt = conversation.lastMessageAt?.trim();
  if (lastAt != null && lastAt.isNotEmpty) {
    return true;
  }
  final content = conversation.lastMessageContent?.trim();
  return content != null && content.isNotEmpty;
}
