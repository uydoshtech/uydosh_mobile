import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_avatar.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";
import "package:uy_dosh/presentation/widgets/conversation/group_tile_action_buttons.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_listing_title_with_category_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
    this.currentUserId,
    this.isGrouped = false,

    /// When true (e.g. messages inbox with day headers), show clock time only — no calendar date in the tile.
    this.showActivityTimeOnly = false,
    this.useFeedTileSurface = false,
    this.surfaceMargin = const EdgeInsets.only(bottom: 16),
    this.showParticipantAvatarStack = false,
    this.groupContext,
    this.onLongPress,
    this.onChatTap,
  });
  final ConversationSummary conversation;
  final VoidCallback onTap;
  final int? currentUserId;
  final bool isGrouped;
  final bool showActivityTimeOnly;
  final bool useFeedTileSurface;
  final EdgeInsetsGeometry? surfaceMargin;
  final bool showParticipantAvatarStack;
  final ListingGroupContext? groupContext;
  final VoidCallback? onLongPress;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return _buildTile(context);
    }
    return ListenableBuilder(
      listenable: ProfileCompletionState(),
      builder: (context, child) => _buildTile(context),
    );
  }

  Widget _buildTile(BuildContext context) {
    final themeState = ThemeState();
    final cardColor = themeState.cardColor;
    final textColor = themeState.cardTextColor;
    final secondaryTextColor = themeState.cardSecondaryTextColor;
    final iconColor = themeState.cardIconColor;
    final avatarColor = themeState.avatarColor;
    final avatarIconColor = themeState.avatarIconColor;
    final unreadColor = themeState.unreadIndicatorColor;
    final unreadTextColor = themeState.unreadIndicatorTextColor;

    // Non–listing chats and listing-group chats show whoever sent the last
    // message (mirrors the preview line). One-to-one listing marketplace
    // chats stay framed around the counterparty — same avatar as
    // [ChatHeader], not your face when you replied last.
    final isListingMarketplace =
        conversationSummaryIsListingMarketplaceChat(conversation);
    final isListingGroup = _isListingGroupConversation(conversation);
    final keepCounterpartyIdentity = isListingMarketplace && !isListingGroup;
    final lastSenderIsCurrentUser = currentUserId != null &&
        conversation.lastMessageSenderId == currentUserId;
    final profileState = ProfileCompletionState();
    final lastSenderMember =
        _memberForUserId(conversation, conversation.lastMessageSenderId);
    final lastSenderRealName = lastSenderIsCurrentUser
        ? profileState.cachedName ?? lastSenderMember?.name
        : lastSenderMember?.name ?? conversation.otherUserName;
    final lastSenderDisplayName = lastSenderIsCurrentUser
        ? L10n.get("chat_last_message_sender_you")
        : lastSenderRealName;
    final titleText = keepCounterpartyIdentity
        ? conversation.otherUserName ?? "Unknown User"
        : lastSenderDisplayName ?? "Unknown User";
    // One-to-one listing chats title the row with the counterparty (same as
    // [ChatHeader]). Showing the last sender's avatar there looked like the
    // peer's face — e.g. "UyDosh" + current user's initials when you
    // replied last.
    final rawAvatar = keepCounterpartyIdentity
        ? conversation.otherUserAvatar
        : (lastSenderIsCurrentUser
            ? profileState.effectiveAvatarUrl ?? lastSenderMember?.avatarUrl
            : lastSenderMember?.avatarUrl ?? conversation.otherUserAvatar);
    final initialsName = keepCounterpartyIdentity ? null : lastSenderRealName;
    final unreadBoldName = conversation.unreadCount != null &&
        conversation.unreadCount! > 0 &&
        currentUserId != null &&
        conversation.lastMessageSenderId != currentUserId;
    final shouldShowParticipantStack = showParticipantAvatarStack &&
        isListingGroup &&
        conversation.members.isNotEmpty;
    final hasUnread = conversation.unreadCount != null &&
        conversation.unreadCount! > 0 &&
        currentUserId != null &&
        conversation.lastMessageSenderId != currentUserId;
    final showUnreadInTrailing =
        onChatTap == null && !shouldShowParticipantStack;
    final pendingJoinRequestCount =
        (groupContext?.pendingJoinRequestCount ?? 0).clamp(0, 999).toInt();
    final groupStatusLabelKey = groupContext?.progressStatusLabelKey;
    final participantAvatarStack = ChatParticipantAvatarStack(
      participants: conversation.members,
      currentUserId: currentUserId,
      avatarSize: 28,
      maxVisible: 5,
    );
    final avatarLeading = UyDoshAvatar(
      avatarUrl: rawAvatar,
      size: UyDoshAvatarSize.medium,
      backgroundColor: avatarColor,
      foregroundColor: avatarIconColor,
      fallback: ConversationAvatarContent(
        conversation: conversation,
        iconColor: avatarIconColor,
        userNameOverride: initialsName,
      ),
    );

    final title = !isGrouped && !isListingMarketplace
        ? ConversationListingTitleWithCategoryIcon(
            conversation: conversation,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            iconColor: iconColor,
          )
        : Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight:
                          unreadBoldName ? FontWeight.bold : FontWeight.w600,
                      height: 1.15,
                      color: textColor,
                    ) ??
                TextStyle(
                  fontSize: 15,
                  fontWeight:
                      unreadBoldName ? FontWeight.bold : FontWeight.w600,
                  height: 1.15,
                  color: textColor,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    final subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Listing / preset title row: on grouped inbox cards the parent
        // header already shows it — omit here to avoid duplication.
        if (isListingMarketplace && !isGrouped) ...[
          ConversationListingTitleWithCategoryIcon(
            conversation: conversation,
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: secondaryTextColor,
            ),
            iconColor: iconColor,
            iconSize: 18,
          ),
          const SizedBox(height: 4),
        ],
        if (!shouldShowParticipantStack &&
            conversation.lastMessageContent != null) ...[
          Text(
            ListingShareMessageCodec.previewText(
              conversation.lastMessageContent!,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: secondaryTextColor),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            ThemeIcon(
              Icons.access_time,
              size: 12,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              _formatTime(
                context,
                conversation.lastMessageAt ?? conversation.updatedAt,
                timeOnly: showActivityTimeOnly,
              ),
              style: TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
          ],
        ),
      ],
    );
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Unread indicator - only show if there are unread messages AND current user is the addressee (not the sender)
        if (hasUnread && showUnreadInTrailing) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: Align(
              // Optical centering: the small badge reads slightly low next
              // to the 18px count badge because of shadow/gradient.
              alignment: conversation.unreadCount! > 1
                  ? Alignment.center
                  : const Alignment(0, -0.12),
              child: Container(
                width: conversation.unreadCount! > 1 ? 18 : 11,
                height: conversation.unreadCount! > 1 ? 18 : 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(unreadColor, Colors.white, 0.32) ??
                          unreadColor,
                      Color.lerp(unreadColor, Colors.black, 0.22) ??
                          unreadColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.24),
                      blurRadius: 6,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                  color: conversation.unreadCount! > 1 ? null : unreadColor,
                ),
                child: conversation.unreadCount! > 1
                    ? Center(
                        child: Text(
                          "${conversation.unreadCount!}",
                          style: TextStyle(
                            color: unreadTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Arrow icon
        if (conversation.lastMessageAt != null)
          SizedBox(
            width: 18,
            height: 18,
            child: Center(
              child: ThemeIcon(
                Icons.arrow_forward_ios,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
      ],
    );

    final listTile = ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      // Sit on parent [ThreeDElevatedSurface] gradient instead of a flat fill.
      tileColor: isGrouped ? Colors.transparent : null,
      // Parent card already owns outer rounding — square top corners so the
      // header seam stays flush (avoids notched gaps at the junction).
      shape: isGrouped
          ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          : null,
      leading: avatarLeading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );

    if (isGrouped) {
      return Material(
        color: Colors.transparent,
        child: listTile,
      );
    }

    final borderRadius = useFeedTileSurface
        ? BorderRadius.circular(12)
        : const BorderRadius.all(Radius.circular(20));
    final useLiquidGlass = useFeedTileSurface &&
        (themeState.usesLiquidGlassChrome);

    final groupTitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
              height: 1.3,
            ) ??
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor,
          height: 1.3,
        );
    final groupParticipantNames = _groupParticipantNames(
      conversation,
      currentUserName: profileState.cachedName,
    );
    final groupTitle = groupParticipantNames != null
        ? Text(
            groupParticipantNames,
            style: groupTitleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        : ConversationListingTitleWithCategoryIcon(
            conversation: conversation,
            textStyle: groupTitleStyle,
            iconColor: iconColor,
            iconSize: 20,
          );
    final groupChatSubtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (conversation.lastMessageContent != null) ...[
          Text(
            ListingShareMessageCodec.previewText(
              conversation.lastMessageContent!,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: secondaryTextColor),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            ThemeIcon(
              Icons.access_time,
              size: 12,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              _formatTime(
                context,
                conversation.lastMessageAt ?? conversation.updatedAt,
                timeOnly: showActivityTimeOnly,
              ),
              style: TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
          ],
        ),
      ],
    );

    final tileContent = shouldShowParticipantStack
        ? _buildGroupTileContent(
            context: context,
            borderRadius: borderRadius,
            participantAvatarStack: participantAvatarStack,
            title: groupTitle,
            subtitle: const SizedBox.shrink(),
            trailing: trailing,
            chatLeading: avatarLeading,
            chatTitle: title,
            chatSubtitle: groupChatSubtitle,
            chatTrailing: trailing,
            secondaryTextColor: secondaryTextColor,
            unreadColor: unreadColor,
            hasUnread: hasUnread,
            groupStatusLabelKey: groupStatusLabelKey,
            pendingJoinRequestCount: pendingJoinRequestCount,
          )
        : listTile;

    return ThreeDElevatedSurface(
      baseColor: useFeedTileSurface
          ? (useLiquidGlass
              ? themeState.primaryColor
              : Theme.of(context).colorScheme.surface)
          : cardColor,
      margin: surfaceMargin,
      borderRadius: borderRadius,
      useLiquidGlass: useLiquidGlass,
      enableBackdropBlur: useFeedTileSurface
          ? LiquidGlassRendering.feedTileBackdropBlurEnabled(context)
          : true,
      liquidGlassShadows: useFeedTileSurface &&
              LiquidGlassRendering.feedTileUseCompactShadows(context)
          ? LiquidGlassRendering.feedTileCompactShadows(context)
          : useFeedTileSurface && themeState.isBlueTheme
              ? ThreeDSurfaceStyle.elevatedShadows(context)
              : null,
      child: tileContent,
    );
  }

  Widget _buildGroupTileContent({
    required BuildContext context,
    required BorderRadius borderRadius,
    required Widget participantAvatarStack,
    required Widget title,
    required Widget subtitle,
    required Widget trailing,
    required Widget chatLeading,
    required Widget chatTitle,
    required Widget chatSubtitle,
    required Widget chatTrailing,
    required Color secondaryTextColor,
    required Color unreadColor,
    required bool hasUnread,
    required String? groupStatusLabelKey,
    required int pendingJoinRequestCount,
  }) {
    final chatTap = onChatTap;
    final topTile = InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: chatTap == null
          ? borderRadius
          : BorderRadius.vertical(top: borderRadius.topLeft),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                participantAvatarStack,
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pendingJoinRequestCount > 0) ...[
                        _GroupJoinRequestBadge(
                          pendingJoinRequestCount: pendingJoinRequestCount,
                        ),
                        if (groupStatusLabelKey != null)
                          const SizedBox(width: 8),
                      ],
                      if (groupStatusLabelKey != null)
                        Flexible(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _GroupProgressStatusBadge(
                              labelKey: groupStatusLabelKey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 3),
                      subtitle,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                trailing,
              ],
            ),
          ],
        ),
      ),
    );

    if (chatTap == null) return topTile;

    final showActionButtons = GroupTileActionButtons.shouldShow(
      conversation: conversation,
      groupContext: groupContext,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        topTile,
        if (showActionButtons)
          GroupTileActionButtons(
            conversation: conversation,
            groupContext: groupContext,
            currentUserId: currentUserId,
          ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: secondaryTextColor.withValues(alpha: 0.14),
        ),
        InkWell(
          onTap: chatTap,
          borderRadius: BorderRadius.vertical(bottom: borderRadius.bottomLeft),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                chatLeading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chatTitle,
                      const SizedBox(height: 3),
                      chatSubtitle,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (hasUnread) ...[
                  PulseThenBlinkDotWidget(
                    trigger: conversation.unreadCount ?? 0,
                    color: unreadColor,
                    size: 22,
                    blinkDuration: const Duration(milliseconds: 750),
                    borderColor: Theme.of(context).colorScheme.surface,
                    borderWidth: 3,
                  ),
                  const SizedBox(width: 10),
                ],
                chatTrailing,
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(
    BuildContext context,
    String dateTimeString, {
    bool timeOnly = false,
  }) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      if (timeOnly) {
        final now = DateTime.now();
        if (now.difference(dateTime) < const Duration(minutes: 1)) {
          return L10n.get("now");
        }
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      }
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return AppDateUtils.formatDateWithMonth(context, dateTime);
      } else if (difference.inHours > 0) {
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else if (difference.inMinutes > 0) {
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else {
        return L10n.get("now");
      }
    } catch (e) {
      return "";
    }
  }

  bool _isListingGroupConversation(ConversationSummary conversation) {
    final contextType = conversation.contextType?.trim().toLowerCase();
    final conversationType =
        conversation.conversationType?.trim().toLowerCase();
    return contextType == "listing_group" ||
        conversationType == "listing_group";
  }

  ConversationMemberSummary? _memberForUserId(
    ConversationSummary conversation,
    int? userId,
  ) {
    if (userId == null) return null;
    for (final member in conversation.members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  String? _groupParticipantNames(
    ConversationSummary conversation, {
    String? currentUserName,
  }) {
    if (conversation.members.isEmpty) return null;

    final orderedMembers = ChatParticipantAvatarStack.orderWithCurrentUserFirst(
      conversation.members,
      currentUserId,
    );
    final seenUserIds = <int>{};
    final names = <String>[];

    for (final member in orderedMembers) {
      if (!seenUserIds.add(member.userId)) continue;

      final currentName =
          member.userId == currentUserId ? currentUserName?.trim() : null;
      final name = currentName != null && currentName.isNotEmpty
          ? currentName
          : member.name.trim();
      if (name.isNotEmpty) names.add(name);
    }

    return names.isEmpty ? null : names.join(", ");
  }
}

class _GroupProgressStatusBadge extends StatelessWidget {
  const _GroupProgressStatusBadge({required this.labelKey});

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final style =
        ListingTypeHelper.getBadgeStyle(ListingTypeCodes.groupForming);

    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Text(
        L10n.get(labelKey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

class _GroupJoinRequestBadge extends StatelessWidget {
  const _GroupJoinRequestBadge({
    required this.pendingJoinRequestCount,
  });

  final int pendingJoinRequestCount;

  @override
  Widget build(BuildContext context) {
    if (pendingJoinRequestCount <= 0) return const SizedBox.shrink();

    final themeState = ThemeState();
    final unreadColor = themeState.unreadIndicatorColor;
    final foreground = themeState.unreadIndicatorTextColor;

    return Tooltip(
      message:
          "${L10n.get("group_pending_join_requests")}: $pendingJoinRequestCount",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(unreadColor, Colors.white, 0.30) ?? unreadColor,
              Color.lerp(unreadColor, Colors.black, 0.20) ?? unreadColor,
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.22),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 7,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add_outlined, size: 13, color: foreground),
            const SizedBox(width: 3),
            Text(
              pendingJoinRequestCount > 99 ? "99+" : "$pendingJoinRequestCount",
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
