import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/pending_gig_bookings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

/// Label chip + circular control (browser-style), opening "My bookings".
class GigHubMyBookingsFab extends StatefulWidget {
  const GigHubMyBookingsFab({super.key});

  @override
  State<GigHubMyBookingsFab> createState() => _GigHubMyBookingsFabState();
}

class _GigHubMyBookingsFabState extends State<GigHubMyBookingsFab> {
  static const double _fabSize = 46.0;
  static const double _pillRadiusValue = 16.0;

  bool _ordersPressed = false;
  bool _publishedPressed = false;

  void _setOrdersPressed(bool v) {
    if (_ordersPressed != v) setState(() => _ordersPressed = v);
  }

  void _setPublishedPressed(bool v) {
    if (_publishedPressed != v) setState(() => _publishedPressed = v);
  }

  void _openOrders() {
    UiFeedbackUtils.tap();
    context.pushMyGigBookings();
  }

  void _openPublished() {
    UiFeedbackUtils.tap();
    context.pushMyPublishedGigs();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final fg = themeState.isBlueTheme ? Colors.white : Colors.black;
    final base = theme.colorScheme.surface;
    final circleRadius = BorderRadius.circular(_fabSize / 2);
    final pillRadius = BorderRadius.circular(_pillRadiusValue);
    final label = L10n.get("gigs_hub_my_bookings_title");
    final publishedLabel = L10n.get("gigs_my_published_title");

    final labelText = Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: fg,
        fontWeight: FontWeight.w600,
      ),
    );

    final labelChip = LiquidGlassPlate(
      height: _fabSize,
      borderRadius: pillRadius,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.event_note_rounded, color: fg, size: 20),
            const SizedBox(width: 8),
            labelText,
          ],
        ),
      ),
    );

    final shadows = _publishedPressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    final circleIcon = Icon(Icons.layers_rounded, color: fg, size: 24);

    final circleLiquid = SizedBox(
      width: _fabSize,
      height: _fabSize,
      child: LiquidGlassPlate(
        height: _fabSize,
        borderRadius: circleRadius,
        child: Center(child: circleIcon),
      ),
    );

    final circleLegacy = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      width: _fabSize,
      height: _fabSize,
      decoration: BoxDecoration(
        borderRadius: circleRadius,
        boxShadow: shadows,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: circleRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
        ),
        child: Center(child: circleIcon),
      ),
    );

    final circleFab = useLiquidGlass ? circleLiquid : circleLegacy;
    final unreadColor = themeState.unreadIndicatorColor;

    return ListenableBuilder(
      listenable: PendingGigBookingsState(),
      builder: (context, _) {
        final pendingState = PendingGigBookingsState();
        final showDot = pendingState.hasPendingBookings;
        final ordersSemanticLabel =
            showDot ? "$label (${L10n.get("gigs_status_pending")})" : label;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: label,
              child: Semantics(
                button: true,
                label: ordersSemanticLabel,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  transform: Matrix4.translationValues(
                    0,
                    _ordersPressed ? 2 : 0,
                    0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => _setOrdersPressed(true),
                    onTapUp: (_) => _setOrdersPressed(false),
                    onTapCancel: () => _setOrdersPressed(false),
                    onTap: _openOrders,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        labelChip,
                        if (showDot)
                          Positioned(
                            right: -3,
                            top: 0,
                            child: PulseThenBlinkDotWidget(
                              trigger: pendingState.dotTrigger,
                              color: unreadColor,
                              size: 11,
                              blinkDuration: const Duration(milliseconds: 750),
                              borderColor: Colors.white,
                              borderWidth: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: publishedLabel,
              child: Semantics(
                button: true,
                label: publishedLabel,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  transform: Matrix4.translationValues(
                    0,
                    _publishedPressed ? 2 : 0,
                    0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => _setPublishedPressed(true),
                    onTapUp: (_) => _setPublishedPressed(false),
                    onTapCancel: () => _setPublishedPressed(false),
                    onTap: _openPublished,
                    child: circleFab,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
