import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/constants/app_version.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/services/version_service.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/moderation_staff_utils.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/router/create_choice_sheet.dart";
import "package:uy_dosh/presentation/screens/admin/admin_panel_screen.dart";
import "package:uy_dosh/presentation/screens/faq/faq_screen.dart";
import "package:uy_dosh/presentation/screens/my/my_hub_screen.dart";
// import "package:uy_dosh/presentation/screens/messages/pushed_messages_inbox_scaffold.dart";
import "package:uy_dosh/presentation/screens/profile/notifications_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";
import "package:uy_dosh/presentation/screens/settings/settings_screen.dart";
// import "package:uy_dosh/presentation/screens/view_history/view_history_screen.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_menu_item.dart";

typedef _AsyncBoolPredicate = Future<bool> Function();

// Data class for BlocSelector to reduce unnecessary rebuilds
class _BurgerMenuProfileData {
  const _BurgerMenuProfileData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.profile,
  });
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _BurgerMenuProfileData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.profile == profile;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        (profile?.hashCode ?? 0);
  }
}

class BurgerMenuWidget extends StatefulWidget {
  const BurgerMenuWidget({super.key});

  @override
  State<BurgerMenuWidget> createState() => _BurgerMenuWidgetState();
}

class _BurgerMenuWidgetState extends State<BurgerMenuWidget> {
  String? _cachedGoogleDisplayName;
  String? _cachedGooglePhotoUrl;
  UserProfile? _cachedUserProfile;

  @override
  void initState() {
    super.initState();
    _loadCachedGoogleProfile();
    AuthenticationState().addListener(_onAuthenticationChanged);
  }

  @override
  void dispose() {
    AuthenticationState().removeListener(_onAuthenticationChanged);
    super.dispose();
  }

  void _onAuthenticationChanged() {
    if (!mounted) return;
    _loadCachedGoogleProfile();
  }

  Future<void> _loadCachedGoogleProfile() async {
    final results = await Future.wait([
      SessionManager.getGoogleDisplayName(),
      SessionManager.getGooglePhotoUrl(),
      SessionManager.getCachedUserProfile(),
    ]);

    setStateIfMounted(() {
      _cachedGoogleDisplayName = results[0] as String?;
      _cachedGooglePhotoUrl = results[1] as String?;
      _cachedUserProfile = results[2] as UserProfile?;
    });

    _maybeFetchProfile();
  }

