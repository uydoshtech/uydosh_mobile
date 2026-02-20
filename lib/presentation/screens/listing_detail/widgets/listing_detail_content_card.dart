import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";

/// Main content card for listing detail (header, title, description, location, amenities, dates).
class ListingDetailContentCard extends StatefulWidget {
  const ListingDetailContentCard({
    required this.listingDetail,
    required this.currentLanguage,
    required this.formatMoveInDate,
    required this.getLocalizedName,
    super.key,
  });

  final ListingDetail listingDetail;
  final String currentLanguage;
  final String Function(BuildContext context, String moveInDate) formatMoveInDate;
  final String Function({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    required String language,
  }) getLocalizedName;

  @override
  State<ListingDetailContentCard> createState() =>
      _ListingDetailContentCardState();
}

class _ListingDetailContentCardState extends State<ListingDetailContentCard> {
  bool _detailsExpanded = true;

  Widget _buildSubwayStationDisplay(SubwayStationDetail station) {
    final transferInfo = MetroCache.getTransferStationInfo(station.id);

    if (transferInfo != null) {
      final connectedStation = SubwayStationDetail(
        id: transferInfo["connectedStationId"] as int,
        nameUz: transferInfo["connectedStationName"] as String,
        nameRu: transferInfo["connectedStationNameRu"] as String,
        nameEn: transferInfo["connectedStationNameEn"] as String,
        line: transferInfo["connectedStationLine"] as int,
      );

      return Row(
        children: [
          Icon(
            Icons.train,
            color: ListingDetailThemeHelper.lineColor(station.line),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            widget.getLocalizedName(
              nameUz: station.nameUz,
              nameRu: station.nameRu,
              nameEn: station.nameEn,
              language: widget.currentLanguage,
            ),
            style: TextStyle(
              fontSize: 15,
              color: ListingDetailThemeHelper.locationTextColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.swap_horiz,
            color: ListingDetailThemeHelper.locationTextColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.train,
            color: ListingDetailThemeHelper.lineColor(connectedStation.line),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            widget.getLocalizedName(
              nameUz: connectedStation.nameUz,
              nameRu: connectedStation.nameRu,
              nameEn: connectedStation.nameEn,
              language: widget.currentLanguage,
            ),
            style: TextStyle(
              fontSize: 15,
              color: ListingDetailThemeHelper.locationTextColor,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.train,
            color: ListingDetailThemeHelper.lineColor(station.line),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.getLocalizedName(
                nameUz: station.nameUz,
                nameRu: station.nameRu,
                nameEn: station.nameEn,
                language: widget.currentLanguage,
              ),
              style: TextStyle(
                fontSize: 15,
                color: ListingDetailThemeHelper.locationTextColor,
              ),
            ),
          ),
        ],
      );
    }
  }

  String _getGenderText(int gender) {
    switch (gender) {
      case 1:
        return L10n.get("male");
      case 2:
        return L10n.get("female");
      default:
        return L10n.get("other");
    }
  }

  IconData _getGenderIcon(int gender) {
    switch (gender) {
      case 1:
        return Icons.male;
      case 2:
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  String _getAmenityLocalizedName(Amenity amenity) {
    switch (widget.currentLanguage) {
      case "ru":
        return amenity.nameRu;
      case "uz":
        return amenity.nameUz;
      case "en":
      default:
        return amenity.nameEn;
    }
  }

  IconData _getAmenityIcon(Amenity amenity) {
    if (amenity.code != null && amenity.code!.isNotEmpty) {
      return AmenityIconHelper.getIcon(amenity.code!);
    }
    return Icons.home;
  }

  void _showAmenityBubble(
    BuildContext context,
    Amenity amenity,
    Offset globalPosition,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => overlayEntry.remove(),
          ),
          Positioned(
            left: globalPosition.dx.clamp(12.0, MediaQuery.of(context).size.width - 150),
            top: globalPosition.dy - 48,
            child: GestureDetector(
              onTap: () => overlayEntry.remove(),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeState().isBlueTheme
                        ? Colors.white
                        : Theme.of(context).colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getAmenityLocalizedName(amenity),
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeState().isBlueTheme
                          ? Colors.black
                          : Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Widget _buildAmenityChip(BuildContext context, Amenity amenity) {
    return GestureDetector(
      onTapDown: (details) => _showAmenityBubble(
        context,
        amenity,
        details.globalPosition,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ListingDetailThemeHelper.amenityChipBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ListingDetailThemeHelper.amenityChipBorderColor,
            width: 1,
          ),
        ),
        child: ThemeIconFactory.detail(
          icon: _getAmenityIcon(amenity),
          size: 18,
          color: ListingDetailThemeHelper.amenityIconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ListingTypeBadge(
                  listingTypeCode: widget.listingDetail.listingType.code,
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                if (widget.listingDetail.gender != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeState().isLightTheme
                          ? null
                          : ListingDetailThemeHelper.genderColor(
                              widget.listingDetail.gender!,
                            ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ListingDetailThemeHelper.genderColor(
                          widget.listingDetail.gender!,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ThemeIconFactory.detail(
                          icon: _getGenderIcon(widget.listingDetail.gender!),
                          color: ListingDetailThemeHelper.genderColor(
                            widget.listingDetail.gender!,
                          ),
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _getGenderText(widget.listingDetail.gender!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ListingDetailThemeHelper.genderColor(
                              widget.listingDetail.gender!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                PriceRangeBadge(
                  minPrice: widget.listingDetail.minPrice,
                  maxPrice: widget.listingDetail.maxPrice,
                  isActive: widget.listingDetail.isActive,
                  fontSize: 13,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  currencySymbol: "y.e.",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.listingDetail.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.listingDetail.description != null &&
                widget.listingDetail.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.listingDetail.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: ListingDetailThemeHelper.descriptionTextColor,
                ),
              ),
            ],
            if (widget.listingDetail.privateRoom != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ThemeIconFactory.detail(
                    icon: Icons.lock_outline,
                    color: ListingDetailThemeHelper.privateRoomIconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get("private_room"),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ListingDetailThemeHelper.locationTextColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            if (widget.listingDetail.location != null || widget.listingDetail.subwayStation != null) ...[
              if (widget.listingDetail.location != null)
                Row(
                  children: [
                    ThemeIconFactory.detail(
                      icon: Icons.location_on,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.getLocalizedName(
                          nameUz: widget.listingDetail.location!.nameUz,
                          nameRu: widget.listingDetail.location!.nameRu,
                          nameEn: widget.listingDetail.location!.nameEn,
                          language: widget.currentLanguage,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: ListingDetailThemeHelper.locationTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              if (widget.listingDetail.subwayStation != null)
                widget.listingDetail.location != null
                    ? const SizedBox(height: 8)
                    : const SizedBox(height: 20),
              if (widget.listingDetail.subwayStation != null) ...[
                _buildSubwayStationDisplay(widget.listingDetail.subwayStation!),
                const SizedBox(height: 20),
              ] else if (widget.listingDetail.location != null)
                const SizedBox(height: 20),
            ],
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _detailsExpanded
                          ? L10n.get("hide_details")
                          : L10n.get("show_details"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ListingDetailThemeHelper.dateTextColor,
                      ),
                    ),
                    Icon(
                      _detailsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: ListingDetailThemeHelper.dateIconColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _detailsExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.listingDetail.amenities != null &&
                            widget.listingDetail.amenities!.isNotEmpty) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: widget.listingDetail.amenities!
                                .map((amenity) =>
                                    _buildAmenityChip(context, amenity))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (widget.listingDetail.moveInDate != null &&
                            widget.listingDetail.moveInDate!.isNotEmpty) ...[
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Center(
                                  child: ThemeIconFactory.detail(
                                    icon: CupertinoIcons.square_arrow_right,
                                    color:
                                        ListingDetailThemeHelper.dateIconColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${L10n.get("move_in_date_label")} ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: ListingDetailThemeHelper
                                              .dateTextColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.formatMoveInDate(
                                          context,
                                          widget.listingDetail.moveInDate!,
                                        ),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: ListingDetailThemeHelper
                                              .dateTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                child: ThemeIconFactory.detail(
                                  icon: Icons.schedule,
                                  color:
                                      ListingDetailThemeHelper.dateIconColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${L10n.get("publication_date")} ${AppDateUtils.formatDateWithShortMonth(
                                  context,
                                  DateTime.parse(widget.listingDetail.createdAt),
                                )}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      ListingDetailThemeHelper.dateTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
