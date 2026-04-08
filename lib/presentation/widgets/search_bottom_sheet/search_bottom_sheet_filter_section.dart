import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/price_range_picker.dart";
import "package:uy_dosh/presentation/widgets/theme_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Primary filters: listing type and gender pickers.
class SearchBottomSheetPrimaryFilters extends StatelessWidget {
  const SearchBottomSheetPrimaryFilters({
    required this.searchFiltersState, required this.onListingTypeChanged, required this.onGenderChanged, super.key,
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

/// Secondary filters: price range, private room / with-photo toggles, search button.
class SearchBottomSheetSecondaryFilters extends StatelessWidget {
  const SearchBottomSheetSecondaryFilters({
    required this.searchFiltersState,
    required this.onPriceRangeChanged,
    required this.onPrivateRoomChanged,
    required this.onWithPhotoChanged,
    required this.onSearchPressed,
    required this.onNotifyPressed,
    super.key,
  });

  final SearchFiltersState searchFiltersState;
  final void Function(double minPrice, double maxPrice) onPriceRangeChanged;
  final void Function(bool value) onPrivateRoomChanged;
  final void Function(bool value) onWithPhotoChanged;
  final VoidCallback onSearchPressed;
  final VoidCallback onNotifyPressed;

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

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SearchSheetFilterToggle(
                icon: Icons.lock_outline,
                label: L10n.get("search_filter_private_room"),
                value: searchFiltersState.privateRoom,
                emphasized: searchFiltersState.privateRoom,
                onChanged: (value) {
                  HapticFeedbackUtils.impact();
                  onPrivateRoomChanged(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SearchSheetFilterToggle(
                icon: Icons.photo_camera_outlined,
                label: L10n.get("search_filter_with_photo"),
                value: searchFiltersState.withPhoto,
                emphasized: searchFiltersState.withPhoto,
                onChanged: (value) {
                  HapticFeedbackUtils.impact();
                  onWithPhotoChanged(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _NotifySearchAlertButton(
          label: L10n.get("search_alert_notify_me"),
          onPressed: onNotifyPressed,
        ),
        const SizedBox(height: 12),

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
                const ThemeIcon(Icons.search, size: 20),
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

/// Notify-me control: expanding ring + bell wiggle on tap.
class _NotifySearchAlertButton extends StatefulWidget {
  const _NotifySearchAlertButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_NotifySearchAlertButton> createState() => _NotifySearchAlertButtonState();
}

class _NotifySearchAlertButtonState extends State<_NotifySearchAlertButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bellTurns;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _bellTurns = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.09).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.09, end: 0.055).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.055, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 30,
      ),
    ]).animate(_controller);
    _ringScale = Tween<double>(begin: 1, end: 2.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.72, curve: Curves.easeOut),
      ),
    );
    _ringOpacity = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.88, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = theme.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handlePressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return IgnorePointer(
                        child: Opacity(
                          opacity: _ringOpacity.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: _ringScale.value,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ringColor.withValues(alpha: 0.85),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  RotationTransition(
                    turns: _bellTurns,
                    alignment: Alignment.topCenter,
                    child: const ThemeIcon(
                      Icons.notifications_active_outlined,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBlue = ThemeState().isBlueTheme;
    final fg = onBlue ? Colors.white : Colors.black;
    final iconColor = onBlue ? Colors.white : theme.iconTheme.color;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
        color: onBlue
            ? BlueThemeColors.primary
            : theme.colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
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
            ThemeToggle(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
