import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";

import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:cached_network_image/cached_network_image.dart";

// Data class for BlocSelector to reduce unnecessary rebuilds
class _ProfileScreenData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;

  const _ProfileScreenData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.profile,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ProfileScreenData &&
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _redirectedToProfileSetup = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CurrentUserProfileBloc(getIt<IUserProfileService>())
                ..add(const CurrentUserProfileEvent.fetchProfile()),
      child: BlocListener<CurrentUserProfileBloc, CurrentUserProfileState>(
        listener: (context, state) {
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
                        (_) => _ProfileScreenData(
                          isLoading: true,
                          hasError: false,
                          errorMessage: "",
                          profile: null,
                        ),
                    loading:
                        (_) => _ProfileScreenData(
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
                if (data.hasError &&
                    data.errorMessage == profileNotFoundErrorCode) {
                  return Scaffold(
                    body: CenteredHouseLoadingIndicator(
                      text: LanguageAwareStringHelper.getCurrent(
                        context,
                        "loading",
                      ),
                    ),
                  );
                }
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      LanguageAwareStringHelper.getCurrent(context, "profile"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      ActionDropdownMenu(
                        items: _buildActionMenuItems(context),
                        icon: Icons.more_vert,
                        tooltip: LanguageAwareStringHelper.getCurrent(
                          context,
                          "menu_settings",
                        ),
                        padding: const EdgeInsets.only(right: 16.0),
                      ),
                    ],
                  ),
                  body:
                      data.isLoading
                          ? CenteredHouseLoadingIndicator(
                            text: LanguageAwareStringHelper.getCurrent(
                              context,
                              "loading",
                            ),
                          )
                          : data.hasError
                          ? _buildErrorState(data.errorMessage, context)
                          : _buildProfileContent(data.profile!),
                );
              },
            );
          },
        ),
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
              // Profile Avatar Section
              Center(
                child: Column(
                  children: [
                    Container(
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile completion indicator
              _buildProfileCompletionCard(profile, context),
              const SizedBox(height: 16),

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
                      // Profile Name
                      if (profile.name != null && profile.name!.isNotEmpty) ...[
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
                                    LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "name",
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    profile.name!,
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
                                    LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "gender",
                                    ),
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
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "im_from",
                                  ),
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
                                      : LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "not_specified",
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

                      // University field
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
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "university",
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
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
                                  LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "about_me",
                                  ),
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
                                      : LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "not_specified",
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
                                      LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "telegram",
                                      ),
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
                                          : LanguageAwareStringHelper.getCurrent(
                                            context,
                                            "not_specified",
                                          ),
                                      style: TextStyle(
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
                                    LanguageAwareStringHelper.getCurrent(
                                      context,
                                      "rating",
                                    ),
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
                ),
              ),

              // New Profile Fields Section
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
                            fontSize: 16,
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

                      ],
                    ),
                  ),
                ),
              ],

              // Logout Button Section
              const SizedBox(height: 20),
              _buildLogoutButton(context),
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
            LanguageAwareStringHelper.getCurrent(
              context,
              "error_loading_profile",
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LanguageAwareStringHelper.getCurrent(context, "error_generic"),
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
            child: Text(LanguageAwareStringHelper.getCurrent(context, "retry")),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(
    UserProfile profile,
    BuildContext context,
  ) {
    final completionPercent = _calculateProfileCompletionPercent(profile);
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
                Expanded(
                  child: Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "profile_completion",
                    ),
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
              LanguageAwareStringHelper.getCurrent(
                context,
                "profile_completion_hint",
              ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTappableDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required BuildContext context,
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
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    if (currentUser?.photoURL != null) {
      // Show Google profile picture with theme border
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: currentUser!.photoURL!,
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
    } else {
      // Fallback to standard person icon with theme border
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1),
        ),
        child: const Icon(Icons.person, size: 50),
      );
    }
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
          padding: const EdgeInsets.all(16.0),
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
                  LanguageAwareStringHelper.getCurrent(context, "logout"),
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

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    CommonConfirmationDialogs.showLogoutConfirmation(
      context: context,
      onConfirm: () async {
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

  int _calculateProfileCompletionPercent(UserProfile profile) {
    const totalFields = 17;
    final completedFields = _countCompletedProfileFields(profile);
    return ((completedFields / totalFields) * 100).round();
  }

  int _countCompletedProfileFields(UserProfile profile) {
    var completedFields = 0;

    if (_hasText(profile.name)) completedFields++;
    if (profile.gender != null) completedFields++;
    if (profile.region != null) completedFields++;
    if (profile.university != null) completedFields++;
    if (_hasText(profile.aboutMe)) completedFields++;
    if (_hasText(profile.telegram)) completedFields++;
    if (profile.employed != null) completedFields++;
    if (profile.cleanliness != null) completedFields++;
    if (profile.noiseLevel != null) completedFields++;
    if (profile.sociability != null) completedFields++;
    if (profile.guestsAllowed != null) completedFields++;
    if (_hasText(profile.smokingPreference)) completedFields++;
    if (_hasText(profile.alcoholPreference)) completedFields++;
    if (profile.cookingHabits != null) completedFields++;
    if (profile.petsPreference != null) completedFields++;
    if (_hasText(profile.wakeupTime)) completedFields++;
    if (_hasText(profile.sleepTime)) completedFields++;

    return completedFields;
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
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
      // Edit Profile item (moved to first position)
      ActionMenuItem(
        value: "edit_profile",
        icon: Icons.edit,
        textKey: "edit_profile",
        onPressed: () async {
          try {
            // Get the current profile from the bloc
            final currentState = context.read<CurrentUserProfileBloc>().state;
            currentState.map(
              initial:
                  (_) => ToastTheme.showInfo(
                    context,
                    message: LanguageAwareStringHelper.getCurrent(
                      context,
                      "profile_not_loaded_yet",
                    ),
                  ),
              loading:
                  (_) => ToastTheme.showInfo(
                    context,
                    message: LanguageAwareStringHelper.getCurrent(
                      context,
                      "profile_still_loading",
                    ),
                  ),
              loaded: (loadedState) async {
                final profile = loadedState.profile;

                // Navigate to edit profile screen
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: profile),
                  ),
                );

                // Refresh profile if edit was successful
                if (result == true) {
                  logger.d("=== PROFILE EDIT SUCCESS ===");
                  logger.d(
                    "Edit profile returned true, refreshing profile data...",
                  );

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
              },
              error:
                  (errorState) => ToastTheme.showError(
                    context,
                    message: LanguageAwareStringHelper.getCurrent(
                      context,
                      "error_with_message",
                    ).replaceAll("{message}", errorState.message),
                  ),
            );
          } catch (e) {
            ToastTheme.showError(
              context,
              message: LanguageAwareStringHelper.getCurrent(
                context,
                "error_opening_edit_screen",
              ).replaceAll("{error}", e.toString()),
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
    ];
  }
}
