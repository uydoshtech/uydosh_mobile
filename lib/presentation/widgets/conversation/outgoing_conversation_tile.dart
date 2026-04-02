import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";

class OutgoingConversationTile extends StatelessWidget {

  const OutgoingConversationTile({
    required this.conversation, required this.onTap, super.key,
    this.currentUserId,
  });
  final ConversationSummary conversation;
  final VoidCallback onTap;
  final int? currentUserId;

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

        // Check if we have location or metro station data
        final hasLocation =
            conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation =
            conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: cardColor,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            onTap: onTap,
            leading: conversation.otherUserAvatar != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: conversation.otherUserAvatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      memCacheWidth: 80,
                      memCacheHeight: 80,
                      placeholder:
                          (context, url) => Center(
                            child: ConversationAvatarContent(
                              conversation: conversation,
                              iconColor: avatarIconColor,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => CircleAvatar(
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
            title: Text(
              conversation.listingTitle ?? "Listing #${conversation.listingId}",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and Metro Station Information
                if (hasLocation || hasSubwayStation) ...[
                  ConversationLocationInfo(
                    conversation: conversation,
                    textColor: secondaryTextColor,
                    showPrice: true,
                  ),
                  const SizedBox(height: 8),
                ],
                // Last message content
                if (conversation.lastMessageContent != null) ...[
                  Text(
                    conversation.lastMessageContent!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  const SizedBox(height: 4),
                ],
                // Time and user info
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(
                        context,
                        conversation.lastMessageAt ?? conversation.updatedAt,
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
                    decoration: const BoxDecoration(
                      color:
                          AppColors.success, // Keep green for unread indicator
                      shape: BoxShape.circle,
                    ),
                    child:
                        conversation.unreadCount! > 1
                            ? Center(
                              child: Text(
                                "${conversation.unreadCount!}",
                                style: const TextStyle(
                                  color: Colors.white,
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
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: iconColor.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(BuildContext context, String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return AppDateUtils.formatDateWithMonth(context, dateTime);
      } else if (difference.inHours > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inMinutes > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return L10n.get("now");
      }
    } catch (e) {
      return "";
    }
  }
}
