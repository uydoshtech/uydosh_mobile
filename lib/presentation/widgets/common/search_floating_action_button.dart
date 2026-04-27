import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
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
    // Match the burger menu button chrome: use surface background and theme-based
    // icon color, without glossy highlight or outer halo.
    final base = widget.backgroundColor ?? theme.colorScheme.surface;
    final tip = widget.tooltip ?? L10n.get("search");
    // Match the profile button shape (circle-ish), but keep the same 56x56 size.
    final radius = const BorderRadius.all(Radius.circular(999));
    final fg =
        widget.foregroundColor ??
        (ThemeState().isBlueTheme ? Colors.white : Colors.black);

    final themeState = ThemeState();
    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

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
              borderRadius: radius,
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              onTap: widget.onPressed ?? () => _handleSearchPressed(context),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                width: SearchFloatingActionButton._fabSize,
                height: SearchFloatingActionButton._fabSize,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: shadows,
                ),
                child: useLiquidGlass
                    ? _LiquidGlassFabFace(
                        radius: radius,
                        base: base,
                        child: _FabIcon(size: widget.iconSize, color: fg),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: ThreeDSurfaceStyle.surfaceGradient(
                            context,
                            base,
                          ),
                        ),
                        child: _FabIcon(size: widget.iconSize, color: fg),
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

class _FabIcon extends StatelessWidget {
  const _FabIcon({required this.size, required this.color});

  final double? size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.search,
        size: (size ?? 25.0) * 1.1,
        color: color,
      ),
    );
  }
}

class _LiquidGlassFabFace extends StatelessWidget {
  const _LiquidGlassFabFace({
    required this.radius,
    required this.base,
    required this.child,
  });

  final BorderRadius radius;
  final Color base;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final baseTint =
        isDark
            ? BlueThemeColors.background
            : (Color.lerp(scheme.surface, scheme.primary, 0.08) ??
                scheme.surface);
    final stroke =
        (isDark ? Colors.white : Colors.black).withValues(
          alpha: isDark ? 0.12 : 0.08,
        );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: (AnimationSettingsState().uiAnimationsEnabled &&
                  !(MediaQuery.maybeOf(context)?.disableAnimations ?? false))
              ? 18
              : 0,
          sigmaY: (AnimationSettingsState().uiAnimationsEnabled &&
                  !(MediaQuery.maybeOf(context)?.disableAnimations ?? false))
              ? 18
              : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: baseTint.withValues(alpha: isDark ? 0.38 : 0.62),
            border: Border.all(color: stroke, width: 0.6),
            gradient: RadialGradient(
              center: const Alignment(-0.45, -0.55),
              radius: 1.1,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.18 : 0.34),
                Colors.transparent,
              ],
              stops: const [0.0, 0.65],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
