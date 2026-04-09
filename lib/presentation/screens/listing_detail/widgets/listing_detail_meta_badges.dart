import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Listing type, gender, and price chips (shown in a dedicated tile on listing detail).
class ListingDetailMetaBadges extends StatelessWidget {
  const ListingDetailMetaBadges({required this.listingDetail, super.key});

  final ListingDetail listingDetail;

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
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ListingTypeBadge(
          listingTypeCode: listingDetail.listingType.code,
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        if (listingDetail.gender != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  color: ListingDetailThemeHelper.genderColor(
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
                    color: ListingDetailThemeHelper.genderColor(
                      listingDetail.gender!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        PriceRangeBadge(
          minPrice: listingDetail.price,
          maxPrice: listingDetail.price,
          isActive: listingDetail.isActive,
          fontSize: 13,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          currencySymbol: "y.e.",
          // Keep existing layout; just make fill slightly tinted.
          useTintBackground: true,
          tintAlpha: 0.12,
        ),
      ],
    );
  }
}
