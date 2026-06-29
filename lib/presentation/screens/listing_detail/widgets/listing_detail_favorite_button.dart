import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/presentation/widgets/common/detail_hosted_photo_gallery.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

enum ListingDetailFavoriteStyle {
  /// Compact icon beside meta chips (legacy placement).
  chip,

  /// Glass pill over the photo carousel top-right corner.
  photoOverlay,
}

/// Favorite heart for listing detail; shares behavior with listing tiles
/// (pulse, haptics, optimistic toggle).
class ListingDetailFavoriteButton extends StatelessWidget {
  const ListingDetailFavoriteButton({
    required this.listingId,
    required this.ownerUserId,
    this.style = ListingDetailFavoriteStyle.chip,
    super.key,
  });

  final int listingId;
  final int ownerUserId;
  final ListingDetailFavoriteStyle style;

  @override
  Widget build(BuildContext context) {
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
        final icon = ui.isFavorite ? Icons.favorite : Icons.favorite_border;
        final iconSize = style == ListingDetailFavoriteStyle.photoOverlay ? 22.0 : 20.0;

        final heart = AnimatedBuilder(
          animation: ui.pulse.listenable,
          builder: (context, child) {
            return Transform.scale(scale: ui.pulse.scale, child: child);
          },
          child: ThemeIcon(
            icon,
            size: iconSize,
            color: activeColor,
            useThemeColor: false,
          ),
        );

        final child = switch (style) {
          ListingDetailFavoriteStyle.chip => Padding(
              padding: const EdgeInsets.all(6),
              child: heart,
            ),
          ListingDetailFavoriteStyle.photoOverlay => DetailPhotoGlassPill(
              padding: const EdgeInsets.all(8),
              child: heart,
            ),
        };

        return Material(
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
              child: child,
            ),
          ),
        );
      },
    );
  }
}
