import "dart:async";
import "dart:ui" show ImageFilter;

import "package:dio/dio.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:telegram_login/telegram_login.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
// import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/base/services/telegram_native_login_service.dart";
// import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/services/logout_service.dart"
    show AccountBlockedException, LogoutService;
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/util/telegram_oauth_web_util.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/support_unread_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/common_friend.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/auth_service.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/follow_service.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
// import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_header_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_listings_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_settings_section.dart";
import "package:uy_dosh/presentation/screens/profile/profile_stats_section.dart";
import "package:uy_dosh/presentation/screens/support/support_chat_screen.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
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
  int?
      _expandedProfileMenuGroupIndex; // 0 = Listings & chats, 1 = Notifications & support
  bool _userRoleLoaded = false;
  bool _refreshingRole = false;
  bool _userBlocked = false;
  UserProfile? _cachedUserProfile;
  String? _cachedGoogleDisplayName;
  String? _cachedGooglePhotoUrl;
  String? _cachedTelegramPhotoUrl;
  String? _cachedUserEmail;
  bool _achievementCheckScheduled = false;
  DateTime? _lastAchievementCheckTime;
  bool? _telegramLinked;
  bool _canUnbindTelegram = false;
  bool _isLinkingTelegram = false;
  bool _isUnlinkingTelegram = false;
  FollowCounts? _prefetchedFollowCounts;
  // AI allowance profile tile (hidden; restore with imports + _refreshListingAiQuota)
  // ListingAiQuotaSnapshot? _listingAiQuota;
  // bool _listingAiQuotaLoading = false;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "profile");
    _loadProfileScreenLocalSnapshot();
    unawaited(SupportUnreadState().refresh());
    unawaited(_prefetchFollowCounts());
    unawaited(_refreshTelegramLinkedStatus());
    _registerTelegramBindDeepLinkListener();
    if (kIsWeb) {
      final webBind = DeepLinkService.tryParseTelegramBindFromCurrentLocation();
      if (webBind != null) {
        clearTelegramOAuthQueryFromBrowserUrl();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(_handleTelegramBindDeepLink(webBind));
          }
        });
      }
    }
    // unawaited(_refreshListingAiQuota());
  }

  @override
  void dispose() {
    getIt<DeepLinkService>().onTelegramBindLink = null;
    super.dispose();
  }

  void _registerTelegramBindDeepLinkListener() {
    getIt<DeepLinkService>().onTelegramBindLink = (link) {
      if (!mounted) return;
      unawaited(_handleTelegramBindDeepLink(link));
    };
  }

  Future<void> _refreshTelegramLinkedStatus() async {
    if (!AuthenticationState().isAuthenticated) return;
    try {
      final me = await getIt<IAuthService>().fetchCurrentUser();
      if (!mounted) return;
      final telegramId = me["telegram_id"];
      setState(() {
        _telegramLinked =
            telegramId is String ? telegramId.trim().isNotEmpty : telegramId != null;
        _canUnbindTelegram = _hasAlternateSignInMethod(me);
        if (_telegramLinked == false && _expandedSectionIndex == null) {
          _expandedSectionIndex = 0;
        }
      });
    } catch (e) {
      logger.d("Failed to load Telegram link status: $e");
    }
  }

  bool _hasAlternateSignInMethod(Map<String, dynamic> me) {
    bool hasValue(dynamic value) =>
        value is String && value.trim().isNotEmpty;
    return hasValue(me["firebase_uid"]) ||
        hasValue(me["email"]) ||
        hasValue(me["phone_number"]);
  }

  Future<void> _handleTelegramBindDeepLink(TelegramBindDeepLink link) async {
    if (link.isError) {
      ToastTheme.showWarning(
        context,
        message: _telegramBindErrorMessage(link.errorMessage ?? "unknown"),
      );
      return;
    }
    setState(() {
      _telegramLinked = true;
      // Bind requires an existing session (Google/phone/etc.), so unlink is safe.
      _canUnbindTelegram = true;
    });
    context.read<CurrentUserProfileBloc>().add(
          const CurrentUserProfileEvent.fetchProfile(),
        );
    unawaited(_refreshTelegramLinkedStatus());
    ToastTheme.showSuccess(
      context,
      message: L10n.get("telegram_linked_success"),
    );
  }

  String? _backendErrorCode(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return data["error"]?.toString();
    }
    return null;
  }

  String _telegramBindErrorMessage(String code) {
    switch (code) {
      case "telegram_already_linked":
        return L10n.get("telegram_already_linked");
      case "telegram_account_in_use":
        return L10n.get("telegram_account_in_use");
      case "telegram_not_linked":
        return L10n.get("telegram_not_linked");
      case "telegram_only_sign_in_method":
        return L10n.get("telegram_only_sign_in_method");
      case "Invalid Telegram id_token":
        return L10n.get("telegram_bind_invalid_token");
      case "Telegram OIDC is not configured":
        return L10n.get("telegram_bind_not_configured");
      default:
        return L10n.get("telegram_link_failed")
            .replaceAll("{error}", code);
    }
  }

  String _telegramUnbindErrorMessage(String code) {
    switch (code) {
      case "telegram_not_linked":
        return L10n.get("telegram_not_linked");
      case "telegram_only_sign_in_method":
        return L10n.get("telegram_only_sign_in_method");
      default:
        return L10n.get("telegram_unlink_failed").replaceAll("{error}", code);
    }
  }

  String _telegramBindErrorFromDio(DioException error) {
    final backendCode = _backendErrorCode(error);
    if (backendCode != null && backendCode.isNotEmpty) {
      return _telegramBindErrorMessage(backendCode);
    }
    if (error.response?.statusCode == 404) {
      return L10n.get("telegram_bind_not_available");
    }
    return L10n.get("telegram_link_failed").replaceAll(
          "{error}",
          ErrorMessageHelper.sanitizeErrorMessage(error),
        );
  }

  Future<void> _linkTelegramAccount() async {
    if (_isLinkingTelegram || !mounted) return;
    setState(() => _isLinkingTelegram = true);
    try {
      if (!kIsWeb && TelegramNativeLoginService.instance.isSupported) {
        final idToken = await TelegramNativeLoginService.instance.login();
        if (!mounted) return;
        if (idToken == null) return;
        await getIt<IAuthService>().telegramBind(idToken: idToken);
        if (!mounted) return;
        setState(() {
          _telegramLinked = true;
          // Bind requires an existing session (Google/phone/etc.), so unlink is safe.
          _canUnbindTelegram = true;
        });
        context.read<CurrentUserProfileBloc>().add(
              const CurrentUserProfileEvent.fetchProfile(),
            );
        unawaited(_refreshTelegramLinkedStatus());
        ToastTheme.showSuccess(
          context,
          message: L10n.get("telegram_linked_success"),
        );
        return;
      }

      final url = await getIt<IAuthService>().fetchTelegramOAuthBindAuthorizationUrl(
        languageCode: LanguageState().currentLanguage,
        returnTo: telegramOAuthWebReturnTo(),
      );
      final uri = Uri.parse(url);
      final ok = kIsWeb
          ? await launchUrl(uri, webOnlyWindowName: "_self")
          : await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        ToastTheme.showWarning(
          context,
          message: L10n.get("could_not_open_telegram"),
        );
        return;
      }
      if (!kIsWeb) {
        ToastTheme.showInfo(
          context,
          message: L10n.get("telegram_login_continue_in_browser"),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ToastTheme.showWarning(
        context,
        message: _telegramBindErrorFromDio(e),
      );
    } on TelegramLoginError catch (e) {
      if (!mounted || e.code == TelegramLoginErrorCode.cancelled) return;
      ToastTheme.showWarning(
        context,
        message: L10n.get("telegram_link_failed")
            .replaceAll("{error}", e.message ?? e.code.name),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showWarning(
        context,
        message: L10n.get("telegram_link_failed")
            .replaceAll("{error}", ErrorMessageHelper.sanitizeErrorMessage(e)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLinkingTelegram = false);
      }
    }
  }

  Future<void> _unlinkTelegramAccount() async {
    if (_isUnlinkingTelegram || !mounted) return;

    final confirmed = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "unlink_telegram_confirmation_title",
      messageKey: "unlink_telegram_confirmation_message",
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isUnlinkingTelegram = true);
    try {
      await getIt<IAuthService>().telegramUnbind();
      if (!mounted) return;
      setState(() => _telegramLinked = false);
      context.read<CurrentUserProfileBloc>().add(
            const CurrentUserProfileEvent.fetchProfile(),
          );
      unawaited(_refreshTelegramLinkedStatus());
      ToastTheme.showSuccess(
        context,
        message: L10n.get("telegram_unlinked_success"),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final backendCode = _backendErrorCode(e);
      ToastTheme.showWarning(
        context,
        message: backendCode != null && backendCode.isNotEmpty
            ? _telegramUnbindErrorMessage(backendCode)
            : L10n.get("telegram_unlink_failed").replaceAll(
                  "{error}",
                  ErrorMessageHelper.sanitizeErrorMessage(e),
                ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showWarning(
        context,
        message: L10n.get("telegram_unlink_failed").replaceAll(
              "{error}",
              ErrorMessageHelper.sanitizeErrorMessage(e),
            ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUnlinkingTelegram = false);
      }
    }
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

  Future<void> _prefetchFollowCounts() async {
    if (!AuthenticationState().isAuthenticated) return;

    final userId = await SessionManager.getUserId();
    if (userId == null || !mounted) return;

    final counts = await getIt<IFollowService>().getFollowCounts(userId);
    if (!mounted) return;

    setStateIfMounted(() => _prefetchedFollowCounts = counts);
  }

  /// One [Future.wait] for all local session fields used on cold open, so
  /// [SessionManager.getIsUserBlocked] (and shared prefs access) is not
  /// duplicated across two parallel startup paths.
  Future<void> _loadProfileScreenLocalSnapshot() async {
    final results = await Future.wait<Object?>([
      SessionManager.getGoogleDisplayName(),
      SessionManager.getGooglePhotoUrl(),
      SessionManager.getTelegramPhotoUrl(),
      SessionManager.getCachedUserProfile(),
      SessionManager.getIsUserBlocked(),
      SessionManager.getUserRole(),
      SessionManager.getUserEmail(),
    ]);

    final cachedRole = results[5] as String?;

    setStateIfMounted(() {
      _cachedGoogleDisplayName = results[0] as String?;
      _cachedGooglePhotoUrl = results[1] as String?;
      _cachedTelegramPhotoUrl = results[2] as String?;
      _cachedUserProfile = results[3] as UserProfile?;
      _userBlocked = results[4]! as bool;
      _userRole = cachedRole;
      _userRoleLoaded = true;
      _cachedUserEmail = results[6] as String?;
    });
    ProfileCompletionState().updateGooglePhotoUrl(results[1] as String?);

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
      final userId = await SessionManager.getUserId();

      var viewedListingsCount = 0;
      var favoritesCount = 0;
      var listingsCreatedCount = 0;
      var messagesSentCount = 0;

      await Future.wait<void>([
        () async {
          try {
            final viewed = await getIt<IListingService>()
                .getViewedListings(page: 1, limit: 1);
            viewedListingsCount = viewed.total;
          } catch (_) {}
        }(),
        () async {
          try {
            favoritesCount = await getIt<IFavoriteService>().getUserFavoritesCount();
          } catch (_) {}
        }(),
        () async {
          if (userId == null) return;
          try {
            final myListings = await getIt<IListingService>()
                .getListingsByUserId(userId: userId, page: 1, limit: 1);
            listingsCreatedCount = myListings.total;
          } catch (_) {}
        }(),
        () async {
          try {
            if (await getIt<IGamificationService>().hasSentFirstMessage()) {
              messagesSentCount = 1;
            }
          } catch (_) {}
        }(),
      ]);

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
            final telegramPhoto = profile.telegramAvatarUrl?.trim();
            setStateIfMounted(() {
              _cachedUserProfile = profile;
              if (telegramPhoto != null && telegramPhoto.isNotEmpty) {
                _cachedTelegramPhotoUrl = resolveAvatarUrl(telegramPhoto);
              }
            });
            if (telegramPhoto != null && telegramPhoto.isNotEmpty) {
              unawaited(SessionManager.storeTelegramPhotoUrl(telegramPhoto));
            }
          },
        );
        state.maybeWhen(
          error: (message) {
            if (message != profileNotFoundErrorCode ||
                _redirectedToProfileSetup) {
              return;
            }
            // A cached profile means this is a returning user — keep them on
            // the profile screen even if the live fetch 404s (stale session,
            // transient API issue, etc.).
            if (_cachedUserProfile != null) {
              return;
            }
            _redirectedToProfileSetup = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.pushAuthWizard(
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
              final themeState = ThemeState();
              final useLiquidGlassAppBar =
                  themeState.isBlueTheme || themeState.isLightTheme;

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
                  data.errorMessage == profileNotFoundErrorCode &&
                  effectiveProfile == null) {
                return Scaffold(
                  body: CenteredHouseLoadingIndicator(
                    text: L10n.get("loading"),
                  ),
                );
              }

              if (effectiveProfile == null && data.hasError) {
                final footerFill = Theme.of(context).scaffoldBackgroundColor;
                return ColoredBox(
                  color: footerFill,
                  child: Scaffold(
                    backgroundColor: footerFill,
                    appBar: _buildProfileScreenAppBar(
                      context,
                      useLiquidGlass: useLiquidGlassAppBar,
                    ),
                    body: _buildErrorState(data.errorMessage, context),
                  ),
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
              final footerFill = Theme.of(context).scaffoldBackgroundColor;
              return ColoredBox(
                color: footerFill,
                child: Scaffold(
                  backgroundColor: footerFill,
                  appBar: _buildProfileScreenAppBar(
                    context,
                    useLiquidGlass: useLiquidGlassAppBar,
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
                  floatingActionButton: _SupportChatFab(
                    onPressed: () => _openSupportChat(context),
                  ),
                  body: _shouldShowProfileFetchError(data)
                      ? _buildErrorState(data.errorMessage, context)
                      : _buildProfileContent(profile),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// When a cached profile exists, a live `profile_not_found` response should
  /// not replace the screen — show the cached profile instead.
  bool _shouldShowProfileFetchError(_ProfileScreenData data) {
    if (!data.hasError) return false;
    if (data.errorMessage == profileNotFoundErrorCode &&
        _cachedUserProfile != null) {
      return false;
    }
    return true;
  }

  PreferredSizeWidget _buildProfileScreenAppBar(
    BuildContext context, {
    required bool useLiquidGlass,
    List<Widget>? actions,
  }) {
    final themeState = ThemeState();
    final appBarTheme = Theme.of(context).appBarTheme;
    return UydoshAppBar(
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
      actions: actions,
      backgroundColor:
          useLiquidGlass
              ? liquidGlassAppBarMaterialColor(context)
              : appBarTheme.backgroundColor,
      surfaceTintColor:
          useLiquidGlass ? Colors.transparent : appBarTheme.surfaceTintColor,
      elevation: useLiquidGlass ? 0 : null,
      scrolledUnderElevation: useLiquidGlass ? 0 : null,
      shadowColor:
          useLiquidGlass ? Colors.transparent : appBarTheme.shadowColor,
      forceMaterialTransparency: useLiquidGlass,
      flexibleSpace:
          useLiquidGlass ? const LiquidGlassAppBarFlexibleSpace() : null,
      foregroundColor:
          useLiquidGlass
              ? (appBarTheme.foregroundColor ?? themeState.textColor)
              : appBarTheme.foregroundColor,
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    return SingleChildScrollView(
      // Pushed route: body already clears the app bar — no
      // [extendBodyBehindAppBar] / status-bar inset (see favorites_screen).
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                initialFollowCounts: _prefetchedFollowCounts,
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
                cachedTelegramPhotoUrl: _cachedTelegramPhotoUrl,
                expandedSectionIndex: _expandedSectionIndex,
                onExpandedSectionChanged: (index) {
                  setState(() => _expandedSectionIndex = index);
                },
                getLocalizedRegionName: _getLocalizedRegionName,
                getLocalizedUniversityName: _getLocalizedUniversityName,
                telegramLinked: _telegramLinked,
                canUnbindTelegram: _canUnbindTelegram,
                isLinkingTelegram: _isLinkingTelegram,
                isUnlinkingTelegram: _isUnlinkingTelegram,
                onLinkTelegram: _telegramLinked == false ? _linkTelegramAccount : null,
                onUnlinkTelegram:
                    _telegramLinked == true && _canUnbindTelegram
                        ? _unlinkTelegramAccount
                        : null,
              ),
              const SizedBox(height: 24),
              ProfileListingsSection(
                userRole: _userRole,
                expandedMenuGroupIndex: _expandedProfileMenuGroupIndex,
                onExpandedMenuGroupChanged: (index) {
                  setState(() => _expandedProfileMenuGroupIndex = index);
                },
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
                  // Email allowlist + any admin: moderators often sign in with a
                  // non-founder Google account, so the founder email check alone
                  // is not enough to keep staff from self-deleting.
                  final deleteProtected =
                      currentEmail == _kProtectedDeleteAccountEmail ||
                      (_userRole?.toLowerCase().trim() == "admin");

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
          PrimaryButton(
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
            TextButtonThemed(
              onPressed: () => _showLogoutDialog(context),
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
      case "moderator":
        return L10n.get("role_moderator");
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

  void _openSupportChat(BuildContext context) {
    HapticFeedbackUtils.impact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SupportChatScreen(),
      ),
    ).then((_) => SupportUnreadState().refresh());
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

    if (!mounted) return;

    // User may have linked/unlinked Telegram without saving other profile fields.
    unawaited(_refreshTelegramLinkedStatus());
    context.read<CurrentUserProfileBloc>().add(
          const CurrentUserProfileEvent.fetchProfile(),
        );

    if (result == true) {
      logger.d("=== PROFILE EDIT SUCCESS ===");
      logger.d("Edit profile returned true");
    } else {
      logger.d("=== PROFILE EDIT CLOSED ===");
      logger.d("Edit profile returned: $result");
    }
  }
}

class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

/// Glass pill FAB that opens support chat from the profile screen. Mirrors the
/// frosted style used by the archived-chats entry point in the messages inbox.
class _SupportChatFab extends StatelessWidget {
  const _SupportChatFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeState(), SupportUnreadState()]),
      builder: (context, _) {
        final themeState = ThemeState();
        final hasUnread = SupportUnreadState().hasUnread;
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final iconColor =
            themeState.isBlueTheme ? Colors.white : themeState.cardIconColor;
        final textColor =
            themeState.isBlueTheme ? Colors.white : themeState.textColor;

        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final enableGlass =
            AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

        final baseTint =
            themeState.isLightTheme ? scheme.surface : themeState.cardColor;

        const radius = BorderRadius.all(Radius.circular(999));

        final pill = Semantics(
          button: true,
          label: L10n.get("menu_contact_support"),
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: enableGlass ? 18 : 0,
                  sigmaY: enableGlass ? 18 : 0,
                ),
                child: InkWell(
                  borderRadius: radius,
                  onTap: onPressed,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: baseTint.withValues(alpha: isDark ? 0.14 : 0.18),
                      border: Border.all(
                        color: (themeState.isBlueTheme
                                ? Colors.white
                                : scheme.onSurface)
                            .withValues(
                          alpha: themeState.isBlueTheme ? 0.18 : 0.10,
                        ),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.22 : 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.support_agent,
                            size: 22,
                            color: iconColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            L10n.get("menu_contact_support"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        if (!hasUnread) return pill;

        final dotBorderColor =
            themeState.isLightTheme ? scheme.surface : themeState.cardColor;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            pill,
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotBorderColor, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
