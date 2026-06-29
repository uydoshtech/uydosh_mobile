import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

Widget _metaBadgesChipWrap({
  required Widget child,
  VoidCallback? onBackgroundTap,
}) {
  if (onBackgroundTap == null) return child;
  return Stack(
    alignment: Alignment.centerLeft,
    clipBehavior: Clip.none,
    children: [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBackgroundTap,
          child: const ColoredBox(color: Color(0x00000000)),
        ),
      ),
      child,
    ],
  );
}

/// Listing type, gender, and price chips (shown in a dedicated tile on listing detail).
class ListingDetailMetaBadges extends StatelessWidget {
  const ListingDetailMetaBadges({
    required this.listingDetail,
    super.key,
    this.onBackgroundTap,
  });

  final ListingDetail listingDetail;

  /// When set, taps on the chip [Wrap] area (including empty space around chips)
  /// invoke this.
  final VoidCallback? onBackgroundTap;

  String _genderLabel(int gender) {
    switch (gender) {
      case 1:
        return L10n.get("male");
      case 2:
        return L10n.get("female");
      default:
        return L10n.get("other");
    }
  }

  IconData _genderIcon(int gender) {
    switch (gender) {
      case 1:
        return Icons.male;
      case 2:
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirror the price-badge styles used by `ListingTile` (transparent fill,
    // green border + icon + text). Inactive listings fall back to the
    // shared inactive token so disabled tiles read the same on both
    // surfaces.
    final priceColor =
        listingDetail.isActive ? Colors.green : AppColors.statusInactive;

    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          child: _metaBadgesChipWrap(
            onBackgroundTap: onBackgroundTap,
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ListingTypeBadge(
                  listingTypeCode: listingDetail.listingType.code,
                  hostResident: listingDetail.hostResident,
                  useShortLabel: true,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                if (listingDetail.gender != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // Keep existing layout; just make fill slightly tinted (also in light theme).
                      color: ListingDetailThemeHelper.genderColor(
                        listingDetail.gender!,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ListingDetailThemeHelper.genderColor(
                          listingDetail.gender!,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ThemeIconFactory.detail(
                          icon: _genderIcon(listingDetail.gender!),
                          color: ListingDetailThemeHelper.genderForegroundColor(
                            listingDetail.gender!,
                          ),
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _genderLabel(listingDetail.gender!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ListingDetailThemeHelper.genderForegroundColor(
                              listingDetail.gender!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ListingPaymentsOutlineBadge(
                  label: PriceRangeHelper.formatStoredListingPrice(
                    storedPrice: listingDetail.price,
                    listingTypeCode: listingDetail.listingType.code,
                    minPrice: listingDetail.minPrice,
                    maxPrice: listingDetail.maxPrice,
                  ),
                  foregroundColor: priceColor,
                  fontSize: 12,
                  iconSize: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
