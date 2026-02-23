import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_toggle.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

/// Primary filters: listing type and gender pickers.
class SearchBottomSheetPrimaryFilters extends StatelessWidget {
  const SearchBottomSheetPrimaryFilters({
    super.key,
    required this.searchFiltersState,
    required this.onListingTypeChanged,
    required this.onGenderChanged,
  });

  final SearchFiltersState searchFiltersState;
  final void Function(int listingTypeId) onListingTypeChanged;
  final void Function(int gender) onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListingTypePicker(
            selectedListingTypeId: searchFiltersState.selectedListingTypeId,
            onListingTypeChanged: onListingTypeChanged,
            useThemeColors: true,
            showArrows: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GenderPicker(
            selectedGender: searchFiltersState.selectedGender,
            onGenderChanged: onGenderChanged,
            useThemeColors: true,
            showArrows: false,
          ),
        ),
      ],
    );
  }
}

/// Secondary filters: price range, private room toggle, search button.
class SearchBottomSheetSecondaryFilters extends StatelessWidget {
  const SearchBottomSheetSecondaryFilters({
    super.key,
    required this.searchFiltersState,
    required this.onPriceRangeChanged,
    required this.onPrivateRoomChanged,
    required this.onSearchPressed,
  });

  final SearchFiltersState searchFiltersState;
  final void Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final void Function(bool value) onPrivateRoomChanged;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Range
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(10),
            color: ThemeState().isBlueTheme
                ? BlueThemeColors.surface
                : theme.colorScheme.surfaceContainerHighest,
          ),
          child: PriceRangePicker(
            initialMinPrice: searchFiltersState.minPrice,
            initialMaxPrice: searchFiltersState.maxPrice,
            onPriceRangeChanged: onPriceRangeChanged,
          ),
        ),
        const SizedBox(height: 15),

        // Private Room Toggle
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(10),
            color: ThemeState().isBlueTheme
                ? BlueThemeColors.primary
                : theme.colorScheme.surfaceContainerHighest,
          ),
          child: UydoshToggle(
            icon: Icons.lock_outline,
            title: Text(
              L10n.get("private_room_only"),
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    searchFiltersState.privateRoom
                        ? FontWeight.w600
                        : FontWeight.w400,
                color: ThemeState().isBlueTheme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            value: searchFiltersState.privateRoom,
            onChanged: (value) {
              HapticFeedbackUtils.impact();
              onPrivateRoomChanged(value);
            },
          ),
        ),
        const SizedBox(height: 20),

        // Search button
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: onSearchPressed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, size: 20),
                const SizedBox(width: 8),
                Text(
                  L10n.get("search"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
