import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_listing_title_with_category_icon.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";
import "package:uy_dosh/presentation/widgets/conversation/outgoing_conversation_tile.dart";

/// Stable id for grouping inbox threads that belong to the same listing or
/// the same gig row. Listing chats use [ConversationSummary.listingId]. Gig
/// rows omit `listing_id`; we bucket by request/offer/booking id instead of
/// `-conversation.id` (which produced one card per thread).
int conversationGroupKey(ConversationSummary c) {
  final listingId = c.listingId;
  if (listingId != null) {
    return listingId;
  }
  final ctx = c.contextType;
  if (ctx == "gig_request") {
    final id = c.gigRequestId ?? c.contextId;
    if (id != null) {
      return -2000000000 - id;
    }
  } else if (ctx == "gig_offer") {
    final id = c.contextId;
    if (id != null) {
      return -2100000000 - id;
    }
  } else if (ctx == "gig_booking") {
    final id = c.contextId;
    if (id != null) {
      return -2200000000 - id;
    }
  }
  return -c.id;
}

bool _sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Latest [lastMessageAt]/[updatedAt] in the group (for ordering + date strips).
DateTime _groupLatestMessageTime(List<ConversationSummary> convs) {
  if (convs.isEmpty) {
    return DateTime.now().toLocal();
  }
  DateTime? latest;
  for (final c in convs) {
    final t = DateTime.parse(c.lastMessageAt ?? c.updatedAt).toLocal();
    if (latest == null || t.isAfter(latest)) {
      latest = t;
    }
  }
  return latest!;
}

DateTime _groupLatestActivityDay(List<ConversationSummary> convs) {
  final t = _groupLatestMessageTime(convs);
  return DateTime(t.year, t.month, t.day);
}

List<Widget> _intersperseGap(List<Widget> items, double gap) {
  if (items.isEmpty) {
    return const [];
  }
  final out = <Widget>[items.first];
  for (var i = 1; i < items.length; i++) {
    out
      ..add(SizedBox(height: gap))
      ..add(items[i]);
  }
  return out;
}

class GroupedConversationsList extends StatefulWidget {
  const GroupedConversationsList({
    required this.conversations,
    required this.onConversationTap,
    super.key,
    this.currentUserId,
    /// When true, builds a [Column] of group cards for use inside another
    /// scrollable (avoids nested [ListView]).
    this.embedInParentScrollView = false,
    this.padding,
    this.itemSpacing,
    /// Passed through to inner [ConversationTile]s (e.g. inbox with day headers).
    this.showActivityTimeOnly = false,
    this.onConversationLongPress,
    /// When true, expanded rows use [OutgoingConversationTile] (messages tab
    /// "others' listings" / initiator side) instead of [ConversationTile].
    this.useOutgoingInnerTiles = false,
  });
  final List<ConversationSummary> conversations;
  final int? currentUserId;
  final Function(ConversationSummary) onConversationTap;
  final bool embedInParentScrollView;
  final EdgeInsets? padding;
  final double? itemSpacing;
  final bool showActivityTimeOnly;
  final Function(ConversationSummary)? onConversationLongPress;
  final bool useOutgoingInnerTiles;

  @override
  State<GroupedConversationsList> createState() =>
      _GroupedConversationsListState();
}

class _GroupedConversationsListState extends State<GroupedConversationsList> {
  final Map<int, bool> _expandedGroups = {};
  Map<int, List<ConversationSummary>> _groupedConversations = const {};
  List<int> _sortedListingIds = const [];

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void didUpdateWidget(covariant GroupedConversationsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recompute when input list or user context changes.
    if (!identical(oldWidget.conversations, widget.conversations) ||
        oldWidget.currentUserId != widget.currentUserId ||
        oldWidget.useOutgoingInnerTiles != widget.useOutgoingInnerTiles) {
      _recompute();
    }
  }

