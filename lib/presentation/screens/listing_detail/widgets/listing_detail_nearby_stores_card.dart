import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ListingDetailNearbyStoresCard extends StatelessWidget {
  const ListingDetailNearbyStoresCard({
    required this.stores,
    this.onStoreTap,
    super.key,
  });

  final List<ListingNearbyStore> stores;
  final ValueChanged<ListingNearbyStore>? onStoreTap;

  String _formatDistance(ListingNearbyStore store) {
    final meters = store.distanceM;
    if (meters < 1000) {
      return "$meters ${L10n.get("listing_detail_nearby_stores_meters")}";
    }
    final km = meters / 1000;
    return "${km.toStringAsFixed(km >= 10 ? 0 : 1)} ${L10n.get("listing_detail_nearby_stores_kilometers")}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final iconColor = ThemeState().isBlueTheme
        ? BlueThemeColors.textPrimary
        : theme.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ThemeIcon(
                    Icons.store_mall_directory_outlined,
                    color: iconColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      L10n.get("listing_detail_nearby_stores_title"),
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                L10n.get("listing_detail_nearby_stores_subtitle"),
                style: bodyStyle,
              ),
              const SizedBox(height: 8),
              for (final store in stores.take(3)) _StoreRow(
                store: store,
                distanceText: _formatDistance(store),
                onTap: onStoreTap == null ? null : () => onStoreTap!(store),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.distanceText,
    this.onTap,
  });

  final ListingNearbyStore store;
  final String distanceText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = store.address?.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            ThemeIcon(
              Icons.shopping_basket_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (address != null && address.isNotEmpty)
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              distanceText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              ThemeIcon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
