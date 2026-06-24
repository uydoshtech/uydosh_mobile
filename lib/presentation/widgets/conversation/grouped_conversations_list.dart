import "dart:async";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_hint_bubble.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/tooltip_fade.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_avatar.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_listing_title_with_category_icon.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";
import "package:uy_dosh/presentation/widgets/conversation/outgoing_conversation_tile.dart";

/// `conversation_type` value for multi-member group chats (mirrors the
/// backend `CONVERSATION_TYPE_LISTING_GROUP`). A group card whose single
/// conversation carries this type renders overlapping member avatars instead
/// of one-avatar-per-thread.
const String _listingGroupConversationType = "listing_group";

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

sealed class _GroupedListSegment {}

final class _GroupedDateHeaderSegment extends _GroupedListSegment {
  _GroupedDateHeaderSegment({required this.day, required this.isFirst});

  final DateTime day;
  final bool isFirst;
}

final class _GroupedCardSegment extends _GroupedListSegment {
  _GroupedCardSegment({
    required this.listingId,
    required this.conversations,
  });

  final int listingId;
  final List<ConversationSummary> conversations;
}

class GroupedConversationsList extends StatefulWidget {
  const GroupedConversationsList({
    required this.conversations,
    required this.onConversationTap,
    super.key,
    this.currentUserId,
    this.padding,
    this.itemSpacing,
    this.physics,

    /// Optional rows rendered before grouped segments (e.g. inbox push banner).
    this.leadingItemCount = 0,
    this.leadingItemBuilder,

    /// Passed through to inner [ConversationTile]s (e.g. inbox with day headers).
    this.showActivityTimeOnly = false,
    this.onConversationLongPress,

    /// When true, expanded rows use [OutgoingConversationTile] (messages tab
    /// "others' listings" / initiator side) instead of [ConversationTile].
    this.useOutgoingInnerTiles = false,

    /// Invoked when the member-avatar cluster of a group chat card is tapped,
    /// with the group's listing id. Lets the host open the group listing
    /// detail. When null, the cluster stays non-interactive.
    this.onGroupListingTap,
  }) : assert(
          leadingItemCount == 0 || leadingItemBuilder != null,
          "leadingItemBuilder is required when leadingItemCount > 0",
        );
  final List<ConversationSummary> conversations;
  final int? currentUserId;
  final Function(ConversationSummary) onConversationTap;
  final EdgeInsets? padding;
  final double? itemSpacing;
  final ScrollPhysics? physics;
  final int leadingItemCount;
  final Widget Function(BuildContext context, int index)? leadingItemBuilder;
  final bool showActivityTimeOnly;
  final Function(ConversationSummary)? onConversationLongPress;
  final bool useOutgoingInnerTiles;
  final void Function(int listingId)? onGroupListingTap;

  @override
  State<GroupedConversationsList> createState() =>
      _GroupedConversationsListState();
}

class _GroupedConversationsListState extends State<GroupedConversationsList> {
  final Map<int, bool> _expandedGroups = {};
  Map<int, List<ConversationSummary>> _groupedConversations = const {};
  List<int> _sortedListingIds = const [];
  List<_GroupedListSegment> _segments = const [];

  /// One-time animated expand + overlay hint for multi-thread groups; ends
  /// collapsed again after the coach unless unread keeps the group expanded.
  bool _groupExpandCoachDismissed = true;
  bool _groupCoachSequenceActive = false;
  int? _groupCoachActiveListingId;
  bool _groupCoachDidExpandForCoach = false;
  int? _groupCoachBubbleListingId;
  bool _groupCoachShowBubble = false;
  final LayerLink _groupCoachLayerLink = LayerLink();
  OverlayEntry? _groupCoachOverlayEntry;

  @override
  void initState() {
    super.initState();
    _recompute();
    unawaited(_loadGroupExpandCoachDismissed());
    TooltipsState().addListener(_onTooltipsStateChanged);
  }

  @override
  void dispose() {
    _removeGroupCoachOverlay();
    TooltipsState().removeListener(_onTooltipsStateChanged);
    super.dispose();
  }

