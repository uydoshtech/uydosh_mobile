import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/admin/admin_panel_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/screens/profile/notifications_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    required this.onLogout, required this.onDeleteAccount, super.key,
  });

  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoutButton(context),
        const SizedBox(height: 8),
        _buildDeleteAccountButton(context),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  L10n.get("logout"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.error,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: errorColor, width: 2),
      ),
      child: InkWell(
        onTap: onDeleteAccount,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: errorColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  L10n.get("delete_account"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: errorColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: errorColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds action menu items for the profile screen AppBar.
List<ActionMenuItem> buildProfileActionMenuItems({
  required BuildContext context,
  required bool userBlocked,
  required String? userRole,
  required UserProfile? cachedUserProfile,
  required Future<void> Function(UserProfile profile) onEditProfile,
  required VoidCallback onLogout,
}) {
  return [
    if (!userBlocked)
      ActionMenuItem(
        value: "edit_profile",
        icon: Icons.edit,
        textKey: "edit_profile",
        onPressed: () async {
          try {
            final currentState = context.read<CurrentUserProfileBloc>().state;
            final cachedProfile = cachedUserProfile;
            currentState.map(
              initial:
                  (_) =>
                      cachedProfile != null
                          ? onEditProfile(cachedProfile)
                          : ToastTheme.showInfo(
                            context,
                            message: L10n.get("profile_not_loaded_yet"),
                          ),
              loading:
                  (_) =>
                      cachedProfile != null
                          ? onEditProfile(cachedProfile)
                          : ToastTheme.showInfo(
                            context,
                            message: L10n.get("profile_still_loading"),
                          ),
              loaded: (loadedState) async {
                await onEditProfile(loadedState.profile);
              },
              error:
                  (errorState) =>
                      cachedProfile != null
                          ? onEditProfile(cachedProfile)
                          : ToastTheme.showError(
                            context,
                            message: L10n.get("error_with_message")
                                .replaceAll("{message}", errorState.message),
                          ),
            );
          } catch (e) {
            ToastTheme.showError(
              context,
              message: L10n.get("error_opening_edit_screen")
                  .replaceAll("{error}", e.toString()),
            );
          }
        },
      ),
    ActionMenuItem(
      value: "messages",
      icon: Icons.chat_bubble_outline,
      textKey: "menu_messages",
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MessagesInboxScreen(),
          ),
        );
      },
    ),
    ActionMenuItem(
      value: "notifications",
      icon: Icons.notifications_none,
      textKey: "menu_notifications",
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
      },
    ),
    ActionMenuItem(
      value: "listings",
      icon: Icons.list_alt,
      textKey: "menu_my_listings",
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => BlocProvider(
                  create: (context) => ListingsBloc(getIt<IListingService>()),
                  child: const UserListingsScreen(),
                ),
          ),
        );
      },
    ),
    if (userRole == "admin")
      ActionMenuItem(
        value: "admin_panel",
        icon: Icons.admin_panel_settings,
        textKey: "menu_admin_panel",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminPanelScreen(),
            ),
          );
        },
      ),
    ActionMenuItem(
      value: "logout",
      icon: Icons.logout,
      textKey: "menu_logout",
      iconColor: AppColors.error,
      textColor: AppColors.error,
      onPressed: onLogout,
    ),
  ];
}
