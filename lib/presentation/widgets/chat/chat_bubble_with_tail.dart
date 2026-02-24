import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/chat/bubble_with_tail_painter.dart";

/// Reusable chat bubble with tail, matching chat/support message styling.
/// Used in user messaging (chat) and support chat screens.
class ChatBubbleWithTail extends StatelessWidget {
  const ChatBubbleWithTail({
    required this.isFromCurrentUser,
    required this.child,
    super.key,
  });

  /// Whether this is the current user's message (right side, white, with border).
  final bool isFromCurrentUser;

  /// Content to display inside the bubble.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final bubbleColor = isFromCurrentUser
            ? Colors.white
            : (themeState.isBlueTheme ? Colors.grey[700]! : Colors.grey[200]!);
        final borderColor = themeState.isLightTheme || themeState.isBlueTheme
            ? Colors.grey[300]!
            : Colors.grey[600]!;
        final shadowColor = themeState.isLightTheme
            ? Colors.black.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.18);

        return CustomPaint(
          painter: BubbleWithTailPainter(
            color: bubbleColor,
            borderColor: isFromCurrentUser ? borderColor : Colors.transparent,
            shadowColor: shadowColor,
            tailPointsRight: isFromCurrentUser,
            hasBorder: isFromCurrentUser,
            radius: 18,
          ),
          child: Container(
            padding: EdgeInsets.only(
              left: isFromCurrentUser ? 16 : 20,
              right: isFromCurrentUser ? 20 : 16,
              top: 12,
              bottom: 12,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
