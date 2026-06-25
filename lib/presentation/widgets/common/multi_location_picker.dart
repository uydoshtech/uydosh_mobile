import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Checkbox-based multi-select for districts, matching the metro station
/// multi-select control. Reports the full set of selected district ids.
class MultiLocationPicker extends StatelessWidget {
  const MultiLocationPicker({
    required this.locations,
    required this.selectedLocationIds,
    required this.onLocationsSelected,
    required this.getLocationName,
    this.isLoading = false,
    this.accentColor,
    super.key,
  });

  final List<Location> locations;
  final Set<int> selectedLocationIds;
  final void Function(List<int> locationIds) onLocationsSelected;
  final String Function(Location location) getLocationName;
  final bool isLoading;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final accent = accentColor ?? theme.colorScheme.primary;
    const locationPinColor = Colors.red;
    final selected = {...selectedLocationIds};
    final locationIds = locations.map((location) => location.id).toList();
    final allSelected =
        locationIds.isNotEmpty && locationIds.every(selected.contains);

    void emit(Set<int> next) => onLocationsSelected(next.toList()..sort());

    void toggleLocation(int id) {
      final next = {...selected};
      if (!next.remove(id)) next.add(id);
      emit(next);
    }

    void toggleAll() {
      final next = {...selected};
      if (allSelected) {
        next.removeAll(locationIds);
      } else {
        next.addAll(locationIds);
      }
      emit(next);
    }

    Widget checkbox(bool value) => ThemeIcon(
          value ? Icons.check_box : Icons.check_box_outline_blank,
          color: value ? accent : textColor.withValues(alpha: 0.5),
          size: 22,
        );

    if (isLoading) {
      return LiquidGlassPlate(
        height: 220,
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return LiquidGlassPlate(
      height: 220,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: Column(
        children: [
          InkWell(
            onTap: locations.isEmpty ? null : toggleAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  checkbox(allSelected),
                  const SizedBox(width: 8),
                  const ThemeIcon(
                    Icons.location_on,
                    color: locationPinColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      L10n.getWithParams(
                        "all_locations_count",
                        params: {"count": "${locations.length}"},
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: textColor.withValues(alpha: 0.12)),
          Expanded(
            child: locations.isEmpty
                ? Center(
                    child: Text(
                      L10n.get("no_locations_available"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 42,
                    ),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      final isSelected = selected.contains(location.id);
                      return InkWell(
                        onTap: () {
                          SendSoundUtils.playCupertinoWheelSound();
                          toggleLocation(location.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              checkbox(isSelected),
                              const SizedBox(width: 6),
                              const ThemeIcon(
                                Icons.location_on,
                                color: locationPinColor,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  getLocationName(location),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
