import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

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
    this.useGlassPlate = false,
    this.embeddedInPlate = false,
    this.readOnly = false,
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
  final bool useGlassPlate;
  final bool embeddedInPlate;

  /// When true, the wheel cannot be scrolled and selection callbacks are ignored.
  final bool readOnly;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  FixedExtentScrollController? _ownScrollController;

  int get _pickerInitialItem {
    if (widget.locations.isEmpty) return 0;
    final maxWheelIndex = widget.locations.length;
    return (widget.selectedLocationIndex + 1).clamp(0, maxWheelIndex);
  }

  FixedExtentScrollController get _effectiveController {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    _ownScrollController ??= FixedExtentScrollController(
      initialItem: _pickerInitialItem,
    );
    return _ownScrollController!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncExternalScrollToSelection();
    });
  }

  /// Parent-owned controllers are often created before [locations] exist; align
  /// scroll offset with [selectedLocationIndex] once the wheel is mounted.
  void _syncExternalScrollToSelection() {
    if (!mounted) return;
    final c = widget.scrollController;
    if (c == null || !c.hasClients || widget.locations.isEmpty) return;
    final target = _pickerInitialItem;
    if (c.selectedItem != target) {
      c.jumpToItem(target);
    }
  }

  @override
  void didUpdateWidget(LocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == null) {
      final locationsLengthChanged =
          oldWidget.locations.length != widget.locations.length;
      if ((oldWidget.selectedLocationIndex != widget.selectedLocationIndex ||
              locationsLengthChanged) &&
          (_ownScrollController?.hasClients ?? false)) {
        final maxIdx = widget.locations.isEmpty ? 0 : widget.locations.length;
        final target = (widget.selectedLocationIndex + 1).clamp(0, maxIdx);
        if (target != _ownScrollController!.selectedItem) {
          _ownScrollController!.animateToItem(
            target,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      }
    } else if (oldWidget.selectedLocationIndex !=
            widget.selectedLocationIndex ||
        oldWidget.locations.length != widget.locations.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncExternalScrollToSelection();
      });
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
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    if (widget.isLoading) {
      final loadingChild = const Center(
        child: UydoshLogoSpinner(),
      );
      if (widget.useGlassPlate && ThemeState().usesLiquidGlassChrome) {
        return LiquidGlassPlate(
          height: widget.height,
          borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
          child: loadingChild,
        );
      }
      if (widget.embeddedInPlate) {
        return SizedBox(
          height: widget.height,
          child: DecoratedBox(
            decoration: ThreeDSurfaceStyle.wheelPickerInsetDecoration(
              context,
              theme: theme,
            ),
            child: loadingChild,
          ),
        );
      }
      return WheelPickerPlateChrome(
        height: widget.height,
        theme: theme,
        showErrorBorder: widget.showError,
        child: loadingChild,
      );
    }

    final selectionOverlayFill = theme.colorScheme.onSurface
        .withValues(alpha: isBlueTheme ? 0.14 : 0.07);

    Widget wheel = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: NotificationListener<ScrollStartNotification>(
            onNotification: (notification) {
              if (!widget.readOnly && notification.dragDetails != null) {
                widget.onMetroReset?.call();
              }
              return false;
            },
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: selectionOverlayFill,
              ),
              itemExtent: widget.itemExtent,
              scrollController: _effectiveController,
              onSelectedItemChanged: widget.readOnly
                  ? null
                  : (index) {
                      FocusScope.of(context).unfocus();
                      SendSoundUtils.playCupertinoWheelSound();
                      widget.onLocationChanged(index - 1);
                    },
              children: [
                // Unselected option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThemeIcon(Icons.location_on, color: iconColor, size: 20),
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
                        ThemeIcon(Icons.location_on,
                            color: iconColor, size: 20),
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
                              ThemeIcon(
                                Icons.location_on,
                                color: widget.useColoredIcons
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
        ),
        // Right part with arrows - same as metro line picker
        if (widget.showArrows)
          Container(
            width: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              borderRadius:
                  ThreeDSurfaceStyle.wheelPickerPlateArrowStripBorderRadius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIcon(
                  Icons.keyboard_arrow_up,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                ThemeIcon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );

    if (widget.readOnly) {
      wheel = Opacity(
        opacity: 0.55,
        child: AbsorbPointer(child: wheel),
      );
    }

    if (widget.useGlassPlate && ThemeState().usesLiquidGlassChrome) {
      return LiquidGlassPlate(
        key: widget.containerKey != null ? ValueKey(widget.containerKey) : null,
        height: widget.height,
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        child: wheel,
      );
    }

    if (widget.embeddedInPlate) {
      return SizedBox(
        key: widget.containerKey != null ? ValueKey(widget.containerKey) : null,
        height: widget.height,
        child: DecoratedBox(
          decoration: ThreeDSurfaceStyle.wheelPickerInsetDecoration(
            context,
            theme: theme,
          ),
          child: wheel,
        ),
      );
    }

    return WheelPickerPlateChrome(
      key: widget.containerKey != null ? ValueKey(widget.containerKey) : null,
      height: widget.height,
      theme: theme,
      showErrorBorder: widget.showError,
      child: wheel,
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
