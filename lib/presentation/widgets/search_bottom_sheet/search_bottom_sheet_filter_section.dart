import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";

/// Primary filters: listing type and gender pickers.
class SearchBottomSheetPrimaryFilters extends StatelessWidget {
  const SearchBottomSheetPrimaryFilters({
    required this.searchFiltersState,
    required this.onListingTypeChanged,
    required this.onGenderChanged,
    super.key,
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
            useGlassPlate: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GenderPicker(
            selectedGender: searchFiltersState.selectedGender,
            onGenderChanged: onGenderChanged,
            useThemeColors: true,
            showArrows: false,
            useGlassPlate: true,
          ),
        ),
      ],
    );
  }
}

/// Secondary filters: price range, private room / with-photo toggles, primary action.
class SearchBottomSheetSecondaryFilters extends StatelessWidget {
  const SearchBottomSheetSecondaryFilters({
    required this.searchFiltersState,
    required this.onPriceRangeChanged,
    required this.onPrivateRoomChanged,
    required this.onWithPhotoChanged,
    required this.onPrimaryPressed,
    required this.primaryLabelKey,
    required this.primaryIcon,
    super.key,
  });

  final SearchFiltersState searchFiltersState;
  final void Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final void Function(bool value) onPrivateRoomChanged;
  final void Function(bool value) onWithPhotoChanged;
  final VoidCallback onPrimaryPressed;
  final String primaryLabelKey;
  final IconData primaryIcon;

  @override
  Widget build(BuildContext context) {
    final canFilterPrivateRoom = searchFiltersState.selectedListingTypeId == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Range ([PriceRangePicker] already uses 3D plate chrome)
        PriceRangePicker(
          initialMinPrice: searchFiltersState.minPrice,
          initialMaxPrice: searchFiltersState.maxPrice,
          onPriceRangeChanged: onPriceRangeChanged,
          useGlassPlate: true,
        ),
        const SizedBox(height: 15),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canFilterPrivateRoom) ...[
              Expanded(
                child: _SearchSheetFilterToggle(
                  icon: Icons.lock_outline,
                  label: L10n.get("search_filter_private_room"),
                  value: searchFiltersState.privateRoom,
                  emphasized: searchFiltersState.privateRoom,
                  onChanged: (value) {
                    UiFeedbackUtils.tap();
                    onPrivateRoomChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: _SearchSheetFilterToggle(
                icon: Icons.photo_camera_outlined,
                label: L10n.get("search_filter_with_photo"),
                value: searchFiltersState.withPhoto,
                emphasized: searchFiltersState.withPhoto,
                onChanged: (value) {
                  UiFeedbackUtils.tap();
                  onWithPhotoChanged(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search / save alert
        SizedBox(
          width: double.infinity,
          child: Builder(
            builder: (context) {
              // Match Create Listing CTA typography and pill radius.
              final label = Theme.of(context).textTheme.labelLarge;
              final baseSize = label?.fontSize ?? 14;
              final textStyle =
                  label?.copyWith(fontSize: baseSize * 1.2, height: 1.0) ??
                      TextStyle(
                        fontSize: baseSize * 1.2,
                        height: 1.0,
                        fontWeight: FontWeight.w500,
                      );
              return PrimaryButtonFactory.iconText(
                onPressed: onPrimaryPressed,
                icon: primaryIcon,
                text: primaryLabelKey == "apply"
                    ? context.l10n.apply
                    : L10n.get(primaryLabelKey),
                width: double.infinity,
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: textStyle,
              );
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _SearchSheetFilterToggle extends StatelessWidget {
  const _SearchSheetFilterToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.emphasized,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final bool emphasized;
  final ValueChanged<bool> onChanged;

  Color _getBorderColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBlue = ThemeState().isBlueTheme;
    final fg = onBlue ? Colors.white : Colors.black;
    final iconColor = onBlue ? Colors.white : theme.iconTheme.color;
    final border = _getBorderColor();
    final isDark = theme.brightness == Brightness.dark;

    return LiquidGlassPlate(
      height: 56,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      padding: const EdgeInsetsDirectional.only(
        start: 8,
        end: 4,
        top: 4,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ThemeIcon(icon, size: 20, color: iconColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
                color: fg,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          NeumorphicToggle(
            value: value,
            activeAccentColor: border,
            activeTrackColor: border.withValues(alpha: 0.3),
            inactiveThumbColor: isDark
                ? theme.colorScheme.onSurfaceVariant.withOpacity(0.7)
                : Colors.grey.shade600,
            inactiveTrackColor: isDark
                ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3)
                : Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
