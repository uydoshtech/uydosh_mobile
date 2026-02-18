import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Map section with Yandex Maps for listing detail.
class ListingDetailMapSection extends StatelessWidget {
  const ListingDetailMapSection({
    required this.listingDetail,
    required this.onOpenInYandexMaps,
    super.key,
  });

  final ListingDetail listingDetail;
  final VoidCallback onOpenInYandexMaps;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ThemeIconFactory.detail(
                  icon: CupertinoIcons.placemark_fill,
                  color: ListingDetailThemeHelper.iconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "location_on_map",
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ListingDetailThemeHelper.descriptionTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "open_in_yandex_maps",
                  ),
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
