import "dart:ui";

import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/constants/app_version.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/services/version_service.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/admin/admin_panel_screen.dart";
import "package:uy_dosh/presentation/screens/faq/faq_screen.dart";
import "package:uy_dosh/presentation/screens/messages/pushed_messages_inbox_scaffold.dart";
import "package:uy_dosh/presentation/screens/profile/notifications_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";
import "package:uy_dosh/presentation/screens/settings/settings_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/screens/view_history/view_history_screen.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
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
        other.profile?.id == profile?.id;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        (profile?.id ?? 0).hashCode;
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

  @override
  void initState() {
    super.initState();
    _loadCachedGoogleProfile();
    // Listen to centralized authentication state changes
    AuthenticationState().addListener(() {
      if (!mounted) return;
      _loadCachedGoogleProfile();
    });
  }

  Future<void> _loadCachedGoogleProfile() async {
    final results = await Future.wait([
      SessionManager.getGoogleDisplayName(),
      SessionManager.getGooglePhotoUrl(),
    ]);

    setStateIfMounted(() {
      _cachedGoogleDisplayName = results[0];
      _cachedGooglePhotoUrl = results[1];
    });

    _maybeFetchProfile();
  }

  void _maybeFetchProfile() {
    if (!AuthenticationState().isAuthenticated) return;
    if (!mounted) return;
    context.read<CurrentUserProfileBloc>().add(
          const CurrentUserProfileEvent.fetchProfile(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ListenableBuilder(
        listenable: ThemeState(),
        builder: (context, _) {
          return _DrawerGlassSurface(
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
                                    builder: (context) =>
                                        const ProfileScreen(),
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
          );
        },
      ),
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
            Navigator.pop(context);
            if (!context.mounted) return;
            _navigateToMainIndex(context, 3);
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) {
                    return ListingsBloc(getIt<IListingService>());
                  },
                  child: const UserListingsScreen(),
                ),
              ),
            );
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
            _navigateToMainIndex(context, 1);
          },
        ),
      );

      addItem(
        _DrawerItemSpec(
          icon: Icons.history,
          titleKey: "menu_history",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ViewHistoryScreen()),
            );
          },
        ),
      );

      addItem(
        _DrawerItemSpec(
          icon: Icons.mail_outline,
          titleKey: "menu_messages",
          onTap: () {
            Navigator.pop(context);
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const PushedMessagesInboxScaffold(),
              ),
            );
          },
        ),
      );

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
          isVisible: () async => (await SessionManager.getUserRole()) == "admin",
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
          if (context.mounted) context.pushAuthWizard();
        },
      ),
    );

    return items;
  }

  void _navigateToMainIndex(BuildContext context, int index) {
    final navState = mainNavigationKey.currentState;
    if (navState != null) {
      navState.navigateToIndex(index);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => AppRouter.buildMainNavigation(initialIndex: index),
      ),
    );
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
      AppTheme.lightTheme => LightThemeColors.divider,
      _ => LightThemeColors.divider,
    };
  }

  static Color glassTint(BuildContext context) {
    final base = ThemeState().backgroundColor;
    final brightness = ThemeData.estimateBrightnessForColor(base);
    if (brightness == Brightness.dark) return base.withValues(alpha: 0.32);
    return base.withValues(alpha: 0.48);
  }
}

class _DrawerGlassSurface extends StatelessWidget {
  const _DrawerGlassSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: enableGlass ? 18 : 0,
          sigmaY: enableGlass ? 18 : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _DrawerColors.glassTint(context),
          ),
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
      thickness: 0.5,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: FutureBuilder<String>(
        future: VersionService.getVersion(),
        builder: (context, snapshot) {
          final version =
              (snapshot.data ?? AppVersion.fullVersion).replaceAll("+", ".");
          return Text(
            "v$version",
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
    required this.profilePicture,
    required this.onOpenProfile,
  });

  final bool isAuthenticated;
  final String? cachedGoogleDisplayName;
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
            BlocSelector<
              CurrentUserProfileBloc,
              CurrentUserProfileState,
              _BurgerMenuProfileData
            >(
              selector: (state) => state.map(
                initial: (_) => const _BurgerMenuProfileData(
                  isLoading: true,
                  hasError: false,
                  errorMessage: "",
                  profile: null,
                ),
                loading: (_) => const _BurgerMenuProfileData(
                  isLoading: true,
                  hasError: false,
                  errorMessage: "",
                  profile: null,
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

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        memCacheWidth: 128,
        memCacheHeight: 128,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeInCurve: Curves.easeOut,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_DrawerColors.border()),
            strokeWidth: 3,
          ),
        ),
        errorWidget: (context, url, error) => ThemeIcon(
          Icons.person,
          color: _DrawerColors.border(),
          size: 40,
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

class _AsyncVisibleMenuItem extends StatelessWidget {
  const _AsyncVisibleMenuItem({
    required this.isVisible,
    required this.child,
  });

  final _AsyncBoolPredicate isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isVisible(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.data != true) return const SizedBox.shrink();
        return child;
      },
    );
  }
}
