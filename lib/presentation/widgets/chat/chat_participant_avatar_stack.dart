import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";

/// Overlapping participant avatars for group-chat app bars.
class ChatParticipantAvatarStack extends StatelessWidget {
  const ChatParticipantAvatarStack({
    required this.participants,
    required this.currentUserId,
    super.key,
    this.avatarSize = 32,
    this.maxVisible = 4,
  });

  final List<ConversationMemberSummary> participants;
  final int? currentUserId;
  final double avatarSize;
  final int maxVisible;

  static const double _overlapFraction = 0.22;
  static const double _avatarBorderWidth = 1;

  /// Ring stroke for circle avatars — visible on both light and blue themes.
  ///
  /// Light theme uses a black ring; blue theme uses a white ring. Other themes
  /// keep [ColorScheme.surface] so overlapping stacks still read as cut-outs on
  /// card backgrounds.
  static Color avatarBorderColor(BuildContext context, {Color? background}) {
    if (background != null) return background;

    final themeState = ThemeState();
    final scheme = Theme.of(context).colorScheme;

    if (themeState.isLightTheme) {
      return AppColors.textDark;
    }
    if (themeState.isBlueTheme) {
      return AppColors.textLight;
    }
    return scheme.surface;
  }

  /// Puts the viewer first so the leftmost avatar is always "you".
  static List<ConversationMemberSummary> orderWithCurrentUserFirst(
    List<ConversationMemberSummary> participants,
    int? currentUserId,
  ) {
    if (currentUserId == null || participants.length <= 1) {
      return participants;
    }

    final currentUser = <ConversationMemberSummary>[];
    final others = <ConversationMemberSummary>[];
    for (final participant in participants) {
      if (participant.userId == currentUserId) {
        currentUser.add(participant);
      } else {
        others.add(participant);
      }
    }
    return [...currentUser, ...others];
  }

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return ChatAvatar(isCurrentUser: false);
    }

    final ordered = orderWithCurrentUserFirst(participants, currentUserId);
    final visible = ordered.take(maxVisible).toList();
    final overflow = participants.length - visible.length;
    final step = avatarSize * (1 - _overlapFraction);
    final width = avatarSize + (visible.length - 1) * step + (overflow > 0 ? step : 0);

    return SizedBox(
      width: width,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * step,
              top: 0,
              child: _MemberAvatar(
                member: visible[i],
                isCurrentUser: currentUserId != null &&
                    visible[i].userId == currentUserId,
                size: avatarSize,
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * step,
              top: 0,
              child: _OverflowChip(count: overflow, size: avatarSize),
            ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.isCurrentUser,
    required this.size,
  });

  final ConversationMemberSummary member;
  final bool isCurrentUser;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = resolveAvatarUrl(member.avatarUrl);
    final initials = StringUtils.extractInitials(member.name);
    final borderColor = ChatParticipantAvatarStack.avatarBorderColor(context);

    if (url == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: ChatParticipantAvatarStack._avatarBorderWidth,
          ),
        ),
        child: ChatAvatar(
          isCurrentUser: isCurrentUser,
          initials: initials,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: NetworkAvatarImage(
                imageUrl: url,
                size: size,
                fallback: ChatAvatar(
                  isCurrentUser: isCurrentUser,
                  initials: initials,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: ChatParticipantAvatarStack._avatarBorderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: ChatParticipantAvatarStack.avatarBorderColor(context),
          width: ChatParticipantAvatarStack._avatarBorderWidth,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        "+$count",
        style: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
