import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_avatar.dart";

/// Compact top-to-bottom participant avatars for narrow leading slots.
class VerticalParticipantAvatarStack extends StatelessWidget {
  const VerticalParticipantAvatarStack({
    required this.participants,
    super.key,
    this.avatarSize = 30,
    this.maxVisible = 3,
  });

  final List<ConversationMemberSummary> participants;
  final double avatarSize;
  final int maxVisible;

  static const double _stepFraction = 0.72;
  static const double _borderWidth = 1;

  @override
  Widget build(BuildContext context) {
    final visible = participants.take(maxVisible).toList();
    final stackItems = visible.isNotEmpty
        ? visible
        : const [
            ConversationMemberSummary(userId: -1, name: ""),
            ConversationMemberSummary(userId: -2, name: ""),
            ConversationMemberSummary(userId: -3, name: ""),
          ];
    final step = avatarSize * _stepFraction;
    final height = avatarSize + (stackItems.length - 1) * step;

    return SizedBox(
      width: avatarSize,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < stackItems.length; i++)
            Positioned(
              top: i * step,
              left: 0,
              child: _VerticalStackAvatar(
                member: stackItems[i],
                size: avatarSize,
                toneIndex: i,
              ),
            ),
        ],
      ),
    );
  }
}

class _VerticalStackAvatar extends StatelessWidget {
  const _VerticalStackAvatar({
    required this.member,
    required this.size,
    required this.toneIndex,
  });

  final ConversationMemberSummary member;
  final double size;
  final int toneIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final base = isBlueTheme
        ? Colors.white
        : Color.lerp(surface, onSurface, 0.03 + toneIndex * 0.03)!;

    return UyDoshAvatar(
      avatarUrl: member.avatarUrl,
      initials: StringUtils.extractInitials(member.name),
      size: UyDoshAvatarSize.small,
      customSize: size,
      backgroundColor: base,
      backgroundGradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
      foregroundColor: isBlueTheme ? primary : theme.colorScheme.onSurface,
      borderColor: avatarCircleBorderColor(context),
      borderWidth: VerticalParticipantAvatarStack._borderWidth,
      fallbackIcon: Icons.person,
      fontWeight: FontWeight.w800,
    );
  }
}
