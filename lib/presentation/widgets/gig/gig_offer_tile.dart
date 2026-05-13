import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_participant_avatar_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";

/// Reusable card for a single [GigOffer] in any vertical list/feed.
///
/// Tapping the tile pushes [GigOfferDetailScreen] via the [GigNavigatorExtensions]
/// helper. Used by both the "Browse services" list and the inline feed on
/// the Services hub.
class GigOfferTile extends StatefulWidget {
  const GigOfferTile({
    required this.offer,
    this.showFavoriteIndicator = false,
    this.forceFavorite,
    this.onFavoriteRemoved,
    this.onFavoriteRemovalFailed,
    super.key,
  });

  final GigOffer offer;
  final bool showFavoriteIndicator;
  final bool? forceFavorite;
  final VoidCallback? onFavoriteRemoved;
  final VoidCallback? onFavoriteRemovalFailed;

  @override
  State<GigOfferTile> createState() => _GigOfferTileState();
}

class _GigOfferTileState extends State<GigOfferTile> {
  late Listenable _favoriteListenable;

  @override
  void initState() {
    super.initState();
    _favoriteListenable = Listenable.merge([
      GigFavoritesState().listenableForOffer(widget.offer.id),
    ]);
  }

  @override
  void didUpdateWidget(GigOfferTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.id != widget.offer.id) {
      _favoriteListenable = Listenable.merge([
        GigFavoritesState().listenableForOffer(widget.offer.id),
      ]);
    }
  }

  Future<void> _onOfferFavoriteToggle(
    BuildContext context,
    bool wasFavorite,
    FavoriteHeartPulseController pulse,
  ) async {
    final gigFav = GigFavoritesState();
    final favScreen = FavoritesState();
    gigFav.toggleOfferLocal(widget.offer.id);
    if (!wasFavorite) {
      unawaited(pulse.playTapPulse());
      favScreen.markDirty();
    }
    try {
      await getIt<IGigService>().toggleFavoriteOffer(widget.offer.id);
      if (wasFavorite && widget.onFavoriteRemoved != null) {
        widget.onFavoriteRemoved!();
      }
    } catch (_) {
      gigFav.toggleOfferLocal(widget.offer.id);
      widget.onFavoriteRemovalFailed?.call();
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_error"),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = widget.offer.category?.localizedName(language) ?? "";
    final photo = widget.offer.primaryPhotoUrl();
    final thumbPx =
        (84 * MediaQuery.devicePixelRatioOf(context)).round().clamp(1, 4096);

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        onTap: () {
          HapticFeedbackUtils.lightImpact();
          context.pushGigOfferDetail(widget.offer.id);
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
                              imageUrl: EnvironmentUtil.hostedImageUrl(photo),
                              memCacheWidth: thumbPx,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: scheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.4),
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
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: widget.showFavoriteIndicator ? 52 : 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (categoryName.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.offer.category?.icon != null) ...[
                                  GigCategoryIconBadge(
                                    icon: widget.offer.category!.icon,
                                    iconColor: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                    badgeBackgroundColor: scheme.onSurface
                                        .withValues(alpha: 0.12),
                                  ),
                                  const SizedBox(width: 8),
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
                            widget.offer.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListenableBuilder(
                            listenable: PriceDisplaySettingsState(),
                            builder: (context, _) =>
                                ListingPaymentsOutlineBadge(
                              label: _formatGigOfferTilePrice(widget.offer),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _GigOfferTileSocialProofRow(
                            offer: widget.offer,
                            scheme: scheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: widget.showFavoriteIndicator
                    ? FavoriteHeartToggle(
                        listenable: _favoriteListenable,
                        shouldShow: (ctx) =>
                            AuthenticationState().isAuthenticated &&
                            !UserListingState().isOwner(
                              widget.offer.providerUserId,
                            ),
                        resolveIsFavorite: (ctx) =>
                            widget.forceFavorite ??
                            GigFavoritesState()
                                .isOfferFavorite(widget.offer.id),
                        onToggle: _onOfferFavoriteToggle,
                        hiddenBuilder: (ctx) => IgnorePointer(
                          child: GigParticipantAvatarBadge(
                            avatarUrl: widget.offer.providerAvatarUrl,
                            displayName: widget.offer.providerDisplayName,
                            ringColor: scheme.surface,
                          ),
                        ),
                        builder: (context, ui) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: ui.onTap,
                                borderRadius: BorderRadius.circular(22),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Center(
                                      child: AnimatedBuilder(
                                        animation: ui.pulse.listenable,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: ui.pulse.scale,
                                            child: child,
                                          );
                                        },
                                        child: ThemeIcon(
                                          ui.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: ui.isFavorite
                                              ? AppColors.favoriteActive
                                              : AppColors.favoriteInactive,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            IgnorePointer(
                              child: GigParticipantAvatarBadge(
                                avatarUrl: widget.offer.providerAvatarUrl,
                                displayName: widget.offer.providerDisplayName,
                                ringColor: scheme.surface,
                              ),
                            ),
                          ],
                        ),
                      )
                    : IgnorePointer(
                        child: GigParticipantAvatarBadge(
                          avatarUrl: widget.offer.providerAvatarUrl,
                          displayName: widget.offer.providerDisplayName,
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
}

String _formatGigOfferTilePrice(GigOffer o) {
  final display = CurrencyDisplayUtils.gigAmountForDisplay(
    amount: o.price,
    currencyCode: o.currencyCode,
  );
  final params = {
    "amount": IntFormatUtils.withDotThousands(display.amount),
    "currency": CurrencyDisplayUtils.isoCodeForBadge(display.currencyCode),
  };
  final String key;
  switch (o.pricingType) {
    case GigPricingType.hourly:
      key = "gigs_price_per_hour";
    case GigPricingType.perUnit:
      key = "gigs_price_per_unit";
    case GigPricingType.fixed:
      key = "gigs_price_fixed";
  }
  return CurrencyDisplayUtils.stripEmptyCurrencyArtifacts(
    L10n.getWithParams(key, params: params),
  );
}

/// Default tile visualization when the feed has no `rating_avg` yet.
const double _kGigOfferTilePlaceholderRatingOutOfFive = 4.0;

/// Shown when the feed payload has no `rating_count` yet (layout placeholder).
const int _kGigOfferTilePlaceholderReviewCount = 16;

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

class _GigOfferTileSocialProofRow extends StatelessWidget {
  const _GigOfferTileSocialProofRow({
    required this.offer,
    required this.scheme,
  });

  final GigOffer offer;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final jobs = offer.providerCompletedJobsCount ?? 0;
    final reviews = offer.providerRatingCount ?? 0;
    final rating = offer.providerRatingAvg;
    final reviewLabelCount =
        reviews > 0 ? reviews : _kGigOfferTilePlaceholderReviewCount;
    final placeholderStarColor = scheme.onSurface.withValues(alpha: 0.38);

    final mutedStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface.withValues(alpha: 0.62),
    );

    final sepStyle = mutedStyle;

    final segments = <Widget>[];

    void pushSep() {
      if (segments.isEmpty) return;
      segments.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text("·", style: sepStyle),
        ),
      );
    }

    if (rating != null) {
      segments.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++) ...[
              Icon(
                _gigOfferTileStarIcon(rating, i),
                size: 14,
                color: Colors.amber,
              ),
              if (i < 4) const SizedBox(width: 1),
            ],
            const SizedBox(width: 6),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      );
    } else {
      final placeholderStarIcons = <Widget>[];
      for (var i = 0; i < 5; i++) {
        final icon = _gigOfferTileStarIcon(
          _kGigOfferTilePlaceholderRatingOutOfFive,
          i,
        );
        placeholderStarIcons.add(
          Icon(
            icon,
            size: 14,
            color: icon == Icons.star_border_rounded
                ? placeholderStarColor
                : Colors.amber,
          ),
        );
        if (i < 4) placeholderStarIcons.add(const SizedBox(width: 1));
      }
      segments.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: placeholderStarIcons,
        ),
      );
    }

    if (jobs > 0) {
      pushSep();
      segments.add(
        Text(
          L10n.plural("gigs_offer_tile_jobs", jobs),
          style: mutedStyle,
        ),
      );
    }

    pushSep();
    segments.add(
      Text(
        L10n.plural("gigs_offer_tile_reviews", reviewLabelCount),
        style: reviews > 0
            ? mutedStyle
            : mutedStyle.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
      ),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 4,
      children: segments,
    );
  }
}
