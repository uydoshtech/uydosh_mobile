import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

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
        final maxIdx =
            widget.locations.isEmpty ? 0 : widget.locations.length;
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

  static const BorderRadius _plateRadius = BorderRadius.all(Radius.circular(10));

  /// Raised control surface: soft gradient, beveled edges, and cast shadow.
  BoxDecoration _locationPickerPlateDecoration({
    required ThemeData theme,
    required Color baseSurface,
    required bool isBlueTheme,
    required bool showError,
  }) {
    if (showError) {
      return BoxDecoration(
        borderRadius: _plateRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(baseSurface, Colors.white, isBlueTheme ? 0.12 : 0.22)!,
            baseSurface,
            Color.lerp(baseSurface, Colors.black, isBlueTheme ? 0.2 : 0.06)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: theme.colorScheme.error, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isBlueTheme ? 0.42 : 0.1),
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isBlueTheme ? 0.28 : 0.05),
            offset: const Offset(0, 5),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ],
      );
    }

    final topLeftEdge = Color.lerp(
      baseSurface,
      Colors.white,
      isBlueTheme ? 0.22 : 0.65,
    )!.withValues(alpha: isBlueTheme ? 0.55 : 0.95);
    final bottomRightEdge = Color.lerp(
      baseSurface,
      Colors.black,
      isBlueTheme ? 0.45 : 0.18,
    )!;

    return BoxDecoration(
      borderRadius: _plateRadius,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(baseSurface, Colors.white, isBlueTheme ? 0.14 : 0.38)!,
          baseSurface,
          Color.lerp(baseSurface, Colors.black, isBlueTheme ? 0.22 : 0.07)!,
        ],
        stops: const [0.0, 0.48, 1.0],
      ),
      border: Border(
        top: BorderSide(color: topLeftEdge, width: 1),
        left: BorderSide(color: topLeftEdge, width: 1),
        right: BorderSide(
          color: bottomRightEdge.withValues(alpha: isBlueTheme ? 0.65 : 0.35),
          width: 1,
        ),
        bottom: BorderSide(
          color: bottomRightEdge.withValues(alpha: isBlueTheme ? 0.9 : 0.5),
          width: 2,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isBlueTheme ? 0.48 : 0.12),
          offset: const Offset(0, 3),
          blurRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isBlueTheme ? 0.32 : 0.06),
          offset: const Offset(0, 5),
          blurRadius: 10,
          spreadRadius: -1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayLocations = widget.locations;
    final isBlueTheme = ThemeState().isBlueTheme;
    final backgroundColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceContainerHighest;
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    final plateDecoration = _locationPickerPlateDecoration(
      theme: theme,
      baseSurface: backgroundColor,
      isBlueTheme: isBlueTheme,
      showError: widget.showError,
    );

    if (widget.isLoading) {
      return _PickerChrome(
        height: widget.height,
        decoration: plateDecoration,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final selectionOverlayFill =
        theme.colorScheme.onSurface.withValues(alpha: isBlueTheme ? 0.14 : 0.07);

    return _PickerChrome(
      key: widget.containerKey != null ? ValueKey(widget.containerKey) : null,
      height: widget.height,
      decoration: plateDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: selectionOverlayFill,
              ),
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
                        ThemeIcon(Icons.location_on, color: iconColor, size: 20),
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
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
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

/// 3D plate behind the wheel: keeps chrome out of the picker subtree and uses
/// [Stack.clipBehavior] none so ListWheelScrollView paint is not hard-clipped.
class _PickerChrome extends StatelessWidget {
  const _PickerChrome({
    required this.height,
    required this.decoration,
    required this.child,
    super.key,
  });

  final double height;
  final BoxDecoration decoration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: decoration,
            child: const SizedBox.expand(),
          ),
          child,
        ],
      ),
    );
  }
}
