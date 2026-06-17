import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/amenities_cache.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/amenity_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Amenities selection section for create/edit listing forms.
/// Wraps [AmenityToggle] chips in a styled container.
class ListingFormAmenitiesSection extends StatelessWidget {
  const ListingFormAmenitiesSection({
    required this.listingTypeId,
    required this.selectedAmenityIds,
    required this.onAmenityToggled,
    required this.onDismissKeyboard,
    super.key,
  });

  final int listingTypeId;
  final Set<int> selectedAmenityIds;
  final void Function(int amenityId) onAmenityToggled;
  final VoidCallback onDismissKeyboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerText = listingTypeId == 1
        ? L10n.get("amenities_header_need_room")
        : L10n.get("amenities_header_roommate_needed");
    final amenityChips = AmenitiesCache.getDefaultOrderedAmenities()
        .map(
          (amenity) => AmenityToggle(
            amenity: amenity,
            isSelected: selectedAmenityIds.contains(amenity.id),
            onTap: () {
              onDismissKeyboard();
              onAmenityToggled(amenity.id);
            },
          ),
        )
        .toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: theme,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                headerText,
                style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ) ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: amenityChips,
            ),
          ],
        ),
      ),
    );
  }
}
