import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";

/// Search control styled like [ThreeDAppBarIconButton]: neumorphic shadows from
/// [ThreeDSurfaceStyle], soft outer halo, and a light radial wash — matching header
/// chrome rather than a flat Material FAB.
class SearchFloatingActionButton extends StatefulWidget {
  const SearchFloatingActionButton({
    required this.searchFiltersState,
    super.key,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 25.0,
    this.elevation,
    this.replaceCurrentRoute = false,
    this.openedFromHomeScreen = false,
  });

  final SearchFiltersState searchFiltersState;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  final double? elevation;
  final bool replaceCurrentRoute;
  final bool openedFromHomeScreen;

  static const double _fabSize = 56.0;

  @override
  State<SearchFloatingActionButton> createState() =>
      _SearchFloatingActionButtonState();
}

class _SearchFloatingActionButtonState extends State<SearchFloatingActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.backgroundColor ?? theme.colorScheme.primary;
    final fg = widget.foregroundColor ?? Colors.white;
    final tip = widget.tooltip ?? L10n.get("search");
    final depthScale =
        ((widget.elevation ?? 10) / 10).clamp(0.55, 1.55).toDouble();

    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : [
            ..._fabOuterHaloShadows(
              base,
              depthScale,
              theme.brightness,
            ),
            ...ThreeDSurfaceStyle.elevatedShadows(context),
          ];

    return Tooltip(
      message: tip,
      child: Semantics(
        button: true,
        label: tip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed ?? () => _handleSearchPressed(context),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                width: SearchFloatingActionButton._fabSize,
                height: SearchFloatingActionButton._fabSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
                  boxShadow: shadows,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.55, -0.62),
                            radius: 1.05,
                            colors: [
                              Colors.white.withValues(
                                alpha: theme.brightness == Brightness.dark
                                    ? 0.22
                                    : 0.45,
                              ),
                              Colors.white.withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.28, 0.52],
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search,
                      size: (widget.iconSize ?? 25.0) * 1.1,
                      color: fg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSearchPressed(BuildContext context) {
    HapticFeedbackUtils.impact();

    widget.searchFiltersState.applyProfileValuesForSearchSheet().then((_) {
      if (!context.mounted) return;
      SearchBottomSheetWidget.show(
        context,
        replaceCurrentRoute: widget.replaceCurrentRoute,
        openedFromHomeScreen: widget.openedFromHomeScreen,
        currentListingTypeId: widget.searchFiltersState.selectedListingTypeId,
        currentLocationId: widget.searchFiltersState.selectedLocationIndex,
        currentSubwayStationId: widget.searchFiltersState.selectedStationId,
        currentSubwayLineId: widget.searchFiltersState.selectedSubwayLine,
        currentGender: widget.searchFiltersState.selectedGender,
        currentMinPrice: widget.searchFiltersState.minPrice,
        currentMaxPrice: widget.searchFiltersState.maxPrice,
      );
    });
  }
}

/// Soft colored glow behind the face (backlit halo), strongest top-left — same
/// idea as tutorial halos on app bar actions, tuned for the primary pill.
List<BoxShadow> _fabOuterHaloShadows(
  Color base,
  double depthScale,
  Brightness brightness,
) {
  final isDark = brightness == Brightness.dark;
  final cool = Color.lerp(base, const Color(0xFF9EB7E8), 0.42)!;
  return [
    BoxShadow(
      color: cool.withValues(alpha: isDark ? 0.38 : 0.22),
      blurRadius: 26 * depthScale,
      spreadRadius: 1.8 * depthScale,
      offset: Offset(-5 * depthScale, -5 * depthScale),
    ),
    BoxShadow(
      color: Color.lerp(base, Colors.white, 0.5)!
          .withValues(alpha: isDark ? 0.16 : 0.12),
      blurRadius: 16 * depthScale,
      spreadRadius: 0.5 * depthScale,
      offset: Offset(-2 * depthScale, -3 * depthScale),
    ),
  ];
}
