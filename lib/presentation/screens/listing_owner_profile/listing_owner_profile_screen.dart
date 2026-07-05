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
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/common_friend.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
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
    required this.isFollowing,
    required this.isFollowLoading,
    required this.commonFriends,
    required this.commonFriendsTotal,
    required this.canFollow,
  });
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;
  final bool isFollowing;
  final bool isFollowLoading;
  final List<CommonFriend> commonFriends;
  final int commonFriendsTotal;
  final bool canFollow;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ListingOwnerProfileData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.profile?.id == profile?.id &&
        other.isFollowing == isFollowing &&
        other.isFollowLoading == isFollowLoading &&
        other.commonFriendsTotal == commonFriendsTotal &&
        other.canFollow == canFollow;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        (profile?.id ?? 0).hashCode ^
        isFollowing.hashCode ^
        isFollowLoading.hashCode ^
        commonFriendsTotal.hashCode ^
        canFollow.hashCode;
  }
}

class ListingOwnerProfileScreen extends StatefulWidget {
  const ListingOwnerProfileScreen({
    required this.userId,
    super.key,
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
    getIt<AppAnalyticsService>()
        .logScreenView(screenName: "listing_owner_profile");
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
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ) ??
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
                _getPrimaryColor(),
            foregroundColor:
                Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
            elevation: 0,
          ),
          body: BlocSelector<ListingOwnerProfileBloc, ListingOwnerProfileState,
              _ListingOwnerProfileData>(
            selector: (state) => state.map(
              initial: (_) => const _ListingOwnerProfileData(
                isLoading: true,
                hasError: false,
                errorMessage: "",
                profile: null,
                isFollowing: false,
                isFollowLoading: false,
                commonFriends: [],
                commonFriendsTotal: 0,
                canFollow: false,
              ),
              loading: (_) => const _ListingOwnerProfileData(
                isLoading: true,
                hasError: false,
                errorMessage: "",
                profile: null,
                isFollowing: false,
                isFollowLoading: false,
                commonFriends: [],
                commonFriendsTotal: 0,
                canFollow: false,
              ),
              loaded: (loadedState) => _ListingOwnerProfileData(
                isLoading: false,
                hasError: false,
                errorMessage: "",
                profile: loadedState.profile,
                isFollowing: loadedState.isFollowing,
                isFollowLoading: loadedState.isFollowLoading,
                commonFriends: loadedState.commonFriends,
                commonFriendsTotal: loadedState.commonFriendsTotal,
                canFollow: loadedState.canFollow,
              ),
              error: (errorState) => _ListingOwnerProfileData(
                isLoading: false,
                hasError: true,
                errorMessage: errorState.message,
                profile: null,
                isFollowing: false,
                isFollowLoading: false,
                commonFriends: [],
                commonFriendsTotal: 0,
                canFollow: false,
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

              return _buildProfileContent(
                data.profile!,
                isFollowing: data.isFollowing,
                isFollowLoading: data.isFollowLoading,
                commonFriends: data.commonFriends,
                commonFriendsTotal: data.commonFriendsTotal,
                canFollow: data.canFollow,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(
    UserProfile profile, {
    required bool isFollowing,
    required bool isFollowLoading,
    required List<CommonFriend> commonFriends,
    required int commonFriendsTotal,
    required bool canFollow,
  }) {
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

              if (canFollow) ...[
                const SizedBox(height: 16),
                _buildFollowButton(
                  isFollowing: isFollowing,
                  isLoading: isFollowLoading,
                ),
              ],

              if (commonFriendsTotal > 0) ...[
                const SizedBox(height: 16),
                _buildCommonFriendsSection(
                  context,
                  commonFriends: commonFriends,
                  total: commonFriendsTotal,
                ),
              ],

              const SizedBox(height: 24),

              // Merged Profile Information Card
              ListingDetailTileShell(
                useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
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
                                    LanguageDisplayHelper
                                        .getLocalizedLanguageName(
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
                                        color: index < profile.rating!
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
                  useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
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
                            value: profile.employed!
                                ? L10n.get("yes")
                                : L10n.get("no"),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Wake-up / sleep pair
                        if (profile.wakeupTime != null ||
                            profile.sleepTime != null) ...[
                          _buildProfileFieldPair(
                            first: profile.wakeupTime == null
                                ? null
                                : (
                                    icon: Icons.wb_sunny,
                                    label: L10n.get("wakeup_time"),
                                    value: _getTimePreferenceText(
                                      profile.wakeupTime!,
                                      context,
                                    ),
                                  ),
                            second: profile.sleepTime == null
                                ? null
                                : (
                                    icon: Icons.bedtime,
                                    label: L10n.get("sleep_time"),
                                    value: _getTimePreferenceText(
                                      profile.sleepTime!,
                                      context,
                                    ),
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
                            value: profile.guestsAllowed!
                                ? L10n.get("yes")
                                : L10n.get("no"),
                            context: context,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Smoking / alcohol pair
                        if (profile.smokingPreference != null ||
                            profile.alcoholPreference != null) ...[
                          _buildProfileFieldPair(
                            first: profile.smokingPreference == null
                                ? null
                                : (
                                    icon: Icons.smoking_rooms,
                                    label: L10n.get("smoking_preference"),
                                    value: _getSmokingPreferenceText(
                                      profile.smokingPreference!,
                                      context,
                                    ),
                                  ),
                            second: profile.alcoholPreference == null
                                ? null
                                : (
                                    icon: Icons.local_bar,
                                    label: L10n.get("alcohol_preference"),
                                    value: _getAlcoholPreferenceText(
                                      profile.alcoholPreference!,
                                      context,
                                    ),
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
                            value: profile.cookingHabits!
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

  Widget _buildFollowButton({
    required bool isFollowing,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (isFollowing) {
      return Center(
        child: GhostButtonFactory.iconText(
          onPressed: () {
            context.read<ListingOwnerProfileBloc>().add(
                  ListingOwnerProfileEvent.toggleFollow(userId: widget.userId),
                );
          },
          icon: Icons.person_remove_outlined,
          text: L10n.get("following"),
          neumorphicSoftUi: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }

    return Center(
      child: PrimaryButtonFactory.iconText(
        onPressed: () {
          context.read<ListingOwnerProfileBloc>().add(
                ListingOwnerProfileEvent.toggleFollow(userId: widget.userId),
              );
        },
        icon: Icons.person_add_outlined,
        text: L10n.get("follow"),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildCommonFriendsSection(
    BuildContext context, {
    required List<CommonFriend> commonFriends,
    required int total,
  }) {
    return ListingDetailTileShell(
      useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ThemeIcon(Icons.people_outline, color: _getPrimaryColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    L10n.get("common_connections"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getPrimaryColor(),
                    ),
                  ),
                ),
                ThreeDElevatedSurface(
                  baseColor: Theme.of(context).colorScheme.surface,
                  useLiquidGlass: true,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    height: 32,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      total.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _getPrimaryColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < commonFriends.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _buildCommonFriendItem(commonFriends[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFriendItem(CommonFriend friend) {
    final (firstName, lastName) = StringUtils.splitFullName(
      friend.name ?? L10n.get("unknown"),
    );

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSmallCircularAvatar(friend.avatarUrl),
          const SizedBox(height: 4),
          _buildCommonFriendNameLine(firstName),
          if (lastName != null) _buildCommonFriendNameLine(lastName),
        ],
      ),
    );
  }

  Widget _buildCommonFriendNameLine(String name) {
    return Text(
      name,
      maxLines: 1,
      overflow: name.length < 12 ? TextOverflow.clip : TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, height: 1.2),
    );
  }

  Widget _buildSmallCircularAvatar(String? avatarUrl, {double size = 40}) {
    final theme = Theme.of(context);
    final resolvedUrl = resolveAvatarUrl(avatarUrl);
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: ThemeIcon(
        Icons.person,
        size: size * 0.5,
        color: _getPrimaryColor(),
      ),
    );

    if (resolvedUrl == null) {
      return fallback;
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: NetworkAvatarImage(
          imageUrl: resolvedUrl,
          size: size,
          fallback: fallback,
        ),
      ),
    );
  }

  Widget _buildTappableDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListingDetailTileShell(
      useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
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
              const ThemeIcon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
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
          gradient: hasAvatar
              ? null
              : ThreeDSurfaceStyle.surfaceGradient(context, faceBase),
          color: hasAvatar ? faceBase : null,
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          border: Border.all(
            color: onSurface.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: hasAvatar
              ? NetworkAvatarImage(
                  imageUrl: resolvedUrl,
                  size: diameter,
                  fallback: Center(
                    child: ThemeIcon(Icons.person, size: 50, color: glyphColor),
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
    return university.getLocalizedNameCapitalized(
      LanguageState().currentLanguage,
    );
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
    final cleanUsername = telegramUsername.startsWith("@")
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
        ThemeIcon(icon,
            size: 20, color: Theme.of(context).colorScheme.onSurface),
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

  Widget _buildProfileFieldPair({
    required ({IconData icon, String label, String value})? first,
    required ({IconData icon, String label, String value})? second,
    required BuildContext context,
  }) {
    if (first == null && second == null) return const SizedBox.shrink();

    if (first == null || second == null) {
      final item = first ?? second!;
      return _buildProfileField(
        icon: item.icon,
        label: item.label,
        value: item.value,
        context: context,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildProfileFieldPairItem(first, context)),
        const SizedBox(width: 12),
        Expanded(child: _buildProfileFieldPairItem(second, context)),
      ],
    );
  }

  Widget _buildProfileFieldPairItem(
    ({IconData icon, String label, String value}) item,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemeIcon(
          item.icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                item.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
