import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/logout_service.dart" show AccountBlockedException, LogoutService;
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/admin/admin_panel_screen.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/presentation/screens/gamification/achievements_screen.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/screens/view_history/view_history_screen.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isBlueTheme = ThemeState().currentTheme == AppTheme.blueTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isBlueTheme
            ? BlueThemeColors.buttonPrimary
            : Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
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
        AchievementUnlockBottomSheet.show(
          context,
          achievement: newlyUnlocked.first,
          onDismiss: () =>
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => const AuthWizardScreen(
                          initialPage: 2,
                          skipExistingSessionCheck: true,
                        ),
                  ),
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
                        items: _buildActionMenuItems(context),
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
        final isComplete =
            ProfileCompletionState.completionPercent(profile) >= 100;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        if (isComplete)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.success,
                                width: 3,
                              ),
                            ),
                            child: _buildProfileAvatar(),
                          )
                        else
                          _buildProfileAvatar(),
                        if (isComplete)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    if (((profile.name ?? _cachedGoogleDisplayName) ?? "")
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.name ?? _cachedGoogleDisplayName ?? "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_userRoleLoaded) ...[
                      const SizedBox(height: 4),
                      _RoleBadge(
                        label: _getRoleLabel(_userRole, context),
                      ),
                    ],
                    if (_userBlocked) ...[
                      const SizedBox(height: 4),
                      Tooltip(
                        message: L10n.get("admin_user_detail_blocked"),
                        child: Icon(
                          Icons.block,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Profile completion indicator
              if (!isComplete) ...[
                _buildProfileCompletionCard(profile, context),
                const SizedBox(height: 4),
              ] else ...[
                const SizedBox(height: 4),
              ],

              // Merged Profile Information Card (first)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedSectionIndex =
                              _expandedSectionIndex == 0 ? null : 0;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 24,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                L10n.get("profile"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _expandedSectionIndex == 0 ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ClipRect(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _expandedSectionIndex == 0
                            ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0,
                                16.0,
                                16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                    // Profile Name
                      if (((profile.name ?? _cachedGoogleDisplayName) ?? "")
                          .isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.get("name"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    profile.name ?? _cachedGoogleDisplayName ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Gender field
                      if (profile.gender != null) ...[
                        Row(
                          children: [
                            Icon(
                              _getGenderIcon(profile.gender!),
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.get("gender"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    _getGenderText(profile.gender!, context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Region field
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.get("im_from"),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  profile.region != null
                                      ? _getLocalizedRegionName(profile.region!)
                                      : L10n.get("not_specified"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // University field (only show when person is a student)
                      if (profile.university != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.get("university"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    _getLocalizedUniversityName(
                                      profile.university!,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // About Me field
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.get("about_me"),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  profile.aboutMe != null &&
                                          profile.aboutMe!.isNotEmpty
                                      ? profile.aboutMe!
                                      : L10n.get("not_specified"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Telegram field
                      InkWell(
                        onTap:
                            profile.telegram != null &&
                                    profile.telegram!.isNotEmpty
                                ? () => _confirmOpenTelegram(
                                  profile.telegram!,
                                  context,
                                )
                                : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.telegram,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      L10n.get("telegram"),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      profile.telegram != null &&
                                              profile.telegram!.isNotEmpty
                                          ? "@${profile.telegram!}"
                                      : L10n.get("not_specified"),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (profile.telegram != null &&
                                  profile.telegram!.isNotEmpty)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Rating field (if available)
                      if (profile.rating != null) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.get("rating"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        Icons.star,
                                        size: 19,
                                        color:
                                            index < profile.rating!
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.3),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                                ],
                              ),
                            )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    // Lifestyle Preferences section (inside same card)
                    if (_hasNewProfileFields(profile)) ...[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedSectionIndex =
                                _expandedSectionIndex == 1 ? null : 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.spa,
                                size: 24,
                                color: _getLifestyleHeaderColor(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  L10n.get("lifestyle_preferences"),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getLifestyleHeaderColor(),
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _expandedSectionIndex == 1 ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: _getLifestyleHeaderColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: _expandedSectionIndex == 1
                              ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  0,
                                  16.0,
                                  16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                      // Wake-up Time field
                        if (profile.wakeupTime != null) ...[
                          _buildProfileField(
                            icon: Icons.wb_sunny,
                            label: L10n.get("wakeup_time"),
                            value: _getTimePreferenceText(
                              profile.wakeupTime!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sleep Time field
                        if (profile.sleepTime != null) ...[
                          _buildProfileField(
                            icon: Icons.bedtime,
                            label: L10n.get("sleep_time"),
                            value: _getTimePreferenceText(
                              profile.sleepTime!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Employed field
                        if (profile.employed != null) ...[
                          _buildProfileField(
                            icon: Icons.work,
                            label: L10n.get("employed"),
                            value:
                                profile.employed!
                                    ? L10n.get("yes")
                                    : L10n.get("no"),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Cleanliness field
                        if (profile.cleanliness != null) ...[
                          _buildProfileField(
                            icon: Icons.cleaning_services,
                            label: L10n.get("cleanliness"),
                            value: _getCleanlinessText(
                              profile.cleanliness!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Noise Level field
                        if (profile.noiseLevel != null) ...[
                          _buildProfileField(
                            icon: Icons.volume_up,
                            label: L10n.get("noise_level"),
                            value: _getNoiseLevelText(
                              profile.noiseLevel!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sociability field
                        if (profile.sociability != null) ...[
                          _buildProfileField(
                            icon: Icons.people,
                            label: L10n.get("sociability"),
                            value: _getSociabilityText(
                              profile.sociability!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Guests Allowed field
                        if (profile.guestsAllowed != null) ...[
                          _buildProfileField(
                            icon: Icons.group_add,
                            label: L10n.get("guests_allowed"),
                            value:
                                profile.guestsAllowed!
                                    ? L10n.get("yes")
                                    : L10n.get("no"),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Smoking Preference field
                        if (profile.smokingPreference != null) ...[
                          _buildProfileField(
                            icon: Icons.smoking_rooms,
                            label: L10n.get("smoking_preference"),
                            value: _getSmokingPreferenceText(
                              profile.smokingPreference!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Alcohol Preference field
                        if (profile.alcoholPreference != null) ...[
                          _buildProfileField(
                            icon: Icons.local_bar,
                            label: L10n.get("alcohol_preference"),
                            value: _getAlcoholPreferenceText(
                              profile.alcoholPreference!,
                              context,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Cooking Habits field
                        if (profile.cookingHabits != null) ...[
                          _buildProfileField(
                            icon: Icons.restaurant,
                            label: L10n.get("cooking_habits"),
                            value:
                                profile.cookingHabits!
                                    ? L10n.get("cook")
                                    : L10n.get("dont_cook"),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                      // Pets Preference field
                      if (profile.petsPreference != null) ...[
                        _buildProfileField(
                          icon: Icons.pets,
                          label: L10n.get("pets_preference"),
                          value:
                              profile.petsPreference!
                                  ? L10n.get("pets_okay")
                                  : L10n.get("pets_not_okay"),
                          context: context,
                        ),
                        const SizedBox(height: 16),
                      ],
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // My Listings, Messages, View History - grouped with separators
              const SizedBox(height: 8),
              _buildGroupedMenuSection(context),
              const SizedBox(height: 8),

              // Achievements section
              _buildAchievementsSection(context),
              const SizedBox(height: 8),

              if (_userRole == "admin") ...[
                const SizedBox(height: 8),
                _buildAdminPanelButton(context),
              ],

              if (_userRole == "landlord") ...[
                const SizedBox(height: 8),
                _buildManagePropertyButton(context),
              ],

              // Logout Button Section
              const SizedBox(height: 8),
              _buildLogoutButton(context),

              // Delete Account Button Section
              const SizedBox(height: 8),
              _buildDeleteAccountButton(context),
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

  Widget _buildProfileCompletionCard(
    UserProfile profile,
    BuildContext context,
  ) {
    final completionPercent =
        ProfileCompletionState.completionPercent(profile);
    final completionFraction = completionPercent / 100;
    final isComplete = completionPercent >= 100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!isComplete) ...[
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: BlinkingDotWidget(
                      color: Colors.green,
                      size: 10,
                      duration: Duration(milliseconds: 1000),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    L10n.get("profile_completion"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isComplete)
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              L10n.get("profile_completion_hint"),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionFraction,
                minHeight: 8,
                backgroundColor:
                    Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).progressIndicatorTheme.color ??
                      Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$completionPercent%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (!_userBlocked) ...[
              const SizedBox(height: 8),
              UydoshLinkButton(
                text: L10n.get("complete_profile"),
                onPressed: () => _openEditProfileScreen(context, profile),
                outlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildProfilePicture(),
    );
  }

  String _getGenderText(int gender, BuildContext context) {
    switch (gender) {
      case 1:
        return L10n.get("male");
      case 2:
        return L10n.get("female");
      default:
        return L10n.get("other");
    }
  }

  IconData _getGenderIcon(int gender) {
    switch (gender) {
      case 1:
        return Icons.male;
      case 2:
        return Icons.female;
      default:
        return Icons.person_outline;
    }
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

  Future<void> _openTelegram(
    String telegramUsername,
    BuildContext context,
  ) async {
    // Remove @ symbol if present and create Telegram URL
    final cleanUsername =
        telegramUsername.startsWith("@")
            ? telegramUsername.substring(1)
            : telegramUsername;

    final url = "https://t.me/$cleanUsername";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ToastTheme.showError(context, message: "Could not open Telegram");
      }
    } catch (e) {
      ToastTheme.showError(context, message: "Could not open Telegram");
    }
  }

  Future<void> _confirmOpenTelegram(
    String telegramUsername,
    BuildContext context,
  ) async {
    final shouldOpen = await CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: "open_in_telegram",
      messageKey: "open_in_telegram_confirmation",
      confirmButtonKey: "confirm",
    );

    if (shouldOpen ?? false) {
      await _openTelegram(telegramUsername, context);
    }
  }

  // Build profile picture - shows Google profile picture if available, fallback to icon
  Widget _buildProfilePicture() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final photoUrl = _cachedGooglePhotoUrl ?? currentUser?.photoURL;

    if (photoUrl != null) {
      // Show Google profile picture with theme border
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            memCacheWidth: 200, // 2x for high DPI displays
            memCacheHeight: 200,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeInCurve: Curves.easeOut,
            placeholder:
                (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
            errorWidget:
                (context, url, error) => const Icon(Icons.person, size: 50),
          ),
        ),
      );
    }

    // Fallback to standard person icon with theme border
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1),
      ),
      child: const Icon(Icons.person, size: 50),
    );
  }

  // Build logout button
  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
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

  Widget _buildGroupedMenuSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGroupedMenuItem(
            context: context,
            icon: Icons.list_alt,
            title: L10n.get("menu_my_listings"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => ListingsBloc(getIt<IListingService>()),
                    child: const UserListingsScreen(),
                  ),
                ),
              );
            },
          ),
          _buildGroupedMenuItem(
            context: context,
            icon: Icons.chat_bubble_outline,
            title: L10n.get("menu_messages"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MessagesInboxScreen(),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  ThemeState().isBlueTheme
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
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AchievementsScreen(),
            ),
          );
          if (mounted) setState(() {});
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color:
                        ThemeState().isBlueTheme
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  FutureBuilder<bool>(
                    future: getIt<IGamificationService>().hasNewAchievements(),
                    builder: (context, snapshot) {
                      if (snapshot.data != true) return const SizedBox.shrink();
                      return Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  L10n.get("menu_achievements"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
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

  Widget _buildAdminPanelButton(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color:
                    ThemeState().isBlueTheme
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  L10n.get("menu_admin_panel"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
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

  Widget _buildManagePropertyButton(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    ListingsBloc(getIt<IListingService>()),
                child: const UserListingsScreen(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.home_work,
                color:
                    ThemeState().isBlueTheme
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
              Icon(
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

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    CommonConfirmationDialogs.showLogoutConfirmation(
      context: context,
      onConfirm: () async {
        // Show success toast immediately before logout to avoid context issues
        final message = L10n.get("logout_success");
        ToastTheme.showSuccess(context, message: message);

        // Then perform logout
        await LogoutService().performLogout(context);
      },
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
        onTap: () => _showDeleteAccountDialog(context),
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

  // Helper method to check if profile has any new fields
  bool _hasNewProfileFields(UserProfile profile) {
    return profile.employed != null ||
        profile.cleanliness != null ||
        profile.noiseLevel != null ||
        profile.sociability != null ||
        profile.guestsAllowed != null ||
        profile.smokingPreference != null ||
        profile.alcoholPreference != null ||
        profile.cookingHabits != null ||
        profile.petsPreference != null ||
        profile.wakeupTime != null ||
        profile.sleepTime != null;
  }

  // Helper method to build profile field
  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for text conversion
  String _getCleanlinessText(int value, BuildContext context) {
    switch (value) {
      case 1:
        return L10n.get("very_messy");
      case 2:
        return L10n.get("messy");
      case 3:
        return L10n.get("average");
      case 4:
        return L10n.get("clean");
      case 5:
        return L10n.get("very_clean");
      default:
        return value.toString();
    }
  }

  String _getNoiseLevelText(int value, BuildContext context) {
    switch (value) {
      case 1:
        return L10n.get("very_quiet");
      case 2:
        return L10n.get("quiet");
      case 3:
        return L10n.get("average");
      case 4:
        return L10n.get("loud");
      case 5:
        return L10n.get("very_loud");
      default:
        return value.toString();
    }
  }

  String _getSociabilityText(int value, BuildContext context) {
    switch (value) {
      case 1:
        return L10n.get("very_introverted");
      case 2:
        return L10n.get("introverted");
      case 3:
        return L10n.get("balanced");
      case 4:
        return L10n.get("extroverted");
      case 5:
        return L10n.get("very_extroverted");
      default:
        return value.toString();
    }
  }

  String _getSmokingPreferenceText(String value, BuildContext context) {
    switch (value) {
      case "non-smoker":
        return L10n.get("non_smoker");
      case "occasional":
        return L10n.get("occasional_smoker");
      case "regular":
        return L10n.get("regular_smoker");
      default:
        return value;
    }
  }

  String _getAlcoholPreferenceText(String value, BuildContext context) {
    switch (value) {
      case "non-drinker":
        return L10n.get("non_drinker");
      case "occasional":
        return L10n.get("occasional_drinker");
      case "regular":
        return L10n.get("regular_drinker");
      default:
        return value;
    }
  }


  String _getTimePreferenceText(String value, BuildContext context) {
    switch (value) {
      case "morning":
        return L10n.get("morning");
      case "evening":
        return L10n.get("evening");
      case "night":
        return L10n.get("night");
      default:
        return value;
    }
  }

  /// Get theme-aware color for lifestyle preferences header
  Color _getLifestyleHeaderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White text for blue theme
    } else {
      return Colors.black; // Black text for other themes
    }
  }

  /// Build action menu items for the dropdown menu
  List<ActionMenuItem> _buildActionMenuItems(BuildContext context) {
    return [
      // Edit Profile item (hidden for blocked users - they get 403 on save)
      if (!_userBlocked)
        ActionMenuItem(
          value: "edit_profile",
          icon: Icons.edit,
          textKey: "edit_profile",
          onPressed: () async {
          try {
            // Get the current profile from the bloc
            final currentState = context.read<CurrentUserProfileBloc>().state;
            final cachedProfile = _cachedUserProfile;
            currentState.map(
              initial:
                  (_) =>
                      cachedProfile != null
                          ? _openEditProfileScreen(
                            context,
                            cachedProfile,
                          )
                          : ToastTheme.showInfo(
                            context,
                            message: L10n.get("profile_not_loaded_yet"),
                          ),
              loading:
                  (_) =>
                      cachedProfile != null
                          ? _openEditProfileScreen(
                            context,
                            cachedProfile,
                          )
                          : ToastTheme.showInfo(
                            context,
                            message: L10n.get("profile_still_loading"),
                          ),
              loaded: (loadedState) async {
                await _openEditProfileScreen(context, loadedState.profile);
              },
              error:
                  (errorState) =>
                      cachedProfile != null
                          ? _openEditProfileScreen(
                            context,
                            cachedProfile,
                          )
                          : ToastTheme.showError(
                            context,
                            message: L10n.get("error_with_message").replaceAll("{message}", errorState.message),
                          ),
            );
          } catch (e) {
            ToastTheme.showError(
              context,
              message: L10n.get("error_opening_edit_screen").replaceAll("{error}", e.toString()),
            );
          }
        },
        ),
      // Messages item
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
      // My Listings item
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
      if (_userRole == "admin")
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
      // Logout item
      ActionMenuItem(
        value: "logout",
        icon: Icons.logout,
        textKey: "menu_logout",
        iconColor: AppColors.error,
        textColor: AppColors.error,
        onPressed: () => _showLogoutDialog(context),
      ),
    ];
  }

  Future<void> _openEditProfileScreen(
    BuildContext context,
    UserProfile profile,
  ) async {
    // Navigate to edit profile screen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );

    // Refresh profile if edit was successful
    if (result == true) {
      logger.d("=== PROFILE EDIT SUCCESS ===");
      logger.d("Edit profile returned true, refreshing profile data...");

      // Refresh the profile data
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
