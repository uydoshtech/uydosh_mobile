import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/admin/admin_panel_screen.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_screen.dart";
import "package:uy_dosh/presentation/screens/gamification/achievements_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/my_groups_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/screens/messages/pushed_messages_inbox_scaffold.dart";
import "package:uy_dosh/presentation/screens/profile/notifications_screen.dart";
import "package:uy_dosh/presentation/screens/support/support_chat_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/screens/view_history/view_history_screen.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ProfileListingsSection extends StatelessWidget {
  const ProfileListingsSection({
    required this.userRole,
    required this.expandedMenuGroupIndex,
    required this.onExpandedMenuGroupChanged,
    required this.onAchievementsOpened,
    super.key,
  });

  final String? userRole;
  final int? expandedMenuGroupIndex;
  final void Function(int? index) onExpandedMenuGroupChanged;
  final VoidCallback? onAchievementsOpened;

  Widget _threeDProfileTile(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          margin: EdgeInsets.zero,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: ListingDetailTileShell(
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGroupedMenuCard(context),
        if (userRole == "landlord" || userRole == "service_provider") ...[
          const SizedBox(height: 8),
          _buildManagePropertyButton(context),
        ],
      ],
    );
  }

  Widget _buildGroupedMenuCard(BuildContext context) {
    return _threeDProfileTile(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCollapsibleGroupHeader(
            context,
            icon: Icons.dynamic_feed,
            title: L10n.get("profile_menu_collapsible_listings_group"),
            expanded: expandedMenuGroupIndex == 0,
            onTap: () {
              HapticFeedbackUtils.impact();
              onExpandedMenuGroupChanged(
                expandedMenuGroupIndex == 0 ? null : 0,
              );
            },
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expandedMenuGroupIndex == 0
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.list_alt,
                          title: L10n.get("menu_my_listings"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UserListingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.groups_outlined,
                          title: L10n.get("menu_my_groups"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyGroupsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildGroupedMenuItem(
                          context: context,
                          icon: CupertinoIcons.suit_heart,
                          title: L10n.get("menu_favorites"),
                          onTap: () => _openFavoritesTab(context),
                        ),
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.chat_bubble_outline,
                          title: L10n.get("menu_messages"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PushedMessagesInboxScaffold(),
                              ),
                            );
                          },
                        ),
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.history,
                          title: L10n.get("menu_history"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ViewHistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.3),
          ),
          _buildCollapsibleGroupHeader(
            context,
            icon: Icons.miscellaneous_services,
            title: L10n.get("profile_menu_collapsible_services_group"),
            expanded: expandedMenuGroupIndex == 1,
            onTap: () {
              HapticFeedbackUtils.impact();
              onExpandedMenuGroupChanged(
                expandedMenuGroupIndex == 1 ? null : 1,
              );
            },
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expandedMenuGroupIndex == 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.notifications_none,
                          title: L10n.get("menu_notifications"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.emoji_events,
                          title: L10n.get("menu_achievements"),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AchievementsScreen(),
                              ),
                            );
                            onAchievementsOpened?.call();
                          },
                        ),
                        _buildGroupedMenuItem(
                          context: context,
                          icon: Icons.support_agent,
                          title: L10n.get("menu_contact_support"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SupportChatScreen(),
                              ),
                            );
                          },
                        ),
                        if (userRole == "admin")
                          _buildGroupedMenuItem(
                            context: context,
                            icon: Icons.admin_panel_settings,
                            title: L10n.get("menu_admin_panel"),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminPanelScreen(),
                                ),
                              );
                            },
                          ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleGroupHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 12),
        child: Row(
          children: [
            ThemeIcon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: ThemeIcon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedbackUtils.impact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            ThemeIcon(
              icon,
              color: ThemeState().isBlueTheme
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ThemeIcon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _openFavoritesTab(BuildContext context) {
    // Favorites is no longer a bottom-nav tab — push it as a standalone
    // route on top of whatever is currently visible (the profile screen).
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const FavoritesScreen(),
      ),
    );
  }

  Widget _buildManagePropertyButton(BuildContext context) {
    return _threeDProfileTile(
      context,
      child: InkWell(
        onTap: () {
          HapticFeedbackUtils.impact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserListingsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              ThemeIcon(
                Icons.home_work,
                color: ThemeState().isBlueTheme
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  L10n.get("manage_property"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ThemeIcon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
