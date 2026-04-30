import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

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
    final isBlueTheme = ThemeState().isBlueTheme;
    final priceActiveColor =
        isBlueTheme ? Colors.white : AppColors.statusActive;
    final priceInactiveColor =
        isBlueTheme ? Colors.white : AppColors.statusInactive;
    final priceBadgeBg =
        isBlueTheme
            ? (listingDetail.isActive
                ? AppColors.statusActive
                : AppColors.statusInactive)
            : Colors.white;

    // Two-zone layout:
    //   • left  — wrapping chips (type / gender / price); may overflow to a
    //     second run when the row gets tight, just like before.
    //   • right — favorite heart, pinned to the trailing edge of the tile.
    // Wrapped in a `Row` so the heart can use `Spacer` / `Expanded` to push
    // itself to the rightmost side. Vertical centering keeps the heart on
    // the same baseline as the chips even when they wrap to two lines.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ListingTypeBadge(
                listingTypeCode: listingDetail.listingType.code,
                fontSize: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              if (listingDetail.gender != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              PriceRangeBadge(
                minPrice: listingDetail.price,
                maxPrice: listingDetail.price,
                isActive: listingDetail.isActive,
                showIcon: true,
                iconSize: 18,
                fontSize: 13,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                currencySymbol: "y.e.",
                activeColor: priceActiveColor,
                inactiveColor: priceInactiveColor,
                badgeBackgroundColor: priceBadgeBg,
              ),
            ],
          ),
        ),
        // "Add to favorites" heart — pinned to the rightmost edge of the
        // tile. Visible only to authenticated users who don't own this
        // listing. Uses the same scale-pulse animation as the home/favorites
        // listing tiles for visual consistency.
        _FavoriteHeartChip(
          listingId: listingDetail.id,
          ownerUserId: listingDetail.user.id,
        ),
      ],
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pulse() async {
    _controller
      ..stop()
      ..value = 0;
    await _controller.forward();
    await _controller.reverse();
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
      _pulse();
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
          return const SizedBox.shrink();
        }
        // Owners can't favorite their own listing — keep parity with the
        // dropdown-menu "Add to favorites" gating.
        if (UserListingState().isOwner(widget.ownerUserId)) {
          return const SizedBox.shrink();
        }

        final isFavorite = FavoritesState().isFavorite(widget.listingId);
        final activeColor = AppColors.favoriteActive;

        return AnimatedBuilder(
          animation: _scale,
          builder: (context, child) {
            return Transform.scale(scale: _scale.value, child: child);
          },
          // Borderless heart that matches the listing-tile heart (size 20,
          // same favorite color tokens). Pinned to the rightmost edge of
          // the meta-badges row by the parent `Row` layout — only the
          // internal `EdgeInsets.all(6)` keeps the icon off the tile's
          // trailing border so the ripple has room to breathe.
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
