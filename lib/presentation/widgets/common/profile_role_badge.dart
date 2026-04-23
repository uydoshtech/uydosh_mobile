import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Neumorphic role capsule (e.g. profile header).
class ProfileRoleNeumorphicBadge extends StatelessWidget {
  const ProfileRoleNeumorphicBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final bg = theme.cardTheme.color ?? scheme.surface;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, bg),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: 0.15,
                color: scheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
