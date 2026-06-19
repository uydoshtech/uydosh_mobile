import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_contact_action_bar.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

/// Sticky footer for `group_forming` listings (join / chat / manage requests).
class ListingGroupFormingActionBar extends StatelessWidget {
  const ListingGroupFormingActionBar({
    super.key,
    required this.listingDetail,
    required this.onPrimary,
    required this.primaryLabel,
    this.onSecondary,
    this.secondaryLabel,
    this.showManageRequestsDot = false,
    this.manageRequestsDotOnSecondary = false,
    this.manageRequestsDotTrigger = 0,
  });

  final ListingDetail listingDetail;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final String? secondaryLabel;
  final bool showManageRequestsDot;
  final bool manageRequestsDotOnSecondary;
  final int manageRequestsDotTrigger;

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
            child: _ManageRequestsNotificationDot(
              showDot:
                  showManageRequestsDot && manageRequestsDotOnSecondary,
              trigger: manageRequestsDotTrigger,
              child: OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ),
          ),
        ListingDetailContactActionBar(
          onMessage: onPrimary,
          inAppChatCtaLabel: primaryLabel,
          showChatNotificationDot:
              showManageRequestsDot && !manageRequestsDotOnSecondary,
          chatNotificationDotTrigger: manageRequestsDotTrigger,
        ),
      ],
    );
  }
}

class _ManageRequestsNotificationDot extends StatelessWidget {
  const _ManageRequestsNotificationDot({
    required this.child,
    required this.showDot,
    required this.trigger,
  });

  final Widget child;
  final bool showDot;
  final int trigger;

  @override
  Widget build(BuildContext context) {
    if (!showDot) return child;

    final theme = Theme.of(context);
    final unreadColor = ThemeState().unreadIndicatorColor;
    final dotBorderColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(width: double.infinity, child: child),
        Positioned(
          right: 10,
          top: -4,
          child: PulseThenBlinkDotWidget(
            trigger: trigger,
            color: unreadColor,
            size: 10,
            blinkDuration: const Duration(milliseconds: 750),
            borderColor: dotBorderColor,
            borderWidth: 1.5,
          ),
        ),
      ],
    );
  }
}
