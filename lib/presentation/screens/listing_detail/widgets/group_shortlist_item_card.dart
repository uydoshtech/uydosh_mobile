import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";

TextStyle _plusOneFontSize(BuildContext context, TextStyle? style) {
  final fallbackStyle = DefaultTextStyle.of(context).style;
  final baseStyle = style ?? fallbackStyle;
  final baseFontSize = baseStyle.fontSize ?? fallbackStyle.fontSize ?? 14;
  return baseStyle.copyWith(fontSize: baseFontSize + 1);
}

class GroupShortlistItemCard extends StatelessWidget {
  const GroupShortlistItemCard({
    required this.item,
    required this.listing,
    required this.fit,
    required this.isRemoving,
    required this.onOpen,
    required this.onRemove,
    this.ownerName,
    this.ownerAvatarUrl,
    this.isOwner = false,
    this.currentUserId,
    this.onRate,
    this.onContactLandlord,
    this.onDiscussInGroup,
    super.key,
  });

  final ListingGroupShortlistItem item;
  final Listing listing;
  final GroupHousingListingFit fit;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final bool isOwner;
  final bool isRemoving;
  final int? currentUserId;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final ValueChanged<int>? onRate;
  final VoidCallback? onContactLandlord;
  final VoidCallback? onDiscussInGroup;

