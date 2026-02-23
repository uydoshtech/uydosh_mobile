import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/logout_service.dart"
    show AccountBlockedException, LogoutService;
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_header_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_listings_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_settings_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_stats_section.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
class _ProfileScreenData {

  const _ProfileScreenData({
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
    return other is _ProfileScreenData &&
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _redirectedToProfileSetup = false;
  String? _userRole;
  int? _expandedSectionIndex; // 0 = Profile, 1 = Lifestyle Preferences (mutually exclusive)
  bool _userRoleLoaded = false;
  bool _refreshingRole = false;
  bool _userBlocked = false;
  UserProfile? _cachedUserProfile;
  String? _cachedGoogleDisplayName;
  String? _cachedGooglePhotoUrl;
  bool _achievementCheckScheduled = false;
  DateTime? _lastAchievementCheckTime;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "profile");
    _loadUserRole();
    _loadCachedProfileData();
  }

  Future<void> _loadCachedProfileData() async {
    final results = await Future.wait([
      SessionManager.getGoogleDisplayName(),
      SessionManager.getGooglePhotoUrl(),
      SessionManager.getCachedUserProfile(),
      SessionManager.getIsUserBlocked(),
    ]);

    if (!mounted) return;

    setState(() {
      _cachedGoogleDisplayName = results[0] as String?;
      _cachedGooglePhotoUrl = results[1] as String?;
      _cachedUserProfile = results[2] as UserProfile?;
      _userBlocked = results[3]! as bool;
    });

    if (_cachedUserProfile == null &&
        AuthenticationState().isAuthenticated &&
        mounted) {
      context.read<CurrentUserProfileBloc>().add(
            const CurrentUserProfileEvent.fetchProfile(),
          );
    }
  }

  Future<void> _loadUserRole() async {
    final results = await Future.wait([
      SessionManager.getUserRole(),
      SessionManager.getIsUserBlocked(),
    ]);
    if (!mounted) return;
    setState(() {
      _userRole = results[0] as String?;
      _userBlocked = results[1]! as bool;
      _userRoleLoaded = true;
    });
    if (_userRole == null) {
      await _refreshUserRoleFromServer();
    }
  }

