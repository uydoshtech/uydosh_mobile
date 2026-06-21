import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";

class GroupShortlistItemCard extends StatelessWidget {
  const GroupShortlistItemCard({
    required this.item,
    required this.listing,
    required this.fit,
    required this.isRemoving,
    required this.onOpen,
    required this.onRemove,
    this.groupListingDetail,
    this.isOwner = false,
    this.onContactLandlord,
    this.onDiscussInGroup,
    super.key,
  });

  final ListingGroupShortlistItem item;
  final Listing listing;
  final GroupHousingListingFit fit;
  final ListingDetail? groupListingDetail;
  final bool isOwner;
  final bool isRemoving;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback? onContactLandlord;
  final VoidCallback? onDiscussInGroup;

  static const double _thumbSize = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final openButtonBorderColor = isLightTheme ? Colors.black : Colors.white;
    final perPersonPrice = fit.formatPerPersonPriceLabel();
    final showDiscuss = onDiscussInGroup != null;
    final groupContextLabel = _groupContextLabel();
    final districtLabel = _districtChecklistLabel();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ListingThumbnail(listing: listing),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (groupContextLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          L10n.getWithParams(
                            "group_shortlist_saved_for_group_context",
                            params: {"label": groupContextLabel},
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (item.savedByName != null) ...[
                        const SizedBox(height: 4),
                        _SaverLine(
                          name: item.savedByName!,
                          avatarUrl: item.savedByAvatarUrl,
                        ),
                      ],
                      if (perPersonPrice != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          L10n.getWithParams(
                            "group_shortlist_price_per_person",
                            params: {"price": perPersonPrice},
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (fit.budget == GroupHousingBudgetFit.fits) ...[
                        const SizedBox(height: 4),
                        _BudgetStatusLine(
                          emoji: "✅",
                          label: L10n.get("group_shortlist_fits_budget_check"),
                          color: AppColors.successDark,
                        ),
                      ] else if (fit.budget == GroupHousingBudgetFit.above) ...[
                        const SizedBox(height: 4),
                        _BudgetStatusLine(
                          emoji: "⚠️",
                          label: L10n.get("group_shortlist_above_budget_check"),
                          color: AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._buildFitChecks(districtLabel),
            const SizedBox(height: 8),
            Text(
              L10n.get("group_shortlist_status_waiting"),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showDiscuss) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isRemoving ? null : onDiscussInGroup,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isLightTheme ? Colors.black87 : AppColors.textLight70,
                    side: BorderSide(color: openButtonBorderColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(L10n.get("group_shortlist_discuss_in_group")),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                TextButtonThemed(
                  onPressed: isRemoving
                      ? null
                      : () {
                          HapticFeedbackUtils.impact();
                          onOpen();
                        },
                  child: Text(L10n.get("group_shortlist_open_listing")),
                ),
                const Spacer(),
                TextButtonThemed(
                  onPressed: isRemoving
                      ? null
                      : () {
                          HapticFeedbackUtils.impact();
                          onRemove();
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: isRemoving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(L10n.get("group_shortlist_remove")),
                ),
              ],
            ),
            if (isOwner && onContactLandlord != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButtonThemed(
                  onPressed: isRemoving ? null : onContactLandlord,
                  child: Text(L10n.get("group_shortlist_contact_landlord")),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _groupContextLabel() {
    final detail = groupListingDetail;
    final parts = <String>[];

    final groupName = detail?.title.trim();
    if (groupName != null && groupName.isNotEmpty) {
      parts.add(groupName);
    }

    final groupSize = fit.groupSize;
    if (groupSize != null && groupSize > 0) {
      parts.add(
        L10n.getWithParams(
          "group_shortlist_group_size_label",
          params: {"count": groupSize.toString()},
        ),
      );
    }

    if (parts.isEmpty) return null;
    return parts.join(" • ");
  }

  String _districtChecklistLabel() {
    final locationLabel = _localizedLocationLabel(listing);
    if (locationLabel.isEmpty) {
      return L10n.get("group_shortlist_fit_district_unspecified");
    }
    return L10n.getWithParams(
      "group_shortlist_fit_district_named",
      params: {"name": locationLabel},
    );
  }

  List<Widget> _buildFitChecks(String districtLabel) {
    final checks = <Widget>[];

    if (fit.budget != GroupHousingBudgetFit.unknown) {
      checks.add(
        _FitCheckRow(
          emoji: "💸",
          label: fit.budget == GroupHousingBudgetFit.fits
              ? L10n.get("group_shortlist_fit_budget_ok")
              : L10n.get("group_shortlist_fit_budget_above"),
          positive: fit.budget == GroupHousingBudgetFit.fits,
        ),
      );
    }

    final groupSize = fit.groupSize;
    if (groupSize != null && groupSize > 0) {
      checks.add(
        _FitCheckRow(
          emoji: "👥",
          label: L10n.getWithParams(
            "group_shortlist_fit_suitable_for_people",
            params: {"count": groupSize.toString()},
          ),
          positive: true,
        ),
      );
    }

    checks.add(
      _FitCheckRow(
        emoji: "📍",
        label: districtLabel,
        positive: fit.location != GroupHousingLocationFit.different,
      ),
    );

    return checks;
  }

  static String _localizedLocationLabel(Listing listing) {
    final location = listing.location;
    if (location == null) {
      final station = listing.subwayStation;
      if (station == null) return "";
      return _localizedName(
        nameUz: station.nameUz,
        nameRu: station.nameRu,
        nameEn: station.nameEn,
      );
    }
    return _localizedName(
      nameUz: location.nameUz,
      nameRu: location.nameRu,
      nameEn: location.nameEn,
      shortNameUz: location.shortNameUz,
      shortNameRu: location.shortNameRu,
      shortNameEn: location.shortNameEn,
    );
  }

  static String _localizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    String? shortNameUz,
    String? shortNameRu,
    String? shortNameEn,
  }) {
    switch (L10n.currentLanguage) {
      case "ru":
        return shortNameRu ?? nameRu ?? nameEn ?? nameUz ?? "";
      case "uz":
        return shortNameUz ?? nameUz ?? nameRu ?? nameEn ?? "";
      default:
        return shortNameEn ?? nameEn ?? nameRu ?? nameUz ?? "";
    }
  }
}

class _BudgetStatusLine extends StatelessWidget {
  const _BudgetStatusLine({
    required this.emoji,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      "$emoji $label",
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ListingThumbnail extends StatelessWidget {
  const _ListingThumbnail({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photos = listing.photos;
    final photoUrl = _primaryPhotoUrl(photos);

    Widget child;
    if (photoUrl != null) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final decodePx = (GroupShortlistItemCard._thumbSize * dpr).round();
      child = Image(
        image: CachedNetworkImageProvider(
          EnvironmentUtil.hostedImageUrl(photoUrl),
          maxWidth: decodePx,
          maxHeight: decodePx,
        ),
        width: GroupShortlistItemCard._thumbSize,
        height: GroupShortlistItemCard._thumbSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(scheme),
      );
    } else {
      child = _placeholder(scheme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: GroupShortlistItemCard._thumbSize,
        height: GroupShortlistItemCard._thumbSize,
        child: child,
      ),
    );
  }

  static String? _primaryPhotoUrl(List<Photo>? photos) {
    if (photos == null || photos.isEmpty) return null;
    for (final photo in photos) {
      if (photo.isPrimary) return photo.photoUrl;
    }
    return photos.first.photoUrl;
  }

  Widget _placeholder(ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.home_outlined,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _SaverLine extends StatelessWidget {
  const _SaverLine({
    required this.name,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.extractInitials(name);

    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: ChatAvatar(
            isCurrentUser: false,
            initials: initials.isEmpty ? null : initials,
            avatarUrl: avatarUrl,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _FitCheckRow extends StatelessWidget {
  const _FitCheckRow({
    required this.emoji,
    required this.label,
    required this.positive,
  });

  final String emoji;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? Theme.of(context).colorScheme.onSurface
        : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "$emoji $label",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
      ),
    );
  }
}
