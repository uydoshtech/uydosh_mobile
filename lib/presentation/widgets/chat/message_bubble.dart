import "dart:async";
import "dart:math" as math;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/message_translation.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_bubble_with_tail.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/chat/message_reaction_catalog.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    required this.message,
    required this.isCurrentUser,
    super.key,
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
    this.onSetReaction,
    this.onClearReaction,
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

  /// Long-press reaction picker: set or replace the viewer's reaction (server
  /// treats this like a new message for the peer — push + inbox preview).
  final Future<void> Function(String reactionId)? onSetReaction;

  /// Clear the viewer's reaction (optional; used when picking the same emoji).
  final Future<void> Function()? onClearReaction;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  static const double _reactionBadgeHoverHeight = 30;
  static const double _reactionBadgeOutsideShift = 10;

  /// How far the picker extends **below** the bubble top (positive = overlaps glass).
  static const double _reactionToolbarOverlapIntoBubble = 12;

  /// Picker uses a slightly smaller inward trailing inset than the corner badge
  /// so the strip sits nearer the bubble edge.
  static const double _reactionToolbarTowardTrailingEdgePx = 14;

  /// Extra horizontal offset **toward the bubble’s trailing edge** (LTR: right).
  /// Lets the pill sit further right when badge inset is already clamped to 0.
  static const double _reactionToolbarShiftTowardTrailingEndPx = 52;

  late AnimationController _scaleAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _startupFadeTimer;
  Timer? _startupCompleteTimer;
  final GlobalKey _bubbleAnchorKey = GlobalKey();

  /// Reactions are only on the other participant's messages (see [ChatScreen]).
  bool get _reactionsEnabled =>
      !widget.isCurrentUser &&
      (widget.onSetReaction != null || widget.onClearReaction != null);

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
      _startupFadeTimer = Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _fadeAnimationController.forward();
      });

      // Wait for both animations to complete (scale takes 500ms, fade starts at 100ms and takes 500ms, so total is 600ms)
      _startupCompleteTimer = Timer(const Duration(milliseconds: 600), () {
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
    _startupFadeTimer?.cancel();
    _startupCompleteTimer?.cancel();
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

        final textColor =
            widget.isCurrentUser ? ownMessageTextColor : otherMessageTextColor;

        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onLongPress: _reactionsEnabled
                          ? () => _openReactionToolbar(context)
                          : null,
                      onSecondaryTap: _reactionsEnabled
                          ? () => _openReactionToolbar(context)
                          : null,
                      behavior: HitTestBehavior.deferToChild,
                      child: ChatMessageRow(
                        isFromCurrentUser: widget.isCurrentUser,
                        leftAvatarInitials: _getOtherUserInitials(),
                        rightAvatarInitials: _getCurrentUserInitials(),
                        leftAvatarUrl: _getOtherUserAvatarUrl(),
                        rightAvatarUrl: widget.currentUserProfile?.avatarUrl,
                        bubbleChild: KeyedSubtree(
                          key: _bubbleAnchorKey,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final bubbleInnerW = constraints.maxWidth;
                              final myId = widget.message.myReaction;
                              final aggCount = myId != null
                                  ? _aggregateCountForReaction(myId)
                                  : 1;
                              final reactionEndInset =
                                  (_reactionsEnabled && myId != null)
                                      ? _reactionBadgeTrailingEndInset(
                                          bubbleInnerWidth: bubbleInnerW,
                                          aggregateCount: aggCount,
                                        )
                                      : 0.0;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildMessageContent(
                                        _displayText(),
                                        textColor,
                                      ),
                                      if (widget.translation == null &&
                                          widget.isTranslating) ...[
                                        const SizedBox(height: 6),
                                        _TranslationSkeleton(
                                          textColor: textColor,
                                        ),
                                      ],
                                      if (widget.translation != null) ...[
                                        const SizedBox(height: 4),
                                        _TranslationToggleRow(
                                          translation: widget.translation!,
                                          isShowingOriginal:
                                              widget.showOriginal,
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
                                            color: textColor.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            _formatTime(
                                              widget.message.createdAt,
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: textColor.withValues(
                                                alpha: 0.7,
                                              ),
                                            ),
                                          ),
                                          if (_reactionsEnabled) ...[
                                            const SizedBox(width: 6),
                                            IconButton(
                                              onPressed: () =>
                                                  _openReactionToolbar(
                                                context,
                                              ),
                                              style: IconButton.styleFrom(
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding:
                                                    const EdgeInsets.all(2),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                              tooltip: L10n.get(
                                                "reaction_add",
                                                fallback: "Add reaction",
                                              ),
                                              icon: Icon(
                                                Icons.add_reaction_outlined,
                                                size: 16,
                                                color: textColor.withValues(
                                                  alpha: 0.65,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                      top: -22,
                                      end: -22,
                                      child: GestureDetector(
                                        onTap: widget.onRiskBadgeTap,
                                        behavior: HitTestBehavior.opaque,
                                        child: _RiskBadge(
                                          level: widget.riskLevel!,
                                        ),
                                      ),
                                    ),
                                  if (_reactionsEnabled && myId != null)
                                    PositionedDirectional(
                                      bottom: -_reactionBadgeHoverHeight / 2 -
                                          _reactionBadgeOutsideShift,
                                      end: reactionEndInset,
                                      child: _buildMyReactionCornerBadge(
                                        textColor,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_hasReactionRow)
                      _buildReactionStrip(context, textColor),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool get _hasReactionRow => _reactionStripEntries().isNotEmpty;

  /// Strip lists reactions after removing the viewer's own count so their
  /// reaction is only shown on the overlapping corner badge.
  List<MessageReactionCount> _reactionStripEntries() {
    final all = widget.message.reactions ?? [];
    if (!_reactionsEnabled) return all;
    final mine = widget.message.myReaction;
    if (mine == null) return all;

    return all
        .map((e) {
          if (e.reaction != mine) return e;
          final adjusted = e.count - 1;
          if (adjusted <= 0) return null;
          return MessageReactionCount(reaction: e.reaction, count: adjusted);
        })
        .whereType<MessageReactionCount>()
        .toList();
  }

  int _aggregateCountForReaction(String reactionId) {
    final entries = widget.message.reactions ?? [];
    for (final e in entries) {
      if (e.reaction == reactionId) return e.count;
    }
    return 1;
  }

  /// Logical inset from the bubble content's trailing edge: hugs the rounded
  /// corner using [ChatBubbleWithTail.cornerRadius], but clamps using measured
  /// [bubbleInnerWidth] so the badge stays inside short bubbles.
  double _reactionBadgeTrailingEndInset({
    required double bubbleInnerWidth,
    required int aggregateCount,
  }) {
    final R = ChatBubbleWithTail.cornerRadius;
    final badgeR = _reactionBadgeHoverHeight / 2;
    final hugCorner = ((R - badgeR).clamp(0.0, R)) * 0.55;
    final approxBadgeW =
        aggregateCount > 1 ? 56.0 : _reactionBadgeHoverHeight.toDouble();
    const minGapFromStart = 8.0;
    final maxPermittedEndInset =
        (bubbleInnerWidth - approxBadgeW - minGapFromStart).clamp(
      0.0,
      double.infinity,
    );
    return math.min(hugCorner, maxPermittedEndInset);
  }

  /// Same horizontal inset as the posted reaction badge (even before a reaction exists).
  double _reactionToolbarTrailingEndInset(double bubbleInnerWidth) {
    final myId = widget.message.myReaction;
    final agg = myId != null ? _aggregateCountForReaction(myId) : 1;
    return _reactionBadgeTrailingEndInset(
      bubbleInnerWidth: bubbleInnerWidth,
      aggregateCount: agg,
    );
  }

  Widget _buildMyReactionCornerBadge(Color textColor) {
    final id = widget.message.myReaction!;
    final count = _aggregateCountForReaction(id);
    final isRoundCapsule = count <= 1;
    final bubbleRadius = isRoundCapsule ? _reactionBadgeHoverHeight / 2 : 15.0;

    return GestureDetector(
      onTap: widget.onClearReaction != null
          ? () {
              HapticFeedback.lightImpact();
              widget.onClearReaction?.call();
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: LiquidGlassPlate(
        height: _reactionBadgeHoverHeight,
        borderRadius: BorderRadius.circular(bubbleRadius),
        sigma: 10,
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              MessageReactionCatalog.emojiFor(id),
              textAlign: TextAlign.center,
              style: MessageReactionCatalog.textStyleForReactionEmoji(
                17,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            if (count > 1) ...[
              const SizedBox(width: 4),
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Layout for the long-press reaction toolbar (matches toolbar width estimate).
  ({double left, double top}) _reactionToolbarOverlayPosition(
    MediaQueryData mq,
    RenderBox? bubbleBox,
    TextDirection textDir,
  ) {
    const toolbarHeightEstimate = 52.0;
    const toolbarWidthEstimate = 248.0;
    final w = mq.size.width;
    final h = mq.size.height;
    final padTop = mq.padding.top;
    final padBottom = mq.padding.bottom;
    var left = 16.0;
    var top = 100.0;
    if (bubbleBox != null) {
      final o = bubbleBox.localToGlobal(Offset.zero);
      final bubbleTop = o.dy;
      final bubbleW = bubbleBox.size.width;
      final badgeEndInset = _reactionToolbarTrailingEndInset(bubbleW);
      final toolbarEndInset = math.max(
        0.0,
        badgeEndInset - _reactionToolbarTowardTrailingEdgePx,
      );
      top = (bubbleTop +
              _reactionToolbarOverlapIntoBubble -
              toolbarHeightEstimate)
          .clamp(
        padTop + 8,
        h - padBottom - toolbarHeightEstimate - 8,
      );
      if (textDir == TextDirection.ltr) {
        left = o.dx +
            bubbleW -
            toolbarEndInset -
            toolbarWidthEstimate +
            _reactionToolbarShiftTowardTrailingEndPx;
      } else {
        left = o.dx +
            toolbarEndInset -
            toolbarWidthEstimate -
            _reactionToolbarShiftTowardTrailingEndPx;
      }
      left = left.clamp(8.0, w - toolbarWidthEstimate - 8);
    }
    return (left: left, top: top);
  }

  void _openReactionToolbar(BuildContext context) {
    if (!_reactionsEnabled) {
      return;
    }
    HapticFeedback.mediumImpact();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      _openReactionDialog(context);
      return;
    }
    final box =
        _bubbleAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    final textDir = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final mq = MediaQuery.of(context);
    final placement = _reactionToolbarOverlayPosition(mq, box, textDir);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ReactionToolbarOverlayAnimated(
        left: placement.left,
        top: placement.top,
        onRemoved: entry.remove,
        onEmojiChosen: _applyReactionChoice,
      ),
    );
    overlay.insert(entry);
  }

  void _openReactionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final id in MessageReactionCatalog.ids)
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _applyReactionChoice(id);
                    },
                    borderRadius: BorderRadius.circular(26),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        MessageReactionCatalog.emojiFor(id),
                        style:
                            MessageReactionCatalog.textStyleForReactionEmoji(
                          28,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyReactionChoice(String reactionId) async {
    final mine = widget.message.myReaction == reactionId;
    if (mine) {
      await widget.onClearReaction?.call();
    } else {
      await widget.onSetReaction?.call(reactionId);
    }
  }

  Widget _buildReactionStrip(BuildContext context, Color textColor) {
    final entries = _reactionStripEntries();
    final scheme = Theme.of(context).colorScheme;
    final mine = widget.message.myReaction;

    return Padding(
      padding: const EdgeInsets.only(
        top: 2,
        left: 4,
        right: 4,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        alignment:
            widget.isCurrentUser ? WrapAlignment.end : WrapAlignment.start,
        children: [
          for (final e in entries)
            Material(
              color: (!_reactionsEnabled && mine == e.reaction)
                  ? scheme.primaryContainer.withValues(alpha: 0.85)
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: (!_reactionsEnabled &&
                        mine == e.reaction &&
                        widget.onClearReaction != null)
                    ? () {
                        HapticFeedback.lightImpact();
                        widget.onClearReaction?.call();
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MessageReactionCatalog.emojiFor(e.reaction),
                        style: MessageReactionCatalog.textStyleForReactionEmoji(
                          14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 0.5),
                            ),
                          ],
                        ),
                      ),
                      if (e.count > 1) ...[
                        const SizedBox(width: 3),
                        Text(
                          "${e.count}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
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
    final prefixKey =
        _translatedFromKeyForSource(translation.sourceLanguageCode);
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

const Duration _kReactionToolbarOverlayAnimDuration =
    Duration(milliseconds: 220);

class _ReactionToolbarOverlayAnimated extends StatefulWidget {
  const _ReactionToolbarOverlayAnimated({
    required this.left,
    required this.top,
    required this.onRemoved,
    required this.onEmojiChosen,
  });

  final double left;
  final double top;
  final VoidCallback onRemoved;

  /// Invoked **after** the overlay entry is removed.
  final Future<void> Function(String reactionId) onEmojiChosen;

  @override
  State<_ReactionToolbarOverlayAnimated> createState() =>
      _ReactionToolbarOverlayAnimatedState();
}

class _ReactionToolbarOverlayAnimatedState
    extends State<_ReactionToolbarOverlayAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _kReactionToolbarOverlayAnimDuration,
      vsync: this,
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateOut({
    Future<void> Function()? afterOverlayRemoved,
  }) async {
    if (_closing) return;
    _closing = true;
    final detach = widget.onRemoved;
    await _controller.reverse();
    final followUp = afterOverlayRemoved;
    detach();
    await followUp?.call();
  }

  @override
  Widget build(BuildContext context) {
    final curved = _curve;
    final slideTween = Tween<Offset>(
      begin: const Offset(0, 0.065),
      end: Offset.zero,
    ).animate(curved);
    final scaleTween = Tween<double>(begin: 0.91, end: 1).animate(curved);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _animateOut(),
            behavior: HitTestBehavior.opaque,
            child: FadeTransition(
              opacity: curved,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        Positioned(
          left: widget.left,
          top: widget.top,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: slideTween,
              child: ScaleTransition(
                scale: scaleTween,
                alignment: Alignment.bottomCenter,
                child: LiquidGlassPlate(
                  borderRadius: BorderRadius.circular(18),
                  sigma: 12,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final id in MessageReactionCatalog.ids)
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                final applyReaction = widget.onEmojiChosen;
                                final reactionId = id;
                                _animateOut(
                                  afterOverlayRemoved: () =>
                                      applyReaction(reactionId),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Text(
                                  MessageReactionCatalog.emojiFor(id),
                                  style: MessageReactionCatalog
                                      .textStyleForReactionEmoji(20),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level});
  final String level; // medium|high

  @override
  Widget build(BuildContext context) {
    final color = level == 'high' ? Colors.redAccent : Colors.amber.shade700;

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
