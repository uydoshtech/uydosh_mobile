import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Circular 3D refresh action matching [TheDotDropMenuButton] chrome, with an
/// explicit icon color so the glyph stays visible on dark blue app bars.
class UydoshAppBarRefreshButton extends StatefulWidget {
  const UydoshAppBarRefreshButton({
    required this.onPressed,
    super.key,
    this.enabled = true,
    this.iconSize = 28,
  });

  final VoidCallback onPressed;
  final bool enabled;
  final double iconSize;

  @override
  State<UydoshAppBarRefreshButton> createState() =>
      _UydoshAppBarRefreshButtonState();
}

class _UydoshAppBarRefreshButtonState extends State<UydoshAppBarRefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _turns;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _turns = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    HapticFeedbackUtils.impact();
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final iconColor = ThemeState().textColor;

        return Tooltip(
          message: L10n.get("refresh"),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.enabled ? _handleTap : null,
              onHighlightChanged:
                  widget.enabled ? (v) => setState(() => _pressed = v) : null,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    scheme.surface,
                  ),
                  boxShadow:
                      _pressed || !widget.enabled
                          ? ThreeDSurfaceStyle.pressedShadows(context)
                          : ThreeDSurfaceStyle.elevatedShadows(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Opacity(
                    opacity: widget.enabled ? 1 : 0.45,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0, end: 1).animate(_turns),
                      child: ThemeIcon(
                        Icons.refresh,
                        size: widget.iconSize,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
