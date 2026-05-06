import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: photo != null
                      ? CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        )
                      : Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.handyman_outlined,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                              color: scheme.primary,
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
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 2),
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
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(offer),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (offer.providerRatingAvg != null) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            offer.providerRatingAvg!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface,
                            ),
                          ),
                          if (offer.providerRatingCount != null)
                            Text(
                              " (${offer.providerRatingCount})",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          const SizedBox(width: 8),
                        ],
                        if (offer.providerDisplayName != null)
                          Expanded(
                            child: Text(
                              offer.providerDisplayName!,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
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
