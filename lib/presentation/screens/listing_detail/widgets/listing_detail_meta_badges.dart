import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Space between the last chip run and the favorite control.
const double _kMetaBadgesFavoriteGap = 8;

Widget _metaBadgesChipWrap({
  required Widget child,
  VoidCallback? onBackgroundTap,
}) {
  if (onBackgroundTap == null) return child;
  return Stack(
    alignment: Alignment.centerLeft,
    clipBehavior: Clip.none,
    children: [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBackgroundTap,
          child: const ColoredBox(color: Color(0x00000000)),
        ),
      ),
      child,
    ],
  );
}

/// Compact favorite heart beside listing-detail meta chips; shares behavior with
/// [FavoriteHeartToggle] / listing tiles (pulse, haptics, optimistic toggle).
Widget _listingDetailMetaFavoriteChip({
  required int listingId,
  required int ownerUserId,
}) {
  return FavoriteHeartToggle(
    listenable: Listenable.merge([
      AuthenticationState(),
      UserListingState(),
      FavoritesState().listenableFor(listingId),
    ]),
    shouldShow: (ctx) => PeerInteractionEligibility.mayInteractWithPublisher(
      publisherUserId: ownerUserId,
    ),
    resolveIsFavorite: (_) => FavoritesState().isFavorite(listingId),
    hiddenBuilder: (_) => const SizedBox.shrink(),
    onToggle: (ctx, wasFavorite, pulse) async {
      final favoritesState = FavoritesState();
      favoritesState.toggleFavorite(listingId);
      if (!wasFavorite) {
        unawaited(pulse.playTapPulse());
        favoritesState.markDirty();
      }
      try {
        final ok = await getIt<IFavoriteService>().toggleFavorite(listingId);
        if (!ok) {
          favoritesState.toggleFavorite(listingId);
          if (ctx.mounted) {
            ToastTheme.showError(
              ctx,
              message: L10n.get("favorite_toggle_error"),
            );
          }
        }
      } catch (_) {
        favoritesState.toggleFavorite(listingId);
        if (ctx.mounted) {
          ToastTheme.showError(
            ctx,
            message: L10n.get("favorite_toggle_network_error"),
          );
        }
      }
    },
    builder: (context, ui) {
      final activeColor = AppColors.favoriteActive;
      return AnimatedBuilder(
        animation: ui.pulse.listenable,
        builder: (context, child) {
          return Transform.scale(scale: ui.pulse.scale, child: child);
        },
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: ui.onTap,
            customBorder: const CircleBorder(),
            child: Tooltip(
              message: L10n.get(
                ui.isFavorite ? "remove_from_favorites" : "add_to_favorites",
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ThemeIconFactory.detail(
                  icon: ui.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: activeColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Listing type, gender, and price chips (shown in a dedicated tile on listing detail).
class ListingDetailMetaBadges extends StatelessWidget {
  const ListingDetailMetaBadges({
    required this.listingDetail,
    super.key,
    this.onBackgroundTap,
  });

  final ListingDetail listingDetail;

  /// When set, taps on the chip [Wrap] area (including empty space around chips)
  /// invoke this. The favorite heart column is outside this region so it keeps
  /// its own tap target.
  final VoidCallback? onBackgroundTap;

  String _genderLabel(int gender) {
    switch (gender) {
      case 1:
        return L10n.get("male");
      case 2:
        return L10n.get("female");
      default:
        return L10n.get("other");
    }
  }

  IconData _genderIcon(int gender) {
    switch (gender) {
      case 1:
        return Icons.male;
      case 2:
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirror the price-badge styles used by `ListingTile` (transparent fill,
    // green border + icon + text). Inactive listings fall back to the
    // shared inactive token so disabled tiles read the same on both
    // surfaces.
    final priceColor =
        listingDetail.isActive ? Colors.green : AppColors.statusInactive;

    // [Row] + [Expanded] keeps the heart on the tile’s trailing edge; a [Stack]
    // can shrink-wrap to the [Wrap]’s intrinsic width so `Positioned` “end” is
    // not the card edge. Parent column should use [CrossAxisAlignment.stretch]
    // (see `_metaBadgesTile`) so this row gets a tight width.
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthenticationState(),
        UserListingState(),
        PriceDisplaySettingsState(),
      ]),
      builder: (context, _) {
        final showFavorite =
            PeerInteractionEligibility.mayInteractWithPublisher(
          publisherUserId: listingDetail.user.id,
        );
        return SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _metaBadgesChipWrap(
                  onBackgroundTap: onBackgroundTap,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ListingTypeBadge(
                        listingTypeCode: listingDetail.listingType.code,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      if (listingDetail.gender != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // Keep existing layout; just make fill slightly tinted (also in light theme).
                            color: ListingDetailThemeHelper.genderColor(
                              listingDetail.gender!,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ListingDetailThemeHelper.genderColor(
                                listingDetail.gender!,
                              ),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ThemeIconFactory.detail(
                                icon: _genderIcon(listingDetail.gender!),
                                color: ListingDetailThemeHelper.genderColor(
                                  listingDetail.gender!,
                                ),
                                size: 18,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _genderLabel(listingDetail.gender!),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ListingDetailThemeHelper.genderColor(
                                    listingDetail.gender!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ListingPaymentsOutlineBadge(
                        label: PriceRangeHelper
                            .formatListingPriceRangeWithCurrency(
                          listingDetail.price,
                          listingDetail.price,
                        ),
                        foregroundColor: priceColor,
                        fontSize: 12,
                        iconSize: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showFavorite) ...[
                SizedBox(width: _kMetaBadgesFavoriteGap),
                _listingDetailMetaFavoriteChip(
                  listingId: listingDetail.id,
                  ownerUserId: listingDetail.user.id,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
