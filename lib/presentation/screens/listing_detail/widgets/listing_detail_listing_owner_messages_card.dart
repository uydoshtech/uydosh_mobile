import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Admin moderation entry — opens every listing-scoped in-app chat for this listing.
class ListingDetailListingOwnerMessagesCard extends StatelessWidget {

  const ListingDetailListingOwnerMessagesCard({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListingDetailTileShell(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedbackUtils.impact();
              onPressed();
            },
            icon: const ThemeIcon(Icons.forum_outlined),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  L10n.get("admin_listing_owner_conversations_card_title"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  L10n.get("admin_listing_owner_conversations_card_subtitle"),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.textDark,
                  ),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              alignment: Alignment.centerLeft,
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}
