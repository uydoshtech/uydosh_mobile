import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/amenities_cache.dart";
import "package:uy_dosh/presentation/widgets/common/amenity_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Amenities selection section for create/edit listing forms.
/// Wraps [AmenityToggle] chips in a styled container.
class ListingFormAmenitiesSection extends StatelessWidget {
  const ListingFormAmenitiesSection({
    required this.selectedAmenityIds,
    required this.onAmenityToggled,
    required this.onDismissKeyboard,
    super.key,
  });

  final Set<int> selectedAmenityIds;
  final void Function(int amenityId) onAmenityToggled;
  final VoidCallback onDismissKeyboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: theme,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AmenitiesCache.getDefaultOrderedAmenities()
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
              .toList(),
        ),
      ),
    );
  }
}
