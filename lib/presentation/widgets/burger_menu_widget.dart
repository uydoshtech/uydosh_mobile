import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_version.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/services/version_service.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/admin/admin_panel_screen.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";
import "package:uy_dosh/presentation/screens/settings/settings_screen.dart";
import "package:uy_dosh/presentation/screens/faq/faq_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
class _BurgerMenuProfileData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;

  const _BurgerMenuProfileData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.profile,
  });

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
  late final CurrentUserProfileBloc _currentUserProfileBloc;
  // Theme-aware color helper methods
  Color _getTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      case AppTheme.lightTheme:
      default:
        return Colors.black; // Black text for light theme
    }
  }

  Color _getSecondaryTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight70;
      case AppTheme.lightTheme:
      default:
        return Colors.grey[600]!; // Dark grey for secondary text in light theme
    }
  }

  Color _getIconColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      case AppTheme.lightTheme:
      default:
        return Colors.black;
    }
  }

  Color _getSecondaryIconColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight70;
      case AppTheme.lightTheme:
      default:
        return Colors
            .grey[600]!; // Dark grey for secondary icons in light theme
    }
  }

  Color _getBorderColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      case AppTheme.lightTheme:
      default:
        return Colors.grey[400]!; // Light grey border for light theme
    }
  }

  Color _getProfileBackgroundColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.primary;
      case AppTheme.lightTheme:
      default:
        return Colors.grey[200]!; // Light grey background for light theme
    }
  }

  // Theme-aware divider method with better contrast for light theme
  Widget _buildThemeAwareDivider() {
    final currentTheme = ThemeState().currentTheme;
    Color dividerColor;

    switch (currentTheme) {
      case AppTheme.blueTheme:
        dividerColor = AppColors.textLight;
        break;
      case AppTheme.lightTheme:
      default:
        // Use a darker color for better visibility in light theme
        dividerColor = const Color(
          0xFFD1D5DB,
        ); // Medium gray for better contrast
        break;
    }

    return Divider(color: dividerColor, thickness: 1.0, height: 1.0);
  }

  @override
  void initState() {
    super.initState();
    _currentUserProfileBloc = CurrentUserProfileBloc(
      getIt<IUserProfileService>(),
    );
    _loadCachedGoogleProfile();
    // Listen to centralized authentication state changes
    AuthenticationState().addListener(() {
      if (!mounted) return;
      _loadCachedGoogleProfile();
    });
  }

  @override
  void dispose() {
    _currentUserProfileBloc.close();
    super.dispose();
  }

  Future<void> _loadCachedGoogleProfile() async {
    final results = await Future.wait([
      SessionManager.getGoogleDisplayName(),
      SessionManager.getGooglePhotoUrl(),
    ]);

    if (!mounted) return;

    setState(() {
      _cachedGoogleDisplayName = results[0];
      _cachedGooglePhotoUrl = results[1];
    });

    _maybeFetchProfile();
  }

  void _maybeFetchProfile() {
    if (!AuthenticationState().isAuthenticated) return;
    if ((_cachedGoogleDisplayName ?? "").trim().isNotEmpty) return;
    _currentUserProfileBloc.add(
      const CurrentUserProfileEvent.fetchProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 100),
              children: [
                // Profile Logo (Round with person icon) and Name - Reserve space when logged out
                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    if (!isAuthenticated) {
                      // Reserve space for avatar area when not authenticated
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        height:
                            80 +
                            12 +
                            24, // Avatar height + spacing + text height
                        child: const SizedBox.shrink(),
                      );
                    }

                    // Show profile section when authenticated
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedbackUtils.impact();
                                Navigator.pop(context);
                                // Navigate to profile
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const ProfileScreen(),
                                    ),
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _getProfileBackgroundColor(),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getBorderColor(),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getProfileBackgroundColor()
                                          .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildProfilePicture(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Profile Name below the logo
                            BlocProvider(
                              create: (context) => _currentUserProfileBloc,
                              child: BlocSelector<
                                CurrentUserProfileBloc,
                                CurrentUserProfileState,
                                _BurgerMenuProfileData
                              >(
                                selector:
                                    (state) => state.map(
                                      initial:
                                          (_) => _BurgerMenuProfileData(
                                            isLoading: true,
                                            hasError: false,
                                            errorMessage: "",
                                            profile: null,
                                          ),
                                      loading:
                                          (_) => _BurgerMenuProfileData(
                                            isLoading: true,
                                            hasError: false,
                                            errorMessage: "",
                                            profile: null,
                                          ),
                                      loaded:
                                          (loadedState) =>
                                              _BurgerMenuProfileData(
                                                isLoading: false,
                                                hasError: false,
                                                errorMessage: "",
                                                profile: loadedState.profile,
                                              ),
                                      error:
                                          (_) => _BurgerMenuProfileData(
                                            isLoading: false,
                                            hasError: true,
                                            errorMessage: "",
                                            profile: null,
                                          ),
                                    ),
                                builder: (context, data) {
                                  final cachedName =
                                      (_cachedGoogleDisplayName ?? "").trim();
                                  if (cachedName.isNotEmpty) {
                                    return Text(
                                      cachedName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _getTextColor(),
                                      ),
                                    );
                                  }

                                  if (data.isLoading) {
                                    return Text(
                                      LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "loading...",
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _getSecondaryTextColor(),
                                      ),
                                    );
                                  }

                                  if (data.hasError || data.profile == null) {
                                    return Text(
                                      LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "user",
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _getSecondaryTextColor(),
                                      ),
                                    );
                                  }

                                  final displayName =
                                      _cachedGoogleDisplayName ??
                                      data.profile!.name;
                                  return Text(
                                    displayName ??
                                        LanguageAwareStringHelper.getCurrent(
                                          context,
                                          "user",
                                        ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _getTextColor(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;
                    if (!isAuthenticated) {
                      return const SizedBox.shrink();
                    }
                    return FutureBuilder<String?>(
                      future: SessionManager.getUserRole(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.data != "admin") {
                          return const SizedBox.shrink();
                        }
                        return _buildMenuItem(
                          icon: Icons.admin_panel_settings,
                          titleKey: "menu_admin_panel",
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const AdminPanelScreen(),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),

                // Always show divider after profile section (reserved space)
                _buildThemeAwareDivider(),

                _buildMenuItem(
                  icon: Icons.home,
                  titleKey: "menu_home",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to home tab (index 0)
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MainNavigation(),
                        ),
                      );
                    }
                  },
                ),
                // Add Listing menu item - Only show when user is logged in
                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    if (!isAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    return _buildMenuItem(
                      icon: Icons.add,
                      titleKey: "menu_add_listing",
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to create listing using MainNavigation
                        if (context.mounted) {
                          debugPrint(
                            "🍔 Burger Menu: Navigating to Add Listing (index 3)",
                          );
                          debugPrint(
                            "🍔 Burger Menu: mainNavigationKey: $mainNavigationKey",
                          );
                          debugPrint(
                            "🍔 Burger Menu: mainNavigationKey.currentState: ${mainNavigationKey.currentState}",
                          );
                          if (mainNavigationKey.currentState != null) {
                            mainNavigationKey.currentState!.navigateToIndex(3);
                            debugPrint("🍔 Burger Menu: Navigation successful");
                          } else {
                            debugPrint(
                              "❌ Burger Menu: mainNavigationKey.currentState is null",
                            );
                            // Fallback: try to navigate using Navigator
                            debugPrint(
                              "🍔 Burger Menu: Attempting fallback navigation...",
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MainNavigation(initialIndex: 3),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),

                // My Listings menu item - Only show when user is logged in
                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    if (!isAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    return _buildMenuItem(
                      icon: Icons.list_alt,
                      titleKey: "menu_my_listings",
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to user listings screen
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => BlocProvider(
                                    create: (context) {
                                      return ListingsBloc(
                                        getIt<IListingService>(),
                                      );
                                    },
                                    child: const UserListingsScreen(),
                                  ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),

                // Favorites menu item - Only show when user is logged in
                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    if (!isAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    return _buildMenuItem(
                      icon: Icons.favorite,
                      titleKey: "menu_favorites",
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to favorites screen using MainNavigation
                        if (context.mounted) {
                          debugPrint(
                            "🍔 Burger Menu: Navigating to Favorites (index 1)",
                          );
                          debugPrint(
                            "🍔 Burger Menu: mainNavigationKey: $mainNavigationKey",
                          );
                          debugPrint(
                            "🍔 Burger Menu: mainNavigationKey.currentState: ${mainNavigationKey.currentState}",
                          );
                          if (mainNavigationKey.currentState != null) {
                            mainNavigationKey.currentState!.navigateToIndex(1);
                            debugPrint("🍔 Burger Menu: Navigation successful");
                          } else {
                            debugPrint(
                              "❌ Burger Menu: mainNavigationKey.currentState is null",
                            );
                            // Fallback: try to navigate using Navigator
                            debugPrint(
                              "🍔 Burger Menu: Attempting fallback navigation...",
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MainNavigation(initialIndex: 1),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),

                // Messages menu item - Only show when user is logged in
                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    if (!isAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    return _buildMenuItem(
                      icon: Icons.mail_outline,
                      titleKey: "menu_messages",
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to messages screen
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MessagesInboxScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),

                _buildThemeAwareDivider(),

                // Settings menu item
                _buildMenuItem(
                  icon: Icons.settings,
                  titleKey: "menu_settings",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    }
                  },
                ),

                // FAQ menu item
                _buildMenuItem(
                  icon: Icons.help_outline,
                  titleKey: "menu_faq",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to FAQ screen
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FaqScreen(),
                        ),
                      );
                    }
                  },
                ),

                // Registration/Auth menu item - Show different text based on auth status
                ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    final logoutColor =
                        isAuthenticated ? AppColors.error : null;
                    return _buildMenuItem(
                      icon: isAuthenticated ? Icons.logout : Icons.person_add,
                      titleKey:
                          isAuthenticated ? "menu_logout" : "menu_registration",
                      iconColor: logoutColor,
                      textColor: logoutColor,
                      trailingColor: logoutColor,
                      onTap: () {
                        if (isAuthenticated) {
                          // Logout user - show dialog first, then close drawer
                          _showLogoutDialog(context);
                        } else {
                          // Navigate to registration/auth wizard
                          Navigator.pop(context);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AuthWizardScreen(),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<String>(
              future: VersionService.getVersion(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Format version to remove the "+" and make it look cleaner
                  final version = snapshot.data!;
                  final formattedVersion = version.replaceAll("+", ".");
                  return Text(
                    "v$formattedVersion",
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 12,
                    ),
                  );
                }

                final formattedVersion =
                    AppVersion.fullVersion.replaceAll("+", ".");
                return Text(
                  "v$formattedVersion",
                  style: TextStyle(
                    color: _getSecondaryTextColor(),
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String titleKey,
    required VoidCallback onTap,
    String? subtitleKey,
    Color? iconColor,
    Color? textColor,
    Color? trailingColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? _getIconColor()),
      title: LanguageAwareStringHelper.getText(
        titleKey,
        context,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? _getTextColor(),
        ),
      ),
      subtitle:
          subtitleKey != null
              ? LanguageAwareStringHelper.getText(
                subtitleKey,
                context,
                style: TextStyle(
                  color: textColor ?? _getSecondaryTextColor(),
                ),
              )
              : null,
      onTap: () {
        HapticFeedbackUtils.impact();
        onTap();
      },
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: trailingColor ?? _getSecondaryIconColor(),
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
        final message = LanguageAwareStringHelper.getCurrent(
          context,
          "logout_success",
        );
        ToastTheme.showSuccess(context, message: message);

        // Then perform logout
        await LogoutService().performLogout(context);
      },
    );
  }

  // Build profile picture - shows Google profile picture if available, fallback to icon
  Widget _buildProfilePicture() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final photoUrl = _cachedGooglePhotoUrl ?? currentUser?.photoURL;

    if (photoUrl != null) {
      // Show Google profile picture
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          memCacheWidth: 160, // 2x for high DPI displays
          memCacheHeight: 160,
          fadeInDuration: const Duration(milliseconds: 300),
          fadeInCurve: Curves.easeOut,
          placeholder:
              (context, url) => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_getBorderColor()),
                  strokeWidth: 3,
                ),
              ),
          errorWidget:
              (context, url, error) =>
                  Icon(Icons.person, color: _getBorderColor(), size: 40),
        ),
      );
    }

    // Fallback to standard person icon
    return Icon(Icons.person, color: _getBorderColor(), size: 40);
  }
}
