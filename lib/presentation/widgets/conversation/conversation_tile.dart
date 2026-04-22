import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
    this.currentUserId,
    this.isGrouped = false,
    /// When true (e.g. messages inbox with day headers), show clock time only — no calendar date in the tile.
    this.showActivityTimeOnly = false,
  });
  final ConversationSummary conversation;
  final VoidCallback onTap;
  final int? currentUserId;
  final bool isGrouped;
  final bool showActivityTimeOnly;

  @override
  Widget build(BuildContext context) {
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

        final resolvedAvatarUrl = resolveAvatarUrl(conversation.otherUserAvatar);

        final listTile = ListTile(
          onTap: onTap,
          // Sit on parent [ThreeDElevatedSurface] gradient instead of a flat fill.
          tileColor: isGrouped ? Colors.transparent : null,
          leading: resolvedAvatarUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: resolvedAvatarUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    memCacheWidth: 80,
                    memCacheHeight: 80,
                    placeholder: (context, url) => Center(
                      child: ConversationAvatarContent(
                        conversation: conversation,
                        iconColor: avatarIconColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: avatarColor,
                      child: ConversationAvatarContent(
                        conversation: conversation,
                        iconColor: avatarIconColor,
                      ),
                    ),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: avatarColor,
                  child: ConversationAvatarContent(
                    conversation: conversation,
                    iconColor: avatarIconColor,
                  ),
                ),
          title: isGrouped
              ? null // Hide title entirely for grouped conversations to remove empty space
              : Text(
                  resolvedConversationListingTitle(conversation),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (conversation.lastMessageContent != null) ...[
                Text(
                  conversation.lastMessageContent!,
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
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unread indicator - only show if there are unread messages AND current user is the addressee (not the sender)
              if (conversation.unreadCount != null &&
                  conversation.unreadCount! > 0 &&
                  currentUserId != null &&
                  conversation.lastMessageSenderId != currentUserId) ...[
                Container(
                  width: conversation.unreadCount! > 1 ? 20 : 12,
                  height: conversation.unreadCount! > 1 ? 20 : 12,
                  decoration: BoxDecoration(
                    color: unreadColor,
                    shape: BoxShape.circle,
                  ),
                  child: conversation.unreadCount! > 1
                      ? Center(
                          child: Text(
                            "${conversation.unreadCount!}",
                            style: TextStyle(
                              color: unreadTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              // Arrow icon
              if (conversation.lastMessageAt != null)
                ThemeIcon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: iconColor,
                ),
            ],
          ),
        );

        if (isGrouped) {
          return Material(
            color: Colors.transparent,
            child: listTile,
          );
        }

        return ThreeDElevatedSurface(
          baseColor: cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          child: listTile,
        );
      },
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
}
