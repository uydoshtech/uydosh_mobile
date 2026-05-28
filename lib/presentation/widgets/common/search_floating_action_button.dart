import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";

/// Search control: on liquid-glass themes uses the same [LiquidGlassPlate] stack
/// as the home filters ribbon (plate wraps tap target; no Material/InkWell above
/// the blur). Otherwise [ThreeDSurfaceStyle] neumorphic fill + shadows.
class SearchFloatingActionButton extends StatefulWidget {
  const SearchFloatingActionButton({
    required this.searchFiltersState,
    super.key,
    this.onPressed,
    this.tooltip,
    this.iconData = Icons.search,
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
  final IconData iconData;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  final double? elevation;
  final bool replaceCurrentRoute;
  final bool openedFromHomeScreen;

  static const double fabSize = 56.0;

  @override
  State<SearchFloatingActionButton> createState() =>
      _SearchFloatingActionButtonState();
}

class _SearchFloatingActionButtonState extends State<SearchFloatingActionButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationSettingsState _animationSettings;
  late final AnimationController _idleController;
  late final CurvedAnimation _idleCurve;
  late final Animation<double> _idleTurns;
  bool _tickersEnabled = true;
  bool _lastWiggleEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationSettings = AnimationSettingsState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    );
    _idleCurve = CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    );
    _idleTurns = Tween<double>(begin: -0.012, end: 0.012).animate(_idleCurve);
    _animationSettings.addListener(_syncFromSettings);
    _syncFromSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickersEnabled = TickerMode.of(context);
    if (tickersEnabled != _tickersEnabled) {
      _tickersEnabled = tickersEnabled;
      _syncFromSettings();
    }
  }

  void _syncFromSettings() {
    if (!mounted) return;
    final wiggleEnabled = _animationSettings.bellIdleEnabled &&
        _animationSettings.uiAnimationsEnabled &&
        widget.iconData == Icons.add_alert &&
        _tickersEnabled;
    if (wiggleEnabled) {
      if (!_idleController.isAnimating) {
        _idleController.repeat(reverse: true);
      }
    } else {
      _idleController.stop();
      _idleController.value = 0.5;
    }
    if (_lastWiggleEnabled != wiggleEnabled) {
      _lastWiggleEnabled = wiggleEnabled;
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant SearchFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData) {
      _syncFromSettings();
    }
  }

  @override
  void dispose() {
    _animationSettings.removeListener(_syncFromSettings);
    _idleCurve.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    void setPressed(bool v) {
      if (_pressed != v) setState(() => _pressed = v);
    }

    void onFabTap() {
      // Ensure haptic is fired even when caller overrides `onPressed`.
      // `_handleSearchPressed` is the default path and intentionally does not
      // trigger haptics to avoid double feedback.
      HapticFeedbackUtils.impact();
      (widget.onPressed ?? () => _handleSearchPressed(context))();
    }

    // Mirrors `_buildInlineFiltersRibbon` on [HomeScreen]: [LiquidGlassPlate] is
    // the glass surface; interaction sits inside it (ribbon uses IconButtons).
    final Widget liquidBody = SizedBox(
      width: SearchFloatingActionButton.fabSize,
      height: SearchFloatingActionButton.fabSize,
      child: LiquidGlassPlate(
        height: SearchFloatingActionButton.fabSize,
        borderRadius: BorderRadius.circular(
          SearchFloatingActionButton.fabSize / 2,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setPressed(true),
          onTapUp: (_) => setPressed(false),
          onTapCancel: () => setPressed(false),
          onTap: onFabTap,
          child: _AnimatedFabIcon(
            iconData: widget.iconData,
            size: widget.iconSize,
            color: fg,
            idleTurns: _idleTurns,
            wiggle: _lastWiggleEnabled,
          ),
        ),
      ),
    );

    final Widget legacyBody = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: onFabTap,
        onHighlightChanged: setPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: SearchFloatingActionButton.fabSize,
          height: SearchFloatingActionButton.fabSize,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: shadows,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: ThreeDSurfaceStyle.surfaceGradient(
                context,
                base,
              ),
            ),
            child: _AnimatedFabIcon(
              iconData: widget.iconData,
              size: widget.iconSize,
              color: fg,
              idleTurns: _idleTurns,
              wiggle: _lastWiggleEnabled,
            ),
          ),
        ),
      ),
    );

    return Tooltip(
      message: tip,
      child: Semantics(
        button: true,
        label: tip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          child: useLiquidGlass ? liquidBody : legacyBody,
        ),
      ),
    );
  }

  void _handleSearchPressed(BuildContext context) {
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

class _AnimatedFabIcon extends StatelessWidget {
  const _AnimatedFabIcon({
    required this.iconData,
    required this.size,
    required this.color,
    required this.idleTurns,
    required this.wiggle,
  });

  final IconData iconData;
  final double? size;
  final Color color;
  final Animation<double> idleTurns;
  final bool wiggle;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      iconData,
      size: (size ?? 25.0) * 1.1,
      color: color,
    );

    return Center(
      child: wiggle
          ? RepaintBoundary(
              child: AnimatedBuilder(
                animation: idleTurns,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: idleTurns.value * 2 * 3.1415926535897932,
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
                child: icon,
              ),
            )
          : icon,
    );
  }
}
