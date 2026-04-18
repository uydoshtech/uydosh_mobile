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
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/util/listing_contact_redaction.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
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
    this.showHeartIcon =
        false, // Default to false - only show on favorites screen
    this.showActiveStatus =
        false, // Default to false - only show on my listings screen
    this.searchLineId, // Optional parameter to indicate which line was used for search
  });

  final Listing listing;
  final bool? forceFavorite; // New parameter to force heart to be red
  final VoidCallback? onFavoriteRemoved; // Callback when favorite is removed
  final bool showHeartIcon; // New parameter to control heart icon visibility
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
  int? _viewCount;
  bool _isLoadingViewCount = false;
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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeInOut,
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
    _heartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadViewCount() async {
    if (_isLoadingViewCount) return;
    setState(() => _isLoadingViewCount = true);
    try {
      final count = await getIt<IListingService>().getListingViewCount(
        widget.listing.id,
      );
      if (mounted) {
        setState(() {
          _viewCount = count;
          _isLoadingViewCount = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingViewCount = false);
      }
    }
  }

  void _pulsateHeart() {
    // Pulsate 3 times
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse().then((_) {
        _heartAnimationController.forward().then((_) {
          _heartAnimationController.reverse().then((_) {
            _heartAnimationController.forward().then((_) {
              _heartAnimationController.reverse();
            });
          });
        });
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: ThemeState(),
        builder: (context, child) {
          final descriptionSnippet = _descriptionSnippetForPublicTile();
          final borderRadius = BorderRadius.circular(12);
          final scheme = Theme.of(context).colorScheme;
          final bg = scheme.surface;
          final darkShadow = Colors.black.withValues(
            alpha: 
            Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.20,
          );
          final lightShadow = Colors.white.withValues(
            alpha: 
            Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.65,
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
                onTap: () => context.pushListingDetail(widget.listing.id),
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
                        // Views count
                        if (_isLoadingViewCount)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textGrey600,
                            ),
                          )
                        else if (_viewCount != null)
                          Padding(
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
                                  L10n.get("listing_views_by_others")
                                  .replaceAll("{count}", _viewCount.toString()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textGrey600,
                                  ),
                                ),
                              ],
                            ),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                  const SizedBox(width: 10),
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
                                FavoritesState().listenableFor(
                                  widget.listing.id,
                                ),
                              ]),
                              builder: (context, child) {
                                final isAuthenticated =
                                    AuthenticationState().isAuthenticated;
                                if (!isAuthenticated) {
                                  return const SizedBox.shrink();
                                }

                                final favoritesState = FavoritesState();
                                // Use forceFavorite parameter if provided, otherwise check FavoritesState
                                final isFavorite =
                                    widget.forceFavorite ??
                                    favoritesState.isFavorite(
                                      widget.listing.id,
                                    );
                                return GestureDetector(
                                      onTap:
                                          _isTogglingFavorite
                                              ? null
                                              : () async {
                                                // Add haptic feedback
                                                HapticFeedbackUtils.impact();

                                                // For favorites screen, we know the item is currently favorited
                                                // For other screens, check the actual state
                                                final wasFavorite =
                                                    widget.forceFavorite ??
                                                    favoritesState.isFavorite(
                                                      widget.listing.id,
                                                    );

                                                // Set loading state
                                                setState(() {
                                                  _isTogglingFavorite = true;
                                                });

                                                // Call API to toggle favorite
                                                try {
                                                  final favoriteService =
                                                      getIt<IFavoriteService>();

                                                  final success =
                                                      await favoriteService
                                                          .toggleFavorite(
                                                            widget.listing.id,
                                                          );

                                                  if (success) {
                                                    // Update local state only if API call succeeds
                                                    favoritesState
                                                        .toggleFavorite(
                                                          widget.listing.id,
                                                        );

                                                    // Only trigger animation when adding to favorites (not when removing)
                                                    if (!wasFavorite) {
                                                      _pulsateHeart();
                                                    }

                                                    // If this was a removal and we have a callback, call it
                                                    if (wasFavorite &&
                                                        widget
                                                                .onFavoriteRemoved !=
                                                            null) {
                                                      widget
                                                          .onFavoriteRemoved!();
                                                    }

                                                    // Show success message to user
                                                    if (context.mounted) {
                                                      ToastTheme.showSuccess(
                                                        context,
                                                        message: L10n.get(
                                                        wasFavorite
                                                            ? "favorite_removed_success"
                                                            : "favorite_added_success",
                                                      ),
                                                      );
                                                    }
                                                  } else {
                                                    // Show error message to user
                                                    if (context.mounted) {
                                                      ToastTheme.showError(
                                                        context,
                                                        message: L10n.get("favorite_toggle_error"),
                                                      );
                                                    }
                                                  }
                                                } catch (e) {
                                                  // Show error message to user
                                                  if (context.mounted) {
                                                    ToastTheme.showError(
                                                      context,
                                                      message: L10n.get("favorite_toggle_network_error"),
                                                  );
                                                  }
                                                } finally {
                                                  // Clear loading state
                                                  if (mounted) {
                                                    setState(() {
                                                      _isTogglingFavorite =
                                                          false;
                                                    });
                                                  }
                                                }
                                              },
                                      child: Opacity(
                                        opacity:
                                            _isTogglingFavorite ? 0.6 : 1.0,
                                        child: Container(
                                          padding: const EdgeInsets.all(12.0),
                                          child: AnimatedBuilder(
                                            animation: _heartScaleAnimation,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale:
                                                    _heartScaleAnimation.value,
                                                child:
                                                    _isTogglingFavorite
                                                        ? SizedBox(
                                                          width: 27,
                                                          height: 27,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<
                                                              Color
                                                            >(
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
                                                          color:
                                                              isFavorite
                                                                  ? AppColors
                                                                      .favoriteActive
                                                                  : AppColors
                                                                      .favoriteInactive,
                                                          size: 27,
                                                        ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                          else
                            const SizedBox(
                              width: 51, // 27 (icon size) + 24 (padding: 12 * 2)
                              height:
                                  51, // 27 (icon size) + 24 (padding: 12 * 2)
                            ),
                        ],
                      ),
                      // Title
                      if (widget.listing.listingType != null) ...[
                        const SizedBox(height: 6),
                      ],
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.listing.location != null) ...[
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
                                              _getLocalizedName(
                                                nameUz:
                                                    widget
                                                        .listing
                                                        .location!
                                                        .nameUz,
                                                nameRu:
                                                    widget
                                                        .listing
                                                        .location!
                                                        .nameRu,
                                                nameEn:
                                                    widget
                                                        .listing
                                                        .location!
                                                        .nameEn,
                                              ),
                                              style: TextStyle(
                                                fontSize:
                                                    14, // 12 * 1.2 = 14.4, rounded to 14
                                                color:
                                                    _getLocationTextColor(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (widget.listing.subwayStation !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      _buildSubwayStationDisplay(
                                        widget.listing.subwayStation!,
                                      ),
                                    ],
                                  ],
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
                          const SizedBox(height: 8),
                        Row(
                          children: (_cachedSortedAmenities ?? [])
                              .map(
                                (amenity) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ThemeIcon(
                                    _getAmenityIcon(amenity),
                                    size: 20,
                                    color: _getAmenityIconColor(),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (widget.listing.price > 0) ...[
                        if (widget.listing.location != null ||
                            widget.listing.subwayStation != null ||
                            (widget.listing.amenities != null &&
                                widget.listing.amenities!.isNotEmpty))
                          const SizedBox(height: 8),
                        Row(
                          children: [
                            const ThemeIcon(
                              CupertinoIcons.money_dollar_circle,
                              size: 22,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatPriceRange(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (widget.listing.privateRoom ?? false) ...[
                        if (widget.listing.location != null ||
                            widget.listing.subwayStation != null ||
                            (widget.listing.amenities != null &&
                                widget.listing.amenities!.isNotEmpty) ||
                            widget.listing.price > 0)
                          const SizedBox(height: 8),
                        ListenableBuilder(
                          listenable: LanguageState(),
                          builder: (context, child) {
                            return Row(
                              children: [
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
                            );
                          },
                        ),
                      ],
                      if (widget.listing.moveInDate != null &&
                          widget.listing.moveInDate!.isNotEmpty) ...[
                        if (widget.listing.location != null ||
                            widget.listing.subwayStation != null ||
                            (widget.listing.amenities != null &&
                                widget.listing.amenities!.isNotEmpty) ||
                            widget.listing.price > 0 ||
                            (widget.listing.privateRoom ?? false))
                          const SizedBox(height: 8),
                        Row(
                          children: [
                            ThemeIcon(
                              CupertinoIcons.square_arrow_right,
                              size: 22,
                              color: _getDateTextColor(),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${L10n.get("move_in_date_label")} ${_cachedFormattedMoveInDate ?? ""}",
                              style: TextStyle(
                                fontSize: 14,
                                color: _getDateTextColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                      size: 24, // 16 * 1.5 = 24
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

  String _formatPriceRange() {
    return "${widget.listing.price} y.e.";
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
        return L10n.getWithParams(
          "in_days",
          params: {"days": difference.toString()},
        );
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
      // Blue theme - use white for icons
      return AppColors.textLight;
    } else if (ThemeState().isLightTheme) {
      // Light theme - use black for icons
      return Colors.black;
    } else {
      // Default theme - use primary icon color
      return AppColors.iconPrimary; // This is Color(0xFF6B46C1)
    }
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
  Color _getDescriptionTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
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
      return AppColors.textLight;
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
          Text(
            _getLocalizedName(
              nameUz: leftStation.nameUz,
              nameRu: leftStation.nameRu,
              nameEn: leftStation.nameEn,
            ),
            style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
          ),
          const SizedBox(width: 4),
          ThemeIcon(Icons.swap_horiz, color: _getLocationTextColor(), size: 16),
          const SizedBox(width: 4),
          ThemeIcon(Icons.train, color: _getLineColor(rightStation.line), size: 20),
          const SizedBox(width: 4),
          Text(
            _getLocalizedName(
              nameUz: rightStation.nameUz,
              nameRu: rightStation.nameRu,
              nameEn: rightStation.nameEn,
            ),
            style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
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
            ),
          ),
        ],
      );
    }
  }
}
