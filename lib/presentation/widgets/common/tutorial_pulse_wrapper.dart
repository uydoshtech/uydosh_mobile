import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/pulsing_border_wrapper.dart";

/// Standardized halo pulse for tutorial spotlights.
///
/// Keeps pulse visuals consistent across surfaces (FAB, AppBar action icons).
class TutorialPulseWrapper extends StatelessWidget {
  const TutorialPulseWrapper({
    required this.child,
    super.key,
    this.enabled = true,
    this.variant = TutorialPulseVariant.appBarAction,
  });

  final Widget child;
  final bool enabled;
  final TutorialPulseVariant variant;

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeState().isBlueTheme;

    switch (variant) {
      case TutorialPulseVariant.floatingActionButton:
        return PulsingBorderWrapper(
          enabled: enabled,
          scaleTo: 1.14,
          haloColor: isBlue
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.24),
          haloBlurRadius: isBlue ? 18 : 32,
          haloSpreadRadius: isBlue ? 0.5 : 1.8,
          padding: const EdgeInsets.all(2),
          child: child,
        );
      case TutorialPulseVariant.appBarAction:
        return PulsingBorderWrapper(
          enabled: enabled,
          scaleTo: 1.12,
          haloColor: Colors.white.withValues(alpha: 0.22),
          haloBlurRadius: 18,
          haloSpreadRadius: 0.6,
          padding: const EdgeInsets.all(2),
          child: child,
        );
    }
  }
}

enum TutorialPulseVariant { floatingActionButton, appBarAction }