  void _onTooltipsStateChanged() {
    unawaited(_loadGroupExpandCoachDismissed());
    if (!TooltipsState().enabled) {
      _suppressGroupExpandCoachForDisabledTips();
    } else {
      _groupCoachOverlayEntry?.markNeedsBuild();
    }
  }

  Future<void> _loadGroupExpandCoachDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed =
          prefs.getBool(TooltipsState.keyGroupedChatsExpandCoachDismissed) ??
              false;
      setStateIfMounted(() => _groupExpandCoachDismissed = dismissed);
      if (!dismissed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeScheduleGroupExpandCoach();
        });
      }
    } catch (_) {
      setStateIfMounted(() => _groupExpandCoachDismissed = true);
    }
  }

  Future<void> _persistGroupExpandCoachDismissed() async {
    setStateIfMounted(() => _groupExpandCoachDismissed = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        TooltipsState.keyGroupedChatsExpandCoachDismissed,
        true,
      );
    } catch (_) {}
  }

  void _suppressGroupExpandCoachForDisabledTips() {
    final id = _groupCoachActiveListingId;
    if (id == null && !_groupCoachShowBubble) return;
    _removeGroupCoachOverlay();
    setStateIfMounted(() {
      _groupCoachShowBubble = false;
      _groupCoachBubbleListingId = null;
      if (_groupCoachDidExpandForCoach && id != null) {
        _expandedGroups[id] = false;
      }
      _groupCoachActiveListingId = null;
      _groupCoachDidExpandForCoach = false;
    });
    _groupCoachSequenceActive = false;
  }

  void _removeGroupCoachOverlay() {
    _groupCoachOverlayEntry?.remove();
    _groupCoachOverlayEntry = null;
  }

  void _insertOrMarkGroupCoachOverlay() {
    if (!mounted) return;
    final visible = _groupCoachShowBubble &&
        TooltipsState().enabled &&
        _groupCoachBubbleListingId != null;
    if (!visible) {
      _removeGroupCoachOverlay();
      return;
    }
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    if (_groupCoachOverlayEntry == null) {
      _groupCoachOverlayEntry = OverlayEntry(
        builder: (_) => _buildGroupCoachOverlay(),
      );
      overlay.insert(_groupCoachOverlayEntry!);
    } else {
      _groupCoachOverlayEntry!.markNeedsBuild();
    }
  }

  Widget _buildGroupCoachOverlay() {
    final listingId = _groupCoachBubbleListingId;
    if (listingId == null) return const SizedBox.shrink();
    final show = _groupCoachShowBubble && TooltipsState().enabled;
    return TooltipFade(
      visible: show,
      collapse: false,
      duration: const Duration(milliseconds: 260),
      child: CompositedTransformFollower(
        link: _groupCoachLayerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.bottomRight,
        offset: const Offset(0, -6),
        child: Material(
          type: MaterialType.transparency,
          child: NeumorphicHintBubble(
            maxWidth: 268,
            tailSide: HintBubbleTailSide.bottom,
            tailHorizontalOffset: 48,
            message: TextSpan(
              text: L10n.get("grouped_chats_expand_coach_hint"),
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.3,
                color: Colors.black,
              ),
            ),
            onClose: () => unawaited(_completeGroupExpandCoach(listingId)),
          ),
        ),
      ),
    );
  }

  void _maybeScheduleGroupExpandCoach() {
    if (!mounted) return;
    if (_groupExpandCoachDismissed || !TooltipsState().enabled) return;
    if (_groupCoachSequenceActive) return;

    final targetId = _sortedListingIds.cast<int?>().firstWhere(
      (id) {
        final convs = _groupedConversations[id] ?? const [];
        final isCollapsed = !(_expandedGroups[id] ?? false);
        final canVisiblyExpand =
            convs.length > 1 && !_groupHasIncomingUnread(convs);
        return canVisiblyExpand && isCollapsed;
      },
      orElse: () => null,
    );
    if (targetId == null) return;
    unawaited(_runGroupExpandCoachSequence(targetId));
  }

  Future<void> _runGroupExpandCoachSequence(int listingId) async {
    if (_groupCoachSequenceActive) return;
    _groupCoachSequenceActive = true;
    _groupCoachActiveListingId = listingId;
    _groupCoachDidExpandForCoach = false;
    var expandedForCoach = false;
    var coachCompletedSuccessfully = false;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted || _groupExpandCoachDismissed || !TooltipsState().enabled) {
        return;
      }
      if ((_expandedGroups[listingId] ?? false)) {
        return;
      }
      final convs = _groupedConversations[listingId] ?? const [];
      if (convs.length < 2) return;

      setStateIfMounted(() {
        _expandedGroups[listingId] = true;
        _groupCoachDidExpandForCoach = true;
      });
      expandedForCoach = true;

      await Future<void>.delayed(const Duration(milliseconds: 480));
      if (!mounted || _groupExpandCoachDismissed || !TooltipsState().enabled) {
        return;
      }

      setStateIfMounted(() {
        _groupCoachBubbleListingId = listingId;
        _groupCoachShowBubble = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _insertOrMarkGroupCoachOverlay();
      });

      await Future<void>.delayed(const Duration(milliseconds: 2800));
      if (!mounted) return;

      await _completeGroupExpandCoach(listingId);
      coachCompletedSuccessfully = true;
    } finally {
      _removeGroupCoachOverlay();
      _groupCoachSequenceActive = false;
      _groupCoachActiveListingId = null;
      _groupCoachDidExpandForCoach = false;
      if (mounted && expandedForCoach && !coachCompletedSuccessfully) {
        setStateIfMounted(() {
          _expandedGroups[listingId] = false;
          _groupCoachShowBubble = false;
          _groupCoachBubbleListingId = null;
        });
      }
    }
  }

  Future<void> _completeGroupExpandCoach(int listingId) async {
    if (!mounted) return;
    _removeGroupCoachOverlay();
    setStateIfMounted(() {
      _expandedGroups[listingId] = false;
      _groupCoachShowBubble = false;
      _groupCoachBubbleListingId = null;
      _groupCoachActiveListingId = null;
      _groupCoachDidExpandForCoach = false;
    });
    await _persistGroupExpandCoachDismissed();
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

  /// True when this listing group has unread messages from someone else.
  bool _groupHasIncomingUnread(List<ConversationSummary> conversations) {
    if (widget.currentUserId == null) return false;
    return conversations.any(
      (conv) =>
          conv.unreadCount != null &&
          conv.unreadCount! > 0 &&
          conv.lastMessageSenderId != widget.currentUserId,
    );
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
        final aHasUnread = a.unreadCount != null &&
            a.unreadCount! > 0 &&
            widget.currentUserId != null &&
            a.lastMessageSenderId != widget.currentUserId;
        final bHasUnread = b.unreadCount != null &&
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

    final segments = _buildSegments(
      groupedConversations: groupedConversations,
      sortedListingIds: sortedListingIds,
    );

    setState(() {
      _groupedConversations = groupedConversations;
      _sortedListingIds = sortedListingIds;
      _segments = segments;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeScheduleGroupExpandCoach();
    });
  }

  List<_GroupedListSegment> _buildSegments({
    required Map<int, List<ConversationSummary>> groupedConversations,
    required List<int> sortedListingIds,
  }) {
    final segments = <_GroupedListSegment>[];
    DateTime? lastEmittedDay;

    for (final listingId in sortedListingIds) {
      final conversations = groupedConversations[listingId] ?? const [];
      final day = _groupLatestActivityDay(conversations);

      if (lastEmittedDay == null || !_sameCalendarDay(lastEmittedDay, day)) {
        segments.add(
          _GroupedDateHeaderSegment(
            day: day,
            isFirst: segments.isEmpty,
          ),
        );
        lastEmittedDay = day;
      }

      segments.add(
        _GroupedCardSegment(
          listingId: listingId,
          conversations: conversations,
        ),
      );
    }
    return segments;
  }

  ({bool isExpanded, bool canToggleExpansion}) _groupCardExpansionState(
    int listingId,
    List<ConversationSummary> conversations,
  ) {
    final onlyOneGroup = _sortedListingIds.length == 1;
    final hasIncomingUnread = _groupHasIncomingUnread(conversations);
    final isSingletonThreadGroup = onlyOneGroup && conversations.length == 1;
    final stored = _expandedGroups[listingId];
    // Unread groups default to expanded so threads are visible; the user can
    // still collapse (stored `false` is honored while unread).
    final isExpanded = isSingletonThreadGroup
        ? true
        : hasIncomingUnread
            ? (stored ?? true)
            : (stored ?? false);
    final canToggleExpansion =
        !isSingletonThreadGroup && (!onlyOneGroup || conversations.length > 1);
    return (isExpanded: isExpanded, canToggleExpansion: canToggleExpansion);
  }

  Widget _buildSegment(BuildContext context, int segmentIndex) {
    final segment = _segments[segmentIndex];
    return switch (segment) {
      _GroupedDateHeaderSegment(:final day, :final isFirst) => DateHeaderWidget(
          dateString: AppDateUtils.formatDateHeader(day, context),
          date: day,
          padding: isFirst
              ? const EdgeInsets.only(top: 8, bottom: 6)
              : const EdgeInsets.only(top: 4, bottom: 6),
        ),
      _GroupedCardSegment(:final listingId, :final conversations) => () {
          final expansion = _groupCardExpansionState(listingId, conversations);
          return _buildGroupCard(
            listingId: listingId,
            conversations: conversations,
            isExpanded: expansion.isExpanded,
            canToggleExpansion: expansion.canToggleExpansion,
          );
        }(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final gap = widget.itemSpacing ?? 10;
    final leadingCount = widget.leadingItemCount;
    final segmentCount = _segments.length;
    final totalCount = leadingCount + segmentCount;

    return CommonListView(
      padding: widget.padding ?? const EdgeInsets.all(16),
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      itemSpacing: gap,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < leadingCount) {
          return widget.leadingItemBuilder!(context, index);
        }
        return _buildSegment(context, index - leadingCount);
      },
    );
  }

  /// A single-conversation `listing_group` card whose member previews drive
  /// the overlapping avatar cluster. Mirrors `_isPersistentGroupStack` in
  /// [_ConversationParticipantStack].
  bool _isGroupChatCard(List<ConversationSummary> conversations) {
    if (conversations.length != 1) return false;
    final conv = conversations.first;
    return conv.conversationType == _listingGroupConversationType &&
        conv.members.isNotEmpty;
  }

  Widget _buildParticipantStackOverlay({
    required int listingId,
    required List<ConversationSummary> conversations,
    required bool isExpanded,
    required Color avatarColor,
    required Color avatarIconColor,
    required Color ringColor,
  }) {
    final stack = _ConversationParticipantStack(
      isExpanded: isExpanded,
      conversations: conversations,
      currentUserId: widget.currentUserId,
      avatarColor: avatarColor,
      avatarIconColor: avatarIconColor,
      ringColor: ringColor,
    );

    final groupListingId = conversations.first.listingId;
    final canOpenListing = widget.onGroupListingTap != null &&
        groupListingId != null &&
        _isGroupChatCard(conversations);
    if (!canOpenListing) {
      return IgnorePointer(child: stack);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedbackUtils.impact();
        widget.onGroupListingTap!(groupListingId);
      },
      child: stack,
    );
  }

  Widget _buildGroupCard({
    required int listingId,
    required List<ConversationSummary> conversations,
    required bool isExpanded,
    required bool canToggleExpansion,
  }) {
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
    final hasSubwayStation = firstConversation.subwayStationNameUz != null ||
        firstConversation.subwayStationNameRu != null ||
        firstConversation.subwayStationNameEn != null;
    final hasBudgetBadge =
        conversationSummaryShowsBudgetBadge(firstConversation);

    final groupUnreadCount = _getGroupUnreadCount(conversations);

    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final glassTintColor = themeState.primaryColor;

    return ThreeDElevatedSurface(
      baseColor: useLiquidGlass ? glassTintColor : cardColor,
      margin: EdgeInsets.zero,
      useLiquidGlass: useLiquidGlass,
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
                onTap: canToggleExpansion
                    ? () {
                        HapticFeedbackUtils.impact();
                        setState(() {
                          _expandedGroups[listingId] = !isExpanded;
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    16,
                    12,
                    12,
                    10,
                  ),
                  // Avoid [IntrinsicHeight] / trailing [Spacer]: unbounded
                  // height under vertical scroll (e.g. web) throws.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                            if (!conversationSummaryIsListingMarketplaceChat(
                                  firstConversation,
                                ) &&
                                (firstConversation.gigOwnerName != null &&
                                    firstConversation.gigOwnerName!
                                        .trim()
                                        .isNotEmpty)) ...[
                              const SizedBox(height: 8),
                              ConversationGigOwnerRow(
                                conversation: firstConversation,
                                textColor: textColor,
                                mutedColor: secondaryTextColor,
                                avatarColor: avatarColor,
                                avatarIconColor: avatarIconColor,
                              ),
                            ],
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
                          if (canToggleExpansion)
                            listingId == _groupCoachActiveListingId
                                ? CompositedTransformTarget(
                                    link: _groupCoachLayerLink,
                                    child: AnimatedRotation(
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
                                  )
                                : AnimatedRotation(
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
                ),
              ),
              // Participant cluster overlay docked in the top-right
              // corner of the header. Always rendered; visibility is
              // animated inside [_ConversationParticipantStack] so
              // multi-person groups can stagger per avatar instead of
              // one [AnimatedOpacity] over the whole stack.
              //
              // For group chats the member-avatar cluster is a tappable
              // shortcut to the group listing detail; for plain listing
              // cards it stays inert ([IgnorePointer]) so taps fall
              // through to the expand/collapse [GestureDetector] below.
              PositionedDirectional(
                top: 10,
                end: 12,
                child: _buildParticipantStackOverlay(
                  listingId: listingId,
                  conversations: conversations,
                  isExpanded: isExpanded,
                  avatarColor: avatarColor,
                  avatarIconColor: avatarIconColor,
                  ringColor: useLiquidGlass
                      ? glassTintColor.withValues(alpha: 0.48)
                      : cardColor,
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
                          onTap: () => widget.onConversationTap(conversation),
                          onLongPress: widget.onConversationLongPress == null
                              ? null
                              : () => widget.onConversationLongPress!(
                                    conversation,
                                  ),
                        )
                      : ConversationTile(
                          conversation: conversation,
                          currentUserId: widget.currentUserId,
                          onTap: () => widget.onConversationTap(conversation),
                          isGrouped: true,
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
/// conversation. Avatars overlap slightly (~8% of diameter plus a small
/// fixed inset) so the cluster stays compact while rings still separate
/// identities. The per-group
/// unread badge in the right rail already conveys the unread signal, so
/// avatars here are intentionally identifier-only — no per-avatar dot.
///
/// When the cluster has more than one slot (multiple people or a `+N`
/// overflow chip), avatars fade in left → right when the group collapses
/// and out right → left when it expands, so they are not tied to one
/// shared opacity on the whole row.
class _ConversationParticipantStack extends StatefulWidget {
  const _ConversationParticipantStack({
    required this.isExpanded,
    required this.conversations,
    required this.currentUserId,
    required this.avatarColor,
    required this.avatarIconColor,
    required this.ringColor,
  });

  static const double _avatarSize = 36;

  /// Horizontal overlap between adjacent circles as a fraction of diameter
  /// (5–10% reads as a light stack without hiding too much of each face).
  static const double _avatarOverlapFraction = 0.08;

  /// Additional overlap in logical pixels, stacked on [_avatarOverlapFraction].
  static const double _avatarOverlapExtraPx = 2;

  /// How many real participant avatars we render before falling back to a
  /// `+N` chip. Five matches the typical "team avatars" pattern (Slack,
  /// Linear) — enough to distinguish faces, not so many that a long listing
  /// crushes the title on the left.
  static const int _maxVisible = 5;

  /// Delay between each slot starting its fade-in (multi-slot clusters only).
  static const int _fadeStaggerMs = 64;

  /// Duration each slot spends fading from 0 → 1 opacity.
  static const int _fadeInMs = 180;

  /// Single-avatar clusters use one fade (matches previous header opacity).
  static const int _singleSlotFadeMs = 240;

  /// When true, the group body is expanded and the cluster should hide.
  final bool isExpanded;

  final List<ConversationSummary> conversations;

  /// Viewer id, used to order the current user first when a group chat's
  /// members are rendered as overlapping avatars.
  final int? currentUserId;

  final Color avatarColor;
  final Color avatarIconColor;

  /// Color used for the thin ring around each circle. Should match the
  /// surrounding card so adjacent circles read as cleanly separated rather
  /// than melting into each other.
  final Color ringColor;

  @override
  State<_ConversationParticipantStack> createState() =>
      _ConversationParticipantStackState();
}

class _ConversationParticipantStackState
    extends State<_ConversationParticipantStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final CurvedAnimation _singleSlotFadeOpacity;

  /// Avatars to stack. For a single-conversation group chat
  /// ([_listingGroupConversationType] with member previews) this is one entry
  /// per member (current user first); otherwise one entry per conversation
  /// thread using the thread's "other user".
  List<_StackAvatar> _resolveAvatars() {
    final convs = widget.conversations;
    if (convs.length == 1) {
      final conv = convs.first;
      if (conv.conversationType == _listingGroupConversationType &&
          conv.members.isNotEmpty) {
        final ordered = ChatParticipantAvatarStack.orderWithCurrentUserFirst(
          conv.members,
          widget.currentUserId,
        );
        return [
          for (final member in ordered)
            _StackAvatar(
              url: member.avatarUrl,
              fallbackContent: _memberInitials(member),
            ),
        ];
      }
    }
    return [
      for (final conversation in convs)
        _StackAvatar(
          url: conversation.otherUserAvatar,
          fallbackContent: ConversationAvatarContent(
            conversation: conversation,
            iconColor: widget.avatarIconColor,
          ),
        ),
    ];
  }

  /// A single-conversation group chat ([_listingGroupConversationType] with
  /// member previews) is always rendered expanded, so its member-avatar
  /// cluster should stay pinned in the header rather than fading out with the
  /// expand/collapse animation used for multi-thread listing cards.
  bool get _isPersistentGroupStack {
    final convs = widget.conversations;
    if (convs.length != 1) return false;
    final conv = convs.first;
    return conv.conversationType == _listingGroupConversationType &&
        conv.members.isNotEmpty;
  }

  Widget _memberInitials(ConversationMemberSummary member) {
    return Text(
      StringUtils.extractInitials(member.name),
      style: TextStyle(
        color: widget.avatarIconColor,
        fontWeight: FontWeight.bold,
        fontSize: _ConversationParticipantStack._avatarSize * 0.4,
      ),
    );
  }

  int _fadeDurationMsForSlots(int slotCount) {
    if (slotCount <= 1) {
      return _ConversationParticipantStack._singleSlotFadeMs;
    }
    return (slotCount - 1) * _ConversationParticipantStack._fadeStaggerMs +
        _ConversationParticipantStack._fadeInMs;
  }

  void _runExpansionFadeAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isPersistentGroupStack) {
        _fadeController.value = 1;
        return;
      }
      if (widget.isExpanded) {
        _fadeController.reverse();
      } else {
        _fadeController.forward(from: 0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final avatars = _resolveAvatars();
    final visible =
        avatars.take(_ConversationParticipantStack._maxVisible).toList();
    final overflow = avatars.length - visible.length;
    final slotCount = visible.length + (overflow > 0 ? 1 : 0);

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _fadeDurationMsForSlots(slotCount)),
    );

    _singleSlotFadeOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    if (_isPersistentGroupStack) {
      _fadeController.value = 1;
    } else if (widget.isExpanded) {
      _fadeController.value = 0;
    } else if (slotCount > 1) {
      _fadeController.value = 0;
      _runExpansionFadeAfterFrame();
    } else {
      _fadeController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _ConversationParticipantStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPersistentGroupStack) {
      if (_fadeController.value != 1) _fadeController.value = 1;
      return;
    }
    if (oldWidget.isExpanded != widget.isExpanded) {
      _runExpansionFadeAfterFrame();
    }
  }

  @override
  void dispose() {
    _singleSlotFadeOpacity.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _staggeredFade({required int index, required Widget child}) {
    final avatars = _resolveAvatars();
    if (avatars.isEmpty) {
      return child;
    }

    final visible =
        avatars.take(_ConversationParticipantStack._maxVisible).toList();
    final overflow = avatars.length - visible.length;
    final slotCount = visible.length + (overflow > 0 ? 1 : 0);
    if (slotCount <= 1) {
      return child;
    }

    final totalMs =
        (slotCount - 1) * _ConversationParticipantStack._fadeStaggerMs +
            _ConversationParticipantStack._fadeInMs;
    final t = totalMs.toDouble();
    final start = (index * _ConversationParticipantStack._fadeStaggerMs) / t;
    final endRaw = (index * _ConversationParticipantStack._fadeStaggerMs +
            _ConversationParticipantStack._fadeInMs) /
        t;
    final end = endRaw.clamp(start + 0.02, 1.0);

    final intervalCurve = Interval(
      start.clamp(0.0, 1.0),
      end,
      curve: Curves.easeOut,
    );
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final o =
            intervalCurve.transform(_fadeController.value).clamp(0.0, 1.0);
        return Opacity(opacity: o, child: child);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatars = _resolveAvatars();
    if (avatars.isEmpty) return const SizedBox.shrink();

    final visible =
        avatars.take(_ConversationParticipantStack._maxVisible).toList();
    final overflow = avatars.length - visible.length;

    final overlap = _ConversationParticipantStack._avatarSize *
            _ConversationParticipantStack._avatarOverlapFraction +
        _ConversationParticipantStack._avatarOverlapExtraPx;
    final step = _ConversationParticipantStack._avatarSize - overlap;
    final slotCount = visible.length + (overflow > 0 ? 1 : 0);
    final stackWidth = slotCount > 0
        ? _ConversationParticipantStack._avatarSize + (slotCount - 1) * step
        : 0.0;

    final stack = SizedBox(
      width: stackWidth,
      height: _ConversationParticipantStack._avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * step,
              top: 0,
              child: _staggeredFade(
                index: i,
                child: _ParticipantAvatar(
                  avatar: visible[i],
                  size: _ConversationParticipantStack._avatarSize,
                  avatarColor: widget.avatarColor,
                  ringColor: widget.ringColor,
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * step,
              top: 0,
              child: _staggeredFade(
                index: visible.length,
                child: _ParticipantOverflowChip(
                  count: overflow,
                  size: _ConversationParticipantStack._avatarSize,
                  ringColor: widget.ringColor,
                  background: widget.avatarColor,
                  textColor: widget.avatarIconColor,
                ),
              ),
            ),
        ],
      ),
    );

    if (slotCount > 1) {
      return stack;
    }
    return FadeTransition(
      opacity: _singleSlotFadeOpacity,
      child: stack,
    );
  }
}

/// One slot in the overlapping cluster: an avatar URL plus the widget to draw
/// when the URL is missing or fails to load (listing thumbnail icon for thread
/// avatars, initials for group members).
class _StackAvatar {
  const _StackAvatar({required this.url, required this.fallbackContent});

  final String? url;
  final Widget fallbackContent;
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({
    required this.avatar,
    required this.size,
    required this.avatarColor,
    required this.ringColor,
  });

  final _StackAvatar avatar;
  final double size;
  final Color avatarColor;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return UyDoshAvatar(
      avatarUrl: avatar.url,
      customSize: size,
      backgroundColor: avatarColor,
      borderColor: ringColor,
      borderWidth: 1.5,
      fallback: avatar.fallbackContent,
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
