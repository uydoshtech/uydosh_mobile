import "package:uy_dosh/domain/models/conversation.dart";

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
