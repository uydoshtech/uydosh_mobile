import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_contact_action_bar.dart";

/// Inline CTAs for `group_forming` listings (join / chat / manage requests).
class ListingGroupFormingActionBar extends StatelessWidget {
  const ListingGroupFormingActionBar({
    required this.listingDetail,
    required this.onPrimary,
    required this.primaryLabel,
    super.key,
    this.onSecondary,
    this.secondaryLabel,
    this.showManageRequestsDot = false,
    this.manageRequestsDotTrigger = 0,
    this.showGroupChatUnreadDot = false,
    this.groupChatUnreadDotTrigger = 0,
    this.onViewMemberProfiles,
    this.showMemberProfilesDot = false,
    this.memberProfilesDotTrigger = 0,
  });

  final ListingDetail listingDetail;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final String? secondaryLabel;
  final bool showManageRequestsDot;
  final int manageRequestsDotTrigger;
  final bool showGroupChatUnreadDot;
  final int groupChatUnreadDotTrigger;
  final VoidCallback? onViewMemberProfiles;
  final bool showMemberProfilesDot;
  final int memberProfilesDotTrigger;

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
    final hasSecondaryAction = onSecondary != null && secondaryLabel != null;
    final isOpenGroupChatPrimary = primaryLabel == L10n.get("group_open_chat");
    final isOpenGroupChatSecondary =
        secondaryLabel == L10n.get("group_open_chat");
    final isFindHousingPrimary = primaryLabel == L10n.get("group_find_housing");
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
    final showPrimaryDot = (showManageRequestsDot && !hasSecondaryAction) ||
        (showGroupChatUnreadDot && isOpenGroupChatPrimary);
    final showSecondaryDot = (showManageRequestsDot && hasSecondaryAction) ||
        (showGroupChatUnreadDot && isOpenGroupChatSecondary);
    final primaryDotTrigger = showGroupChatUnreadDot && isOpenGroupChatPrimary
        ? groupChatUnreadDotTrigger
        : manageRequestsDotTrigger;
    final secondaryDotTrigger =
        showGroupChatUnreadDot && isOpenGroupChatSecondary
            ? groupChatUnreadDotTrigger
            : manageRequestsDotTrigger;

    return ListingDetailContactActionBar(
      embedded: true,
      onMessage: onPrimary,
      inAppChatCtaLabel: primaryCtaLabel,
      primaryIcon: isFindHousingPrimary ? Icons.home_rounded : null,
      onSecondary: onSecondary,
      secondaryLabel: secondaryCtaLabel,
      secondaryIcon:
          isOpenGroupChatSecondary ? Icons.chat_bubble_outline : null,
      showPrimaryNotificationDot: showPrimaryDot,
      primaryNotificationDotTrigger: primaryDotTrigger,
      showPrimaryRequestPill: showManageRequestsDot && !hasSecondaryAction,
      showSecondaryNotificationDot: showSecondaryDot,
      secondaryNotificationDotTrigger: secondaryDotTrigger,
      showSecondaryRequestPill: showManageRequestsDot && hasSecondaryAction,
      onMemberProfiles: onViewMemberProfiles,
      memberProfilesCount: groupProgress?.current,
      showMemberProfilesNotificationDot: showMemberProfilesDot,
      memberProfilesNotificationDotTrigger: memberProfilesDotTrigger,
      showMemberProfilesRequestPill: showMemberProfilesDot,
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
