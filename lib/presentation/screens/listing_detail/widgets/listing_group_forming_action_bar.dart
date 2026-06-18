import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_contact_action_bar.dart";

/// Sticky footer for `group_forming` listings (join / chat / manage requests).
class ListingGroupFormingActionBar extends StatelessWidget {
  const ListingGroupFormingActionBar({
    super.key,
    required this.listingDetail,
    required this.onPrimary,
    required this.primaryLabel,
    this.onSecondary,
    this.secondaryLabel,
  });

  final ListingDetail listingDetail;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final ctx = listingDetail.groupContext;
    final target = ctx?.groupSizeTarget ?? listingDetail.groupSizeTarget;
    final current = ctx?.groupMemberCount ?? 1;
    final progress = target != null
        ? L10n.getWithParams(
            "group_members_progress",
            params: {
              "current": "$current",
              "target": "$target",
            },
          )
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (progress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              progress,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeState().isBlueTheme
                    ? Colors.white70
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (onSecondary != null && secondaryLabel != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel!),
            ),
          ),
        ListingDetailContactActionBar(
          onMessage: onPrimary,
          inAppChatCtaLabel: primaryLabel,
        ),
      ],
    );
  }
}
