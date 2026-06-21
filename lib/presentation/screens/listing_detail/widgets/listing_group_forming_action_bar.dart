import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/widgets/common/glass_green_chat_cta_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

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
    final isManageRequestsSecondary =
        secondaryLabel == L10n.get("group_manage_requests");
    final requestsRepresentedByMemberProfiles =
        onViewMemberProfiles != null && isManageRequestsSecondary;
    final hasSecondaryAction = onSecondary != null &&
        secondaryLabel != null &&
        !requestsRepresentedByMemberProfiles;
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
    final showPrimaryDot = (showManageRequestsDot &&
            !hasSecondaryAction &&
            !requestsRepresentedByMemberProfiles) ||
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

    final children = <Widget>[
      if (onViewMemberProfiles != null) ...[
        _GroupFormingSecondaryButton(
          onPressed: onViewMemberProfiles!,
          icon: Icons.group_outlined,
          label: L10n.get("view_member_profiles"),
          leading: groupProgress?.current == null
              ? null
              : _MemberProfilesLeadingIcon(
                  memberCount: groupProgress!.current,
                  color: _secondaryAccentColor(context),
                ),
          showDot: showMemberProfilesDot,
          dotTrigger: memberProfilesDotTrigger,
          showRequestPill: showMemberProfilesDot,
        ),
        const SizedBox(height: 8),
      ],
      if (hasSecondaryAction) ...[
        _GroupFormingSecondaryButton(
          onPressed: onSecondary!,
          icon: isOpenGroupChatSecondary
              ? Icons.chat_bubble_outline
              : Icons.group_outlined,
          label: secondaryCtaLabel!,
          showDot: showSecondaryDot,
          dotTrigger: secondaryDotTrigger,
          showRequestPill: showManageRequestsDot,
        ),
        const SizedBox(height: 8),
      ],
      _GroupFormingPrimaryButton(
        onPressed: onPrimary,
        icon: isFindHousingPrimary ? Icons.home_rounded : null,
        label: primaryCtaLabel,
        showDot: showPrimaryDot,
        dotTrigger: primaryDotTrigger,
        showRequestPill: showManageRequestsDot &&
            !hasSecondaryAction &&
            onViewMemberProfiles == null,
      ),
    ];

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
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

  Color _secondaryAccentColor(BuildContext context) {
    if (ThemeState().isBlueTheme) return const Color(0xFF34D399);
    return Theme.of(context).colorScheme.primary;
  }
}

class _GroupFormingPrimaryButton extends StatelessWidget {
  const _GroupFormingPrimaryButton({
    required this.onPressed,
    required this.label,
    required this.showDot,
    required this.dotTrigger,
    required this.showRequestPill,
    this.icon,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool showDot;
  final int dotTrigger;
  final bool showRequestPill;

  @override
  Widget build(BuildContext context) {
    final button = GlassGreenChatCtaButton(
      onPressed: onPressed,
      label: label,
      icon: icon ?? Icons.shield,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      height: 48,
      width: double.infinity,
      enableBackdropBlur: false,
    );
    return _GroupActionBadgeWrapper(
      showDot: showDot,
      dotTrigger: dotTrigger,
      showRequestPill: showRequestPill,
      child: button,
    );
  }
}

class _GroupFormingSecondaryButton extends StatefulWidget {
  const _GroupFormingSecondaryButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.showDot,
    required this.dotTrigger,
    required this.showRequestPill,
    this.leading,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Widget? leading;
  final bool showDot;
  final int dotTrigger;
  final bool showRequestPill;

  @override
  State<_GroupFormingSecondaryButton> createState() =>
      _GroupFormingSecondaryButtonState();
}

class _GroupFormingSecondaryButtonState
    extends State<_GroupFormingSecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        ThemeState().isBlueTheme ? const Color(0xFF34D399) : scheme.primary;
    final textColor = ThemeState().isLightTheme ? Colors.black : Colors.white;
    const radius = BorderRadius.all(Radius.circular(12));
    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    final button = SizedBox(
      height: 48,
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: Material(
          color: scheme.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedbackUtils.impact();
              widget.onPressed();
            },
            onHighlightChanged: (v) => setState(() => _pressed = v),
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.60 : 0.70),
                  width: 0.9,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                        scheme.surface, Colors.white, isDark ? 0.10 : 0.18)!,
                    scheme.surface,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.leading ??
                        ThemeIcon(widget.icon, size: 18, color: accentColor),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _GroupActionBadgeWrapper(
        showDot: widget.showDot,
        dotTrigger: widget.dotTrigger,
        showRequestPill: widget.showRequestPill,
        child: button,
      ),
    );
  }
}

class _GroupActionBadgeWrapper extends StatelessWidget {
  const _GroupActionBadgeWrapper({
    required this.child,
    required this.showDot,
    required this.dotTrigger,
    required this.showRequestPill,
  });

  final Widget child;
  final bool showDot;
  final int dotTrigger;
  final bool showRequestPill;

  @override
  Widget build(BuildContext context) {
    if (showRequestPill) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            right: 10,
            top: -9,
            child: _RequestPill(label: L10n.get("group_new_request_pill")),
          ),
        ],
      );
    }
    if (!showDot) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 10,
          top: -4,
          child: PulseThenBlinkDotWidget(
            trigger: dotTrigger,
            color: ThemeState().unreadIndicatorColor,
            size: 10,
            blinkDuration: const Duration(milliseconds: 750),
            borderColor: Theme.of(context).colorScheme.surface,
            borderWidth: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RequestPill extends StatelessWidget {
  const _RequestPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _MemberProfilesLeadingIcon extends StatelessWidget {
  const _MemberProfilesLeadingIcon({
    required this.memberCount,
    required this.color,
  });

  final int memberCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;
    const overlap = 8.0;
    final visibleCount =
        memberCount < 1 ? 1 : (memberCount > 6 ? 6 : memberCount);
    final step = iconSize - overlap;

    return SizedBox(
      width: iconSize + (visibleCount - 1) * step,
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          visibleCount,
          (index) => Positioned(
            left: index * step,
            child: ThemeIcon(
              index.isEven ? Icons.person_outline : Icons.person,
              size: iconSize,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
