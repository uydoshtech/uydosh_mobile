import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";

/// Map section with Yandex Maps for listing detail.
/// Collapsed by default: shows only location and metro. Tap to expand and show map.
/// Uses the same Card + ExpansionTile pattern as [ListingDetailCompatibilitySection]
/// so the entire header row is tappable (ListTile ink / hit targets).
class ListingDetailMapSection extends StatefulWidget {
  const ListingDetailMapSection({
    required this.listingDetail,
    required this.currentLanguage,
    required this.getLocalizedName,
    required this.onOpenInYandexMaps,
    required this.sectionKey,
    super.key,
  });

  final GlobalKey sectionKey;
  final ListingDetail listingDetail;
  final String currentLanguage;
  final String Function({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    required String language,
  }) getLocalizedName;
  final VoidCallback onOpenInYandexMaps;

  @override
  State<ListingDetailMapSection> createState() => _ListingDetailMapSectionState();
}

class _ListingDetailMapSectionState extends State<ListingDetailMapSection> {
  void _onExpansionChanged(bool isExpanded) {
    HapticFeedbackUtils.impact();
    if (isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          final ctx = widget.sectionKey.currentContext;
          if (ctx != null && ctx.mounted) {
            Scrollable.ensureVisible(
              ctx,
              alignment: 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.listingDetail.location != null;
    final hasSubway = widget.listingDetail.subwayStation != null;
    final hasMapContent = hasLocation || hasSubway;

    final chevronColor = ListingDetailThemeHelper.locationTextColor;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSubway)
          _buildSubwayStationDisplay(
            widget.listingDetail.subwayStation!,
          ),
        if (hasSubway && hasLocation) const SizedBox(height: 8),
        if (hasLocation)
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
      ],
    );

    return Card(
      key: widget.sectionKey,
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: _onExpansionChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: chevronColor,
        collapsedIconColor: chevronColor,
        title: title,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              YandexMapWidget(
                apiKey: AppConfig.yandexMapsApiKey,
                height: 250,
                listingDetail: widget.listingDetail,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    widget.onOpenInYandexMaps();
                  },
                  icon: Icon(
                    Icons.link,
                    size: 18,
                    color: ListingDetailThemeHelper.yandexButtonColor,
                  ),
                  label: Text(
                    L10n.get("open_in_yandex_maps"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ListingDetailThemeHelper.yandexButtonColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: ListingDetailThemeHelper.yandexButtonColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