  void _recompute() {
    final groupedConversations = <int, List<ConversationSummary>>{};
    for (final conversation in widget.conversations) {
      final groupKey = conversationGroupKey(conversation);
      (groupedConversations[groupKey] ??= []).add(conversation);
    }

    // Sort conversations within each group: unread first, then most recent first.
    groupedConversations.forEach((_, conversations) {
      conversations.sort((a, b) {
        final aHasUnread =
            a.unreadCount != null &&
            a.unreadCount! > 0 &&
            widget.currentUserId != null &&
            a.lastMessageSenderId != widget.currentUserId;
        final bHasUnread =
            b.unreadCount != null &&
            b.unreadCount! > 0 &&
            widget.currentUserId != null &&
            b.lastMessageSenderId != widget.currentUserId;

        if (aHasUnread && !bHasUnread) return -1;
        if (!aHasUnread && bHasUnread) return 1;

        final aTime = a.lastMessageAt ?? a.updatedAt;
        final bTime = b.lastMessageAt ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });
    });

    // Sort listing groups: groups with unread first, then by most recent conversation.
    final sortedListingIds = groupedConversations.keys.toList()
      ..sort((a, b) {
        final aConversations = groupedConversations[a]!;
        final bConversations = groupedConversations[b]!;

        final aHasUnread = aConversations.any(
          (conv) =>
              conv.unreadCount != null &&
              conv.unreadCount! > 0 &&
              widget.currentUserId != null &&
              conv.lastMessageSenderId != widget.currentUserId,
        );
        final bHasUnread = bConversations.any(
          (conv) =>
              conv.unreadCount != null &&
              conv.unreadCount! > 0 &&
              widget.currentUserId != null &&
              conv.lastMessageSenderId != widget.currentUserId,
        );

        if (aHasUnread && !bHasUnread) return -1;
        if (!aHasUnread && bHasUnread) return 1;

        final aLatest = _groupLatestMessageTime(aConversations);
        final bLatest = _groupLatestMessageTime(bConversations);
        return bLatest.compareTo(aLatest);
      });

    // Auto-expand the first group with unread messages (no side-effects in build).
    if (sortedListingIds.isNotEmpty) {
      final firstGroupId = sortedListingIds.first;
      final firstGroupConversations = groupedConversations[firstGroupId]!;
      final hasUnreadInFirstGroup = firstGroupConversations.any(
        (conv) =>
            conv.unreadCount != null &&
            conv.unreadCount! > 0 &&
            widget.currentUserId != null &&
            conv.lastMessageSenderId != widget.currentUserId,
      );
      if (hasUnreadInFirstGroup && !_expandedGroups.containsKey(firstGroupId)) {
        _expandedGroups[firstGroupId] = true;
      }
    }

    setState(() {
      _groupedConversations = groupedConversations;
      _sortedListingIds = sortedListingIds;
    });
  }

