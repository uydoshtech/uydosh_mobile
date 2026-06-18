import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/widgets/animated_featured_border.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/gender_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/room_3d_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ListingTile extends StatefulWidget {
  const ListingTile({
    required this.listing,
    super.key,
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

class _ListingTileState extends State<ListingTile> {
  // View count UI state lives in a dedicated notifier so the owner-only
  // "views + active badge" area can rebuild on its own when the count lands,
  // without forcing a full tile rebuild (which would re-lay-out photos,
  // amenities, metro badges, etc.).
  final ValueNotifier<_ListingViewCountState> _viewCountState =
      ValueNotifier<_ListingViewCountState>(
    const _ListingViewCountState(count: null, loading: false),
  );
  Timer? _viewCountDelayTimer;
  List<Amenity>? _cachedSortedAmenities;
  // Cached merged listenable for the favorite-related state. Allocating a
  // `_CombiningListenable` per build (in build()) caused every visible tile
  // in the feed to attach/detach listeners on three notifiers on every
  // rebuild — material on long scrolls. We rebuild it only when the
  // listing id changes (the FavoritesState key).
  late Listenable _favoriteListenable;

  // When an admin removes a featured listing from the top directly from the
  // feed tile, we drop the featured border immediately (optimistic) instead of
  // waiting for the surrounding list to refetch.
  bool _featuredRemovedLocally = false;

  bool get _isFeatured =>
      !_featuredRemovedLocally &&
      ListingUtils.isCurrentlyFeatured(widget.listing);

  static const _viewCountLoadDelay = Duration(milliseconds: 300);

  void _updateCachedValues() {
    _cachedSortedAmenities =
        widget.listing.amenities != null && widget.listing.amenities!.isNotEmpty
            ? _computeSortedAmenities(widget.listing.amenities!)
            : null;
  }

  Listenable _buildFavoriteListenable() => Listenable.merge([
        AuthenticationState(),
        UserListingState(),
        FavoritesState().listenableFor(widget.listing.id),
      ]);

  @override
  void initState() {
    super.initState();
    _updateCachedValues();
    _favoriteListenable = _buildFavoriteListenable();
    if (widget.showActiveStatus) {
      // Delay view count load so tiles that scroll off quickly don't fire requests
      _viewCountDelayTimer = Timer(_viewCountLoadDelay, () {
        _viewCountDelayTimer = null;
        if (mounted) _loadViewCount();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ListingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.id != widget.listing.id ||
        oldWidget.listing.amenities != widget.listing.amenities) {
      _updateCachedValues();
    }
    if (oldWidget.listing.id != widget.listing.id) {
      // Listing identity changed — rebuild the merged listenable so we listen
      // to the right per-id FavoritesState notifier.
      _favoriteListenable = _buildFavoriteListenable();
      // ...and drop any optimistic unfeature applied to the previous listing.
      _featuredRemovedLocally = false;
    }
  }

  @override
  void dispose() {
    _viewCountDelayTimer?.cancel();
    _viewCountDelayTimer = null;
    _viewCountState.dispose();
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

  /// Optimistic toggle + API for listing favorites (tiles).
  /// Haptics/sound/busy pulse live in [FavoriteHeartToggle].
  Future<void> _onListingFavoriteToggle(
    BuildContext context,
    bool wasFavorite,
    FavoriteHeartPulseController pulse,
  ) async {
    final favoritesState = FavoritesState();
    favoritesState.toggleFavorite(widget.listing.id);
    if (!wasFavorite) {
      unawaited(pulse.playTapPulse());
      favoritesState.markDirty();
    }

    if (wasFavorite && widget.onFavoriteRemoved != null) {
      widget.onFavoriteRemoved!();
    }

    try {
      final favoriteService = getIt<IFavoriteService>();
      final success = await favoriteService.toggleFavorite(widget.listing.id);

      if (success) {
        return;
      }

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

  /// Admin-only affordance: long-pressing a *featured* tile lets an admin pull
  /// the listing back down from the top, without opening it. The menu is only
  /// surfaced for admins on currently-featured listings, so for everyone else
  /// the long-press is a silent no-op.
  Future<void> _onTileLongPress() async {
    if (!_isFeatured) return;

    final role = await SessionManager.getUserRole();
    if (role != "admin") return;
    if (!mounted) return;

    HapticFeedbackUtils.lightImpact();
    await _showAdminTileActions();
  }

  Future<void> _showAdminTileActions() async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showAppBottomSheet<bool>(
      context: context,
      cardColor: scheme.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  CupertinoIcons.arrow_down_circle,
                  color: Colors.red,
                ),
                title: Text(
                  L10n.get("remove_from_top"),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if ((confirmed ?? false) && mounted) {
      await _removeFromTop();
    }
  }

  Future<void> _removeFromTop() async {
    try {
      final listingService = getIt<IListingService>();
      // The tile is featured here, so this routes to DELETE /listings/:id/feature.
      final success = await listingService.toggleFeatureListing(
        widget.listing.id,
        true,
      );

      if (!mounted) return;

      if (success) {
        setState(() => _featuredRemovedLocally = true);
        // Keep the home/search feeds in sync on their next refresh.
        HomeRefreshState().markForRefresh();
        ToastTheme.showSuccess(
          context,
          message: L10n.get("unfeature_listing_success"),
        );
      } else {
        ToastTheme.showError(
          context,
          message: L10n.get("feature_listing_error"),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("feature_listing_error"),
      );
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
  /// ru: "Алмазарский район" → "Алмазарский р."
  /// uz: "Olmazor tumani"    → "Olmazor t."
  /// en: "Almazar district"  → "Almazar dist."
  ///
  /// Uses plain `replaceAll` (not `\b` word boundaries) because Dart's default
  /// `\w` class excludes Cyrillic characters — so `\bрайон\b` never matches.
  String _shortenDistrictSuffix(String name) {
    const replacements = <String, String>{
      " район": " р.",
      " Район": " р.",
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
    final borderRadius = BorderRadius.circular(12);
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = ThemeState();
    final useLiquidGlass =
        themeState.isBlueTheme || themeState.isLightTheme;
    final darkShadow = Colors.black.withValues(
      alpha: isDark ? 0.45 : 0.20,
    );
    final lightShadow = Colors.white.withValues(
      alpha: LiquidGlassRendering.neumorphicLightShadowAlpha(context),
    );

    final tileInkWell = InkWell(
      onTap: () {
        HapticFeedbackUtils.lightImpact();
        context.pushListingDetail(widget.listing.id);
      },
      onLongPress: () => unawaited(_onTileLongPress()),
      borderRadius: borderRadius,
      child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges (type, gender, price, 3D) span the full card
                      // width above the photo; favorite heart at the far end.
                      Row(
                        children: [
                          // Type / gender / price / 3D badges. A Wrap (not a
                          // Row) so labelled badges flow onto a second line on
                          // narrow screens instead of overflowing.
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Listing Type
                                if (widget.listing.listingType != null)
                                  ListingTypeIconBadge(
                                    listingTypeCode:
                                        widget.listing.listingType!.code,
                                    size: 16,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    label: _shortListingTypeLabel(
                                      widget.listing.listingType!.code,
                                      widget.listing.gender,
                                    ),
                                  ),
                                // Gender Badge
                                if (widget.listing.gender != null)
                                  GenderBadge(
                                    gender: widget.listing.gender!,
                                    size: 16,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    label: _shortGenderLabel(
                                      widget.listing.gender!,
                                    ),
                                  ),
                                // Price is shown only in the prominent price
                                // card below the title (no header duplicate).
                                // 3D room scan (available on iOS; show indicator on web too)
                                if ((kIsWeb || isIPhoneFormFactor(context)) &&
                                    (widget.listing.pointCloudUrl?.isNotEmpty ??
                                        false))
                                  const Room3dIconBadge(
                                    size: 16,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    label: "3D",
                                  ),
                              ],
                            ),
                          ),
                          // Favorite heart(s): explicit icon on favorites screen,
                          // or compact indicator on home / feeds ([FavoriteHeartToggle]).
                          if (widget.showHeartIcon ||
                              widget.showFavoriteIndicator)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FavoriteHeartToggle(
                                listenable: _favoriteListenable,
                                shouldShow: (ctx) => PeerInteractionEligibility
                                    .mayInteractWithPublisher(
                                  publisherUserId: widget.listing.userId,
                                ),
                                resolveIsFavorite: (ctx) => widget.showHeartIcon
                                    ? (widget.forceFavorite ??
                                        FavoritesState().isFavorite(
                                          widget.listing.id,
                                        ))
                                    : widget.forceFavorite == true
                                        ? true
                                        : FavoritesState().isFavorite(
                                            widget.listing.id,
                                          ),
                                hiddenBuilder: (_) => const SizedBox.shrink(),
                                onToggle: _onListingFavoriteToggle,
                                builder: (context, ui) {
                                  if (widget.showHeartIcon) {
                                    return SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: ui.onTap,
                                            child: const SizedBox(
                                              width: 48,
                                              height: 48,
                                            ),
                                          ),
                                          IgnorePointer(
                                            child: AnimatedBuilder(
                                              animation: ui.pulse.listenable,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: ui.pulse.scale,
                                                  child: ThemeIcon(
                                                    ui.isFavorite
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: ui.isFavorite
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
                                        ],
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: ui.onTap,
                                          child: const SizedBox(
                                            width: 48,
                                            height: 48,
                                          ),
                                        ),
                                        IgnorePointer(
                                          child: AnimatedBuilder(
                                            animation: ui.pulse.listenable,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: ui.pulse.scale,
                                                child: child,
                                              );
                                            },
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              reverseDuration: const Duration(
                                                milliseconds: 180,
                                              ),
                                              switchInCurve: Curves.elasticOut,
                                              switchOutCurve: Curves.easeInBack,
                                              transitionBuilder:
                                                  (child, animation) =>
                                                      ScaleTransition(
                                                scale: animation,
                                                child: child,
                                              ),
                                              child: SizedBox(
                                                key: ValueKey(
                                                  ui.isFavorite
                                                      ? "fav-on"
                                                      : "fav-off",
                                                ),
                                                width: 20,
                                                height: 20,
                                                child: ThemeIcon(
                                                  ui.isFavorite
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: ui.isFavorite
                                                      ? AppColors.favoriteActive
                                                      : AppColors
                                                          .favoriteInactive,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Fixed media cell plus flexible details. Avoid
                      // IntrinsicHeight here; this tile is a hot feed row and
                      // intrinsic layout adds an extra measurement pass.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Floor the media/info row height so sparse tiles
                          // (e.g. title + price only) don't visually shrink
                          // relative to fuller tiles.
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: _minMediaRowHeight,
                            ),
                            child: _buildThumbnail(context),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Padding(
                              // Keep text clear of the centered chevron.
                              padding: const EdgeInsets.only(right: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title
                                  Text(
                                    ListingUtils.usesPresetListingTitle(
                                      widget.listing.listingTypeId,
                                    )
                                        ? L10n.get(
                                            ListingUtils
                                                .presetListingTitleL10nKey(
                                              listingTypeId:
                                                  widget.listing.listingTypeId,
                                              gender: widget.listing.gender,
                                            ),
                                          )
                                        : widget.listing.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _getTitleTextColor(),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Prominent monthly-price card.
                                  if (widget.listing.price > 0) ...[
                                    const SizedBox(height: 10),
                                    _buildPriceCard(),
                                  ],
                                  // Location and metro on separate lines.
                                  if (widget.listing.location != null ||
                                      widget.listing.subwayStation != null) ...[
                                    const SizedBox(height: 12),
                                    ListenableBuilder(
                                      listenable: LanguageState(),
                                      builder: (context, child) {
                                        final hasLocation =
                                            widget.listing.location != null;
                                        final hasStation =
                                            widget.listing.subwayStation !=
                                                null;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (hasLocation)
                                              Row(
                                                children: [
                                                  const ThemeIcon(
                                                    Icons.location_on,
                                                    color: AppColors.error,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      _shortenDistrictSuffix(
                                                        _getLocalizedName(
                                                          nameUz: widget.listing
                                                              .location!.nameUz,
                                                          nameRu: widget.listing
                                                              .location!.nameRu,
                                                          nameEn: widget.listing
                                                              .location!.nameEn,
                                                        ),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            _getLocationTextColor(),
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (hasStation) ...[
                                              if (hasLocation)
                                                const SizedBox(height: 8),
                                              _buildSubwayStationDisplay(
                                                widget.listing.subwayStation!,
                                              ),
                                            ] else if (hasLocation)
                                              // Reserve the metro-row height
                                              // (8px gap + 20px icon row) so
                                              // tiles without a station match
                                              // the height of those with one.
                                              const SizedBox(
                                                height: 8 + 20,
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Footer rendered *below* the photo/info row, spanning
                      // the full tile width. Keeping it out of the
                      // media row means owner-only views/status can sit at the
                      // right edge without affecting the photo.
                      if (_hasTileFooter) ...[
                        const SizedBox(height: 12),
                        _buildTileFooter(),
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
    );

    final cardSurface = useLiquidGlass
        ? ThreeDElevatedSurface(
            baseColor: themeState.primaryColor,
            useLiquidGlass: true,
            borderRadius: borderRadius,
            liquidGlassShadows: themeState.isBlueTheme
                ? ThreeDSurfaceStyle.elevatedShadows(context)
                : null,
            child: tileInkWell,
          )
        : DecoratedBox(
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
              child: tileInkWell,
            ),
          );

    final cardWidget = RepaintBoundary(child: cardSurface);

    if (_isFeatured) {
      return AnimatedFeaturedBorder(
        borderWidth: 3.0,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: cardWidget,
      );
    }

    return cardWidget;
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

  /// Priority order for amenity icons. Lower index = shown first. The most
  /// useful "at a glance" features lead so that — once the visible list is
  /// capped to a single row — the icons that survive are the meaningful ones.
  static const List<String> _amenityPriority = <String>[
    "wifi",
    "air_conditioning",
    "bed",
    "oven",
  ];

  List<Amenity> _computeSortedAmenities(List<Amenity> amenities) {
    final sortedAmenities = List<Amenity>.from(amenities);

    int rank(Amenity a) {
      final index = _amenityPriority.indexOf(a.code ?? "");
      // Unprioritised amenities sort after the prioritised ones.
      return index == -1 ? _amenityPriority.length : index;
    }

    sortedAmenities.sort((a, b) {
      final rankCompare = rank(a).compareTo(rank(b));
      if (rankCompare != 0) return rankCompare;
      // Stable, predictable order within the same rank.
      return (a.code ?? "").compareTo(b.code ?? "");
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

  /// Green accent for the price card on dark (blue) tile backgrounds.
  static const Color _accentGreen = Color(0xFF35C26B);

  /// Darker sibling of [_accentGreen] for light-theme tiles (stronger contrast
  /// on pale surfaces).
  static const Color _accentGreenLightTheme = Color(0xFF25884B);

  Color _priceAccentGreen() =>
      ThemeState().isLightTheme ? _accentGreenLightTheme : _accentGreen;

  /// Branded illustration shown in the media slot when a listing has no photo.
  /// Resolution-aware (`2.0x` / `3.0x` variants live alongside the base asset).
  /// Dark artwork suits the blue/dark themes; [_noPhotoPlaceholderAssetLight]
  /// is the airy variant for the light theme.
  static const String _noPhotoPlaceholderAsset =
      "assets/images/uydosh_no_photo_placeholder.png";
  static const String _noPhotoPlaceholderAssetLight =
      "assets/images/uydosh_light_no_photo_placeholder.png";

  /// Dedicated "no photo yet" artwork for the *room needed* listing type
  /// (listingTypeId == 1) — a seeker-themed illustration shown instead of the
  /// generic house when a listing of that type has no photo.
  static const String _roomNeededPlaceholderAsset =
      "assets/images/uydosh_room_needed_no_photo_placeholder.png";
  static const String _roomNeededPlaceholderAssetLight =
      "assets/images/uydosh_light_room_needed_no_photo_placeholder.png";

  /// Listing type id for "room needed" (see [ListingUtils]). Listings of this
  /// type use the seeker-themed placeholder above.
  static const int _roomNeededListingTypeId = 1;

  /// Short, badge-friendly label for a listing type code (e.g. "Сосед").
  /// The roommate label is gendered where the language distinguishes it
  /// (ru: "Сосед" / "Соседка"). Returns null for unknown codes so the badge
  /// stays icon-only.
  String? _shortListingTypeLabel(String code, int? gender) {
    switch (code) {
      case "roommate_needed":
        return gender == 2
            ? L10n.get("listing_type_short_roommate_needed_female")
            : L10n.get("listing_type_short_roommate_needed");
      case "room_needed":
        return L10n.get("listing_type_short_room_needed");
      default:
        return null;
    }
  }

  /// Gender label for the tile badge. Reads as the object of the listing
  /// type phrase (ru accusative: "Парня" / "Девушку"), so it pairs with the
  /// "Ищем Соседа/Соседку" type badge. Null for unspecified gender.
  String? _shortGenderLabel(int gender) {
    switch (gender) {
      case 1:
        return L10n.get("gender_badge_male");
      case 2:
        return L10n.get("gender_badge_female");
      default:
        return null;
    }
  }

  /// Prominent monthly-price card shown under the title. The amount respects
  /// the user's currency preference; the unit suffix follows it.
  Widget _buildPriceCard() {
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final amount = PriceRangeHelper.formatListingPriceRangeWithCurrency(
          widget.listing.price,
          widget.listing.price,
        );
        final isUsd =
            PriceDisplaySettingsState().currency == PriceDisplayCurrency.usd;
        final unit = L10n.get(
          isUsd ? "price_unit_usd_per_month" : "price_unit_uzs_per_month",
        );
        final priceGreen = _priceAccentGreen();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: priceGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: priceGreen.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(
                Icons.payments,
                size: 16,
                color: priceGreen,
                useThemeColor: false,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: priceGreen,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: priceGreen.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Fixed width of the leading photo column. Shared between the thumbnail
  /// and the amenity strip (which indents by this much to line up under the
  /// info column).
  static const double _thumbWidth = 118;

  /// Minimum height of the media/info row. Mirrors the natural height of a
  /// "full" tile (title + price + location + metro) so that sparse tiles —
  /// e.g. ones with only a title and price — don't render visibly shorter
  /// than their neighbours. Applied via a `ConstrainedBox` around the
  /// thumbnail inside the `IntrinsicHeight` row.
  static const double _minMediaRowHeight = 120;

  bool get _hasAmenities =>
      widget.listing.amenities != null && widget.listing.amenities!.isNotEmpty;

  bool get _hasTileFooter => _hasAmenities || widget.showActiveStatus;

  Widget _buildTileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: _amenityDividerColor()),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _hasAmenities
                  ? _buildAmenityIcons()
                  : const SizedBox.shrink(),
            ),
            if (widget.showActiveStatus) ...[
              const SizedBox(width: 12),
              _buildOwnerFooterStatus(),
            ],
          ],
        ),
      ],
    );
  }

  /// Amenity icons (no labels) rendered inside the tile footer — compact,
  /// but still enough to hint at the listing's features.
  Widget _buildAmenityIcons() {
    final amenities = _cachedSortedAmenities ?? const <Amenity>[];
    if (amenities.isEmpty) return const SizedBox.shrink();
    final fg = _getAmenityIconColor();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final amenity in amenities)
          ThemeIcon(_getAmenityIcon(amenity), size: 20, color: fg),
      ],
    );
  }

  Widget _buildOwnerFooterStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<_ListingViewCountState>(
          valueListenable: _viewCountState,
          builder: (context, vc, _) {
            if (vc.loading) {
              return const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textGrey600,
                  ),
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
              widget.listing.isActive ? "listing_active" : "listing_inactive",
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
    );
  }

  Color _amenityDividerColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white.withValues(alpha: 0.12);
    }
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);
  }

  // Theme-dependent color method for title text
  Color _getTitleTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87; // Default dark text for light theme
    }
  }

  // Theme-dependent color method for description text
  /// Leading photo thumbnail shown on the left of the tile. Uses the primary
  /// photo when available (falling back to the first), otherwise renders a
  /// neutral placeholder so every tile keeps a consistent left column.
  Widget _buildThumbnail(BuildContext context) {
    // Fixed square media cell (`thumbWidth` x `thumbWidth`). We use `Image`
    // with a `CachedNetworkImageProvider` (not the `CachedNetworkImage`
    // widget) so the subtree reports clean intrinsic dimensions for the
    // `IntrinsicHeight` pass.
    const double thumbWidth = _thumbWidth;
    final scheme = Theme.of(context).colorScheme;
    final photos = widget.listing.photos;
    final hasPhoto = photos != null && photos.isNotEmpty;

    Widget content;
    if (hasPhoto) {
      // Decode cap: one bound only (or maxWidth/maxHeight on the provider).
      // Both width *and* height on [ResizeImage] use `ResizeImagePolicy.exact`
      // and squash non-square photos before [BoxFit.cover] can crop them.
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final decodePx = (thumbWidth * dpr).round();
      content = Image(
        image: CachedNetworkImageProvider(
          _buildPhotoUrl(_primaryPhotoUrl(photos)),
          maxWidth: decodePx,
          maxHeight: decodePx,
        ),
        width: thumbWidth,
        height: thumbWidth,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return ColoredBox(color: scheme.onSurface.withValues(alpha: 0.06));
        },
        errorBuilder: (context, error, stackTrace) =>
            _thumbnailPlaceholder(scheme),
      );
    } else {
      content = _thumbnailPlaceholder(scheme);
    }

    // Neumorphic "raised" treatment — same light/dark shadow recipe as the
    // card itself (scaled down), so the photo looks softly extruded from the
    // tile surface.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkShadow = Colors.black.withValues(alpha: isDark ? 0.45 : 0.22);
    final lightShadow = Colors.white.withValues(
      alpha: LiquidGlassRendering.neumorphicLightShadowAlpha(context),
    );
    const radius = BorderRadius.all(Radius.circular(14));

    // The media is a fixed square (`thumbWidth` x `thumbWidth`) so the square
    // artwork/photos fit the frame exactly (no letterbox, no distortion).
    // `Align` (vertically centered, `widthFactor: 1`) lets the surrounding
    // `IntrinsicHeight`/stretch row be taller than the square without
    // stretching it — the square stays centered and any taller photo is
    // `cover`-cropped to the square instead.
    return Align(
      alignment: Alignment.center,
      widthFactor: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: lightShadow,
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: darkShadow,
              offset: const Offset(4, 4),
              blurRadius: 9,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: thumbWidth,
            height: thumbWidth,
            child: Stack(
              children: [Positioned.fill(child: content)],
            ),
          ),
        ),
      ),
    );
  }

  /// Branded "no photo yet" illustration (house + "Фото скоро" chip baked into
  /// the artwork). Resolution variants (2.0x / 3.0x) live next to the asset and
  /// are picked automatically. Falls back to a neutral tile if the asset fails.
  Widget _thumbnailPlaceholder(ColorScheme scheme) {
    final isLight = ThemeState().isLightTheme;
    final isRoomNeeded =
        widget.listing.listingTypeId == _roomNeededListingTypeId;
    final String asset;
    if (isRoomNeeded) {
      asset = isLight
          ? _roomNeededPlaceholderAssetLight
          : _roomNeededPlaceholderAsset;
    } else {
      asset =
          isLight ? _noPhotoPlaceholderAssetLight : _noPhotoPlaceholderAsset;
    }
    // Backdrop gradient sampled from the artwork's own background so the
    // letterbox area (when the media cell is taller/shorter than the image)
    // blends seamlessly — the illustration is shown with `contain` so its
    // aspect ratio is never distorted or cropped.
    final gradient = isLight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB1BFD5), Color(0xFFAABBD3)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3962), Color(0xFF112548)],
          );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: ThemeIcon(
            Icons.photo_outlined,
            size: 32,
            color: scheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  String _primaryPhotoUrl(List<Photo> photos) {
    final primary = photos.where((p) => p.isPrimary);
    return (primary.isNotEmpty ? primary.first : photos.first).photoUrl;
  }

  /// Resolves a stored photo path to a full URL. Absolute URLs are returned
  /// unchanged; relative paths are prefixed with the API base path.
  String _buildPhotoUrl(String photoUrl) {
    if (photoUrl.startsWith("http://") || photoUrl.startsWith("https://")) {
      return photoUrl;
    }
    return "${EnvironmentUtil.basePath}$photoUrl";
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

  // Theme-dependent color method for arrow icon
  Color _getArrowIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight.withValues(alpha: 0.5);
    } else {
      return AppColors.textGrey400; // Default grey for light theme
    }
  }

  // Build subway station display with transfer station support
  Widget _buildSubwayStationDisplay(SubwayStationDetail station) {
    final transferInfo = MetroCache.getTransferStationInfo(station.id);

    if (transferInfo != null) {
      // Transfer station: render both line-colored icons side by side, then
      // only the main station's name. Which side counts as "main" depends on
      // the active search context — when the user filtered by a specific
      // line, that line's station is the main one.
      final connectedStation = SubwayStationDetail(
        id: transferInfo["connectedStationId"],
        nameUz: transferInfo["connectedStationName"],
        nameRu: transferInfo["connectedStationNameRu"],
        nameEn: transferInfo["connectedStationNameEn"],
        line: transferInfo["connectedStationLine"],
      );

      final mainStation = (widget.searchLineId != null &&
              connectedStation.line == widget.searchLineId)
          ? connectedStation
          : station;
      final transferStation =
          (mainStation.id == station.id) ? connectedStation : station;

      return Row(
        children: [
          // Lock both line icons to the same square footprint so they render
          // at identical visual size — without this, baseline alignment from
          // the trailing Expanded text can subtly shrink one of them.
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: ThemeIcon(
                Icons.train,
                color: _getLineColor(transferStation.line),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: ThemeIcon(
                Icons.train,
                color: _getLineColor(mainStation.line),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              MetroCache.formatStationLabel(
                _getLocalizedName(
                  nameUz: mainStation.nameUz,
                  nameRu: mainStation.nameRu,
                  nameEn: mainStation.nameEn,
                ),
                LanguageState().currentLanguage,
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
              MetroCache.formatStationLabel(
                _getLocalizedName(
                  nameUz: station.nameUz,
                  nameRu: station.nameRu,
                  nameEn: station.nameEn,
                ),
                LanguageState().currentLanguage,
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
