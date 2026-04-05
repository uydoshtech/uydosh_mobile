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
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
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
        return Scaffold(
          appBar: AppBar(
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
        final currentLanguage = LanguageState().currentLanguage;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: Colors.white),
                      ),
                      child: Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          color: _getPrimaryColor(),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getPrimaryColor().withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _buildProfilePicture(profile),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Merged Profile Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Name
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
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
                            Icon(
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
                          const Icon(Icons.school, size: 20),
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
                            const Icon(CupertinoIcons.globe, size: 20),
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
                                    LanguageDisplayHelper.getLanguageDisplayName(
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
                          const Icon(Icons.info_outline, size: 20),
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
                            Icon(
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
                                      return Icon(
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
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                            label: L10n.get("employed"),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: _getPrimaryColor(), size: 24),
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
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeIconFactory.status(
              icon: Icons.error_outline,
              size: 64,
              isError: true,
            ),
            const SizedBox(height: 16),
            Text(
              L10n.get("error_loading_profile"),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              L10n.get("error_generic"),
              style: TextStyle(fontSize: 16, color: _getTextSecondaryColor()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GhostButtonFactory.text(
              onPressed: () {
                context.read<ListingOwnerProfileBloc>().add(
                  ListingOwnerProfileEvent.fetchProfile(userId: widget.userId),
                );
              },
              text: L10n.get("retry"),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString, String language) {
    if (dateString == null) return "Unknown";

    try {
      final date = DateTime.parse(dateString);

      final months = {
        "en": [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December",
        ],
        "ru": [
          "Январь",
          "Февраль",
          "Март",
          "Апрель",
          "Май",
          "Июнь",
          "Июль",
          "Август",
          "Сентябрь",
          "Октябрь",
          "Ноябрь",
          "Декабрь",
        ],
        "uz": [
          "Yanvar",
          "Fevral",
          "Mart",
          "Aprel",
          "May",
          "Iyun",
          "Iyul",
          "Avgust",
          "Sentabr",
          "Oktabr",
          "Noyabr",
          "Dekabr",
        ],
      };

      final monthNames = months[language] ?? months["en"]!;
      final month = monthNames[date.month - 1];
      final year = date.year;

      return "$month $year";
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }

  // Theme-dependent color helper methods
  Color _getPrimaryColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  Color _getButtonPrimaryColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary;
    } else {
      return AppColors.buttonPrimary;
    }
  }

  Color _getTextPrimaryColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.textPrimary;
    } else {
      return AppColors.textPrimary;
    }
  }

  Color _getTextSecondaryColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.textSecondary;
    } else {
      return AppColors.textSecondary;
    }
  }

  String _resolveAvatarUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    return "${EnvironmentUtil.basePath}$trimmed";
  }

  Widget _buildProfilePicture(UserProfile profile) {
    final raw = profile.avatarUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return const Center(
        child: Icon(Icons.person, size: 50, color: Colors.white),
      );
    }
    final imageUrl = _resolveAvatarUrl(raw);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 94,
        height: 94,
        fit: BoxFit.cover,
        memCacheWidth: 188,
        memCacheHeight: 188,
        placeholder:
            (context, url) => const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget:
            (context, url, error) => const Center(
              child: Icon(Icons.person, size: 50, color: Colors.white),
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
}
