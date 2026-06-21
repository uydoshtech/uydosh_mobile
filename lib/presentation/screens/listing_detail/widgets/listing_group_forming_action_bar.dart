import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_contact_action_bar.dart";

/// Inline CTAs for `group_forming` listings (join / chat / manage requests).
class ListingGroupFormingActionBar extends StatelessWidget {
  const ListingGroupFormingActionBar({
    super.key,
    required this.listingDetail,
    required this.onPrimary,
    required this.primaryLabel,
    this.onSecondary,
    this.secondaryLabel,
    this.showManageRequestsDot = false,
    this.manageRequestsDotTrigger = 0,
    this.onViewMemberProfiles,
  });

  final ListingDetail listingDetail;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final String? secondaryLabel;
  final bool showManageRequestsDot;
  final int manageRequestsDotTrigger;
  final VoidCallback? onViewMemberProfiles;

  @override
  Widget build(BuildContext context) {
    final groupProgress = ListingGroupProgress.fromListingDetail(listingDetail);
    final progress = groupProgress != null
        ? L10n.getWithParams(
            "group_members_progress",
            params: {
              "current": "${groupProgress.current}",
              "target": "${groupProgress.target}",
            },
          )
        : null;
    final hasSecondaryAction =
        onSecondary != null && secondaryLabel != null;
    final isOpenGroupChatPrimary =
        primaryLabel == L10n.get("group_open_chat");
    final isOpenGroupChatSecondary =
        secondaryLabel == L10n.get("group_open_chat");
    final includePrimaryProgress = !hasSecondaryAction &&
        primaryLabel != L10n.get("group_manage_requests");
    final primaryCtaLabel = _labelWithProgress(
      primaryLabel,
      progress,
      includeProgress: includePrimaryProgress || isOpenGroupChatPrimary,
    );
    final secondaryCtaLabel = hasSecondaryAction
        ? _labelWithProgress(
            secondaryLabel!,
            progress,
            includeProgress: isOpenGroupChatSecondary,
          )
        : null;
    final notificationDot = showManageRequestsDot
        ? (hasSecondaryAction
            ? ListingDetailActionBarNotificationDot.top
            : ListingDetailActionBarNotificationDot.primary)
        : null;

    return ListingDetailContactActionBar(
      embedded: true,
      onMessage: onPrimary,
      inAppChatCtaLabel: primaryCtaLabel,
      onSecondary: onSecondary,
      secondaryLabel: secondaryCtaLabel,
      secondaryIcon: isOpenGroupChatSecondary
          ? Icons.chat_bubble_outline
          : null,
      notificationDot: notificationDot,
      notificationDotTrigger: manageRequestsDotTrigger,
      onMemberProfiles: onViewMemberProfiles,
    );
  }

  String _labelWithProgress(
    String label,
    String? progress, {
    required bool includeProgress,
  }) {
    if (!includeProgress || progress == null) return label;
    return "$label ($progress)";
  }
}
