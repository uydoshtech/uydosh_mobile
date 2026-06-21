import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";

class ListingShareMessageBubble extends StatelessWidget {
  const ListingShareMessageBubble({
    required this.message,
    required this.payload,
    required this.isCurrentUser,
    required this.onOpenListing,
    required this.onRate,
    this.rating,
    this.leftAvatarInitials,
    this.rightAvatarInitials,
    this.leftAvatarUrl,
    this.rightAvatarUrl,
    super.key,
  });

  final Message message;
  final ListingShareMessagePayload payload;
  final MessageListingRating? rating;
  final bool isCurrentUser;
  final VoidCallback onOpenListing;
  final ValueChanged<int> onRate;
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
        : (themeState.isBlueTheme
            ? Colors.white
            : theme.colorScheme.onSurface);
    final footerColor = textColor.withValues(alpha: 0.95);

    return ChatMessageRow(
      isFromCurrentUser: isCurrentUser,
      leftAvatarInitials: leftAvatarInitials,
      rightAvatarInitials: rightAvatarInitials,
      leftAvatarUrl: leftAvatarUrl,
      rightAvatarUrl: rightAvatarUrl,
      bubbleChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (payload.intro != null && payload.intro!.isNotEmpty) ...[
            Text(
              payload.intro!,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            payload.title,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (payload.location != null) ...[
            const SizedBox(height: 6),
            _DetailLine(
              emoji: "📍",
              label: payload.location!,
              color: textColor,
            ),
          ],
          if (payload.metro != null) ...[
            const SizedBox(height: 4),
            _DetailLine(
              emoji: "🚇",
              label: payload.metro!,
              color: textColor,
            ),
          ],
          if (payload.priceLabel != null) ...[
            const SizedBox(height: 4),
            _DetailLine(
              emoji: "💰",
              label: payload.priceLabel!,
              color: textColor,
            ),
          ],
          const SizedBox(height: 10),
          _StarRatingRow(
            myStars: rating?.myStars,
            average: rating?.average,
            count: rating?.count ?? 0,
            onRate: onRate,
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedbackUtils.impact();
                onOpenListing();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: textColor.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: footerColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      L10n.get("group_shortlist_open_listing"),
                      style: TextStyle(
                        color: footerColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.emoji,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      "$emoji $label",
      style: TextStyle(color: color, fontSize: 14, height: 1.3),
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({
    required this.myStars,
    required this.average,
    required this.count,
    required this.onRate,
  });

  final int? myStars;
  final double? average;
  final int count;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = count > 0 && average != null
        ? L10n.getWithParams(
            "group_shortlist_rating_summary",
            params: {
              "average": average!.toStringAsFixed(1),
              "count": count.toString(),
            },
          )
        : L10n.get("group_shortlist_rate_prompt");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final filled = (myStars ?? 0) >= starValue;
            return IconButton(
              onPressed: () {
                HapticFeedbackUtils.selectionClick();
                onRate(starValue);
              },
              padding: const EdgeInsets.symmetric(horizontal: 2),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 22,
                color: filled
                    ? AppColors.warning
                    : theme.colorScheme.onSurfaceVariant,
              ),
            );
          }),
        ),
        Text(
          summary,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
