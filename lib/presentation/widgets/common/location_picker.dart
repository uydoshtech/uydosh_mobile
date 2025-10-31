import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class LocationPicker extends StatelessWidget {
  const LocationPicker({
    super.key,
    required this.locations,
    required this.selectedLocationIndex,
    required this.onLocationChanged,
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

  /// Whether to show error styling (red border)
  final bool showError;

  // Search-specific parameters
  final bool sortLocations;
  final String? containerKey;
  final VoidCallback? onMetroReset;
  final bool useColoredIcons;
  final bool showArrows;
  final FixedExtentScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use locations as-is (already sorted by ID in cache)
    final displayLocations = locations;

    // Use the same styling as metro line picker
    final backgroundColor = theme.colorScheme.surfaceVariant;
    final borderColor = theme.colorScheme.outline;
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: showError ? theme.colorScheme.error : borderColor,
          ),
        ),
        height: height,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Container(
      key: containerKey != null ? ValueKey(containerKey) : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: showError ? theme.colorScheme.error : borderColor,
        ),
      ),
      height: height,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: itemExtent,
              scrollController:
                  scrollController ??
                  FixedExtentScrollController(
                    initialItem:
                        selectedLocationIndex + 1, // +1 for unselected option
                  ),
              onSelectedItemChanged: (index) {
                // Dismiss keyboard if it is open
                FocusScope.of(context).unfocus();
                // Provide haptic feedback
                HapticFeedback.lightImpact();

                // Update the selected location index (convert back to -1 for unselected)
                onLocationChanged(index - 1);

                // Reset metro filters if requested (for search filters)
                if (onMetroReset != null && index > 0) {
                  onMetroReset!();
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
                          placeholderText ??
                              (isRequired
                                  ? LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "select_location_required",
                                  )
                                  : LanguageAwareStringHelper.getCurrent(
                                    context,
                                    "select_location",
                                  )),
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
                            LanguageAwareStringHelper.getCurrent(
                              context,
                              "no_locations_available",
                            ),
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
                                useColoredIcons
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
          if (showArrows)
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
      Colors.pink,
    ];
    return colors[(index - 1) % colors.length];
  }

  String _getLocalizedName(BuildContext context, Location location) {
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );

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
