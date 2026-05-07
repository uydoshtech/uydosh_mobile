import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";

IconData? gigCategoryIconForConversationSummary(ConversationSummary c) {
  if (c.contextType != "gig_request") return null;
  final id = c.gigCategoryId;
  if (id == null) return null;
  return gigCategoryIcon(GigCategoryCache.getById(id)?.code);
}

/// Leading glyph for inbox / conversation rows: gig category when available,
/// otherwise [ListingTypeHelper] icons for housing (`room_needed` / `roommate_needed`),
/// matching [ListingTypeIconBadge] on listing cards.
IconData? conversationListingLeadingIcon(ConversationSummary c) {
  final gig = gigCategoryIconForConversationSummary(c);
  if (gig != null) return gig;
  if (c.listingId == null) return null;

  final typeId = c.listingTypeId;
  if (typeId != null) {
    final code = ListingTypeHelper.getCodeFromId(typeId);
    return ListingTypeHelper.getIcon(code);
  }
  return Icons.home;
}

/// Listing / gig-request title with a leading glyph: gig category when the
/// server sends [ConversationSummary.gigCategoryId] for `gig_request` chats,
/// or listing-type icons / [Icons.home] fallback for housing threads.
class ConversationListingTitleWithCategoryIcon extends StatelessWidget {
  const ConversationListingTitleWithCategoryIcon({
    required this.conversation,
    required this.textStyle,
    required this.iconColor,
    super.key,
    this.iconSize = 22,
    this.titleMaxLines = 1,
  });

  final ConversationSummary conversation;
  final TextStyle textStyle;
  final Color iconColor;
  final double iconSize;

  /// Listing / gig title line cap. Inbox group headers use 2 so long titles
  /// are readable; dense [ListTile] rows keep the default of 1.
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final icon = conversationListingLeadingIcon(conversation);
    final themeState = ThemeState();
    final isGigCategoryBadge =
        gigCategoryIconForConversationSummary(conversation) != null;

    var badgeIconColor = iconColor;
    var badgeBgColor = iconColor.withValues(alpha: 0.14);
    if (isGigCategoryBadge && themeState.isBlueTheme) {
      badgeIconColor = BlueThemeColors.textPrimary;
      badgeBgColor = BlueThemeColors.textPrimary.withValues(alpha: 0.14);
    } else if (!isGigCategoryBadge && conversation.listingTypeId != null) {
      final code = ListingTypeHelper.getCodeFromId(conversation.listingTypeId!);
      if (code != "unknown") {
        final tint = ListingTypeHelper.getColor(code);
        badgeIconColor = tint;
        badgeBgColor = tint.withValues(alpha: 0.18);
      }
    }

    final badgeScale =
        themeState.isBlueTheme && icon != null ? 1.2 : 1.0;
    final badgeDimension = (iconSize + 4) * badgeScale;
    final glyphSize = (iconSize * 0.64).clamp(11.0, 14.5) * badgeScale;

    return Row(
      crossAxisAlignment: titleMaxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          GigCategoryIconBadge(
            icon: icon,
            iconColor: badgeIconColor,
            badgeBackgroundColor: badgeBgColor,
            dimension: badgeDimension,
            iconSize: glyphSize,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            resolvedConversationListingTitle(conversation),
            style: textStyle,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
