import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/string_helper.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/listing_type_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/gender_badge.dart";
import "package:uy_dosh/presentation/widgets/photo_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/animated_featured_border.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/widgets/common/language_aware_date_picker.dart";
import "package:flutter/cupertino.dart";

class ListingTile extends StatefulWidget {
  const ListingTile({
    super.key,
    required this.listing,
    this.forceFavorite, // Optional parameter
    this.onFavoriteRemoved, // Optional callback
    this.showHeartIcon =
        false, // Default to false - only show on favorites screen
    this.searchLineId, // Optional parameter to indicate which line was used for search
  });

  final Listing listing;
  final bool? forceFavorite; // New parameter to force heart to be red
  final VoidCallback? onFavoriteRemoved; // Callback when favorite is removed
  final bool showHeartIcon; // New parameter to control heart icon visibility
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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
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
    final cardWidget = Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider(
                    create:
                        (context) =>
                            ListingDetailBloc(getIt<IListingService>()),
                    child: ListingDetailScreen(listingId: widget.listing.id),
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                                padding: const EdgeInsets.all(6),
                              ),
                              const SizedBox(width: 10),
                            ],
                            // Gender Badge
                            if (widget.listing.gender != null) ...[
                              GenderBadge(gender: widget.listing.gender!),
                              const SizedBox(width: 10),
                            ],
                            // Photo indicator icon
                            if (widget.listing.photos != null &&
                                widget.listing.photos!.isNotEmpty) ...[
                              PhotoIcon(),
                            ],
                          ],
                        ),
                      ),
                      // Heart icon in top-right corner - only show when showHeartIcon is true and user is authenticated
                      if (widget.showHeartIcon)
                        ListenableBuilder(
                          listenable: AuthenticationState(),
                          builder: (context, child) {
                            final isAuthenticated =
                                AuthenticationState().isAuthenticated;
                            if (!isAuthenticated) {
                              return const SizedBox.shrink();
                            }

                            return ListenableBuilder(
                              listenable: FavoritesState(),
                              builder: (context, child) {
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
                                                favoritesState.toggleFavorite(
                                                  widget.listing.id,
                                                );

                                                // Only trigger animation when adding to favorites (not when removing)
                                                if (!wasFavorite) {
                                                  _pulsateHeart();
                                                }

                                                // If this was a removal and we have a callback, call it
                                                if (wasFavorite &&
                                                    widget.onFavoriteRemoved !=
                                                        null) {
                                                  widget.onFavoriteRemoved!();
                                                }

                                                // Show success message to user
                                                if (context.mounted) {
                                                  ToastTheme.showSuccess(
                                                    context,
                                                    message: StringHelper.getCurrent(
                                                      wasFavorite
                                                          ? "favorite_removed_success"
                                                          : "favorite_added_success",
                                                      context,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Show error message to user
                                                if (context.mounted) {
                                                  ToastTheme.showError(
                                                    context,
                                                    message:
                                                        StringHelper.getCurrent(
                                                          "favorite_toggle_error",
                                                          context,
                                                        ),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              // Show error message to user
                                              if (context.mounted) {
                                                ToastTheme.showError(
                                                  context,
                                                  message: StringHelper.getCurrent(
                                                    "favorite_toggle_network_error",
                                                    context,
                                                  ),
                                                );
                                              }
                                            } finally {
                                              // Clear loading state
                                              if (mounted) {
                                                setState(() {
                                                  _isTogglingFavorite = false;
                                                });
                                              }
                                            }
                                          },
                                  child: Opacity(
                                    opacity: _isTogglingFavorite ? 0.6 : 1.0,
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: AnimatedBuilder(
                                        animation: _heartScaleAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _heartScaleAnimation.value,
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
                                                    : Icon(
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
                            );
                          },
                        )
                      else
                        const SizedBox(
                          width: 51, // 27 (icon size) + 24 (padding: 12 * 2)
                          height: 51, // 27 (icon size) + 24 (padding: 12 * 2)
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
                      widget.listing.title,
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
                  if (widget.listing.description != null &&
                      widget.listing.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        right: 40,
                      ), // Add right padding to avoid arrow overlap
                      child: Text(
                        widget.listing.description!,
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
                  // Location and Subway Station Information
                  if (widget.listing.location != null ||
                      widget.listing.subwayStation != null) ...[
                    ListenableBuilder(
                      listenable: LanguageState(),
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location and Metro info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location (District)
                                if (widget.listing.location != null) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _getLocalizedName(
                                            nameUz:
                                                widget.listing.location!.nameUz,
                                            nameRu:
                                                widget.listing.location!.nameRu,
                                            nameEn:
                                                widget.listing.location!.nameEn,
                                          ),
                                          style: TextStyle(
                                            fontSize:
                                                14, // 12 * 1.2 = 14.4, rounded to 14
                                            color: _getLocationTextColor(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                // Subway Station (below district)
                                if (widget.listing.subwayStation != null) ...[
                                  const SizedBox(height: 4),
                                  _buildSubwayStationDisplay(
                                    widget.listing.subwayStation!,
                                  ),
                                ],
                              ],
                            ),
                            // Amenities icons below location and metro
                            if (widget.listing.amenities != null &&
                                widget.listing.amenities!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children:
                                    _getSortedAmenities(
                                          widget.listing.amenities!,
                                        )
                                        .map(
                                          (amenity) => Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: Icon(
                                              _getAmenityIcon(amenity),
                                              size: 20,
                                              color: _getAmenityIconColor(),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                            // Price range display
                            if (widget.listing.minPrice != null ||
                                widget.listing.maxPrice != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.money_dollar_circle,
                                    size: 22,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatPriceRange(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Private Room indicator below price
                            if (widget.listing.privateRoom == true) ...[
                              const SizedBox(height: 8),
                              ListenableBuilder(
                                listenable: LanguageState(),
                                builder: (context, child) {
                                  return Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.lock_fill,
                                        size: 20,
                                        color: _getPrivateRoomIconColor(),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        StringHelper.get(
                                          "private_room",
                                          LanguageState().currentLanguage,
                                        ),
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
                            // Move-in Date
                            if (widget.listing.moveInDate != null &&
                                widget.listing.moveInDate!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.square_arrow_right,
                                    size: 22,
                                    color: _getDateTextColor(),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${StringHelper.get("move_in_date_label", LanguageState().currentLanguage)} ${_formatMoveInDate()}",
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
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 24, // 16 * 1.5 = 24
                  color: _getArrowIconColor(),
                ),
              ),
            ),
          ],
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
    final minPrice = widget.listing.minPrice;
    final maxPrice = widget.listing.maxPrice;

    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return minPrice.toString();
      } else {
        return "$minPrice - $maxPrice";
      }
    } else if (minPrice != null) {
      return "от $minPrice";
    } else if (maxPrice != null) {
      return "до $maxPrice";
    } else {
      return "";
    }
  }

  String _formatMoveInDate() {
    if (widget.listing.moveInDate == null ||
        widget.listing.moveInDate!.isEmpty) {
      return "";
    }

    try {
      final date = DateTime.parse(widget.listing.moveInDate!);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return StringHelper.get("today", LanguageState().currentLanguage);
      } else if (difference == 1) {
        return StringHelper.get("tomorrow", LanguageState().currentLanguage);
      } else if (difference > 0 && difference <= 7) {
        return AppStrings.getWithParams(
          "in_days",
          LanguageState().currentLanguage,
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
        final localizedMonth = StringHelper.get(
          monthKeys[date.month - 1],
          LanguageState().currentLanguage,
        );
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
        return StringHelper.get("monday", LanguageState().currentLanguage);
      case 2:
        return StringHelper.get("tuesday", LanguageState().currentLanguage);
      case 3:
        return StringHelper.get("wednesday", LanguageState().currentLanguage);
      case 4:
        return StringHelper.get("thursday", LanguageState().currentLanguage);
      case 5:
        return StringHelper.get("friday", LanguageState().currentLanguage);
      case 6:
        return StringHelper.get("saturday", LanguageState().currentLanguage);
      case 7:
        return StringHelper.get("sunday", LanguageState().currentLanguage);
      default:
        return "";
    }
  }

  /// Gets localized month name using LanguageState
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return StringHelper.get("january", LanguageState().currentLanguage);
      case 2:
        return StringHelper.get("february", LanguageState().currentLanguage);
      case 3:
        return StringHelper.get("march", LanguageState().currentLanguage);
      case 4:
        return StringHelper.get("april", LanguageState().currentLanguage);
      case 5:
        return StringHelper.get("may", LanguageState().currentLanguage);
      case 6:
        return StringHelper.get("june", LanguageState().currentLanguage);
      case 7:
        return StringHelper.get("july", LanguageState().currentLanguage);
      case 8:
        return StringHelper.get("august", LanguageState().currentLanguage);
      case 9:
        return StringHelper.get("september", LanguageState().currentLanguage);
      case 10:
        return StringHelper.get("october", LanguageState().currentLanguage);
      case 11:
        return StringHelper.get("november", LanguageState().currentLanguage);
      case 12:
        return StringHelper.get("december", LanguageState().currentLanguage);
      default:
        return "";
    }
  }

  List<Amenity> _getSortedAmenities(List<Amenity> amenities) {
    // Custom sorting: WiFi first, then air conditioning, then the rest
    final sortedAmenities = List<Amenity>.from(amenities);

    sortedAmenities.sort((a, b) {
      // WiFi gets highest priority (1)
      if (a.code == "wifi" && b.code != "wifi") return -1;
      if (a.code != "wifi" && b.code == "wifi") return 1;

      // Air conditioning gets second priority (2)
      if (a.code == "air_conditioning" &&
          b.code != "air_conditioning" &&
          b.code != "wifi")
        return -1;
      if (a.code != "air_conditioning" &&
          b.code == "air_conditioning" &&
          a.code != "wifi")
        return 1;

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
      return AppColors.textLight;
    } else {
      return AppColors.textGrey400; // Default grey for light theme
    }
  }

  // Theme-dependent color method for private room icon
  Color _getPrivateRoomIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.primary;
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
          Icon(Icons.train, color: _getLineColor(leftStation.line), size: 20),
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
          Icon(Icons.swap_horiz, color: _getLocationTextColor(), size: 16),
          const SizedBox(width: 4),
          Icon(Icons.train, color: _getLineColor(rightStation.line), size: 20),
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
          Icon(Icons.train, color: _getLineColor(station.line), size: 20),
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
