import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_participant_avatar_badge.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Reusable card for a single [GigOffer] in any vertical list/feed.
///
/// Tapping the tile pushes [GigOfferDetailScreen] via the [GigNavigatorExtensions]
/// helper. Used by both the "Browse services" list and the inline feed on
/// the Services hub.
class GigOfferTile extends StatelessWidget {
  const GigOfferTile({required this.offer, super.key});

  final GigOffer offer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = offer.category?.localizedName(language) ?? "";
    final photo = offer.primaryPhotoUrl();

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        onTap: () {
          HapticFeedbackUtils.lightImpact();
          context.pushGigOfferDetail(offer.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: photo != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  EnvironmentUtil.hostedImageUrl(photo),
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: scheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            )
                          : Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.handyman_outlined,
                                color: scheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (categoryName.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (offer.category?.icon != null) ...[
                                  Icon(
                                    offer.category!.icon,
                                    size: 14,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    categoryName.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.72),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 6),
                          Text(
                            offer.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListingPaymentsOutlineBadge(
                            label: _formatPrice(offer),
                          ),
                          if (_gigOfferTileHasRating(offer)) ...[
                            const SizedBox(height: 8),
                            _GigOfferTileRatingStars(
                              rating: offer.providerRatingAvg,
                              reviewCount: offer.providerRatingCount ?? 0,
                              scheme: scheme,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IgnorePointer(
                  child: GigParticipantAvatarBadge(
                    avatarUrl: offer.providerAvatarUrl,
                    displayName: offer.providerDisplayName,
                    ringColor: scheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(GigOffer o) {
    final params = {"amount": o.price.toString(), "currency": o.currencyCode};
    switch (o.pricingType) {
      case GigPricingType.hourly:
        return L10n.getWithParams("gigs_price_per_hour", params: params);
      case GigPricingType.perUnit:
        return L10n.getWithParams("gigs_price_per_unit", params: params);
      case GigPricingType.fixed:
        return L10n.getWithParams("gigs_price_fixed", params: params);
    }
  }
}

bool _gigOfferTileHasRating(GigOffer offer) =>
    offer.providerRatingAvg != null ||
    (offer.providerRatingCount != null && offer.providerRatingCount! > 0);

IconData _gigOfferTileStarIcon(double? averageOutOfFive, int starIndex) {
  if (averageOutOfFive == null) {
    return Icons.star_border_rounded;
  }
  final r = averageOutOfFive.clamp(0.0, 5.0);
  final remainder = r - starIndex;
  if (remainder >= 0.75) return Icons.star_rounded;
  if (remainder >= 0.25) return Icons.star_half_rounded;
  return Icons.star_border_rounded;
}

class _GigOfferTileRatingStars extends StatelessWidget {
  const _GigOfferTileRatingStars({
    required this.rating,
    required this.reviewCount,
    required this.scheme,
  });

  final double? rating;
  final int reviewCount;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 5; i++) ...[
          Icon(
            _gigOfferTileStarIcon(rating, i),
            size: 16,
            color: Colors.amber,
          ),
          if (i < 4) const SizedBox(width: 2),
        ],
        if (rating != null) ...[
          const SizedBox(width: 8),
          Text(
            rating!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            "($reviewCount)",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }
}
