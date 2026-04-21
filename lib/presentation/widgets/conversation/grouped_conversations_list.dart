import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";

class GroupedConversationsList extends StatefulWidget {
  const GroupedConversationsList({
    required this.conversations,
    required this.onConversationTap,
    super.key,
    this.currentUserId,
  });
  final List<ConversationSummary> conversations;
  final int? currentUserId;
  final Function(ConversationSummary) onConversationTap;

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
        oldWidget.currentUserId != widget.currentUserId) {
      _recompute();
    }
  }

  void _recompute() {
    // Group conversations by listing ID
    final groupedConversations = <int, List<ConversationSummary>>{};
    for (final conversation in widget.conversations) {
      (groupedConversations[conversation.listingId] ??= []).add(conversation);
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

        final aLatest =
            aConversations.first.lastMessageAt ?? aConversations.first.updatedAt;
        final bLatest =
            bConversations.first.lastMessageAt ?? bConversations.first.updatedAt;
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

  @override
  Widget build(BuildContext context) {
    return CommonListView(
      padding: const EdgeInsets.all(16),
      itemCount: _sortedListingIds.length,
      itemBuilder: (context, index) {
        final listingId = _sortedListingIds[index];
        final conversations = _groupedConversations[listingId] ?? const [];
        final isExpanded =
            _expandedGroups[listingId] ?? false; // Default to collapsed
        final listingTitle = conversations.isEmpty
            ? ""
            : resolvedConversationListingTitle(conversations.first);

        return _buildGroupCard(
          listingId: listingId,
          listingTitle: listingTitle,
          conversations: conversations,
          isExpanded: isExpanded,
        );
      },
    );
  }

  Widget _buildGroupCard({
    required int listingId,
    required String listingTitle,
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

        // Get location and metro station info from the first conversation
        final firstConversation = conversations.first;
        final hasLocation = firstConversation.locationNameUz != null ||
            firstConversation.locationNameRu != null ||
            firstConversation.locationNameEn != null;
        final hasSubwayStation =
            firstConversation.subwayStationNameUz != null ||
                firstConversation.subwayStationNameRu != null ||
                firstConversation.subwayStationNameEn != null;
        final hasListingPrice =
            firstConversation.listingPrice != null &&
                firstConversation.listingPrice! > 0;

        return ThreeDElevatedSurface(
          baseColor: cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Group header
              ListTile(
                onTap: () {
                  HapticFeedbackUtils.impact();
                  setState(() {
                    _expandedGroups[listingId] = !isExpanded;
                  });
                },
                title: Text(
                  listingTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${conversations.length} ${conversations.length == 1 ? L10n.get("conversation_count") : L10n.get("conversations_count")}',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                    // Location, metro, and price (same data as single conversation tiles)
                    if (hasLocation || hasSubwayStation || hasListingPrice) ...[
                      const SizedBox(height: 8),
                      ConversationLocationInfo(
                        conversation: firstConversation,
                        textColor: secondaryTextColor,
                        showPrice: true,
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Unread count indicator for the group
                    if (_getGroupUnreadCount(conversations) > 0) ...[
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${_getGroupUnreadCount(conversations)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    AnimatedRotation(
                      turns: isExpanded ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: ThemeIcon(Icons.expand_less, color: iconColor),
                    ),
                  ],
                ),
              ),
              // Group content with animation
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Column(
                        children: [
                          const Divider(height: 1),
                          ...conversations.map(
                            (conversation) => ConversationTile(
                              conversation: conversation,
                              currentUserId: widget.currentUserId,
                              onTap: () =>
                                  widget.onConversationTap(conversation),
                              isGrouped:
                                  true, // Add this parameter to style differently
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
