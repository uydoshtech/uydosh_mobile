import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "dart:async";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/admin_feature_flags_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
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
class ListingDetailCompatibilitySection extends StatefulWidget {
  const ListingDetailCompatibilitySection({
    required this.listingDetail,
    required this.scrollController,
    required this.sectionKey,
    required this.compatibilityPercent,
    required this.isLoadingCompatibility,
    required this.compatibilityError,
    required this.matches,
    required this.differences,
    required this.telegramHandle,
    required this.phoneNumber,
    required this.onTelegram,
    required this.onPhone,
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
  final String? telegramHandle;
  final String? phoneNumber;
  final VoidCallback? onTelegram;
  final VoidCallback? onPhone;
  final VoidCallback onViewProfile;
  final VoidCallback onCompleteProfile;

  @override
  State<ListingDetailCompatibilitySection> createState() =>
      _ListingDetailCompatibilitySectionState();
}

class _ListingDetailCompatibilitySectionState
    extends State<ListingDetailCompatibilitySection> {
  Timer? _scrollIntoViewTimer;

  @override
  void dispose() {
    _scrollIntoViewTimer?.cancel();
    super.dispose();
  }

  static void _maybeAnimateScrollIntoView(
    BuildContext ctx, {
    required double alignment,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    final scrollable = Scrollable.maybeOf(ctx);
    final position = scrollable?.position;
    if (position == null) return;

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;

    final target = viewport
        .getOffsetToReveal(renderObject, alignment)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((target - position.pixels).abs() < 8) return;
    position.animateTo(target, duration: duration, curve: curve);
  }

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
      case "same_region":
      case "region":
        return Icons.location_on;
      case "language":
        return CupertinoIcons.globe;
      case "same_university":
      case "both_students":
      case "university":
        return Icons.school;
      default:
        return Icons.info_outline;
    }
  }

  String _formatUzbekPhoneDisplay(String raw) {
    final d = raw.replaceAll(RegExp(r"\D"), "");
    // Handle +998XXXXXXXXX, 998XXXXXXXXX, or 9XXXXXXXX
    String? nine;
    if (d.startsWith("998") && d.length >= 12) {
      final rest = d.substring(3);
      if (rest.length >= 9 &&
          RegExp(r"^9[0134679]\d{7}$").hasMatch(rest.substring(0, 9))) {
        nine = rest.substring(0, 9);
      }
    } else if (d.startsWith("9") &&
        d.length >= 9 &&
        RegExp(r"^9[0134679]\d{7}$").hasMatch(d.substring(0, 9))) {
      nine = d.substring(0, 9);
    } else if (d.length == 9 && RegExp(r"^9[0134679]\d{7}$").hasMatch(d)) {
      nine = d;
    } else if (d.length > 9) {
      final m = RegExp(r"(9[0134679]\d{7})$").firstMatch(d);
      nine = m?.group(1);
    }

    if (nine == null || nine.length != 9) return raw.trim();
    return "+998 ${nine.substring(0, 2)} ${nine.substring(2, 5)} "
        "${nine.substring(5, 7)} ${nine.substring(7, 9)}";
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
    if (widget.compatibilityPercent == null) return _getDescriptionTextColor();
    if (widget.compatibilityPercent! >= 80) return AppColors.success;
    if (widget.compatibilityPercent! >= 60) return AppColors.warning;
    return AppColors.error;
  }

  void _onExpansionChanged(bool isExpanded) {
    HapticFeedbackUtils.impact();
    if (!isExpanded) return;

    // Measure the 350ms from a settled layout (after the tap's frame has
    // flushed), matching the pattern in [ListingDetailMapSection] that fixed
    // the same scroll-jitter there. Starting the Timer mid-frame and then
    // awaiting `endOfFrame` inside it schedules an extra frame that shifts
    // layout *between* our target calculation and the scroll animation,
    // producing the visible "up then back down" jerk.
    //
    // Cancelling the pending Timer still protects against rapid
    // expand/collapse queuing multiple scroll adjustments.
    _scrollIntoViewTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollIntoViewTimer = Timer(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        final ctx = widget.sectionKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        _maybeAnimateScrollIntoView(ctx, alignment: 0.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AdminFeatureFlagsState().ensureLoaded();

    final isAuthenticated = AuthenticationState().isAuthenticated;
    final isOwner = UserListingState().isOwner(widget.listingDetail.user.id);

    if (isOwner) {
      return const SizedBox.shrink();
    }

    final percentText = widget.compatibilityPercent == null
        ? null
        : AppStrings.getWithParams(
            "compatibility_match_percentage",
            LanguageState().currentLanguage,
            params: {"percent": widget.compatibilityPercent!.toString()},
          );
    final headerPercentText = widget.compatibilityPercent == null
        ? L10n.get("na")
        : "${widget.compatibilityPercent}%";

    final isProfileComplete = ProfileCompletionState().isProfileComplete;

    final chevronColor = ListingDetailThemeHelper.locationTextColor;

    return ListingDetailTileShell(
      key: widget.sectionKey,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          initiallyExpanded: !isAuthenticated || !isProfileComplete,
          onExpansionChanged: _onExpansionChanged,
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
          iconColor: chevronColor,
          collapsedIconColor: chevronColor,
          title: Row(
            children: [
              ThemeIcon(
                ThemeState().isBlueTheme
                    ? CupertinoIcons.group_solid
                    : CupertinoIcons.group,
                size: 24,
                color: ThemeState().isBlueTheme
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
            else if (widget.isLoadingCompatibility)
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
            else if (widget.compatibilityError != null || percentText == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UydoshLinkButton(
                    text: L10n.get("complete_profile"),
                    onPressed: widget.onCompleteProfile,
                    color: _getIconColor(),
                    outlined: true,
                  ),
                ],
              )
            else
              ListenableBuilder(
                listenable: AdminFeatureFlagsState(),
                builder: (context, _) {
                  final showContacts =
                      AdminFeatureFlagsState().showListingContacts;
                  final hasPhone = showContacts &&
                      (widget.phoneNumber?.trim().isNotEmpty ?? false) &&
                      widget.onPhone != null;
                  final phoneDisplay =
                      hasPhone
                          ? _formatUzbekPhoneDisplay(widget.phoneNumber!)
                          : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.matches.isNotEmpty) ...[
                        Text(
                          L10n.get("compatibility_matches"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getLocationTextColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.matches.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemeIcon(
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
                      if (widget.differences.isNotEmpty) ...[
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
                        ...widget.differences.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemeIcon(
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
                                          text:
                                              "${item.label}: ${item.currentText} ",
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: ThemeIcon(
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
                      if (widget.matches.isEmpty && widget.differences.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UydoshLinkButton(
                              text: L10n.get("complete_profile"),
                              onPressed: widget.onCompleteProfile,
                              color: _getIconColor(),
                              outlined: true,
                            ),
                          ],
                        ),
                      // Telegram / in-app chat CTAs live in the sticky
                      // [ListingDetailContactActionBar] at the bottom of the
                      // screen (always reachable). Phone stays here because
                      // it's a compat-adjacent conditional contact channel
                      // (gated by admin flag + handle presence) and it's the
                      // only inline contact we still surface in-section.
                      if (hasPhone) ...[
                        const SizedBox(height: 16),
                        GhostButton(
                          onPressed: () {
                            HapticFeedbackUtils.impact();
                            widget.onPhone?.call();
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          borderWidth: 1.5,
                          borderColor: _getIconColor(),
                          textColor: _getDescriptionTextColor(),
                          iconColor: _getIconColor(),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ThemeIcon(
                                Icons.phone,
                                size: 18,
                                color: _getIconColor(),
                              ),
                              const SizedBox(width: 8),
                              Text(phoneDisplay ?? L10n.get("contact_user")),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedbackUtils.impact();
                            widget.onViewProfile();
                          },
                          icon: ThemeIcon(
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
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
