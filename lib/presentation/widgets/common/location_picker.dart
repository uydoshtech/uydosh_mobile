import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// Location picker - uses persistent scroll controller (from parent or own)
/// so the wheel scrolls smoothly with sound. Same pattern as GenderPicker.
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    required this.locations,
    required this.selectedLocationIndex,
    required this.onLocationChanged,
    super.key,
    this.useThemeColors = false,
    this.height = 80,
    this.itemExtent = 40,
    this.isLoading = false,
    this.isRequired = false,
    this.placeholderText,
    this.showError = false,
    this.sortLocations = false,
    this.containerKey,
    this.onMetroReset,
    this.useColoredIcons = false,
    this.showArrows = true,
    this.scrollController,
  });

  final List<Location> locations;
  final int selectedLocationIndex;
  final ValueChanged<int> onLocationChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool isLoading;
  final bool isRequired;
  final String? placeholderText;
  final bool showError;
  final bool sortLocations;
  final String? containerKey;
  final VoidCallback? onMetroReset;
  final bool useColoredIcons;
  final bool showArrows;
  final FixedExtentScrollController? scrollController;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  FixedExtentScrollController? _ownScrollController;

  int get _pickerInitialItem => widget.selectedLocationIndex + 1;

  FixedExtentScrollController get _effectiveController {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    _ownScrollController ??= FixedExtentScrollController(
      initialItem: _pickerInitialItem.clamp(0, 999),
    );
    return _ownScrollController!;
  }

  @override
  void didUpdateWidget(LocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == null &&
        oldWidget.selectedLocationIndex != widget.selectedLocationIndex &&
        (_ownScrollController?.hasClients ?? false)) {
      final target = _pickerInitialItem.clamp(0, 999);
      if (target != _ownScrollController!.selectedItem) {
        _ownScrollController!.animateToItem(
          target,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _ownScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayLocations = widget.locations;
    final isBlueTheme = ThemeState().isBlueTheme;
    final backgroundColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.colorScheme.outline;
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    if (widget.isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.showError ? theme.colorScheme.error : borderColor,
          ),
        ),
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Container(
      key: widget.containerKey != null ? ValueKey(widget.containerKey) : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.showError ? theme.colorScheme.error : borderColor,
        ),
      ),
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: widget.itemExtent,
              scrollController: _effectiveController,
              onSelectedItemChanged: (index) {
                FocusScope.of(context).unfocus();
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                widget.onLocationChanged(index - 1);
                if (widget.onMetroReset != null && index > 0) {
                  widget.onMetroReset!();
                }
              },
              children: [
                // Unselected option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: iconColor, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.placeholderText ??
                              (widget.isRequired
                                  ? L10n.get("select_location_required")
                                  : L10n.get("select_location")),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                // Location options
                if (displayLocations.isEmpty)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: iconColor, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            L10n.get("no_locations_available"),
                            style: TextStyle(fontSize: 16, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...displayLocations.asMap().entries.map(
                    (entry) => Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color:
                                widget.useColoredIcons
                                    ? _getLocationIconColorForIndex(
                                      entry.key + 1,
                                    )
                                    : iconColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getLocalizedName(context, entry.value),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Right part with arrows - same as metro line picker
          if (widget.showArrows)
            Container(
              width: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getLocationIconColorForIndex(int index) {
    // Alternate between different colors based on location index
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[(index - 1) % colors.length];
  }

  String _getLocalizedName(BuildContext context, Location location) {
    final currentLanguage = L10n.currentLanguage;

    switch (currentLanguage) {
      case "ru":
        return location.shortNameRu ?? location.shortName ?? "";
      case "uz":
        return location.shortNameUz ?? location.shortName ?? "";
      case "en":
        return location.shortNameEn ?? location.shortName ?? "";
      default:
        return location.shortName ?? "";
    }
  }
}