  static const double _thumbSize = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final openButtonBorderColor = isLightTheme ? Colors.black : Colors.white;
    final actionButtonForegroundColor =
        isLightTheme ? Colors.black87 : AppColors.textLight70;
    final actionButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: actionButtonForegroundColor,
      side: BorderSide(color: openButtonBorderColor),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
    final removeButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.error,
      side: BorderSide(color: theme.colorScheme.error),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
    final perPersonPrice = fit.formatPerPersonPriceLabel();
    final showDiscuss = onDiscussInGroup != null;
    final rating = item.rating;

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
                        style: _plusOneFontSize(
                          context,
                          theme.textTheme.titleSmall,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (ownerName != null || ownerAvatarUrl != null) ...[
                        const SizedBox(height: 4),
                        _OwnerLine(
                          name: ownerName,
                          avatarUrl: ownerAvatarUrl,
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
                          style: _plusOneFontSize(
                            context,
                            theme.textTheme.bodyMedium,
                          ).copyWith(
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
            ..._buildFitChecks(),
            if (rating != null && rating.participants.isNotEmpty) ...[
              const SizedBox(height: 8),
              _GroupRatingSection(
                rating: rating,
                currentUserId: currentUserId,
                onRate: onRate,
              ),
            ],
            if (showDiscuss) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isRemoving ? null : onDiscussInGroup,
                  style: actionButtonStyle,
                  icon: const Icon(Icons.forum_outlined, size: 20),
                  label: Text(
                    L10n.get("group_shortlist_discuss_in_group"),
                    style: _plusOneFontSize(
                      context,
                      theme.textTheme.labelLarge,
                    ).copyWith(height: 1.0),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRemoving
                        ? null
                        : () {
                            HapticFeedbackUtils.impact();
                            onOpen();
                          },
                    style: actionButtonStyle,
                    icon: const Icon(Icons.open_in_new, size: 20),
                    label: Text(
                      L10n.get("group_shortlist_open_listing"),
                      style: _plusOneFontSize(
                        context,
                        theme.textTheme.labelLarge,
                      ).copyWith(height: 1.0),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRemoving
                        ? null
                        : () {
                            HapticFeedbackUtils.impact();
                            onRemove();
                          },
                    style: removeButtonStyle,
                    icon: isRemoving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, size: 20),
                    label: Text(
                      L10n.get("group_shortlist_remove"),
                      style: _plusOneFontSize(
                        context,
                        theme.textTheme.labelLarge,
                      ).copyWith(height: 1.0),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isOwner && onContactLandlord != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isRemoving ? null : onContactLandlord,
                  style: actionButtonStyle,
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: Text(
                    L10n.get("group_shortlist_contact_landlord"),
                    style: _plusOneFontSize(
                      context,
                      theme.textTheme.labelLarge,
                    ).copyWith(height: 1.0),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFitChecks() {
    final checks = <Widget>[];

    if (fit.budget == GroupHousingBudgetFit.above) {
      checks.add(
        _FitCheckRow(
          emoji: "💸",
          label: L10n.get("group_shortlist_fit_budget_above"),
          positive: false,
        ),
      );
    }

    checks.add(_ListingLocationRows(listing: listing));

    return checks;
  }

  static String _localizedDistrictLabel(Listing listing) {
    final location = listing.location;
    if (location == null) return "";
    return _localizedName(
      nameUz: location.nameUz,
      nameRu: location.nameRu,
      nameEn: location.nameEn,
    );
  }

  static String _localizedStationLabel(Listing listing) {
    final station = listing.subwayStation;
    if (station == null) return "";
    final stationName = _localizedName(
      nameUz: station.nameUz,
      nameRu: station.nameRu,
      nameEn: station.nameEn,
    );
    return MetroCache.formatStationLabel(stationName, L10n.currentLanguage);
  }

  static Color _stationLineColor(Listing listing) {
    final line = listing.subwayStation?.line;
    if (line == null) return AppColors.error;
    return ListingDetailThemeHelper.lineColor(line);
  }

  static String _fallbackLocationLabel() {
    return L10n.get("group_shortlist_fit_district_unspecified");
  }

  static String districtLabelFor(Listing listing) {
    return _localizedDistrictLabel(listing);
  }

  static String stationLabelFor(Listing listing) {
    return _localizedStationLabel(listing);
  }

  static Color stationLineColorFor(Listing listing) {
    return _stationLineColor(listing);
  }

  static bool hasAnyPlaceLabel(Listing listing) {
    return _localizedDistrictLabel(listing).isNotEmpty ||
        _localizedStationLabel(listing).isNotEmpty;
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
      style: _plusOneFontSize(
        context,
        Theme.of(context).textTheme.bodySmall,
      ).copyWith(
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

  static const double _avatarSize = 24;

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.extractInitials(name);
    final prefix = L10n.get("group_shortlist_saved_by").trim();
    final suffix = L10n.get("group_shortlist_saved_by_suffix").trim();
    final textStyle = _plusOneFontSize(
      context,
      Theme.of(context).textTheme.bodySmall,
    ).copyWith(
      fontWeight: FontWeight.w700,
    );

    final textParts = <String>[
      if (prefix.isNotEmpty) prefix,
      name,
      if (suffix.isNotEmpty) suffix,
    ];

    return Row(
      children: [
        SizedBox(
          width: _avatarSize,
          height: _avatarSize,
          child: ChatAvatar(
            isCurrentUser: false,
            initials: initials.isEmpty ? null : initials,
            avatarUrl: avatarUrl,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            textParts.join(" "),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class _OwnerLine extends StatelessWidget {
  const _OwnerLine({
    required this.name,
    this.avatarUrl,
  });

  static const double _avatarSize = _SaverLine._avatarSize;

  final String? name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedName = name?.trim();
    final hasName = trimmedName != null && trimmedName.isNotEmpty;
    final authorLabel = L10n.get(
      "listing_author",
      fallback: L10n.get("author"),
    );
    final displayName = hasName ? "$authorLabel: $trimmedName" : authorLabel;
    final initials = StringUtils.extractInitials(hasName ? trimmedName : "");

    return Row(
      children: [
        SizedBox(
          width: _avatarSize,
          height: _avatarSize,
          child: ChatAvatar(
            isCurrentUser: false,
            initials: initials.isEmpty ? null : initials,
            avatarUrl: avatarUrl,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _plusOneFontSize(
              context,
              Theme.of(context).textTheme.bodySmall,
            ).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
    final color =
        positive ? Theme.of(context).colorScheme.onSurface : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "$emoji $label",
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ListingLocationRows extends StatelessWidget {
  const _ListingLocationRows({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final districtLabel = GroupShortlistItemCard.districtLabelFor(listing);
    final stationLabel = GroupShortlistItemCard.stationLabelFor(listing);
    final hasPlaceLabel = GroupShortlistItemCard.hasAnyPlaceLabel(listing);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (districtLabel.isNotEmpty)
            _PlaceLabelRow(
              icon: Icons.location_on,
              iconColor: Colors.red,
              label: districtLabel,
            ),
          if (!hasPlaceLabel)
            _PlaceLabelRow(
              icon: Icons.location_on,
              iconColor: Colors.red,
              label: GroupShortlistItemCard._fallbackLocationLabel(),
            ),
          if (stationLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PlaceLabelRow(
              icon: Icons.train,
              iconColor: GroupShortlistItemCard.stationLineColorFor(listing),
              label: stationLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlaceLabelRow extends StatelessWidget {
  const _PlaceLabelRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: ListingDetailThemeHelper.locationTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupRatingSection extends StatelessWidget {
  const _GroupRatingSection({
    required this.rating,
    this.currentUserId,
    this.onRate,
  });

  final ListingGroupShortlistRating rating;
  final int? currentUserId;
  final ValueChanged<int>? onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRating = rating.count > 0 && rating.average != null;
    final averageText = rating.average?.toStringAsFixed(1);
    final countText = hasRating
        ? L10n.getWithParams(
            "group_shortlist_rating_count_summary",
            params: {
              "count": rating.count.toString(),
            },
          )
        : null;
    final headerStyle = _plusOneFontSize(
      context,
      theme.textTheme.bodySmall,
    ).copyWith(
      fontWeight: FontWeight.w700,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRating)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "${L10n.get("group_shortlist_group_rating")} · ",
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 14,
                    ),
                  ),
                  TextSpan(text: " $averageText · $countText"),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: headerStyle,
            )
          else
            Text(
              "${L10n.get("group_shortlist_group_rating")} · ${L10n.get("group_shortlist_no_ratings")}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: headerStyle,
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: rating.participants.map((participant) {
              final canEdit = currentUserId != null &&
                  participant.userId == currentUserId &&
                  participant.stars != null &&
                  onRate != null;
              return _ParticipantRatingChip(
                participant: participant,
                isCurrentUser: canEdit,
                onTap: canEdit ? () => onRate!(participant.stars!) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ParticipantRatingChip extends StatelessWidget {
  const _ParticipantRatingChip({
    required this.participant,
    this.isCurrentUser = false,
    this.onTap,
  });

  final ListingGroupShortlistParticipantRating participant;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.extractInitials(participant.name);

    return Tooltip(
      message: participant.name,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: ChatAvatar(
                    isCurrentUser: isCurrentUser,
                    initials: initials.isEmpty ? null : initials,
                    avatarUrl: participant.avatarUrl,
                  ),
                ),
                const SizedBox(width: 4),
                _StaticStars(stars: participant.stars),
                if (onTap != null) ...[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticStars extends StatelessWidget {
  const _StaticStars({required this.stars});

  final int? stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        final filled = (stars ?? 0) >= value;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: filled
              ? AppColors.warning
              : Theme.of(context).colorScheme.onSurfaceVariant,
        );
      }),
    );
  }
}