  Future<void> _checkAndUnlockAchievements(
    UserProfile profile,
    BuildContext context,
  ) async {
    if (!AuthenticationState().isAuthenticated) return;
    try {
      final profileCompletionPercent =
          ProfileCompletionState.completionPercent(profile);
      var viewedListingsCount = 0;
      var favoritesCount = 0;
      var listingsCreatedCount = 0;
      var messagesSentCount = 0;

      try {
        final viewed =
            await getIt<IListingService>().getViewedListings(page: 1, limit: 1);
        viewedListingsCount = viewed.total;
      } catch (_) {}

      try {
        final favorites =
            await getIt<IFavoriteService>().getUserFavorites(page: 1, limit: 100);
        favoritesCount = favorites.length;
      } catch (_) {}

      final userId = await SessionManager.getUserId();
      if (userId != null) {
        try {
          final myListings = await getIt<IListingService>()
              .getListingsByUserId(userId: userId, page: 1, limit: 1);
          listingsCreatedCount = myListings.total;
        } catch (_) {}
      }

      try {
        if (await getIt<IGamificationService>().hasSentFirstMessage()) {
          messagesSentCount = 1;
        }
      } catch (_) {}

      final newlyUnlocked =
          await getIt<IGamificationService>().checkAndUnlockAchievements(
        hasAccount: true,
        profileCompletionPercent: profileCompletionPercent,
        viewedListingsCount: viewedListingsCount,
        favoritesCount: favoritesCount,
        messagesSentCount: messagesSentCount,
        listingsCreatedCount: listingsCreatedCount,
        conversationsStartedCount: 0,
      );
      if (mounted && newlyUnlocked.isNotEmpty) {
        AchievementUnlockBottomSheet.showMultiple(
          context,
          achievements: newlyUnlocked,
          onAllDismissed: () =>
              AchievementUnlockState().clearPendingAchievement(),
        );
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _refreshUserRoleFromServer() async {
    if (_refreshingRole) return;
    _refreshingRole = true;
    try {
      final response = await getIt<IOAuthApiClient>()
          .post<Map<String, dynamic>, _EmptyRequest>(
            "/users/verify-session",
            (json) => json as Map<String, dynamic>,
            data: _EmptyRequest(),
          );
      final user = response["user"];
      final role = user is Map<String, dynamic> ? user["role"] as String? : null;
      final isBlocked = user is Map<String, dynamic>
          ? (user["is_blocked"] as bool? ?? false)
          : false;
      if (role != null) {
        await SessionManager.storeUserRole(role);
      }
      await SessionManager.storeUserBlockedStatus(isBlocked);
      if (!mounted) return;
      setState(() {
        _userRole = role;
        _userBlocked = isBlocked;
        _userRoleLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _userRoleLoaded = true;
        });
      }
    } finally {
      _refreshingRole = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentUserProfileBloc, CurrentUserProfileState>(
        listener: (context, state) {
          state.whenOrNull(
            loaded: (profile) {
              if (!mounted) return;
              setState(() {
                _cachedUserProfile = profile;
              });
            },
          );
          state.maybeWhen(
            error: (message) {
              if (message != profileNotFoundErrorCode ||
                  _redirectedToProfileSetup) {
                return;
              }
              _redirectedToProfileSetup = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.pushReplaceAuthWizard(
                  initialPage: 2,
                  skipExistingSessionCheck: true,
                );
              });
            },
            orElse: () {},
          );
        },
        child: ListenableBuilder(
          listenable: ThemeState(),
          builder: (context, child) {
            return BlocSelector<
              CurrentUserProfileBloc,
              CurrentUserProfileState,
              _ProfileScreenData
            >(
              selector:
                  (state) => state.map(
                    initial:
                        (_) => const _ProfileScreenData(
                          isLoading: true,
                          hasError: false,
                          errorMessage: "",
                          profile: null,
                        ),
                    loading:
                        (_) => const _ProfileScreenData(
                          isLoading: true,
                          hasError: false,
                          errorMessage: "",
                          profile: null,
                        ),
                    loaded:
                        (loadedState) => _ProfileScreenData(
                          isLoading: false,
                          hasError: false,
                          errorMessage: "",
                          profile: loadedState.profile,
                        ),
                    error:
                        (errorState) => _ProfileScreenData(
                          isLoading: false,
                          hasError: true,
                          errorMessage: errorState.message,
                          profile: null,
                        ),
                  ),
              builder: (context, data) {
                final effectiveProfile =
                    data.profile ?? _cachedUserProfile;

                if (effectiveProfile == null &&
                    (data.isLoading || data.hasError)) {
                  return Scaffold(
                    body: CenteredHouseLoadingIndicator(
                      text: L10n.get("loading"),
                    ),
                  );
                }

                if (data.hasError &&
                    data.errorMessage == profileNotFoundErrorCode) {
                  return Scaffold(
                    body: CenteredHouseLoadingIndicator(
                      text: L10n.get("loading"),
                    ),
                  );
                }

                final profile = effectiveProfile!;
                final now = DateTime.now();
                final shouldCheck = !_achievementCheckScheduled ||
                    (_lastAchievementCheckTime != null &&
                        now.difference(_lastAchievementCheckTime!).inSeconds > 30);
                if (shouldCheck) {
                  _achievementCheckScheduled = true;
                  _lastAchievementCheckTime = now;
                  Future.microtask(
                    () => _checkAndUnlockAchievements(profile, context),
                  );
                }
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      L10n.get("profile"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      ActionDropdownMenu(
                        items: buildProfileActionMenuItems(
                          context: context,
                          userBlocked: _userBlocked,
                          userRole: _userRole,
                          cachedUserProfile: _cachedUserProfile,
                          onEditProfile: (profile) =>
                              _openEditProfileScreen(context, profile),
                          onLogout: () => _showLogoutDialog(context),
                        ),
                        icon: Icons.more_vert,
                        tooltip: L10n.get("menu_settings"),
                        padding: const EdgeInsets.only(right: 16.0),
                      ),
                    ],
                  ),
                  body:
                      data.hasError
                          ? _buildErrorState(data.errorMessage, context)
                          : _buildProfileContent(profile),
                );
              },
            );
          },
        ),
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderSection(
                profile: profile,
                cachedGoogleDisplayName: _cachedGoogleDisplayName,
                cachedGooglePhotoUrl: _cachedGooglePhotoUrl,
                userRole: _userRole,
                userRoleLoaded: _userRoleLoaded,
                userBlocked: _userBlocked,
                getRoleLabel: (role) => _getRoleLabel(role, context),
                onEditProfile: () =>
                    _openEditProfileScreen(context, profile),
              ),

              const SizedBox(height: 8),

              ProfileStatsSection(
                profile: profile,
                cachedGoogleDisplayName: _cachedGoogleDisplayName,
                expandedSectionIndex: _expandedSectionIndex,
                onExpandedSectionChanged: (index) {
                  setState(() => _expandedSectionIndex = index);
                },
                getLocalizedRegionName: _getLocalizedRegionName,
                getLocalizedUniversityName: _getLocalizedUniversityName,
              ),

              const SizedBox(height: 8),
              ProfileListingsSection(
                userRole: _userRole,
                onAchievementsOpened: () => setState(() {}),
              ),
              const SizedBox(height: 8),
              ProfileSettingsSection(
                onLogout: () => _showLogoutDialog(context),
                onDeleteAccount: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.get("error_loading_profile"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get("error_generic"),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<CurrentUserProfileBloc>().add(
                const CurrentUserProfileEvent.fetchProfile(),
              );
            },
            child: Text(L10n.get("retry")),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String? role, BuildContext context) {
    switch (role) {
      case "tenant":
        return L10n.get("role_tenant");
      case "landlord":
        return L10n.get("role_landlord");
      case "manager":
        return L10n.get("role_manager");
      case "admin":
        return L10n.get("role_admin");
      default:
        return L10n.get("not_specified");
    }
  }

  String _getLocalizedRegionName(UserProfileRegion region) {
    final currentLanguage = LanguageState().currentLanguage;

    switch (currentLanguage) {
      case "ru":
        return region.shortNameRu ?? region.nameRu ?? "Unknown";
      case "uz":
        return region.shortNameUz ?? region.nameUz ?? "Unknown";
      case "en":
      default:
        return region.shortNameEn ?? region.nameEn ?? "Unknown";
    }
  }

  String _getLocalizedUniversityName(UserProfileUniversity university) {
    return university.getLocalizedNameCapitalized(
      LanguageState().currentLanguage,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    CommonConfirmationDialogs.showLogoutConfirmation(
      context: context,
      onConfirm: () async {
        final message = L10n.get("logout_success");
        ToastTheme.showSuccess(context, message: message);
        await LogoutService().performLogout(context);
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    CommonConfirmationDialogs.showDeleteAccountConfirmation(
      context: context,
      onConfirm: () async {
        try {
          await LogoutService().performDeleteAccount(context);
        } on AccountBlockedException {
          if (!context.mounted) return;
          ToastTheme.showError(
            context,
            message: L10n.get("delete_account_blocked"),
          );
        } catch (e) {
          if (!context.mounted) return;
          ToastTheme.showError(
            context,
            message: L10n.get("delete_account_error"),
          );
        }
      },
    );
  }

  Future<void> _openEditProfileScreen(
    BuildContext context,
    UserProfile profile,
  ) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );

    if (result == true) {
      logger.d("=== PROFILE EDIT SUCCESS ===");
      logger.d("Edit profile returned true, refreshing profile data...");

      context.read<CurrentUserProfileBloc>().add(
        const CurrentUserProfileEvent.fetchProfile(),
      );

      logger.d("✅ Profile refresh event dispatched");
    } else {
      logger.d("=== PROFILE EDIT CANCELLED ===");
      logger.d("Edit profile returned: $result");
      logger.d("Profile will not be refreshed");
    }
  }
}

class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}
