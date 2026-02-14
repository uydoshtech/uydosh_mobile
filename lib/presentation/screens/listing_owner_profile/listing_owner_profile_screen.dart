import "package:uy_dosh/base/logger/logger.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
class _ListingOwnerProfileData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;

  const _ListingOwnerProfileData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.profile,
  });

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
  final int userId;
  final String? phoneNumber;

  const ListingOwnerProfileScreen({
    super.key,
    required this.userId,
    this.phoneNumber,
  });

  @override
  State<ListingOwnerProfileScreen> createState() =>
      _ListingOwnerProfileScreenState();
}

class _ListingOwnerProfileScreenState extends State<ListingOwnerProfileScreen> {
  @override
  void initState() {
    super.initState();
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
            title: LanguageAwareStringHelper.getText(
              "profile",
              context,
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
                      (_) => _ListingOwnerProfileData(
                        isLoading: true,
                        hasError: false,
                        errorMessage: "",
                        profile: null,
                      ),
                  loading:
                      (_) => _ListingOwnerProfileData(
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
                  text: LanguageAwareStringHelper.getCurrent(
                    context,
                    "loading",
                  ),
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
                        child: _buildProfilePicture(),
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
                          Icon(Icons.person, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "name",
                                  ),
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
                                    LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "gender",
                                    ),
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
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "location",
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  profile.region != null
                                      ? _getLocalizedRegionName(profile.region!)
                                      : LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "not_specified",
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

                      // University field
                      Row(
                        children: [
                          Icon(Icons.school, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "university",
                                  ),
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
                                      : LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "not_specified",
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

                      // About Me field
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "about_me",
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  profile.aboutMe != null &&
                                          profile.aboutMe!.isNotEmpty
                                      ? profile.aboutMe!
                                      : LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "not_specified",
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
                                    LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "rating",
                                    ),
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
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "lifestyle_preferences",
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getLifestyleHeaderColor(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Wake-up Time field
                        if (profile.wakeupTime != null) ...[
                          _buildProfileField(
                            icon: Icons.wb_sunny,
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "wakeup_time",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "sleep_time",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "employed",
                            ),
                            value:
                                profile.employed!
                                    ? LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "yes",
                                    )
                                    : LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "no",
                                    ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Cleanliness field
                        if (profile.cleanliness != null) ...[
                          _buildProfileField(
                            icon: Icons.cleaning_services,
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "cleanliness",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "noise_level",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "sociability",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "guests_allowed",
                            ),
                            value:
                                profile.guestsAllowed!
                                    ? LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "yes",
                                    )
                                    : LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "no",
                                    ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Smoking Preference field
                        if (profile.smokingPreference != null) ...[
                          _buildProfileField(
                            icon: Icons.smoking_rooms,
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "smoking_preference",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "alcohol_preference",
                            ),
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
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "cooking_habits",
                            ),
                            value:
                                profile.cookingHabits!
                                    ? LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "cook",
                                    )
                                    : LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "dont_cook",
                                    ),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Pets Preference field
                        if (profile.petsPreference != null) ...[
                          _buildProfileField(
                            icon: Icons.pets,
                            label: LanguageAwareStringHelper.getCurrent(
                              context,
                              "pets_preference",
                            ),
                            value:
                                profile.petsPreference!
                                    ? LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "pets_okay",
                                    )
                                    : LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "pets_not_okay",
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

              if (profile.telegram != null) ...[
                _buildTappableDetailCard(
                  icon: Icons.telegram,
                  title: LanguageAwareStringHelper.getCurrent(
                    context,
                    "telegram",
                  ),
                  value: profile.telegram!,
                  onTap: () => _openTelegram(profile.telegram!, context),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Contact Button - only show if phone number is available
              if (widget.phoneNumber != null &&
                  widget.phoneNumber!.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: GhostButtonFactory.iconText(
                    onPressed: () => _makePhoneCall(widget.phoneNumber!),
                    icon: Icons.phone,
                    text: LanguageAwareStringHelper.getCurrent(
                      context,
                      "contact_user",
                    ),
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
              LanguageAwareStringHelper.getCurrent(
                context,
                "error_loading_profile",
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LanguageAwareStringHelper.getCurrent(context, "error_generic"),
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
              text: LanguageAwareStringHelper.getCurrent(context, "retry"),
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

  Widget _buildProfilePicture() {
    return Center(child: Icon(Icons.person, size: 50, color: Colors.white));
  }

  String _getGenderText(int gender, BuildContext context) {
    switch (gender) {
      case 1:
        return LanguageAwareStringHelper.getCurrent(context, "male");
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "female");
      default:
        return LanguageAwareStringHelper.getCurrent(context, "other");
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
    final url = "tel:$phoneNumber";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(context, "error"),
        );
      }
    } catch (e) {
      ToastTheme.showError(
        context,
        message: LanguageAwareStringHelper.getCurrent(context, "error"),
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
        return LanguageAwareStringHelper.getCurrent(context, "very_messy");
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "messy");
      case 3:
        return LanguageAwareStringHelper.getCurrent(context, "average");
      case 4:
        return LanguageAwareStringHelper.getCurrent(context, "clean");
      case 5:
        return LanguageAwareStringHelper.getCurrent(context, "very_clean");
      default:
        return value.toString();
    }
  }

  String _getNoiseLevelText(int value, BuildContext context) {
    switch (value) {
      case 1:
        return LanguageAwareStringHelper.getCurrent(context, "very_quiet");
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "quiet");
      case 3:
        return LanguageAwareStringHelper.getCurrent(context, "average");
      case 4:
        return LanguageAwareStringHelper.getCurrent(context, "loud");
      case 5:
        return LanguageAwareStringHelper.getCurrent(context, "very_loud");
      default:
        return value.toString();
    }
  }

  String _getSociabilityText(int value, BuildContext context) {
    switch (value) {
      case 1:
        return LanguageAwareStringHelper.getCurrent(
          context,
          "very_introverted",
        );
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "introverted");
      case 3:
        return LanguageAwareStringHelper.getCurrent(context, "balanced");
      case 4:
        return LanguageAwareStringHelper.getCurrent(context, "extroverted");
      case 5:
        return LanguageAwareStringHelper.getCurrent(
          context,
          "very_extroverted",
        );
      default:
        return value.toString();
    }
  }

  String _getSmokingPreferenceText(String value, BuildContext context) {
    switch (value) {
      case "non-smoker":
        return LanguageAwareStringHelper.getCurrent(context, "non_smoker");
      case "occasional":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "occasional_smoker",
        );
      case "regular":
        return LanguageAwareStringHelper.getCurrent(context, "regular_smoker");
      default:
        return value;
    }
  }

  String _getAlcoholPreferenceText(String value, BuildContext context) {
    switch (value) {
      case "non-drinker":
        return LanguageAwareStringHelper.getCurrent(context, "non_drinker");
      case "occasional":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "occasional_drinker",
        );
      case "regular":
        return LanguageAwareStringHelper.getCurrent(context, "regular_drinker");
      default:
        return value;
    }
  }


  String _getTimePreferenceText(String value, BuildContext context) {
    switch (value) {
      case "morning":
        return LanguageAwareStringHelper.getCurrent(context, "morning");
      case "evening":
        return LanguageAwareStringHelper.getCurrent(context, "evening");
      case "night":
        return LanguageAwareStringHelper.getCurrent(context, "night");
      default:
        return value;
    }
  }
}
