import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_bubble_with_tail.dart";

/// Row layout for chat/support messages: [avatar?] [bubble] [avatar?].
/// Used in user messaging (chat) and support chat screens.
class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    required this.isFromCurrentUser,
    required this.bubbleChild,
    this.leftAvatarInitials,
    this.rightAvatarInitials,
    this.leftAvatarUrl,
    this.rightAvatarUrl,
    super.key,
  });

  /// Whether this is the current user's message (right-aligned, avatar on right).
  final bool isFromCurrentUser;

  /// Content inside the bubble.
  final Widget bubbleChild;

  /// Initials for avatar on the left (other user / support).
  final String? leftAvatarInitials;

  /// Initials for avatar on the right (current user / support staff).
  final String? rightAvatarInitials;

  /// Optional avatar image URL (raw or resolvable) for the left avatar.
  final String? leftAvatarUrl;

  /// Optional avatar image URL (raw or resolvable) for the right avatar.
  final String? rightAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            ChatAvatar(
              isCurrentUser: false,
              initials: leftAvatarInitials,
              avatarUrl: leftAvatarUrl,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                left: isFromCurrentUser ? 0 : 10,
                right: isFromCurrentUser ? 10 : 0,
              ),
              child: ChatBubbleWithTail(
                isFromCurrentUser: isFromCurrentUser,
                child: bubbleChild,
              ),
            ),
          ),
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            ChatAvatar(
              isCurrentUser: true,
              initials: rightAvatarInitials,
              avatarUrl: rightAvatarUrl,
            ),
          ],
        ],
      ),
    );
  }
}
