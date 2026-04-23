import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart"
    show ThemeHelper, liquidGlassAppBarMaterialColor;
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
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
    /// Opens the peer's profile (e.g. [ListingOwnerProfileScreen]) when set.
    this.onPeerAvatarTap,
  });
  final String displayName;
  final String? peerAvatarUrl;
  final String? peerInitials;
  final VoidCallback onRefresh;
  final List<ActionMenuItem> actionMenuItems;
  final VoidCallback? onPeerAvatarTap;

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
        final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
        final appBarTheme = Theme.of(context).appBarTheme;
        final onBarColor =
            useLiquidGlass
                ? (appBarTheme.foregroundColor ?? textColor)
                : textColor;

        return UydoshAppBar(
          leading: ThreeDAppBarIconButton.backLeading(context),
          title: Row(
            children: [
              _peerAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: onBarColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor:
              useLiquidGlass
                  ? liquidGlassAppBarMaterialColor(context)
                  : appBarBackgroundColor,
          surfaceTintColor:
              useLiquidGlass ? Colors.transparent : appBarTheme.surfaceTintColor,
          elevation: useLiquidGlass ? 0 : null,
          scrolledUnderElevation: useLiquidGlass ? 0 : null,
          shadowColor:
              useLiquidGlass ? Colors.transparent : appBarTheme.shadowColor,
          forceMaterialTransparency: useLiquidGlass,
          flexibleSpace:
              useLiquidGlass ? const LiquidGlassAppBarFlexibleSpace() : null,
          foregroundColor: onBarColor,
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
