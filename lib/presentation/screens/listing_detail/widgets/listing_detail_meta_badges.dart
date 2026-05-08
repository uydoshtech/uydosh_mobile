import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";

/// Space between the last chip run and the favorite control.
const double _kMetaBadgesFavoriteGap = 8;

/// Listing type, gender, and price chips (shown in a dedicated tile on listing detail).
class ListingDetailMetaBadges extends StatelessWidget {
  const ListingDetailMetaBadges({required this.listingDetail, super.key});

  final ListingDetail listingDetail;

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
      ]),
      builder: (context, _) {
        final showFavorite =
            AuthenticationState().isAuthenticated &&
            !UserListingState().isOwner(listingDetail.user.id);
        return SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
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
                      label: "${listingDetail.price} y.e.",
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
              if (showFavorite) ...[
                SizedBox(width: _kMetaBadgesFavoriteGap),
                _FavoriteHeartChip(
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

/// Compact, pill-shaped heart toggle that mirrors the visual chrome of the
/// surrounding type/gender/price chips. The heart pulses (scale 1.0 → 1.45,
/// `easeOutBack`) on a successful add — same animation used in
/// `ListingTile._handleFavoriteTap` so the behavior reads as one app-wide
/// pattern, not a one-off here.
class _FavoriteHeartChip extends StatefulWidget {
  const _FavoriteHeartChip({
    required this.listingId,
    required this.ownerUserId,
  });

  final int listingId;
  final int ownerUserId;

  @override
  State<_FavoriteHeartChip> createState() => _FavoriteHeartChipState();
}

class _FavoriteHeartChipState extends State<_FavoriteHeartChip>
    with TickerProviderStateMixin {
  late final FavoriteHeartPulseController _pulse;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pulse = FavoriteHeartPulseController(
      vsync: this,
      repaint: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_busy) return;
    HapticFeedbackUtils.impact();
    SoundService().playLike();

    final favoritesState = FavoritesState();
    final wasFavorite = favoritesState.isFavorite(widget.listingId);

    // Optimistic local toggle so the icon flips and animates immediately —
    // the network round-trip is hidden behind the visual feedback.
    favoritesState.toggleFavorite(widget.listingId);
    if (!wasFavorite) {
      unawaited(_pulse.playTapPulse());
      // Mark Favorites list dirty so the screen refetches next open.
      favoritesState.markDirty();
    }

    setState(() => _busy = true);
    try {
      final ok = await getIt<IFavoriteService>().toggleFavorite(
        widget.listingId,
      );
      if (!ok) {
        favoritesState.toggleFavorite(widget.listingId);
        if (mounted) {
          ToastTheme.showError(
            context,
            message: L10n.get("favorite_toggle_error"),
          );
        }
      }
    } catch (_) {
      favoritesState.toggleFavorite(widget.listingId);
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_network_error"),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthenticationState(),
        UserListingState(),
        FavoritesState().listenableFor(widget.listingId),
      ]),
      builder: (context, _) {
        if (!AuthenticationState().isAuthenticated) {
          _pulse.setFavoriteOutlineState(isFavorite: true);
          return const SizedBox.shrink();
        }
        // Owners can't favorite their own listing — keep parity with the
        // dropdown-menu "Add to favorites" gating.
        if (UserListingState().isOwner(widget.ownerUserId)) {
          _pulse.setFavoriteOutlineState(isFavorite: true);
          return const SizedBox.shrink();
        }

        final isFavorite = FavoritesState().isFavorite(widget.listingId);
        _pulse.setFavoriteOutlineState(isFavorite: isFavorite);
        final activeColor = AppColors.favoriteActive;

        return AnimatedBuilder(
          animation: _pulse.listenable,
          builder: (context, child) {
            return Transform.scale(scale: _pulse.scale, child: child);
          },
          // Borderless heart that matches the listing-tile heart (size 20,
          // same favorite color tokens). Sits in the trailing column of the
          // badges [Row]; EdgeInsets.all(6) gives the ripple room.
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _busy ? null : _onTap,
              customBorder: const CircleBorder(),
              child: Tooltip(
                message: L10n.get(
                  isFavorite ? "remove_from_favorites" : "add_to_favorites",
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Opacity(
                    opacity: _busy ? 0.6 : 1.0,
                    child: ThemeIconFactory.detail(
                      icon:
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: activeColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
