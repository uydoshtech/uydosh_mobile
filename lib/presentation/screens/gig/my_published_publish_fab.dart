import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Single pill FAB for publishing from [MyPublishedGigsScreen].
class MyPublishedPublishFab extends StatefulWidget {
  const MyPublishedPublishFab({
    required this.isService,
    required this.onPressed,
    super.key,
  });

  final bool isService;
  final VoidCallback onPressed;

  @override
  State<MyPublishedPublishFab> createState() => _MyPublishedPublishFabState();
}

class _MyPublishedPublishFabState extends State<MyPublishedPublishFab> {
  static const double _fabHeight = 46.0;
  static const double _pillRadiusValue = 16.0;

  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _onTap() {
    UiFeedbackUtils.tap();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final fg = themeState.isBlueTheme ? Colors.white : Colors.black;
    final base = theme.colorScheme.surface;
    final pillRadius = BorderRadius.circular(_pillRadiusValue);
    final label = L10n.get(
      widget.isService
          ? "gigs_my_published_add_service"
          : "gigs_my_published_add_task",
    );

    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      color: fg,
      fontWeight: FontWeight.w600,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.add_rounded, color: fg, size: 22),
        const SizedBox(width: 8),
        Text(label, style: labelStyle),
      ],
    );

    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    final pill = useLiquidGlass
        ? LiquidGlassPlate(
            height: _fabHeight,
            borderRadius: pillRadius,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(child: content),
          )
        : AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            height: _fabHeight,
            decoration: BoxDecoration(
              borderRadius: pillRadius,
              boxShadow: shadows,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: pillRadius,
                gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(child: content),
              ),
            ),
          );

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: _onTap,
            child: pill,
          ),
        ),
      ),
    );
  }
}
