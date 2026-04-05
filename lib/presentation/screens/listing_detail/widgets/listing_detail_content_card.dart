import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_description_translation.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

/// Main content card for listing detail (header, title, description, location, amenities, dates).
class ListingDetailContentCard extends StatefulWidget {
  const ListingDetailContentCard({
    required this.listingDetail,
    required this.currentLanguage,
    required this.getLocalizedName,
    this.formatMoveInDate,
    this.formattedMoveInDate,
    this.formattedPublicationDate,
    this.amenityChips,
    this.ownerName,
    this.onAuthorTap,
    super.key,
  });

  final ListingDetail listingDetail;
  final String currentLanguage;
  final String? ownerName;
  final VoidCallback? onAuthorTap;
  /// Pre-formatted move-in date (avoids DateTime.parse in build).
  final String? formattedMoveInDate;
  /// Pre-formatted publication date (avoids DateTime.parse in build).
  final String? formattedPublicationDate;
  /// Pre-built amenity chips (avoids .map().toList() in build).
  final List<Widget>? amenityChips;
  final String Function(BuildContext context, String moveInDate)? formatMoveInDate;
  final String Function({
    required String language,
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) getLocalizedName;

  @override
  State<ListingDetailContentCard> createState() =>
      _ListingDetailContentCardState();
}

class _ListingDetailContentCardState extends State<ListingDetailContentCard> {
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

  String _getPublicationDateText(BuildContext context) {
    if (widget.formattedPublicationDate != null) {
      return widget.formattedPublicationDate!;
    }
    final date = ListingDetailDateUtils.parseCreatedAt(
      widget.listingDetail.createdAt,
    );
    if (date != null) {
      return AppDateUtils.formatDateWithShortMonth(context, date);
    }
    return widget.listingDetail.createdAt;
  }

  void _showAmenityBubble(
    BuildContext context,
    Amenity amenity,
    Offset globalPosition,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    var removed = false;
    void removeOnce() {
      if (!removed) {
        removed = true;
        overlayEntry.remove();
      }
    }
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: removeOnce,
          ),
          Positioned(
            left: globalPosition.dx.clamp(12.0, MediaQuery.of(context).size.width - 150),
            top: globalPosition.dy - 48,
            child: GestureDetector(
              onTap: removeOnce,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeState().isLightTheme
                        ? Colors.black
                        : (ThemeState().isBlueTheme
                            ? Colors.white
                            : Theme.of(context).colorScheme.inverseSurface),
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
                      color: ThemeState().isLightTheme
                          ? Colors.white
                          : (ThemeState().isBlueTheme
                              ? Colors.black
                              : Theme.of(context).colorScheme.onInverseSurface),
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
    Future.delayed(const Duration(seconds: 2), removeOnce);
  }

  Widget _buildAmenityChip(BuildContext context, Amenity amenity) {
    return GestureDetector(
      onTapDown: (details) => _showAmenityBubble(
        context,
        amenity,
        details.globalPosition,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
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
        // Tighter top: reduces gap between image tile and title/description row only.
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.listingDetail.description == null ||
                widget.listingDetail.description!.isEmpty)
              Text(
                ListingUtils.usesPresetListingTitle(
                      widget.listingDetail.listingTypeId,
                    )
                    ? L10n.get(
                        ListingUtils.presetListingTitleL10nKey(
                          listingTypeId: widget.listingDetail.listingTypeId,
                          gender: widget.listingDetail.gender,
                        ),
                      )
                    : widget.listingDetail.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (widget.listingDetail.description != null &&
                widget.listingDetail.description!.isNotEmpty)
              ListingDescriptionTranslation(
                listingId: widget.listingDetail.id,
                listingTitle:
                    ListingUtils.usesPresetListingTitle(
                          widget.listingDetail.listingTypeId,
                        )
                        ? L10n.get(
                            ListingUtils.presetListingTitleL10nKey(
                              listingTypeId:
                                  widget.listingDetail.listingTypeId,
                              gender: widget.listingDetail.gender,
                            ),
                          )
                        : widget.listingDetail.title,
                listingTitleStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                descriptionRu: widget.listingDetail.descriptionRu,
                descriptionEn: widget.listingDetail.descriptionEn,
                descriptionUz: widget.listingDetail.descriptionUz,
                originalText: widget.listingDetail.description!,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: ListingDetailThemeHelper.descriptionTextColor,
                ),
              ),
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
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                        if ((widget.amenityChips != null &&
                                widget.amenityChips!.isNotEmpty) ||
                            (widget.listingDetail.amenities != null &&
                                widget.listingDetail.amenities!.isNotEmpty)) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.amenityChips ??
                                (widget.listingDetail.amenities ?? <Amenity>[])
                                    .map((amenity) =>
                                        _buildAmenityChip(context, amenity))
                                    .toList(),
                          ),
                          const SizedBox(height: 24),
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
                                        text: widget.formattedMoveInDate ??
                                            (widget.formatMoveInDate != null
                                                ? widget.formatMoveInDate!(
                                                    context,
                                                    widget.listingDetail.moveInDate!,
                                                  )
                                                : widget.listingDetail.moveInDate!),
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
                                  icon: Icons.person_outline,
                                  color:
                                      ListingDetailThemeHelper.dateIconColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    "${L10n.get("author")}: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: ListingDetailThemeHelper
                                          .dateTextColor,
                                    ),
                                  ),
                                  if (widget.onAuthorTap != null)
                                    UydoshLinkButton(
                                      text: (widget.ownerName ?? "").trim().isNotEmpty
                                          ? widget.ownerName!
                                          : L10n.get("na"),
                                      onPressed: widget.onAuthorTap!,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: ListingDetailThemeHelper
                                          .dateTextColor,
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.centerLeft,
                                    )
                                  else
                                    Text(
                                      widget.ownerName ?? L10n.get("na"),
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
                          ],
                        ),
                        const SizedBox(height: 8),
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
                                "${L10n.get("publication_date")} ${_getPublicationDateText(context)}",
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
            ),
          ],
        ),
      ),
    );
  }
}
