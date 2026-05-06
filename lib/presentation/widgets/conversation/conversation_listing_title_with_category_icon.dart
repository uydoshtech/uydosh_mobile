import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

IconData? gigCategoryIconForConversationSummary(ConversationSummary c) {
  if (c.contextType != "gig_request") return null;
  final id = c.gigCategoryId;
  if (id == null) return null;
  return gigCategoryIcon(GigCategoryCache.getById(id)?.code);
}

/// Listing / gig-request title with leading category glyph when the server
/// sends [ConversationSummary.gigCategoryId] for `gig_request` chats.
class ConversationListingTitleWithCategoryIcon extends StatelessWidget {
  const ConversationListingTitleWithCategoryIcon({
    required this.conversation,
    required this.textStyle,
    required this.iconColor,
    super.key,
    this.iconSize = 22,
  });

  final ConversationSummary conversation;
  final TextStyle textStyle;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final icon = gigCategoryIconForConversationSummary(conversation);
    return Row(
      children: [
        if (icon != null) ...[
          ThemeIcon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            resolvedConversationListingTitle(conversation),
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
