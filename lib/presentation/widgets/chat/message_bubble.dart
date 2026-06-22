import "dart:async";
import "dart:math" as math;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/message_translation.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_bubble_with_tail.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/chat/message_reaction_catalog.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

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
    this.onLongPressEditOwnMessage,
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

  /// Long-press on **own** text bubbles opens edit in the parent.
  final VoidCallback? onLongPressEditOwnMessage;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  static const double _reactionBadgeHoverHeight = 30;

  /// Vertical paint offset so **half** the on-bubble reaction sits on the bubble
  /// and half below — badge center on the bubble’s bottom edge.
  static const double _reactionBubbleOverlapTranslateY =
      _reactionBadgeHoverHeight / 2;

  /// Pulls the badge a few px further **onto** the bubble so it meets the
  /// bottom corner curve (still mirrored by tail side via alignment).
  static const double _reactionCornerPullOntoBubblePx = 6;

  /// Fine vertical position of overlapping bubble reactions (+ = downward).
  static const double _reactionIconNudgeDownPx = 2;

  /// Emoji size for reactions on the bubble (corner + strip); picker ribbon unchanged.
  static const double _reactionBubbleEmojiSize = 15;

  /// Incoming (peer) bubble: small inward nudge from the **trailing** bottom
  /// corner so the badge does not clip the outer stroke; keep small to stay
  /// tight to the corner (tail is on the leading side).
  static const double _peerBubbleReactionExtraEndInset = 3;

  /// Outgoing bubble: same on the **leading** bottom corner (tail on trailing).
  static const double _outgoingBubbleReactionExtraStartInset = 3;

  /// How far the picker extends **below** the painted bubble top (positive =
  /// overlaps glass). Tuned so most of the pill sits on the bubble like legacy UX.
  static const double _reactionToolbarOverlapIntoBubble = 22;

  /// Picker uses a slightly smaller inward trailing inset than the corner badge
  /// so the strip sits nearer the bubble edge.
  static const double _reactionToolbarTowardTrailingEdgePx = 14;

  /// Extra horizontal offset **toward the bubble’s trailing edge** (LTR: right).
  /// Lets the pill sit further right when badge inset is already clamped to 0.
  static const double _reactionToolbarShiftTowardTrailingEndPx = 52;

  AnimationController? _scaleAnimationController;
  AnimationController? _fadeAnimationController;
  AnimationController? _reactionAppearPulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _reactionAppearPulseScale;
  Timer? _startupFadeTimer;
  Timer? _startupCompleteTimer;
  final GlobalKey _bubbleAnchorKey = GlobalKey();

  /// Reactions are only on the other participant's messages (see [ChatScreen]).
  bool get _reactionsEnabled =>
      !widget.isCurrentUser &&
      (widget.onSetReaction != null || widget.onClearReaction != null);

  bool get _canLongPressEditOwnMessage =>
      widget.isCurrentUser &&
      widget.onLongPressEditOwnMessage != null &&
      widget.message.messageType.toLowerCase() == 'text' &&
      widget.message.isDeleted != true &&
      (widget.message.attachments == null ||
          widget.message.attachments!.isEmpty);

  /// Server / JSON may vary casing; keeps ribbon toggle vs [Message.myReaction] stable.
  static bool _reactionKeysEqual(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  static bool _reactionKeysEqualNullable(String? a, String b) {
    if (a == null || a.trim().isEmpty) return false;
    return _reactionKeysEqual(a, b);
  }

  static int _totalReactionCount(Message m) {
    final r = m.reactions;
    if (r == null || r.isEmpty) return 0;
    return r.fold<int>(0, (sum, e) => sum + e.count);
  }

  @override
  void initState() {
    super.initState();

    // Only start the animation if this is the latest message
    if (widget.isLatest) {
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
          parent: _scaleAnimationController!,
          curve: Curves.elasticOut,
        ),
      );

      // Create a fade-in animation (from 0.5 to 1.0 opacity)
      _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeAnimationController!,
          curve: Curves.easeInOut,
        ),
      );

      // Start scale animation immediately
      _scaleAnimationController!.forward();

      // Start fade animation with a slight delay (100ms) to create overlap
      _startupFadeTimer = Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _fadeAnimationController?.forward();
      });

      // Wait for both animations to complete (scale takes 500ms, fade starts at 100ms and takes 500ms, so total is 600ms)
      _startupCompleteTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        widget.onAnimationComplete?.call();
      });
    } else {
      // Older messages are static rows; avoid allocating idle controllers.
      _scaleAnimation = const AlwaysStoppedAnimation<double>(1);
      _fadeAnimation = const AlwaysStoppedAnimation<double>(1);
    }

    if (_reactionsEnabled) {
      _reactionAppearPulseController = AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      );
      _reactionAppearPulseScale = TweenSequence<double>(
        [
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.14).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
            weight: 23,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.14, end: 1.0).chain(
              CurveTween(curve: Curves.easeInCubic),
            ),
            weight: 23,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.11).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
            weight: 21,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.11, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
            weight: 33,
          ),
        ],
      ).animate(
        CurvedAnimation(
          parent: _reactionAppearPulseController!,
          curve: Curves.linear,
        ),
      );
      _reactionAppearPulseController!.value = 1.0;
    } else {
      _reactionAppearPulseScale = const AlwaysStoppedAnimation<double>(1);
    }
  }

  @override
  void dispose() {
    _startupFadeTimer?.cancel();
    _startupCompleteTimer?.cancel();
    _scaleAnimationController?.dispose();
    _fadeAnimationController?.dispose();
    _reactionAppearPulseController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.message.myReaction;
    final prev = oldWidget.message.myReaction;
    final myReactionAppeared =
        _reactionsEnabled && next != null && next != prev;
    final totalIncreased = _totalReactionCount(widget.message) >
        _totalReactionCount(oldWidget.message);
    final shouldFeedback = myReactionAppeared ||
        (totalIncreased && (widget.isCurrentUser || !myReactionAppeared));
    if (!mounted) return;
    if (shouldFeedback) {
      HapticFeedbackUtils.tapticChain();
      SendSoundUtils.playSendSound();
    }
    if (_reactionsEnabled && next != null && next != prev) {
      _reactionAppearPulseController?.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.messageType.toLowerCase() == "system") {
      return _SystemMessageBubble(content: widget.message.content);
    }

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
        final embedOutgoingReactionsUnderBubble =
            widget.isCurrentUser && _hasReactionRow;

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
                      onLongPress: _canLongPressEditOwnMessage
                          ? widget.onLongPressEditOwnMessage
                          : null,
                      behavior: HitTestBehavior.translucent,
                      child: ChatMessageRow(
                        isFromCurrentUser: widget.isCurrentUser,
                        leftAvatarInitials: _getOtherUserInitials(),
                        rightAvatarInitials: _getCurrentUserInitials(),
                        leftAvatarUrl: _getOtherUserAvatarUrl(),
                        rightAvatarUrl: widget.currentUserProfile?.avatarUrl,
                        bubbleChild: KeyedSubtree(
                          key: _bubbleAnchorKey,
                          child: Stack(
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
                                    _TranslationSkeleton(
                                      textColor: textColor,
                                    ),
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
                                      if (widget.message.isVisiblyEdited) ...[
                                        const SizedBox(width: 6),
                                        ThemeIcon(
                                          Icons.circle,
                                          size: 5,
                                          color: textColor.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          context
                                              .l10n.chat_message_edited_label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: textColor.withValues(
                                              alpha: 0.55,
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
                            ],
                          ),
                        ),
                        belowBubble: _reactionsEnabled
                            ? (ctx, maxWidth) => _buildOverlappingReactionRow(
                                  ctx,
                                  maxWidth,
                                  textColor,
                                )
                            : embedOutgoingReactionsUnderBubble
                                ? (ctx, maxWidth) =>
                                    _buildOutgoingOverlappingReactionRow(
                                      ctx,
                                      maxWidth,
                                      textColor,
                                    )
                                : null,
                      ),
                    ),
                    if (_hasReactionRow &&
                        !embedOutgoingReactionsUnderBubble &&
                        !_reactionsEnabled)
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
    double? approxBadgeWidth,
    double extraEndInset = 0,
  }) {
    final R = ChatBubbleWithTail.cornerRadius;
    final badgeR = _reactionBadgeHoverHeight / 2;
    final hugCorner = ((R - badgeR).clamp(0.0, R)) * 0.38;
    final approxBadgeW = approxBadgeWidth ??
        (aggregateCount > 1 ? 56.0 : _reactionBadgeHoverHeight.toDouble());
    const minGapFromStart = 5.0;
    final maxPermittedEndInset =
        (bubbleInnerWidth - approxBadgeW - minGapFromStart).clamp(
      0.0,
      double.infinity,
    );
    final base = math.min(hugCorner, maxPermittedEndInset);
    return math.min(base + extraEndInset, maxPermittedEndInset);
  }

  /// Bottom-**leading** inset (LTR: left): mirrors [_reactionBadgeTrailingEndInset]
  /// so badges hug the corner opposite the outgoing tail.
  double _reactionBadgeLeadingStartInset({
    required double bubbleInnerWidth,
    required double approxStripWidth,
    double extraStartInset = 0,
  }) {
    final R = ChatBubbleWithTail.cornerRadius;
    final badgeR = _reactionBadgeHoverHeight / 2;
    final hugCorner = ((R - badgeR).clamp(0.0, R)) * 0.38;
    const minGapFromEnd = 5.0;
    final maxPermittedStartInset =
        (bubbleInnerWidth - approxStripWidth - minGapFromEnd).clamp(
      0.0,
      double.infinity,
    );
    final base = math.min(hugCorner, maxPermittedStartInset);
    return math.min(base + extraStartInset, maxPermittedStartInset);
  }

  BoxDecoration _reactionBadgeDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(_reactionBadgeHoverHeight / 2),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.black.withValues(alpha: 0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
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

  /// Reaction control is laid out *below* the painted bubble (reliable hit
  /// testing) and shifted up so it overlaps the corner like the original
  /// overlapping design.
  Widget _buildOverlappingReactionRow(
    BuildContext context,
    double maxWidth,
    Color textColor,
  ) {
    final myId = widget.message.myReaction;
    final aggCount = myId != null ? _aggregateCountForReaction(myId) : 1;
    final otherEntries = _reactionStripEntries();
    final rowW = _approxIncomingReactionRowWidth(
      otherEntries,
      hasMyBadge: myId != null,
      myAggregateCount: aggCount,
    );
    final reactionEndInset = _reactionBadgeTrailingEndInset(
      bubbleInnerWidth: maxWidth,
      aggregateCount: aggCount,
      approxBadgeWidth: rowW,
      extraEndInset: _peerBubbleReactionExtraEndInset,
    );
    final overlapY =
        _reactionBubbleOverlapTranslateY + _reactionCornerPullOntoBubblePx;

    final Widget cornerSlot = myId != null
        ? ScaleTransition(
            scale: _reactionAppearPulseScale,
            alignment: AlignmentDirectional.bottomEnd.resolve(
              Directionality.of(context),
            ),
            child: _buildMyReactionCornerBadge(context, textColor),
          )
        : _buildAddReactionCornerBadge(context, textColor);

    return Transform.translate(
      offset: Offset(0, -overlapY + _reactionIconNudgeDownPx),
      child: SizedBox(
        height: _reactionBadgeHoverHeight,
        child: Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: reactionEndInset),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (otherEntries.isNotEmpty) ...[
                  _buildReactionStrip(
                    context,
                    textColor,
                    outerPadding: EdgeInsets.zero,
                    wrapAlignment: WrapAlignment.end,
                  ),
                  const SizedBox(width: 4),
                ],
                cornerSlot,
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _approxIncomingReactionRowWidth(
    List<MessageReactionCount> otherEntries, {
    required bool hasMyBadge,
    required int myAggregateCount,
  }) {
    var w = _approxOutgoingReactionWidth(otherEntries);
    if (otherEntries.isNotEmpty) {
      w += 4;
    }
    if (hasMyBadge) {
      w += myAggregateCount > 1 ? 56.0 : _reactionBadgeHoverHeight;
    } else {
      w += _reactionBadgeHoverHeight;
    }
    return math.max(w, _reactionBadgeHoverHeight);
  }

  /// Other users’ reactions on **own** messages: overlap the bottom-leading
  /// corner (tail is on the trailing side for outgoing bubbles).
  Widget _buildOutgoingOverlappingReactionRow(
    BuildContext context,
    double maxWidth,
    Color textColor,
  ) {
    final entries = _reactionStripEntries();
    final stripW = _approxOutgoingReactionWidth(entries);
    final reactionStartInset = _reactionBadgeLeadingStartInset(
      bubbleInnerWidth: maxWidth,
      approxStripWidth: stripW,
      extraStartInset: _outgoingBubbleReactionExtraStartInset,
    );
    final overlapY =
        _reactionBubbleOverlapTranslateY + _reactionCornerPullOntoBubblePx;
    return Transform.translate(
      offset: Offset(0, -overlapY + _reactionIconNudgeDownPx),
      child: SizedBox(
        height: _reactionBadgeHoverHeight,
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: reactionStartInset),
            child: _buildReactionStrip(
              context,
              textColor,
              outerPadding: EdgeInsets.zero,
              wrapAlignment: WrapAlignment.start,
            ),
          ),
        ),
      ),
    );
  }

  double _approxOutgoingReactionWidth(List<MessageReactionCount> entries) {
    if (entries.isEmpty) return _reactionBadgeHoverHeight.toDouble();
    double w = 0;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      w += 12 + _reactionBubbleEmojiSize + (e.count > 1 ? 22 : 0);
      if (i > 0) w += 4;
    }
    return math.max(w, _reactionBadgeHoverHeight);
  }

  /// “Smile +” in the same corner slot when the viewer has not reacted yet.
  Widget _buildAddReactionCornerBadge(
    BuildContext context,
    Color textColor,
  ) {
    return Tooltip(
      message: L10n.get(
        "reaction_add",
        fallback: "Add reaction",
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _openReactionToolbar(context);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: _reactionBadgeHoverHeight,
          height: _reactionBadgeHoverHeight,
          decoration: _reactionBadgeDecoration(context),
          child: Icon(
            Icons.add_reaction_outlined,
            size: _reactionBubbleEmojiSize + 2,
            color: textColor.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }

  Widget _buildMyReactionCornerBadge(
    BuildContext context,
    Color textColor,
  ) {
    final id = widget.message.myReaction!;
    final count = _aggregateCountForReaction(id);
    final isSingle = count <= 1;

    final emojiShadows = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 2,
        offset: const Offset(0, 0.5),
      ),
    ];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openReactionToolbar(context);
      },
      behavior: HitTestBehavior.opaque,
      child: isSingle
          ? Container(
              width: _reactionBadgeHoverHeight,
              height: _reactionBadgeHoverHeight,
              decoration: _reactionBadgeDecoration(context),
              child: Center(
                child: Text(
                  MessageReactionCatalog.emojiFor(id),
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: MessageReactionCatalog.textStyleForReactionEmoji(
                    _reactionBubbleEmojiSize,
                    height: 1,
                    shadows: emojiShadows,
                  ),
                ),
              ),
            )
          : Container(
              height: _reactionBadgeHoverHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: _reactionBadgeDecoration(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    MessageReactionCatalog.emojiFor(id),
                    textAlign: TextAlign.center,
                    style: MessageReactionCatalog.textStyleForReactionEmoji(
                      _reactionBubbleEmojiSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
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
    final w = mq.size.width;
    final h = mq.size.height;
    final padTop = mq.padding.top;
    final padBottom = mq.padding.bottom;
    var left = 16.0;
    var top = 100.0;
    if (bubbleBox != null) {
      final o = bubbleBox.localToGlobal(Offset.zero);
      // [_bubbleAnchorKey] sits inside [ChatBubbleWithTail]'s padded container,
      // so [o.dy] is the inner content top — subtract vertical inset to match
      // the visible frosted / painted bubble edge for overlap placement.
      final bubbleTop = o.dy - ChatBubbleWithTail.innerVerticalPadding;
      final bubbleW = bubbleBox.size.width;
      final badgeEndInset = _reactionToolbarTrailingEndInset(bubbleW);
      final toolbarEndInset = math.max(
        0.0,
        badgeEndInset - _reactionToolbarTowardTrailingEdgePx,
      );
      top = (bubbleTop +
              _reactionToolbarOverlapIntoBubble -
              _kReactionToolbarHeightEstimate)
          .clamp(
        padTop + 8,
        h - padBottom - _kReactionToolbarHeightEstimate - 8,
      );
      if (textDir == TextDirection.ltr) {
        left = o.dx +
            bubbleW -
            toolbarEndInset -
            _kReactionToolbarWidth +
            _reactionToolbarShiftTowardTrailingEndPx;
      } else {
        left = o.dx +
            toolbarEndInset -
            _kReactionToolbarWidth -
            _reactionToolbarShiftTowardTrailingEndPx;
      }
      left = left.clamp(8.0, w - _kReactionToolbarWidth - 8);
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
        selectedReactionId: widget.message.myReaction,
        onRemoved: entry.remove,
        onEmojiChosen: (reactionId, {required matchesOpeningSelection}) =>
            _applyReactionChoice(
          reactionId,
          matchesOpeningSelection: matchesOpeningSelection,
        ),
      ),
    );
    overlay.insert(entry);
  }

  void _openReactionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return UydoshGlassDialog(
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
                      HapticFeedbackUtils.tapticChain();
                      Navigator.of(ctx).pop();
                      await _applyReactionChoice(id);
                    },
                    borderRadius: BorderRadius.circular(26),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _reactionRibbonEmojiBody(
                        reactionId: id,
                        emojiSize: 28,
                        selected: _reactionKeysEqualNullable(
                          widget.message.myReaction,
                          id,
                        ),
                        onGlassBackground: false,
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

  /// Clears when the user picks their current reaction, or re-taps the emoji
  /// that was highlighted when the ribbon opened ([matchesOpeningSelection]).
  Future<void> _applyReactionChoice(
    String reactionId, {
    bool matchesOpeningSelection = false,
  }) async {
    final mine =
        _reactionKeysEqualNullable(widget.message.myReaction, reactionId);
    if (mine || matchesOpeningSelection) {
      await widget.onClearReaction?.call();
    } else {
      await widget.onSetReaction?.call(reactionId);
    }
  }

  /// Shared emoji cell for reaction picker: optional circular ring when
  /// [selected] matches the corner badge state.
  static Widget _reactionRibbonEmojiBody({
    required String reactionId,
    required double emojiSize,
    required bool selected,
    required bool onGlassBackground,
  }) {
    final emoji = Text(
      MessageReactionCatalog.emojiFor(reactionId),
      textAlign: TextAlign.center,
      style: MessageReactionCatalog.textStyleForReactionEmoji(emojiSize),
    );
    if (!selected) {
      return emoji;
    }
    final borderColor = onGlassBackground
        ? Colors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.22);
    final fillColor = onGlassBackground
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.07);
    final diameter = emojiSize + 16;
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(
          color: borderColor,
          width: onGlassBackground ? 1 : 1.2,
        ),
      ),
      child: emoji,
    );
  }

  Widget _buildReactionStrip(
    BuildContext context,
    Color textColor, {
    EdgeInsetsGeometry outerPadding = const EdgeInsets.only(
      top: 4,
      left: 4,
      right: 4,
    ),
    WrapAlignment? wrapAlignment,
  }) {
    final entries = _reactionStripEntries();
    final mine = widget.message.myReaction;

    return Padding(
      padding: outerPadding,
      child: Wrap(
        spacing: 6,
        runSpacing: 2,
        alignment: wrapAlignment ??
            (widget.isCurrentUser ? WrapAlignment.end : WrapAlignment.start),
        children: [
          for (final e in entries)
            GestureDetector(
              onTap: (!_reactionsEnabled &&
                      mine == e.reaction &&
                      widget.onClearReaction != null)
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onClearReaction?.call();
                    }
                  : null,
              behavior: HitTestBehavior.translucent,
              child: Container(
                decoration: _reactionBadgeDecoration(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      MessageReactionCatalog.emojiFor(e.reaction),
                      textAlign: TextAlign.center,
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: MessageReactionCatalog.textStyleForReactionEmoji(
                        _reactionBubbleEmojiSize,
                        height: 1,
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

class _SystemMessageBubble extends StatelessWidget {
  const _SystemMessageBubble({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = ThemeState().isLightTheme;
    final backgroundColor = isLight
        ? Colors.black.withValues(alpha: 0.06)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final textColor = isLight
        ? Colors.black.withValues(alpha: 0.68)
        : scheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: textColor.withValues(alpha: 0.10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
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
const double _kReactionToolbarHeightEstimate = 48;
const double _kReactionToolbarWidth = 248;
const double _kReactionToolbarHorizontalPadding = 12;
const double _kReactionToolbarScrollViewportWidth =
    _kReactionToolbarWidth - _kReactionToolbarHorizontalPadding;

class _ReactionToolbarOverlayAnimated extends StatefulWidget {
  const _ReactionToolbarOverlayAnimated({
    required this.left,
    required this.top,
    required this.onRemoved,
    required this.onEmojiChosen,
    this.selectedReactionId,
  });

  final double left;
  final double top;
  final VoidCallback onRemoved;

  /// Viewer’s active reaction on this message, if any — highlighted in the ribbon.
  final String? selectedReactionId;

  /// Invoked **after** the overlay entry is removed.
  /// [matchesOpeningSelection] is true when this [reactionId] was the viewer’s
  /// reaction at ribbon open — re-tap removes even if live [Message.myReaction]
  /// was out of sync with strict string equality.
  final Future<void> Function(
    String reactionId, {
    required bool matchesOpeningSelection,
  }) onEmojiChosen;

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
                    child: SizedBox(
                      width: _kReactionToolbarScrollViewportWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final id in MessageReactionCatalog.ids)
                              Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedbackUtils.tapticChain();
                                    final applyReaction = widget.onEmojiChosen;
                                    final reactionId = id;
                                    final matchesOpening = _MessageBubbleState
                                        ._reactionKeysEqualNullable(
                                      widget.selectedReactionId,
                                      reactionId,
                                    );
                                    _animateOut(
                                      afterOverlayRemoved: () => applyReaction(
                                        reactionId,
                                        matchesOpeningSelection: matchesOpening,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(22),
                                  customBorder: const CircleBorder(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    child: _MessageBubbleState
                                        ._reactionRibbonEmojiBody(
                                      reactionId: id,
                                      emojiSize: 20,
                                      selected: _MessageBubbleState
                                          ._reactionKeysEqualNullable(
                                        widget.selectedReactionId,
                                        id,
                                      ),
                                      onGlassBackground: true,
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
