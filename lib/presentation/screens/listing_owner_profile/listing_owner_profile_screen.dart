import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/config/client_listing_contact_ui_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/pets_preference_strings.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
class _ListingOwnerProfileData {

  const _ListingOwnerProfileData({
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
    return other is _ListingOwnerProfileData &&
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

class ListingOwnerProfileScreen extends StatefulWidget {

  const ListingOwnerProfileScreen({
    required this.userId, super.key,
    this.phoneNumber,
  });
  final int userId;
  final String? phoneNumber;

  @override
  State<ListingOwnerProfileScreen> createState() =>
      _ListingOwnerProfileScreenState();
}

class _ListingOwnerProfileScreenState extends State<ListingOwnerProfileScreen> {
  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "listing_owner_profile");
    getIt<AppAnalyticsService>().logOwnerProfileViewed(ownerId: widget.userId);
    context.read<ListingOwnerProfileBloc>().add(
      ListingOwnerProfileEvent.fetchProfile(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    logger.d("🔍 Profile Screen: Building with userId: ${widget.userId}");

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: UydoshAppBar(
            leading: ThreeDAppBarIconButton.backLeading(context),
            title: L10n.text(
              "profile",
              style:
                  Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor ??
                _getPrimaryColor(),
            foregroundColor:
                Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
            elevation: 0,
          ),
          body: BlocSelector<
            ListingOwnerProfileBloc,
            ListingOwnerProfileState,
            _ListingOwnerProfileData
          >(
            selector:
                (state) => state.map(
                  initial:
                      (_) => const _ListingOwnerProfileData(
                        isLoading: true,
                        hasError: false,
                        errorMessage: "",
                        profile: null,
                      ),
                  loading:
                      (_) => const _ListingOwnerProfileData(
                        isLoading: true,
                        hasError: false,
                        errorMessage: "",
                        profile: null,
                      ),
                  loaded:
                      (loadedState) => _ListingOwnerProfileData(
                        isLoading: false,
                        hasError: false,
                        errorMessage: "",
                        profile: loadedState.profile,
                      ),
                  error:
                      (errorState) => _ListingOwnerProfileData(
                        isLoading: false,
                        hasError: true,
                        errorMessage: errorState.message,
                        profile: null,
                      ),
                ),
            builder: (context, data) {
              logger.d(
                "🔍 Profile Screen: Building with data: isLoading=${data.isLoading}, hasError=${data.hasError}",
              );

              if (data.isLoading) {
                return CenteredHouseLoadingIndicator(
                  text: L10n.get("loading"),
                );
              }

              if (data.hasError) {
                return _buildErrorState(data.errorMessage, context);
              }

              return _buildProfileContent(data.profile!);
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    logger.d("🔍 Profile Screen: Building profile content for: $profile");
    logger.d(
      "🔍 Profile Screen: Profile fields - id: ${profile.id}, userId: ${profile.userId}, name: ${profile.name}, gender: ${profile.gender}, isVerified: ${profile.isVerified}, rating: ${profile.rating}, aboutMe: ${profile.aboutMe}, telegram: ${profile.telegram}, createdAt: ${profile.createdAt}, updatedAt: ${profile.updatedAt}",
    );

    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar Section
              Center(child: _buildNeumorphicAvatar(context, profile)),

              const SizedBox(height: 24),

              // Merged Profile Information Card
              ListingDetailTileShell(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Name
                      Row(
                        children: [
                          const ThemeIcon(Icons.person, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.get("name"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  profile.name ?? "User",
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

                      // Gender field
                      if (profile.gender != null) ...[
                        Row(
                          children: [
                            ThemeIcon(
                              _getGenderIcon(profile.gender!),
                              size: 20,
                              color: _getGenderColor(profile.gender!),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.get("gender"),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
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
                          ThemeIconFactory.detail(
                            icon: Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.get("location"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  profile.region != null
                                      ? _getLocalizedRegionName(profile.region!)
                                      : L10n.get("not_specified"),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getPrimaryColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // University field
                      Row(
                        children: [
                          const ThemeIcon(Icons.school, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.get("university"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  profile.university != null
                                      ? _getLocalizedUniversityName(
                                        profile.university!,
                                      )
                                      : L10n.get("not_specified"),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getPrimaryColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Language field (what language the user speaks)
                      if (profile.preferredLanguage != null &&
                          profile.preferredLanguage!.isNotEmpty) ...[
                        Row(
                          children: [
                            const ThemeIcon(CupertinoIcons.globe, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    L10n.get("language"),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    LanguageDisplayHelper.getLocalizedLanguageName(
                                      profile.preferredLanguage!,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _getPrimaryColor(),
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
                          const ThemeIcon(Icons.info_outline, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.get("about_me"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  profile.aboutMe != null &&
                                          profile.aboutMe!.isNotEmpty
                                      ? profile.aboutMe!
                                      : L10n.get("not_specified"),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getPrimaryColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Rating field (if available)
                      if (profile.rating != null) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ThemeIcon(
                              Icons.star,
                              color: _getPrimaryColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
L10n.get("rating"),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return ThemeIcon(
                                        Icons.star,
                                        size: 19,
                                        color:
                                            index < profile.rating!
                                                ? _getPrimaryColor()
                                                : Colors.grey.withValues(
                                                  alpha: 0.3,
                                                ),
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
                ),
              ),

              // Lifestyle Preferences Section
              if (_hasNewProfileFields(profile)) ...[
                const SizedBox(height: 16),
                ListingDetailTileShell(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.get("lifestyle_preferences"),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getLifestyleHeaderColor(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Employed field
                        if (profile.employed != null) ...[
                          _buildProfileField(
                            icon: Icons.work,
                            label: L10n.get("work"),
                            value:
                                profile.employed!
                                    ? L10n.get("yes")
                                    : L10n.get("no"),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

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
                            label: L10n.get("guests"),
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
                            value: localizedPetsPreference(
                              profile.petsPreference!,
                            ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                      ],
                    ),
                  ),
                ),
              ],

              if (!ClientListingContactUiConfig.hidePublicContactDetails &&
                  profile.telegram != null) ...[
                _buildTappableDetailCard(
                  icon: Icons.telegram,
                  title: L10n.get("telegram"),
                  value: profile.telegram!,
                  onTap: () => _openTelegram(profile.telegram!, context),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Contact Button - only show if phone number is available
              if (!ClientListingContactUiConfig.hidePublicContactDetails &&
                  widget.phoneNumber != null &&
                  widget.phoneNumber!.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: GhostButtonFactory.iconText(
                    onPressed: () => _makePhoneCall(widget.phoneNumber!),
                    icon: Icons.phone,
                    text: L10n.get("contact_user"),
                    neumorphicSoftUi: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTappableDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListingDetailTileShell(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ThemeIcon(icon, color: _getPrimaryColor(), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              const ThemeIcon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return UydoshErrorRetryColumn(
      iconColor: AppColors.error,
      title: L10n.get("error"),
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      ),
      message: ErrorMessageHelper.sanitizeErrorMessage(
        message,
        context: context,
      ),
      messageStyle: TextStyle(
        fontSize: 14,
        color: AppColors.getThemeAwareTextColor(context).withOpacity(0.7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      spacingAfterIcon: 24,
      spacingAfterTitle: 12,
      spacingBeforeButton: 20,
      retryButton: GhostButtonFactory.text(
        onPressed: () {
          context.read<ListingOwnerProfileBloc>().add(
            ListingOwnerProfileEvent.fetchProfile(userId: widget.userId),
          );
        },
        text: L10n.get("retry"),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  // Theme-dependent color helper methods
  Color _getPrimaryColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  /// Raised circular face matching chat avatars and soft-UI profile controls.
  Widget _buildNeumorphicAvatar(BuildContext context, UserProfile profile) {
    const diameter = 100.0;
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final resolvedUrl = resolveAvatarUrl(profile.avatarUrl);
    final hasAvatar = resolvedUrl != null;
    final faceBase =
        isBlueTheme ? Colors.white : Color.lerp(surface, onSurface, 0.02)!;
    final glyphColor = isBlueTheme ? primary : onSurface;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              hasAvatar ? null : ThreeDSurfaceStyle.surfaceGradient(context, faceBase),
          color: hasAvatar ? faceBase : null,
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          border: Border.all(
            color: onSurface.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: ClipOval(
          child:
              hasAvatar
                  ? CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                    memCacheWidth: (diameter * 2).round(),
                    memCacheHeight: (diameter * 2).round(),
                    placeholder:
                        (context, url) => Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: glyphColor,
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Center(
                          child: ThemeIcon(
                            Icons.person,
                            size: 50,
                            color: glyphColor,
                          ),
                        ),
                  )
                  : Center(
                    child: ThemeIcon(Icons.person, size: 50, color: glyphColor),
                  ),
        ),
      ),
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
    return university.getLocalizedName(LanguageState().currentLanguage);
  }

  IconData _getGenderIcon(int gender) {
    switch (gender) {
      case 1: // Male
        return Icons.male;
      case 2: // Female
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  Color _getGenderColor(int gender) {
    switch (gender) {
      case 1: // Male
        return AppColors.genderMale;
      case 2: // Female
        return AppColors.genderFemale;
      default:
        return AppColors.genderOther;
    }
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    getIt<AppAnalyticsService>().logContactUserTapped(ownerId: widget.userId);
    final url = "tel:$phoneNumber";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ToastTheme.showError(
          context,
          message: L10n.get("error"),
        );
      }
    } catch (e) {
      ToastTheme.showError(
        context,
        message: L10n.get("error"),
      );
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
        ThemeIcon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
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
}
