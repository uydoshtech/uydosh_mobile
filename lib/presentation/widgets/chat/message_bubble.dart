import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class MessageBubble extends StatefulWidget {

  const MessageBubble({
    required this.message, required this.isCurrentUser, super.key,
    this.isLatest = false,
    this.onAnimationComplete,
    this.currentUserProfile,
    this.otherUserInitials,
  });
  final Message message;
  final bool isCurrentUser;
  final bool isLatest;
  final VoidCallback? onAnimationComplete;
  final UserProfile? currentUserProfile;
  final String? otherUserInitials;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller (for the shake/elastic effect)
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Fade animation controller (for the fade-in effect)
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create a stretch and shrink animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Create a fade-in animation (from 0.5 to 1.0 opacity)
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Only start the animation if this is the latest message
    if (widget.isLatest) {
      // Start scale animation immediately
      _scaleAnimationController.forward();

      // Start fade animation with a slight delay (100ms) to create overlap
      Future.delayed(const Duration(milliseconds: 100), () {
        _fadeAnimationController.forward();
      });

      // Wait for both animations to complete (scale takes 500ms, fade starts at 100ms and takes 500ms, so total is 600ms)
      Future.delayed(const Duration(milliseconds: 600), () {
        widget.onAnimationComplete?.call();
      });
    } else {
      // For older messages, set to final state immediately
      _scaleAnimationController.value = 1.0;
      _fadeAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final ownMessageTextColor = _getThemeAwareOwnMessageTextColor(
          themeState,
        );
        final otherMessageTextColor = _getThemeAwareOtherMessageTextColor(
          themeState,
        );

        final textColor = widget.isCurrentUser
            ? ownMessageTextColor
            : otherMessageTextColor;

        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: ChatMessageRow(
                  isFromCurrentUser: widget.isCurrentUser,
                  leftAvatarInitials: _getOtherUserInitials(),
                  rightAvatarInitials: _getCurrentUserInitials(),
                  bubbleChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMessageContent(
                        widget.message.content,
                        textColor,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ThemeIcon(
                            Icons.access_time,
                            size: 10,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatTime(widget.message.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                          if (widget.isCurrentUser) ...[
                            const SizedBox(width: 4),
                            _buildCheckmarks(textColor),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _getOtherUserInitials() {
    if (widget.otherUserInitials != null &&
        widget.otherUserInitials!.isNotEmpty) {
      return widget.otherUserInitials;
    }
    final sender = widget.message.sender;
    var userName = sender?.profile?.name;
    if (userName == null || userName.isEmpty) {
      if (sender?.email != null && sender!.email.isNotEmpty) {
        final emailParts = sender.email.split("@");
        if (emailParts.isNotEmpty) userName = emailParts[0];
      }
    }
    return StringUtils.extractInitials(userName);
  }

  String? _getCurrentUserInitials() {
    return StringUtils.extractInitials(widget.currentUserProfile?.name);
  }

  /// Get theme-aware own message text color
  Color _getThemeAwareOwnMessageTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for own messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.black; // Black text for own messages in blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware other message text color
  Color _getThemeAwareOtherMessageTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for other messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text for other messages in blue theme
    }
    return Colors.black; // Default to black
  }

  /// Regex to match emoji characters (covers emoticons, symbols, etc.)
  static final _emojiRegex = RegExp(
    r"[\u{1F300}-\u{1F9FF}\u{1F600}-\u{1F64F}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]",
    unicode: true,
  );

  static const _baseFontSize = 14.0;
  static const _emojiFontSize = 28.0; // 2x base size for emojis

  Widget _buildMessageContent(String text, Color color) {
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _emojiRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(color: color, fontSize: _baseFontSize),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(color: color, fontSize: _emojiFontSize),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(color: color, fontSize: _baseFontSize),
        ),
      );
    }
    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: _baseFontSize),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // Always show only time, no date
      if (difference.inMinutes > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return L10n.get("now");
      }
    } catch (e) {
      return "";
    }
  }

  /// Build checkmarks for message status
  /// Single checkmark = sent, double checkmark = read by recipient
  Widget _buildCheckmarks(Color ownBubbleTextColor) {
    final isReadByRecipient = widget.message.isReadByRecipient ?? false;
    // WhatsApp-style blue for “read” double ticks on white outgoing bubbles.
    const readColor = Color(0xFF34B7F1);
    return ThemeIcon(
      isReadByRecipient ? Icons.done_all : Icons.check,
      size: 14,
      color: isReadByRecipient
          ? readColor
          : ownBubbleTextColor.withValues(alpha: 0.45),
    );
  }
}
