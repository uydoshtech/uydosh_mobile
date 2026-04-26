import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/util/listing_contact_redaction.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/widgets/animated_featured_border.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/gender_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/photo_icon.dart";
import "package:uy_dosh/presentation/widgets/room_3d_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ListingTile extends StatefulWidget {
  const ListingTile({
    required this.listing, super.key,
    this.forceFavorite, // Optional parameter
    this.onFavoriteRemoved, // Optional callback
    this.onFavoriteRemovalFailed, // Optional rollback callback (favorites screen)
    this.showHeartIcon =
        false, // Default to false - only show on favorites screen
    this.showFavoriteIndicator =
        false, // Read-only heart, visible only if listing is in user favorites
    this.showActiveStatus =
        false, // Default to false - only show on my listings screen
    this.searchLineId, // Optional parameter to indicate which line was used for search
  });

  final Listing listing;
  final bool? forceFavorite; // New parameter to force heart to be red
  final VoidCallback? onFavoriteRemoved; // Callback when favorite is removed
  final VoidCallback?
  onFavoriteRemovalFailed; // Callback when optimistic removal must be rolled back
  final bool showHeartIcon; // New parameter to control heart icon visibility
  /// When true, renders a small non-interactive filled heart in the top-right
  /// of the tile if the listing is currently in the user's favorites.
  /// Ignored when [showHeartIcon] is true (the interactive heart takes over).
  final bool showFavoriteIndicator;
  final bool showActiveStatus; // Show active/inactive badge in top-right corner
  final int?
  searchLineId; // Line ID used for search (helps order transfer stations)

  @override
  State<ListingTile> createState() => _ListingTileState();
}

