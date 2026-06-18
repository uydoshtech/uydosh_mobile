import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_nearby_matches_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";

/// Tappable row that opens cross-type listings near the current listing.
class ListingDetailNearbyMatchesTile extends StatelessWidget {
  const ListingDetailNearbyMatchesTile({
    required this.listingDetail,
    required this.onTap,
    super.key,
  });

  final ListingDetail listingDetail;
  final VoidCallback onTap;

  IconData get _icon {
    switch (listingDetail.listingType.code) {
      case "room_needed":
        return ListingTypeHelper.getIcon("roommate_needed");
      case "roommate_needed":
        return ListingTypeHelper.getIcon("room_needed");
      default:
        return Icons.location_on_outlined;
    }
  }

  Color _iconColor(BuildContext context) {
    final complementaryCode = switch (listingDetail.listingType.code) {
      "room_needed" => "roommate_needed",
      "roommate_needed" => "room_needed",
      _ => listingDetail.listingType.code,
    };
    return ListingTypeHelper.getColor(complementaryCode);
  }

  @override
  Widget build(BuildContext context) {
    final labelKey =
        ListingDetailNearbyMatchesHelper.labelKeyForListing(listingDetail);

    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
            child: Row(
              children: [
                ThemeIcon(
                  _icon,
                  color: ThemeState().isBlueTheme
                      ? BlueThemeColors.textPrimary
                      : _iconColor(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    L10n.get(labelKey),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ThemeIcon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
