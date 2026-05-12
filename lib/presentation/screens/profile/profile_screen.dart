import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
// import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
// import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/services/logout_service.dart"
    show AccountBlockedException, LogoutService;
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
// import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_header_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_listings_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_settings_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_stats_section.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
// import "package:uy_dosh/presentation/widgets/profile/ai_allowance_upsell_banner.dart";

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
  static const String _kProtectedDeleteAccountEmail = "uydoshtech@gmail.com";

  bool _redirectedToProfileSetup = false;
  String? _userRole;
  int?
      _expandedSectionIndex; // 0 = Profile, 1 = Lifestyle Preferences (mutually exclusive)
  bool _userRoleLoaded = false;
  bool _refreshingRole = false;
  bool _userBlocked = false;
  UserProfile? _cachedUserProfile;
  String? _cachedGoogleDisplayName;
  String? _cachedGooglePhotoUrl;
  String? _cachedUserEmail;
  bool _achievementCheckScheduled = false;
  DateTime? _lastAchievementCheckTime;
  // AI allowance profile tile (hidden; restore with imports + _refreshListingAiQuota)
  // ListingAiQuotaSnapshot? _listingAiQuota;
  // bool _listingAiQuotaLoading = false;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "profile");
    _loadProfileScreenLocalSnapshot();
    // unawaited(_refreshListingAiQuota());
  }

  // Future<void> _refreshListingAiQuota() async {
  //   if (!AuthenticationState().isAuthenticated || _userBlocked) {
  //     if (mounted) {
  //       setState(() {
  //         _listingAiQuotaLoading = false;
  //         _listingAiQuota = null;
  //       });
  //     }
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() => _listingAiQuotaLoading = true);
  //   final snap = await getIt<GeminiService>().fetchListingAiQuota();
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {
  //     _listingAiQuotaLoading = false;
  //     _listingAiQuota = snap;
  //   });
  // }

  /// One [Future.wait] for all local session fields used on cold open, so
  /// [SessionManager.getIsUserBlocked] (and shared prefs access) is not
  /// duplicated across two parallel startup paths.
  Future<void> _loadProfileScreenLocalSnapshot() async {
    final results = await Future.wait<Object?>([
      SessionManager.getGoogleDisplayName(),
      SessionManager.getGooglePhotoUrl(),
      SessionManager.getCachedUserProfile(),
      SessionManager.getIsUserBlocked(),
      SessionManager.getUserRole(),
      SessionManager.getUserEmail(),
    ]);

    final cachedRole = results[4] as String?;

    setStateIfMounted(() {
      _cachedGoogleDisplayName = results[0] as String?;
      _cachedGooglePhotoUrl = results[1] as String?;
      _cachedUserProfile = results[2] as UserProfile?;
      _userBlocked = results[3]! as bool;
      _userRole = cachedRole;
      _userRoleLoaded = true;
      _cachedUserEmail = results[5] as String?;
    });

    // unawaited(_refreshListingAiQuota());

    // Always opportunistically refresh from the server after showing the
    // cached profile. This keeps the screen instant-render from cache but
    // overwrites any stale fields (e.g. completion %) with the latest data.
    if (AuthenticationState().isAuthenticated && mounted) {
      context.read<CurrentUserProfileBloc>().add(
            const CurrentUserProfileEvent.fetchProfile(),
          );
    }

    if (cachedRole == null && mounted) {
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
        final favorites = await getIt<IFavoriteService>()
            .getUserFavorites(page: 1, limit: 100);
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
      setStateIfMounted(() {});
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
      final role =
          user is Map<String, dynamic> ? user["role"] as String? : null;
      final isBlocked = user is Map<String, dynamic>
          ? (user["is_blocked"] as bool? ?? false)
          : false;
      if (role != null) {
        await SessionManager.storeUserRole(role);
      }
      await SessionManager.storeUserBlockedStatus(isBlocked);
      setStateIfMounted(() {
        _userRole = role;
        _userBlocked = isBlocked;
        _userRoleLoaded = true;
      });
    } catch (_) {
      setStateIfMounted(() {
        _userRoleLoaded = true;
      });
    } finally {
      _refreshingRole = false;
      // unawaited(_refreshListingAiQuota());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentUserProfileBloc, CurrentUserProfileState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (profile) {
            setStateIfMounted(() {
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
          return BlocSelector<CurrentUserProfileBloc, CurrentUserProfileState,
              _ProfileScreenData>(
            selector: (state) => state.map(
              initial: (_) => const _ProfileScreenData(
                isLoading: true,
                hasError: false,
                errorMessage: "",
                profile: null,
              ),
              loading: (_) => const _ProfileScreenData(
                isLoading: true,
                hasError: false,
                errorMessage: "",
                profile: null,
              ),
              loaded: (loadedState) => _ProfileScreenData(
                isLoading: false,
                hasError: false,
                errorMessage: "",
                profile: loadedState.profile,
              ),
              error: (errorState) => _ProfileScreenData(
                isLoading: false,
                hasError: true,
                errorMessage: errorState.message,
                profile: null,
              ),
            ),
            builder: (context, data) {
              final effectiveProfile = data.profile ?? _cachedUserProfile;

              if (effectiveProfile == null &&
                  data.isLoading &&
                  !data.hasError) {
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

              if (effectiveProfile == null && data.hasError) {
                return Scaffold(
                  appBar: UydoshAppBar(
                    leading: ThreeDAppBarIconButton.backLeading(
                      context,
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    title: Text(
                      L10n.get("profile"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: _buildErrorState(data.errorMessage, context),
                );
              }

              final profile = effectiveProfile!;
              final now = DateTime.now();
              final shouldCheck = !_achievementCheckScheduled ||
                  (_lastAchievementCheckTime != null &&
                      now.difference(_lastAchievementCheckTime!).inSeconds >
                          30);
              if (shouldCheck) {
                _achievementCheckScheduled = true;
                _lastAchievementCheckTime = now;
                Future.microtask(
                  () => _checkAndUnlockAchievements(profile, context),
                );
              }
              return Scaffold(
                appBar: UydoshAppBar(
                  leading: ThreeDAppBarIconButton.backLeading(
                    context,
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
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
                body: data.hasError
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
                onEditProfile: () => _openEditProfileScreen(context, profile),
                onAvatarUpdated: () {
                  if (!mounted) return;
                  context.read<CurrentUserProfileBloc>().add(
                        const CurrentUserProfileEvent.fetchProfile(),
                      );
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              ProfileListingsSection(
                userRole: _userRole,
                onAchievementsOpened: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              // AI allowance upsell tile (Использование AI-помощника)
              // if (!_userBlocked && AuthenticationState().isAuthenticated)
              //   ValueListenableBuilder<bool>(
              //     valueListenable:
              //         ClientGeminiListingUiConfig.hideGeminiListingUi,
              //     builder: (context, hideListingGeminiUi, _) {
              //       final allowanceVisible =
              //           AiAllowanceUpsellBanner.willShowContent(
              //         snapshot: _listingAiQuota,
              //         isLoading: _listingAiQuotaLoading,
              //       );
              //       return Column(
              //         mainAxisSize: MainAxisSize.min,
              //         crossAxisAlignment: CrossAxisAlignment.stretch,
              //         children: [
              //           AiAllowanceUpsellBanner(
              //             snapshot: _listingAiQuota,
              //             isLoading: _listingAiQuotaLoading,
              //             hideListingGeminiUi: hideListingGeminiUi,
              //             onUpgradeTap: () {
              //               Navigator.of(context).push<void>(
              //                 MaterialPageRoute<void>(
              //                   builder: (_) =>
              //                       const AiPremiumPlaceholderScreen(),
              //                 ),
              //               );
              //             },
              //           ),
              //           if (allowanceVisible) const SizedBox(height: 24),
              //         ],
              //       );
              //     },
              //   ),
              Builder(
                builder: (context) {
                  final firebaseEmail =
                      FirebaseAuth.instance.currentUser?.email;
                  final currentEmail =
                      (firebaseEmail ?? _cachedUserEmail)?.trim().toLowerCase();
                  final deleteProtected =
                      currentEmail == _kProtectedDeleteAccountEmail;

                  return ProfileSettingsSection(
                    onLogout: () => _showLogoutDialog(context),
                    canDeleteAccount: !deleteProtected,
                    onDeleteAccount: () => _showDeleteAccountDialog(context),
                    onDeleteAccountDisabledTap: () {
                      ToastTheme.showInfo(
                        context,
                        message: L10n.get("delete_account_not_allowed"),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    final isSessionExpired = message == sessionExpiredErrorCode;
    final sanitizedMessage = isSessionExpired
        ? null
        : ErrorMessageHelper.sanitizeErrorMessage(message, context: context);

    return UydoshErrorRetryColumn(
      iconColor: AppColors.error,
      title: L10n.get(
        isSessionExpired ? "session_expired" : "error_loading_profile",
      ),
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      ),
      message: sanitizedMessage,
      messageStyle: TextStyle(
        fontSize: 14,
        color: AppColors.getThemeAwareTextColor(context).withOpacity(0.7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      spacingAfterIcon: 24,
      spacingAfterTitle: 12,
      spacingBeforeButton: 20,
      retryButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              HapticFeedbackUtils.impact();
              if (isSessionExpired) {
                LogoutService().performLogout();
              } else {
                context.read<CurrentUserProfileBloc>().add(
                      const CurrentUserProfileEvent.fetchProfile(),
                    );
              }
            },
            child: Text(
              L10n.get(isSessionExpired ? "logout" : "retry"),
            ),
          ),
          if (!isSessionExpired) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                HapticFeedbackUtils.impact();
                _showLogoutDialog(context);
              },
              child: Text(L10n.get("logout")),
            ),
          ],
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
      case "service_requester":
        return L10n.get("role_service_requester");
      case "service_provider":
        return L10n.get("role_service_provider");
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
        await LogoutService().performLogout();
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    CommonConfirmationDialogs.showDeleteAccountConfirmation(
      context: context,
      onConfirm: () async {
        final rootNav = Navigator.of(context, rootNavigator: true);
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (_) => const PopScope(
            canPop: false,
            child: Center(child: HouseLoadingIndicator()),
          ),
        );
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
        } finally {
          if (rootNav.mounted && rootNav.canPop()) {
            rootNav.pop();
          }
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