  List<Widget> _buildDatedSegments(BuildContext context) {
    final segments = <Widget>[];
    DateTime? lastEmittedDay;

    for (var i = 0; i < _sortedListingIds.length; i++) {
      final listingId = _sortedListingIds[i];
      final conversations = _groupedConversations[listingId] ?? const [];
      final isExpanded = _expandedGroups[listingId] ?? false;
      final day = _groupLatestActivityDay(conversations);

      if (lastEmittedDay == null || !_sameCalendarDay(lastEmittedDay, day)) {
        segments.add(
          DateHeaderWidget(
            dateString: MessageGroupingUtils.formatDateHeader(day, context),
            date: day,
            padding:
                segments.isEmpty
                    ? const EdgeInsets.only(top: 8, bottom: 6)
                    : const EdgeInsets.only(top: 4, bottom: 6),
          ),
        );
        lastEmittedDay = day;
      }

      segments.add(
        _buildGroupCard(
          listingId: listingId,
          conversations: conversations,
          isExpanded: isExpanded,
        ),
      );
    }
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final gap = widget.itemSpacing ?? 10;

    if (widget.embedInParentScrollView) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _intersperseGap(_buildDatedSegments(context), gap),
        ),
      );
    }

    return CommonListView(
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemSpacing: gap,
      children: _buildDatedSegments(context),
    );
  }

  Widget _buildGroupCard({
    required int listingId,
    required List<ConversationSummary> conversations,
    required bool isExpanded,
  }) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final cardColor = themeState.cardColor;
        final textColor = themeState.cardTextColor;
        final secondaryTextColor = themeState.cardSecondaryTextColor;
        final iconColor = themeState.cardIconColor;
        final avatarColor = themeState.avatarColor;
        final avatarIconColor = themeState.avatarIconColor;
        final unreadColor = themeState.unreadIndicatorColor;
        final unreadTextColor = themeState.unreadIndicatorTextColor;

        // Get location and metro station info from the first conversation
        final firstConversation = conversations.first;
        final hasLocation = firstConversation.locationNameUz != null ||
            firstConversation.locationNameRu != null ||
            firstConversation.locationNameEn != null;
        final hasSubwayStation =
            firstConversation.subwayStationNameUz != null ||
                firstConversation.subwayStationNameRu != null ||
                firstConversation.subwayStationNameEn != null;
        final hasBudgetBadge =
            conversationSummaryShowsBudgetBadge(firstConversation);

        final groupUnreadCount = _getGroupUnreadCount(conversations);

        return ThreeDElevatedSurface(
          baseColor: cardColor,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              // Group header. Custom Row layout (rather than [ListTile]) so we
              // can keep the title/subtitle on the left, the unread badge +
              // expand chevron on the right rail, and overlay the
              // participant-avatar cluster at the geometric center of the
              // header via a [Stack] (see [Positioned.fill] below). The
              // overlay is wrapped in [IgnorePointer] so taps still hit the
              // [InkWell] underneath.
              Stack(
                alignment: Alignment.center,
                children: [
                  // Plain [GestureDetector] (rather than [InkWell]) — the
                  // Material ink ripple looks heavy across the full-width
                  // glass tile when expanding/collapsing. The haptic tap
                  // below is enough feedback on its own.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedbackUtils.impact();
                      setState(() {
                        _expandedGroups[listingId] = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        12,
                        12,
                        10,
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConversationListingTitleWithCategoryIcon(
                                    conversation: firstConversation,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                    iconColor: iconColor,
                                    titleMaxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    L10n.plural(
                                      "conversations_count",
                                      conversations.length,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  if (hasLocation ||
                                      hasSubwayStation ||
                                      hasBudgetBadge) ...[
                                    const SizedBox(height: 8),
                                    ConversationLocationInfo(
                                      conversation: firstConversation,
                                      textColor: secondaryTextColor,
                                      showPrice: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Right rail: a [Spacer] pushes everything to
                            // the bottom-right corner, where the unread
                            // count badge sits beside the expand chevron —
                            // mirrors the original [ListTile.trailing]
                            // layout (badge to the left of the chevron).
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (groupUnreadCount > 0) ...[
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color.lerp(
                                                    unreadColor,
                                                    Colors.white,
                                                    0.32,
                                                  ) ??
                                                  unreadColor,
                                              Color.lerp(
                                                    unreadColor,
                                                    Colors.black,
                                                    0.22,
                                                  ) ??
                                                  unreadColor,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.24,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(-2, -2),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.22,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "$groupUnreadCount",
                                            style: TextStyle(
                                              color: unreadTextColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.0 : 0.5,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: ThemeIcon(
                                        Icons.expand_less,
                                        color: iconColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Participant cluster overlay docked in the top-right
                  // corner of the header. Always rendered so
                  // [AnimatedOpacity] can cross-fade it in/out as the group
                  // expands or collapses — leaving it as `if (!isExpanded)
                  // …` would pop the cluster on/off in a single frame.
                  PositionedDirectional(
                    top: 10,
                    end: 12,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOut,
                        opacity: isExpanded ? 0.0 : 1.0,
                        child: _ConversationParticipantStack(
                          conversations: conversations,
                          avatarColor: avatarColor,
                          avatarIconColor: avatarIconColor,
                          ringColor: cardColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Group content with animation. [AnimatedCrossFade] (rather
              // than [AnimatedSize] swapping in a [SizedBox.shrink]) keeps
              // the conversation tiles visible while the height collapses,
              // and fades them out in step with the size change so the
              // closing tile feels like one continuous gesture instead of
              // "content vanishes, then padding shrinks".
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                sizeCurve: Curves.easeInOut,
                firstCurve: Curves.easeIn,
                secondCurve: Curves.easeOut,
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Column(
                  children: [
                    const Divider(height: 1),
                    ...conversations.map(
                      (conversation) => widget.useOutgoingInnerTiles
                          ? OutgoingConversationTile(
                              conversation: conversation,
                              currentUserId: widget.currentUserId,
                              showActivityTimeOnly: widget.showActivityTimeOnly,
                              isGrouped: true,
                              onTap: () =>
                                  widget.onConversationTap(conversation),
                              onLongPress: widget.onConversationLongPress == null
                                  ? null
                                  : () => widget.onConversationLongPress!(
                                        conversation,
                                      ),
                            )
                          : ConversationTile(
                              conversation: conversation,
                              currentUserId: widget.currentUserId,
                              onTap: () =>
                                  widget.onConversationTap(conversation),
                              isGrouped:
                                  true, // Add this parameter to style differently
                              showActivityTimeOnly: widget.showActivityTimeOnly,
                              onLongPress: widget.onConversationLongPress == null
                                  ? null
                                  : () => widget.onConversationLongPress!(
                                        conversation,
                                      ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getGroupUnreadCount(List<ConversationSummary> conversations) {
    return conversations.fold(0, (sum, conversation) {
      if (conversation.unreadCount != null &&
          conversation.unreadCount! > 0 &&
          widget.currentUserId != null &&
          conversation.lastMessageSenderId != widget.currentUserId) {
        return sum + conversation.unreadCount!;
      }
      return sum;
    });
  }
}

/// Horizontal cluster of participant avatars overlaid at the center of the
/// collapsed group header. Each circle shows the "other user" of one
/// conversation. Avatars are placed side-by-side with a small gap between
/// them (no overlap) so every face reads as its own discrete identity. The
/// per-group unread badge in the right rail already conveys the unread
/// signal, so avatars here are intentionally identifier-only — no
/// per-avatar dot.
class _ConversationParticipantStack extends StatelessWidget {
  const _ConversationParticipantStack({
    required this.conversations,
    required this.avatarColor,
    required this.avatarIconColor,
    required this.ringColor,
  });

  static const double _avatarSize = 36;
  static const double _avatarGap = 2;

  /// How many real participant avatars we render before falling back to a
  /// `+N` chip. Five matches the typical "team avatars" pattern (Slack,
  /// Linear) — enough to distinguish faces, not so many that a long listing
  /// crushes the title on the left.
  static const int _maxVisible = 5;

  final List<ConversationSummary> conversations;
  final Color avatarColor;
  final Color avatarIconColor;

  /// Color used for the thin ring around each circle. Should match the
  /// surrounding card so adjacent circles read as cleanly separated rather
  /// than melting into each other.
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) return const SizedBox.shrink();

    final visible = conversations.take(_maxVisible).toList();
    final overflow = conversations.length - visible.length;

    final children = <Widget>[
      for (var i = 0; i < visible.length; i++) ...[
        if (i > 0) const SizedBox(width: _avatarGap),
        _ParticipantAvatar(
          conversation: visible[i],
          size: _avatarSize,
          avatarColor: avatarColor,
          avatarIconColor: avatarIconColor,
          ringColor: ringColor,
        ),
      ],
      if (overflow > 0) ...[
        const SizedBox(width: _avatarGap),
        _ParticipantOverflowChip(
          count: overflow,
          size: _avatarSize,
          ringColor: ringColor,
          background: avatarColor,
          textColor: avatarIconColor,
        ),
      ],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({
    required this.conversation,
    required this.size,
    required this.avatarColor,
    required this.avatarIconColor,
    required this.ringColor,
  });

  final ConversationSummary conversation;
  final double size;
  final Color avatarColor;
  final Color avatarIconColor;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final url = resolveAvatarUrl(conversation.otherUserAvatar);
    final cacheExtent = (size * MediaQuery.devicePixelRatioOf(context)).round();

    Widget fallback() => Container(
          color: avatarColor,
          alignment: Alignment.center,
          child: ConversationAvatarContent(
            conversation: conversation,
            iconColor: avatarIconColor,
          ),
        );

    // Pipeline: an explicit [SizedBox] locks the 36×36 footprint, [ClipOval]
    // forces a perfectly circular image clip (more reliable than relying on
    // [Container.clipBehavior] + [BoxShape.circle], which can render
    // unevenly when the child has its own width/height), and the outer
    // [DecoratedBox] paints the thin separator ring on top so the border
    // never gets eaten by the clip.
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: url != null
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheExtent,
                      memCacheHeight: cacheExtent,
                      placeholder: (_, __) => fallback(),
                      errorWidget: (_, __, ___) => fallback(),
                    )
                  : fallback(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantOverflowChip extends StatelessWidget {
  const _ParticipantOverflowChip({
    required this.count,
    required this.size,
    required this.ringColor,
    required this.background,
    required this.textColor,
  });

  final int count;
  final double size;
  final Color ringColor;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: Border.all(color: ringColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        "+$count",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
