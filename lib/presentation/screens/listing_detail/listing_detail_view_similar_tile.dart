import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Tappable row that opens similar listings for the current listing.
class ListingDetailViewSimilarTile extends StatelessWidget {
  const ListingDetailViewSimilarTile({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  Icons.auto_awesome_mosaic_outlined,
                  color: ThemeState().isBlueTheme
                      ? BlueThemeColors.textPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    L10n.get("view_similar_results"),
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
