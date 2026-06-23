import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart"
    show ThemeHelper, liquidGlassAppBarMaterialColor;
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Back control is ~48px wide (8px inset + 40px button); default [AppBar]
  /// [leadingWidth] (56) + [titleSpacing] (16) leaves a ~24px gap before the
  /// title row — halved here so avatars sit closer to the back button.
  static const double _leadingWidth = 52;
  static const double _titleSpacing = 8;

  const ChatHeader({
    required this.displayName,
    required this.actionMenuItems,
    super.key,
    this.subtitle,
    this.peerAvatarUrl,
    this.peerInitials,

    /// When set (group chats), renders an overlapping avatar stack instead of
    /// [peerAvatarUrl] / [peerInitials].
    this.groupParticipants,
    this.currentUserId,

    /// Opens the peer's profile (e.g. [ListingOwnerProfileScreen]) when set.
    this.onPeerAvatarTap,

    /// Opens group participants when the group avatar stack is tapped.
    this.onGroupParticipantsTap,

    /// Placed immediately to the left of the 3-dot overflow menu (e.g. gig
    /// "invite to book" on task chats).
    this.actionBeforeMenu,
  });
  final String displayName;

  /// Optional secondary line beneath [displayName] (gig task title or listing
  /// headline).
  final String? subtitle;

  final String? peerAvatarUrl;
  final String? peerInitials;
  final List<ConversationMemberSummary>? groupParticipants;
  final int? currentUserId;
  final List<ActionMenuItem> actionMenuItems;
  final VoidCallback? onPeerAvatarTap;
  final VoidCallback? onGroupParticipantsTap;
  final Widget? actionBeforeMenu;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final appBarBackgroundColor = themeState.appBarBackgroundColor;
        final textColor = themeState.textColor;
        final useLiquidGlass =
            themeState.isBlueTheme || themeState.isLightTheme;
        final appBarTheme = Theme.of(context).appBarTheme;
        final onBarColor = useLiquidGlass
            ? (appBarTheme.foregroundColor ?? textColor)
            : textColor;

        return UydoshAppBar(
          leading: ThreeDAppBarIconButton.backLeading(context),
          leadingWidth: _leadingWidth,
          titleSpacing: _titleSpacing,
          title: Row(
            children: [
              _peerAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: onBarColor,
                        // Tighten the primary title slightly when a subtitle
                        // is present so the two lines comfortably fit
                        // [kToolbarHeight] without inflating the AppBar.
                        // Group participant names use a smaller size so long
                        // comma-separated lists fit without crowding the bar.
                        fontSize: (subtitle == null ? 20 : 17) -
                            (groupParticipants != null &&
                                    groupParticipants!.isNotEmpty
                                ? 2
                                : 0),
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: onBarColor.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: useLiquidGlass
              ? liquidGlassAppBarMaterialColor(context)
              : appBarBackgroundColor,
          surfaceTintColor: useLiquidGlass
              ? Colors.transparent
              : appBarTheme.surfaceTintColor,
          elevation: useLiquidGlass ? 0 : null,
          scrolledUnderElevation: useLiquidGlass ? 0 : null,
          shadowColor:
              useLiquidGlass ? Colors.transparent : appBarTheme.shadowColor,
          forceMaterialTransparency: useLiquidGlass,
          flexibleSpace:
              useLiquidGlass ? const LiquidGlassAppBarFlexibleSpace() : null,
          foregroundColor: onBarColor,
          actions: [
            if (actionBeforeMenu != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: actionBeforeMenu,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ActionDropdownMenu(
                items: actionMenuItems,
                icon: Icons.more_vert,
                iconColor: onBarColor,
                tooltip: L10n.get("actions"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _peerAvatar() {
    final participants = groupParticipants;
    if (participants != null && participants.isNotEmpty) {
      final stack = ChatParticipantAvatarStack(
        participants: participants,
        currentUserId: currentUserId,
      );
      final tap = onGroupParticipantsTap;
      if (tap == null) {
        return stack;
      }
      return Tooltip(
        message: L10n.get("view_member_profiles"),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: tap,
              customBorder: const CircleBorder(),
              child: stack,
            ),
          ),
        ),
      );
    }

    final avatar = ChatAvatar(
      isCurrentUser: false,
      initials: peerInitials,
      avatarUrl: peerAvatarUrl,
    );
    final tap = onPeerAvatarTap;
    if (tap == null) {
      return avatar;
    }
    return Tooltip(
      message: L10n.get("profile_interlocutor"),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tap,
            customBorder: const CircleBorder(),
            child: avatar,
          ),
        ),
      ),
    );
  }
}
