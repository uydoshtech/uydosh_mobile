import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";
import "package:uy_dosh/base/localization/l10n.dart";

class GroupedConversationsList extends StatefulWidget {

  const GroupedConversationsList({
    required this.conversations, required this.onConversationTap, super.key,
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

  @override
  Widget build(BuildContext context) {
    // Group conversations by listing ID
    final groupedConversations = <int, List<ConversationSummary>>{};
    for (final conversation in widget.conversations) {
      if (!groupedConversations.containsKey(conversation.listingId)) {
        groupedConversations[conversation.listingId] = [];
      }
      groupedConversations[conversation.listingId]!.add(conversation);
    }

    // Sort conversations within each group: unread messages first, then by last message time
    groupedConversations.forEach((listingId, conversations) {
      conversations.sort((a, b) {
        // Check if conversations have unread messages
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

        // If one has unread and the other doesn't, prioritize the one with unread
        if (aHasUnread && !bHasUnread) return -1;
        if (!aHasUnread && bHasUnread) return 1;

        // If both have same unread status, sort by last message time (most recent first)
        final aTime = a.lastMessageAt ?? a.updatedAt;
        final bTime = b.lastMessageAt ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });
    });

    // Get sorted listing IDs: groups with unread messages first, then by most recent conversation
    final sortedListingIds =
        groupedConversations.keys.toList()..sort((a, b) {
          final aConversations = groupedConversations[a]!;
          final bConversations = groupedConversations[b]!;

          // Check if groups have any unread messages
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

          // If one group has unread and the other doesn't, prioritize the one with unread
          if (aHasUnread && !bHasUnread) return -1;
          if (!aHasUnread && bHasUnread) return 1;

          // If both groups have same unread status, sort by most recent conversation
          final aLatest =
              aConversations.first.lastMessageAt ??
              aConversations.first.updatedAt;
          final bLatest =
              bConversations.first.lastMessageAt ??
              bConversations.first.updatedAt;
          return bLatest.compareTo(aLatest);
        });

    // Auto-expand the first group with unread messages
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

    return CommonListView(
      padding: const EdgeInsets.all(16),
      itemCount: sortedListingIds.length,
      itemBuilder: (context, index) {
        final listingId = sortedListingIds[index];
        final conversations = groupedConversations[listingId]!;
        final isExpanded =
            _expandedGroups[listingId] ?? false; // Default to collapsed
        final listingTitle =
            conversations.first.listingTitle ?? "Listing #$listingId";

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
        final hasLocation =
            firstConversation.locationNameUz != null ||
            firstConversation.locationNameRu != null ||
            firstConversation.locationNameEn != null;
        final hasSubwayStation =
            firstConversation.subwayStationNameUz != null ||
            firstConversation.subwayStationNameRu != null ||
            firstConversation.subwayStationNameEn != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: cardColor,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                    // Location and Metro Station Information
                    if (hasLocation || hasSubwayStation) ...[
                      const SizedBox(height: 8),
                      ConversationLocationInfo(
                        conversation: firstConversation,
                        textColor: secondaryTextColor,
                        showPrice: false,
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
                      child: Icon(Icons.expand_less, color: iconColor),
                    ),
                  ],
                ),
              ),
              // Group content with animation
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:
                    isExpanded
                        ? Column(
                          children: [
                            const Divider(height: 1),
                            ...conversations.map(
                              (conversation) => ConversationTile(
                                conversation: conversation,
                                currentUserId: widget.currentUserId,
                                onTap:
                                    () =>
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
