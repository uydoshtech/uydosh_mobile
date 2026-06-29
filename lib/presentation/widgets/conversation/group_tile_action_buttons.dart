import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/follow_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_group_member_profiles_sheet.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

/// Shortlist + participants actions shown on group conversation tiles.
class GroupTileActionButtons extends StatefulWidget {
  const GroupTileActionButtons({
    required this.conversation,
    required this.groupContext,
    required this.currentUserId,
    super.key,
  });

  final ConversationSummary conversation;
  final ListingGroupContext? groupContext;
  final int? currentUserId;

  static bool shouldShow({
    required ConversationSummary conversation,
    required ListingGroupContext? groupContext,
  }) {
    final ctx = groupContext;
    final showShortlist = ctx?.canUseHousingShortlist == true &&
        (ctx?.isOwner == true || ctx?.isMember == true);
    final members = conversation.members;
    final showParticipants = members.isNotEmpty ||
        (ctx?.groupMemberCount ?? 0) >=
            ListingGroupProgress.minMembersForGroupCompatibility;
    return showShortlist || showParticipants;
  }

  @override
  State<GroupTileActionButtons> createState() => _GroupTileActionButtonsState();
}

class _GroupTileActionButtonsState extends State<GroupTileActionButtons> {
  @override
  void initState() {
    super.initState();
    _seedShortlistCount();
  }

  @override
  void didUpdateWidget(covariant GroupTileActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupContext?.groupShortlistCount !=
            widget.groupContext?.groupShortlistCount ||
        oldWidget.conversation.listingId != widget.conversation.listingId) {
      _seedShortlistCount();
    }
  }

  void _seedShortlistCount() {
    final listingId = widget.conversation.listingId;
    final count = widget.groupContext?.groupShortlistCount;
    if (listingId == null || count == null) return;
    GroupShortlistState().setShortlistCountForGroup(listingId, count);
  }

  bool get _showShortlist {
    final ctx = widget.groupContext;
    if (ctx?.canUseHousingShortlist != true) return false;
    return ctx?.isOwner == true || ctx?.isMember == true;
  }

  bool get _showParticipants {
    final members = widget.conversation.members;
    if (members.isNotEmpty) return true;
    final count = widget.groupContext?.groupMemberCount ?? 0;
    return count >= ListingGroupProgress.minMembersForGroupCompatibility;
  }

  @override
  Widget build(BuildContext context) {
    if (!_showShortlist && !_showParticipants) {
      return const SizedBox.shrink();
    }

    final pendingJoinRequestCount =
        (widget.groupContext?.pendingJoinRequestCount ?? 0).clamp(0, 999);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showShortlist) _buildShortlistButton(context),
          if (_showShortlist && _showParticipants) const SizedBox(height: 8),
          if (_showParticipants)
            _buildParticipantsButton(
              context,
              pendingJoinRequestCount: pendingJoinRequestCount,
            ),
        ],
      ),
    );
  }

  Widget _buildShortlistButton(BuildContext context) {
    final listingId = widget.conversation.listingId;
    if (listingId == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: GroupShortlistState(),
      builder: (context, _) {
        final count = GroupShortlistState().shortlistCountForGroup(listingId);
        final label = count > 0
            ? L10n.getWithParams(
                "group_floating_shortlist_label",
                params: {"count": count > 99 ? "99+" : count.toString()},
              )
            : L10n.get("group_shortlist_title");

        return _GroupTileActionButton(
          label: label,
          mutedBackground: true,
          leading: Icon(
            Icons.bookmark,
            size: 20,
            color: _foregroundColor(context),
          ),
          onTap: () {
            HapticFeedbackUtils.impact();
            unawaited(
              GroupHousingFlow.openShortlistSheet(
                context: context,
                groupListingId: listingId,
                isOwner: widget.groupContext?.isOwner == true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParticipantsButton(
    BuildContext context, {
    required int pendingJoinRequestCount,
  }) {
    final members = widget.conversation.members;
    final canOpen = members.isNotEmpty;
    final label = L10n.get("group_floating_participants_label");
    final memberCount =
        widget.groupContext?.groupMemberCount ?? members.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _GroupTileActionButton(
          label: label,
          mutedBackground: false,
          leading: members.isEmpty
              ? _ParticipantIconStack(
                  count: memberCount,
                  color: _foregroundColor(context),
                )
              : ChatParticipantAvatarStack(
                  participants: members,
                  currentUserId: widget.currentUserId,
                  avatarSize: 22,
                  maxVisible: 5,
                ),
          onTap: canOpen
              ? () {
                  HapticFeedbackUtils.impact();
                  unawaited(_openParticipantsSheet(context));
                }
              : null,
        ),
        if (pendingJoinRequestCount > 0)
          Positioned(
            right: 4,
            top: -3,
            child: PulseThenBlinkDotWidget(
              trigger: pendingJoinRequestCount,
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

  Future<void> _openParticipantsSheet(BuildContext context) async {
    final listingId = widget.conversation.listingId;
    final members = widget.conversation.members;
    if (listingId == null || members.isEmpty) return;

    final ownerUserId = members.first.userId;
    final isOwner = widget.groupContext?.isOwner == true ||
        (widget.currentUserId != null &&
            widget.currentUserId == ownerUserId);

    await showListingGroupMemberProfilesSheet(
      context: context,
      listingId: listingId,
      members: members,
      ownerUserId: ownerUserId,
      currentUserId: widget.currentUserId,
      isOwner: isOwner,
      groupProgress: widget.groupContext == null
          ? null
          : ListingGroupProgress.fromGroupContext(widget.groupContext!),
      onMemberTap: (userId) => _navigateToProfile(context, userId),
    );
  }

  void _navigateToProfile(BuildContext context, int userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (context) => ListingOwnerProfileBloc(
            getIt<IUserProfileService>(),
            getIt<IFollowService>(),
          ),
          child: ListingOwnerProfileScreen(userId: userId),
        ),
      ),
    );
  }

  Color _foregroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;
  }
}

class _GroupTileActionButton extends StatefulWidget {
  const _GroupTileActionButton({
    required this.label,
    required this.leading,
    required this.mutedBackground,
    this.onTap,
  });

  final String label;
  final Widget leading;
  final bool mutedBackground;
  final VoidCallback? onTap;

  @override
  State<_GroupTileActionButton> createState() => _GroupTileActionButtonState();
}

class _GroupTileActionButtonState extends State<_GroupTileActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : theme.colorScheme.onSurface;
    final enabled = widget.onTap != null;
    final background = widget.mutedBackground
        ? (isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
            : themeState.backgroundColor)
        : theme.colorScheme.surface;
    const radius = BorderRadius.all(Radius.circular(999));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(0, _pressed ? 1.5 : 0, 0),
      child: Material(
        color: background,
        shape: const RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? widget.onTap : null,
          onHighlightChanged: enabled
              ? (value) => setState(() => _pressed = value)
              : null,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                widget.leading,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground.withValues(alpha: enabled ? 1 : 0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantIconStack extends StatelessWidget {
  const _ParticipantIconStack({
    required this.count,
    required this.color,
  });

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const iconSize = 22.0;
    const overlap = 9.0;
    final visibleCount = count.clamp(1, 6).toInt();
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
            child: Icon(
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
