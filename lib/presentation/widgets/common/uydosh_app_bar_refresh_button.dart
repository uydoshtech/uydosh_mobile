import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Circular 3D refresh action matching [TheDotDropMenuButton] chrome, with an
/// explicit icon color so the glyph stays visible on dark blue app bars.
class UydoshAppBarRefreshButton extends StatelessWidget {
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
              onTap:
                  enabled
                      ? () {
                        HapticFeedbackUtils.impact();
                        onPressed();
                      }
                      : null,
              customBorder: const CircleBorder(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    scheme.surface,
                  ),
                  boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Opacity(
                    opacity: enabled ? 1 : 0.45,
                    child: ThemeIcon(
                      Icons.refresh,
                      size: iconSize,
                      color: iconColor,
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
