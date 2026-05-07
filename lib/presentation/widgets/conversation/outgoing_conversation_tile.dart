import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_info_widgets.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_listing_title_with_category_icon.dart";

class OutgoingConversationTile extends StatelessWidget {
  const OutgoingConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
    this.currentUserId,
    /// When true (e.g. messages inbox with day headers), show clock time only — no calendar date in the tile.
    this.showActivityTimeOnly = false,
    this.onLongPress,
  });
  final ConversationSummary conversation;
  final VoidCallback onTap;
  final int? currentUserId;
  final bool showActivityTimeOnly;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable:
          Listenable.merge([ThemeState(), ProfileCompletionState()]),
      builder: (context, child) {
        final themeState = ThemeState();
        final cardColor = themeState.cardColor;
        final textColor = themeState.cardTextColor;
        final secondaryTextColor = themeState.cardSecondaryTextColor;
        final iconColor = themeState.cardIconColor;
        final avatarColor = themeState.avatarColor;
        final avatarIconColor = themeState.avatarIconColor;
        final outlineVariant = Theme.of(context).colorScheme.outlineVariant;
        final unreadColor = themeState.unreadIndicatorColor;
        final unreadTextColor = themeState.unreadIndicatorTextColor;

        final hasLocation = conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation = conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;
        final hasBudgetBadge = conversationSummaryShowsBudgetBadge(conversation);
        final isListingMarketplace =
            conversationSummaryIsListingMarketplaceChat(conversation);

        // Show the avatar of whoever sent the most recent message: the current
        // user when they were the last sender, otherwise the conversation
        // partner.
        final lastSenderIsCurrentUser = currentUserId != null &&
            conversation.lastMessageSenderId == currentUserId;
        final profileState = ProfileCompletionState();
        final rawAvatar = lastSenderIsCurrentUser
            ? profileState.cachedAvatarUrl
            : conversation.otherUserAvatar;
        final initialsName = lastSenderIsCurrentUser
            ? profileState.cachedName
            : null;
        final resolvedAvatarUrl = resolveAvatarUrl(rawAvatar);
        const avatarSize = 40.0;

        final avatarLeading = resolvedAvatarUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: resolvedAvatarUrl,
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                  memCacheWidth: 80,
                  memCacheHeight: 80,
                  placeholder:
                      (context, url) => SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: Center(
                          child: ConversationAvatarContent(
                            conversation: conversation,
                            iconColor: avatarIconColor,
                            userNameOverride: initialsName,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: CircleAvatar(
                          backgroundColor: avatarColor,
                          child: ConversationAvatarContent(
                            conversation: conversation,
                            iconColor: avatarIconColor,
                            userNameOverride: initialsName,
                          ),
                        ),
                      ),
                ),
              )
            : CircleAvatar(
                backgroundColor: avatarColor,
                child: ConversationAvatarContent(
                  conversation: conversation,
                  iconColor: avatarIconColor,
                  userNameOverride: initialsName,
                ),
              );

        return ThreeDElevatedSurface(
          baseColor: cardColor,
          useFlatHighlightColor: true,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isListingMarketplace) ...[
                        Text(
                          conversation.otherUserName ?? "Unknown User",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],
                      ConversationListingTitleWithCategoryIcon(
                        conversation: conversation,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        iconColor: iconColor,
                        titleMaxLines: 2,
                      ),
                      if (hasLocation || hasSubwayStation || hasBudgetBadge) ...[
                        const SizedBox(height: 8),
                        ConversationLocationInfo(
                          conversation: conversation,
                          textColor: secondaryTextColor,
                          showPrice: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: outlineVariant),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      avatarLeading,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
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
                                    conversation.lastMessageAt ??
                                        conversation.updatedAt,
                                    timeOnly: showActivityTimeOnly,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (conversation.unreadCount != null &&
                              conversation.unreadCount! > 0 &&
                              currentUserId != null &&
                              conversation.lastMessageSenderId !=
                                  currentUserId) ...[
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Align(
                                alignment:
                                    conversation.unreadCount! > 1
                                        ? Alignment.center
                                        : const Alignment(0, -0.12),
                                child: Container(
                                  width:
                                      conversation.unreadCount! > 1 ? 18 : 11,
                                  height:
                                      conversation.unreadCount! > 1 ? 18 : 11,
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
                                    color:
                                        conversation.unreadCount! > 1
                                            ? null
                                            : unreadColor,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