  void _maybeFetchProfile() {
    if (!AuthenticationState().isAuthenticated) return;
    if (!mounted) return;
    if (_cachedUserProfile != null) return;
    final currentProfileState = context.read<CurrentUserProfileBloc>().state;
    final profileRequestInFlightOrLoaded = currentProfileState.maybeMap(
      loading: (_) => true,
      loaded: (_) => true,
      orElse: () => false,
    );
    if (profileRequestInFlightOrLoaded) return;
    context.read<CurrentUserProfileBloc>().add(
          const CurrentUserProfileEvent.fetchProfile(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final solidDrawer = !ThemeState().usesLiquidGlassChrome;
        final drawerBackground = solidDrawer
            ? (Theme.of(context).drawerTheme.backgroundColor ??
                ThemeState().backgroundColor)
            : Colors.transparent;

        return Drawer(
          backgroundColor: drawerBackground,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(20),
            ),
          ),
          child: _DrawerGlassSurface(
            child: SafeArea(
              child: ListenableBuilder(
                listenable: AuthenticationState(),
                builder: (context, __) {
                  final isAuthenticated = AuthenticationState().isAuthenticated;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [
                            _DrawerProfileHeader(
                              isAuthenticated: isAuthenticated,
                              cachedGoogleDisplayName: _cachedGoogleDisplayName,
                              cachedUserProfile: _cachedUserProfile,
                              profilePicture: _ProfilePicture(
                                photoUrl: _cachedGooglePhotoUrl ??
                                    FirebaseAuth.instance.currentUser?.photoURL,
                              ),
                              onOpenProfile: () {
                                HapticFeedbackUtils.impact();
                                Navigator.pop(context);
                                if (!context.mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            const _DrawerDivider(),
                            ..._buildMenuItems(
                              context,
                              isAuthenticated: isAuthenticated,
                            ),
                          ],
                        ),
                      ),
                      const _DrawerFooter(),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context, {
    required bool isAuthenticated,
  }) {
    final items = <Widget>[];

    void addItem(_DrawerItemSpec spec) {
      items.add(_DrawerMenuItem.fromSpec(spec));
    }

    void addDivider() {
      items.add(const _DrawerDivider());
    }

    if (isAuthenticated) {
      addItem(
        _DrawerItemSpec(
          icon: Icons.person_outline,
          titleKey: "menu_profile",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      );

      addItem(
        _DrawerItemSpec(
          icon: Icons.add,
          titleKey: "menu_add_listing",
          onTap: () {
            HapticFeedbackUtils.impact();
            Navigator.pop(context);
            if (!context.mounted) return;
            unawaited(showCreateChoiceSheet(context));
          },
        ),
      );

      addItem(
        _DrawerItemSpec(
          icon: Icons.list_alt,
          titleKey: "menu_my_listings",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            context.openMyHub(MyHubCategory.listings);
          },
        ),
      );

      addItem(
        _DrawerItemSpec(
          icon: Icons.groups_outlined,
          titleKey: "menu_my_groups",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            context.openMyHub(MyHubCategory.groups);
          },
        ),
      );

      addItem(
        _DrawerItemSpec(
          icon: CupertinoIcons.suit_heart,
          titleKey: "menu_favorites",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            context.openMyHub(MyHubCategory.favorites);
          },
        ),
      );

      // addItem(
      //   _DrawerItemSpec(
      //     icon: Icons.history,
      //     titleKey: "menu_history",
      //     onTap: () {
      //       Navigator.pop(context);
      //       if (!context.mounted) return;
      //       Navigator.of(context).push(
      //         MaterialPageRoute(
      //             builder: (context) => const ViewHistoryScreen()),
      //       );
      //     },
      //   ),
      // );

      // addItem(
      //   _DrawerItemSpec(
      //     icon: Icons.mail_outline,
      //     titleKey: "menu_messages",
      //     onTap: () {
      //       Navigator.pop(context);
      //       if (!context.mounted) return;
      //       Navigator.of(context).push(
      //         MaterialPageRoute<void>(
      //           builder: (context) => const PushedMessagesInboxScaffold(),
      //         ),
      //       );
      //     },
      //   ),
      // );

      addItem(
        _DrawerItemSpec(
          icon: Icons.notifications_none_outlined,
          titleKey: "menu_notifications",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
      );
    }

    addDivider();

    addItem(
      _DrawerItemSpec(
        icon: Icons.settings,
        titleKey: "menu_settings",
        onTap: () {
          Navigator.pop(context);
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
    );

    addItem(
      _DrawerItemSpec(
        icon: Icons.help_outline,
        titleKey: "menu_faq",
        onTap: () {
          Navigator.pop(context);
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FaqScreen()),
          );
        },
      ),
    );

    if (isAuthenticated) {
      items.add(
        _AsyncVisibleMenuItem(
          isVisible: () async {
            final r = await SessionManager.getUserRole();
            return ModerationStaffUtils.isModerationStaff(r);
          },
          child: _DrawerMenuItem.fromSpec(
            _DrawerItemSpec(
              icon: Icons.admin_panel_settings,
              titleKey: "menu_admin_panel",
              onTap: () {
                Navigator.pop(context);
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    final logoutColor = isAuthenticated ? AppColors.error : null;
    addItem(
      _DrawerItemSpec(
        icon: isAuthenticated ? Icons.logout : Icons.person_add,
        titleKey: isAuthenticated ? "menu_logout" : "menu_registration",
        iconColor: logoutColor,
        textColor: logoutColor,
        trailingColor: logoutColor,
        onTap: () {
          if (isAuthenticated) {
            _showLogoutDialog(context);
            return;
          }
          Navigator.pop(context);
          if (context.mounted) AuthFlow.openSignIn(context);
        },
      ),
    );

    return items;
  }

  void _showLogoutDialog(BuildContext context) {
    CommonConfirmationDialogs.showLogoutConfirmation(
      context: context,
      onConfirm: () async {
        // Close the drawer first
        Navigator.pop(context);

        // Show success toast immediately before logout to avoid context issues
        final message = L10n.get("logout_success");
        ToastTheme.showSuccess(context, message: message);

        // Then perform logout
        await LogoutService().performLogout();
      },
    );
  }
}

final class _DrawerColors {
  const _DrawerColors._();

  static Color text() {
    final currentTheme = ThemeState().currentTheme;
    return switch (currentTheme) {
      AppTheme.blueTheme => AppColors.textLight,
      AppTheme.lightTheme => Colors.black,
      _ => Colors.black,
    };
  }

  static Color secondaryText() {
    final currentTheme = ThemeState().currentTheme;
    return switch (currentTheme) {
      AppTheme.blueTheme => AppColors.textLight70,
      AppTheme.lightTheme => Colors.grey[600]!,
      _ => Colors.grey[600]!,
    };
  }

  static Color icon() => text();

  static Color secondaryIcon() => secondaryText();

  static Color border() {
    final currentTheme = ThemeState().currentTheme;
    return switch (currentTheme) {
      AppTheme.blueTheme => AppColors.textLight,
      AppTheme.lightTheme => Colors.grey[400]!,
      _ => Colors.grey[400]!,
    };
  }

  static Color divider() {
    final currentTheme = ThemeState().currentTheme;
    return switch (currentTheme) {
      AppTheme.blueTheme => AppColors.textLight.withValues(alpha: 0.18),
      AppTheme.messagingTheme => MessagingThemeColors.divider,
      // Frosted-glass panels need a darker tint than card dividers.
      AppTheme.lightTheme => Colors.black.withValues(alpha: 0.14),
      _ => Colors.black.withValues(alpha: 0.14),
    };
  }

  static Color glassTint(
    BuildContext context, {
    required bool effectsEnabled,
  }) {
    final base = ThemeState().backgroundColor;
    final brightness = ThemeData.estimateBrightnessForColor(base);
    final isDark = brightness == Brightness.dark;
    final alpha =
        effectsEnabled ? (isDark ? 0.64 : 0.78) : (isDark ? 0.88 : 0.94);
    return base.withValues(alpha: alpha);
  }

  static Color surfaceFill(
    BuildContext context, {
    required bool effectsEnabled,
  }) {
    if (!ThemeState().usesLiquidGlassChrome) {
      return Theme.of(context).drawerTheme.backgroundColor ??
          ThemeState().backgroundColor;
    }
    return glassTint(context, effectsEnabled: effectsEnabled);
  }
}

class _DrawerGlassSurface extends StatelessWidget {
  const _DrawerGlassSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effectsEnabled = LiquidGlassRendering.effectsEnabled(context);
    final tint = _DrawerColors.surfaceFill(
      context,
      effectsEnabled: effectsEnabled,
    );
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        right: Radius.circular(20),
      ),
      child: LiquidGlassRendering.backdropBlur(
        enabled: effectsEnabled,
        sigma: LiquidGlassRendering.panelBlurSigma,
        child: DecoratedBox(
          decoration: BoxDecoration(color: tint),
          child: child,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: _DrawerColors.divider(),
      thickness: 1,
      height: 24,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: FutureBuilder<String>(
        future: VersionService.getVersion(),
        builder: (context, snapshot) {
          final version =
              (snapshot.data ?? AppVersion.fullVersion).replaceAll("+", ".");
          return Text(
            "v$version",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _DrawerColors.secondaryText(),
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader({
    required this.isAuthenticated,
    required this.cachedGoogleDisplayName,
    required this.cachedUserProfile,
    required this.profilePicture,
    required this.onOpenProfile,
  });

  final bool isAuthenticated;
  final String? cachedGoogleDisplayName;
  final UserProfile? cachedUserProfile;
  final Widget profilePicture;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        height: 64 + 10 + 22,
        child: const SizedBox.shrink(),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: Column(
          children: [
            ThreeDPillButton(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              padding: EdgeInsets.zero,
              neumorphicSoftUi: true,
              onPressed: onOpenProfile,
              child: Semantics(
                label: L10n.get("profile"),
                button: true,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ClipOval(child: profilePicture),
                ),
              ),
            ),
            const SizedBox(height: 10),
            BlocSelector<CurrentUserProfileBloc, CurrentUserProfileState,
                _BurgerMenuProfileData>(
              selector: (state) => state.map(
                initial: (_) => _BurgerMenuProfileData(
                  isLoading: cachedUserProfile == null,
                  hasError: false,
                  errorMessage: "",
                  profile: cachedUserProfile,
                ),
                loading: (_) => _BurgerMenuProfileData(
                  isLoading: cachedUserProfile == null,
                  hasError: false,
                  errorMessage: "",
                  profile: cachedUserProfile,
                ),
                loaded: (loadedState) => _BurgerMenuProfileData(
                  isLoading: false,
                  hasError: false,
                  errorMessage: "",
                  profile: loadedState.profile,
                ),
                error: (_) => const _BurgerMenuProfileData(
                  isLoading: false,
                  hasError: true,
                  errorMessage: "",
                  profile: null,
                ),
              ),
              builder: (context, data) {
                if (data.isLoading) {
                  return Text(
                    L10n.get("loading..."),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _DrawerColors.secondaryText(),
                    ),
                  );
                }

                if (data.hasError || data.profile == null) {
                  final fallbackName = (cachedGoogleDisplayName ?? "").trim();
                  return Text(
                    fallbackName.isNotEmpty ? fallbackName : L10n.get("user"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fallbackName.isNotEmpty
                          ? _DrawerColors.text()
                          : _DrawerColors.secondaryText(),
                    ),
                  );
                }

                final profileName = data.profile!.name?.trim();
                final displayName =
                    (profileName != null && profileName.isNotEmpty)
                        ? profileName
                        : (cachedGoogleDisplayName?.trim().isNotEmpty ?? false)
                            ? cachedGoogleDisplayName!.trim()
                            : L10n.get("user");

                return Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _DrawerColors.text(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  const _ProfilePicture({required this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url == null) {
      return ThemeIcon(Icons.person, color: _DrawerColors.border(), size: 40);
    }

    const avatarSize = 64.0;
    final fallback = ThemeIcon(
      Icons.person,
      color: _DrawerColors.border(),
      size: 40,
    );

    return ClipOval(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: NetworkAvatarImage(
          imageUrl: url,
          size: avatarSize,
          fallback: Center(child: fallback),
        ),
      ),
    );
  }
}

final class _DrawerItemSpec {
  const _DrawerItemSpec({
    required this.icon,
    required this.titleKey,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailingColor,
  });

  final IconData icon;
  final String titleKey;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? trailingColor;
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.titleKey,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailingColor,
  });

  factory _DrawerMenuItem.fromSpec(_DrawerItemSpec spec) {
    return _DrawerMenuItem(
      icon: spec.icon,
      titleKey: spec.titleKey,
      onTap: spec.onTap,
      iconColor: spec.iconColor,
      textColor: spec.textColor,
      trailingColor: spec.trailingColor,
    );
  }

  final IconData icon;
  final String titleKey;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return UydoshMenuItem(
      icon: icon,
      title: L10n.text(
        titleKey,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? _DrawerColors.text(),
        ),
      ),
      onTap: onTap,
      iconColor: iconColor ?? _DrawerColors.icon(),
      textColor: textColor ?? _DrawerColors.text(),
      trailingColor: trailingColor ?? _DrawerColors.secondaryIcon(),
    );
  }
}

class _AsyncVisibleMenuItem extends StatefulWidget {
  const _AsyncVisibleMenuItem({
    required this.isVisible,
    required this.child,
  });

  final _AsyncBoolPredicate isVisible;
  final Widget child;

  @override
  State<_AsyncVisibleMenuItem> createState() => _AsyncVisibleMenuItemState();
}

class _AsyncVisibleMenuItemState extends State<_AsyncVisibleMenuItem> {
  late final Future<bool> _visibilityFuture = widget.isVisible();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _visibilityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.data != true) return const SizedBox.shrink();
        return widget.child;
      },
    );
  }
}
