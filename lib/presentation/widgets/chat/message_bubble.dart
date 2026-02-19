import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/chat/bubble_with_tail_painter.dart";

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
        final ownMessageColor = _getThemeAwareOwnMessageColor(themeState);
        final ownMessageTextColor = _getThemeAwareOwnMessageTextColor(
          themeState,
        );
        final ownMessageBorderColor = _getThemeAwareOwnMessageBorderColor(
          themeState,
        );
        final otherMessageColor = _getThemeAwareOtherMessageColor(themeState);
        final otherMessageTextColor = _getThemeAwareOtherMessageTextColor(
          themeState,
        );
        final bubbleShadowColor = _getThemeAwareBubbleShadowColor(themeState);

        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment:
                        widget.isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      if (!widget.isCurrentUser) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: _getThemeAwareOtherUserAvatarColor(
                              themeState,
                            ),
                            child: _buildOtherUserAvatarContent(themeState),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: widget.isCurrentUser ? 0 : 10,
                            right: widget.isCurrentUser ? 10 : 0,
                          ),
                          child: CustomPaint(
                            painter: BubbleWithTailPainter(
                              color: widget.isCurrentUser
                                  ? ownMessageColor
                                  : otherMessageColor,
                              borderColor: widget.isCurrentUser
                                  ? ownMessageBorderColor
                                  : Colors.transparent,
                              shadowColor: bubbleShadowColor,
                              tailPointsRight: widget.isCurrentUser,
                              hasBorder: widget.isCurrentUser,
                              radius: 18,
                            ),
                            child: Container(
                              padding: EdgeInsets.only(
                                left: widget.isCurrentUser ? 16 : 20,
                                right: widget.isCurrentUser ? 20 : 16,
                                top: 12,
                                bottom: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMessageContent(
                                    widget.message.content,
                                    widget.isCurrentUser
                                        ? ownMessageTextColor
                                        : otherMessageTextColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 10,
                                        color: (widget.isCurrentUser
                                                ? ownMessageTextColor
                                                : otherMessageTextColor)
                                            .withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _formatTime(widget.message.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: (widget.isCurrentUser
                                                  ? ownMessageTextColor
                                                  : otherMessageTextColor)
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      if (widget.isCurrentUser) ...[
                                        const SizedBox(width: 4),
                                        _buildCheckmarks(),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.isCurrentUser) ...[
                        const SizedBox(width: 8),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                _getThemeAwareCurrentUserAvatarColor(
                                  themeState,
                                ),
                            child: _buildCurrentUserAvatarContent(themeState),
                          ),
                        ),
                      ],
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

  /// Get theme-aware own message background color
  Color _getThemeAwareOwnMessageColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White background for own messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White background for own messages in blue theme
    }
    return Colors.white; // Default to white
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

  /// Get theme-aware own message border color
  Color _getThemeAwareOwnMessageBorderColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .grey[300]!; // Light grey border for own messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors
          .grey[300]!; // Light grey border for own messages in blue theme
    }
    return Colors.grey[300]!; // Default to light grey
  }

  /// Get theme-aware message bubble shadow color
  Color _getThemeAwareBubbleShadowColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black.withValues(alpha: 0.12);
    } else if (themeState.isBlueTheme) {
      return Colors.black.withValues(alpha: 0.18);
    }
    return Colors.black.withValues(alpha: 0.12);
  }

  /// Get theme-aware other message background color
  Color _getThemeAwareOtherMessageColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .grey[200]!; // Light grey background for other messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors
          .grey[700]!; // Dark grey background for other messages in blue theme
    }
    return Colors.grey[200]!; // Default to light grey
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

  /// Get theme-aware current user avatar background color
  Color _getThemeAwareCurrentUserAvatarColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black avatar for current user in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.black; // Black avatar for current user in blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware current user avatar icon color
  Color _getThemeAwareCurrentUserAvatarIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .white; // White icon on black avatar for current user in light theme
    } else if (themeState.isBlueTheme) {
      return Colors
          .white; // White icon on black avatar for current user in blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware other user (listing owner) avatar background color
  Color _getThemeAwareOtherUserAvatarColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .white; // White avatar for other user in light theme (inverted)
    } else if (themeState.isBlueTheme) {
      return Colors
          .white; // White avatar for other user in blue theme (inverted)
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware other user (listing owner) avatar icon color
  Color _getThemeAwareOtherUserAvatarIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .black; // Black icon on white avatar for other user in light theme (inverted)
    } else if (themeState.isBlueTheme) {
      return Colors
          .black; // Black icon on white avatar for other user in blue theme (inverted)
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

  /// Build avatar content for other user - first letter(s) of name or person icon
  Widget _buildOtherUserAvatarContent(ThemeState themeState) {
    // Use passed initials if available
    if (widget.otherUserInitials != null &&
        widget.otherUserInitials!.isNotEmpty) {
      return Text(
        widget.otherUserInitials!,
        style: TextStyle(
          color: _getThemeAwareOtherUserAvatarIconColor(themeState),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    // Fallback: Try to get the other user's name from message sender
    final sender = widget.message.sender;
    var userName = sender?.profile?.name;

    // If still no name, try to extract from sender email as fallback
    if (userName == null || userName.isEmpty) {
      if (sender?.email != null && sender!.email.isNotEmpty) {
        // Extract name from email (part before @)
        final emailParts = sender.email.split("@");
        if (emailParts.isNotEmpty) {
          userName = emailParts[0];
        }
      }
    }

    final initials = StringUtils.extractInitials(userName);

    // If we have initials, show them
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: _getThemeAwareOtherUserAvatarIconColor(themeState),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    // Fallback to person icon
    return Icon(
      Icons.person,
      size: 16,
      color: _getThemeAwareOtherUserAvatarIconColor(themeState),
    );
  }

  /// Build avatar content for current user - first letter(s) of name or person icon
  Widget _buildCurrentUserAvatarContent(ThemeState themeState) {
    // Get the current user's name from profile
    final userName = widget.currentUserProfile?.name;

    final initials = StringUtils.extractInitials(userName);

    // If we have initials, show them
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: _getThemeAwareCurrentUserAvatarIconColor(themeState),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    // Fallback to person icon
    return Icon(
      Icons.person,
      size: 16,
      color: _getThemeAwareCurrentUserAvatarIconColor(themeState),
    );
  }

  /// Build checkmarks for message status
  Widget _buildCheckmarks() {
    final themeState = ThemeState();
    final checkmarkColor = _getThemeAwareOwnMessageTextColor(
      themeState,
    ).withValues(alpha: 0.7);

    // For now, show single checkmark for sent messages
    // TODO: Add double checkmark when backend provides read status by other user
    return Icon(Icons.check, size: 12, color: checkmarkColor);
  }
}
