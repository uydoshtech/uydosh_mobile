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
    this.belowBubble,
    this.bubbleAccentColor,
    super.key,
  });

  /// Whether this is the current user's message (right-aligned, avatar on right).
  final bool isFromCurrentUser;

  /// Content inside the bubble.
  final Widget bubbleChild;

  /// Optional row rendered **below** [ChatBubbleWithTail] (outside the painted
  /// bubble). Use for controls that should visually overlap the bubble bottom
  /// (e.g. reaction chip) without breaking hit tests.
  ///
  /// [maxWidth] is the upper bound from the surrounding [LayoutBuilder] (the
  /// chat [Flexible] lane), for inset math. The bubble column is wrapped in
  /// [IntrinsicWidth] so [belowBubble] aligns to the bubble, not the full lane.
  ///
  /// Do not put a [LayoutBuilder] inside [belowBubble]: [IntrinsicWidth] would
  /// then trigger the intrinsic-dimension assert.
  final Widget Function(BuildContext context, double maxWidth)? belowBubble;

  /// Initials for avatar on the left (other user / support).
  final String? leftAvatarInitials;

  /// Initials for avatar on the right (current user / support staff).
  final String? rightAvatarInitials;

  /// Optional avatar image URL (raw or resolvable) for the left avatar.
  final String? leftAvatarUrl;

  /// Optional avatar image URL (raw or resolvable) for the right avatar.
  final String? rightAvatarUrl;

  /// Optional role/accent treatment applied by [ChatBubbleWithTail].
  final Color? bubbleAccentColor;

  @override
  Widget build(BuildContext context) {
    final bubbleColumnCrossAxis =
        isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final Widget flexibleInner;
    if (belowBubble == null) {
      flexibleInner = ChatBubbleWithTail(
        isFromCurrentUser: isFromCurrentUser,
        accentColor: bubbleAccentColor,
        child: bubbleChild,
      );
    } else {
      // [IntrinsicWidth] ties the column width to the bubble so an [Align]
      // bottomEnd in [belowBubble] hugs the bubble, not the [Flexible] lane.
      // Lane [maxWidth] comes only from this outer [LayoutBuilder], not from a
      // [LayoutBuilder] under [IntrinsicWidth].
      flexibleInner = LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: isFromCurrentUser
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: bubbleColumnCrossAxis,
                children: [
                  ChatBubbleWithTail(
                    isFromCurrentUser: isFromCurrentUser,
                    accentColor: bubbleAccentColor,
                    child: bubbleChild,
                  ),
                  belowBubble!(context, constraints.maxWidth),
                ],
              ),
            ),
          );
        },
      );
    }

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
              child: flexibleInner,
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
