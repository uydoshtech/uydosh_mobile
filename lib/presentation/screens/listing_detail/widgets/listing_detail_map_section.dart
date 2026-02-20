import "package:flutter/cupertino.dart";
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
class ListingDetailMapSection extends StatelessWidget {
  const ListingDetailMapSection({
    required this.listingDetail,
    required this.currentLanguage,
    required this.getLocalizedName,
    required this.onOpenInYandexMaps,
    super.key,
  });

  final ListingDetail listingDetail;
  final String currentLanguage;
  final String Function({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    required String language,
  }) getLocalizedName;
  final VoidCallback onOpenInYandexMaps;

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
            getLocalizedName(
              nameUz: station.nameUz,
              nameRu: station.nameRu,
              nameEn: station.nameEn,
              language: currentLanguage,
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
            getLocalizedName(
              nameUz: connectedStation.nameUz,
              nameRu: connectedStation.nameRu,
              nameEn: connectedStation.nameEn,
              language: currentLanguage,
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
              getLocalizedName(
                nameUz: station.nameUz,
                nameRu: station.nameRu,
                nameEn: station.nameEn,
                language: currentLanguage,
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
    final hasLocation = listingDetail.location != null;
    final hasSubway = listingDetail.subwayStation != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasSubway) _buildSubwayStationDisplay(listingDetail.subwayStation!),
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
                      getLocalizedName(
                        nameUz: listingDetail.location!.nameUz,
                        nameRu: listingDetail.location!.nameRu,
                        nameEn: listingDetail.location!.nameEn,
                        language: currentLanguage,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: ListingDetailThemeHelper.locationTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            if (hasLocation || hasSubway) const SizedBox(height: 16),
            YandexMapWidget(
              apiKey: AppConfig.yandexMapsApiKey,
              height: 250,
              listingDetail: listingDetail,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedbackUtils.impact();
                  onOpenInYandexMaps();
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
      ),
    );
  }
}