class _ListingTileState extends State<ListingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  bool _isTogglingFavorite = false;
  // View count UI state lives in a dedicated notifier so the owner-only
  // "views + active badge" area can rebuild on its own when the count lands,
  // without forcing a full tile rebuild (which would re-lay-out photos,
  // amenities, metro badges, etc.).
  final ValueNotifier<_ListingViewCountState> _viewCountState =
      ValueNotifier<_ListingViewCountState>(
    const _ListingViewCountState(count: null, loading: false),
  );
  Timer? _viewCountDelayTimer;
  String? _cachedFormattedMoveInDate;
  List<Amenity>? _cachedSortedAmenities;

  static const _viewCountLoadDelay = Duration(milliseconds: 300);

  void _updateCachedValues() {
    _cachedFormattedMoveInDate = _computeFormattedMoveInDate();
    _cachedSortedAmenities = widget.listing.amenities != null &&
            widget.listing.amenities!.isNotEmpty
        ? _computeSortedAmenities(widget.listing.amenities!)
        : null;
  }

  @override
  void initState() {
    super.initState();
    _updateCachedValues();
    if (widget.showActiveStatus) {
      // Delay view count load so tiles that scroll off quickly don't fire requests
      _viewCountDelayTimer = Timer(_viewCountLoadDelay, () {
        _viewCountDelayTimer = null;
        if (mounted) _loadViewCount();
      });
    }
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ListingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.id != widget.listing.id ||
        oldWidget.listing.moveInDate != widget.listing.moveInDate ||
        oldWidget.listing.amenities != widget.listing.amenities) {
      _updateCachedValues();
    }
  }

  @override
  void dispose() {
    _viewCountDelayTimer?.cancel();
    _viewCountDelayTimer = null;
    _viewCountState.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadViewCount() async {
    if (_viewCountState.value.loading) return;
    _viewCountState.value = _viewCountState.value.copyWith(loading: true);
    try {
      final count = await getIt<IListingService>().getListingViewCount(
        widget.listing.id,
      );
      if (mounted) {
        _viewCountState.value = _ListingViewCountState(
          count: count,
          loading: false,
        );
      }
    } catch (_) {
      if (mounted) {
        _viewCountState.value = _viewCountState.value.copyWith(loading: false);
      }
    }
  }

  Future<void> _pulsateHeart() async {
    // Single quick "pop" (1 pulse) — conspicuous but not long.
    _heartAnimationController.stop();
    _heartAnimationController.value = 0;
    await _heartAnimationController.forward();
    await _heartAnimationController.reverse();
  }

  /// Shared favorite-toggle handler used by both the interactive heart
  /// (favorites screen) and the compact heart indicator (home screen).
  ///
  /// Uses an optimistic update: the local [FavoritesState] is toggled
  /// immediately so the heart animation plays without waiting for the
  /// network round-trip. If the API call fails, the state is rolled back
  /// and an error toast is shown.
  Future<void> _handleFavoriteTap(BuildContext context) async {
    HapticFeedbackUtils.impact();
    SoundService().playLike();
    final favoritesState = FavoritesState();
    final wasFavorite =
        widget.forceFavorite ?? favoritesState.isFavorite(widget.listing.id);

    // Optimistic local toggle — triggers the heart's scale/pulse animation
    // immediately, before we know whether the server accepted the change.
    favoritesState.toggleFavorite(widget.listing.id);
    if (!wasFavorite) {
      _pulsateHeart();
      // Favorited from a non-favorites surface (e.g. Home): mark Favorites list dirty
      // so the favorites screen can refresh next time it's opened.
      favoritesState.markDirty();
    }

    // Favorites screen: remove from the list immediately (optimistic),
    // without waiting for the network round-trip.
    if (wasFavorite && widget.onFavoriteRemoved != null) {
      widget.onFavoriteRemoved!();
    }

    try {
      final favoriteService = getIt<IFavoriteService>();
      final success = await favoriteService.toggleFavorite(widget.listing.id);

      if (success) {
        return;
      }

      // Server rejected the toggle — roll back local state.
      favoritesState.toggleFavorite(widget.listing.id);
      if (wasFavorite && widget.onFavoriteRemovalFailed != null) {
        widget.onFavoriteRemovalFailed!();
      }
      if (context.mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_error"),
        );
      }
    } catch (_) {
      favoritesState.toggleFavorite(widget.listing.id);
      if (wasFavorite && widget.onFavoriteRemovalFailed != null) {
        widget.onFavoriteRemovalFailed!();
      }
      if (context.mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_network_error"),
        );
      }
    }
  }

  // Helper method to get the appropriate name based on current language
  String _getLocalizedName({String? nameUz, String? nameRu, String? nameEn}) {
    final currentLanguage = LanguageState().currentLanguage;

    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  /// Abbreviates the "district" suffix so long names fit on one tile row.
  /// ru: "Алмазарский район" → "Алмазарский р-н"
  /// uz: "Olmazor tumani"    → "Olmazor t."
  /// en: "Almazar district"  → "Almazar dist."
  ///
  /// Uses plain `replaceAll` (not `\b` word boundaries) because Dart's default
  /// `\w` class excludes Cyrillic characters — so `\bрайон\b` never matches.
  String _shortenDistrictSuffix(String name) {
    const replacements = <String, String>{
      " район": " р-н",
      " Район": " р-н",
      " tumani": " t.",
      " Tumani": " t.",
      " district": " dist.",
      " District": " dist.",
    };
    var result = name;
    replacements.forEach((from, to) {
      result = result.replaceAll(from, to);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: this intentionally does NOT wrap in `ListenableBuilder(ThemeState())`.
    //
    // MaterialApp at the root of the app is already wrapped in a
    // ListenableBuilder that listens to ThemeState (see `main.dart`). When the
    // theme changes, MaterialApp rebuilds with a new `theme`, which triggers
    // `Theme.of(context)` dependents below to rebuild. Since this tile reads
    // `Theme.of(context)` (scheme, brightness), it's already wired in.
    //
    // Adding a per-tile listener on top of that caused every visible tile in
    // the feed to also rebuild on ANY `ThemeState.notifyListeners()` call —
    // e.g. `ThemeState.initialize()` firing after the feed rendered — for
    // zero correctness benefit.
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          final descriptionSnippet = _descriptionSnippetForPublicTile();
          final borderRadius = BorderRadius.circular(12);
          final scheme = Theme.of(context).colorScheme;
          final bg = scheme.surface;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final darkShadow = Colors.black.withValues(
            alpha: isDark ? 0.45 : 0.20,
          );
          final lightShadow = Colors.white.withValues(
            alpha: isDark ? 0.06 : 0.65,
          );

          final cardWidget = DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    bg,
                    scheme.onSurface,
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.06
                        : 0.03,
                  )!,
                  bg,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: lightShadow,
                  offset: const Offset(-3, -3),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: darkShadow,
                  offset: const Offset(6, 6),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedbackUtils.lightImpact();
                  context.pushListingDetail(widget.listing.id);
                },
                borderRadius: borderRadius,
                child: Stack(
                  children: [
                // Active/Inactive badge and views count in top-right corner (for my listings)
                if (widget.showActiveStatus)
                  Positioned(
                    top: 8,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View count: only this widget rebuilds when the count
                        // lands — the rest of the tile (photos, amenities,
                        // etc.) doesn't get invalidated.
                        ValueListenableBuilder<_ListingViewCountState>(
                          valueListenable: _viewCountState,
                          builder: (context, vc, _) {
                            if (vc.loading) {
                              return const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textGrey600,
                                ),
                              );
                            }
                            final count = vc.count;
                            if (count == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ThemeIcon(
                                    CupertinoIcons.eye,
                                    size: 16,
                                    color: AppColors.textGrey600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    L10n.plural("listing_views_count", count),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Active/Inactive badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.listing.isActive
                                ? AppColors.statusActive.withValues(alpha: 0.2)
                                : AppColors.statusInactive.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.listing.isActive
                                  ? AppColors.statusActive
                                  : AppColors.statusInactive,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            L10n.get(
                              widget.listing.isActive
                                  ? "listing_active"
                                  : "listing_inactive",
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.listing.isActive
                                  ? AppColors.statusActive
                                  : AppColors.statusInactive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with listing type, price, and date
                      Row(
                        children: [
                          // Listing Type and Price
                          Expanded(
                            child: Row(
                              children: [
                                // Listing Type
                                if (widget.listing.listingType != null) ...[
                                  ListingTypeIconBadge(
                                    listingTypeCode:
                                        widget.listing.listingType!.code,
                                    size: 18,
                                    padding: const EdgeInsets.all(4),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                // Gender Badge
                                if (widget.listing.gender != null) ...[
                                  GenderBadge(
                                    gender: widget.listing.gender!,
                                    size: 18,
                                    padding: const EdgeInsets.all(4),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                // Price (inline with top icons)
                                if (widget.listing.price > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const ThemeIcon(
                                          Icons.payments,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${widget.listing.price}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                // Photo indicator icon
                                if (widget.listing.photos != null &&
                                    widget.listing.photos!.isNotEmpty) ...[
                                  const PhotoIcon(
                                    size: 18,
                                    padding: EdgeInsets.all(4),
                                    borderRadius: 8,
                                  ),
                                ],
                                // 3D room scan (available on iOS; show indicator on web too)
                                if ((kIsWeb || isIPhoneFormFactor(context)) &&
                                    (widget.listing.pointCloudUrl?.isNotEmpty ??
                                        false)) ...[
                                  if (widget.listing.photos != null &&
                                      widget.listing.photos!.isNotEmpty)
                                    const SizedBox(width: 6),
                                  const Room3dIconBadge(
                                    size: 18,
                                    padding: EdgeInsets.all(4),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Heart icon in top-right corner - only show when showHeartIcon is true and user is authenticated
                          if (widget.showHeartIcon)
                            ListenableBuilder(
                              listenable: Listenable.merge([
                                AuthenticationState(),
                                UserListingState(),
                                FavoritesState().listenableFor(
                                  widget.listing.id,
                                ),
                              ]),
                              builder: (context, child) {
                                if (!AuthenticationState().isAuthenticated) {
                                  return const SizedBox.shrink();
                                }
                                // Owners can't favorite their own listing.
                                if (UserListingState()
                                    .isOwner(widget.listing.userId)) {
                                  return const SizedBox.shrink();
                                }

                                final isFavorite =
                                    widget.forceFavorite ??
                                    FavoritesState().isFavorite(
                                      widget.listing.id,
                                    );
                                // Keep the layout slot at the icon's 20x20
                                // footprint, but expand the tap target to be
                                // easier to hit without shifting the row.
                                return SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: OverflowBox(
                                    maxWidth: 44,
                                    maxHeight: 44,
                                    child: GestureDetector(
                                      onTap: _isTogglingFavorite
                                          ? null
                                          : () => _handleFavoriteTap(context),
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Center(
                                          child: Opacity(
                                            opacity:
                                                _isTogglingFavorite ? 0.6 : 1.0,
                                            child: AnimatedBuilder(
                                              animation: _heartScaleAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale:
                                                      _heartScaleAnimation.value,
                                                  child: _isTogglingFavorite
                                                      ? SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              isFavorite
                                                                  ? AppColors
                                                                      .favoriteActive
                                                                  : AppColors
                                                                      .favoriteInactive,
                                                            ),
                                                          ),
                                                        )
                                                      : ThemeIcon(
                                                          isFavorite
                                                              ? Icons.favorite
                                                              : Icons
                                                                    .favorite_border,
                                                          color: isFavorite
                                                              ? AppColors
                                                                    .favoriteActive
                                                              : AppColors
                                                                    .favoriteInactive,
                                                          size: 20,
                                                        ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Tappable favorite indicator (e.g. for home screen):
                          // shows an outline heart when not favorited and a
                          // filled heart when favorited. Tapping toggles the
                          // favorite. Transitions are animated with a scale
                          // pulse via AnimatedSwitcher.
                          if (!widget.showHeartIcon &&
                              widget.showFavoriteIndicator)
                            ListenableBuilder(
                              listenable: Listenable.merge([
                                AuthenticationState(),
                                UserListingState(),
                                FavoritesState().listenableFor(
                                  widget.listing.id,
                                ),
                              ]),
                              builder: (context, child) {
                                if (!AuthenticationState().isAuthenticated) {
                                  return const SizedBox.shrink();
                                }
                                // Owners can't favorite their own listing.
                                if (UserListingState()
                                    .isOwner(widget.listing.userId)) {
                                  return const SizedBox.shrink();
                                }
                                final isFavorite = FavoritesState()
                                    .isFavorite(widget.listing.id);
                                return AnimatedBuilder(
                                  animation: _heartScaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _heartScaleAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    reverseDuration:
                                        const Duration(milliseconds: 180),
                                    switchInCurve: Curves.elasticOut,
                                    switchOutCurve: Curves.easeInBack,
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                    // Layout slot stays at the icon's 20x20
                                    // footprint; OverflowBox expands the
                                    // GestureDetector's hit area to 44x44
                                    // (standard touch target) without
                                    // affecting surrounding layout.
                                    child: SizedBox(
                                      key: ValueKey(
                                        isFavorite ? "fav-on" : "fav-off",
                                      ),
                                      width: 20,
                                      height: 20,
                                      child: OverflowBox(
                                        maxWidth: 44,
                                        maxHeight: 44,
                                        child: GestureDetector(
                                          onTap: _isTogglingFavorite
                                              ? null
                                              : () =>
                                                    _handleFavoriteTap(context),
                                          behavior: HitTestBehavior.opaque,
                                          child: SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: Center(
                                              child: Opacity(
                                                opacity: _isTogglingFavorite
                                                    ? 0.6
                                                    : 1.0,
                                                child: ThemeIcon(
                                                  isFavorite
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isFavorite
                                                      ? AppColors.favoriteActive
                                                      : AppColors
                                                            .favoriteInactive,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      // Title
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          right: 40,
                        ), // Add right padding to avoid arrow overlap
                        child: Text(
                          ListingUtils.usesPresetListingTitle(
                                widget.listing.listingTypeId,
                              )
                              ? L10n.get(
                                  ListingUtils.presetListingTitleL10nKey(
                                    listingTypeId:
                                        widget.listing.listingTypeId,
                                    gender: widget.listing.gender,
                                  ),
                                )
                              : widget.listing.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getTitleTextColor(),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Description
                      if (descriptionSnippet != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            right: 40,
                          ), // Add right padding to avoid arrow overlap
                          child: Text(
                            descriptionSnippet,
                            style: TextStyle(
                              fontSize: 14,
                              color: _getDescriptionTextColor(),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Location and subway (optional); price/amenities/date are not gated on these
                      if (widget.listing.location != null ||
                          widget.listing.subwayStation != null) ...[
                        ListenableBuilder(
                          listenable: LanguageState(),
                          builder: (context, child) {
                            final hasLocation =
                                widget.listing.location != null;
                            final hasStation =
                                widget.listing.subwayStation != null;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (hasLocation) ...[
                                  const ThemeIcon(
                                    Icons.location_on,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _shortenDistrictSuffix(
                                        _getLocalizedName(
                                          nameUz:
                                              widget.listing.location!.nameUz,
                                          nameRu:
                                              widget.listing.location!.nameRu,
                                          nameEn:
                                              widget.listing.location!.nameEn,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _getLocationTextColor(),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                if (hasLocation && hasStation)
                                  const SizedBox(width: 12),
                                if (hasStation)
                                  Flexible(
                                    child: _buildSubwayStationDisplay(
                                      widget.listing.subwayStation!,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                      if (widget.listing.amenities != null &&
                          widget.listing.amenities!.isNotEmpty) ...[
                        if (widget.listing.location != null ||
                            widget.listing.subwayStation != null)
                          const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: (_cachedSortedAmenities ?? [])
                                .map(
                                  (amenity) => ThemeIcon(
                                    _getAmenityIcon(amenity),
                                    size: 18,
                                    color: _getAmenityIconColor(),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      if ((widget.listing.privateRoom ?? false) ||
                          (widget.listing.moveInDate != null &&
                              widget.listing.moveInDate!.isNotEmpty)) ...[
                        if (widget.listing.location != null ||
                            widget.listing.subwayStation != null ||
                            (widget.listing.amenities != null &&
                                widget.listing.amenities!.isNotEmpty))
                          const SizedBox(height: 12),
                        ListenableBuilder(
                          listenable: LanguageState(),
                          builder: (context, child) {
                            final hasPrivateRoom =
                                widget.listing.privateRoom ?? false;
                            final hasMoveInDate =
                                widget.listing.moveInDate != null &&
                                    widget.listing.moveInDate!.isNotEmpty;
                            return Row(
                              children: [
                                if (hasPrivateRoom) ...[
                                  ThemeIcon(
                                    CupertinoIcons.lock_fill,
                                    size: 20,
                                    color: _getPrivateRoomIconColor(),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    L10n.get("private_room"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getPrivateRoomTextColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                if (hasPrivateRoom && hasMoveInDate)
                                  const SizedBox(width: 12),
                                if (hasMoveInDate) ...[
                                  ThemeIcon(
                                    CupertinoIcons.square_arrow_right,
                                    size: 22,
                                    color: _getDateTextColor(),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      hasPrivateRoom
                                          ? (_cachedFormattedMoveInDate ?? "")
                                          : "${L10n.get("move_in_date_label")} ${_cachedFormattedMoveInDate ?? ""}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _getDateTextColor(),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow positioned in the middle of tile height
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ThemeIcon(
                      Icons.arrow_forward_ios,
                      size: 19.2, // 24 * 0.8 = 19.2
                      color: _getArrowIconColor(),
                    ),
                  ),
                ),
              ],
                ),
              ),
            ),
          );

        // Wrap with RGB rotating border if featured
        if (ListingUtils.isCurrentlyFeatured(widget.listing)) {
          return AnimatedFeaturedBorder(
            borderWidth: 3.0,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: cardWidget,
          );
        }

        return cardWidget;
        },
      ),
    );
  }

  Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  String _computeFormattedMoveInDate() {
    if (widget.listing.moveInDate == null ||
        widget.listing.moveInDate!.isEmpty) {
      return "";
    }

    try {
      final date = DateTime.parse(widget.listing.moveInDate!);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return L10n.get("today");
      } else if (difference == 1) {
        return L10n.get("tomorrow");
      } else if (difference > 0 && difference <= 7) {
        return L10n.plural("in_days", difference);
      } else {
        // Format as "MMM dd, yyyy" for dates more than a week away
        final monthKeys = [
          "january",
          "february",
          "march",
          "april",
          "may",
          "june",
          "july",
          "august",
          "september",
          "october",
          "november",
          "december",
        ];
        final localizedMonth = L10n.get(monthKeys[date.month - 1]);
        return "${localizedMonth.substring(0, 3)} ${date.day}, ${date.year}";
      }
    } catch (e) {
      // If parsing fails, return empty string instead of the raw invalid value
      return "";
    }
  }

  /// Gets localized day name using LanguageState
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return L10n.get("monday");
      case 2:
        return L10n.get("tuesday");
      case 3:
        return L10n.get("wednesday");
      case 4:
        return L10n.get("thursday");
      case 5:
        return L10n.get("friday");
      case 6:
        return L10n.get("saturday");
      case 7:
        return L10n.get("sunday");
      default:
        return "";
    }
  }

  /// Gets localized month name using LanguageState
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return L10n.get("january");
      case 2:
        return L10n.get("february");
      case 3:
        return L10n.get("march");
      case 4:
        return L10n.get("april");
      case 5:
        return L10n.get("may");
      case 6:
        return L10n.get("june");
      case 7:
        return L10n.get("july");
      case 8:
        return L10n.get("august");
      case 9:
        return L10n.get("september");
      case 10:
        return L10n.get("october");
      case 11:
        return L10n.get("november");
      case 12:
        return L10n.get("december");
      default:
        return "";
    }
  }

  List<Amenity> _computeSortedAmenities(List<Amenity> amenities) {
    // Custom sorting: WiFi first, then air conditioning, then the rest
    final sortedAmenities = List<Amenity>.from(amenities);

    sortedAmenities.sort((a, b) {
      // WiFi gets highest priority (1)
      if (a.code == "wifi" && b.code != "wifi") return -1;
      if (a.code != "wifi" && b.code == "wifi") return 1;

      // Air conditioning gets second priority (2)
      if (a.code == "air_conditioning" &&
          b.code != "air_conditioning" &&
          b.code != "wifi") {
        return -1;
      }
      if (a.code != "air_conditioning" &&
          b.code == "air_conditioning" &&
          a.code != "wifi") {
        return 1;
      }

      // For all other amenities, sort alphabetically by code
      // Handle nullable codes safely
      final aCode = a.code ?? "";
      final bCode = b.code ?? "";
      return aCode.compareTo(bCode);
    });

    return sortedAmenities;
  }

  IconData _getAmenityIcon(Amenity amenity) {
    // First try to use the icon from the backend response
    if (amenity.icon != null && amenity.icon!.isNotEmpty) {
      // Convert emoji to IconData if possible, or use a default icon
      return _getIconFromEmoji(amenity.icon!);
    }

    // Fallback to using the code with AmenityIconHelper
    if (amenity.code != null && amenity.code!.isNotEmpty) {
      return AmenityIconHelper.getIcon(amenity.code!);
    }

    // Default icon if neither icon nor code is available
    return Icons.home;
  }

  IconData _getIconFromEmoji(String emoji) {
    // Simple mapping of common emojis to Flutter icons
    switch (emoji) {
      case "❄️":
        return Icons.ac_unit; // Air conditioning
      case "🌐":
        return Icons.wifi; // Internet
      case "🪑":
        return Icons.chair; // Furniture
      case "🍳":
        return Icons.kitchen; // Kitchen appliances
      case "🚿":
        return Icons.shower; // Shower
      case "🧺":
        return Icons.local_laundry_service; // Washing machine
      case "📺":
        return Icons.tv; // TV
      case "🚗":
        return Icons.local_parking; // Parking
      case "🐕":
        return Icons.pets; // Pets allowed
      case "🚭":
        return Icons.smoke_free; // No smoking
      default:
        return Icons.home; // Default icon
    }
  }

  // Theme-dependent color method for amenities
  Color _getAmenityIconColor() {
    // Use ThemeState to detect current theme
    if (ThemeState().isBlueTheme) {
      // Blue theme — soft blue-gray so amenity icons read as secondary
      // info and don't compete with the bold white title/meta text.
      return _blueThemeSecondary;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use black for icons
      return Colors.black;
    } else {
      // Default theme - use primary icon color
      return AppColors.iconPrimary; // This is Color(0xFF6B46C1)
    }
  }

  /// Soft blue-gray used for secondary text/icons on the dark-blue theme,
  /// matching `MessagingThemeColors.textSecondary`/`iconSecondary`.
  static const Color _blueThemeSecondary = Color(0xFFB3C0CC);

  // Theme-dependent color method for title text
  Color _getTitleTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87; // Default dark text for light theme
    }
  }

  // Theme-dependent color method for description text
  Color _getDescriptionTextColor() {
    if (ThemeState().isBlueTheme) {
      // Secondary-tier text on blue theme: softer than the white title
      // so body copy recedes and establishes a clear hierarchy.
      return _blueThemeSecondary;
    } else {
      return Colors.black; // Default text for light theme
    }
  }

  String? _descriptionSnippetForPublicTile() {
    final raw = widget.listing.description;
    if (raw == null || raw.isEmpty) return null;
    final s = ListingContactRedaction.stripForPublicDisplay(raw);
    return s.isEmpty ? null : s;
  }

  // Theme-dependent color method for location and metro text
  Color _getLocationTextColor() {
    if (ThemeState().isBlueTheme) {
      // Secondary-tier text on blue theme — keeps location/metro legible
      // but visually subordinate to the title and primary meta (private
      // room / move-in date) rows.
      return _blueThemeSecondary;
    } else {
      return Colors.black; // Default text for light theme
    }
  }

  // Theme-dependent color method for date text
  Color _getDateTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return Colors.black; // Default text for light theme
    }
  }

  // Theme-dependent color method for arrow icon
  Color _getArrowIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight.withValues(alpha: 0.5);
    } else {
      return AppColors.textGrey400; // Default grey for light theme
    }
  }

  // Theme-dependent color method for private room icon
  Color _getPrivateRoomIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.primary;
    }
  }

  // Theme-dependent color method for private room text
  Color _getPrivateRoomTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return Colors.black;
    }
  }

  // Build subway station display with transfer station support
  Widget _buildSubwayStationDisplay(SubwayStationDetail station) {
    final transferInfo = MetroCache.getTransferStationInfo(station.id);

    if (transferInfo != null) {
      // This is a transfer station - show both stations with <-> icon
      // Determine which station should be on the left based on search context
      final connectedStation = SubwayStationDetail(
        id: transferInfo["connectedStationId"],
        nameUz: transferInfo["connectedStationName"],
        nameRu: transferInfo["connectedStationNameRu"],
        nameEn: transferInfo["connectedStationNameEn"],
        line: transferInfo["connectedStationLine"],
      );

      // If we have a searchLineId, prioritize that line on the left
      // Otherwise, keep the original station on the left
      final leftStation =
          (widget.searchLineId != null &&
                  connectedStation.line == widget.searchLineId)
              ? connectedStation
              : station;
      final rightStation =
          (leftStation.id == station.id) ? connectedStation : station;

      return Row(
        children: [
          ThemeIcon(Icons.train, color: _getLineColor(leftStation.line), size: 20),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _getLocalizedName(
                nameUz: leftStation.nameUz,
                nameRu: leftStation.nameRu,
                nameEn: leftStation.nameEn,
              ),
              style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          ThemeIcon(Icons.swap_horiz, color: _getLocationTextColor(), size: 16),
          const SizedBox(width: 4),
          ThemeIcon(Icons.train, color: _getLineColor(rightStation.line), size: 20),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _getLocalizedName(
                nameUz: rightStation.nameUz,
                nameRu: rightStation.nameRu,
                nameEn: rightStation.nameEn,
              ),
              style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      // Regular station - show normally
      return Row(
        children: [
          ThemeIcon(Icons.train, color: _getLineColor(station.line), size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _getLocalizedName(
                nameUz: station.nameUz,
                nameRu: station.nameRu,
                nameEn: station.nameEn,
              ),
              style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }
}

/// Narrow state container for the owner-only "view count" pill inside a tile.
/// Kept immutable so `ValueNotifier` change detection works with identity
/// checks on state transitions (loading -> loaded / error).
class _ListingViewCountState {
  const _ListingViewCountState({required this.count, required this.loading});
  final int? count;
  final bool loading;

  _ListingViewCountState copyWith({int? count, bool? loading}) {
    return _ListingViewCountState(
      count: count ?? this.count,
      loading: loading ?? this.loading,
    );
  }
}
