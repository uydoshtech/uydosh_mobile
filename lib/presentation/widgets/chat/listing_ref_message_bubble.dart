import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";

/// Compact, tappable breadcrumb that points at a listing card already posted
/// earlier in the same group chat. Tapping it scrolls the chat to the original
/// card (see [onTapAnchor]).
class ListingRefMessageBubble extends StatelessWidget {
  const ListingRefMessageBubble({
    required this.message,
    required this.payload,
    required this.isCurrentUser,
    required this.onTapAnchor,
    this.leftAvatarInitials,
    this.rightAvatarInitials,
    this.leftAvatarUrl,
    this.rightAvatarUrl,
    super.key,
  });

  final Message message;
  final ListingRefMessagePayload payload;
  final bool isCurrentUser;
  final VoidCallback onTapAnchor;
  final String? leftAvatarInitials;
  final String? rightAvatarInitials;
  final String? leftAvatarUrl;
  final String? rightAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final textColor = isCurrentUser
        ? (themeState.isBlueTheme || themeState.isLightTheme
            ? Colors.black
            : AppColors.textDark87)
        : (themeState.isBlueTheme ? Colors.white : theme.colorScheme.onSurface);
    // Match the bubble's own text color so the header stays legible across
    // themes (e.g. the current user's bubble is light in the blue theme, where
    // a white accent would vanish).
    final accent = textColor;
    final title = payload.title.trim().isEmpty
        ? L10n.get("group_shortlist_ref_label")
        : payload.title.trim();

    return ChatMessageRow(
      isFromCurrentUser: isCurrentUser,
      leftAvatarInitials: leftAvatarInitials,
      rightAvatarInitials: rightAvatarInitials,
      leftAvatarUrl: leftAvatarUrl,
      rightAvatarUrl: rightAvatarUrl,
      bubbleChild: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackUtils.impact();
            onTapAnchor();
          },
          borderRadius: BorderRadius.circular(10),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.subdirectory_arrow_right_rounded,
                        size: 16, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      L10n.get("group_shortlist_ref_label"),
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // A quote-style left border to read as a reference, not a card.
                Container(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(
                        color: accent.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 13,
                        color: textColor.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      L10n.get("group_shortlist_ref_tap_hint"),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
