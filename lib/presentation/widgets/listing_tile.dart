import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
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
import "package:uy_dosh/domain/models/subway_station.dart";
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
import "package:uy_dosh/domain/utils/listing_utils.dart";
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
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final cardWidget = Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => BlocProvider(
                        create:
                            (context) =>
                                ListingDetailBloc(getIt<IListingService>()),
                        child: ListingDetailScreen(
                          listingId: widget.listing.id,
                        ),
                      ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
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
                                                        message:
                                                            StringHelper.getCurrent(
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
                                                      message:
                                                          StringHelper.getCurrent(
                                                            "favorite_toggle_network_error",
                                                            context,
                                                          ),
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
                      ListenableBuilder(
                        listenable: LanguageState(),
                        builder: (context, child) {
                          final locationRows = _buildLocationRows();
                          final stationRows = _buildStationRows();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (locationRows.isNotEmpty) ...locationRows,
                              if (locationRows.isNotEmpty &&
                                  stationRows.isNotEmpty)
                                const SizedBox(height: 6),
                              if (stationRows.isNotEmpty) ...stationRows,
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
      },
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
    final minPrice = widget.listing.minPrice;
    final maxPrice = widget.listing.maxPrice;

    if (minPrice == maxPrice) {
      return minPrice.toString();
    }
    return "$minPrice - $maxPrice";
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

  List<Widget> _buildLocationRows() {
    final currentLanguage = LanguageState().currentLanguage;
    final locationIds =
        widget.listing.locationIds ??
        (widget.listing.locationId != null
            ? [widget.listing.locationId!]
            : <int>[]);
    final names = <String>[];

    for (final locationId in locationIds) {
      final name = LocationCache.getLocationName(locationId, currentLanguage);
      if (name.isNotEmpty && name != "Unknown Location") {
        names.add(name);
      }
    }

    if (names.isEmpty && widget.listing.location != null) {
      names.add(
        _getLocalizedName(
          nameUz: widget.listing.location!.nameUz,
          nameRu: widget.listing.location!.nameRu,
          nameEn: widget.listing.location!.nameEn,
        ),
      );
    }

    if (names.isEmpty) {
      return [];
    }

    if (names.length >= 12) {
      final countLabel = StringHelper.get(
        "select_location",
        LanguageState().currentLanguage,
      );
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.error, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  countLabel,
                  style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return names
        .map(
          (name) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.error, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 14, color: _getLocationTextColor()),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildStationRows() {
    final stationIds =
        widget.listing.subwayStationIds ??
        (widget.listing.subwayStationId != null
            ? [widget.listing.subwayStationId!]
            : <int>[]);
    final stations = <int, SubwayStation>{};
    for (final stationId in stationIds) {
      final station = MetroCache.getStationById(stationId);
      if (station != null) {
        stations[stationId] = station;
      }
    }

    if (stations.isEmpty && widget.listing.subwayStation != null) {
      final station = widget.listing.subwayStation!;
      return [
        _buildStationRow(
          label: _buildStationLabel(
            stationId: station.id,
            nameUz: station.nameUz,
            nameRu: station.nameRu,
            nameEn: station.nameEn,
          ),
          lineColor: _getLineColor(station.line),
          boldParenthetical: false,
          boldCount: false,
        ),
      ];
    }

    if (stations.isEmpty) {
      return [];
    }

    final rows = <Widget>[];
    final selectedLines =
        stations.values.map((station) => station.line).toSet().toList()..sort();
    final fullLineSelections =
        selectedLines.where((line) => _hasFullLineSelected(stations, line));
    final fullLineStationIds = <int>{};
    for (final line in fullLineSelections) {
      fullLineStationIds.addAll(
        MetroCache.getStationsForLine(line).map((station) => station.id),
      );
      final label = LanguageAwareStringHelper.getCurrent(
        context,
        "line_all_stations",
      ).replaceAll("{line}", _getLineName(line));
      rows.add(
        _buildLineRow(
          label: label,
          lineColor: _getLineColor(line),
          boldParenthetical: true,
          boldCount: false,
        ),
      );
    }

    final stationsByLine = <int, List<SubwayStation>>{};
    for (final station in stations.values) {
      if (fullLineStationIds.contains(station.id)) {
        continue;
      }
      stationsByLine.putIfAbsent(station.line, () => []).add(station);
    }

    for (final line in stationsByLine.keys.toList()..sort()) {
      final lineStations = stationsByLine[line] ?? [];
      if (lineStations.length > 1) {
        final label = LanguageAwareStringHelper.getCurrent(
          context,
          "line_stations_count",
        )
            .replaceAll("{line}", _getLineName(line))
            .replaceAll("{count}", lineStations.length.toString());
        rows.add(
          _buildLineRow(
            label: label,
            lineColor: _getLineColor(line),
            boldParenthetical: false,
            boldCount: true,
          ),
        );
      } else if (lineStations.isNotEmpty) {
        final station = lineStations.first;
        rows.add(
          _buildStationRow(
            label: _buildStationLabel(
              stationId: station.id,
              nameUz: station.nameUz,
              nameRu: station.nameRu,
              nameEn: station.nameEn,
            ),
            lineColor: _getLineColor(station.line),
            boldParenthetical: false,
            boldCount: false,
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildLineRow({
    required String label,
    required Color lineColor,
    required bool boldParenthetical,
    required bool boldCount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(Icons.train, color: lineColor, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: _buildLabelSpans(
                  label,
                  boldParenthetical: boldParenthetical,
                  boldCount: boldCount,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationRow({
    required String label,
    required Color lineColor,
    required bool boldParenthetical,
    required bool boldCount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(Icons.train, color: lineColor, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: _buildLabelSpans(
                  label,
                  boldParenthetical: boldParenthetical,
                  boldCount: boldCount,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildLabelSpans(
    String label, {
    required bool boldParenthetical,
    required bool boldCount,
  }) {
    final baseStyle = TextStyle(fontSize: 14, color: _getLocationTextColor());
    final boldRanges = <List<int>>[];

    if (boldParenthetical) {
      final start = label.indexOf("(");
      final end = label.lastIndexOf(")");
      if (start != -1 && end != -1 && end > start) {
        boldRanges.add([start, end + 1]);
      }
    }

    if (boldCount) {
      final index = label.indexOf("·");
      if (index != -1) {
        boldRanges.add([index, label.length]);
      }
    }

    if (boldRanges.isEmpty) {
      return [TextSpan(text: label, style: baseStyle)];
    }

    boldRanges.sort((a, b) => a[0].compareTo(b[0]));
    final merged = <List<int>>[];
    for (final range in boldRanges) {
      if (merged.isEmpty || range[0] > merged.last[1]) {
        merged.add([range[0], range[1]]);
      } else {
        final nextEnd = range[1] > merged.last[1] ? range[1] : merged.last[1];
        merged.last[1] = nextEnd > label.length ? label.length : nextEnd;
      }
    }

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final range in merged) {
      final start = range[0].clamp(0, label.length);
      final end = range[1].clamp(0, label.length);
      if (start > cursor) {
        spans.add(
          TextSpan(text: label.substring(cursor, start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: label.substring(start, end),
          style: baseStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      );
      cursor = end;
    }
    if (cursor < label.length) {
      spans.add(TextSpan(text: label.substring(cursor), style: baseStyle));
    }

    return spans;
  }

  String _buildStationLabel({
    required int stationId,
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final stationName = _getLocalizedName(
      nameUz: nameUz,
      nameRu: nameRu,
      nameEn: nameEn,
    );
    final transferInfo = MetroCache.getTransferStationInfo(stationId);
    if (transferInfo == null) {
      return stationName;
    }
    final connectedName = _getLocalizedName(
      nameUz: transferInfo["connectedStationName"],
      nameRu: transferInfo["connectedStationNameRu"],
      nameEn: transferInfo["connectedStationNameEn"],
    );
    return "$stationName ↔ $connectedName";
  }

  bool _hasFullLineSelected(Map<int, SubwayStation> stations, int line) {
    final stationIdsForLine =
        MetroCache.getStationsForLine(line).map((station) => station.id).toSet();
    return stationIdsForLine.isNotEmpty &&
        stations.keys.toSet().containsAll(stationIdsForLine);
  }

  String _getLineName(int line) {
    final language = LanguageState().currentLanguage;
    final lineName = MetroCache.metroLineNames[line]?[language];
    if (lineName != null && lineName.isNotEmpty) {
      return lineName;
    }
    return line.toString();
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
}
