import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/pets_preference_strings.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/telegram_sign_in_branded_button.dart";
import "package:uy_dosh/presentation/widgets/profile/linked_telegram_account_tile.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({
    required this.profile,
    required this.cachedGoogleDisplayName,
    required this.expandedSectionIndex,
    required this.onExpandedSectionChanged,
    required this.getLocalizedRegionName,
    required this.getLocalizedUniversityName,
    this.cachedTelegramPhotoUrl,
    this.telegramLinked,
    this.canUnbindTelegram = false,
    this.isLinkingTelegram = false,
    this.isUnlinkingTelegram = false,
    this.onLinkTelegram,
    this.onUnlinkTelegram,
    super.key,
  });

  final UserProfile profile;
  final String? cachedGoogleDisplayName;
  final String? cachedTelegramPhotoUrl;
  final int? expandedSectionIndex;
  final void Function(int? index) onExpandedSectionChanged;
  final String Function(UserProfileRegion region) getLocalizedRegionName;
  final String Function(UserProfileUniversity university)
      getLocalizedUniversityName;

  /// `null` while loading identity; `true` when Telegram auth is linked.
  final bool? telegramLinked;
  /// Whether the user has another sign-in method and can safely unlink Telegram.
  final bool canUnbindTelegram;
  final bool isLinkingTelegram;
  final bool isUnlinkingTelegram;
  final VoidCallback? onLinkTelegram;
  final VoidCallback? onUnlinkTelegram;

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

  Color _getLifestyleHeaderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          margin: EdgeInsets.zero,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: ListingDetailTileShell(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                HapticFeedbackUtils.impact();
                onExpandedSectionChanged(
                  expandedSectionIndex == 0 ? null : 0,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 12),
                child: Row(
                  children: [
                    ThemeIcon(
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
                      turns: expandedSectionIndex == 0 ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: ThemeIcon(
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
                child: expandedSectionIndex == 0
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
                            if (((profile.name ?? cachedGoogleDisplayName) ??
                                    "")
                                .isNotEmpty) ...[
                              _buildProfileFieldRow(
                                context,
                                icon: Icons.person,
                                label: L10n.get("name"),
                                value: profile.name ??
                                    cachedGoogleDisplayName ??
                                    "",
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (profile.gender != null) ...[
                              _buildProfileFieldRow(
                                context,
                                icon: _getGenderIcon(profile.gender!),
                                label: L10n.get("gender"),
                                value: _getGenderText(profile.gender!, context),
                              ),
                              const SizedBox(height: 24),
                            ],
                            _buildProfileFieldRow(
                              context,
                              icon: Icons.location_on,
                              label: L10n.get("im_from"),
                              value: profile.region != null
                                  ? getLocalizedRegionName(profile.region!)
                                  : L10n.get("not_specified"),
                            ),
                            const SizedBox(height: 24),
                            if (profile.university != null) ...[
                              _buildProfileFieldRow(
                                context,
                                icon: Icons.school,
                                label: L10n.get("university"),
                                value: getLocalizedUniversityName(
                                    profile.university!),
                              ),
                              const SizedBox(height: 24),
                            ],
                            _buildProfileFieldRow(
                              context,
                              icon: Icons.info_outline,
                              label: L10n.get("about_me"),
                              value: profile.aboutMe != null &&
                                      profile.aboutMe!.isNotEmpty
                                  ? profile.aboutMe!
                                  : L10n.get("not_specified"),
                            ),
                            const SizedBox(height: 24),
                            if (telegramLinked == true) ...[
                              LinkedTelegramAccountTile(
                                profile: profile,
                                cachedTelegramPhotoUrl: cachedTelegramPhotoUrl,
                              ),
                            ] else if (telegramLinked == false &&
                                onLinkTelegram != null) ...[
                              TelegramSignInBrandedButton(
                                label: L10n.get("link_telegram"),
                                onPressed: isLinkingTelegram ? null : onLinkTelegram,
                              ),
                            ],
                            if (telegramLinked == true &&
                                canUnbindTelegram &&
                                onUnlinkTelegram != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextButtonThemed(
                                  onPressed: isUnlinkingTelegram
                                      ? null
                                      : onUnlinkTelegram,
                                  attentionBorder: true,
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  child: isUnlinkingTelegram
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        )
                                      : Text(L10n.get("unlink_telegram")),
                                ),
                              ),
                            ],
                            if (profile.rating != null) ...[
                              const SizedBox(height: 24),
                              _buildRatingField(context),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
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
                  HapticFeedbackUtils.impact();
                  onExpandedSectionChanged(
                    expandedSectionIndex == 1 ? null : 1,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 12),
                  child: Row(
                    children: [
                      ThemeIcon(
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
                        turns: expandedSectionIndex == 1 ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: ThemeIcon(
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
                  child: expandedSectionIndex == 1
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
                              if (profile.employed != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.work,
                                  label: L10n.get("work"),
                                  value: profile.employed!
                                      ? L10n.get("yes")
                                      : L10n.get("no"),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.wakeupTime != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.wb_sunny,
                                  label: L10n.get("wakeup_time"),
                                  value: _getTimePreferenceText(
                                    profile.wakeupTime!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.sleepTime != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.bedtime,
                                  label: L10n.get("sleep_time"),
                                  value: _getTimePreferenceText(
                                    profile.sleepTime!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.cleanliness != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.cleaning_services,
                                  label: L10n.get("cleanliness"),
                                  value: _getCleanlinessText(
                                    profile.cleanliness!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.noiseLevel != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.volume_up,
                                  label: L10n.get("noise_level"),
                                  value: _getNoiseLevelText(
                                    profile.noiseLevel!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.sociability != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.people,
                                  label: L10n.get("sociability"),
                                  value: _getSociabilityText(
                                    profile.sociability!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.guestsAllowed != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.group_add,
                                  label: L10n.get("guests"),
                                  value: profile.guestsAllowed!
                                      ? L10n.get("yes")
                                      : L10n.get("no"),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.smokingPreference != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.smoking_rooms,
                                  label: L10n.get("smoking_preference"),
                                  value: _getSmokingPreferenceText(
                                    profile.smokingPreference!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.alcoholPreference != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.local_bar,
                                  label: L10n.get("alcohol_preference"),
                                  value: _getAlcoholPreferenceText(
                                    profile.alcoholPreference!,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.cookingHabits != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.restaurant,
                                  label: L10n.get("cooking_habits"),
                                  value: profile.cookingHabits!
                                      ? L10n.get("cook")
                                      : L10n.get("dont_cook"),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (profile.petsPreference != null) ...[
                                _buildProfileField(
                                  context,
                                  icon: Icons.pets,
                                  label: L10n.get("pets_preference"),
                                  value: localizedPetsPreference(
                                    profile.petsPreference!,
                                  ),
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
    );
  }

  Widget _buildProfileFieldRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        ThemeIcon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
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

  Widget _buildProfileField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
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

  Widget _buildRatingField(BuildContext context) {
    return Row(
      children: [
        ThemeIcon(
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return ThemeIcon(
                    Icons.star,
                    size: 19,
                    color: index < profile.rating!
                        ? Theme.of(context).colorScheme.onSurface
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
