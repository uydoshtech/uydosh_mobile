import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/amenities_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/amenity_toggle.dart";

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

  Color _getControlBackgroundColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.surface;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.outline
              : AppColors.borderGrey600,
        ),
        color: _getControlBackgroundColor(context),
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
