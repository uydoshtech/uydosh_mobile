import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

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
        compatibilityPercent == null ? "—" : "$compatibilityPercent%";

    return Card(
      key: sectionKey,
      child: ExpansionTile(
        onExpansionChanged: (isExpanded) {
          HapticFeedbackUtils.impact();
          if (!isExpanded) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 250), () {
              if (!scrollController.hasClients) return;
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
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
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "compatibility_title",
                ),
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
              LanguageAwareStringHelper.getCurrent(
                context,
                "compatibility_sign_in",
              ),
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
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "compatibility_calculating",
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getDescriptionTextColor(),
                  ),
                ),
              ],
            )
          else if (compatibilityError != null || percentText == null)
            Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "compatibility_unavailable",
              ),
              style: TextStyle(
                fontSize: 14,
                color: _getDescriptionTextColor(),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (matches.isNotEmpty) ...[
                  Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "compatibility_matches",
                    ),
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
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "compatibility_differences",
                    ),
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
                  Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "compatibility_unavailable",
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getDescriptionTextColor(),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
