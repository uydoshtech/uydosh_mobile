import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar_refresh_button.dart";

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {

  const ChatHeader({
    required this.displayName,
    required this.onRefresh,
    required this.actionMenuItems,
    super.key,
    this.peerAvatarUrl,
    this.peerInitials,
  });
  final String displayName;
  final String? peerAvatarUrl;
  final String? peerInitials;
  final VoidCallback onRefresh;
  final List<ActionMenuItem> actionMenuItems;

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

        return UydoshAppBar(
          leading: ThreeDAppBarIconButton.backLeading(context),
          title: Row(
            children: [
              ChatAvatar(
                isCurrentUser: false,
                initials: peerInitials,
                avatarUrl: peerAvatarUrl,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: appBarBackgroundColor,
          foregroundColor: textColor,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Center(
                child: UydoshAppBarRefreshButton(
                  onPressed: onRefresh,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ActionDropdownMenu(
                items: actionMenuItems,
                icon: Icons.more_vert,
                iconColor: textColor,
                tooltip: L10n.get("actions"),
              ),
            ),
          ],
        );
      },
    );
  }

}
