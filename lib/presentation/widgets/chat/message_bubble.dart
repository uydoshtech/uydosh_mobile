import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/message_translation.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class MessageBubble extends StatefulWidget {

  const MessageBubble({
    required this.message, required this.isCurrentUser, super.key,
    this.isLatest = false,
    this.onAnimationComplete,
    this.riskLevel,
    this.riskReason,
    this.onRiskBadgeTap,
    this.currentUserProfile,
    this.otherUserInitials,
    this.otherUserAvatarUrl,
    this.translation,
    this.isTranslating = false,
    this.showOriginal = false,
    this.onToggleTranslation,
  });
  final Message message;
  final bool isCurrentUser;
  final bool isLatest;
  final VoidCallback? onAnimationComplete;
  final String? riskLevel; // 'medium' | 'high' (only other user messages)
  final String? riskReason; // localized, per-message (optional)
  final VoidCallback? onRiskBadgeTap;
  final UserProfile? currentUserProfile;
  final String? otherUserInitials;

  /// Avatar URL (raw or backend-relative) for the other user in this
  /// conversation. Takes precedence over the per-message sender avatar so
  /// the same image is shown even when a given message omits sender profile.
  final String? otherUserAvatarUrl;

  /// Lazily-populated Gemini translation of [message] into the viewer's
  /// preferred language. When non-null we render the translated text by
  /// default and expose a "Show original" / "Show translation" toggle
  /// footer — Airbnb-style.
  final MessageTranslation? translation;

  /// Whether this message is currently being translated in the background.
  /// When true and [translation] is still null, we show a small inline
  /// "Translating…" indicator so users understand work is happening.
  final bool isTranslating;

  /// When true the bubble renders [message.content] even if [translation]
  /// is available. Parent screen owns the toggle state so scroll off-screen
  /// + back preserves it.
  final bool showOriginal;

  /// Invoked when the user taps the translation toggle. Parent is expected
  /// to flip [showOriginal]. No-op when [translation] is null.
  final VoidCallback? onToggleTranslation;

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
        if (!mounted) return;
        _fadeAnimationController.forward();
      });

      // Wait for both animations to complete (scale takes 500ms, fade starts at 100ms and takes 500ms, so total is 600ms)
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
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
                  leftAvatarUrl: _getOtherUserAvatarUrl(),
                  rightAvatarUrl: widget.currentUserProfile?.avatarUrl,
                  bubbleChild: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMessageContent(
                            _displayText(),
                            textColor,
                          ),
                          if (widget.translation == null &&
                              widget.isTranslating) ...[
                            const SizedBox(height: 6),
                            _TranslationSkeleton(textColor: textColor),
                          ],
                          if (widget.translation != null) ...[
                            const SizedBox(height: 4),
                            _TranslationToggleRow(
                              translation: widget.translation!,
                              isShowingOriginal: widget.showOriginal,
                              textColor: textColor,
                              onTap: widget.onToggleTranslation,
                            ),
                          ],
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
                      if (!widget.isCurrentUser &&
                          (widget.riskLevel == 'medium' ||
                              widget.riskLevel == 'high'))
                        PositionedDirectional(
                          // Badge-style: overlap the bubble in the top-right.
                          // Negative offsets keep it outside (hovering above).
                          // Roughly half outside the bubble.
                          top: -22,
                          end: -22,
                          child: GestureDetector(
                            onTap: widget.onRiskBadgeTap,
                            behavior: HitTestBehavior.opaque,
                            child: _RiskBadge(level: widget.riskLevel!),
                          ),
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
      final email = sender?.email;
      if (email != null && email.isNotEmpty) {
        final emailParts = email.split("@");
        if (emailParts.isNotEmpty) userName = emailParts[0];
      }
    }
    return StringUtils.extractInitials(userName);
  }

  String? _getCurrentUserInitials() {
    return StringUtils.extractInitials(widget.currentUserProfile?.name);
  }

  String? _getOtherUserAvatarUrl() {
    final passed = widget.otherUserAvatarUrl;
    if (passed != null && passed.trim().isNotEmpty) return passed;
    return widget.message.sender?.profile?.avatarUrl;
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

  /// Text to render inside the bubble — translation by default when
  /// available, original when the user has toggled "Show original".
  String _displayText() {
    final t = widget.translation;
    if (t == null || widget.showOriginal) return widget.message.content;
    return t.translatedText;
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

class _TranslationSkeleton extends StatelessWidget {
  const _TranslationSkeleton({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    // A subtle 2-line skeleton that sits where translated text will appear.
    // We avoid shimmer to keep it cheap and calm in a dense chat list.
    final base = textColor.withValues(alpha: 0.16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBar(height: 10, widthFactor: 0.78, color: base),
        const SizedBox(height: 6),
        _SkeletonBar(height: 10, widthFactor: 0.52, color: base),
      ],
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.height,
    required this.widthFactor,
    required this.color,
  });

  final double height;
  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor.clamp(0.1, 1.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

/// Small inline footer under a translated bubble: "Translated from 🇷🇺 ·
/// Show original" (or "Show translation" when the user already toggled).
/// Kept in the same bubble width so it reads as part of the message, à la
/// Airbnb's message UI.
class _TranslationToggleRow extends StatelessWidget {
  const _TranslationToggleRow({
    required this.translation,
    required this.isShowingOriginal,
    required this.textColor,
    this.onTap,
  });

  final MessageTranslation translation;
  final bool isShowingOriginal;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final prefixKey = _translatedFromKeyForSource(translation.sourceLanguageCode);
    final basePrefix = prefixKey != null ? L10n.get(prefixKey) : null;
    final targetFlag = _flagForLanguage(translation.targetLanguageCode);
    // Append "→ <target-flag>" so the viewer can see WHICH language the
    // translation is in (today it's implicit = app UI language; making it
    // explicit avoids confusion for multilingual users without adding any
    // new switcher UI).
    final prefix = basePrefix != null && targetFlag != null
        ? "$basePrefix → $targetFlag"
        : basePrefix;
    final toggleLabel = L10n.get(
      isShowingOriginal ? "chat_show_translation" : "chat_show_original",
    );
    final subtleColor = textColor.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) ...[
            Flexible(
              child: Text(
                prefix,
                style: TextStyle(fontSize: 11, color: subtleColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              " · ",
              style: TextStyle(fontSize: 11, color: subtleColor),
            ),
          ],
          Flexible(
            child: Text(
              toggleLabel,
              style: TextStyle(
                fontSize: 11,
                color: subtleColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: subtleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Map Gemini's detected source language → localization key. We only
  /// carry keys for the three languages the backend actually returns
  /// ("en", "ru", "uz"); anything else (unknown, "other") falls back to
  /// just "Show original" with no prefix.
  static String? _translatedFromKeyForSource(String? source) {
    switch (source) {
      case "en":
        return "chat_translated_from_en";
      case "ru":
        return "chat_translated_from_ru";
      case "uz":
        return "chat_translated_from_uz";
      default:
        return null;
    }
  }

  /// Flag emoji per supported translation target. Returns null for unknown
  /// codes so the caller can omit the "→ flag" suffix gracefully.
  static String? _flagForLanguage(String code) {
    switch (code) {
      case "en":
        return "🇺🇸";
      case "ru":
        return "🇷🇺";
      case "uz":
        return "🇺🇿";
      default:
        return null;
    }
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level});
  final String level; // medium|high

  @override
  Widget build(BuildContext context) {
    final color =
        level == 'high' ? Colors.redAccent : Colors.amber.shade700;

    const badgeSize = 22.0;

    // Solid badge: no transparency bleeding the bubble color through.
    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const Center(
          child: ThemeIcon(
            CupertinoIcons.exclamationmark,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
