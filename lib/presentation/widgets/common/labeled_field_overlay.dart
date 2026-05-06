import "package:flutter/material.dart";
import "package:uy_dosh/base/services/remote_config_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// Wraps [child] with a small label that sits at the top-left of the field,
/// straddling its border (half outside the field, half overlapping the top
/// edge). Mirrors the look of the example "Чат" label above the chat picker
/// on the gig request screen.
///
/// Use this for create/edit listing form fields (title, description, price)
/// where there's no built-in floating label and we want a persistent caption.
class LabeledFieldOverlay extends StatelessWidget {
  const LabeledFieldOverlay({
    required this.label,
    required this.child,
    super.key,
    this.horizontalInset = 16,
    this.topReserve = 7,
  });

  final String label;
  final Widget child;

  /// Distance from the left edge of the field to the start of the label.
  final double horizontalInset;

  /// Vertical room (in logical pixels) reserved at the top so the floating
  /// label can sit half over the field border without being clipped or
  /// pushing siblings around.
  final double topReserve;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: RemoteConfigService.showListingFormFieldLabels,
      builder: (context, showLabels, _) {
        if (!showLabels) {
          // Flag is off — render the bare child so layout matches what we'd
          // get without this wrapper at all.
          return child;
        }
        return _buildWithLabel(context);
      },
    );
  }

  Widget _buildWithLabel(BuildContext context) {
    final themeState = ThemeState();
    final theme = Theme.of(context);

    Color resolveColor() {
      if (themeState.isBlueTheme) {
        return Colors.white;
      }
      if (themeState.isLightTheme) {
        return Colors.black;
      }
      return theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85);
    }

    final labelColor = resolveColor();

    return Padding(
      padding: EdgeInsets.only(top: topReserve),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: -topReserve + 2,
            left: horizontalInset,
            child: IgnorePointer(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
