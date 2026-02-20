import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

/// Data class for a compatibility match (same value).
class CompatibilityMatch {
  const CompatibilityMatch({
    required this.labelKey,
    required this.label,
    required this.value,
  });

  final String labelKey;
  final String label;
  final String value;
}

/// Data class for a compatibility difference (user vs owner).
class CompatibilityDifference {
  const CompatibilityDifference({
    required this.labelKey,
    required this.label,
    required this.currentText,
    required this.ownerText,
  });

  final String labelKey;
  final String label;
  final String currentText;
  final String ownerText;
}

/// Compatibility section widget for listing detail screen.
/// Shows match percentage and expandable list of matches/differences.
class ListingDetailCompatibilitySection extends StatelessWidget {
  const ListingDetailCompatibilitySection({
    required this.listingDetail,
    required this.scrollController,
    required this.sectionKey,
    required this.compatibilityPercent,
    required this.isLoadingCompatibility,
    required this.compatibilityError,
    required this.matches,
    required this.differences,
  required this.onMessage,
  required this.onViewProfile,
  required this.onCompleteProfile,
  super.key,
});

  final ListingDetail listingDetail;
  final ScrollController scrollController;
  final GlobalKey sectionKey;
  final int? compatibilityPercent;
  final bool isLoadingCompatibility;
  final String? compatibilityError;
  final List<CompatibilityMatch> matches;
  final List<CompatibilityDifference> differences;
  final VoidCallback onMessage;
  final VoidCallback onViewProfile;
  final VoidCallback onCompleteProfile;

  static IconData _getLifestyleIcon(String labelKey) {
    switch (labelKey) {
      case "wakeup_time":
        return Icons.wb_sunny;
      case "sleep_time":
        return Icons.bedtime;
      case "employed":
        return Icons.work;
      case "cleanliness":
        return Icons.cleaning_services;
      case "noise_level":
        return Icons.volume_up;
      case "sociability":
        return Icons.people;
      case "guests_allowed":
        return Icons.group_add;
      case "smoking_preference":
        return Icons.smoking_rooms;
      case "alcohol_preference":
        return Icons.local_bar;
      case "cooking_habits":
        return Icons.restaurant;
      case "pets_preference":
        return Icons.pets;
      case "same_university":
      case "both_students":
      case "university":
        return Icons.school;
      default:
        return Icons.info_outline;
    }
  }

  Color _getDescriptionTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87;
    }
  }

  Color _getLocationTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87;
    }
  }

  Color _getIconColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else if (ThemeState().isLightTheme) {
      return Colors.black;
    } else {
      return AppColors.iconPrimary;
    }
  }

  Color _getCompatibilityPercentColor() {
    if (compatibilityPercent == null) return _getDescriptionTextColor();
    if (compatibilityPercent! >= 80) return AppColors.success;
    if (compatibilityPercent! >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = AuthenticationState().isAuthenticated;
    final isOwner = UserListingState().isOwner(listingDetail.user.id);

    if (isOwner) {
      return const SizedBox.shrink();
    }

    final percentText =
        compatibilityPercent == null
            ? null
            : AppStrings.getWithParams(
              "compatibility_match_percentage",
              LanguageState().currentLanguage,
              params: {"percent": compatibilityPercent!.toString()},
            );
    final headerPercentText =
        compatibilityPercent == null ? L10n.get("na") : "$compatibilityPercent%";

    final isProfileComplete = ProfileCompletionState().isProfileComplete;

    return Card(
      key: sectionKey,
      child: ExpansionTile(
        initiallyExpanded: !isAuthenticated || !isProfileComplete,
        onExpansionChanged: (isExpanded) {
          HapticFeedbackUtils.impact();
          if (!isExpanded) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 250), () {
              final context = sectionKey.currentContext;
              if (context != null) {
                Scrollable.ensureVisible(
                  context,
                  alignment: 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            });
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Icon(
              ThemeState().isBlueTheme
                  ? CupertinoIcons.group_solid
                  : CupertinoIcons.group,
              size: 24,
              color:
                  ThemeState().isBlueTheme
                      ? Colors.white
                      : ThemeState().isLightTheme
                      ? Colors.black
                      : _getIconColor(),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                L10n.get("compatibility_title"),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getDescriptionTextColor(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              headerPercentText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getCompatibilityPercentColor(),
              ),
            ),
          ],
        ),
        children: [
          if (!isAuthenticated)
            Text(
              L10n.get("compatibility_sign_in"),
              style: TextStyle(
                fontSize: 14,
                color: _getDescriptionTextColor(),
              ),
            )
          else if (isLoadingCompatibility)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _getIconColor(),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  L10n.get("compatibility_calculating"),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getDescriptionTextColor(),
                  ),
                ),
              ],
            )
          else if (compatibilityError != null || percentText == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UydoshLinkButton(
                  text: L10n.get("complete_profile"),
                  onPressed: onCompleteProfile,
                  color: _getIconColor(),
                  outlined: true,
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (matches.isNotEmpty) ...[
                  Text(
                    L10n.get("compatibility_matches"),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getLocationTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...matches.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getLifestyleIcon(item.labelKey),
                            size: 20,
                            color: _getDescriptionTextColor(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${item.label}: ${item.value}",
                              style: TextStyle(
                                fontSize: 14,
                                color: _getDescriptionTextColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (differences.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    L10n.get("compatibility_differences"),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getLocationTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...differences.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getLifestyleIcon(item.labelKey),
                            size: 20,
                            color: _getDescriptionTextColor(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getDescriptionTextColor(),
                                ),
                                children: [
                                  TextSpan(
                                    text: "${item.label}: ${item.currentText} ",
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.compare_arrows,
                                      size: 16,
                                      color: _getDescriptionTextColor(),
                                    ),
                                  ),
                                  TextSpan(text: " ${item.ownerText}"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (matches.isEmpty && differences.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UydoshLinkButton(
                        text: L10n.get("complete_profile"),
                        onPressed: onCompleteProfile,
                        color: _getIconColor(),
                        outlined: true,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedbackUtils.impact();
                          onMessage();
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: _getIconColor(),
                        ),
                        label: Text(
                          L10n.get("message"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getDescriptionTextColor(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: _getIconColor()),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedbackUtils.impact();
                          onViewProfile();
                        },
                        icon: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: _getIconColor(),
                        ),
                        label: Text(
                          L10n.get("view_profile"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getDescriptionTextColor(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: _getIconColor()),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
